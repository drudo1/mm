using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace MunchkinMonitor.Classes
{
    public enum RoomStates
    {
        TournamentScoreBoard,
        Game,
        GameResults
    }

    [Serializable]
    public class AppState
    {
        private static AppState _curState;

        public static AppState CurrentState
        {
            get
            {
                if (_curState == null)
                {
                    _curState = new AppState();
                    _curState.Rooms = RoomState.LoadRooms();
                    _curState.ScoreBoardGamePairings = new Dictionary<string, string>();
                }
                return _curState;
            }
            set
            {
                _curState = value;
            }
        }

        public Dictionary<string, string> ScoreBoardGamePairings { get; set; }
        public Dictionary<string, RoomState> Rooms { get; set; }
        public string LinkScoreBoardToRoom(string boardName, string roomKey)
        {
            if (ScoreBoardGamePairings.ContainsKey(boardName))
                return "Board Name is Already in Use.";
            else if (!Rooms.Values.Cast<RoomState>().ToList().Exists(r => r.RoomKey == roomKey))
                return "Invalid Room Key.";
            else
            {
                HttpContext.Current.Session["boardName"] = boardName;
                RoomState room = Rooms.Values.Cast<RoomState>().Where(r => r.RoomKey == roomKey).FirstOrDefault();
                HttpContext.Current.Session["RoomID"] = room.RoomID;
                int gameID = -1;
                if (room.games.Cast<Game>().ToList().Exists(g => g.ScoreBoardName == boardName))
                    gameID = room.games.Cast<Game>().Where(g => g.ScoreBoardName == boardName).FirstOrDefault().GameID;
                ScoreBoardGamePairings.Add(boardName, gameID.ToString());
                return "LoggedIn";
            }
        }
        public string JoinRoom(string roomKey)
        {
            if (!Rooms.Values.Cast<RoomState>().ToList().Exists(r => r.RoomKey == roomKey))
                return "Invalid Room Key.";
            else
            {
                HttpContext.Current.Session["RoomID"] = Rooms.Values.Cast<RoomState>().Where(r => r.RoomKey == roomKey).FirstOrDefault().RoomID;
                return "JoinedRoom";
            }
        }
        public void NewRoom(string name, string roomKey)
        {
            int id = Rooms.Values.Cast<RoomState>().Max(mr => mr.RoomID) + 1;
            RoomState r = new RoomState(id, name, roomKey);
            Rooms[id.ToString()] = r;
            HttpContext.Current.Session["RoomID"] = r.RoomID;
        }
    }

    [Serializable]
    public class RoomState
    {
        public RoomStates currentState { get; set; }
        public int RoomID { get; set; }
        public string RoomKey { get; set; }
        public string Name { get; set; }
        public Dictionary<string, Game> games { get; set; }
        public PlayerStats playerStats { get; set; }
        public DateTime stateUpdated { get; set; }
        public string currentStateDescription
        {
            get
            {
                return currentState.ToString();
            }
        }
        public double stateUpdatedJS
        {
            get
            {
                return stateUpdated.Subtract(new DateTime(1970, 1, 1).AddHours(-6)).TotalMilliseconds;
            }
        }
        public bool PairedToGame
        {
            get
            {
                if (HttpContext.Current.Session["boardName"] != null && (AppState.CurrentState.ScoreBoardGamePairings[HttpContext.Current.Session["boardName"].ToString()] != "-1"))
                {
                    HttpContext.Current.Session["GameID"] = AppState.CurrentState.ScoreBoardGamePairings[HttpContext.Current.Session["boardName"].ToString()];
                    return true;
                }
                else
                    return false;
            }
        }

        public static RoomState CurrentState
        {
            get
            {
                RoomState room = null;
                if (HttpContext.Current.Session["RoomID"] != null && AppState.CurrentState.Rooms != null)
                {
                    room = (RoomState)AppState.CurrentState.Rooms[HttpContext.Current.Session["RoomID"].ToString()];
                }
                return room;
            }
        }

        public RoomState() { }
        
        public RoomState(int roomid, string name, string key)
        {
            RoomID = roomid;
            Name = name;
            RoomKey = key;
            games = new Dictionary<string, Game>();
            playerStats = new PlayerStats();
            Update();
        }

        public static Dictionary<string, RoomState> LoadRooms()
        {
            Dictionary<string, RoomState> tbl = new Dictionary<string, RoomState>();
            string path = HttpContext.Current.Server.MapPath("~/") + "rooms.xml";
            XmlSerializer serializer = new XmlSerializer(typeof(List<RoomMembership>));
            if (File.Exists(path))
            {
                List<RoomMembership> rooms = new List<RoomMembership>();
                using (FileStream stream = File.OpenRead(path))
                {
                    rooms = ((List<RoomMembership>)serializer.Deserialize(stream)).ToList();
                }
                foreach(RoomMembership r in rooms)
                {
                    tbl[r.RoomID.ToString()] = new RoomState(r.RoomID, r.RoomName, r.RoomKey);
                }
            }
            return tbl;
        }

        public void SetState(RoomStates newState)
        {
            currentState = newState;
            stateUpdated = DateTime.Now;
        }

        public void NewGame(string name, bool isEpic, string sbName)
        {
            int id = 1;
            if(games.Count > 0)
                id = games.Values.Cast<Game>().Max(cg => cg.GameID) + 1;
            Game g = new Game(id, name, isEpic);
            g.ScoreBoardName = sbName;
            games[id.ToString()] = g;
            if (AppState.CurrentState.ScoreBoardGamePairings[sbName] != null)
                AppState.CurrentState.ScoreBoardGamePairings[sbName] = id.ToString();
            SetState(RoomStates.Game);
            HttpContext.Current.Session["GameID"] = g.GameID;
        }

        public void CancelGame()
        {
            if (games.Values.Cast<Game>().ToList().Exists(g => g.GameID == (int)HttpContext.Current.Session["GameID"]))
                games.Remove(HttpContext.Current.Session["GameID"].ToString());
            HttpContext.Current.Session.Remove("GameID");
            SetState(RoomStates.TournamentScoreBoard);
        }

        public void EndGame()
        {
            if (games[HttpContext.Current.Session["GameID"].ToString()] != null)
            {
                ((Game)games[HttpContext.Current.Session["GameID"].ToString()]).LogWinner();
                SetState(RoomStates.GameResults);
            }
        }

        public void LoadScoreboard()
        {
            playerStats = new PlayerStats();
            SetState(RoomStates.TournamentScoreBoard);
        }

        public List<Trophy> GetGameResults()
        {
            return GameStats.GetTrophies();
        }

        public void LoadPlayers()
        {
            playerStats = new PlayerStats();
        }
        public void Update()
        {
            stateUpdated = DateTime.Now;
        }
    }

    [Serializable]
    public class PlayerState
    {
        public double stateUpdatedJS
        {
            get
            {
                if(RoomState.CurrentState != null)
                    return RoomState.CurrentState.stateUpdated.Subtract(new DateTime(1970, 1, 1).AddHours(-6)).TotalMilliseconds;
                else
                    return DateTime.MinValue.Subtract(new DateTime(1970, 1, 1).AddHours(-6)).TotalMilliseconds;
            }
        }
        public void Update()
        {
            RoomState.CurrentState.Update();
        }
        public bool loggedIn
        {
            get
            {
                return HttpContext.Current.Session["PlayerID"] != null;
            }
        }
        public bool inRoom
        {
            get
            {
                return HttpContext.Current.Session["RoomID"] != null;
            }
        }
        public bool inGame
        {
            get
            {
                return HttpContext.Current.Session["GameID"] != null;
            }
        }
        public CurrentGamePlayer Player
        {
            get
            {
                if (HttpContext.Current.Session["RoomID"] != null && HttpContext.Current.Session["GameID"] != null && HttpContext.Current.Session["PlayerID"] != null)
                    return Game.CurrentGame.players.Where(p => p.currentPlayer.PlayerID == (int)HttpContext.Current.Session["PlayerID"]).FirstOrDefault();
                else
                    return null;
            }
        }
        public List<string> PlayerRooms
        {
            get
            {
                if (HttpContext.Current.Session["PlayerID"] != null)
                    return RoomMembership.CurrentPlayerRooms;
                else
                    return new List<string>();
            }
        }
        public List<string> AvailableGames
        {
            get
            {
                if (HttpContext.Current.Session["RoomID"] != null && HttpContext.Current.Session["PlayerID"] != null)
                    return CurrentRoomState.games.Values.Cast<Game>().Select(g => string.Format("{0}|{1}", g.GameID, g.Name)).ToList();
                else
                    return new List<string>();
            }
        }
        public string DisplayName
        {
            get
            {
                return Player == null ? null : Player.currentPlayer.DisplayName;
            }
        }
        public int CurrentLevel
        {
            get
            {
                return Player == null ? 0 : Player.CurrentLevel;
            }
        }
        public int FightingLevel
        {
            get
            {
                return Player == null ? 0 : Player.FightingLevel;
            }
        }
        public int AllyLevel
        {
            get
            {
                return Player == null ? 0 : Player.AllyLevel;
            }
        }
        public string Race
        {
            get
            {
                return Player == null ? null : Player.currentRaces;
            }
        }
        public string Gender
        {
            get
            {
                return Player == null ? null : Player.CurrentGender.ToString();
            }
        }
        public string Class
        {
            get
            {
                return Player == null ? null : Player.currentClasses;
            }
        }
        public bool myTurn
        {
            get
            {
                return Player == null || Game.CurrentGame == null || Game.CurrentGame.currentPlayer == null ? false : Player.currentPlayer.PlayerID == Game.CurrentGame.currentPlayer.currentPlayer.PlayerID;
            }
        }
        public bool CanAlly
        {
            get
            {
                return Player == null ? false : Game.CurrentGame.currentState == GameStates.Battle && !myTurn && !Game.CurrentGame.currentBattle.HasAlly;
            }
        }
        public int GearBonus
        {
            get
            {
                return Player == null ? 0 : Player.GearBonus;
            }
        }
        public bool HasSteeds
        {
            get
            {
                return Player == null ? false : Player.HasSteeds;
            }
        }
        public bool HasHirelings
        {
            get
            {
                return Player == null ? false : Player.HasHirelings;
            }
        }
        public List<CharacterHelper> Steeds
        {
            get
            {
                return Player == null ? null : Player.Steeds;
            }
        }
        public List<CharacterHelper> Hirelings
        {
            get
            {
                return Player == null ? null : Player.Hirelings;
            }
        }
        public bool IsInBattle
        {
            get
            {
                return Game.CurrentGame == null ? false :  Game.CurrentGame.currentState == GameStates.Battle && myTurn;
            }
        }
        public Battle currentBattle
        {
            get
            {
                return IsInBattle ? Game.CurrentGame.currentBattle : null;
            }
        }
        public RoomState CurrentRoomState
        {
            get
            {
                return RoomState.CurrentState;
            }
        }
        public Game currentGame
        {
            get
            {
                return Game.CurrentGame;
            }
        }
    }
}
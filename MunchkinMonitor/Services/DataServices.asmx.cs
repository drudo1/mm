using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using MunchkinMonitor.Classes;
using System.Web.Script.Services;
using System.IO;

namespace MunchkinMonitor.Services
{
    /// <summary>
    /// Summary description for DataServices
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    public class DataServices : System.Web.Services.WebService
    {

        [WebMethod(EnableSession = true)]
        public string LinkScoreBoardToRoom(string boardName, string roomKey)
        {
            return AppState.CurrentState.LinkScoreBoardToRoom(boardName, roomKey);
        }

        [WebMethod(EnableSession = true)]
        public bool CheckForStateUpdate(DateTime lastUpdate)
        {
            bool result = false;
            if (HttpContext.Current.Session["GameID"] != null)
            {
                if ((Classes.Game.CurrentGame.lastUpdated.Minute != lastUpdate.Minute || (Classes.Game.CurrentGame.lastUpdated.Minute == lastUpdate.Minute && Classes.Game.CurrentGame.lastUpdated.Second > lastUpdate.Second)))
                    result = true;
            }
            else if (HttpContext.Current.Session["RoomID"] != null)
            {
                if ((RoomState.CurrentState.stateUpdated.Minute != lastUpdate.Minute || (RoomState.CurrentState.stateUpdated.Minute == lastUpdate.Minute && RoomState.CurrentState.stateUpdated.Second > lastUpdate.Second)))
                    result = true;
            }
            else
                result = true;
            return result;
        }

        [WebMethod(EnableSession = true)]
        public RoomState GetCurrentRoomState()
        {
            return RoomState.CurrentState;
        }

        [WebMethod(EnableSession = true)]
        public Classes.Game GetCurrentGameState()
        {
            return Classes.Game.CurrentGame;
        }

        [WebMethod(EnableSession = true)]
        public AppState GetControllerState()
        {
            return AppState.CurrentState;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState GetPlayerState()
        {
            return new PlayerState();
        }

        [WebMethod(EnableSession = true)]
        public PlayerState PlayerEnterRoom(int id)
        {
            Session["RoomID"] = id;
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public PlayerState PlayerExitRoom()
        {
            Session.Remove("RoomID");
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public PlayerState PlayerLeaveRoom()
        {
            RoomMembership.LeaveRoom();
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public string PlayerCreateRoom(string name, string key)
        {
            return RoomMembership.AddNewRoom(name, key);
        }

        [WebMethod(EnableSession = true)]
        public string PlayerJoinRoom(string key)
        {
            return RoomMembership.JoinRoom(key);
        }

        [WebMethod(EnableSession = true)]
        public void LoadScoreboard()
        {
            RoomState state = RoomState.CurrentState;
            state.LoadScoreboard();
        }

        [WebMethod(EnableSession = true)]
        public void LoadPlayers()
        {
            RoomState state = RoomState.CurrentState;
            state.LoadPlayers();
        }

        [WebMethod(EnableSession = true)]
        public PlayerState PlayerJoinGame(int id)
        {
            Session["GameID"] = id;
            if (HttpContext.Current.Session["PlayerID"] != null)
                Classes.Game.CurrentGame.AddExistingPlayer((int)HttpContext.Current.Session["PlayerID"]);
            RoomState.CurrentState.Update();
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public void NewGame(string name, bool isEpic, string sbName)
        {
            RoomState state = RoomState.CurrentState;
            state.NewGame(name, isEpic, sbName);
            if(HttpContext.Current.Session["PlayerID"] != null)
                Classes.Game.CurrentGame.AddExistingPlayer((int)HttpContext.Current.Session["PlayerID"]);
            RoomState.CurrentState.Update();
        }

        [WebMethod(EnableSession = true)]
        public void AddExistingPlayer(int id)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                state.AddExistingPlayer(id);
            }
        }

        [WebMethod(EnableSession = true)]
        public void AddNewPlayer(string username, string password, string firstName, string lastName, string nickName, Gender gender)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                state.AddNewPlayer(username, password, firstName, lastName, nickName, gender);
            }
        }

        [WebMethod(EnableSession = true)]
        public string LoginPlayer(string username, string password)
        {
            int id = Player.Login(username, password);
            if (id > 0)
            {
                Session["PlayerID"] = id;
                return "LoggedIn";
            }
            else
                return "LoginFailed";
        }

        [WebMethod(EnableSession =true)]
        public void LoginNewPlayer(string username, string password, string firstName, string lastName, string nickName, Gender gender)
        {
            int id = Player.AddNewPlayer(username, password, firstName, lastName, nickName, gender);
            Session["PlayerID"] = id;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState StartGame()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                state.StartGame();
            }
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public void StartGameWithPlayer(int PlayerID)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                state.StartGame(PlayerID);
            }
        }

        [WebMethod(EnableSession = true)]
        public List<CharacterModifier> GetRaceList()
        {
            return CharacterModifier.GetRaceList();
        }

        [WebMethod(EnableSession = true)]
        public List<CharacterModifier> GetClassList()
        {
            return CharacterModifier.GetClassList();
        }

        [WebMethod(EnableSession = true)]
        public void AddLevel()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    state.currentPlayer.CurrentLevel++;
                    state.Update();
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public int AddPlayerLevel()
        {
            int newLevel = 0;
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                state.Player.CurrentLevel++;
                state.Update();
                newLevel = state.CurrentLevel;
            }
            return newLevel;
        }

        [WebMethod(EnableSession = true)]
        public void UpdateGear(int amount)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    state.currentPlayer.GearBonus += amount;
                    GameStats.LogMaxGear(state.currentPlayer.currentPlayer.PlayerID, state.currentPlayer.GearBonus);
                    state.Update();
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public PlayerState UpdatePlayerGear(int amount)
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                (new PlayerState()).Player.GearBonus += amount;
                GameStats.LogMaxGear((new PlayerState()).Player.currentPlayer.PlayerID, (new PlayerState()).Player.GearBonus);
                state.Update();
            }
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public void NextRace()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    state.currentPlayer.NextRace();
                    state.Update();
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public void ToggleHalfBreed()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    state.currentPlayer.ToggleHalfBreed();
                    state.Update();
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public void NextHalfBreed()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    state.currentPlayer.NextHalfBreed();
                    state.Update();
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public void ToggleSuperMunchkin()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    state.currentPlayer.ToggleSuperMunchkin();
                    state.Update();
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public void NextSMClass()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    state.currentPlayer.NextSMClass();
                    state.Update();
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public void NextClass()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    state.currentPlayer.NextClass();
                    state.Update();
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public void ChangeGender(int penalty)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    state.currentPlayer.ChangeGender(penalty);
                    state.Update();
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public string ChangePlayerGender()
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                state.Player.ChangeGender(0);
                state.Update();
            }
            return GetPlayerState().Gender;
        }

        [WebMethod(EnableSession = true)]
        public string NextPlayerRace()
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                state.Player.NextRace();
                state.Update();
            }
            return GetPlayerState().Race;
        }

        [WebMethod(EnableSession = true)]
        public string TogglePlayerHalfBreed()
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                state.Player.ToggleHalfBreed();
                state.Update();
            }
            return GetPlayerState().Race;
        }

        [WebMethod(EnableSession = true)]
        public string NextPlayerHalfBreed()
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                state.Player.NextHalfBreed();
                state.Update();
            }
            return GetPlayerState().Race;
        }

        [WebMethod(EnableSession = true)]
        public string TogglePlayerSuperMunchkin()
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                state.Player.ToggleSuperMunchkin();
                state.Update();
            }
            return GetPlayerState().Class;
        }

        [WebMethod(EnableSession = true)]
        public string NextPlayerSMClass()
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                state.Player.NextSMClass();
                state.Update();
            }
            return GetPlayerState().Class;
        }

        [WebMethod(EnableSession = true)]
        public string NextPlayerClass()
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                state.Player.NextClass();
                state.Update();
            }
            return GetPlayerState().Class;
        }

        [WebMethod(EnableSession = true)]
        public void KillCurrentPlayer()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    state.currentPlayer.Die();
                    state.Update();
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public void AddHelper(bool steed, int bonus)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    state.currentPlayer.AddHelper(steed, bonus);
                    state.Update();
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public CurrentGamePlayer AddPlayerHelper(bool steed, int bonus)
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                state.Player.AddHelper(steed, bonus);
                state.Update();
            }
            return GetPlayerState().Player;
        }

        [WebMethod(EnableSession = true)]
        public void UpdateHelperGear(Guid helperID, int amount)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    CharacterHelper hlp = state.currentPlayer.Helpers.Where(h => h.ID == helperID).FirstOrDefault();
                    if (hlp != null)
                    {
                        hlp.GearBonus += amount;
                        state.Update();
                    }
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public int UpdatePlayerHelperGear(Guid helperID, int amount)
        {
            int newGear = 0;
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                CharacterHelper hlp = state.Player.Helpers.Where(h => h.ID == helperID).FirstOrDefault();
                if (hlp != null)
                {
                    hlp.GearBonus += amount;
                    state.Update();
                    newGear = hlp.GearBonus;
                }
            }
            return newGear;
        }

        [WebMethod(EnableSession = true)]
        public void ChangeHelperRace(Guid helperID)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    CharacterHelper hlp = state.currentPlayer.Helpers.Where(h => h.ID == helperID).FirstOrDefault();
                    if (hlp != null)
                    {
                        hlp.ChangeRace();
                        state.Update();
                    }
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public string ChangePlayerHelperRace(Guid helperID)
        {
            string race = "";
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                CharacterHelper hlp = state.Player.Helpers.Where(h => h.ID == helperID).FirstOrDefault();
                if (hlp != null)
                {
                    hlp.ChangeRace();
                    state.Update();
                    race = hlp.Race;
                }
            }
            return race;
        }

        [WebMethod(EnableSession = true)]
        public void KillHelper(Guid helperID)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    if(state.currentPlayer.Helpers.Where(h => h.ID == helperID).Count() > 0)
                    {
                        state.currentPlayer.Helpers.Remove(state.currentPlayer.Helpers.Where(h => h.ID == helperID).FirstOrDefault());
                        state.Update();
                    }
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public PlayerState KillPlayerHelper(Guid helperID)
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                if (state.Player.Helpers.Where(h => h.ID == helperID).Count() > 0)
                {
                    state.Player.Helpers.Remove(state.Player.Helpers.Where(h => h.ID == helperID).FirstOrDefault());
                    state.Update();
                }
            }
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public void SubtractLevel()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    if (state.currentPlayer.CurrentLevel > 1)
                    {
                        state.currentPlayer.CurrentLevel--;
                        GameStats.LogLevelLost(state.currentPlayer.currentPlayer.PlayerID);
                        state.Update();
                    }
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public int SubtractPlayerLevel()
        {
            int newLevel = 0;
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                state.Player.CurrentLevel--;
                GameStats.LogLevelLost((new PlayerState()).Player.currentPlayer.PlayerID);
                state.Update();
                newLevel = state.Player.CurrentLevel;
            }
            return newLevel;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState NextPlayer()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                state.NextPlayer();
                state.Update();
            }
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public PlayerState IAmNext()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                state.playerSeats.Add((int)Session["PlayerID"]);
                if (state.playerSeats.Count == state.players.Where(p => !p.DroppedOut).Count() - 1)
                    state.playerSeats.Add(state.players.Where(p => !p.DroppedOut && !state.playerSeats.Contains(p.currentPlayer.PlayerID)).FirstOrDefault().currentPlayer.PlayerID);
                state.currentPlayer = state.players.Where(p => p.currentPlayer.PlayerID == (int)Session["PlayerID"]).FirstOrDefault();
                state.currentState = GameStates.BattlePrep;
                state.NeedNextPlayer = false;
                state.Update();
            }
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public void PrevPlayer()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                state.PrevPlayer();
                state.Update();
            }
        }

        [WebMethod(EnableSession = true)]
        public void StartBattle(int level, int levelsToWin, int treasures)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            state.StartBattle(level, levelsToWin, treasures);
            state.Update();
        }

        [WebMethod(EnableSession = true)]
        public PlayerState StartEmptyBattle()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            state.StartEmptyBattle();
            state.Update();
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public Battle BattleBonus(int amount)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if(state.currentBattle != null)
                {
                    state.currentBattle.playerOneTimeBonus += amount;
                    state.Update();
                }
            }
            return GetPlayerState().currentBattle;
        }

        [WebMethod(EnableSession = true)]
        public Battle AddFirstMonster(int level, int levelsToWin, int treasures)
        {
            int idx = -1;
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                idx = state.AddMonsterToBattle(level, levelsToWin, treasures);
                state.Update();
            }
            return GetPlayerState().currentBattle;
        }

        [WebMethod(EnableSession = true)]
        public Monster AddMonster(int level, int levelsToWin, int treasures)
        {
            Monster m = null;
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                int idx = state.AddMonsterToBattle(level, levelsToWin, treasures);
                m = GetPlayerState().currentBattle.opponents[idx];
                state.Update();
            }
            return m;
        }

        [WebMethod(EnableSession = true)]
        public Battle RemoveMonster(int monsterIDX)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                state.RemoveMonster(monsterIDX);
                state.Update();
            }
            return GetPlayerState().currentBattle;
        }

        [WebMethod(EnableSession = true)]
        public Monster UpdateMonsterLevel(int monsterIDX, int amount)
        {
            Monster m = null;
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentBattle != null)
                {
                    m = state.currentBattle.opponents[monsterIDX];
                    m.Level += amount;
                    state.Update();
                }
            }
            return m;
        }

        [WebMethod(EnableSession = true)]
        public Monster UpdateMonsterBonus(int monsterIDX, int amount)
        {
            Monster m = null;
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentBattle != null)
                {
                    m = state.currentBattle.opponents[monsterIDX];
                    m.OneTimeBonus += amount;
                    state.Update();
                }
            }
            return m;
        }

        [WebMethod(EnableSession = true)]
        public Monster UpdateMonsterLTW(int monsterIDX, int amount)
        {
            Monster m = null;
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentBattle != null)
                {
                    m = state.currentBattle.opponents[monsterIDX];
                    m.LevelsToWin += amount;
                    state.Update();
                }
            }
            return m;
        }

        [WebMethod(EnableSession = true)]
        public Monster UpdateMonsterTreasures(int monsterIDX, int amount)
        {
            Monster m = null;
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentBattle != null)
                {
                    m = state.currentBattle.opponents[monsterIDX];
                    m.Treasures += amount;
                    state.Update();
                }
            }
            return m;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState AddAlly(int allyID, int allyTreasures)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                state.AddAlly(allyID, allyTreasures);
                state.Update();
            }
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public void AddPlayerAsAlly(string allyTreasures)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                state.AddAlly((int)Session["PlayerID"], Convert.ToInt32(allyTreasures));
                state.Update();
            }
        }

        [WebMethod(EnableSession = true)]
        public PlayerState OfferToAlly(string allyTreasures)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                state.OfferToAlly((int)Session["PlayerID"], Convert.ToInt32(allyTreasures));
                state.Update();
            }
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public Battle RemoveAlly()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                state.RemoveAlly();
                state.Update();
            }
            return GetPlayerState().currentBattle;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState CancelBattle()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                state.CancelBattle();
                state.Update();
            }
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public PlayerState ResolveBattle()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                state.ResolveBattle();
                state.Update();
            }
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public PlayerState CompleteBattle()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                state.currentBattle = null;
                state.SetState(GameStates.Battle);
                state.Update();
            }
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public void CancelGame()
        {
            RoomState state = RoomState.CurrentState;
            state.CancelGame();
        }

        [WebMethod(EnableSession = true)]
        public void EndGame()
        {
            RoomState state = RoomState.CurrentState;
            state.EndGame();
        }

        [WebMethod(EnableSession = true)]
        public List<Trophy> GetTrophies()
        {
            return GameStats.GetTrophies();
        }

        [WebMethod(EnableSession = true)]
        public PlayerState ToggleEpic()
        {
            Classes.Game.CurrentGame.isEpic = !Classes.Game.CurrentGame.isEpic;
            Classes.Game.CurrentGame.Update();
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public PlayerState ResetGame()
        {
            List<int> players = Classes.Game.CurrentGame.players.Select(p => p.currentPlayer.PlayerID).ToList();
            RoomState.CurrentState.games[HttpContext.Current.Session["GameID"].ToString()] = new Classes.Game(Classes.Game.CurrentGame.GameID, Classes.Game.CurrentGame.Name, Classes.Game.CurrentGame.isEpic);
            foreach(int p in players)
            {
                Classes.Game.CurrentGame.AddExistingPlayer(p);
            }
            Classes.Game.CurrentGame.Update();
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public void SellItem(int amount)
        {
            Classes.Game state = Classes.Game.CurrentGame;
            if (state != null)
            {
                if (state.currentPlayer != null)
                {
                    state.currentPlayer.SellItem(amount);
                    state.Update();
                }
            }
        }

        [WebMethod(EnableSession = true)]
        public PlayerState SellPlayerItem(int amount)
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                (new PlayerState()).Player.SellItem(amount);
                state.Update();
            }
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public PlayerState Fake()
        {
            RoomState room;
            room = AppState.CurrentState.Rooms[AppState.CurrentState.Rooms.Keys.ToList()[0]];
            Classes.Game gameState = room.games[room.games.Keys.ToList()[0]];
            gameState.gameDate = DateTime.Now;
            Random rnd = new Random(Environment.TickCount);
            gameState.StartGame();
            for (int idx = 0; idx < gameState.players.Count; idx++)
            {
                gameState.playerSeats.Add(gameState.players[idx].currentPlayer.PlayerID);
            }
            for (int idx = 0; idx < gameState.players.Count; idx++)
            {
                gameState.NextPlayer();
                gameState.currentPlayer.CurrentLevel = rnd.Next(7, 10);
                UpdateGear(rnd.Next(15, 35));
                if (rnd.Next(1, 3) == 3)
                    gameState.players[idx].CurrentRaceList.Add(CharacterModifier.GetRaceList()[rnd.Next(0, CharacterModifier.GetRaceList().Count - 1)]);
                if (rnd.Next(1, 3) == 3)
                    gameState.players[idx].CurrentClassList.Add(CharacterModifier.GetClassList()[rnd.Next(0, CharacterModifier.GetClassList().Count - 1)]);
                int battles = rnd.Next(20, 30);
                for (int i = 0; i < battles; i++)
                {
                    BattleResult br = new BattleResult(gameState.players[idx]);
                    bool assist = (rnd.Next(1, 10) <= 7);
                    if (assist)
                    {
                        br.assistedBy = gameState.players.Where(pl => pl.currentPlayer.PlayerID != br.gamePlayer.currentPlayer.PlayerID).ToList()[rnd.Next(0, gameState.players.Count - 2)];
                        br.assistTreasures = 1;
                    }
                    br.opponentPoints = rnd.Next(1, 50);
                    br.levelsWon = br.opponentPoints <= 5 ? 1 : br.opponentPoints <= 12 ? 2 : br.opponentPoints <= 25 ? 3 : br.opponentPoints <= 35 ? 4 : 5;
                    br.NumDefeated = rnd.Next(1, 10) <= 7 ? 1 : 2;
                    br.treasuresWon = br.opponentPoints > 20 ? 2 : 1;
                    gameState.currentPlayer.Treasures += br.treasuresWon;
                    br.Victory = (rnd.Next(1, 10) >= 6);
                    Logger.LogBattle(br);
                }
            }
            room.Update();
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public void ToggleCheatCard()
        {
            Classes.Game state = Classes.Game.CurrentGame;
            state.currentPlayer.showCheatCard = state.currentPlayer.showCheatCard == "true" ? "false" : "true";
            state.Update();
        }

        [WebMethod(EnableSession = true)]
        public PlayerState MakeMeNextPlayer()
        {
            CurrentGamePlayer plyr = Classes.Game.CurrentGame.players.Where(p => p.currentPlayer.PlayerID.ToString() == Session["PlayerID"].ToString()).FirstOrDefault();
            int curIdx = Classes.Game.CurrentGame.players.IndexOf(plyr);
            int newIdx = curIdx + 1;
            newIdx = newIdx % Classes.Game.CurrentGame.players.Count;
            Session["PlayerID"] = Classes.Game.CurrentGame.players[newIdx].currentPlayer.PlayerID;
            return GetPlayerState();
        }

        [WebMethod(EnableSession = true)]
        public PlayerState RemovePlayerFromRotation()
        {
            if (Classes.Game.CurrentGame.currentPlayer.currentPlayer.PlayerID == (int)Session["PlayerID"])
                Classes.Game.CurrentGame.NextPlayer();
            Classes.Game.CurrentGame.playerSeats.Remove((int)Session["PlayerID"]);
            Classes.Game.CurrentGame.players.Where(p => p.currentPlayer.PlayerID == (int)Session["PlayerID"]).FirstOrDefault().DroppedOut = true;
            Classes.Game.CurrentGame.Update();
            return GetPlayerState();
        }
    }
}

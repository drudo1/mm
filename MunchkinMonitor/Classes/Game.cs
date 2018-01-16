using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace MunchkinMonitor.Classes
{
    public enum GameStates
    {
        Setup,
        BattlePrep,
        Battle,
        BattleResults
    }

    [Serializable]
    public class Game
    {
        public int GameID { get; set; }
        public string Name { get; set; }
        public string ScoreBoardName { get; set; }
        public ScoreBoardStates sbState { get; set; }
        public bool isEpic { get; set; }
        public GameStates currentState { get; set; }
        public List<CurrentGamePlayer> players { get; set; }
        public List<int> playerSeats { get; set; }
        public DateTime gameDate { get; set; }
        public CurrentGamePlayer currentPlayer { get; set; }
        public Battle currentBattle { get; set; }
        public DateTime lastUpdated { get; set; }
        public bool NeedNextPlayer { get; set; }
        public List<Trophy> results { get; set; }
        public string currentSBStateDescription
        {
            get
            {
                return sbState.ToString();
            }
        }
        public double stateUpdatedJS
        {
            get
            {
                return lastUpdated.Subtract(new DateTime(1970, 1, 1)).TotalMilliseconds;
            }
        }
        public bool hasCurrentPlayer
        {
            get
            {
                return !(currentPlayer == null);
            }
        }
        public List<Player> AvailablePlayers
        {
            get
            {
                return RoomState.CurrentState.playerStats.players.Where(p => !players.Select(gp => gp.currentPlayer.PlayerID).Contains(p.PlayerID)).OrderByDescending(p => p.GamesPlayed).ThenBy(p => p.DisplayName).ToList();
            }
        }
        public List<CurrentGamePlayer> playersOrdered
        {
            get
            {
                return players.OrderBy(p => playerSeats != null && playerSeats.Contains(p.currentPlayer.PlayerID) ? playerSeats.IndexOf(p.currentPlayer.PlayerID) : 100).ThenBy(p => p.currentPlayer.DisplayName).ToList();
            }
        }
        public static Game CurrentGame
        {
            get
            {
                if (HttpContext.Current.Session["RoomID"] != null && HttpContext.Current.Session["GameID"] != null)
                    return (Game)RoomState.CurrentState.games[HttpContext.Current.Session["GameID"].ToString()];
                else
                    return null;
            }
        }

        public Game(int id, string name, bool epic)
        {
            GameID = id;
            Name = name;
            gameDate = DateTime.Now;
            players = new List<CurrentGamePlayer>();
            currentState = GameStates.Setup;
            isEpic = epic;
            lastUpdated = DateTime.Now;
            currentPlayer = null;
            currentBattle = null;
        }

        public void SetSBState(ScoreBoardStates newState)
        {
            sbState = newState;
            lastUpdated = DateTime.Now;
        }

        public void AddExistingPlayer(int id)
        {
            string path = HttpContext.Current.Server.MapPath("~/ ") + "players.xml";
            Player p = null;
            XmlSerializer serializer = new XmlSerializer(typeof(List<Player>));
            if (File.Exists(path))
            {
                using (FileStream stream = File.OpenRead(path))
                {
                    List<Player> players = (List<Player>)serializer.Deserialize(stream);
                    p = players.Where(x => x.PlayerID == id).FirstOrDefault();
                }
            }
            players.Add(new CurrentGamePlayer(p));
            lastUpdated = DateTime.Now;
        }

        public void AddNewPlayer(string username, string password, string firstName, string lastName, string nickName, Gender gender)
        {
            int id = Player.AddNewPlayer(username, password, firstName, lastName, nickName, gender);
            AddExistingPlayer(id);
        }

        public void SetState(GameStates newState)
        {
            currentState = newState;
            lastUpdated = DateTime.Now;
        }

        public void Update()
        {
            lastUpdated = DateTime.Now;
        }

        public void StartGame()
        {
            playerSeats = new List<int>();
            NeedNextPlayer = true;
            currentPlayer = null;
            SetState(GameStates.BattlePrep);
        }

        public void StartGame(int playerID)
        {
            currentPlayer = players.Where(p => p.currentPlayer.PlayerID == playerID).FirstOrDefault();
            SetState(GameStates.BattlePrep);
        }

        public void NextPlayer()
        {
            int idx = 0;
            if (currentPlayer != null)
            {
                idx = playerSeats.IndexOf(currentPlayer.currentPlayer.PlayerID);
                idx = (idx + 1) % players.Count;
            }
            if (idx >= playerSeats.Count)
            {
                currentPlayer = null;
                NeedNextPlayer = true;
            }
            else
            {
                currentPlayer = players.Where(p=> p.currentPlayer.PlayerID == playerSeats[idx]).FirstOrDefault();
                SetState(GameStates.BattlePrep);
            }
        }

        public void PrevPlayer()
        {
            int idx = 0;
            if (currentPlayer != null)
            {
                idx = players.IndexOf(currentPlayer);
                idx = ((idx + players.Count) - 1) % players.Count;
            }
            currentPlayer = players[idx];
            SetState(GameStates.BattlePrep);
        }

        public void StartBattle(int level, int levelsToWin, int treasures)
        {
            currentBattle = new Battle(currentPlayer, level, levelsToWin, treasures);
            SetState(GameStates.Battle);
        }

        public void StartEmptyBattle()
        {
            currentBattle = new Battle(currentPlayer);
            SetState(GameStates.Battle);
        }

        public int AddMonsterToBattle(int level, int levelsToWin, int treasures)
        {
            int idx = -1;
            if(currentBattle != null)
            {
                currentBattle.AddMonster(new Monster(level, levelsToWin, treasures));
                idx = currentBattle.opponents.Count - 1;
            }
            return idx;
        }

        public void RemoveMonster(int idx)
        {
            currentBattle.opponents.Remove(currentBattle.opponents[idx]);
        }

        public void AddAlly(int allyID, int allyTreasures)
        {
            if (currentBattle != null)
            {
                CurrentGamePlayer ally = players.Where(gp => gp.currentPlayer.PlayerID == allyID).FirstOrDefault();
                currentBattle.AddAlly(ally, allyTreasures);
            }
        }

        public void OfferToAlly(int allyID, int allyTreasures)
        {
            if (currentBattle != null)
            {
                if (currentBattle.offers == null)
                    currentBattle.offers = new List<string>();
                if (!currentBattle.offers.Exists(o => o.Split('|')[0] == allyID.ToString()))
                    currentBattle.offers.Add(string.Format("{0}|{1}|{2}", allyID, players.Where(p => p.currentPlayer.PlayerID == allyID).First().currentPlayer.DisplayName, allyTreasures));
            }
        }

        public void RemoveAlly()
        {
            if (currentBattle != null)
            {
                currentBattle.RemoveAlly();
            }
        }

        public void HelpMonster(int idx, int points)
        {
            if(currentBattle != null)
            {
                currentBattle.HelpMonster(idx, points);
                lastUpdated = DateTime.Now;
            }
        }

        public void HurtMonster(int idx, int points)
        {
            if (currentBattle != null)
            {
                currentBattle.AttackMonster(idx, points);
                lastUpdated = DateTime.Now;
            }
        }

        public void HelpGoodGuys(int points)
        {
            if (currentBattle != null)
            {
                currentBattle.HelpGoodGuys(points);
                lastUpdated = DateTime.Now;
            }
        }

        public void AttackPlayer(int points)
        {
            if (currentBattle != null)
            {
                currentBattle.AttackPlayer(points);
                lastUpdated = DateTime.Now;
            }
        }

        public void CancelBattle()
        {
            currentBattle = null;
            SetState(GameStates.BattlePrep);
        }

        public void ResolveBattle()
        {
            if (currentBattle != null)
            {
                currentBattle.ResolveBattle();
                SetState(GameStates.BattleResults);
            }
        }
        public void LogWinner()
        {
            Logger.LogVictory(players.OrderByDescending(p => p.CurrentLevel).ToList()[0].currentPlayer.PlayerID);
        }
    }
}
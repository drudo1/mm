using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace MunchkinMonitor.Classes
{
    public enum AppStates
    {
        TournamentScoreBoard,
        Game,
        GameResults
    }

    [Serializable]
    public class AppState
    {
        public AppStates currentState { get; set; }
        public Game gameState { get; set; }
        public PlayerStats playerStats { get; set; }
        public DateTime stateUpdated { get; set; }
        private static AppState _curState;
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
        public List<Player> AvailablePlayers
        {
            get
            {
                if (playerStats == null)
                    LoadPlayers();
                if (gameState != null && gameState.players != null)
                    return playerStats.players.Where(p => !gameState.players.Select(gp => gp.currentPlayer.PlayerID).Contains(p.PlayerID)).OrderByDescending(p => p.GamesPlayed).ThenBy(p => p.DisplayName).ToList();
                else
                    return playerStats.players.OrderByDescending(p => p.GamesPlayed).ThenBy(p => p.DisplayName).ToList();
            }
        }

        public static AppState CurrentState
        {
            get
            {
                if (_curState == null)
                {
                    _curState = new AppState();
                    _curState.SetState(AppStates.TournamentScoreBoard);
                }
                return _curState;
            }
            set
            {
                _curState = value;
            }
        }

        public void SetState(AppStates newState)
        {
            currentState = newState;
            stateUpdated = DateTime.Now;
        }

        public void NewGame(bool isEpic)
        {
            gameState = new Game(isEpic);
            SetState(AppStates.Game);
        }

        public void CancelGame()
        {
            SetState(AppStates.TournamentScoreBoard);
        }

        public void EndGame()
        {
            gameState.LogWinner();
            SetState(AppStates.GameResults);
        }

        public void LoadScoreboard()
        {
            playerStats = new PlayerStats();
            SetState(AppStates.TournamentScoreBoard);
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
                return AppState.CurrentState.stateUpdated.Subtract(new DateTime(1970, 1, 1).AddHours(-6)).TotalMilliseconds;
            }
        }
        public void Update()
        {
            AppState.CurrentState.Update();
        }
        public AppStates currentAppState
        {
            get
            {
                return AppState.CurrentState.currentState;
            }
        }
        public GameStates currentGameState
        {
            get
            {
                return AppState.CurrentState.gameState == null ? GameStates.Setup : AppState.CurrentState.gameState.currentState;
            }
        }
        public bool playerReady
        {
            get
            {
                return Player != null;
            }
        }
        public CurrentGamePlayer Player
        {
            get
            {
                if (AppState.CurrentState.gameState != null && HttpContext.Current.Session["PlayerID"] != null)
                    return AppState.CurrentState.gameState.players.Where(p => p.currentPlayer.PlayerID == (int)HttpContext.Current.Session["PlayerID"]).FirstOrDefault();
                else
                    return null;
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
                return Player == null ? false : Player.currentPlayer.PlayerID == AppState.CurrentState.gameState.currentPlayer.currentPlayer.PlayerID;
            }
        }
        public bool CanAlly
        {
            get
            {
                return Player == null ? false : AppState.CurrentState.gameState.currentState == GameStates.Battle && !myTurn && !AppState.CurrentState.gameState.currentBattle.HasAlly;
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
                return AppState.CurrentState.gameState == null ? false :  AppState.CurrentState.gameState.currentState == GameStates.Battle && myTurn;
            }
        }
        public Battle currentBattle
        {
            get
            {
                return IsInBattle ? AppState.CurrentState.gameState.currentBattle : null;
            }
        }
        public Game currentGame
        {
            get
            {
                return AppState.CurrentState.gameState;
            }
        }
    }
}
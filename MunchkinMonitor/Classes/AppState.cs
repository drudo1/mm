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

        public static AppState CurrentState()
        {
            if (HttpContext.Current.Application["CurrentState"] == null)
            {
                AppState state = new AppState();
                //state.LoadScoreboard();
                state.SetState(AppStates.TournamentScoreBoard);
                HttpContext.Current.Application["CurrentState"] = state;
            }

            return (AppState)(HttpContext.Current.Application["CurrentState"]);
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
}
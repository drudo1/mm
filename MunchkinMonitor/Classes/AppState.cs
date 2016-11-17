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
        Game
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

        public static AppState CurrentState()
        {
            if (HttpContext.Current.Application["CurrentState"] == null)
            {
                AppState state = new AppState();
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

        public void EndGame()
        {
            //record game stats
            LoadScoreboard();
        }

        public void LoadScoreboard()
        {
            playerStats = new PlayerStats();
            SetState(AppStates.TournamentScoreBoard);
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
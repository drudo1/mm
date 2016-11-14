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
        Battle,
        GameResults
    }

    public class AppState
    {
        public AppStates currentState { get; set; }
        public List<PlayerStats> playerStats { get; set; }
        public AppStates gameState { get; set; }

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
            switch (newState)
            {
                case AppStates.TournamentScoreBoard:
                    LoadPlayerStats();
                    break;
                case AppStates.Game:
                    LoadGame();
                    break;
                case AppStates.Battle:
                    LoadBattle();
                    break;
                case AppStates.GameResults:
                    LoadGameResults();
                    break;
            }
            gameState = newState;
        }

        private void LoadGameResults()
        {
            //throw new NotImplementedException();
        }

        private void LoadBattle()
        {
            //throw new NotImplementedException();
        }

        private void LoadGame()
        {
            //throw new NotImplementedException();
        }

        private void LoadPlayerStats()
        {
            playerStats = new List<PlayerStats>();
        }
    }
}
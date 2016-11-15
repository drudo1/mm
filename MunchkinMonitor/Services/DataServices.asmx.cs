using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using MunchkinMonitor.Classes;
using System.Web.Script.Services;

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

        [WebMethod]
        public bool CheckForStateUpdate(DateTime lastUpdate)
        {
            return (AppState.CurrentState().stateUpdated.Subtract(lastUpdate).TotalMilliseconds > 1);
        }

        [WebMethod]
        public AppState GetCurrentAppState()
        {
            return AppState.CurrentState();
        }

        [WebMethod]
        public void LoadScroreboard()
        {
            AppState state = AppState.CurrentState();
            state.LoadScoreboard();
        }

        [WebMethod]
        public void NewGame(bool isEpic)
        {
            AppState state = AppState.CurrentState();
            state.NewGame(isEpic);
        }

        [WebMethod]
        public void AddExistingPlayer(int id)
        {
            AppState state = AppState.CurrentState();
            if(state.gameState != null)
                state.gameState.AddExistingPlayer(id);
        }

        [WebMethod]
        public void AddNewPlayer(string firstName, string lastName, string nickName, Gender gender)
        {
            AppState state = AppState.CurrentState();
            if(state.gameState != null)
                state.gameState.AddNewPlayer(firstName, lastName, nickName, gender, "");
        }

        [WebMethod]
        public void StartGame(int playerID)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
                state.gameState.StartGame(playerID);
        }

        [WebMethod]
        public void NextPlayer()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
                state.gameState.NextPlayer();
        }

        [WebMethod]
        public void StartBattle(int level, int levelsToWin, int treasures)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
                state.gameState.StartBattle(level, levelsToWin, treasures);
        }

        [WebMethod]
        public void AddMonster(int level, int levelsToWin, int treasures, int attackerID)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                state.gameState.AddMonsterToBattle(level, levelsToWin, treasures, attackerID);
            }
        }

        [WebMethod]
        public void AddAlly(int allyID, int allyTreasures, int allyLevels)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
                state.gameState.AddAlly(allyID, allyTreasures, allyLevels);
        }

        [WebMethod]
        public void ResolveBattle()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
                state.gameState.ResolveBattle();
        }

        [WebMethod]
        public void EndGame()
        {
            AppState state = AppState.CurrentState();
            state.EndGame();
        }
    }
}

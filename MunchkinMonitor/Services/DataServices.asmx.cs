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
        public void LoadScoreboard()
        {
            AppState state = AppState.CurrentState();
            state.LoadScoreboard();
        }

        [WebMethod]
        public void LoadPlayers()
        {
            AppState state = AppState.CurrentState();
            state.LoadPlayers();
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
            if (state.gameState != null)
            {
                state.gameState.AddExistingPlayer(id);
                state.Update();
            }
        }

        [WebMethod]
        public void AddNewPlayer(string firstName, string lastName, string nickName, Gender gender)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                state.gameState.AddNewPlayer(firstName, lastName, nickName, gender, "");
                state.Update();
            }
        }

        [WebMethod]
        public void StartGame()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                state.gameState.StartGame();
                state.Update();
            }
        }

        [WebMethod]
        public void StartGameWithPlayer(int PlayerID)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                state.gameState.StartGame(PlayerID);
                state.Update();
            }
        }

        [WebMethod]
        public List<CharacterModifier> GetRaceList()
        {
            return CharacterModifier.GetRaceList();
        }

        [WebMethod]
        public List<CharacterModifier> GetClassList()
        {
            return CharacterModifier.GetClassList();
        }

        [WebMethod]
        public void AddLevel()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    state.gameState.currentPlayer.CurrentLevel++;
                    state.Update();
                }
            }
        }

        [WebMethod]
        public void UpdateGear(int amount)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    state.gameState.currentPlayer.GearBonus += amount;
                    state.Update();
                }
            }
        }

        [WebMethod]
        public void NextRace()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    state.gameState.currentPlayer.NextRace();
                    state.Update();
                }
            }
        }

        [WebMethod]
        public void NextClass()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    state.gameState.currentPlayer.NextClass();
                    state.Update();
                }
            }
        }

        [WebMethod]
        public void SubtractLevel()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    if (state.gameState.currentPlayer.CurrentLevel > 1)
                    {
                        state.gameState.currentPlayer.CurrentLevel--;
                        state.Update();
                    }
                }
            }
        }

        [WebMethod]
        public void NextPlayer()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                state.gameState.NextPlayer();
                state.Update();
            }
        }

        [WebMethod]
        public void PrevPlayer()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                state.gameState.PrevPlayer();
                state.Update();
            }
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

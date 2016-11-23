﻿using System;
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
                    GameStats.LogMaxGear(state.gameState.currentPlayer.currentPlayer.PlayerID, state.gameState.currentPlayer.GearBonus);
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
        public void ToggleHalfBreed()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    state.gameState.currentPlayer.ToggleHalfBreed();
                    state.Update();
                }
            }
        }

        [WebMethod]
        public void NextHalfBreed()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    state.gameState.currentPlayer.NextHalfBreed();
                    state.Update();
                }
            }
        }

        [WebMethod]
        public void ToggleSuperMunchkin()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    state.gameState.currentPlayer.ToggleSuperMunchkin();
                    state.Update();
                }
            }
        }

        [WebMethod]
        public void NextSMClass()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    state.gameState.currentPlayer.NextSMClass();
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
        public void ChangeGender(int penalty)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    state.gameState.currentPlayer.ChangeGender(penalty);
                    state.Update();
                }
            }
        }

        [WebMethod]
        public void KillCurrentPlayer()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    state.gameState.currentPlayer.Die();
                    state.Update();
                }
            }
        }

        [WebMethod]
        public void AddHelper(bool steed, int bonus)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    state.gameState.currentPlayer.AddHelper(steed, bonus);
                    state.Update();
                }
            }
        }

        [WebMethod]
        public void UpdateHelperGear(Guid helperID, int amount)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    CharacterHelper hlp = state.gameState.currentPlayer.Helpers.Where(h => h.ID == helperID).FirstOrDefault();
                    if (hlp != null)
                    {
                        hlp.GearBonus += amount;
                        state.Update();
                    }
                }
            }
        }

        [WebMethod]
        public void ChangeHelperRace(Guid helperID)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    CharacterHelper hlp = state.gameState.currentPlayer.Helpers.Where(h => h.ID == helperID).FirstOrDefault();
                    if (hlp != null)
                    {
                        hlp.ChangeRace();
                        state.Update();
                    }
                }
            }
        }

        [WebMethod]
        public void KillHelper(Guid helperID)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    if(state.gameState.currentPlayer.Helpers.Where(h => h.ID == helperID).Count() > 0)
                    {
                        state.gameState.currentPlayer.Helpers.Remove(state.gameState.currentPlayer.Helpers.Where(h => h.ID == helperID).FirstOrDefault());
                        state.Update();
                    }
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
                        GameStats.LogLevelLost(state.gameState.currentPlayer.currentPlayer.PlayerID);
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
            state.gameState.StartBattle(level, levelsToWin, treasures);
            state.Update();
        }

        [WebMethod]
        public void BattleBonus(int amount)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if(state.gameState.currentBattle != null)
                {
                    state.gameState.currentBattle.playerOneTimeBonus += amount;
                    state.Update();
                }
            }
        }

        [WebMethod]
        public int AddMonster(int level, int levelsToWin, int treasures)
        {
            int idx = -1;
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                idx = state.gameState.AddMonsterToBattle(level, levelsToWin, treasures);
                state.Update();
            }
            return idx;
        }

        [WebMethod]
        public void RemoveMonster(int monsterIDX)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                state.gameState.RemoveMonster(monsterIDX);
                state.Update();
            }
        }

        [WebMethod]
        public void UpdateMonsterLevel(int monsterIDX, int amount)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentBattle != null)
                {
                    state.gameState.currentBattle.opponents[monsterIDX].Level += amount;
                    state.Update();
                }
            }
        }

        [WebMethod]
        public void UpdateMonsterBonus(int monsterIDX, int amount)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentBattle != null)
                {
                    state.gameState.currentBattle.opponents[monsterIDX].OneTimeBonus += amount;
                    state.Update();
                }
            }
        }

        [WebMethod]
        public void UpdateMonsterLTW(int monsterIDX, int amount)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentBattle != null)
                {
                    state.gameState.currentBattle.opponents[monsterIDX].LevelsToWin += amount;
                    state.Update();
                }
            }
        }

        [WebMethod]
        public void UpdateMonsterTreasures(int monsterIDX, int amount)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentBattle != null)
                {
                    state.gameState.currentBattle.opponents[monsterIDX].Treasures += amount;
                    state.Update();
                }
            }
        }

        [WebMethod]
        public void AddAlly(int allyID, int allyTreasures)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                state.gameState.AddAlly(allyID, allyTreasures);
                state.Update();
            }
        }

        [WebMethod]
        public void RemoveAlly()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                state.gameState.RemoveAlly();
                state.Update();
            }
        }

        [WebMethod]
        public void CancelBattle()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                state.gameState.CancelBattle();
                state.Update();
            }
        }

        [WebMethod]
        public void ResolveBattle()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                state.gameState.ResolveBattle();
                state.Update();
            }
        }

        [WebMethod]
        public void CompleteBattle()
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                state.gameState.currentBattle = null;
                state.gameState.SetState(GameStates.BattlePrep);
                state.Update();
            }
        }

        [WebMethod]
        public void EndGame()
        {
            AppState state = AppState.CurrentState();
            state.EndGame();
        }

        [WebMethod]
        public void Reset()
        {
            HttpContext.Current.Application["CurrentState"] = null;
        }
    }
}

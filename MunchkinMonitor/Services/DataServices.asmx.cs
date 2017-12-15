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

        [WebMethod]
        public bool CheckForStateUpdate(DateTime lastUpdate)
        {
            return (AppState.CurrentState().stateUpdated.Minute != lastUpdate.Minute || (AppState.CurrentState().stateUpdated.Minute == lastUpdate.Minute && AppState.CurrentState().stateUpdated.Second > lastUpdate.Second));
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
        public void AddNewPlayer(string username, string firstName, string lastName, string nickName, Gender gender)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                state.gameState.AddNewPlayer(username, firstName, lastName, nickName, gender);
                state.Update();
            }
        }

        [WebMethod]
        public void LoginPlayer(string username)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                int id = Player.GetPlayerByUserName(username).PlayerID;
                state.gameState.AddExistingPlayer(id);
                Session["PlayerID"] = id;
                state.Update();
            }
        }

        [WebMethod]
        public void LoginNewPlayer(string username, string firstName, string lastName, string nickName, Gender gender)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                int id = Player.AddNewPlayer(username, firstName, lastName, nickName, gender);
                state.gameState.AddExistingPlayer(id);
                Session["PlayerID"] = id;
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
        public void AddPlayerLevel()
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                (new PlayerState()).Player.CurrentLevel++;
                state.Update();
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
        public void UpdatePlayerGear(int amount)
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                (new PlayerState()).Player.GearBonus += amount;
                GameStats.LogMaxGear((new PlayerState()).Player.currentPlayer.PlayerID, (new PlayerState()).Player.GearBonus);
                state.Update();
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
        public void ChangePlayerGender(int penalty)
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                (new PlayerState()).Player.ChangeGender(penalty);
                state.Update();
            }
        }

        [WebMethod]
        public void NextPlayerRace()
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                (new PlayerState()).Player.NextRace();
                state.Update();
            }
        }

        [WebMethod]
        public void TogglePlayerHalfBreed()
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                (new PlayerState()).Player.ToggleHalfBreed();
                state.Update();
            }
        }

        [WebMethod]
        public void NextPlayerHalfBreed()
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                (new PlayerState()).Player.NextHalfBreed();
                state.Update();
            }
        }

        [WebMethod]
        public void TogglePlayerSuperMunchkin()
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                (new PlayerState()).Player.ToggleSuperMunchkin();
                state.Update();
            }
        }

        [WebMethod]
        public void NextPlayerSMClass()
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                (new PlayerState()).Player.NextSMClass();
                state.Update();
            }
        }

        [WebMethod]
        public void NextPlayerClass()
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                (new PlayerState()).Player.NextClass();
                state.Update();
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
        public void AddPlayerHelper(bool steed, int bonus)
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                (new PlayerState()).Player.AddHelper(steed, bonus);
                state.Update();
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
        public void UpdatePlayerHelperGear(Guid helperID, int amount)
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                CharacterHelper hlp = state.Player.Helpers.Where(h => h.ID == helperID).FirstOrDefault();
                if (hlp != null)
                {
                    hlp.GearBonus += amount;
                    state.Update();
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
        public void ChangePlayerHelperRace(Guid helperID)
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                CharacterHelper hlp = state.Player.Helpers.Where(h => h.ID == helperID).FirstOrDefault();
                if (hlp != null)
                {
                    hlp.ChangeRace();
                    state.Update();
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
        public void KillPlayerHelper(Guid helperID)
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
        public void SubtractPlayerLevel()
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                (new PlayerState()).Player.CurrentLevel--;
                GameStats.LogLevelLost((new PlayerState()).Player.currentPlayer.PlayerID);
                state.Update();
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
        public void StartEmptyBattle()
        {
            AppState state = AppState.CurrentState();
            state.gameState.StartEmptyBattle();
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
        public void AddPlayerAsAlly(int allyTreasures)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                state.gameState.AddAlly((int)Session["PlayerID"], allyTreasures);
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
        public void CancelGame()
        {
            AppState state = AppState.CurrentState();
            state.CancelGame();
        }

        [WebMethod]
        public void EndGame()
        {
            AppState state = AppState.CurrentState();
            state.EndGame();
        }

        [WebMethod]
        public List<Trophy> GetTrophies()
        {
            return GameStats.GetTrophies();
        }

        [WebMethod]
        public void ResetGame()
        {
            HttpContext.Current.Application["CurrentState"] = null;
        }

        [WebMethod]
        public void Reset()
        {
            HttpContext.Current.Application["CurrentState"] = null;
            string path = HttpContext.Current.Server.MapPath("~/") + "players.xml";
            File.Delete(path);
        }

        [WebMethod]
        public void SellItem(int amount)
        {
            AppState state = AppState.CurrentState();
            if (state.gameState != null)
            {
                if (state.gameState.currentPlayer != null)
                {
                    state.gameState.currentPlayer.SellItem(amount);
                    state.Update();
                }
            }
        }

        [WebMethod]
        public void SellPlayerItem(int amount)
        {
            if (Session["PlayerID"] != null)
            {
                PlayerState state = new PlayerState();
                (new PlayerState()).Player.SellItem(amount);
                state.Update();
            }
        }

        [WebMethod]
        public void Fake()
        {
            AppState state = AppState.CurrentState();
            state.currentState = AppStates.Game;
            state.LoadPlayers();
            state.NewGame(false);
            state.gameState.gameDate = DateTime.Now;
            Random rnd = new Random(Environment.TickCount);
            foreach (Player p in state.playerStats.players)
            {
                state.gameState.AddExistingPlayer(p.PlayerID);
            }
            state.gameState.StartGame();
            for (int idx = 0; idx < state.gameState.players.Count; idx++)
            {
                state.gameState.NextPlayer();
                state.gameState.currentPlayer.CurrentLevel = rnd.Next(7, 10);
                UpdateGear(rnd.Next(15, 35));
                if (rnd.Next(1, 3) == 3)
                    state.gameState.players[idx].CurrentRaceList.Add(CharacterModifier.GetRaceList()[rnd.Next(0, CharacterModifier.GetRaceList().Count - 1)]);
                if (rnd.Next(1, 3) == 3)
                    state.gameState.players[idx].CurrentClassList.Add(CharacterModifier.GetClassList()[rnd.Next(0, CharacterModifier.GetClassList().Count - 1)]);
                int battles = rnd.Next(20, 30);
                for (int i = 0; i < battles; i++)
                {
                    BattleResult br = new BattleResult(state.gameState.players[idx]);
                    bool assist = (rnd.Next(1, 10) <= 7);
                    if (assist)
                    {
                        br.assistedBy = state.gameState.players.Where(pl => pl.currentPlayer.PlayerID != br.gamePlayer.currentPlayer.PlayerID).ToList()[rnd.Next(0, state.gameState.players.Count - 2)];
                        br.assistTreasures = 1;
                    }
                    br.opponentPoints = rnd.Next(1, 50);
                    br.levelsWon = br.opponentPoints <= 5 ? 1 : br.opponentPoints <= 12 ? 2 : br.opponentPoints <= 25 ? 3 : br.opponentPoints <= 35 ? 4 : 5;
                    br.NumDefeated = rnd.Next(1, 10) <= 7 ? 1 : 2;
                    br.treasuresWon = br.opponentPoints > 20 ? 2 : 1;
                    state.gameState.currentPlayer.Treasures += br.treasuresWon;
                    br.Victory = (rnd.Next(1, 10) >= 6);
                    Logger.LogBattle(br);
                }
            }
            state.Update();
        }

        [WebMethod]
        public void ToggleCheatCard()
        {
            AppState state = AppState.CurrentState();
            state.gameState.currentPlayer.showCheatCard = state.gameState.currentPlayer.showCheatCard == "true" ? "false" : "true";
            state.Update();
        }
    }
}

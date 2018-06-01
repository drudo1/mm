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
        private void LogError(Exception ex)
        {
            Logger.LogError(ex);
        }

        [WebMethod(EnableSession = true)]
        public string LinkScoreBoardToRoom(string boardName, string roomKey)
        {
            string result = null;
            try
            {
                result = AppState.CurrentState.LinkScoreBoardToRoom(boardName, roomKey);
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return result;
        }

        [WebMethod(EnableSession = true)]
        public bool CheckForStateUpdate(DateTime lastUpdate)
        {
            bool result = false;
            try
            {
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
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return result;
        }

        [WebMethod(EnableSession = true)]
        public RoomState GetCurrentRoomState()
        {
            RoomState s = null;
            try
            {
                s = RoomState.CurrentState;
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public Classes.Game GetCurrentGameState()
        {
            Classes.Game g = null;
            try
            {
                g = Classes.Game.CurrentGame;
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return g;
        }

        [WebMethod(EnableSession = true)]
        public AppState GetControllerState()
        {
            AppState s = null;
            try
            {
                s = AppState.CurrentState;
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState GetPlayerState()
        {
            PlayerState s = null;
            try
            {
                s = new PlayerState();
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState PlayerEnterRoom(int id)
        {
            PlayerState s = null;
            try
            {
                Session["RoomID"] = id;
                s = GetPlayerState();
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState PlayerExitRoom()
        {
            PlayerState s = null;
            try
            {
                Session.Remove("RoomID");
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState PlayerLeaveRoom()
        {
            PlayerState s = null;
            try
            {
                RoomMembership.LeaveRoom();
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public string PlayerCreateRoom(string name, string key)
        {
            string x = null;
            try
            {
                x = RoomMembership.AddNewRoom(name, key);
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return x;
        }

        [WebMethod(EnableSession = true)]
        public string PlayerJoinRoom(string key)
        {
            string x = null;
            try
            {
                x = RoomMembership.JoinRoom(key);
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return x;
        }

        [WebMethod(EnableSession = true)]
        public void LoadScoreboard()
        {
            try
            {
                RoomState state = RoomState.CurrentState;
                state.LoadScoreboard();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public void LoadPlayers()
        {
            try
            {
                RoomState state = RoomState.CurrentState;
                state.LoadPlayers();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public PlayerState PlayerJoinGame(int id)
        {

            PlayerState s = null;
            try
            {
                Session["GameID"] = id;
                if (HttpContext.Current.Session["PlayerID"] != null)
                    Classes.Game.CurrentGame.AddExistingPlayer((int)HttpContext.Current.Session["PlayerID"]);
                RoomState.CurrentState.Update();
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public void NewGame(string name, bool isEpic, string sbName)
        {
            try
            {
                RoomState state = RoomState.CurrentState;
                state.NewGame(name, isEpic, sbName);
                if (HttpContext.Current.Session["PlayerID"] != null)
                    Classes.Game.CurrentGame.AddExistingPlayer((int)HttpContext.Current.Session["PlayerID"]);
                RoomState.CurrentState.Update();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public void AddExistingPlayer(int id)
        {
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    state.AddExistingPlayer(id);
                }
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public void AddNewPlayer(string username, string password, string firstName, string lastName, string nickName, Gender gender)
        {
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    state.AddNewPlayer(username, password, firstName, lastName, nickName, gender);
                }
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public string LoginPlayer(string username, string password)
        {
            string x = null;
            try
            {
                int id = Player.Login(username, password);
                if (id > 0)
                {
                    Session["PlayerID"] = id;
                    x = "LoggedIn";
                }
                else
                    x = "LoginFailed";
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return x;
        }

        [WebMethod(EnableSession =true)]
        public void LoginNewPlayer(string username, string password, string firstName, string lastName, string nickName, Gender gender)
        {
            try
            {
                int id = Player.AddNewPlayer(username, password, firstName, lastName, nickName, gender);
                Session["PlayerID"] = id;
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public PlayerState StartGame()
        {
            PlayerState s = null;
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    state.StartGame();
                }
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public void StartGameWithPlayer(int PlayerID)
        {
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    state.StartGame(PlayerID);
                }
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public List<CharacterModifier> GetRaceList()
        {
            List<CharacterModifier> ls = null;
            try
            {
                ls = CharacterModifier.GetRaceList();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return ls;
        }

        [WebMethod(EnableSession = true)]
        public List<CharacterModifier> GetClassList()
        {
            List<CharacterModifier> ls = null;
            try
            {
                ls = CharacterModifier.GetClassList();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return ls;
        }

        [WebMethod(EnableSession = true)]
        public void AddLevel()
        {
            try
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
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public int AddPlayerLevel()
        {
            int newLevel = 0;
            try
            {
                if (Session["PlayerID"] != null)
                {
                    PlayerState state = new PlayerState();
                    state.Player.CurrentLevel++;
                    state.Update();
                    newLevel = state.CurrentLevel;
                }
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return newLevel;
        }

        [WebMethod(EnableSession = true)]
        public void UpdateGear(int amount)
        {
            try
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
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public PlayerState UpdatePlayerGear(int amount)
        {
            PlayerState s = null;
            try
            {
                if (Session["PlayerID"] != null)
                {
                    PlayerState state = new PlayerState();
                    (new PlayerState()).Player.GearBonus += amount;
                    GameStats.LogMaxGear((new PlayerState()).Player.currentPlayer.PlayerID, (new PlayerState()).Player.GearBonus);
                    state.Update();
                }
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public void NextRace()
        {
            try
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
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public void ToggleHalfBreed()
        {
            try
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
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public void NextHalfBreed()
        {
            try
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
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public void ToggleSuperMunchkin()
        {
            try
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
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public void NextSMClass()
        {
            try
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
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public void NextClass()
        {
            try
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
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public void ChangeGender(int penalty)
        {
            try
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
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public string ChangePlayerGender()
        {
            string x = null;
            try
            {
                if (Session["PlayerID"] != null)
                {
                    PlayerState state = new PlayerState();
                    state.Player.ChangeGender(0);
                    state.Update();
                }
                x = GetPlayerState().Gender;
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return x;
        }

        [WebMethod(EnableSession = true)]
        public string NextPlayerRace()
        {
            string x = null;
            try
            {
                if (Session["PlayerID"] != null)
                {
                    PlayerState state = new PlayerState();
                    state.Player.NextRace();
                    state.Update();
                }
                x = GetPlayerState().Race;
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return x;
        }

        [WebMethod(EnableSession = true)]
        public string TogglePlayerHalfBreed()
        {
            string x = null;
            try
            {
                if (Session["PlayerID"] != null)
                {
                    PlayerState state = new PlayerState();
                    state.Player.ToggleHalfBreed();
                    state.Update();
                }
                x = GetPlayerState().Race;
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return x;
        }

        [WebMethod(EnableSession = true)]
        public string NextPlayerHalfBreed()
        {
            string x = null;
            try
            {
                if (Session["PlayerID"] != null)
                {
                    PlayerState state = new PlayerState();
                    state.Player.NextHalfBreed();
                    state.Update();
                }
                x = GetPlayerState().Race;
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return x;
        }

        [WebMethod(EnableSession = true)]
        public string TogglePlayerSuperMunchkin()
        {
            string x = null;
            try
            {
                if (Session["PlayerID"] != null)
                {
                    PlayerState state = new PlayerState();
                    state.Player.ToggleSuperMunchkin();
                    state.Update();
                }
                x = GetPlayerState().Class;
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return x;
        }

        [WebMethod(EnableSession = true)]
        public string NextPlayerSMClass()
        {
            string x = null;
            try
            {
                if (Session["PlayerID"] != null)
                {
                    PlayerState state = new PlayerState();
                    state.Player.NextSMClass();
                    state.Update();
                }
                x = GetPlayerState().Class;
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return x;
        }

        [WebMethod(EnableSession = true)]
        public string NextPlayerClass()
        {
            string x = null;
            try
            {
                if (Session["PlayerID"] != null)
                {
                    PlayerState state = new PlayerState();
                    state.Player.NextClass();
                    state.Update();
                }
                x = GetPlayerState().Class;
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return x;
        }

        [WebMethod(EnableSession = true)]
        public void KillCurrentPlayer()
        {
            try
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
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public void AddHelper(bool steed, int bonus)
        {
            try
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
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public CurrentGamePlayer AddPlayerHelper(bool steed, int bonus)
        {
            CurrentGamePlayer p = null;
            try
            {
                if (Session["PlayerID"] != null)
                {
                    PlayerState state = new PlayerState();
                    state.Player.AddHelper(steed, bonus);
                    state.Update();
                }
                p = GetPlayerState().Player;
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return p;
        }

        [WebMethod(EnableSession = true)]
        public void UpdateHelperGear(Guid helperID, int amount)
        {
            try
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
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public int UpdatePlayerHelperGear(Guid helperID, int amount)
        {
            int newGear = 0;
            try
            {
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
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return newGear;
        }

        [WebMethod(EnableSession = true)]
        public void ChangeHelperRace(Guid helperID)
        {
            try
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
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public string ChangePlayerHelperRace(Guid helperID)
        {
            string x = null;
            try
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
                x = race;
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return x;
        }

        [WebMethod(EnableSession = true)]
        public void KillHelper(Guid helperID)
        {
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    if (state.currentPlayer != null)
                    {
                        if (state.currentPlayer.Helpers.Where(h => h.ID == helperID).Count() > 0)
                        {
                            state.currentPlayer.Helpers.Remove(state.currentPlayer.Helpers.Where(h => h.ID == helperID).FirstOrDefault());
                            state.Update();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public PlayerState KillPlayerHelper(Guid helperID)
        {
            PlayerState s = null;
            try
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
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public void SubtractLevel()
        {
            try
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
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public int SubtractPlayerLevel()
        {
            int newLevel = 0;
            try
            {
                if (Session["PlayerID"] != null)
                {
                    PlayerState state = new PlayerState();
                    state.Player.CurrentLevel--;
                    GameStats.LogLevelLost((new PlayerState()).Player.currentPlayer.PlayerID);
                    state.Update();
                    newLevel = state.Player.CurrentLevel;
                }
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return newLevel;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState NextPlayer()
        {
            PlayerState s = null;
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    state.NextPlayer();
                    state.Update();
                }
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState IAmNext()
        {
            PlayerState s = null;
            try
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
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public void PrevPlayer()
        {
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    state.PrevPlayer();
                    state.Update();
                }
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public void StartBattle(int level, int levelsToWin, int treasures)
        {
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                state.StartBattle(level, levelsToWin, treasures);
                state.Update();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public PlayerState StartEmptyBattle()
        {
            PlayerState s = null;
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                state.StartEmptyBattle();
                state.Update();
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public Battle BattleBonus(int amount)
        {
            Battle b = null;
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    if (state.currentBattle != null)
                    {
                        state.currentBattle.playerOneTimeBonus += amount;
                        state.Update();
                    }
                }
                b = GetPlayerState().currentBattle;
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return b;
        }

        [WebMethod(EnableSession = true)]
        public Battle AddFirstMonster(int level, int levelsToWin, int treasures)
        {
            Battle b = null;
            try
            {
                int idx = -1;
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    idx = state.AddMonsterToBattle(level, levelsToWin, treasures);
                    state.Update();
                }
                b = GetPlayerState().currentBattle;
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return b;
        }

        [WebMethod(EnableSession = true)]
        public KeyValuePair<int, Monster> AddMonster(int level, int levelsToWin, int treasures)
        {
            KeyValuePair<int, Monster> m = new KeyValuePair<int, Monster>();
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    int idx = state.AddMonsterToBattle(level, levelsToWin, treasures);
                    m = new KeyValuePair<int, Monster>(idx, GetPlayerState().currentBattle.opponents[idx]);
                    state.Update();
                }
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return m;
        }

        [WebMethod(EnableSession = true)]
        public Battle RemoveMonster(int monsterIDX)
        {
            Battle b = null;
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    state.RemoveMonster(monsterIDX);
                    state.Update();
                }
                b = GetPlayerState().currentBattle;
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return b;
        }

        [WebMethod(EnableSession = true)]
        public Monster UpdateMonsterLevel(int monsterIDX, int amount)
        {
            Monster m = null;
            try
            {
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
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return m;
        }

        [WebMethod(EnableSession = true)]
        public Monster UpdateMonsterBonus(int monsterIDX, int amount)
        {
            Monster m = null;
            try
            {
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
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return m;
        }

        [WebMethod(EnableSession = true)]
        public Monster UpdateMonsterLTW(int monsterIDX, int amount)
        {
            Monster m = null;
            try
            {
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
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return m;
        }

        [WebMethod(EnableSession = true)]
        public Monster UpdateMonsterTreasures(int monsterIDX, int amount)
        {
            Monster m = null;
            try
            {
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
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return m;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState AddAlly(int allyID, int allyTreasures)
        {
            PlayerState s = null;
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    state.AddAlly(allyID, allyTreasures);
                    state.Update();
                }
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public void AddPlayerAsAlly(string allyTreasures)
        {
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    state.AddAlly((int)Session["PlayerID"], Convert.ToInt32(allyTreasures));
                    state.Update();
                }
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public PlayerState OfferToAlly(string allyTreasures)
        {
            PlayerState s = null;
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    state.OfferToAlly((int)Session["PlayerID"], Convert.ToInt32(allyTreasures));
                    state.Update();
                }
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public Battle RemoveAlly()
        {
            Battle b = null;
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    state.RemoveAlly();
                    state.Update();
                }
                b = GetPlayerState().currentBattle;
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return b;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState CancelBattle()
        {
            PlayerState s = null;
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    state.CancelBattle();
                    state.Update();
                }
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState ResolveBattle()
        {
            PlayerState s = null;
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    state.ResolveBattle();
                    state.Update();
                    RoomState.CurrentState.Update();
                }
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState CompleteBattle()
        {
            PlayerState s = null;
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                if (state != null)
                {
                    state.currentBattle = null;
                    state.SetState(GameStates.BattlePrep);
                    state.Update();
                }
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public void CancelGame()
        {
            try
            {
                RoomState state = RoomState.CurrentState;
                state.CancelGame();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public void EndGame()
        {
            try
            {
                RoomState state = RoomState.CurrentState;
                state.EndGame();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public List<Trophy> GetTrophies()
        {
            List<Trophy> ls = null;
            try
            {
                ls = GameStats.GetTrophies();
            }
            catch(Exception ex)
            {
                LogError(ex);
            }
            return ls;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState ToggleEpic()
        {
            PlayerState s = null;
            try
            {
                Classes.Game.CurrentGame.isEpic = !Classes.Game.CurrentGame.isEpic;
                Classes.Game.CurrentGame.Update();
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState ResetGame()
        {
            PlayerState s = null;
            try
            {
                List<int> players = Classes.Game.CurrentGame.players.Select(p => p.currentPlayer.PlayerID).ToList();
                RoomState.CurrentState.games[HttpContext.Current.Session["GameID"].ToString()] = new Classes.Game(Classes.Game.CurrentGame.GameID, Classes.Game.CurrentGame.Name, Classes.Game.CurrentGame.isEpic);
                foreach (int p in players)
                {
                    Classes.Game.CurrentGame.AddExistingPlayer(p);
                }
                Classes.Game.CurrentGame.Update();
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public void SellItem(int amount)
        {
            try
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
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public PlayerState SellPlayerItem(int amount)
        {
            PlayerState s = null;
            try
            {
                if (Session["PlayerID"] != null)
                {
                    PlayerState state = new PlayerState();
                    (new PlayerState()).Player.SellItem(amount);
                    state.Update();
                }
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState Fake()
        {
            PlayerState s = null;
            try
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
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public void ToggleCheatCard()
        {
            try
            {
                Classes.Game state = Classes.Game.CurrentGame;
                state.currentPlayer.showCheatCard = state.currentPlayer.showCheatCard == "true" ? "false" : "true";
                state.Update();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
        }

        [WebMethod(EnableSession = true)]
        public PlayerState MakeMeNextPlayer()
        {
            PlayerState s = null;
            try
            {
                CurrentGamePlayer plyr = Classes.Game.CurrentGame.players.Where(p => p.currentPlayer.PlayerID.ToString() == Session["PlayerID"].ToString()).FirstOrDefault();
                int curIdx = Classes.Game.CurrentGame.players.IndexOf(plyr);
                int newIdx = curIdx + 1;
                newIdx = newIdx % Classes.Game.CurrentGame.players.Count;
                Session["PlayerID"] = Classes.Game.CurrentGame.players[newIdx].currentPlayer.PlayerID;
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }

        [WebMethod(EnableSession = true)]
        public PlayerState RemovePlayerFromRotation()
        {
            PlayerState s = null;
            try
            {
                if (Classes.Game.CurrentGame.currentPlayer.currentPlayer.PlayerID == (int)Session["PlayerID"])
                    Classes.Game.CurrentGame.NextPlayer();
                Classes.Game.CurrentGame.playerSeats.Remove((int)Session["PlayerID"]);
                Classes.Game.CurrentGame.players.Where(p => p.currentPlayer.PlayerID == (int)Session["PlayerID"]).FirstOrDefault().DroppedOut = true;
                Classes.Game.CurrentGame.Update();
                s = GetPlayerState();
            }
            catch (Exception ex)
            {
                LogError(ex);
            }
            return s;
        }
    }
}

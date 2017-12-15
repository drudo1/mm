﻿using System;
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
        public bool isEpic { get; set; }
        public GameStates currentState { get; set; }
        public List<CurrentGamePlayer> players { get; set; }
        public DateTime gameDate { get; set; }
        public CurrentGamePlayer currentPlayer { get; set; }
        public Battle currentBattle { get; set; }
        public DateTime lastUpdated { get; set; }
        public double lastUpdatedJS
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

        public Game(bool epic)
        {
            gameDate = DateTime.Now;
            players = new List<CurrentGamePlayer>();
            currentState = GameStates.Setup;
            isEpic = epic;
            lastUpdated = DateTime.Now;
            currentPlayer = new CurrentGamePlayer();
            currentBattle = new Battle();
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

        public void AddNewPlayer(string username, string firstName, string lastName, string nickName, Gender gender)
        {
            int id = Player.AddNewPlayer(username, firstName, lastName, nickName, gender);
            AddExistingPlayer(id);
        }

        public void SetState(GameStates newState)
        {
            currentState = newState;
            lastUpdated = DateTime.Now;
        }

        public void StartGame()
        {
            StartGame(players[0].currentPlayer.PlayerID);
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
                idx = players.IndexOf(currentPlayer);
                idx = (idx + 1) % players.Count;
            }
            currentPlayer = players[idx];
            SetState(GameStates.BattlePrep);
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
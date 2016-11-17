using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MunchkinMonitor.Classes
{

    [Serializable]
    public class Battle
    {
        public DateTime battleDT { get; set; }
        public CurrentGamePlayer gamePlayer { get; set; }
        public CurrentGamePlayer ally { get; set; }
        public List<Monster> opponents { get; set; }
        public int opponentBonus { get; set; }
        public int playerOneTimeBonus { get; set; }
        public int allyTreasures { get; set; }
        public int allyHelpLevels { get; set; }
        public DateTime lastUpdated { get; set; }
        public BattleResult result { get; set; }
        public int playerPoints
        {
            get
            {
                int points = gamePlayer.FightingLevel;
                if (ally != null)
                    points += ally.FightingLevel;
                points += playerOneTimeBonus;
                return points;
            }
        }
        public int opponentPoints
        {
            get
            {
                int points = opponentBonus;
                foreach(Monster m in opponents)
                {
                    points += m.Level;
                }
                return points;
            }
        }
        public int LevelsAtStake
        {
            get
            {
                int levels = 0;
                foreach (Monster m in opponents)
                    levels += m.LevelsToWin;
                if (gamePlayer.CurrentRaceList.Where(r => r.ExtraLevelForTenOrHigherWhenAlone).Count() > 0 || gamePlayer.CurrentClassList.Where(c => c.ExtraLevelForTenOrHigherWhenAlone).Count() > 0 || gamePlayer.Helpers.Where(h => h.Modifier != null && h.Modifier.LevelsForHelp).Count() > 0)
                {
                    if (ally == null)
                    {
                        int strenth = 0;
                        foreach (Monster m in opponents)
                            strenth += m.Level;
                        if (strenth >= 10)
                            levels += 1;
                    }
                }
                return levels;
            }
        }

        public int AssistLevels
        {
            get
            {
                int levels = allyHelpLevels;
                if(ally != null && (ally.CurrentRaceList.Where(r => r.LevelsForHelp).Count() > 0 || ally.CurrentClassList.Where(c => c.LevelsForHelp).Count() > 0 || ally.Helpers.Where(h => h.Modifier != null && h.Modifier.LevelsForHelp).Count() > 0))
                {
                    foreach (Monster m in opponents)
                        levels += 1;
                }
                return levels;
            }
        }

        public int TotalTreasures
        {
            get
            {
                int treasures = 0;
                foreach (Monster m in opponents)
                    treasures += m.Treasures;
                return treasures;
            }
        }
        public double lastUpdatedJS
        {
            get
            {
                return lastUpdated.Subtract(new DateTime(1970, 1, 1)).TotalMilliseconds;
            }
        }

        public Battle()
        {
            gamePlayer = new CurrentGamePlayer();
            opponents = new List<Monster>();
            opponentBonus = 0;
            playerOneTimeBonus = 0;
            lastUpdated = DateTime.Now;
        }

        public Battle(CurrentGamePlayer challenger, int monsterLevel, int levelsToWin, int treasures)
        {
            battleDT = DateTime.Now;
            gamePlayer = challenger;
            opponents = new List<Monster> { new Monster(monsterLevel, levelsToWin, treasures) };
            opponentBonus = 0;
            playerOneTimeBonus = 0;
            lastUpdated = DateTime.Now;
        }

        public void AddMonster(Monster add, Player attacker)
        {
            if (attacker != null)
                Logger.LogAttack(gamePlayer, attacker);
            opponents.Add(add);
            lastUpdated = DateTime.Now;
        }

        public void AddAlly (CurrentGamePlayer player, int treasures, int levels)
        {
            ally = player;
            allyTreasures = treasures;
            allyHelpLevels = levels;
            lastUpdated = DateTime.Now;
        }

        public void HelpPlayer(int points, Player helper)
        {
            if (helper != null)
                Logger.LogHelp(gamePlayer, helper);
            playerOneTimeBonus += points;
            lastUpdated = DateTime.Now;
        }

        public void HelpMonster(int points, Player attacker)
        {
            if (attacker != null)
                Logger.LogAttack(gamePlayer, attacker);
            opponentBonus += points;
            lastUpdated = DateTime.Now;
        }

        public void AttackPlayer(int points, Player attacker)
        {
            if (attacker != null)
                Logger.LogAttack(gamePlayer, attacker);
            playerOneTimeBonus -= points;
            lastUpdated = DateTime.Now;
        }

        public void AttackMonster(int points, Player helper)
        {
            if (helper != null)
                Logger.LogHelp(gamePlayer, helper);
            opponentBonus -= points;
            lastUpdated = DateTime.Now;
        }

        public void ResolveBattle()
        {
            result = new BattleResult(gamePlayer);
            if(playerPoints > opponentPoints)
            {
                result.Victory = true;
                result.levelsWon = (LevelsAtStake - allyHelpLevels);
                result.treasuresWon = (TotalTreasures - allyTreasures);
                if(ally != null)
                {
                    result.assistedBy = ally;
                    result.assistLevels = AssistLevels;
                    result.assistTreasures = allyTreasures;
                }
                gamePlayer.CurrentLevel += result.levelsWon;
                ally.CurrentLevel += AssistLevels;
                gamePlayer.NextBattleModifier = 0;
                ally.Treasures += allyTreasures;
                gamePlayer.Treasures += result.treasuresWon;
                Logger.LogVictory(result);
            }
            else
            {
                result.Victory = false;
                Logger.LogDefeat(result);
            }
        }
    }

}
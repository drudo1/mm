using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MunchkinMonitor.Classes
{
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
                if (gamePlayer.CurrentRace.ExtraLevelForTenOrHigherWhenAlone || gamePlayer.CurrentClass.ExtraLevelForTenOrHigherWhenAlone)
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
                if(ally.CurrentRace.LevelsForHelp || ally.CurrentClass.LevelsForHelp)
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

        public Battle()
        { }

        public Battle(CurrentGamePlayer challenger, int monsterLevel, int levelsToWin, int treasures)
        {
            battleDT = DateTime.Now;
            gamePlayer = challenger;
            opponents = new List<Monster> { new Monster(monsterLevel, levelsToWin, treasures) };
            opponentBonus = 0;
            playerOneTimeBonus = 0;
        }

        public void AddMonster(Monster add, Player attacker)
        {
            if (attacker != null)
                Logger.LogAttack(gamePlayer, attacker);
            opponents.Add(add);
        }

        public void AddAlly (CurrentGamePlayer player, int treasures, int levels)
        {
            ally = player;
            allyTreasures = treasures;
            allyHelpLevels = levels;
        }

        public void HelpPlayer(int points, Player helper)
        {
            if (helper != null)
                Logger.LogHelp(gamePlayer, helper);
            playerOneTimeBonus += points;
        }

        public void HelpMonster(int points, Player attacker)
        {
            if (attacker != null)
                Logger.LogAttack(gamePlayer, attacker);
            opponentBonus += points;
        }

        public void AttackPlayer(int points, Player attacker)
        {
            if (attacker != null)
                Logger.LogAttack(gamePlayer, attacker);
            playerOneTimeBonus -= points;
        }

        public void AttackMonster(int points, Player helper)
        {
            if (helper != null)
                Logger.LogHelp(gamePlayer, helper);
            opponentBonus -= points;
        }

        public BattleResult ResolveBattle()
        {
            BattleResult br = new BattleResult(gamePlayer);
            if(playerPoints > opponentPoints)
            {
                br.Victory = true;
                br.levelsWon = (LevelsAtStake - allyHelpLevels);
                br.treasuresWon = (TotalTreasures - allyTreasures);
                if(ally != null)
                {
                    br.assistedBy = ally;
                    br.assistLevels = AssistLevels;
                    br.assistTreasures = allyTreasures;
                }
                gamePlayer.CurrentLevel += br.levelsWon;
                ally.CurrentLevel += AssistLevels;
                gamePlayer.NextBattleModifier = 0;
                ally.Treasures += allyTreasures;
                gamePlayer.Treasures += br.treasuresWon;
                Logger.LogVictory(br);
            }
            else
            {
                br.Victory = false;
                Logger.LogDefeat(br);
            }
            return br;
        }
    }

}
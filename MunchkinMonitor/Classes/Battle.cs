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
        public int playerOneTimeBonus { get; set; }
        public int allyTreasures { get; set; }
        public DateTime lastUpdated { get; set; }
        public BattleResult result { get; set; }
        public bool HasAlly
        {
            get
            {
                return ally != null;
            }
        }
        public string AllyName
        {
            get
            {
                return HasAlly ? ally.currentPlayer.DisplayName : "none";
            }
        }
        public List<CurrentGamePlayer> PossibleAllies
        {
            get
            {
                AppState state = AppState.CurrentState();
                List<CurrentGamePlayer> results = state.gameState.players.Where(p => p != gamePlayer).ToList();
                return results;
            }
        }
        public bool WinsTies
        {
            get
            {
                bool result = false;
                List<CharacterModifier> lcm =
                    gamePlayer.CurrentClassList.Union(gamePlayer.CurrentRaceList).ToList();
                foreach (CharacterModifier cm in lcm)
                {
                    if (cm.WinsTies)
                    {
                        result = true;
                        break;
                    }
                }
                if(!result)
                {
                    foreach(CharacterHelper ch in gamePlayer.Helpers)
                    {
                        if(ch.RaceModifier.WinsTies)
                        {
                            result = true;
                            break;
                        }
                        if(ch.ClassModifier.WinsTies)
                        {
                            result = true;
                            break;
                        }
                    }
                }
                if(!result && HasAlly)
                {
                    lcm = ally.CurrentClassList.Union(ally.CurrentRaceList).ToList();
                    foreach(CharacterModifier cm in lcm)
                    {
                        if(cm.WinsTies)
                        {
                            result = true;
                            break;
                        }
                    }
                }
                return result;
            }
        }
        public bool GoodGuysWin
        {
            get
            {
                return playerPoints > opponentPoints || (WinsTies && (playerPoints == opponentPoints));
            }
        }
        public int allyFightingLevel
        {
            get
            {
                return HasAlly ? ally.AllyLevel : 0;
            }
        }
        public int playerPoints
        {
            get
            {
                int points = gamePlayer.FightingLevel;
                if (ally != null)
                    points += ally.AllyLevel;
                points += playerOneTimeBonus;
                return points;
            }
        }
        public int opponentPoints
        {
            get
            {
                int points = 0;
                foreach(Monster m in opponents)
                {
                    points += m.Level;
                    points += m.OneTimeBonus;
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
                {
                    levels += m.LevelsToWin;
                    if (gamePlayer.CurrentRaceList.Where(r => r.ExtraLevelForTenOrHigherWhenAlone).Count() > 0 || gamePlayer.CurrentClassList.Where(c => c.ExtraLevelForTenOrHigherWhenAlone).Count() > 0)
                    {
                        if (ally == null)
                        {
                            if (gamePlayer.FightingLevel - m.Level >= 10)
                                levels += 1;
                        }
                    }
                }
               
                return levels;
            }
        }

        public int AssistLevels
        {
            get
            {
                int levels = 0;
                if(ally != null && (ally.CurrentRaceList.Where(r => r.LevelsForHelp).Count() > 0 || ally.CurrentClassList.Where(c => c.LevelsForHelp).Count() > 0 || ally.Helpers.Where(h => h.RaceModifier != null && h.RaceModifier.LevelsForHelp).Count() > 0))
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
            playerOneTimeBonus = 0;
            lastUpdated = DateTime.Now;
        }

        public Battle(CurrentGamePlayer challenger, int monsterLevel, int levelsToWin, int treasures)
        {
            battleDT = DateTime.Now;
            gamePlayer = challenger;
            opponents = new List<Monster> { new Monster(monsterLevel, levelsToWin, treasures) };
            playerOneTimeBonus = 0;
            lastUpdated = DateTime.Now;
        }

        public void AddMonster(Monster add)
        {
            opponents.Add(add);
            lastUpdated = DateTime.Now;
        }

        public void HelpMonster(int idx, int points)
        {
            if (opponents.Count >= idx + 1)
            {
                opponents[idx].OneTimeBonus += points;
                lastUpdated = DateTime.Now;
            }
        }

        public void AddAlly (CurrentGamePlayer player, int treasures)
        {
            ally = player;
            allyTreasures = treasures;
            lastUpdated = DateTime.Now;
        }

        public void RemoveAlly()
        {
            ally = null;
            allyTreasures = 0;
            lastUpdated = DateTime.Now;
        }

        public void HelpGoodGuys(int points)
        {
            playerOneTimeBonus += points;
            lastUpdated = DateTime.Now;
        }

        public void AttackPlayer(int points)
        {
            playerOneTimeBonus -= points;
            lastUpdated = DateTime.Now;
        }

        public void AttackMonster(int idx, int points)
        {
            if (opponents.Count >= idx + 1)
            {
                opponents[idx].OneTimeBonus -= points;
                lastUpdated = DateTime.Now;
            }
        }

        public void ResolveBattle()
        {
            result = new BattleResult(gamePlayer);
            if(playerPoints > opponentPoints || (WinsTies && (playerPoints == opponentPoints)))
            {
                result.Victory = true;
                result.NumDefeated = opponents.Count;
                result.levelsWon = LevelsAtStake;
                result.treasuresWon = (TotalTreasures - allyTreasures);
                result.opponentPoints = opponentPoints;
                if(ally != null)
                {
                    result.assistedBy = ally;
                    result.assistLevels = AssistLevels;
                    result.assistTreasures = allyTreasures;
                    ally.CurrentLevel += AssistLevels;
                    ally.Treasures += allyTreasures;
                }
                gamePlayer.CurrentLevel += result.levelsWon;
                gamePlayer.NextBattleModifier = 0;
                gamePlayer.Treasures += result.treasuresWon;
            }
            else
            {
                result.Victory = false;
            }
            Logger.LogBattle(result);
        }
    }

}
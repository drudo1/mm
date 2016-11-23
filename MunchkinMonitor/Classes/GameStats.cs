using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MunchkinMonitor.Classes
{
    public class GameStats
    {
        public int playerID { get; set; }
        public int kills { get; set; }
        public int treasures { get; set; }
        public int singleHandedKills { get; set; }
        public int assists { get; set; }
        public int losses { get; set; }
        public int maxGear { get; set; }
        public int levelsLost { get; set; }
        public int deaths { get; set; }
        public int genderChanges { get; set; }
        public bool Victory { get; set; }

        public static List<GameStats> CurrentGameStats
        {
            get
            {
                if (HttpContext.Current.Application["GameStats"] == null)
                {
                    List<GameStats> stats = new List<GameStats>();
                    HttpContext.Current.Application["GameStats"] = stats;
                }

                return (List<GameStats>)(HttpContext.Current.Application["GameStats"]);
            }
        }
        public static GameStats playerStats(int playerID)
        {
            if (CurrentGameStats.Where(gs => gs.playerID == playerID).Count() == 0)
                CurrentGameStats.Add(new GameStats { playerID = playerID });
            return CurrentGameStats.Where(gs => gs.playerID == playerID).FirstOrDefault();
        }
        public static void LogBattle(BattleResult br)
        {
            if (br.Victory)
            {
                playerStats(br.gamePlayer.currentPlayer.PlayerID).kills += br.NumDefeated;
                playerStats(br.gamePlayer.currentPlayer.PlayerID).treasures += br.treasuresWon;
                if (br.assistedBy == null)
                    playerStats(br.gamePlayer.currentPlayer.PlayerID).singleHandedKills += br.NumDefeated;
                else
                {
                    playerStats(br.assistedBy.currentPlayer.PlayerID).treasures += br.assistTreasures;
                }
            }
            else
                playerStats(br.gamePlayer.currentPlayer.PlayerID).losses += 1;

            if (br.assistedBy != null)
                playerStats(br.assistedBy.currentPlayer.PlayerID).assists += 1;
        }
        public static void LogLevelLost(int playerID)
        {
            playerStats(playerID).levelsLost += 1;
        }
        public static void LogMaxGear(int playerID, int gearBonus)
        {
            if (playerStats(playerID).maxGear < gearBonus)
                playerStats(playerID).maxGear = gearBonus;
        }
        public static void LogDeath(int playerID)
        {
            playerStats(playerID).deaths += 1;
        }
        public static void LogGenderChange(int playerID)
        {
            playerStats(playerID).genderChanges += 1;
        }
        public static void LogVictory(int playerID)
        {
            playerStats(playerID).Victory = true;
        }

    }

}
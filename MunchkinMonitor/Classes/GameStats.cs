using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MunchkinMonitor.Classes
{
    public class TrophyRequirement
    {
        public int difficulty { get; set; }
        public string Title { get; set; }
        public int kills { get; set; }
        public int treasures { get; set; }
        public int singleHandedKills { get; set; }
        public int assists { get; set; }
        public int losses { get; set; }
        public int maxGear { get; set; }
        public int maxMonster { get; set; }
        public int levelsLost { get; set; }
        public int deaths { get; set; }
        public int genderChanges { get; set; }
        public string reason { get; set; }
        public static List<TrophyRequirement> possibleTrophies = new List<TrophyRequirement>
        {
            new TrophyRequirement {Title= "Armed to the Teeth!" , maxGear=10, reason="Achieved a gear bonus of {0}", difficulty= 1 },
            new TrophyRequirement {Title= "The Lone Munchkin", singleHandedKills=3, reason="Had {0} single-handed kills.", difficulty= 2},
            new TrophyRequirement {Title= "Got BLING!", treasures= 4, reason="Captured {0} treasures", difficulty= 1 },
            new TrophyRequirement {Title= "Rolling in It!", treasures=4, reason="Captured {0} treasures", difficulty= 1 },
            new TrophyRequirement {Title= "There and Back Again...", genderChanges=2, reason="Had their gender changed {0} times.", difficulty= 3 },
            new TrophyRequirement {Title= "Confused Little Munchkin", genderChanges=2, reason="Had their gender changed {0} times.", difficulty= 3},
            new TrophyRequirement {Title= "Never Say DIE!", deaths=2, reason="Died and resurrected {0} times.", difficulty= 4 },
            new TrophyRequirement {Title= "Good Samaritan", assists=3, reason="Provided assistance {0} times.", difficulty= 3 },
            new TrophyRequirement {Title= "Rough Ride Award", levelsLost=2, reason="Lost {0} levels.", difficulty= 2 },
            new TrophyRequirement {Title= "Slayer!", maxMonster=20, reason="Single-handedly won a battle against a fighting level of {0}.", difficulty= 1 },
            new TrophyRequirement {Title= "Why Won't You DIE?", losses=7, reason="Lost {0} battles and kept coming back for more!", difficulty= 2 },
            new TrophyRequirement {Title= "Consolation Prize", reason="Yeah... you really didn't accomplish anything.  Better luck next time...", difficulty= 0 },
            new TrophyRequirement {Title= "Defeat", reason="For every winner, there are dozens of losers...  Odds are you're one of them.", difficulty= 0 },
            new TrophyRequirement {Title= "Blame", reason="The secret to success is knowing who to blame for your failures.", difficulty= 0 }
        };
    }
    public class Trophy
    {
        public string Title { get; set; }
        public Player player { get; set; }
        public string Reason { get; set; }
    }
    public class GameStats
    {
        public int playerID { get; set; }
        public int kills { get; set; }
        public int treasures { get; set; }
        public int singleHandedKills { get; set; }
        public int assists { get; set; }
        public int losses { get; set; }
        public int maxGear { get; set; }
        public int maxMonster { get; set; }
        public int levelsLost { get; set; }
        public int deaths { get; set; }
        public int genderChanges { get; set; }
        public bool Victory { get; set; }
        static Random rnd = new Random();

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
                {
                    playerStats(br.gamePlayer.currentPlayer.PlayerID).singleHandedKills += br.NumDefeated;
                    playerStats(br.gamePlayer.currentPlayer.PlayerID).maxMonster = Math.Max(br.opponentPoints, playerStats(br.gamePlayer.currentPlayer.PlayerID).maxMonster);
                }
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

        public static List<Trophy> GetTrophies()
        {
            
            List<Trophy> trophies = new List<Trophy>();
            trophies.AddRange(CurrentGameStats.Where(gs => gs.Victory).Select(gs => new Trophy { Title = "King Munchkin", player = AppState.CurrentState().playerStats.players.Where(p => p.PlayerID == gs.playerID).FirstOrDefault(), Reason = "For Thieving, Lying, Backstabbing, and all around Good Munchkinry... and for getting there first..." }));
            List<string> attempted = new List<string> { "King Munchkin" };
            while (CurrentGameStats.Where(gs => trophies.Where(t => t.player.PlayerID == gs.playerID).Count() == 0).Count() > 0)
            {
                Trophy trophy = null;
                while(trophy == null && attempted.Count < TrophyRequirement.possibleTrophies.Where(t => t.assists + t.deaths + t.genderChanges + t.kills + t.levelsLost + t.losses + t.maxGear + t.singleHandedKills + t.treasures > 0).Count())
                {
                    int r = rnd.Next(TrophyRequirement.possibleTrophies.Where(pt => !attempted.Contains(pt.Title) && (pt.assists + pt.deaths + pt.genderChanges + pt.kills + pt.levelsLost + pt.losses + pt.maxGear + pt.singleHandedKills + pt.treasures > 0)).OrderByDescending(pt => pt.difficulty).Count());
                    TrophyRequirement tmp = TrophyRequirement.possibleTrophies.Where(pt => !attempted.Contains(pt.Title) && (pt.assists + pt.deaths + pt.genderChanges + pt.kills + pt.levelsLost + pt.losses + pt.maxGear + pt.singleHandedKills + pt.treasures > 0)).OrderByDescending(pt => pt.difficulty).ToList()[r];
                    if (!attempted.Contains(tmp.Title))
                        attempted.Add(tmp.Title);
                    bool qualified = false;
                    foreach(GameStats gs in CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)))
                    {
                        if(tmp.assists > 0 && gs.assists >= tmp.assists)
                        {
                            qualified = true;
                            break;
                        }
                        else if (tmp.deaths > 0 && gs.deaths >= tmp.deaths)
                        {
                            qualified = true;
                            break;
                        }
                        else if (tmp.genderChanges > 0 && gs.genderChanges >= tmp.genderChanges)
                        {
                            qualified = true;
                            break;
                        }
                        else if (tmp.kills > 0 && gs.kills >= tmp.kills)
                        {
                            qualified = true;
                            break;
                        }
                        else if (tmp.levelsLost > 0 && gs.levelsLost >= tmp.levelsLost)
                        {
                            qualified = true;
                            break;
                        }
                        else if (tmp.losses > 0 && gs.losses >= tmp.losses)
                        {
                            qualified = true;
                            break;
                        }
                        else if (tmp.maxGear > 0 && gs.maxGear >= tmp.maxGear)
                        {
                            qualified = true;
                            break;
                        }
                        else if (tmp.maxMonster > 0 && gs.maxMonster >= tmp.maxMonster)
                        {
                            qualified = true;
                            break;
                        }
                        else if (tmp.singleHandedKills > 0 && gs.singleHandedKills >= tmp.singleHandedKills)
                        {
                            qualified = true;
                            break;
                        }
                        else if (tmp.treasures > 0 && gs.treasures >= tmp.treasures)
                        {
                            qualified = true;
                            break;
                        }
                    }
                    if (qualified)
                    {
                        if (tmp.assists > 0)
                        {
                            int max = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Max(gs => gs.assists);
                            GameStats stat = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Where(gs => gs.assists == max).FirstOrDefault();
                            trophy = new Trophy
                            {
                                player = AppState.CurrentState().playerStats.players.Where(p => p.PlayerID == stat.playerID).FirstOrDefault(),
                                Title = tmp.Title,
                                Reason = string.Format(tmp.reason, stat.assists)
                            };
                        }
                        else if (tmp.deaths > 0)
                        {
                            int max = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Max(gs => gs.deaths);
                            GameStats stat = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Where(gs => gs.deaths == max).FirstOrDefault();
                            trophy = new Trophy
                            {
                                player = AppState.CurrentState().playerStats.players.Where(p => p.PlayerID == stat.playerID).FirstOrDefault(),
                                Title = tmp.Title,
                                Reason = string.Format(tmp.reason, stat.deaths)
                            };
                        }
                        else if (tmp.genderChanges > 0)
                        {
                            int max = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Max(gs => gs.genderChanges);
                            GameStats stat = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Where(gs => gs.genderChanges == max).FirstOrDefault();
                            trophy = new Trophy
                            {
                                player = AppState.CurrentState().playerStats.players.Where(p => p.PlayerID == stat.playerID).FirstOrDefault(),
                                Title = tmp.Title,
                                Reason = string.Format(tmp.reason, stat.genderChanges)
                            };
                        }
                        else if (tmp.kills > 0)
                        {
                            int max = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Max(gs => gs.kills);
                            GameStats stat = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Where(gs => gs.kills == max).FirstOrDefault();
                            trophy = new Trophy
                            {
                                player = AppState.CurrentState().playerStats.players.Where(p => p.PlayerID == stat.playerID).FirstOrDefault(),
                                Title = tmp.Title,
                                Reason = string.Format(tmp.reason, stat.kills)
                            };
                        }
                        else if (tmp.levelsLost > 0)
                        {
                            int max = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Max(gs => gs.levelsLost);
                            GameStats stat = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Where(gs => gs.levelsLost == max).FirstOrDefault();
                            trophy = new Trophy
                            {
                                player = AppState.CurrentState().playerStats.players.Where(p => p.PlayerID == stat.playerID).FirstOrDefault(),
                                Title = tmp.Title,
                                Reason = string.Format(tmp.reason, stat.levelsLost)
                            };
                        }
                        else if (tmp.losses > 0)
                        {
                            int max = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Max(gs => gs.losses);
                            GameStats stat = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Where(gs => gs.losses == max).FirstOrDefault();
                            trophy = new Trophy
                            {
                                player = AppState.CurrentState().playerStats.players.Where(p => p.PlayerID == stat.playerID).FirstOrDefault(),
                                Title = tmp.Title,
                                Reason = string.Format(tmp.reason, stat.losses)
                            };
                        }
                        else if (tmp.maxGear > 0)
                        {
                            int max = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Max(gs => gs.maxGear);
                            GameStats stat = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Where(gs => gs.maxGear == max).FirstOrDefault();
                            trophy = new Trophy
                            {
                                player = AppState.CurrentState().playerStats.players.Where(p => p.PlayerID == stat.playerID).FirstOrDefault(),
                                Title = tmp.Title,
                                Reason = string.Format(tmp.reason, stat.maxGear)
                            };
                        }
                        else if (tmp.maxMonster > 0)
                        {
                            int max = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Max(gs => gs.maxMonster);
                            GameStats stat = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Where(gs => gs.maxMonster == max).FirstOrDefault();
                            trophy = new Trophy
                            {
                                player = AppState.CurrentState().playerStats.players.Where(p => p.PlayerID == stat.playerID).FirstOrDefault(),
                                Title = tmp.Title,
                                Reason = string.Format(tmp.reason, stat.maxMonster)
                            };
                        }
                        else if (tmp.singleHandedKills > 0)
                        {
                            int max = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Max(gs => gs.singleHandedKills);
                            GameStats stat = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Where(gs => gs.singleHandedKills == max).FirstOrDefault();
                            trophy = new Trophy
                            {
                                player = AppState.CurrentState().playerStats.players.Where(p => p.PlayerID == stat.playerID).FirstOrDefault(),
                                Title = tmp.Title,
                                Reason = string.Format(tmp.reason, stat.singleHandedKills)
                            };
                        }
                        else if (tmp.treasures > 0)
                        {
                            int max = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Max(gs => gs.treasures);
                            GameStats stat = CurrentGameStats.Where(gs => !trophies.Select(t => t.player.PlayerID).Contains(gs.playerID)).Where(gs => gs.treasures == max).FirstOrDefault();
                            trophy = new Trophy
                            {
                                player = AppState.CurrentState().playerStats.players.Where(p => p.PlayerID == stat.playerID).FirstOrDefault(),
                                Title = tmp.Title,
                                Reason = string.Format(tmp.reason, stat.treasures)
                            };
                        }
                    }
                }
                if(trophy != null)
                    trophies.Add(trophy);
            }
            while (CurrentGameStats.Where(gs => trophies.Where(t => t.player.PlayerID == gs.playerID).Count() == 0).Count() > 0)
            {
                Random rnd = new Random(Environment.TickCount);
                int idx = rnd.Next(0, TrophyRequirement.possibleTrophies.Where(t => t.assists + t.deaths + t.genderChanges + t.kills + t.levelsLost + t.losses + t.maxGear + t.singleHandedKills + t.treasures == 0).Count());
                TrophyRequirement tmp = TrophyRequirement.possibleTrophies.Where(t => t.assists + t.deaths + t.genderChanges + t.kills + t.levelsLost + t.losses + t.maxGear + t.singleHandedKills + t.treasures == 0).ToList()[idx];
                Trophy trophy = new Trophy
                {
                    player = AppState.CurrentState().playerStats.players.Where(p => !trophies.Select(t => t.player.PlayerID).Contains(p.PlayerID)).FirstOrDefault(),
                    Title = tmp.Title,
                    Reason = tmp.reason
                };
                trophies.Add(trophy);
            }
            return trophies;
        }
    }

}
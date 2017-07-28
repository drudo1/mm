using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MunchkinMonitor.Classes
{

    [Serializable]
    public class BattleResult
    {
        public CurrentGamePlayer gamePlayer { get; set; }
        public bool Victory { get; set; }
        public int NumDefeated { get; set; }
        public int levelsWon { get; set; }
        public int treasuresWon { get; set; }
        public CurrentGamePlayer assistedBy { get; set; }
        public int assistLevels { get; set; }
        public int assistTreasures { get; set; }

        public BattleResult(CurrentGamePlayer gamePlayer)
        {
            this.gamePlayer = gamePlayer;
        }

        public string Message
        {
            get
            {
                List<string> victoryMessages = new List<string>
                {
                    "WTF!\r\nI WON?",
                    "I LOVE THE SMELL OF VICTORY IN THE MORNING.",
                    "THANK GOD!\r\nI SURVIVED!!!",
                    "FI-YAH POW-AH!!!",
                    "IS IT OKAY TO GLOAT NOW?",
                    "I WAS TOLD THERE WOULD BE CAKE...",
                    "MMMM...\r\nYOUR TEARS ARE SO YUMMY AND SWEET.",
                    "AND THE PEASANTS REJOICED...",
                    "TRY TO KEEP UP.",
                    "WINNERS NEVER FLY HIGHER THAN WHEN THEY'RE BOUNCING UP AND DOWN ON THE EGOS OF THOSE THEY'VE DEFEATED.",
                    "BOO-YAH!",
                    "I LOVE WINNING!\r\nWINNING'S MY FAVORITE!",
                    "UMMMM... WINNING!",
                    "ONE DAY I WILL STOP WINNING...\r\nBUT TODAY IS NOT THAT DAY!",
                    "SO MUCH WIN!",
                    "IT'S NOT ABOUT WINNING...\r\nIT'S ABOUT SENDING A MESSAGE.",
                    "WHO'S AWESOME?\r\nYOU'RE AWESOME!",
                    "VICTORY SHALL BE MINE!",
                    "SOME PEOPLE DREAM OF SUCCESS, WHILE OTHERS LIVE TO CRUSH THOSE DREAMS!",
                    "THERE CAN BE ONLY ONE!",
                    "MAY GOD HAVE MERCY ON MY ENEMIES... BECAUSE I WON'T!",
                    "PAIN IS ONLY TEMPORARY, BUT VICTORY IS FOREVER.",
                    "I DON'T KNOW...  I WAS TOO BUSY WINNING!",
                    "YOU'RE A WINNER... AND YOU'RE A WINNER... AND YOU'RE A WINNER... EVERYONE'S A WINNER!!!",
                    "WINNER, WINNER, CHICKEN DINNER...",
                    "SPRINKLES ARE FOR WINNERS...",
                    "IF IT'S NOT ABOUT WINNING, WHAT'S THE POINT OF PLAYING?",
                    "ALL I DO IS WIN!",
                    "I DON'T ALWAYS WIN... OH WAIT... YES I DO!",
                    "THIS IS MY WINNING FACE",
                    "NOW THIS... THIS IS WHAT A WINNER LOOKS LIKE.",
                    "WINNING IS JUST MY THING...",
                    "THEY TOLD ME TO ADMIT DEFEAT... I ADMITTED THEM TO THEIR GRAVES.",
                    "I SHALL DEFEAT MY ENEMIES... WITH NUKES... AND SPIDERS!",
                    "WHO ARE YOU? ..... I'M BATMAN.",
                    "Y U NO ACCEPT DEFEAT?",
                    "YOU WIN.... THIS TIME.",
                    "TO ALL MY HATERS... THIS WIN IS FOR YOU."
                };
                List<string> loserMessages = new List<string>
                {
                    "JUST BECAUSE YOU'VE ALWAYS DONE IT THAT WAY DOESN'T MEAN IT'S NOT INCREDIBLY STUPID.",
                    "IT COULD BE THAT THE PURPOSE OF YOUR LIFE IS ONLY TO SERVE AS A WARNING TO OTHERS.",
                    "THE JOURNEY OF A THOUSANT MILES SOMETIMES ENDS VERY, VERY BADLY.",
                    "NOT EVERYONE GETS TO BE AN ASTRONAUT WHEN THEY GROW UP...",
                    "BELIEVE IN YOURSELF... BECAUSE THE REST OF US THINK YOU'RE A LOSER.",
                    "THOSE WHO SAY IT CANNOT BE DONE SHOULD NOT INTERRUPT THOSE BUSY PROVING THEM RIGHT.",
                    "HOPE MAY NOT BE WARRANTED AT THIS POINT.",
                    "ALL WE ASK IS THAT YOU GIVE US YOUR HEART.",
                    "I EXPECTED TIMES LIKE THIS, BUT I NEVER THOUGHT THEY'D BE SO BAD, SO LONG, AND SO FREQUENT.",
                    "THAT WHICH DOES NOT KILL ME ONLY POSTPONES THE INEVITABLE.",
                    "AGONY\r\nNOT ALL PAIN IS GAIN",
                    "THE SECRET TO SUCCESS IS KNOWING WHO TO BLAME FOR YOUR FAILURES.",
                    "EVERY MAN DIES, BUT NOT EVERY MAN TRULY LIVES ONLY TO DIE OF SHEER STUPIDITY.",
                    "FOR EVERY WINNER THERE ARE DOZENS OF LOSERS... ODDS ARE GOOD YOU'RE ONE OF THEM.",
                    "IT'S ALWAYS DARKEST JUST BEFORE IT GOES PITCH BLACK.",
                    "FAILURE\r\nWHEN YOUR BEST JUST ISN'T GOOD ENOUGH.",
                    "GIVE UP\r\nAT SOME POINT HANGING IN THERE JUST MAKES YOU LOOK LIKE AN EVEN BIGGER LOSER.",
                    "THE HARDER YOU TRY\r\nTHE DUMBER YOU LOOK.",
                    "WHEN YOU EARNESTLY BELIEVE YOU CAN COMPENSATE FOR A LACK OF SKILL BY DOUBLING YOUR EFFORTS, THERE'S NO END TO WHAT YOU CAN'T DO.",
                    "IF YOU CAN'T LEARN TO DO SOMETHING WELL, LEARN TO ENJOY DOING IT POORLY.",
                    "WHEN THE GOING GETS TOUGH, THE TOUGH GET GOING...\r\nTHE SMART LEFT A LONG TIME AGO.",
                    "NO ONE CAN MAKE YOU FEEL INFERIOR WITHOUT YOUR CONSENT.\r\nBUT YOU'D BE A FOOL TO WITHHOLD THAT FROM YOUR SUPERIORS.",
                    "IF AT FIRST YOU DON'T SUCEEED...\r\nLOSING MAY JUST BE YOUR STYLE.",
                    "SOME THINGS CANNOT BE OVERCOME WITH DETERMINATION AND A POSITIVE ATTITUDE.",
                    "BEFORE YOU ATTEMPT TO BEAT THE ODDS, BE SURE YOU CAN SURVIVE THE ODDS BEATING YOU.",
                    "PAIN IS JUST WEEKNESS LEAVING THE BODY... LOTS OF WEEKNESS.",
                    "QUITTERS NEVER WIN, WINNERS NEVER QUIT, BUT THOSE WHO NEVER WIN AND NEVER QUIT ARE IDIOTS.",
                    "TYPE LOSER.COM IN TO YOUR BROWSER AND SEE WHAT COMES UP... IT'S AWESOME.",
                    "YEAH, IF YOU COULD STOP BEIN A LIL BITCH... THAT WOULD BE GREAT...",
                    "NOT SURE IF I DON'T HAVE ANY FRIENDS BECAUSE I'M A LOSER... OR IF I AM A LOSER BECAUSE I DON'T HAVE ANY FRIENDS...",
                    "WHEN YOU REALISE, THIS REALLY ISN'T YOUR GAME...",
                    "GET IN LOSER... WE'RE GOIN' TO WALMART.",
                    "EAT, SLEEP, LOSE... REPEAT",
                    "I HAVE NO IDEA WHAT I'M DOING.",
                    "THIS IS WHAT DEFEAT SMELLS LIKE."
                };
                Random r = new Random(Environment.TickCount);
                if (Victory)
                {
                    int idx = r.Next(0, victoryMessages.Count - 1);
                    return victoryMessages[idx];
                }
                else
                {
                    int idx = r.Next(0, loserMessages.Count - 1);
                    return loserMessages[idx];
                }
            }
        }

        public List<string> battleResults
        {
            get
            {
                List<string> results = new List<string>();
                if (Victory)
                {
                    results.Add(string.Format("{0} wins {1} Level(s){2}.", gamePlayer.currentPlayer.DisplayName, levelsWon, treasuresWon > 0 ? string.Format(" and {0} Treasure(s)", treasuresWon) : ""));
                    if (assistedBy != null)
                        results.Add(string.Format("{0} wins {1}{2}.", assistedBy.currentPlayer.DisplayName, assistLevels > 0 ? string.Format("{0} Level(s) and ", assistLevels) : "", string.Format("{0} Treasure(s)", assistTreasures)));
                    results.AddRange(gamePlayer.victoryReminders);
                }
                else
                    results.AddRange(gamePlayer.failureReminders);
                return results;
            }
        }

        public int opponentPoints { get; internal set; }
    }
}

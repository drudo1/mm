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
        public int levelsWon { get; set; }
        public int treasuresWon { get; set; }
        public CurrentGamePlayer assistedBy { get; set; }
        public int assistLevels { get; set; }
        public int assistTreasures { get; set; }

        public BattleResult(CurrentGamePlayer gamePlayer)
        {
            this.gamePlayer = gamePlayer;
        }
    }
}

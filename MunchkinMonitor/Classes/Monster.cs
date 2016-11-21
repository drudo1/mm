using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MunchkinMonitor.Classes
{
    public class Monster
    {
        public int Level { get; set; }
        public int LevelsToWin { get; set; }
        public int Treasures { get; set; }
        public int OneTimeBonus { get; set; }

        public Monster(int monsterLevel, int levelsToWin, int treasures)
        {
            this.Level = monsterLevel;
            this.LevelsToWin = levelsToWin;
            this.Treasures = treasures;
            this.OneTimeBonus = 0;
        }
    }
}
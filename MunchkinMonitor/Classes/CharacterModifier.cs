using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MunchkinMonitor.Classes
{
    public class CharacterModifier
    {
        public int ModifierID { get; set; }
        public bool isRace { get; set; }
        public bool isClass { get; set; }
        public int GameTypeID { get; set; }
        public string Description { get; set; }
        public bool WinsTies { get; set; }
        public bool LevelsForHelp { get; set; }
        public bool ExtraLevelForTenOrHigherWhenAlone { get; set; }
        public int combatBonusForHelp { get; set; }
        public List<string> turnReminders { get; set; }
        public List<string> victoryReminders { get; set; }
        public List<string> failureReminders { get; set; }
    }
}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MunchkinMonitor.Classes
{
    public class CharacterHelper
    {
        public int ID { get; set; }
        public bool isHireling { get; set; }
        public bool isSteed { get; set; }
        public int Bonus { get; set; }
        public int Modifier { get; set; }
        public int GearBonus { get; set; }
    }
}
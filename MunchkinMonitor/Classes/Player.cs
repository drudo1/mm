using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MunchkinMonitor.Classes
{
    public enum Gender
    {
        Male,
        Female
    }

    public class Player
    {
        public int PlayerID { get; set; }
        public Gender Gender { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string NickName { get; set; }
        public string DisplayName
        {
            get
            {
                return string.IsNullOrWhiteSpace(NickName) ? string.Format("{0} {1}.", FirstName, LastName.Substring(0,1)) : NickName;
            }
        }
    }
}
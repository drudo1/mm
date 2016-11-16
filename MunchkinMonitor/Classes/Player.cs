using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace MunchkinMonitor.Classes
{
    public enum Gender
    {
        Male,
        Female
    }


    [Serializable]
    public class Player
    {
        public int PlayerID { get; set; }
        public Gender Gender { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string NickName { get; set; }
        public string customImagePath { get; set; }
        public int Victories { get; set; }
        public int Kills { get; set; }
        public int Treasures { get; set; }
        public int Score
        {
            get
            {
                return (Victories * 250) + (Kills * 5) + Treasures;
            }
        }
        public string DisplayName
        {
            get
            {
                return string.IsNullOrWhiteSpace(NickName) ? string.Format("{0} {1}.", FirstName, LastName.Substring(0,1)) : NickName;
            }
        }
        public string ImagePath
        {
            get
            {
                return string.IsNullOrWhiteSpace(customImagePath) ? (Gender == Gender.Male ? "images/DefaultMale.jpg" : "images/DefaultFemale.jpg") : customImagePath;
            }
        }

        public static int AddNewPlayer(string firstName, string lastName, string nickName, Gender gender, string customPath)
        {
            Player p = new Player
            {
                Gender = gender,
                FirstName = firstName,
                LastName = lastName,
                NickName = nickName,
                customImagePath = customPath,
                Victories = 0,
                Kills = 0,
                Treasures = 0
            };

            List<Player> players;
            XmlSerializer serializer = new XmlSerializer(typeof(List<Player>));
            if (File.Exists("players.xml"))
            {
                using (FileStream stream = File.OpenRead("players.xml"))
                {
                    players = (List<Player>)serializer.Deserialize(stream);
                }
            }
            else
                players = new List<Player>();

            p.PlayerID = players.Count > 0 ? players.Aggregate((curMax, x) => (curMax == null || (x.PlayerID) > curMax.PlayerID ? x : curMax)).PlayerID + 1 : 1;
            players.Add(p);

            using (FileStream stream = File.OpenWrite("players.xml"))
            {
                serializer.Serialize(stream, players);
            }

            return p.PlayerID;
        }

        public static Player GetPlayerByID(int id)
        {
            Player p = null;
            XmlSerializer serializer = new XmlSerializer(typeof(List<Player>));
            if (File.Exists("players.xml"))
            {
                using (FileStream stream = File.OpenRead("players.xml"))
                {
                    List<Player> players = (List<Player>)serializer.Deserialize(stream);
                    p = players.Where(x => x.PlayerID == id).FirstOrDefault();
                }
            }
            return p;
        }
    }
}
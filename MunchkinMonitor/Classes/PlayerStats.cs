using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml.Serialization;

namespace MunchkinMonitor.Classes
{

    [Serializable]
    public class PlayerStats
    {
        public List<Player> players { get; set; }

        public PlayerStats()
        {
            XmlSerializer serializer = new XmlSerializer(typeof(List<Player>));
            if (File.Exists("players.xml"))
            {
                using (FileStream stream = File.OpenRead("players.xml"))
                {
                    players = ((List<Player>)serializer.Deserialize(stream)).OrderBy(p => p.Score).ToList();
                }
            }
            else
            {
                players = new List<Player>();
                players.Add(new Player
                {
                    NickName = "No Players Yet",
                    Victories = 0,
                    Kills = 0,
                    Treasures = 0,
                    PlayerID = -1
                });
                players.Add(new Player
                {
                    FirstName = "Dave",
                    LastName = "Rudolph",
                    Kills = 0,
                    Treasures = 0,
                    Victories = 0,
                    PlayerID = 1
                });
                players.Add(new Player
                {
                    FirstName = "Jeff",
                    LastName = "Beierman",
                    NickName = "Jeffster",
                    Kills = 0,
                    Treasures = 0,
                    Victories = 0,
                    PlayerID = 2
                });
            }
        }

    }
}
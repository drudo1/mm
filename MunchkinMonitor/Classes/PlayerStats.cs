using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace MunchkinMonitor.Classes
{

    [Serializable]
    public class PlayerStats
    {
        public List<Player> players { get; set; }

        public PlayerStats()
        {
            string path = HttpContext.Current.Server.MapPath("~/") + "players.xml";
            XmlSerializer serializer = new XmlSerializer(typeof(List<Player>));
            if (File.Exists(path))
            {
                using (FileStream stream = File.OpenRead(path))
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
                    PlayerID = -1,
                    Assists = 0
                });
            }
        }
        public void LogBattleVictory(BattleResult br)
        {
            foreach (Player p in players)
            {
                if (p.PlayerID == br.gamePlayer.currentPlayer.PlayerID)
                {
                    p.Kills += br.NumDefeated;
                    p.Treasures += br.treasuresWon;
                }
                if (br.assistedBy != null && p.PlayerID == br.assistedBy.currentPlayer.PlayerID)
                {
                    p.Assists++;
                    p.Treasures += br.assistTreasures;
                }
            }

            string path = HttpContext.Current.Server.MapPath("~/") + "players.xml";
            XmlSerializer serializer = new XmlSerializer(typeof(List<Player>));
            if (File.Exists(path))
            {
                using (FileStream stream = File.OpenWrite(path))
                {
                    serializer.Serialize(stream, players);
                }
            }
        }

        public void LogVictory(int playerID)
        {
            foreach (Player p in players)
            {
                if (p.PlayerID == playerID)
                {
                    p.Victories++;
                    break;
                }
            }

            string path = HttpContext.Current.Server.MapPath("~/") + "players.xml";
            XmlSerializer serializer = new XmlSerializer(typeof(List<Player>));
            if (File.Exists(path))
            {
                using (FileStream stream = File.OpenWrite(path))
                {
                    serializer.Serialize(stream, players);
                }
            }
        }
    }
}
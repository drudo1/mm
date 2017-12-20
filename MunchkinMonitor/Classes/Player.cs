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
        public string UserName { get; set; }
        public string Password { get; set; }
        public Gender Gender { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string NickName { get; set; }
        public string customImagePathMale { get; set; }
        public string customImagePathFemale { get; set; }
        public int Victories { get; set; }
        public int Kills { get; set; }
        public int Treasures { get; set; }
        public int Assists { get; set; }
        public int GamesPlayed { get; set; }
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
                RoomState state = RoomState.CurrentState;
                return string.IsNullOrWhiteSpace(NickName) ? string.Format("{0}{1}", string.IsNullOrWhiteSpace(FirstName) ? "" : FirstName, string.IsNullOrWhiteSpace(LastName) ? "" : (state != null && state.playerStats != null && state.playerStats.players.Where(p => p.FirstName == FirstName).Count() > 1) ? string.Format(" {0}.", LastName.Substring(0,1)) : "") : NickName;
            }
        }

        public static int AddNewPlayer(string username, string password, string firstName, string lastName, string nickName, Gender gender)
        {
            string path = HttpContext.Current.Server.MapPath("~/") + "players.xml";
            Player p = new Player
            {
                UserName = username,
                Password = password,
                Gender = gender,
                FirstName = firstName,
                LastName = lastName,
                NickName = nickName,
                Victories = 0,
                Kills = 0,
                Treasures = 0
            };

            List<Player> players;
            XmlSerializer serializer = new XmlSerializer(typeof(List<Player>));
            if (File.Exists(path))
            {
                using (FileStream stream = File.OpenRead(path))
                {
                    players = (List<Player>)serializer.Deserialize(stream);
                }
            }
            else
                players = new List<Player>();

            p.PlayerID = players.Count > 0 ? players.Aggregate((curMax, x) => (curMax == null || (x.PlayerID) > curMax.PlayerID ? x : curMax)).PlayerID + 1 : 1;
            players.Add(p);

            using (FileStream stream = File.OpenWrite(path))
            {
                serializer.Serialize(stream, players);
            }

            return p.PlayerID;
        }

        public static int Login(string username, string password)
        {
            string path = HttpContext.Current.Server.MapPath("~/ ") + "players.xml";
            int id = -1;
            XmlSerializer serializer = new XmlSerializer(typeof(List<Player>));
            if (File.Exists(path))
            {
                using (FileStream stream = File.OpenRead(path))
                {
                    List<Player> players = (List<Player>)serializer.Deserialize(stream);
                    Player p = players.Where(x => x.UserName.ToLower() == username.ToLower() && x.Password == password).FirstOrDefault();
                    if(p != null)
                        id = p.PlayerID;
                }
            }
            return id;
        }

        public static Player GetPlayerByUserName(string username)
        {
            string path = HttpContext.Current.Server.MapPath("~/ ") + "players.xml";
            Player p = null;
            XmlSerializer serializer = new XmlSerializer(typeof(List<Player>));
            if (File.Exists(path))
            {
                using (FileStream stream = File.OpenRead(path))
                {
                    List<Player> players = (List<Player>)serializer.Deserialize(stream);
                    p = players.Where(x => x.UserName.ToLower() == username.ToLower()).FirstOrDefault();
                }
            }
            return p;
        }

        public static Player GetPlayerByID(int id)
        {
            string path = HttpContext.Current.Server.MapPath("~/ ") + "players.xml";
            Player p = null;
            XmlSerializer serializer = new XmlSerializer(typeof(List<Player>));
            if (File.Exists(path))
            {
                using (FileStream stream = File.OpenRead(path))
                {
                    List<Player> players = (List<Player>)serializer.Deserialize(stream);
                    p = players.Where(x => x.PlayerID == id).FirstOrDefault();
                }
            }
            return p;
        }
    }

    [Serializable]
    public class RoomMembership
    {
        public int RoomID { get; set; }
        public string RoomName { get; set; }
        public string RoomKey { get; set; }
        public List<int> RoomPlayers { get; set; }

        public static List<string> CurrentPlayerRooms
        {
            get
            {
                List<string> result = new List<string>();
                if(HttpContext.Current.Session["PlayerID"] != null)
                {
                    string path = HttpContext.Current.Server.MapPath("~/") + "rooms.xml";

                    List<RoomMembership> rooms;
                    XmlSerializer serializer = new XmlSerializer(typeof(List<RoomMembership>));
                    if (File.Exists(path))
                    {
                        using (FileStream stream = File.OpenRead(path))
                        {
                            rooms = (List<RoomMembership>)serializer.Deserialize(stream);
                            result = rooms.Where(cr => cr.RoomPlayers.Contains((int)HttpContext.Current.Session["PlayerID"])).Select(cr => string.Format("{0}|{1}", cr.RoomID, cr.RoomName)).ToList();
                        }
                    }
                }
                return result;
            }
        }

        public static string AddNewRoom(string name, string key)
        {
            int id = 1;
            string path = HttpContext.Current.Server.MapPath("~/") + "rooms.xml";

            List<RoomMembership> rooms;
            XmlSerializer serializer = new XmlSerializer(typeof(List<RoomMembership>));
            if (File.Exists(path))
            {
                using (FileStream stream = File.OpenRead(path))
                {
                    rooms = (List<RoomMembership>)serializer.Deserialize(stream);
                }
            }
            else
                rooms = new List<RoomMembership>();

            if (rooms.Count() > 0)
                id = rooms.Max(cr => cr.RoomID) + 1;

            if (!rooms.Exists(cr => cr.RoomName == name))
            {
                RoomMembership r = new RoomMembership
                {
                    RoomID = id,
                    RoomName = name,
                    RoomKey = key,
                    RoomPlayers = new List<int>()
                };
                r.RoomPlayers.Add((int)HttpContext.Current.Session["PlayerID"]);
                HttpContext.Current.Session["RoomID"] = id;
                rooms.Add(r);

                using (FileStream stream = File.OpenWrite(path))
                {
                    serializer.Serialize(stream, rooms);
                }

                return "RoomCreated";
            }
            else
            {
                return "Room Name is already in use.";
            }
        }

        public static string JoinRoom(string key)
        {
            int id = 0;
            string path = HttpContext.Current.Server.MapPath("~/") + "rooms.xml";

            List<RoomMembership> rooms;
            XmlSerializer serializer = new XmlSerializer(typeof(List<RoomMembership>));
            if (File.Exists(path))
            {
                using (FileStream stream = File.OpenRead(path))
                {
                    rooms = (List<RoomMembership>)serializer.Deserialize(stream);
                }
            }
            else
                rooms = new List<RoomMembership>();

            if (rooms.Exists(cr => cr.RoomKey == key))
            {
                RoomMembership r = rooms.Where(cr => cr.RoomKey == key).FirstOrDefault();
                r.RoomPlayers.Add((int)HttpContext.Current.Session["PlayerID"]);
                HttpContext.Current.Session["RoomID"] = r.RoomID;

                using (FileStream stream = File.OpenWrite(path))
                {
                    serializer.Serialize(stream, rooms);
                }

                return "RoomJoined";
            }
            else
            {
                return "Invalid Room Key.";
            }
        }

        public static void LeaveRoom()
        {
            int id = 0;
            string path = HttpContext.Current.Server.MapPath("~/") + "rooms.xml";

            List<RoomMembership> rooms;
            XmlSerializer serializer = new XmlSerializer(typeof(List<RoomMembership>));
            if (File.Exists(path))
            {
                using (FileStream stream = File.OpenRead(path))
                {
                    rooms = (List<RoomMembership>)serializer.Deserialize(stream);
                }
            }
            else
                rooms = new List<RoomMembership>();

            if (rooms.Exists(cr => cr.RoomID == (int)HttpContext.Current.Session["RoomID"]))
            {
                RoomMembership r = rooms.Where(cr => cr.RoomID == (int)HttpContext.Current.Session["RoomID"]).FirstOrDefault();
                r.RoomPlayers.Remove((int)HttpContext.Current.Session["PlayerID"]);
                if (r.RoomPlayers.Count == 0)
                    rooms.Remove(r);
                HttpContext.Current.Session.Remove("RoomID");

                using (FileStream stream = File.OpenWrite(path))
                {
                    serializer.Serialize(stream, rooms);
                }
            }
        }
    }
}
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace MunchkinMonitor.Classes
{
    public class Logger
    {
        internal static void LogBattle(BattleResult br)
        {
            RoomState state = RoomState.CurrentState;
            GameStats.LogBattle(br);
            if(br.Victory)
                state.playerStats.LogBattleVictory(br);
        }
        internal static void LogVictory(int playerID)
        {
            RoomState state = RoomState.CurrentState;
            state.playerStats.LogVictory(playerID);
            GameStats.LogVictory(playerID);
        }
        internal static void LogError(Exception ex)
        {
            string path = HttpContext.Current.Server.MapPath("~/") + "errors.xml";
            XmlSerializer serializer = new XmlSerializer(typeof(List<Exception>));
            if (!File.Exists(path))
            {
                File.Create(path);
            }
            List<Exception> exList;
            using (FileStream stream = File.OpenRead(path))
            {
                exList = ((List<Exception>)serializer.Deserialize(stream)).ToList();
            }
            exList.Add(ex);
            using (FileStream stream = File.OpenWrite(path))
            {
                serializer.Serialize(stream, exList);
            }
        }
    }
}

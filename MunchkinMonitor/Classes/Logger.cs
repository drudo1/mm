using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
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
            SerializableException sEx = new SerializableException(ex);

            string path = HttpContext.Current.Server.MapPath("~/") + "errors.xml";
            XmlSerializer serializer = new XmlSerializer(typeof(List<SerializableException>));
            if (!File.Exists(path))
            {
                File.Create(path);
            }
            List<SerializableException> exList;
            using (FileStream stream = File.OpenRead(path))
            {
                exList = ((List<SerializableException>)serializer.Deserialize(stream)).ToList();
            }
            exList.Add(sEx);
            using (FileStream stream = File.OpenWrite(path))
            {
                serializer.Serialize(stream, exList);
            }
        }
    }

    [Serializable]
    public class SerializableException
    {
        #region Members
        private KeyValuePair<object, object>[] _Data; //This is the reason this class exists. Turning an IDictionary into a serializable object
        private string _HelpLink = string.Empty;
        private SerializableException _InnerException;
        private string _Message = string.Empty;
        private string _Source = string.Empty;
        private string _StackTrace = string.Empty;
        #endregion

        #region Constructors
        public SerializableException()
        {
        }

        public SerializableException(Exception exception) : this()
        {
            setValues(exception);
        }
        #endregion

        #region Properties
        public string HelpLink { get { return _HelpLink; } set { _HelpLink = value; } }
        public string Message { get { return _Message; } set { _Message = value; } }
        public string Source { get { return _Source; } set { _Source = value; } }
        public string StackTrace { get { return _StackTrace; } set { _StackTrace = value; } }
        public SerializableException InnerException { get { return _InnerException; } set { _InnerException = value; } } // Allow null to be returned, so serialization doesn't cascade until an out of memory exception occurs
        public KeyValuePair<object, object>[] Data { get { return _Data ?? new KeyValuePair<object, object>[0]; } set { _Data = value; } }
        #endregion

        #region Private Methods
        private void setValues(Exception exception)
        {
            if (null != exception)
            {
                _HelpLink = exception.HelpLink ?? string.Empty;
                _Message = exception.Message ?? string.Empty;
                _Source = exception.Source ?? string.Empty;
                _StackTrace = exception.StackTrace ?? string.Empty;
                setData(exception.Data);
                _InnerException = new SerializableException(exception.InnerException);
            }
        }

        private void setData(ICollection collection)
        {
            _Data = new KeyValuePair<object, object>[0];

            if (null != collection)
                collection.CopyTo(_Data, 0);
        }
        #endregion
    }
}

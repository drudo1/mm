using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

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
    }
}
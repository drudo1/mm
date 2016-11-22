using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MunchkinMonitor.Classes
{
    public class Logger
    {
        internal static void LogBattleVictory(BattleResult br)
        {
            AppState state = AppState.CurrentState();
            state.playerStats.LogBattleVictory(br.gamePlayer.currentPlayer.PlayerID, br.NumDefeated, br.treasuresWon, br.assistedBy.currentPlayer.PlayerID);
        }
        internal static void LogVictory(int playerID)
        {
            AppState state = AppState.CurrentState();
            state.playerStats.LogVictory(playerID);
        }
    }
}
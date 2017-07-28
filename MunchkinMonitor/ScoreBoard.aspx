<%@ Page Title="Hall of Fame" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ScoreBoard.aspx.cs" Inherits="MunchkinMonitor.ScoreBoard" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        var appData = null;
        data.run('LoadScoreboard');
        objPing.UpdateState = function () {
            var getUpdate = false;
            if (appData == null) {
                appData = data.run('GetCurrentAppState');
                getUpdate = false;
            }
            else {
                getUpdate = data.run('CheckForStateUpdate', { lastUpdate: new Date(appData.stateUpdatedJS) });
            }
            
            if (getUpdate) {
                objectCopy(data.run('GetCurrentAppState'), appData);
            }
            if (appData.currentStateDescription == "Game")
                window.location = "Game.aspx";
        };
    </script>
    <img src="Images/scoreboardBG.jpg" id="bg" alt="">
    <div class="scoreboard">
        <table>
            <tr>
                <th>&nbsp;</th>
                <th>Victories</th>
                <th>Kills</th>
                <th>Treasures</th>
            </tr>
            <tr rv-each-player="appData.playerStats.players">
                <td class="title">{player.DisplayName}</td>
                <td>{player.Victories}</td>
                <td>{player.Kills}</td>
                <td>{player.Treasures}</td>
            </tr>
        </table>
    </div>

</asp:Content>

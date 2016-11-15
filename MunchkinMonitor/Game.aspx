<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Game.aspx.cs" Inherits="MunchkinMonitor.Game" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
     <script type="text/javascript">
        var appData = null;
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
                if (appData.currentStateDescription == "TournamentScoreBoard")
                    window.location = "ScoreBoard.aspx";
            }
        };
        $(document).ready(function () {
            rivets.bind($(document), { appData: appData });
        })
    </script>
    <div class="jumbotron">
        <h1 rv-text="appData.currentStateDescription"></h1><br />
        <h1 rv-show="appData.gameState.isEpic">EPIC</h1>
    </div>
</asp:Content>

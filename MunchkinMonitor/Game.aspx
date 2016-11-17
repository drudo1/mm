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
            appData.gameState.players = [{ currentPlayer: { PlayerID: -1, DisplayName: 'Add a Player' }, CurrentLevel: -1 }];
            rivets.bind($(document), { appData: appData });
        })
    </script>
    <img src="Images/gameBG.jpg" id="bg" alt="">
    <div class="row">
        <div class="col-lg-4">
            <div class="gamePlayerList">
                <div class='row playerRow' rv-class-selected="player.currentPlayer.PlayerID | isCurrentPlayer" rv-each-player="appData.gameState.players">
                    <div class="col-sm-7" rv-class-col-sm-12="player.CurrentLevel | lt 1" >
                        {player.currentPlayer.DisplayName}
                    </div>
                    <div class="col-sm-5" rv-class-hide="player.CurrentLevel | lt 1" >
                        Level {player.CurrentLevel}
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-9">
            &nbsp;
        </div>
    </div>
</asp:Content>

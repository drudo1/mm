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
                pageMethods.TriggerChange();
            }
        };
        var local = {};
        var pageMethods = {
            TriggerChange: function () {
                var objUpdates = pageMethods.Updates;
                for (var key in objUpdates) {
                    if (typeof objUpdates[key] === 'function') {
                        objUpdates[key]();
                    }
                }
            },
            Updates: {
                Redirect: function () {
                    if (appData.currentStateDescription == "TournamentScoreBoard")
                        window.location = "ScoreBoard.aspx";
                },
                ChangePlayer: function () {
                    if (pageMethods.playerChanged()) {
                        pageMethods.UpdatePlayer();
                    }
                },
                ChangeGameState: function () {

                }
            },
            playerChanged: function () {
                var result = false;
                if (appData.gameState.currentPlayer.currentPlayer.PlayerID != -1) {
                    if (pageState.currentPlayerID == -1)
                        result = true;
                    else if (appData.gameState.currentPlayer.currentPlayer.PlayerID != pageState.currentPlayerID)
                        result = true;
                }
                return result;
            },
            UpdatePlayer: function () {
                var newPID = appData.gameState.currentPlayer.currentPlayer.PlayerID;
                if (pageState.currentPlayerID && $('#divPlayer_' + pageState.currentPlayerID).length) {
                    $('#divPlayer_' + pageState.currentPlayerID).hide('slide', { direction: 'left' }, 500);
                    $('#divPlayer_' + pageState.currentPlayerID).remove();
                    $('.ui - effects - placeholder').remove();
                }
                $('#divPlayer_template').clone().prependTo('#divCurrentAction').attr('id', 'divPlayer_' + newPID);
                rivets.bind($('#divPlayer_' + newPID), { appData: appData })
                $('#divPlayer_' + newPID).show('slide', { direction: 'right' }, 500);
                pageState.currentPlayerID = appData.gameState.currentPlayer.currentPlayer.PlayerID;
            }
        };
        var pageState = {};
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
        <div class="col-lg-8">
            <div id="divCurrentAction">

            </div>
        </div>
    </div>
    <div id="divPlayer_template" rv-if="appData.gameState.hasCurrentPlayer" class="battlePrep mkn" style="display:none;">
        <div class="row">
            <div class="col-lg-12 mkn">
                <h1>{appData.gameState.currentPlayer.currentPlayer.DisplayName}&nbsp;&nbsp;&nbsp;<span rv-show="appData.gameState.currentPlayer.currentPlayer.Gender | eq 0" style="font-weight:bold;">&#9794;</span><span rv-show="appData.gameState.currentPlayer.currentPlayer.Gender | eq 1" style="font-weight:bold;">&#9792;</span></h1>
            </div>
        </div>
        <div class="row">
            <div class="col-lg-6 mkn" stye="text-align:center;">
                <h2>Race: {appData.gameState.currentPlayer.currentRaces}</h2>
            </div>
            <div class="col-lg-6 mkn" style="text-align:center;">
                <h2>Class: {appData.gameState.currentPlayer.currentClasses}</h2>
            </div>
        </div>
        <div class="row">
            <div class="col-lg-6 mkn">
                <h2>Level: {appData.gameState.currentPlayer.CurrentLevel}</h2>
            </div>
            <div class="col-lg-6 mkn">
                <h2>Gear: {appData.gameState.currentPlayer.GearBonus}</h2>
            </div>
        </div>
        <div class="row">&nbsp;</div>
        <div class="row">&nbsp;</div>
        <div rv-show="appData.gameState.currentPlayer.HasHelpers" class="row">
            <div class="col-lg-12 playerRow mkn">
                <h2>Helpers</h2>
            </div>
        </div>
        <div rv-show="appData.gameState.currentPlayer.HasHelpers" class="row">
            <div class="col-lg-2 playerRow mkn" style="font-weight:bold;">
                <h3>Type</h3>
            </div>
            <div class="col-lg-3 playerRow mkn" style="font-weight:bold;">
                <h3>Name</h3>
            </div>
            <div class="col-lg-2 playerRow mkn" style="font-weight:bold;">
                <h3>Bonus</h3>
            </div>
            <div class="col-lg-2 playerRow mkn" style="font-weight:bold;">
                <h3>Gear</h3>
            </div>
            <div class="col-lg-3 playerRow mkn" style="font-weight:bold;">
                <h3>Race</h3>
            </div>
        </div>
        <div class="row playerRow" rv-show="appData.gameState.currentPlayer.HasHelpers" rv-each-helper="appData.gameState.currentPlayer.OrderedHelpers">
            <div class="col-lg-2 mkn">
                <h3>
                    <span rv-show="helper.isHireling">Hireling</span>
                    <span rv-show="helper.isSteed">Steed</span>
                </h3>
            </div>
            <div class="col-lg-2 mkn">
                <h3>{helper.Name}</h3>
            </div>
            <div class="col-lg-2 mkn">
                <h3>{helper.Bonus | test}</h3>
            </div>
            <div class="col-lg-2 mkn">
                <h3><span rv-show="helper.isHireling">{helper.GearBonus}</span><span rv-show="helper.isSteed">&nbsp;</span></h3>
            </div>
            <div class="col-lg-3 mkn">
                <h3><span rv-show="helper.isHireling">{helper.Race}</span><span rv-show="helper.isSteed">&nbsp;</span></h3>
            </div>
        </div>
        <div class="row">&nbsp;</div>    
    </div>
</asp:Content>

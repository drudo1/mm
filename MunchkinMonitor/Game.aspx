<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Game.aspx.cs" Inherits="MunchkinMonitor.Game" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
     <script type="text/javascript">
         var appData = null;
         var timeout = null;
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
        function S4() {
            return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
        }
        function newGuid() {
            guid = (S4() + S4() + "-" + S4() + "-4" + S4().substr(0, 3) + "-" + S4() + "-" + S4() + S4() + S4()).toLowerCase();
            return guid;
        }
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
                    if (appData.currentStateDescription == "GameResults")
                        window.location = "GameResults.aspx";
                    if (appData.currentStateDescription == "TournamentScoreBoard")
                        window.location = "ScoreBoard.aspx";
                },
                ChangePlayer: function () {
                    if (pageMethods.playerChanged()) {
                        pageMethods.UpdatePlayer();
                    }
                },
                ChangeGameState: function () {
                    if (pageMethods.gameStateChanged()) {
                        pageMethods.UpdateGameState();
                    }
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
                var guid = newGuid();
                $('.playerPanel').hide('slide', { direction: 'left' });
                $('.reminderPanel').hide('slide', { direction: 'left' });
                $('.playerPanel').remove();
                $('.reminderPanel').remove();
                if (appData.gameState.currentPlayer.hasTurnReminders) {
                    $(pageMethods.playerRemindersTemplate.replace('divPlayer_template', 'divPlayer_' + newPID + '_' + guid)).prependTo('#divCurrentAction');
                    rivets.bind($('#divPlayer_' + newPID + '_' + guid + '_reminders'), { appData: appData })
                    $($('#divPlayer_' + newPID + '_' + guid + '_reminders').get(0)).show('slide', { direction: 'right' });
                    $('.ui-effects-placeholder').remove();

                    if(timeout != null)
                        clearTimeout(timeout);
                    timeout =
                        setTimeout(function () {
                            $('.playerPanel').hide('slide', { direction: 'left' });
                            $('.reminderPanel').hide('slide', { direction: 'left' });
                            $('.playerPanel').remove();
                            $('.reminderPanel').remove();
                            $('.ui-effects-placeholder').remove();
                            $(pageMethods.playerPanelTemplate.replace('divPlayer_template', 'divPlayer_' + newPID + '_' + guid)).prependTo('#divCurrentAction');
                            rivets.bind($('#divPlayer_' + newPID + '_' + guid), { appData: appData })
                            $('#divPlayer_' + newPID + '_' + guid).show('slide', { direction: 'right' });
                        }, 15000);
                }
                else {
                    $(pageMethods.playerPanelTemplate.replace('divPlayer_template', 'divPlayer_' + newPID + '_' + guid)).prependTo('#divCurrentAction');
                    rivets.bind($('#divPlayer_' + newPID + '_' + guid), { appData: appData })
                    $('.ui-effects-placeholder').remove();
                    $('#divPlayer_' + newPID + '_' + guid).show('slide', { direction: 'right' });
                }
                pageState.currentPlayerID = appData.gameState.currentPlayer.currentPlayer.PlayerID;
                pageState.currentGuid = guid;
            },
            gameStateChanged: function () {
                var result = false;
                if (appData.gameState.currentState != -1) {
                    if (pageState.currentGameState == -1)
                        result = true;
                    else if (appData.gameState.currentstate != pageState.currentGameState)
                        result = true;
                }
                return result;
            },
            UpdateGameState: function() {
                if (appData.gameState.currentState == 0 || appData.gameState.currentState == 1) {
                    $('.playerPanel').slideDown();
                    $('#divBattle').slideUp();
                    $('#divBattleResults').slideUp();
                }
                else if (appData.gameState.currentState == 2) {
                    $('#divBattle').slideDown();
                    $('.playerPanel').slideUp();
                    $('#divBattleResults').slideUp();
                }
                else if (appData.gameState.currentState == 3) {
                    $('#divBattleResults').slideDown();
                    $('#divBattle').slideUp();
                    $('.playerPanel').slideUp();
                }

            },
            playerPanelTemplate: '<div id="divPlayer_template" class="battlePrep mkn playerPanel" style="display:none;">'
                             +' <div class="row">'
                             +'     <div class="col-lg-12 mkn">'
                             +'         <h1>{appData.gameState.currentPlayer.currentPlayer.DisplayName}&nbsp;&nbsp;&nbsp;<span rv-show="appData.gameState.currentPlayer.currentPlayer.Gender | eq 0" style="font-weight:bold;">&#9794;</span><span rv-show="appData.gameState.currentPlayer.currentPlayer.Gender | eq 1" style="font-weight:bold;">&#9792;</span></h1>'
                             +'     </div>'
                             +' </div>'
                             +' <div class="row">'
                             +'     <div class="col-lg-6 mkn" stye="text-align:center;">'
                             +'         <h2>Race: {appData.gameState.currentPlayer.currentRaces}</h2>'
                             +'     </div>'
                             +'     <div class="col-lg-6 mkn" style="text-align:center;">'
                             +'         <h2>Class: {appData.gameState.currentPlayer.currentClasses}</h2>'
                             +'     </div>'
                             +' </div>'
                             +' <div class="row">'
                             +'     <div class="col-lg-6 mkn">'
                             +'         <h2>Level: {appData.gameState.currentPlayer.CurrentLevel}</h2>'
                             +'     </div>'
                             +'     <div class="col-lg-6 mkn">'
                             +'         <h2>Gear: {appData.gameState.currentPlayer.GearBonus}</h2>'
                             +'     </div>'
                             +' </div>'
                             +' <div class="row">&nbsp;</div>'
                             +' <div class="row">&nbsp;</div>'
                             +' <div rv-show="appData.gameState.currentPlayer.HasHelpers" class="row">'
                             +'     <div class="col-lg-12 playerRow mkn">'
                             +'         <h2>Helpers</h2>'
                             +'     </div>'
                             +' </div>'
                             +' <div rv-show="appData.gameState.currentPlayer.HasHelpers" class="row">'
                             +'     <div class="col-lg-2 playerRow mkn" style="font-weight:bold;">'
                             +'         <h3>Type</h3>'
                             +'     </div>'
                             +'     <div class="col-lg-3 playerRow mkn" style="font-weight:bold;">'
                             +'         <h3>Name</h3>'
                             +'     </div>'
                             +'     <div class="col-lg-2 playerRow mkn" style="font-weight:bold;">'
                             +'         <h3>Bonus</h3>'
                             +'     </div>'
                             +'     <div class="col-lg-2 playerRow mkn" style="font-weight:bold;">'
                             +'         <h3>Gear</h3>'
                             +'     </div>'
                             +'     <div class="col-lg-3 playerRow mkn" style="font-weight:bold;">'
                             +'         <h3>Race</h3>'
                             +'     </div>'
                             +' </div>'
                             +' <div class="row playerRow" rv-show="appData.gameState.currentPlayer.HasHelpers" rv-each-helper="appData.gameState.currentPlayer.OrderedHelpers">'
                             +'     <div class="col-lg-2 mkn">'
                             +'         <h3>'
                             +'             <span rv-show="helper.isHireling">Hireling</span>'
                             +'             <span rv-show="helper.isSteed">Steed</span>'
                             +'         </h3>'
                             +'     </div>'
                             +'     <div class="col-lg-3 mkn">'
                             +'         <h3>{helper.Name}</h3>'
                             +'     </div>'
                             +'     <div class="col-lg-2 mkn">'
                             +'         <h3>{helper.Bonus}</h3>'
                             +'     </div>'
                             +'     <div class="col-lg-2 mkn">'
                             +'         <h3><span rv-show="helper.isHireling">{helper.GearBonus}</span><span rv-show="helper.isSteed">N/A</span></h3>'
                             +'     </div>'
                             +'     <div class="col-lg-3 mkn">'
                             +'         <h3><span rv-show="helper.isHireling">{helper.Race}</span><span rv-show="helper.isSteed">N/A</span></h3>'
                             +'     </div>'
                             +' </div>'
                             +' <div class="row">'
                             +'    <div class="col-lg-12 mkn">'
                             +'        <h1>Fighting Level</h1>'
                             + '        <div class="mknFightingLevel" style="border:2px solid #350400; padding:12px; width:150px;">{appData.gameState.currentPlayer.FightingLevel}</div>'
                             +'    </div>'
                             +' </div>'
                             +'</div>',
            playerRemindersTemplate: '<div id="divPlayer_template_reminders" class="mkn reminderPanel" style="display:none;">'
                             +'    <div class="row">'
                             +'        <div class="col-lg-12 mkn">'
                             +'            <h1>{appData.gameState.currentPlayer.currentPlayer.DisplayName}&nbsp;&nbsp;&nbsp;<span rv-show="appData.gameState.currentPlayer.currentPlayer.Gender | eq 0" style="font-weight:bold;">&#9794;</span><span rv-show="appData.gameState.currentPlayer.currentPlayer.Gender | eq 1" style="font-weight:bold;">&#9792;</span></h1>'
                             +'        </div>'
                             +'    </div>'
                             +'    <ul>'
                             + '        <li class="mknReminder" rv-each-minder="appData.gameState.currentPlayer.turnReminders" rv-text="minder">'
                             +'        </li>'
                             +'    </ul>'
                             +'</div>'
        };
        var pageState = {
            currentPlayerID: -1,
            currentGuid: '',
            currentGameState: -1
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
        <div class="col-lg-8">
            <div id="divCurrentAction">
                <div id="divBattle" class="statePanels" style="display:none;">
                    <div class="row mkn" style="text-align:center; font-size:60px;">VS</div>
                    <div class="row" style="height:8px; background-color: #350400;">&nbsp;</div>
                    <div class="row" style="min-height:500px;">
                        <div class="col-lg-6 mkn battleLeft" >
                            <div class="row">
                                <div class="col-md-12 mkn">
                                    <h1 rv-text="appData.gameState.currentBattle.gamePlayer.currentPlayer.DisplayName"></h1>
                                </div>
                                <div class="col-md-12 mkn">
                                    <h2>Fighting Level: {appData.gameState.currentBattle.gamePlayer.FightingLevel}</h2>
                                </div>
                            </div>
                            <div class="row" style="height:4px; background-color: #350400;">&nbsp;</div>
                            <div class="row" rv-show="appData.gameState.currentBattle.HasAlly">
                                <div class="col-md-12 mkn">
                                    <h1>Ally: {appData.gameState.currentBattle.ally.currentPlayer.DisplayName}</h1>
                                </div>
                                <div class="col-md-12 mkn">
                                    <h2>Fighting Level: {appData.gameState.currentBattle.ally.FightingLevel}</h2>
                                </div>
                            </div>
                            <div class="row" rv-show="appData.gameState.currentBattle.HasAlly" style="height:4px; background-color: #350400;">&nbsp;</div>
                            <div class="row">
                                <div class="col-md-12 mkn">
                                    <h1>Battle Bonus: {appData.gameState.currentBattle.playerOneTimeBonus}</h1>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12 mkn">
                                    <h1>Total: {appData.gameState.currentBattle.playerPoints}</h1>
                                </div>
                            </div>
                            <div class="row" style="position:absolute; bottom:0">
                                <div class="col-md-12" rv-show="appData.gameState.currentBattle.GoodGuysWin" style="text-align:center;">
                                    <img src="Images/playerWins.png" style="height:250px;" />
                                </div>
                                <div class="col-md-12" rv-hide="appData.gameState.currentBattle.GoodGuysWin" style="text-align:center;">
                                    <img src="Images/playerLoses.png" style="height:250px;" />
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-6 mkn battleRight">                            
                            <div class="row playerRow" rv-each-monster="appData.gameState.currentBattle.opponents">
                                <div class="col-md-6 mkn playerRow" style="padding-top:8px;">
                                    Level: {monster.Level}
                                </div>
                                <div class="col-md-6 mkn playerRow" style="padding-top:8px;">
                                    Bonus: {monster.OneTimeBonus}
                                </div>
                                <div class="col-md-6 mkn playerRow">
                                    Worth: {monster.LevelsToWin}
                                </div>
                                <div class="col-md-6 mkn playerRow">
                                    Treasure: {monster.Treasures}
                                </div>
                                <div class="col-md-12 playerRow" style="height:8px; background-color:#350400;">
                                    &nbsp;
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12 mkn">
                                    <h1>Total: {appData.gameState.currentBattle.opponentPoints}</h1>
                                </div>
                            </div>
                            <div class="row" style="position:absolute; bottom:0;">
                                <div class="col-md-12" rv-show="appData.gameState.currentBattle.GoodGuysWin" style="text-align:center;">
                                    <img src="Images/monsterLoses.png" style="height:250px;" />
                                </div>
                                <div class="col-md-12" rv-hide="appData.gameState.currentBattle.GoodGuysWin" style="text-align:center;">
                                    <img src="Images/monsterWins.png" style="height:250px;" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="divBattleResults" class="statePanels" style="display:none;">
                    <div class="row">
                        <div class="col-lg-12 mkn playerRow" style="text-align:center;">
                            <h1 rv-text="appData.gameState.currentBattle.result.Message"></h1>
                        </div>
                    </div>
                    <div class="row" >
                        <div class="col-lg-12 mkn" rv-each-result="appData.gameState.currentBattle.result.battleResults" style="text-align:center;">
                            <h2 rv-text="result"></h2>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
</asp:Content>

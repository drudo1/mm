<%@ Page Title="Score Board" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Game.aspx.cs" Inherits="MunchkinMonitor.Game" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
     <script type="text/javascript">
         var appData = { data: null };
         var timeout = null;
        objPing.UpdateState = function () {
            var getUpdate = false;
            if (appData.data == null) {
                appData.data = data.run('GetCurrentGameState');
                rivets.bind($(document), { appData: appData });
                getUpdate = false;
                pageMethods.TriggerChange();
            }
            else {
                getUpdate = data.run('CheckForStateUpdate', { lastUpdate: new Date(appData.data.stateUpdatedJS) });
            }
            
            if (getUpdate) {
                appData.data = data.run('GetCurrentGameState');
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
                    if (appData == null || appData.data.currentSBStateDescription == "TournamentScoreBoard")
                        window.location = "ScoreBoard.aspx";
                    if (appData != null && appData.data.currentSBStateDescription == "GameResults")
                        window.location = "GameResults.aspx";
                },
                ChangePlayer: function () {
                    if (pageMethods.playerChanged()) {
                        pageMethods.UpdatePlayer();
                    }
                },
                ShowCheatCard: function() {
                    if (pageMethods.showCheatCard()) {
                        pageMethods.DisplayCheatCard();
                    }
                    else {
                        pageMethods.HideCheatCard();
                    }
                },
                ChangeGender: function () {
                    if (!pageMethods.playerChanged() && appData.data.currentPlayer != null) {
                        $('.playerPanel').css('background-image', 'url(' + appData.data.currentPlayer.ImagePath + ')');
                    }
                },
                ChangeGameState: function () {
                    if (pageMethods.gameStateChanged()) {
                        pageMethods.UpdateGameState();
                    }
                }
            },
            showCheatCard: function() {
                var result = false;
                if (appData.data.currentPlayer != null) {
                    if (appData.data.currentPlayer.showCheatCard == 'true')
                        result = true;
                }
                return result;
            },
            playerChanged: function () {
                var result = false;
                if (appData.data.currentPlayer != null) {
                    if (appData.data.currentPlayer.currentPlayer.PlayerID != -1) {
                        if (pageState.currentPlayerID == -1)
                            result = true;
                        else if (appData.data.currentPlayer.currentPlayer.PlayerID != pageState.currentPlayerID)
                            result = true;
                    }
                }
                return result;
            },
            DisplayCheatCard: function() {
                
                if (appData.data.currentPlayer != null) {
                    if (appData.data.currentPlayer.hasTurnReminders) {
                        var newPID = appData.data.currentPlayer.currentPlayer.PlayerID;
                        $(pageMethods.playerRemindersTemplate.replace('divPlayer_template', 'divPlayer_' + newPID + '_' + this.guid)).prependTo('#divCurrentAction');
                        rivets.bind($('#divPlayer_' + newPID + '_' + this.guid + '_reminders'), { appData: appData })
                        $('.playerPanel').hide('slide', { direction: 'left' });
                        $($('#divPlayer_' + newPID + '_' + this.guid + '_reminders').get(0)).show('slide', { direction: 'right' });
                        $('.ui-effects-placeholder').remove();
                    }
                }
            },
            HideCheatCard: function () {
                if ($('.reminderPanel').is(':visible')) {
                    var newPID = appData.data.currentPlayer.currentPlayer.PlayerID;
                    $('.playerPanel').hide('slide', { direction: 'left' });
                    $('.reminderPanel').hide('slide', { direction: 'left' });
                    $('.playerPanel').remove();
                    $('.reminderPanel').remove();
                    $('.ui-effects-placeholder').remove();
                    $(pageMethods.playerPanelTemplate.replace('divPlayer_template', 'divPlayer_' + newPID + '_' + this.guid)).prependTo('#divCurrentAction');
                    rivets.bind($('#divPlayer_' + newPID + '_' + this.guid), { appData: appData })
                    $('#divPlayer_' + newPID + '_' + this.guid).css({ 'background-image': 'url(' + appData.data.currentPlayer.ImagePath + ')', 'background-position': 'left bottom', 'background-repeat': 'no-repeat' });
                    $('#divPlayer_' + newPID + '_' + this.guid).show('slide', { direction: 'right' });
                }
            },
            UpdatePlayer: function () {
                
                if (appData.data.currentPlayer != null) {
                    var newPID = appData.data.currentPlayer.currentPlayer.PlayerID;
                    this.guid = newGuid();
                    $('.playerPanel').hide('slide', { direction: 'left' });
                    $('.reminderPanel').hide('slide', { direction: 'left' });
                    $('.playerPanel').remove();
                    $('.reminderPanel').remove();
                    $(pageMethods.playerPanelTemplate.replace('divPlayer_template', 'divPlayer_' + newPID + '_' + this.guid)).prependTo('#divCurrentAction');
                    rivets.bind($('#divPlayer_' + newPID + '_' + this.guid), { appData: appData })
                    $('.ui-effects-placeholder').remove();
                    $('#divPlayer_' + newPID + '_' + this.guid).css({ 'background-image': 'url(' + appData.data.currentPlayer.ImagePath + ')', 'background-position': 'left bottom', 'background-repeat': 'no-repeat' });
                    $('#divPlayer_' + newPID + '_' + this.guid).show('slide', { direction: 'right' });
                    pageState.currentPlayerID = appData.data.currentPlayer.currentPlayer.PlayerID;
                    pageState.currentGuid = this.guid;
                }
            },
            gameStateChanged: function () {
                var result = false;
                if (appData.data.currentState != -1) {
                    if (pageState.currentGameState == -1)
                        result = true;
                    else if (appData.data.currentstate != pageState.currentGameState)
                        result = true;
                }
                return result;
            },
            UpdateGameState: function() {
                if (appData.data.currentState == 0 || appData.data.currentState == 1) {
                    $('.playerPanel').slideDown();
                    $('#divBattle').slideUp();
                    $('#divBattleResults').slideUp();
                }
                else if (appData.data.currentState == 2) {
                    $('#divBattle').slideDown();
                    $('.playerPanel').slideUp();
                    $('#divBattleResults').slideUp();
                }
                else if (appData.data.currentState == 3) {
                    $('#divBattleResults').slideDown();
                    $('#divBattle').slideUp();
                    $('.playerPanel').slideUp();
                }

            },
            playerPanelTemplate: '<div id="divPlayer_template" class="battlePrep mkn playerPanel" style="display:none; min-height:700px;">'
                             +' <div class="row">'
                             +'     <div class="col-lg-12 mkn">'
                             + '         <h1>{appData.data.currentPlayer.currentPlayer.DisplayName}&nbsp;&nbsp;&nbsp;<span rv-show="appData.data.currentPlayer.CurrentGender | eq 0" style="font-weight:bold;">&#9794;</span><span rv-show="appData.data.currentPlayer.currentGender | eq 1" style="font-weight:bold;">&#9792;</span>&nbsp;&nbsp;&nbsp;<span rv-show="appData.data.currentPlayer.Bank | neq 0" style="font-weight:bold;">${appData.data.currentPlayer.Bank}</span></h1>'
                             +'     </div>'
                             +' </div>'
                             +' <div class="row">'
                             +'     <div class="col-lg-6 mkn" stye="text-align:center;">'
                             +'         <h2>Race: {appData.data.currentPlayer.currentRaces}</h2>'
                             +'     </div>'
                             +'     <div class="col-lg-6 mkn" style="text-align:center;">'
                             +'         <h2>Class: {appData.data.currentPlayer.currentClasses}</h2>'
                             +'     </div>'
                             +' </div>'
                             +' <div class="row">'
                             +'     <div class="col-lg-6 mkn">'
                             +'         <h2>Level: {appData.data.currentPlayer.CurrentLevel}</h2>'
                             +'     </div>'
                             +'     <div class="col-lg-6 mkn">'
                             +'         <h2>Gear: {appData.data.currentPlayer.GearBonus}</h2>'
                             +'     </div>'
                             +' </div>'
                             +' <div class="row">&nbsp;</div>'
                             +' <div class="row">&nbsp;</div>'
                             +' <div rv-show="appData.data.currentPlayer.HasHelpers" class="row">'
                             +'     <div class="col-lg-12 playerRow mkn">'
                             +'         <h2>Helpers</h2>'
                             +'     </div>'
                             +' </div>'
                             +' <div rv-show="appData.data.currentPlayer.HasHelpers" class="row">'
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
                             +' <div class="row playerRow" rv-show="appData.data.currentPlayer.HasHelpers" rv-each-helper="appData.data.currentPlayer.OrderedHelpers">'
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
                             + '        <div class="mknFightingLevel" style="border:2px solid #350400; padding:12px; width:150px;">{appData.data.currentPlayer.FightingLevel}</div>'
                             +'    </div>'
                             +' </div>'
                             +'</div>',
            playerRemindersTemplate: '<div id="divPlayer_template_reminders" class="mkn reminderPanel" style="display:none;">'
                             +'    <div class="row">'
                             +'        <div class="col-lg-12 mkn">'
                             +'            <h1>{appData.data.currentPlayer.currentPlayer.DisplayName}&nbsp;&nbsp;&nbsp;<span rv-show="appData.data.currentPlayer.CurrentGender | eq 0" style="font-weight:bold;">&#9794;</span><span rv-show="appData.data.currentPlayer.currentGender | eq 1" style="font-weight:bold;">&#9792;</span></h1>'
                             +'        </div>'
                             +'    </div>'
                             +'    <ul>'
                             + '        <li class="mknReminder" rv-each-minder="appData.data.currentPlayer.turnReminders" rv-text="minder">'
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
            rivets.bind($(document), { appData: appData });
        })
    </script>
    <img src="Images/gameBG.jpg" id="bg" alt="">
    <div class="row">
        <div class="col-lg-4">
            <div class="gamePlayerList">
                <div class="row playerRow" style="padding-top:50px;">
                    <div class="col-sm-offset-6 col-sm-2">
                        L
                    </div>
                    <div class="col-sm-2">
                        FL
                    </div>
                    <div class="col-sm-2">
                        AL
                    </div>
                </div>
                <div class='row playerRow' rv-class-selected="player.currentPlayer.PlayerID | isCurrentPlayer" rv-each-player="appData.data.playersOrdered">
                    <div class='col-sm-6' >
                        &nbsp;&nbsp;{player.currentPlayer.DisplayName}
                    </div>
                    <div class="col-sm-2" style="text-align:center" >
                        {player.CurrentLevel}
                    </div>
                    <div class="col-sm-2" style="text-align:center" >
                        {player.FightingLevel}
                    </div>
                    <div class="col-sm-2" style="text-align:center" >
                        {player.AllyLevel}
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
                                    <h1 rv-text="appData.data.currentBattle.gamePlayer.currentPlayer.DisplayName"></h1>
                                </div>
                                <div class="col-md-12 mkn">
                                    <h2>Fighting Level: {appData.data.currentBattle.gamePlayer.FightingLevel}</h2>
                                </div>
                            </div>
                            <div class="row" style="height:4px; background-color: #350400;">&nbsp;</div>
                            <div class="row" rv-show="appData.data.currentBattle.HasAlly">
                                <div class="col-md-12 mkn">
                                    <h1>Ally: {appData.data.currentBattle.ally.currentPlayer.DisplayName}</h1>
                                </div>
                                <div class="col-md-12 mkn">
                                    <h2>Fighting Level: {appData.data.currentBattle.ally.FightingLevel}</h2>
                                </div>
                            </div>
                            <div class="row" rv-show="appData.data.currentBattle.HasAlly" style="height:4px; background-color: #350400;">&nbsp;</div>
                            <div class="row">
                                <div class="col-md-12 mkn">
                                    <h1>Battle Bonus: {appData.data.currentBattle.playerOneTimeBonus}</h1>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12 mkn">
                                    <h1>Total: {appData.data.currentBattle.playerPoints}</h1>
                                </div>
                            </div>
                            <div class="row" style="position:absolute; bottom:0">
                                <div class="col-md-12" rv-show="appData.data.currentBattle.GoodGuysWin" style="text-align:center;">
                                    <img src="Images/playerWins.png" style="height:250px;" />
                                </div>
                                <div class="col-md-12" rv-hide="appData.data.currentBattle.GoodGuysWin" style="text-align:center;">
                                    <img src="Images/playerLoses.png" style="height:250px;" />
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-6 mkn battleRight">                            
                            <div class="row playerRow" rv-each-monster="appData.data.currentBattle.opponents">
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
                                    <h1>Total: {appData.data.currentBattle.opponentPoints}</h1>
                                </div>
                            </div>
                            <div class="row" style="position:absolute; bottom:0;">
                                <div class="col-md-12" rv-show="appData.data.currentBattle.GoodGuysWin" style="text-align:center;">
                                    <img src="Images/monsterLoses.png" style="height:250px;" />
                                </div>
                                <div class="col-md-12" rv-hide="appData.data.currentBattle.GoodGuysWin" style="text-align:center;">
                                    <img src="Images/monsterWins.png" style="height:250px;" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="divBattleResults" class="statePanels" style="display:none;">
                    <div class="row">
                        <div class="col-lg-12 mkn playerRow" style="text-align:center;">
                            <h1 rv-text="appData.data.currentBattle.result.Message"></h1>
                        </div>
                    </div>
                    <div class="row" >
                        <div class="col-lg-12 mkn" rv-each-result="appData.data.currentBattle.result.battleResults" style="text-align:center;">
                            <h2 rv-text="result"></h2>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
</asp:Content>

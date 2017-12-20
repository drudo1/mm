<%@ Page Title="Munchkin Controller" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Controller.aspx.cs" Inherits="MunchkinMonitor.Controller" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        var appData = null;
        var helperData = null;
        var monsterData = null;
        var idx = -1;
        var mIdx = -1;
        objPing.UpdateState = function () {
            var getUpdate = false;
            if (appData == null) {
                appData = data.run('GetControllerState');
                getUpdate = false;
            }
            else {
                getUpdate = data.run('CheckForStateUpdate', { lastUpdate: new Date(appData.stateUpdatedJS) });
            }

            if (getUpdate) {
                objectCopy(data.run('GetControllerState'), appData);
            }
        };
        $(document).ready(function () {
            $('#btnNewGame').click(function () {
                appData.gameState = { currentState: 0, isEpic: false };
                appData.currentState = 1;
                data.run('NewGame', { isEpic: 'false' });
            });
            $('#btnNewEpic').click(function () {
                appData.gameState = { currentState: 0, isEpic: true };
                appData.currentState = 1;
                data.run('NewGame', { isEpic: 'true' });
            });
            $('#btnCancelGame').click(function () {
                appData.currentState = 0;
                data.run('CancelGame');
            });
            $('#btnAddPlayer').click(function () {
                if ($('#ddlPlayers').val() != -1) {
                    data.run('AddExistingPlayer', { id: $('#ddlPlayers').val() });
                    $('#ddlPlayers').val('-1');
                    objectCopy(data.run('GetCurrentRoomState'), appData);
                }
                else {
                    $('#divAddExistingPlayer').slideUp();
                    $('#divAddNewPlayer').slideDown();
                }
            });
            $('#btnCancelNewPlayer').click(function () {
                $('#divAddExistingPlayer').slideDown();
                $('#divAddNewPlayer').slideUp();
            });
            $('#btnSaveNewPlayer').click(function () {
                data.run('AddNewPlayer', { username: $('#txtUserName').val(), firstName: $('#txtFirstName').val(), lastName: $('#txtLastName').val(), nickName: $('#txtNickName').val(), gender: $('#ddlGender').val() });
                data.run('LoadPlayers');
                objectCopy(data.run('GetCurrentRoomState'), appData);
                $('#txtFirstName').val('');
                $('#txtLastName').val('');
                $('#txtNickName').val('');
                $('#ddlGender').val('0');
                $('#divAddExistingPlayer').slideDown();
                $('#divAddNewPlayer').slideUp();
            });
            $('#btnStartGame').click(function () {
                data.run('StartGame');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnSubtractLevel, #btnSubtractLevel2').click(function () {
                data.run('SubtractLevel');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnAddLevel, #btnAddLevel2').click(function () {
                data.run('AddLevel');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('.gearUpdate').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateGear', { amount: amount });
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnRace').click(function () {
                $('#divPlayerSettings').slideUp();
                $('#divRace').slideDown();
            });
            $('#btnChgRace').click(function () {
                data.run('NextRace');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnHalfBreed').click(function () {
                data.run('ToggleHalfBreed');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnChgHBRace').click(function () {
                data.run('NextHalfBreed');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnClass').click(function () {
                $('#divPlayerSettings').slideUp();
                $('#divClass').slideDown();
            });
            $('#btnChgClass').click(function () {
                data.run('NextClass');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnSuperMkn').click(function () {
                data.run('ToggleSuperMunchkin');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnChgSMClass').click(function () {
                data.run('NextSMClass');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnGender').click(function () {
                $('#divPlayerSettings').slideUp();
                $('#divGender').slideDown();
            });
            $('#btnChgGender').click(function () {
                data.run('ChangeGender', { penalty: $('#txtGenderPenalty').val() });
                objectCopy(data.run('GetCurrentRoomState'), appData);
                $('#divPlayerSettings').slideDown();
                $('#divGender').slideUp();
            });
            $('#btnDie').click(function () {
                data.run('KillCurrentPlayer');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            })
            $('#btnHirelings').click(function () {
                $('#divPlayerSettings').slideUp();
                $('#divHirelings').slideDown();
            });
            $('#btnSteeds').click(function () {
                $('#divPlayerSettings').slideUp();
                $('#divSteeds').slideDown();
            });
            $('.btnAddHelper').click(function () {
                $('#hdnHelperType').val($(this).attr('helperType'));
                $('#txtHelperBonus').val('');
                $('#divHirelings').slideUp();
                $('#divSteeds').slideUp();
                $('#divAddHelper').slideDown();
            });
            $('#btnSaveHelper').click(function () {
                var steed = ($('#hdnHelperType').val() == 'steed');
                data.run('AddHelper', { steed: steed, bonus: $('#txtHelperBonus').val() });
                objectCopy(data.run('GetCurrentRoomState'), appData);
                if ($('#hdnHelperType').val() == 'hireling')
                    $('#divHirelings').slideDown();
                else
                    $('#divSteeds').slideDown();
                $('#divAddHelper').slideUp();
            });
            $('.helperHome').click(function () {
                if ($('#hdnHelperType').val() == 'hireling')
                    $('#divHirelings').slideDown();
                else
                    $('#divSteeds').slideDown();
                $('#divAddHelper').slideUp();
                $('#divEditHelper').slideUp();
            });
            $(document).on('click', '.hirelingButton,.steedButton', function () {
                idx = $(this).attr('hireIDX');
                if ($(this).hasClass('hirelingButton')) {
                    $('#hdnHelperType').val('hireling');
                    helperData = appData.gameState.currentPlayer.Hirelings[idx];
                    rivets.bind($('#divEditHelper'), { helper: helperData });
                }
                else {
                    $('#hdnHelperType').val('steed');
                    helperData = appData.gameState.currentPlayer.Steeds[idx];
                    rivets.bind($('#divEditHelper'), { helper: helperData });
                }
                $('#divHirelings').slideUp();
                $('#divSteeds').slideUp();
                $('#divEditHelper').slideDown();
            });
            $('.hlpGearUpdate').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateHelperGear', { helperID: $('#hdnHelperID').val(), amount: amount });
                objectCopy(data.run('GetCurrentRoomState'), appData);
                objectCopy(appData.gameState.currentPlayer.Hirelings[idx], helperData);
            });
            $('#btnChangeHelperRace').click(function () {
                data.run('ChangeHelperRace', { helperID: $('#hdnHelperID').val() });
                objectCopy(data.run('GetCurrentRoomState'), appData);
                objectCopy(appData.gameState.currentPlayer.Hirelings[idx], helperData);
            });
            $('#btnKillHelper').click(function () {
                data.run('KillHelper', { helperID: $('#hdnHelperID').val() });
                objectCopy(data.run('GetCurrentRoomState'), appData);

                if ($('#hdnHelperType').val() == 'hireling')
                    $('#divHirelings').slideDown();
                else
                    $('#divSteeds').slideDown();
                $('#divAddHelper').slideUp();
                $('#divEditHelper').slideUp();
            });
            $('#btnPrevPlayer').click(function () {
                data.run('PrevPlayer');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnNextPlayer').click(function () {
                data.run('NextPlayer');
                objectCopy(data.run('GetCurrentRoomState'), appData);
                $('#btnShowReminders').text('Help');
            });
            $('.playerSetupHome').click(function () {
                $('#divPlayerSettings').slideDown();
                $('#divRace').slideUp();
                $('#divClass').slideUp();
                $('#divGender').slideUp();
                $('#divHirelings').slideUp();
                $('#divSteeds').slideUp();
            });
            $('#btnBattle').click(function () {
                data.run('StartBattle', { level: 1, levelsToWin: 1, treasures: 1 });
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('.BattleBonus').click(function () {
                var amount = $(this).attr('amount');
                data.run('BattleBonus', { amount: amount });
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnAddAlly').click(function () {
                data.run('AddAlly', { allyID: $('#ddlAvailableAllys').val(), allyTreasures: $('#ddlAllyTreasures').val() });
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnRemoveAlly').click(function () {
                data.run('RemoveAlly');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $(document).on('click', '.monsterButton', function () {
                mIdx = $(this).attr('monsterIDX');
                monsterData = appData.gameState.currentBattle.opponents[mIdx];
                rivets.bind($('#divMonsterEdit'), { curMonster: monsterData });
                $('#divBattle').slideUp();
                $('#divMonsterEdit').slideDown();
            });
            $('.monsterLevel').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateMonsterLevel', { monsterIDX: mIdx, amount: amount });
                objectCopy(data.run('GetCurrentRoomState'), appData);
                objectCopy(appData.gameState.currentBattle.opponents[mIdx], monsterData);
            });
            $('.monsterBonus').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateMonsterBonus', { monsterIDX: mIdx, amount: amount });
                objectCopy(data.run('GetCurrentRoomState'), appData);
                objectCopy(appData.gameState.currentBattle.opponents[mIdx], monsterData);
            });
            $('.updMonsterLTW').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateMonsterLTW', { monsterIDX: mIdx, amount: amount });
                objectCopy(data.run('GetCurrentRoomState'), appData);
                objectCopy(appData.gameState.currentBattle.opponents[mIdx], monsterData);
            });
            $('.updMonsterTreasure').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateMonsterTreasures', { monsterIDX: mIdx, amount: amount });
                objectCopy(data.run('GetCurrentRoomState'), appData);
                objectCopy(appData.gameState.currentBattle.opponents[mIdx], monsterData);
            });
            $('#btnRemoveMonster').click(function () {
                data.run('RemoveMonster', { monsterIDX: mIdx });
                objectCopy(data.run('GetCurrentRoomState'), appData);
                mIdx = -1;
                monsterData = null;
                $('#divBattle').slideDown();
                $('#divMonsterEdit').slideUp();
            });
            $('#btnCloseMonster').click(function () {
                mIdx = -1;
                monsterData = null;
                $('#divBattle').slideDown();
                $('#divMonsterEdit').slideUp();
            });
            $('#btnAddMonster').click(function () {
                mIdx = data.run('AddMonster', { level: 1, levelsToWin: 1, treasures: 1 });
                objectCopy(data.run('GetCurrentRoomState'), appData);
                monsterData = appData.gameState.currentBattle.opponents[mIdx];
                rivets.bind($('#divMonsterEdit'), { curMonster: monsterData });
                $('#divBattle').slideUp();
                $('#divMonsterEdit').slideDown();
            });
            $('#btnCancelBattle').click(function () {
                mIdx = data.run('CancelBattle');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnResolveBattle').click(function () {
                mIdx = data.run('ResolveBattle');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnCompleteBattle').click(function () {
                mIdx = data.run('CompleteBattle');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnEndGame').click(function () {
                data.run('EndGame');
                objectCopy(data.run('GetCurrentRoomState'), appData);
            });
            $('#btnOpenSellPanel').click(function () {
                $('#divPlayerSettings').slideUp();
                $('#divSellItem').slideDown();
            });
            $('#btnCancelSell').click(function () {
                $('#divPlayerSettings').slideDown();
                $('#divSellItem').slideUp();
                $('#txtSaleAmount').val('');
            });
            $('#btnSellItem').click(function () {
                data.run('SellItem', { amount: $('#txtSaleAmount').val() });
                $('#divPlayerSettings').slideDown();
                $('#divSellItem').slideUp();
                $('#txtSaleAmount').val('');
            });
            $('#btnShowReminders').click(function () {
                if ($('#btnShowReminders').val() == 'Help')
                    $('#btnShowReminders').val('Hide');
                else
                    $('#btnShowReminders').val('Help');
                data.run('ToggleCheatCard');
            });
        });
    </script>
                <img src="Images/controllerBG.jpg" id="bg" alt="">
    <table style="width:100%">
        <tr>
            <td>
                
            </td>
            <td style="text-align:right">
                <input rv-show="appData.gameState.currentState | eq 1" type="button" id="btnShowReminders" class="btn mkn btn-xs" value="Help" />
                <input rv-show="appData.gameState.currentState | eq 1" type="button" id="btnOpenSellPanel" class="btn mkn btn-xs" value="Sell Item" />
            </td>
        </tr>
    </table>
    <div id="bound">
    <div id="divChooseGame" class="mobile mkn2 mkn" >
        <div class="row">
            <div class="col-xs-12 mkn">
                <h3>Select a Room</h3>
            </div>
        </div>
    </div>
    <div rv-show="appData.currentState | eq 1">
        <div id="divSetup" class="mobile mkn2 mkn" rv-show="appData.gameState.currentState | eq 0">
            <div id="divAddExistingPlayer">
                <select id="ddlPlayers" class="form-control">
                    <option value="-1">New Player</option>
                    <option rv-each-player="appData.AvailablePlayers" rv-value="player.PlayerID" rv-class-hide="player.PlayerID | eq -1">{player.DisplayName}</option>
                </select>
                <input id="btnAddPlayer" type="button" class="btn mkn" value="Add Player" /><br />
                <div class="row">
                    <div class="col-xs-6" style="text-align:center">
                        <input id="btnCancelGame" type="button" class="btn mkn" value="Cancel" style="font-size:30px;" />
                    </div>
                    <div class="col-xs-6" style="text-align:center">
                        <input id="btnStartGame" type="button" class="btn mkn" value="GO!" style="font-size:30px;" />
                    </div>
                </div>
            </div>
            <div id="divAddNewPlayer" style="display:none;">
                <div class="row">
                    <div class="col-xs-3">
                        <label for="txtUserName">User Name</label>
                    </div>
                    <div class="col-xs-9">
                        <input id="txtUserName" class="form-control" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-3">
                        <label for="txtFirstName">First</label>
                    </div>
                    <div class="col-xs-9">
                        <input id="txtFirstName" class="form-control" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-3">
                        <label for="txtLastName">Last</label>
                    </div>
                    <div class="col-xs-9">
                        <input id="txtLastName" class="form-control" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-3">
                        <label for="txtNickName">Nick</label>
                    </div>
                    <div class="col-xs-9">
                        <input id="txtNickName" class="form-control" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-3">
                        <label for="ddlGender">Gender</label>
                    </div>
                    <div class="col-xs-9">
                        <select id="ddlGender" class="form-control">
                            <option value="0">Male</option>
                            <option value="1">Female</option>
                        </select>
                    </div>
                </div>
                <input id="btnSaveNewPlayer" type="button" class="btn mkn btn-xs" value="Add New Player" />
                <input id="btnCancelNewPlayer" type="button" class="btn mkn btn-xs" value="Cancel New Player" />
            </div>
        </div>
        <div id="divNotBattle" class="mobile mkn2 mkn" rv-show="appData.gameState.currentState | eq 1">
            <div id="divPlayer">
                <div class="row">
                    <div class="col-xs-12">
                        <h1>{appData.gameState.currentPlayer.currentPlayer.DisplayName}</h1>
                    </div>
                </div>
                <div class="row" id="divPlayerSettings">
                    <div class="col-xs-12">
                        <div class="row">
                            <div class="col-xs-4">
                                <input type="button" id="btnRace" class="btn mkn btn-xs" value="Race" />
                            </div>
                            <div class="col-xs-4">
                                <input type="button" id="btnGender" class="btn mkn btn-xs" value="Gender" />
                            </div>
                            <div class="col-xs-4">
                                <input type="button" id="btnClass" class="btn mkn btn-xs" value="Class" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-xs-4" style="vertical-align:middle;">
                                <input type="button" id="btnSubtractLevel" class="btn mkn btn-xs" value="<" />
                            </div>
                            <div class="col-xs-4 mkn" style="vertical-align:middle;">
                                <h1>{appData.gameState.currentPlayer.CurrentLevel}</h1><span style="font-size:20px;">Level</span>
                            </div>
                            <div class="col-xs-4" style="vertical-align:middle;">
                                <input type="button" id="btnAddLevel" class="btn mkn btn-xs" value=">" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-xs-4 mkn">
                                <table>
                                    <tr><td colspan="3" style="text-align:center"><h2 style="padding:0;">-</h2></td></tr>
                                    <tr>
                                        <td style="text-align:center"><input type="button" class="btn btn-xs mkn gearUpdate" value="5" amount="-5" /></td>
                                        <td style="text-align:center"><input type="button" class="btn btn-xs mkn gearUpdate" value="2" amount="-2" /></td>
                                        <td style="text-align:center"><input type="button" class="btn btn-xs mkn gearUpdate" value="1" amount="-1" /></td>
                                    </tr>
                                </table>
                            </div>
                            <div class="col-xs-4 mkn">
                                <h1>{appData.gameState.currentPlayer.GearBonus}</h1><span style="font-size:20px;">Gear</span>
                            </div>
                            <div class="col-xs-4 mkn">
                                <table>
                                    <tr><td colspan="3" style="text-align:center"><h2 style="padding:0;">+</h2></td></tr>
                                    <tr>
                                        <td style="text-align:center"><input type="button" class="btn btn-xs mkn gearUpdate" value="1" amount="1" /></td>
                                        <td style="text-align:center"><input type="button" class="btn btn-xs mkn gearUpdate" value="2" amount="2" /></td>
                                        <td style="text-align:center"><input type="button" class="btn btn-xs mkn gearUpdate" value="5" amount="5" /></td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-xs-4">
                                <input type="button" id="btnPrevPlayer" class="btn mkn btn-xs" value="< Player" />
                            </div>
                            <div class="col-xs-4">
                                <input type="button" id="btnBattle" class="btn mkn btn-xs" value="Battle" />
                            </div>
                            <div class="col-xs-4">
                                <input type="button" id="btnNextPlayer" class="btn mkn btn-xs" value="Player >" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-xs-4">
                                <input type="button" id="btnHirelings" class="btn mkn btn-xs" value="Hirelings" />
                            </div>
                            <div class="col-xs-4">
                                <input type="button" id="btnDie" class="btn mkn btn-xs" value="Die" />
                            </div>
                            <div class="col-xs-4">
                                <input type="button" id="btnSteeds" class="btn mkn btn-xs" value="Steeds" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-xs-12">
                                <input type="button" id="btnEndGame" class="btn mkn btn-xs" value="End Game" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row" id="divRace" style="display:none;">
                    <div class="col-xs-12">
                        <input type="button" id="btnChgRace" class="btn mkn" rv-value="appData.gameState.currentPlayer.CurrentRaceList.0.Description | test" value="Race" />
                    </div>
                    <div class="col-xs-12">
                        <input type="button" id="btnHalfBreed" class="btn mkn" rv-value="appData.gameState.currentPlayer.HalfBreed | ite 'Half-Breed' 'Single Race'" />
                    </div>
                    <div class="col-xs-12" rv-show="appData.gameState.currentPlayer.HalfBreed">
                        <input type="button" id="btnChgHBRace" class="btn mkn" rv-value="appData.gameState.currentPlayer.CurrentRaceList.1.Description" value="Other Race" />
                    </div>
                    <div class="col-xs-12" >
                        <input type="button" class="btn mkn playerSetupHome" value="Go Back" />
                    </div>
                </div>
                <div class="row" id="divClass" style="display:none;">
                    <div class="col-xs-12">
                        <input type="button" id="btnChgClass" class="btn mkn" rv-value="appData.gameState.currentPlayer.CurrentClassList.0.Description" ="Class" />
                    </div>
                    <div class="col-xs-12">
                        <input type="button" id="btnSuperMkn" class="btn mkn" rv-value="appData.gameState.currentPlayer.SuperMunchkin | ite 'Super Munchkin' 'Single Class'" />
                    </div>
                    <div class="col-xs-12" rv-show="appData.gameState.currentPlayer.SuperMunchkin">
                        <input type="button" id="btnChgSMClass" class="btn mkn" rv-value="appData.gameState.currentPlayer.CurrentClassList.1.Description" value="Other Class" />
                    </div>
                    <div class="col-xs-12" >
                        <input type="button" class="btn mkn playerSetupHome" value="Go Back" />
                    </div>
                </div>
                <div class="row" id="divGender" style="display:none;">
                    <div class="row">
                    <div class="col-xs-6 mkn">
                        <h4>Penalty:</h4>
                        <input type="text" id="txtGenderPenalty" class="form-control" value="0" />
                    </div>
                    <div class="col-xs-6">
                        <input type="button" id="btnChgGender" class="btn mkn" value="Change" />
                    </div>
                    </div>
                    <div class="row">
                    <div class="col-xs-12" >
                        <input type="button" class="btn mkn playerSetupHome" value="Go Back" />
                    </div>
                    </div>
                </div>
                <div class="row" id="divHirelings" style="display:none;">
                    <div class="col-xs-12 mkn">
                        <h2>Hirelings</h2>
                    </div>
                    <div class="row">
                        <div class="col-xs-3">
                            &nbsp;
                        </div>
                        <div class="col-xs-2">
                            &nbsp;
                        </div>
                        <div class="col-xs-2">
                            <h3>Gear</h3>
                        </div>
                        <div class="col-xs-5">
                            <h3>Race</h3>
                        </div>
                    </div>
                    <div class="row" rv-show="appData.gameState.currentPlayer.HasHirelings | neq true">
                        <div class="col-xs-6">
                            <h3>No Hirelings</h3>
                        </div>
                    </div>
                    <div class="row playerRow" rv-each-hireling="appData.gameState.currentPlayer.Hirelings">
                        <div class="col-xs-3 mkn">
                            <input type="button" class="btn btn-xs mkn hirelingButton" rv-hireIDX=" %hireling% " rv-value="hireling.Name" />
                        </div>
                        <div class="col-xs-2 mkn">
                            <h3>+{hireling.Bonus}</h3>
                        </div>
                        <div class="col-xs-2 mkn">
                            <h3>{hireling.GearBonus}</h3>
                        </div>
                        <div class="col-xs-5 mkn">
                            <h3>{hireling.RaceClass}</h3>
                        </div>
                    </div>
                    <div class="col-xs-6">
                        <input type="button" class="btn mkn btnAddHelper" helperType="hireling" value="Add Hireling" />
                    </div>
                    <div class="col-xs-6">
                        <input type="button" class="btn mkn playerSetupHome" value="Go Back" />
                    </div>
                </div>
                <div class="row" id="divSteeds" style="display:none;">                    
                    <div class="col-xs-12 mkn">
                        <h2>Steeds</h2>
                    </div>
                    <div class="row">&nbsp;
                    </div>
                    <div class="row" rv-show="appData.gameState.currentPlayer.HasSteeds | neq true">
                        <div class="col-xs-6">
                            <h3>No Steeds</h3>
                        </div>
                    </div>
                    <div class="row" rv-each-steed="appData.gameState.currentPlayer.Steeds">
                        <div class="col-xs-3">
                            &nbsp;
                        </div>
                        <div class="col-xs-3 mkn">
                            <input type="button" class="btn btn-xs mkn steedButton" rv-hireIDX=" %steed% " rv-value="steed.Name" />
                        </div>
                        <div class="col-xs-3 mkn">
                            <h3>+{steed.Bonus}</h3>
                        </div>
                    </div>
                    <div class="col-xs-6">
                        <input type="button" class="btn mkn btnAddHelper" helperType="steed" value="Add Steed" />
                    </div>
                    <div class="col-xs-6">
                        <input type="button" class="btn mkn playerSetupHome" value="Go Back" />
                    </div>
                </div>
                <div class="row" id="divAddHelper" style="display:none;">
                    <input type="hidden" id="hdnHelperType" />
                    <div class="row">
                        <div class="col-xs-6 mkn" style="vertical-align:bottom;">
                            <h3>Bonus:</h3>
                        </div>
                        <div class="col-xs-6 mkn" style="vertical-align:bottom;">
                            <input type="number" class="form-control" id="txtHelperBonus" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-xs-6 mkn">
                            <input type="button" class ="btn mkn helperHome" value="Go Back" />
                        </div>
                        <div class="col-xs-6 mkn">
                            <input type="button" class ="btn mkn" id="btnSaveHelper" value="Go" />
                        </div>
                    </div>
                </div>
                <div class="row" id="divEditHelper" style="display:none;">
                    <input type="hidden" id="hdnHelperID" rv-value="helper.ID" />
                    <div class="row">
                        <div class="col-xs-12 mkn">
                            <h2 rv-text='helper.Name'></h2>
                        </div>
                    </div>
                    <div class="row" rv-show="helper.isHireling">
                        <div class="col-xs-6 mkn" style="text-align:center;">
                            <input type="button" class="btn btn-xs mkn" id="btnChangeHelperRace" rv-value="helper.Race" />
                        </div>
                        <div class="col-xs-6 mkn" style="text-align:center;">
                            <input type="button" class="btn btn-xs mkn" id="btnChangeHelperClass" rv-value="helper.Class" />
                        </div>
                    </div>
                    <div class="row" rv-show="helper.isHireling">
                        <div class="col-xs-4 mkn">
                            <input type="button" class="btn btn-xs mkn hlpGearUpdate" value="5" amount="-5" />
                            <input type="button" class="btn btn-xs mkn hlpGearUpdate" value="2" amount="-2" />
                            <input type="button" class="btn btn-xs mkn hlpGearUpdate" value="1" amount="-1" />
                            <h2 style="padding:0;">-</h2>
                        </div>
                        <div class="col-xs-4 mkn">
                            <h1 rv-text="helper.GearBonus"></h1><span style="font-size:20px;">Gear</span>
                        </div>
                        <div class="col-xs-4 mkn">
                            <h2 style="padding:0;">+</h2>
                            <input type="button" class="btn btn-xs mkn hlpGearUpdate" value="1" amount="1" />
                            <input type="button" class="btn btn-xs mkn hlpGearUpdate" value="2" amount="2" />
                            <input type="button" class="btn btn-xs mkn hlpGearUpdate" value="5" amount="5" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-xs-6 mkn">
                            <input type="button" class ="btn mkn helperHome" value="Go Back" />
                        </div>
                        <div class="col-xs-6 mkn">
                            <input type="button" class ="btn mkn" id="btnKillHelper" value="Kill" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div id="divBattle" class="mobile mkn2 mkn" rv-show="appData.gameState.currentState | eq 2">
            <div class="col-xs-12 mkn playerRow">
                <h3>Combatants</h3>
            </div>
            <div class="row playerRow">
                <div class="col-xs-2 mkn">
                    <table><tr>
                        <td><input type="button" id="btnSubtractLevel2" class="btn mkn btn-xs" value="L" /></td>
                        <td><input type="button" class="btn btn-xs mkn gearUpdate" value="G" amount="-1" /></td>
                        <td><h3>-</h3></td>
                    </tr></table>
                </div>
                <div class="col-xs-5 mkn">
                    <h3>{appData.gameState.currentBattle.gamePlayer.currentPlayer.DisplayName}</h3>
                </div>
                <div class="col-xs-2 mkn">
                    <h3>+{appData.gameState.currentBattle.gamePlayer.FightingLevel}</h3>
                </div>
                <div class="col-xs-2 mkn">
                    <table><tr>
                        <td><h3>+</h3></td>
                        <td><input type="button" class="btn btn-xs mkn gearUpdate" value="G" amount="1" /></td>
                        <td><input type="button" id="btnAddLevel2" class="btn mkn btn-xs" value="L" /></td>
                    </tr></table>
                </div>
            </div>
            <div class="row playerRow" rv-show="appData.gameState.currentBattle.HasAlly">
                <div class="col-xs-6 mkn">
                    <input type="button" id="btnRemoveAlly" class="btn btn-xs mkn" rv-value="appData.gameState.currentBattle.AllyName" />
                </div>
                <div class="col-xs-6 mkn">
                    <h3>+{appData.gameState.currentBattle.allyFightingLevel}</h3>
                </div>
            </div>
            <div class="row">
                <div class="col-xs-4 mkn">
                    <input type="button" class="btn btn-xs mkn BattleBonus" value="5" amount="-5" />
                    <input type="button" class="btn btn-xs mkn BattleBonus" value="2" amount="-2" />
                    <input type="button" class="btn btn-xs mkn BattleBonus" value="1" amount="-1" />
                    <h2 style="padding:0;">-</h2>
                </div>
                <div class="col-xs-4 mkn">
                    <h2>{appData.gameState.currentBattle.playerOneTimeBonus}</h2><span style="font-size:20px;">Bonus</span>
                </div>
                <div class="col-xs-4 mkn">
                    <h2 style="padding:0;">+</h2>
                    <input type="button" class="btn btn-xs mkn BattleBonus" value="1" amount="1" />
                    <input type="button" class="btn btn-xs mkn BattleBonus" value="2" amount="2" />
                    <input type="button" class="btn btn-xs mkn BattleBonus" value="5" amount="5" />
                </div>
            </div>
            <div class="row" id="divAddAlly" rv-hide="appData.gameState.currentBattle.HasAlly">
                <div class="col-xs-6 mkn">
                    <select id="ddlAvailableAllys" class="form-control">
                        <option rv-each-player="appData.gameState.currentBattle.PossibleAllies" rv-value="player.currentPlayer.PlayerID">{player.currentPlayer.DisplayName}</option>
                    </select>
                </div>
                <div class="col-xs-3 mkn">
                    <select id="ddlAllyTreasures" class="form-control">
                        <option value="0">0</option>
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                        <option value="5">5</option>
                        <option value="6">6</option>
                        <option value="7">7</option>
                        <option value="8">8</option>
                        <option value="9">9</option>
                    </select>
                </div>
                <div class="col-xs-3 mkn">
                    <input type="button" class="btn btn-xs mkn" id="btnAddAlly" value="Ally" />
                </div>
            </div>
            <div class="row" style="height:4px; background-color: #350400;">&nbsp;</div>
            <div class="col-xs-12 mkn playerRow">
                <h3>Monsters</h3>
            </div>
            <div class="row">
                <div class="col-xs-3">
                    <h3>Level</h3>
                </div>
                <div class="col-xs-3">
                    <h3>Bonus</h3>
                </div>
                <div class="col-xs-3">
                    <h3>Value</h3>
                </div>
                <div class="col-xs-3">
                    <h3>Loot</h3>
                </div>
            </div>
            <div class="row playerRow" rv-each-monster="appData.gameState.currentBattle.opponents">
                <div class="col-xs-3 mkn">
                    <input type="button" class="btn btn-xs mkn monsterButton" rv-monsterIDX=" %monster% " rv-value="monster.Level" />
                </div>
                <div class="col-xs-3 mkn">
                    <h3>{monster.OneTimeBonus}</h3>
                </div>
                <div class="col-xs-3 mkn">
                    <h3>{monster.LevelsToWin}</h3>
                </div>
                <div class="col-xs-3 mkn">
                    <h3>{monster.Treasures}</h3>
                </div>
            </div>
            <div class="row">
                <div class="col-xs-12 mkn">
                    <input type="button" class="btn btn-xs mkn" id="btnAddMonster" value="Add Monster" />
                </div>
            </div>
            <div class="row">
                <div class="col-xs-6">
                    <input type="button" id="btnCancelBattle" class="btn mkn" value="Cancel Battle" />
                </div>
                <div class="col-xs-6">
                    <input type="button" id="btnResolveBattle" class="btn mkn" value="GO" />
                </div>
            </div>
        </div>
        <div id="divMonsterEdit" class="mobile mkn2 mkn" style="display:none;" >
            <input type="hidden" id="hdnMonsterID" rv-value="curMonster.MonsterID" />
            <div class="row">
                <div class="col-xs-4" style="vertical-align:middle;">
                    <h2 style="padding:0;">-</h2>
                    <input type="button" class="btn btn-xs mkn monsterLevel" value="5" amount="-5" />
                    <input type="button" class="btn btn-xs mkn monsterLevel" value="2" amount="-2" />
                    <input type="button" class="btn btn-xs mkn monsterLevel" value="1" amount="-1" />
                </div>
                <div class="col-xs-4 mkn" style="vertical-align:middle;">
                    <h1 rv-text="curMonster.Level"></h1><span style="font-size:20px;">Level</span>
                </div>
                <div class="col-xs-4" style="vertical-align:middle;">
                    <h2 style="padding:0;">+</h2>
                    <input type="button" class="btn btn-xs mkn monsterLevel" value="1" amount="1" />
                    <input type="button" class="btn btn-xs mkn monsterLevel" value="2" amount="2" />
                    <input type="button" class="btn btn-xs mkn monsterLevel" value="5" amount="5" />
                </div>
            </div>
            <div class="row">
                <div class="col-xs-4 mkn">
                    <h2 style="padding:0;">-</h2>
                    <input type="button" class="btn btn-xs mkn monsterBonus" value="5" amount="-5" />
                    <input type="button" class="btn btn-xs mkn monsterBonus" value="2" amount="-2" />
                    <input type="button" class="btn btn-xs mkn monsterBonus" value="1" amount="-1" />
                </div>
                <div class="col-xs-4 mkn">
                    <h1 rv-text="curMonster.OneTimeBonus"></h1><span style="font-size:20px;">Bonus</span>
                </div>
                <div class="col-xs-4 mkn">
                    <h2 style="padding:0;">+</h2>
                    <input type="button" class="btn btn-xs mkn monsterBonus" value="1" amount="1" />
                    <input type="button" class="btn btn-xs mkn monsterBonus" value="2" amount="2" />
                    <input type="button" class="btn btn-xs mkn monsterBonus" value="5" amount="5" />
                </div>
            </div>
            <div class="row">
                <div class="col-xs-4" style="vertical-align:middle;">
                    <input type="button" id="btnSubtractMonsterLevelsToWin" class="btn mkn btn-xs updMonsterLTW" amount="-1" value="<" />
                </div>
                <div class="col-xs-4 mkn" style="vertical-align:middle;">
                    <h1 rv-text="curMonster.LevelsToWin"></h1><span style="font-size:20px;">Prize Levels</span>
                </div>
                <div class="col-xs-4" style="vertical-align:middle;">
                    <input type="button" id="btnAddMonsterLevelsToWin" class="btn mkn btn-xs updMonsterLTW" amount="1" value=">" />
                </div>
            </div>
            <div class="row">
                <div class="col-xs-4 mkn" style="vertical-align:middle;">
                    <input type="button" id="btnSubtractMonsterTreasures" class="btn mkn btn-xs updMonsterTreasure" amount="-1" value="<" />
                </div>
                <div class="col-xs-4 mkn" style="vertical-align:middle;">
                    <h1 rv-text="curMonster.Treasures"></h1><span style="font-size:20px;">Treasures</span>
                </div>
                <div class="col-xs-4 mkn" style="vertical-align:middle;">
                    <input type="button" id="btnAddMonsterTreasures" class="btn mkn btn-xs updMonsterTreasure" amount="1" value=">" />
                </div>
            </div>
            <div class="row">
                <div class="col-xs-6 mkn">
                    <input type="button" id="btnRemoveMonster" class="btn mkn btn-xs" value="Remove" />
                </div>
                <div class="col-xs-6 mkn">
                    <input type="button" id="btnCloseMonster" class="btn mkn btn-xs" value="Go Back" />
                </div>
            </div>
        </div>
        <div id="divSellItem" class="mobile mkn2 mkn" style="display:none;" >
            <div class="row">
                <div class="col-xs-4 mkn">
                    <input type="number" class="form-control" id="txtSaleAmount" />
                </div>
                <div class="col-xs-4 mkn">
                    <input type="button" id="btnSellItem" class="btn mkn btn-xs" value="Sell" />
                </div>
                <div class="col-xs-4 mkn">
                    <input type="button" id="btnCancelSell" class="btn mkn btn-xs" value="Cancel" />
                </div>
            </div>
        </div>
        <div id="divPostBattle" class="mobile mkn2 mkn" rv-show="appData.gameState.currentState | eq 3">
            <div class="row">
                <div class="col-xs-12 mkn">
                    <input type="button" class="btn btn-xs mkn" id="btnCompleteBattle" value="OK" />
                </div>
            </div>
        </div>
    </div>
    </div>
</asp:Content>

<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Controller.aspx.cs" Inherits="MunchkinMonitor.Controller" %>
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
            $('#btnEndGame').click(function () {
                appData.currentState = 0;
                data.run('EndGame');
            });
            $('#btnAddPlayer').click(function () {
                if ($('#ddlPlayers').val() != -1) {
                    data.run('AddExistingPlayer', { id: $('#ddlPlayers').val() });
                    $('#ddlPlayers').val('-1');
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
                data.run('AddNewPlayer', { firstName: $('#txtFirstName').val(), lastName: $('#txtLastName').val(), nickName: $('#txtNickName').val(), gender: $('#ddlGender').val() });
                data.run('LoadPlayers');
                objectCopy(data.run('GetCurrentAppState'), appData);
                $('#txtFirstName').val('');
                $('#txtLastName').val('');
                $('#txtNickName').val('');
                $('#ddlGender').val('0');
                $('#divAddExistingPlayer').slideDown();
                $('#divAddNewPlayer').slideUp();
            });
            $('#btnStartGame').click(function () {
                data.run('StartGame');
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('#btnSubtractLevel').click(function () {
                data.run('SubtractLevel');
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('#btnAddLevel').click(function () {
                data.run('AddLevel');
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('.gearUpdate').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateGear', { amount: amount });
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('#btnRace').click(function () {
                $('#divPlayerSettings').slideUp();
                $('#divRace').slideDown();
            });
            $('#btnChgRace').click(function () {
                data.run('NextRace');
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('#btnHalfBreed').click(function () {
                data.run('ToggleHalfBreed');
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('#btnChgHBRace').click(function () {
                data.run('NextHalfBreed');
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('#btnClass').click(function () {
                $('#divPlayerSettings').slideUp();
                $('#divClass').slideDown();
            });
            $('#btnChgClass').click(function () {
                data.run('NextClass');
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('#btnSuperMkn').click(function () {
                data.run('ToggleSuperMunchkin');
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('#btnChgSMClass').click(function () {
                data.run('NextSMClass');
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('#btnGender').click(function () {
                $('#divPlayerSettings').slideUp();
                $('#divGender').slideDown();
            });
            $('#btnChgGender').click(function () {
                data.run('ChangeGender', { penalty: $('#txtGenderPenalty').val() });
                objectCopy(data.run('GetCurrentAppState'), appData);
                $('#divPlayerSettings').slideDown();
                $('#divGender').slideUp();
            });
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
                objectCopy(data.run('GetCurrentAppState'), appData);
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
            $('.hirelingButton .steedButton').click(function () {
                var idx = $(this).attr('hireIDX');
                if ($(this).hasClass('hirelingButton')) {
                    $('#hdnHelperType').val('hireling');
                    rivets.bind($('#divEditHelper'), { appData: appData.gameState.currentPlayer.Hirelings[idx] });
                }
                else {
                    $('#hdnHelperType').val('steed');
                    rivets.bind($('#divEditHelper'), { appData: appData.gameState.currentPlayer.Steeds[idx] });
                }
                $('divHirelings').slideUp();
                $('#divSteeds').slideUp();
                $('#divEditHelper').slideDown();
            });
            $('.hlpGearUpdate').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateHelperGear', { helperID: $('hdnHelperID').val(), amount: amount });
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('#btnKillHelper').click(function () {
                data.run('KillHelper', { helperID: $('hdnHelperID').val() });
                objectCopy(data.run('GetCurrentAppState'), appData);

                if ($('#hdnHelperType').val() == 'hireling')
                    $('#divHirelings').slideDown();
                else
                    $('#divSteeds').slideDown();
                $('#divAddHelper').slideUp();
                $('#divEditHelper').slideUp();
            })
            $('#btnPrevPlayer').click(function () {
                data.run('PrevPlayer');
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('#btnNextPlayer').click(function () {
                data.run('NextPlayer');
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('.playerSetupHome').click(function () {
                $('#divPlayerSettings').slideDown();
                $('#divRace').slideUp();
                $('#divClass').slideUp();
                $('#divGender').slideUp();
                $('#divHirelings').slideUp();
                $('#divSteeds').slideUp();
            });
        });
    </script>
    <img src="Images/controllerBG.jpg" id="bg" alt="">
    <div id="divPreGame" class="mobile mkn2 mkn" rv-show="appData.currentState | eq 0">
        <input id="btnNewGame" type="button" class="btn mkn" value="Start New Game" /><br />
        <input id="btnNewEpic" type="button" class="btn mkn" value="Start New Epic Game" />
    </div>
    <div rv-show="appData.currentState | neq 0">
        <div id="divSetup" class="mobile mkn2 mkn" rv-show="appData.gameState.currentState | eq 0">
            <div id="divAddExistingPlayer">
                <select id="ddlPlayers" class="form-control">
                    <option value="-1">New Player</option>
                    <option rv-each-player="appData.playerStats.players" rv-value="player.PlayerID" rv-class-hide="player.PlayerID | eq -1">{player.DisplayName}</option>
                </select>
                <input id="btnAddPlayer" type="button" class="btn mkn" value="Add Player" /><br />
                <div class="row">
                    <div class="col-xs-6" style="text-align:center">
                        <input id="btnEndGame" type="button" class="btn mkn" value="Cancel" style="font-size:30px;" />
                    </div>
                    <div class="col-xs-6" style="text-align:center">
                        <input id="btnStartGame" type="button" class="btn mkn" value="GO!" style="font-size:30px;" />
                    </div>
                </div>
            </div>
            <div id="divAddNewPlayer" style="display:none;">
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
                                <h2 style="padding:0;">-</h2>
                                <input type="button" class="btn btn-xs mkn gearUpdate" value="5" amount="-5" />
                                <input type="button" class="btn btn-xs mkn gearUpdate" value="2" amount="-2" />
                                <input type="button" class="btn btn-xs mkn gearUpdate" value="1" amount="-1" />
                            </div>
                            <div class="col-xs-4 mkn">
                                <h1>{appData.gameState.currentPlayer.GearBonus}</h1><span style="font-size:20px;">Gear</span>
                            </div>
                            <div class="col-xs-4 mkn">
                                <h2 style="padding:0;">+</h2>
                                <input type="button" class="btn btn-xs mkn gearUpdate" value="1" amount="1" />
                                <input type="button" class="btn btn-xs mkn gearUpdate" value="2" amount="2" />
                                <input type="button" class="btn btn-xs mkn gearUpdate" value="5" amount="5" />
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
                            <div class="col-xs-6">
                                <input type="button" id="btnHirelings" class="btn mkn btn-xs" value="Hirelings" />
                            </div>
                            <div class="col-xs-6">
                                <input type="button" id="btnSteeds" class="btn mkn btn-xs" value="Steeds" />
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
                    <div class="col-xs-6">
                        <input type="text" id="txtGenderPenalty" class="form-control" />
                    </div>
                    <div class="col-xs-6">
                        <input type="button" id="btnChgGender" class="btn mkn" value="Change" />
                    </div>
                    <div class="col-xs-12" >
                        <input type="button" class="btn mkn playerSetupHome" value="Go Back" />
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
                            <h3>{hireling.Race}</h3>
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
                            <h2>{helper.Name}</h2>
                        </div>
                    </div>
                    <div class="row" rv-show="helper.isHireling">
                        <div class="col-xs-4 mkn">
                            <h2 style="padding:0;">-</h2>
                            <input type="button" class="btn btn-xs mkn hlpGearUpdate" value="5" amount="-5" />
                            <input type="button" class="btn btn-xs mkn hlpGearUpdate" value="2" amount="-2" />
                            <input type="button" class="btn btn-xs mkn hlpGearUpdate" value="1" amount="-1" />
                        </div>
                        <div class="col-xs-4 mkn">
                            <h1>{helper.GearBonus}</h1><span style="font-size:20px;">Gear</span>
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
        </div>
        <div id="divPostBattle" class="mobile mkn2 mkn" rv-show="appData.gameState.currentState | eq 3">
        </div>
    </div>
</asp:Content>

<%@ Page Title="Munchkin Player Controller" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Controller.aspx.cs" Inherits="MunchkinMonitor.Controller" %>
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
                appData = data.run('GetCurrentPlayerAppState');
                getUpdate = false;
            }
            else {
                getUpdate = data.run('CheckForStateUpdate', { lastUpdate: new Date(appData.stateUpdatedJS) });
            }

            if (getUpdate) {
                objectCopy(data.run('GetCurrentPlayerAppState'), appData);
            }
        };
        $(document).ready(function () {
            $('#btnJoinGame').click(function () {
                data.run('LoginPlayer', { username: $('#txtUserName').val() });
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnJoinGameNewPlayer').click(function () {
                data.run('LoginNewPlayer', { username: $('#txtNewUserName').val(), firstName: $('#txtFirstName').val(), lastName: $('#txtLastName').val(), nickName: $('#txtNickName').val(), gender: $('#ddlGender').val() });
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('.toggleNewPlayer').click(function () {
                $('.loginButton').toggle();
            });
            $('.dashboard').click(function () {
                $('.ctrlPanel').hide();
                $('#divPlayerDashboard').slideDown();
            })
            $('#btnLevel').click(function () {
                $('#divPlayerDashboard').hide();
                $('#divCtrlPlayerLevel').slideDown();
            });
            $('#btnAddLevel,#btnAddLevel2').click(function () {
                data.run('AddPlayerLevel');
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnSubtractLevel,#btnSubtractLevel2').click(function () {
                data.run('SubtractPlayerLevel');
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnGear').click(function () {
                $('#divPlayerDashboard').hide();
                $('#divCtrlPlayerGear').slideDown();
            });
            $('.gearUpdate').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdatePlayerGear', { amount: amount });
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnSell').click(function () {
                $('#divPlayerDashboard').hide();
                $('#divCtrlPlayerSell').slideDown();
            });
            $('#btnSellItem').click(function () {
                data.run('SellPlayerItem', { amount: $('#txtSaleAmount').val() });
                $('.ctrlPanel').hide();
                $('#divPlayerDashboard').slideDown();
                $('#txtSaleAmount').val('');
            });
            $('#btnCancelSell').click(function () {
                $('.ctrlPanel').hide();
                $('#divPlayerDashboard').slideDown();
                $('#txtSaleAmount').val('');
            });
            $('#btnRace').click(function () {
                $('#divPlayerDashboard').hide();
                $('#divCtrlPlayerRace').slideDown();
            });
            $('#btnGender').click(function () {
                data.run('ChangePlayerGender', { penalty: 0 });
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnClass').click(function () {
                $('#divPlayerDashboard').hide();
                $('#divCtrlPlayerClass').slideDown();
            });
            $('#btnChgRace').click(function () {
                data.run('NextPlayerRace');
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnHalfBreed').click(function () {
                data.run('TogglePlayerHalfBreed');
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnChgHBRace').click(function () {
                data.run('NextPlayerHalfBreed');
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnChgClass').click(function () {
                data.run('NextPlayerClass');
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnSuperMkn').click(function () {
                data.run('TogglePlayerSuperMunchkin');
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnChgSMClass').click(function () {
                data.run('NextPlayerSMClass');
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnSteed').click(function () {
                $('#divPlayerDashboard').hide();
                $('#divCtrlPlayerSteed').slideDown();
            });
            $('#btnHireling').click(function () {
                $('#divPlayerDashboard').hide();
                $('#divCtrlPlayerSteed').slideDown();
            });
            $(document).on('click', '.hirelingButton,.steedButton', function () {
                idx = $(this).attr('hireIDX');
                if ($(this).hasClass('hirelingButton')) {
                    $('#hdnHelperType').val('hireling');
                    helperData = appData.playerState.Player.Hirelings[idx];
                    rivets.bind($('#divEditHelper'), { helper: helperData });
                }
                else {
                    $('#hdnHelperType').val('steed');
                    helperData = appData.playerState.Player.Steeds[idx];
                    rivets.bind($('#divEditHelper'), { helper: helperData });
                }
                $('#divHirelings').slideUp();
                $('#divSteeds').slideUp();
                $('#divEditHelper').slideDown();
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
                data.run('AddPlayerHelper', { steed: steed, bonus: $('#txtHelperBonus').val() });
                objectCopy(data.run('GetPlayerState'), appData);
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
            $('#btnChangeHelperRace').click(function () {
                data.run('ChangePlayerHelperRace', { helperID: $('#hdnHelperID').val() });
                objectCopy(data.run('GetPlayerState'), appData);
                objectCopy(appData.playerState.Player.Hirelings[idx], helperData);
            });
            $('.hlpGearUpdate').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdatePlayerHelperGear', { helperID: $('#hdnHelperID').val(), amount: amount });
                objectCopy(data.run('GetPlayerState'), appData);
                objectCopy(appData.playerState.Player.Hirelings[idx], helperData);
            });
            $('#btnKillHelper').click(function () {
                data.run('KillPlayerHelper', { helperID: $('#hdnHelperID').val() });
                objectCopy(data.run('GetPlayerState'), appData);

                if ($('#hdnHelperType').val() == 'hireling')
                    $('#divHirelings').slideDown();
                else
                    $('#divSteeds').slideDown();
                $('#divAddHelper').slideUp();
                $('#divEditHelper').slideUp();
            });
            $('#btnBattle').click(function () {
                data.run('StartEmptyBattle');
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnAddFirstMonster').click(function () {
                data.run('AddMonster', { level: $('#txtFirstMonsterLevel').val(), levelsToWin: $('#txtFirstMonsterPrizeLevels').val(), treasures: $('#txtFirstMonsterTreasures').val() });
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnRemoveAlly').click(function () {
                data.run('RemoveAlly');
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('.BattleBonus').click(function () {
                var amount = $(this).attr('amount');
                data.run('BattleBonus', { amount: amount });
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $(document).on('click', '.monsterButton', function () {
                mIdx = $(this).attr('monsterIDX');
                monsterData = appData.playerState.currentBattle.opponents[mIdx];
                rivets.bind($('#divMonsterEdit'), { curMonster: monsterData });
                $('#divCtrlPlayerBattle').slideUp();
                $('#divMonsterEdit').slideDown();
            });
            $('#btnAddMonster').click(function () {
                mIdx = data.run('AddMonster', { level: 1, levelsToWin: 1, treasures: 1 });
                objectCopy(data.run('GetPlayerState'), appData);
                monsterData = appData.playerState.currentBattle.opponents[mIdx];
                rivets.bind($('#divMonsterEdit'), { curMonster: monsterData });
                $('#divCtrlPlayerBattle').slideUp();
                $('#divMonsterEdit').slideDown();
            });
            $('#btnCancelBattle').click(function () {
                mIdx = data.run('CancelBattle');
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnResolveBattle').click(function () {
                mIdx = data.run('ResolveBattle');
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('.monsterLevel').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateMonsterLevel', { monsterIDX: mIdx, amount: amount });
                objectCopy(data.run('GetPlayerState'), appData);
                objectCopy(appData.playerState.currentBattle.opponents[mIdx], monsterData);
            });
            $('.monsterBonus').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateMonsterBonus', { monsterIDX: mIdx, amount: amount });
                objectCopy(data.run('GetPlayerState'), appData);
                objectCopy(appData.playerState.currentBattle.opponents[mIdx], monsterData);
            });
            $('.updMonsterLTW').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateMonsterLTW', { monsterIDX: mIdx, amount: amount });
                objectCopy(data.run('GetPlayerState'), appData);
                objectCopy(appData.playerState.currentBattle.opponents[mIdx], monsterData);
            });
            $('.updMonsterTreasure').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateMonsterTreasures', { monsterIDX: mIdx, amount: amount });
                objectCopy(data.run('GetPlayerState'), appData);
                objectCopy(appData.playerState.currentBattle.opponents[mIdx], monsterData);
            });
            $('#btnRemoveMonster').click(function () {
                data.run('RemoveMonster', { monsterIDX: mIdx });
                objectCopy(data.run('GetPlayerState'), appData);
                mIdx = -1;
                monsterData = null;
                $('#divCtrlPlayerBattle').slideDown();
                $('#divMonsterEdit').slideUp();
            });
            $('#btnCloseMonster').click(function () {
                mIdx = -1;
                monsterData = null;
                $('#divCtrlPlayerBattle').slideDown();
                $('#divMonsterEdit').slideUp();
            });
            $('#btnOfferAlly').click(function () {
                data.run('AddPlayerAsAlly', { allyTreasures: $('#ddlAllyTreasures').val() });
                objectCopy(data.run('GetPlayerState'), appData);
            });
        });

    </script>
    <img src="Images/controllerBG.jpg" id="bg" alt="">
    <div class="row" rv-show="appData.playerState.gameState | neq 1">
        <div id="pnlExistingLogin">
            <div class="col-xs-3">
                <label for="txtUserName">User</label>
            </div>
            <div class="col-xs-9">
                <input id="txtUserName" class="form-control" />
            </div>
        </div>
        <div id="pnlNewLogin">
            <div class="col-xs-3">
                <label for="txtNewUserName">User Name</label>
            </div>
            <div class="col-xs-9">
                <input id="txtNewUserName" class="form-control" />
            </div>
            <div class="col-xs-3">
                <label for="txtFirstName">First</label>
            </div>
            <div class="col-xs-9">
                <input id="txtFirstName" class="form-control" />
            </div>
            <div class="col-xs-3">
                <label for="txtLastName">Last</label>
            </div>
            <div class="col-xs-9">
                <input id="txtLastName" class="form-control" />
            </div>
            <div class="col-xs-3">
                <label for="txtNickName">Nick</label>
            </div>
            <div class="col-xs-9">
                <input id="txtNickName" class="form-control" />
            </div>
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
        <div class="col-xs-6 loginButton">            
            <input id="btnJoinGame" type="button" class="btn mkn btn-xs" value="Join Game" />
        </div>
        <div class="col-xs-6 loginButton">            
            <input type="button" class="btn mkn btn-xs toggleNewPlayer" value="New Player" />
        </div>
        <div class="col-xs-6 loginButton" style="display:none;">            
            <input id="btnJoinGameNewPlayer" type="button" class="btn mkn btn-xs" value="Join Game" />
        </div>
        <div class="col-xs-6 loginButton" style="display:none;">            
            <input type="button" class="btn mkn btn-xs toggleNewPlayer" value="Existing Player" />
        </div>
    </div>
    <div class="row" rv-show="appData.playerState.gameState | eq 1">        
        <div id="divPlayer">
            <div class="row">
                <div class="col-xs-12">
                    <h1>{appData.playerState.DisplayName}</h1>
                </div>
            </div>
            <div class="row">
                <div class="col-xs-4" style="border-right:black solid 1px;">
                    <h4>L: {appData.playerState.CurrentLevel}</h4>
                </div>
                <div class="col-xs-4" style="border-right:black solid 1px;">
                    <h4>FL: {appData.playerState.FightingLevel}</h4>
                </div>
                <div class="col-xs-4">
                    <h4>AL: {appData.playerState.AllyLevel}</h4>
                </div>
            </div>
            <div class="row" id="divPlayerDashboard">
                <div class="col-xs-12">
                    <div class="row">
                        <div class="col-xs-4">
                            <input type="button" id="btnLevel" class="btn mkn btn-xs" value="Level" />
                        </div>
                        <div class="col-xs-4">
                            <input type="button" id="btnGear" class="btn mkn btn-xs" value="Gear" />
                        </div>
                        <div class="col-xs-4">
                            <input type="button" id="btnSell" class="btn mkn btn-xs" value="Sell" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-xs-4">
                            <input type="button" id="btnRace" class="btn mkn btn-xs" rv-value="appData.playerState.Race" />
                        </div>
                        <div class="col-xs-4">
                            <input type="button" id="btnGender" class="btn mkn btn-xs" rv-value="appData.playerState.Gender" />
                        </div>
                        <div class="col-xs-4">
                            <input type="button" id="btnClass" class="btn mkn btn-xs" rv-value="appData.playerState.Class" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-xs-6">
                            <input type="button" id="btnSteed" class="btn mkn btn-xs" value="Steed" />
                        </div>
                        <div class="col-xs-6">
                            <input type="button" id="btnHireling" class="btn mkn btn-xs" value="Hireling" />
                        </div>
                    </div>
                    <div class="row" rv-show="appData.playerState.myTurn">
                        <div class="col-xs-12">
                            <input type="button" id="btnBattle" class="btn mkn btn-xs" style="width:100%;" value="Battle!" />
                        </div>
                    </div>
                    <div class="row" rv-show="appData.playerState.CanAlly">
                        <div class="col-xs-12">
                            <input type="button" id="btnAlly" class="btn mkn btn-xs" style="width:100%;" value="Offer to Ally" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="row ctrlPanel" id="divCtrlPlayerLevel" style="display:none;">
                <div class="col-xs-12" style="vertical-align:middle;">
                    <input type="button" id="btnAddLevel" class="btn mkn btn-xs" style="font-size:25px;" value="+" />
                </div>
                <div class="col-xs-12 mkn" style="vertical-align:middle;">
                    <h1>{appData.playerState.CurrentLevel}</h1><span style="font-size:20px;">Level</span>
                </div>
                <div class="col-xs-12" style="vertical-align:middle;">
                    <input type="button" id="btnSubtractLevel" class="btn mkn btn-xs" style="font-size:25px;" value="-" />
                </div>
                <div class="col-xs-12" style="vertical-align:middle;">
                    <input type="button" class="btn mkn btn-xs dashboard" value="Done" />
                </div>
            </div>
            <div class="row ctrlPanel" id="divCtrlPlayerGear" style="display:none;">
                <div class="col-xs-4" style="vertical-align:middle;">
                    <input type="button" class="btn mkn btn-xs gearUpdate" amount="1" style="font-size:25px;" value="+1" />
                </div>
                <div class="col-xs-4" style="vertical-align:middle;">
                    <input type="button" class="btn mkn btn-xs gearUpdate" amount="2" style="font-size:25px;" value="+2" />
                </div>
                <div class="col-xs-4" style="vertical-align:middle;">
                    <input type="button" class="btn mkn btn-xs gearUpdate" amount="5" style="font-size:25px;" value="+5" />
                </div>
                <div class="col-xs-12 mkn" style="vertical-align:middle;">
                    <h1>{appData.playerState.GearBonus}</h1><span style="font-size:20px;">Level</span>
                </div>                
                <div class="col-xs-4" style="vertical-align:middle;">
                    <input type="button" class="btn mkn btn-xs gearUpdate" amount="-1" style="font-size:25px;" value="-1" />
                </div>
                <div class="col-xs-4" style="vertical-align:middle;">
                    <input type="button" class="btn mkn btn-xs gearUpdate" amount="-2" style="font-size:25px;" value="-2" />
                </div>
                <div class="col-xs-4" style="vertical-align:middle;">
                    <input type="button" class="btn mkn btn-xs gearUpdate" amount="-5" style="font-size:25px;" value="-5" />
                </div>
                <div class="col-xs-12" style="vertical-align:middle;">
                    <input type="button" class="btn mkn btn-xs dashboard" value="Done" />
                </div>
            </div>
            <div class="row ctrlPanel" id="divCtrlPlayerSell" style="display:none;">
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
            <div class="row ctrlPanel" id="divCtrlPlayerRace" style="display:none;">
                <div class="col-xs-12">
                    <input type="button" id="btnChgRace" class="btn mkn" rv-value="appData.playerState.Player.CurrentRaceList.0.Description | test" value="Race" />
                </div>
                <div class="col-xs-12">
                    <input type="button" id="btnHalfBreed" class="btn mkn" rv-value="appData.playerState.Player.HalfBreed | ite 'Half-Breed' 'Single Race'" />
                </div>
                <div class="col-xs-12" rv-show="appData.playerState.Player.HalfBreed">
                    <input type="button" id="btnChgHBRace" class="btn mkn" rv-value="appData.playerState.Player.CurrentRaceList.1.Description" value="Other Race" />
                </div>
                <div class="col-xs-12" >
                    <input type="button" class="btn mkn dashboard" value="Go Back" />
                </div>
            </div>
            <div class="row ctrlPanel" id="divCtrlPlayerClass" style="display:none;">
                <div class="col-xs-12">
                    <input type="button" id="btnChgClass" class="btn mkn" rv-value="appData.playerState.Player.CurrentClassList.0.Description" ="Class" />
                </div>
                <div class="col-xs-12">
                    <input type="button" id="btnSuperMkn" class="btn mkn" rv-value="appData.playerState.Player.SuperMunchkin | ite 'Super Munchkin' 'Single Class'" />
                </div>
                <div class="col-xs-12" rv-show="appData.playerState.Player.SuperMunchkin">
                    <input type="button" id="btnChgSMClass" class="btn mkn" rv-value="appData.playerState.Player.CurrentClassList.1.Description" value="Other Class" />
                </div>
                <div class="col-xs-12" >
                    <input type="button" class="btn mkn dashboard" value="Go Back" />
                </div>
            </div>
            <div class="row ctrlPanel" id="divCtrlPlayerSteed" style="display:none;">
                <div class="col-xs-12 mkn">
                    <h2>Steeds</h2>
                </div>
                <div class="row">&nbsp;
                </div>
                <div class="row" rv-show="appData.playerState.HasSteeds | neq true">
                    <div class="col-xs-6">
                        <h3>No Steeds</h3>
                    </div>
                </div>
                <div class="row" rv-each-steed="appData.playerState.Steeds">
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
                    <input type="button" class="btn mkn dashboard" value="Done" />
                </div>
            </div>
            <div class="row ctrlPanel" id="divCtrlPlayerHireling" style="display:none;">
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
                <div class="row" rv-show="appData.playerState.HasHirelings | neq true">
                    <div class="col-xs-6">
                        <h3>No Hirelings</h3>
                    </div>
                </div>
                <div class="row playerRow" rv-each-hireling="appData.playerState.Hirelings">
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
                    <input type="button" class="btn mkn dashboard" value="Done" />
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
            <div class="row ctrlPanel" id="divCtrlPlayerBattle" rv-show="appData.playerState.IsInBattle">
                <div class="col-xs-12 mkn" rv-show="appData.playerState.currentBattle.needsOpponent">
                    <div class="row">
                        <div class="col-xs-6 mkn"style="vertical-align:bottom;">
                            <h3>Fighting Level:</h3>
                        </div>
                        <div class="col-xs-6 mkn" style="vertical-align:bottom;">
                            <input type="number" class="form-control" id="txtFirstMonsterLevel" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-xs-6 mkn"style="vertical-align:bottom;">
                            <h3>Treasures:</h3>
                        </div>
                        <div class="col-xs-6 mkn" style="vertical-align:bottom;">
                            <input type="number" class="form-control" id="txtFirstMonsterTreasures" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-xs-6 mkn"style="vertical-align:bottom;">
                            <h3>Prize Levels:</h3>
                        </div>
                        <div class="col-xs-6 mkn" style="vertical-align:bottom;">
                            <input type="number" class="form-control" id="txtFirstMonsterPrizeLevels" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-xs-6 mkn">
                            <input type="button" id="btnAddFirstMonster" class ="btn mkn" value="Go!" />
                        </div>
                        <div class="col-xs-6 mkn">
                            <input type="button" class ="btn mkn dashboard" id="btnNoBattle" value="Cancel" />
                        </div>
                    </div>
                </div>
                <div class="col-xs-12 mkn" rv-show="appData.playerState.currentBattle.hasOpponent">
                    <div class="row">
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
                                <h3>{appData.playerState.DisplayName}</h3>
                            </div>
                            <div class="col-xs-2 mkn">
                                <h3>+{appData.playerState.FightingLevel}</h3>
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
                                <input type="button" id="btnRemoveAlly" class="btn btn-xs mkn" rv-value="appData.playerState.currentBattle.AllyName" />
                            </div>
                            <div class="col-xs-6 mkn">
                                <h3>+{appData.playerState.currentBattle.allyFightingLevel}</h3>
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
                                <h2>{appData.playerState.currentBattle.playerOneTimeBonus}</h2><span style="font-size:20px;">Bonus</span>
                            </div>
                            <div class="col-xs-4 mkn">
                                <h2 style="padding:0;">+</h2>
                                <input type="button" class="btn btn-xs mkn BattleBonus" value="1" amount="1" />
                                <input type="button" class="btn btn-xs mkn BattleBonus" value="2" amount="2" />
                                <input type="button" class="btn btn-xs mkn BattleBonus" value="5" amount="5" />
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
            <div class="row ctrlPanel" id="divCtrlPlayerAlly" style="display:none;">
                <div class="col-xs-6 mkn"style="vertical-align:bottom;">
                    <h3>Treasures:</h3>
                </div>
                <div class="col-xs-6 mkn" style="vertical-align:bottom;">
                    <input type="number" class="form-control" id="txtAllyTreasures" />
                </div>
                <div class="col-xs-6 mkn">
                    <input type="button" id="btnOfferAlly" class="btn mkn btn-xs" value="Make Offer" />
                </div>
                <div class="col-xs-6 mkn">
                    <input type="button" id="btnCancelAlly" class="btn mkn btn-xs dashboard" value="Cancel" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
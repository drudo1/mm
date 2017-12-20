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
                appData = data.run('GetPlayerState');
                getUpdate = false;
            }
            else {
                getUpdate = data.run('CheckForStateUpdate', { lastUpdate: new Date(appData.stateUpdatedJS) });
            }

            if (getUpdate) {
                objectCopy(data.run('GetPlayerState'), appData);
            }
        };
        function getUrlVars() {
            var vars = [], hash;
            var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
            for (var i = 0; i < hashes.length; i++) {
                hash = hashes[i].split('=');
                vars.push(hash[0]);
                vars[hash[0]] = hash[1];
            }
            return vars;
        }
        $(document).ready(function () {
            if (getUrlVars()["ADMIN"] == "42") {
                $('#pnlAdmin').show();
                $('#btnPlayerRotate').click(function () {
                    data.run('MakeMeNextPlayer');
                    objectCopy(data.run('GetPlayerState'), appData);
                });
                $('#btnPlayerNotPlaying').click(function () {
                    data.run('RemovePlayerFromRotation');
                    objectCopy(data.run('GetPlayerState'), appData);
                });
            }
            $('#btnJoinGame').click(function () {
                var result = data.run('LoginPlayer', { username: $('#txtUserName').val(), password: $('#txtPassword').val() });
                if (result == "LoggedIn") {
                    $('#h3LoginError').html('');
                    objectCopy(data.run('GetPlayerState'), appData);
                    $('#txtUserName').val('');
                    $('#txtPassword').val('');
                }
                else
                    $('#h3LoginError').html('Bad username or password.');
            });
            $('#btnJoinGameNewPlayer').click(function () {
                var result = data.run('LoginNewPlayer', { username: $('#txtNewUserName').val(), password: $('#txtNewPassword').val(), firstName: $('#txtFirstName').val(), lastName: $('#txtLastName').val(), nickName: $('#txtNickName').val(), gender: $('#ddlGender').val() });
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('.toggleNewPlayer').click(function () {
                $('#pnlNewLogin').toggle();
                $('#pnlExistingLogin').toggle();
                $('.loginButton').toggle();
            });
            $('.dashboard').click(function () {
                $('.ctrlPanel').hide();
                $('#divPlayerDashboard').slideDown();
            });
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
                objectCopy(data.run('GetPlayerState'), appData);
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
                data.run('ChangePlayerGender');
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
                $('#divCtrlPlayerHireling').slideDown();
            });
            $(document).on('click', '.hirelingButton,.steedButton', function () {
                idx = $(this).attr('hireIDX');
                if ($(this).hasClass('hirelingButton')) {
                    $('#hdnHelperType').val('hireling');
                    helperData = appData.Player.Hirelings[idx];
                    rivets.bind($('#divEditHelper'), { helper: helperData });
                }
                else {
                    $('#hdnHelperType').val('steed');
                    helperData = appData.Player.Steeds[idx];
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
                $('#txtHelperBonus').val('');
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
                objectCopy(appData.Player.Hirelings[idx], helperData);
            });
            $('.hlpGearUpdate').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdatePlayerHelperGear', { helperID: $('#hdnHelperID').val(), amount: amount });
                objectCopy(data.run('GetPlayerState'), appData);
                objectCopy(appData.Player.Hirelings[idx], helperData);
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
                $('#txtFirstMonsterLevel').val('');
                $('#txtFirstMonsterPrizeLevels').val('');
                $('#txtFirstMonsterTreasures').val('');
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
                monsterData = appData.currentBattle.opponents[mIdx];
                rivets.bind($('#divMonsterEdit'), { curMonster: monsterData });
                $('#divCtrlPlayerBattle').slideUp();
                $('#divMonsterEdit').slideDown();
            });
            $('#btnAddMonster').click(function () {
                mIdx = data.run('AddMonster', { level: 1, levelsToWin: 1, treasures: 1 });
                objectCopy(data.run('GetPlayerState'), appData);
                monsterData = appData.currentBattle.opponents[mIdx];
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
                setTimeout(function () {
                    mIdx = data.run('CompleteBattle');
                    objectCopy(data.run('GetCurrentRoomState'), appData);
                }, 30000);
            });
            $('.monsterLevel').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateMonsterLevel', { monsterIDX: mIdx, amount: amount });
                objectCopy(data.run('GetPlayerState'), appData);
                objectCopy(appData.currentBattle.opponents[mIdx], monsterData);
            });
            $('.monsterBonus').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateMonsterBonus', { monsterIDX: mIdx, amount: amount });
                objectCopy(data.run('GetPlayerState'), appData);
                objectCopy(appData.currentBattle.opponents[mIdx], monsterData);
            });
            $('.updMonsterLTW').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateMonsterLTW', { monsterIDX: mIdx, amount: amount });
                objectCopy(data.run('GetPlayerState'), appData);
                objectCopy(appData.currentBattle.opponents[mIdx], monsterData);
            });
            $('.updMonsterTreasure').click(function () {
                var amount = $(this).attr('amount');
                data.run('UpdateMonsterTreasures', { monsterIDX: mIdx, amount: amount });
                objectCopy(data.run('GetPlayerState'), appData);
                objectCopy(appData.currentBattle.opponents[mIdx], monsterData);
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
            $('#btnAlly').click(function () {
                $('#divCtrlPlayerAlly').slideDown();
            });
            $('#btnOfferAlly').click(function () {
                data.run('AddPlayerAsAlly', { allyTreasures: $('#txtAllyTreasures').val() });
                objectCopy(data.run('GetPlayerState'), appData);
                $('#divCtrlPlayerAlly').hide();
                $('#txtAllyTreasures').val('');
            });
            $('#btnStartGame').click(function ()  {
                data.run('StartGame');
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnNextPlayer').click(function () {
                data.run('NextPlayer');
                objectCopy(data.run('GetPlayerState'), appData);
            });
            $('#btnScoreboard').click(function () {
                $('#divScoreBoardHeader').after('<div class="row playerRow playerRowBound" rv-class-selected="player.currentPlayer.PlayerID | isCurrentPlayer" rv-each-player="appData.currentGame.players"><div class="col-xs-6 mkn" rv-class-col-xs-12="player.CurrentLevel | lt 1" >&nbsp;&nbsp;{player.currentPlayer.DisplayName}</div><div class="col-xs-2 mkn" rv-class-hide="player.CurrentLevel | lt 1" style="text-align:center" >{player.CurrentLevel}</div><div class="col-xs-2 mkn" rv-class-hide="player.CurrentLevel | lt 1" style="text-align:center" >{player.FightingLevel}</div><div class="col-xs-2 mkn" rv-class-hide="player.CurrentLevel | lt 1" style="text-align:center" >{player.AllyLevel}</div></div>');
                rivets.bind($('#divScoreBoard'), { appData: appData });
                $('#divPlayerDashboard').hide();
                $('#divScoreBoard').slideDown();
            });
            $('#btnCloseScoreboard').click(function () {
                $('#divScoreBoard').hide();
                $('#divPlayerDashboard').slideDown();
                $('.playerRowBound').remove();
            });

            $(document).on('click', '.roomButton', function () {
                data.run('PlayerEnterRoom', { id: $(this).attr('RoomID') });
                objectCopy(data.run('GetPlayerState'), appData);
            });

            $(document).on('click', '.removeRoomButton', function () {
                data.run('PlayerLeaveRoom', { id: $(this).attr('RoomID') });
                objectCopy(data.run('GetPlayerState'), appData);
            });

            $('#btnExitRoom').click(function () {
                data.run('PlayerExitRoom');
                objectCopy(data.run('GetPlayerState'), appData);
            });

            $('#btnNewRoom').click(function () {
                $('#roomList').hide();
                $('#pnlCreateRoom').slideDown();
            });

            $('#btnJoinRoom').click(function () {
                $('#roomList').hide();
                $('#pnlJoinRoom').slideDown();
            });

            $('#btnCancelCreateRoom').click(function () {
                $('#pnlCreateRoom').hide();
                $('#roomList').slideDown();
            });

            $('#btnCancelJoinRoom').click(function () {
                $('#pnlJoinRoom').hide();
                $('#roomList').slideDown();
            });

            $('#btnCreateRoom').click(function () {
                var result = data.run('PlayerCreateRoom', { name: $('#txtNewRoomName').val(), key: $('#txtNewRoomKey').val() });
                if (result != 'RoomCreated')
                    $('#roomNewError').val(result);
                else
                    $('#roomNewError').val('');
                objectCopy(data.run('GetPlayerState'), appData);
                $('#txtNewRoomName').val('');
                $('#txtNewRoomKey').val('');
            });

            $('#btnJoinRoomKey').click(function () {
                result = data.run('PlayerJoinRoom', { key: $('#txtRoomKey').val() });
                if (result != 'RoomJoined')
                    $('#roomJoinError').val(result);
                else
                    $('#roomJoinError').val('');
                objectCopy(data.run('GetPlayerState'), appData);
                $('#txtRoomKey').val('');
            });

            $(document).on('click', '.joinGameButton', function () {
                data.run('PlayerJoinGame', { id: $(this).attr('GameID') });
                objectCopy(data.run('GetPlayerState'), appData);
            });

            $('#btnNewGame').click(function () {
                $('#gameList').hide();
                $('#pnlCreateGame').slideDown();
            });

            $('#btnCancelCreateRoom').click(function () {
                $('#pnlCreateGame').hide();
                $('#gameList').slideDown();
            });

            $('#btnCreateGame').click(function () {
                var result = data.run('NewGame', { name: $('#txtNewGameName').val(), isEpic: false, sbName: $('#txtNewGameSBName').val() });
                if (result != 'RoomCreated')
                    $('#roomNewError').val(result);
                else
                    $('#roomNewError').val('');
                objectCopy(data.run('GetPlayerState'), appData);
                $('#txtNewGameName').val('');
                $('#txtNewGameSBName').val('');
            });
            $('#btnIAmNext').click(function () {
                data.run('IAmNext');
                objectCopy(data.run('GetPlayerState'), appData);
            });
        });

    </script>
                <img src="Images/controllerBG.jpg" id="bg" alt="">
    <div class="mkn" style="text-align:right; height:50px;"><h2><span rv-show="appData.Player.Bank | eq 0" style="font-weight:bold;">&nbsp;</span><span rv-show="appData.playerReady"><span rv-show="appData.Player.Bank | neq 0" style="font-weight:bold;">${appData.Player.Bank}</span></span></h2></div>
    <div class="row" rv-hide="appData.loggedIn">
        <div class="col-xs-12">
            <div id="pnlExistingLogin">
                <div class="row">
                    <div class="col-xs-12 mkn">
                        <label for="txtUserName">User</label>
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-12 mkn" style="text-align:center;">
                        <input id="txtUserName" class="form-control" style="width:100%;" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-12 mkn">
                        <label for="txtPassword">Password</label>
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-12 mkn" style="text-align:center;">
                        <input id="txtPassword" class="form-control" style="width:100%;" />
                    </div>
                </div>
            </div>
            <div id="pnlNewLogin" style="display:none;">
                <div class="row">
                    <div class="col-xs-3 mkn">
                        <label for="txtNewUserName">User Name</label>
                    </div>
                    <div class="col-xs-9">
                        <input id="txtNewUserName" class="form-control" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-3 mkn">
                        <label for="txtNewPassword">Password</label>
                    </div>
                    <div class="col-xs-9">
                        <input id="txtNewPassword" class="form-control" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-3 mkn">
                        <label for="txtFirstName">First</label>
                    </div>
                    <div class="col-xs-9">
                        <input id="txtFirstName" class="form-control" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-3 mkn">
                        <label for="txtLastName">Last</label>
                    </div>
                    <div class="col-xs-9">
                        <input id="txtLastName" class="form-control" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-3 mkn">
                        <label for="txtNickName">Nick</label>
                    </div>
                    <div class="col-xs-9">
                        <input id="txtNickName" class="form-control" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-3 min">
                        <label for="ddlGender">Gender</label>
                    </div>
                    <div class="col-xs-9">
                        <select id="ddlGender" class="form-control">
                            <option value="0">Male</option>
                            <option value="1">Female</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-xs-6 mkn loginButton">            
                    <input id="btnJoinGame" type="button" class="btn mkn btn-xs" value="Login" />
                </div>
                <div class="col-xs-6 mkn loginButton">            
                    <input type="button" class="btn mkn btn-xs toggleNewPlayer" value="New Player" />
                </div>
            </div>
            <div class="row">
                <div class="col-xs-6 mkn loginButton" style="display:none;">            
                    <input id="btnJoinGameNewPlayer" type="button" class="btn mkn btn-xs" value="Join Game" />
                </div>
                <div class="col-xs-6 mkn loginButton" style="display:none;">            
                    <input type="button" class="btn mkn btn-xs toggleNewPlayer" value="Existing Player" />
                </div>
            </div>
            <div class="row">
                <div class="col-xs-12 mkn error" style="color:red;">
                    <h3 id="h3LoginError"></h3>
                </div>
            </div>
        </div>
    </div>
    <div rv-show="appData.loggedIn">
        <div class="row" rv-hide="appData.inRoom">
            <div class="col-xs-12" id="roomList">
                <div class="row" rv-each-room="appData.PlayerRooms">
                    <div class="col-xs-12 mkn">
                        <input type="button" class="roomButton btn mkn btn-xs" rv-RoomID="room | pipeSplit 0" rv-value="room | pipeSplit 1" />
                        <input type="button" class="removeRoomButton btn mkn btn-xs" rv-RoomID="room | pipeSplit 0" rv-value="Remove" />
                    </div>
                </div>
                <hr />
                <div class="row">
                    <div class="col-xs-6 mkn">
                        <input type="button" class="btn mkn btn-xs" id="btnNewRoom" value="New Room" />
                    </div>
                    <div class="col-xs-6 mkn">
                        <input type="button" class="btn mkn btn-xs" id="btnJoinRoom" value="Join Room" />
                    </div>
                </div>
            </div>
            <div id="pnlCreateRoom" style="display:none;">
                <div class="row">
                    <div class="col-xs-4 mkn" style="text-align:right;">
                        <h3>Name:</h3>
                    </div>
                    <div class="col-xs-8 mkn">
                        <input type="text" id="txtNewRoomName" class="form-control" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-4 mkn" style="text-align:right;">
                        <h3>Key:</h3>
                    </div>
                    <div class="col-xs-8 mkn">
                        <input type="text" id="txtNewRoomKey" class="form-control" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-6 mkn">
                        <input type="button" id="btnCancelCreateRoom" class="btn mkn btn-xs" value="Cancel" />
                    </div>
                    <div class="col-xs-6 mkn">
                        <input type="button" id="btnCreateRoom" class="btn mkn btn-xs" value="Create Room" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-12 mkn">
                        <span style="color:red;" id="roomNewError"></span>
                    </div>
                </div>
            </div>
            <div id="pnlJoinRoom" style="display:none;">
                <div class="row">
                    <div class="col-xs-4 mkn" style="text-align:right;">
                        <h3>Key:</h3>
                    </div>
                    <div class="col-xs-8 mkn">
                        <input type="text" id="txtRoomKey" class="form-control" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-6 mkn">
                        <input type="button" id="btnCancelJoinRoom" class="btn mkn btn-xs" value="Cancel" />
                    </div>
                    <div class="col-xs-16 mkn">
                        <input type="button" id="btnJoinRoomKey" class="btn mkn btn-xs" value="Enter Room" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-12 mkn">
                        <span style="color:red;" id="roomJoinError"></span>
                    </div>
                </div>
            </div>
        </div>
        <div rv-show="appData.inRoom">
            <div class="row" rv-hide="appData.inGame">
                <div class="col-xs-12" id="gameList">
                    <div class="row" rv-each-game="appData.AvailableGames">
                        <div class="col-xs-12 mkn">
                            <input type="button" class="joinGameButton btn mkn btn-xs" rv-GameID="game | pipeSplit 0" rv-value="game | pipeSplit 1" />
                        </div>
                    </div>
                    <hr />
                    <div class="row">
                        <div class="col-xs-6 mkn">
                            <input type="button" class="btn mkn btn-xs" id="btnExitRoom" value="Leave Room" />
                        </div>
                        <div class="col-xs-6 mkn">
                            <input type="button" class="btn mkn btn-xs" id="btnNewGame" value="New Game" />
                        </div>
                    </div>
                </div>
                <div id="pnlCreateGame" style="display:none;">
                    <div class="row">
                        <div class="col-xs-4 mkn" style="text-align:right;">
                            <h3>Name:</h3>
                        </div>
                        <div class="col-xs-8 mkn">
                            <input type="text" id="txtNewGameName" class="form-control" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-xs-4 mkn" style="text-align:right;">
                            <h3>Score Board:</h3>
                        </div>
                        <div class="col-xs-8 mkn">
                            <input type="text" id="txtNewGameSBName" class="form-control" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-xs-6 mkn">
                            <input type="button" id="btnCancelCreateGame" class="btn mkn btn-xs" value="Cancel" />
                        </div>
                        <div class="col-xs-6 mkn">
                            <input type="button" id="btnCreateGame" class="btn mkn btn-xs" value="Create Game" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="row" rv-show="appData.inGame">
                <div id="divPlayer">
                    <div class="row">
                        <div class="col-xs-12 mkn">
                            <h1>{appData.DisplayName}</h1>
                        </div>
                    </div>
                    <div class="row" id="pnlAdmin" style="display:none;">
                        <div class="col-xs-6 mkn">
                            <input type="button" id="btnPlayerRotate" class="btn mkn btn-xs" value="Rotate Player" />
                        </div>
                        <div class="col-xs-6 mkn">
                            <input type="button" id="btnPlayerNotPlaying" class="btn mkn btn-xs" value="Leave Game" />
                        </div>
                    </div>
                    <div class="row" rv-hide="appData.IsInBattle">
                        <div class="col-xs-4 mkn" style="border-right:black solid 1px;">
                            <h3>L: {appData.CurrentLevel}</h3>
                        </div>
                        <div class="col-xs-4 mkn" style="border-right:black solid 1px;">
                            <h3>FL: {appData.FightingLevel}</h3>
                        </div>
                        <div class="col-xs-4 mkn">
                            <h3>AL: {appData.AllyLevel}</h3>
                        </div>
                    </div>
                    <div class="row" rv-show="appData.IsInBattle">
                        <div class="col-xs-12" rv-hide="appData.currentBattle.needsOpponent">
                            <div class="row">
                                <div class="col-xs-12 mkn" rv-show="appData.currentBattle.GoodGuysWin">
                                    <h2>Winning</h2>
                                </div>
                                <div class="col-xs-12 mkn" rv-hide="appData.currentBattle.GoodGuysWin">
                                    <h2>Losing</h2>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-xs-4 mkn">
                                    <h2>{appData.currentBattle.playerPoints}</h2>
                                </div>
                                <div class="col-xs-4 mkn" rv-show="appData.currentBattle.GoodGuysWin">
                                    <img src="Images/playerWins.png" style="height:50px;" />
                                </div>
                                <div class="col-xs-4 mkn" rv-hide="appData.currentBattle.GoodGuysWin">
                                    <img src="Images/playerLoses.png" style="height:80px;" />
                                </div>
                                <div class="col-xs-4 mkn">
                                    <h2>{appData.currentBattle.opponentPoints}</h2>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row" id="divScoreBoard" style="display:none;">
                        <div rv-show="appData.playerReady">
                            <div >
                                <div id="divScoreBoardHeader" class="row playerRow">
                                    <div class="col-xs-6 mkn">&nbsp;</div>
                                    <div class="col-xs-2 mkn">
                                        <h3>L</h3>
                                    </div>
                                    <div class="col-xs-2 mkn">
                                        <h3>FL</h3>
                                    </div>
                                    <div class="col-xs-2 mkn">
                                        <h3>AL</h3>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-xs-12 mkn">
                                        <input type="button" id="btnCloseScoreboard" class="btn mkn btn-xs" value="Go Back" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row" id="divPlayerDashboard" rv-hide="appData.IsInBattle">
                        <div class="col-xs-12">
                            <div class="row">
                                <div class="col-xs-4 mkn">
                                    <input type="button" id="btnLevel" class="btn mkn btn-xs" value="Level" />
                                </div>
                                <div class="col-xs-4 mkn">
                                    <input type="button" id="btnGear" class="btn mkn btn-xs" value="Gear" />
                                </div>
                                <div class="col-xs-4 mkn">
                                    <input type="button" id="btnSell" class="btn mkn btn-xs" value="Sell" />
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-xs-6 mkn">
                                    <h3>Race</h3>
                                    <input type="button" id="btnRace" class="btn mkn btn-xs" rv-value="appData.Race" />
                                </div>
                                <div class="col-xs-6 mkn">
                                    <h3>Class</h3>
                                    <input type="button" id="btnClass" class="btn mkn btn-xs" rv-value="appData.Class" />
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-xs-4 mkn">
                                    <input type="button" id="btnSteed" class="btn mkn btn-xs" value="Steed" />
                                </div>
                                <div class="col-xs-4 mkn">
                                    <input type="button" id="btnGender" class="btn mkn btn-xs" rv-value="appData.Gender" />
                                </div>
                                <div class="col-xs-4 mkn">
                                    <input type="button" id="btnHireling" class="btn mkn btn-xs" value="Hireling" />
                                </div>
                            </div>
                            <div class="row" rv-show="appData.myTurn">
                                <div class="col-xs-12">
                                    <input type="button" id="btnBattle" class="btn mkn btn-xs" style="width:100%;" value="Battle!" />
                                </div>
                            </div>
                            <div class="row" rv-show="appData.CanAlly">
                                <div class="col-xs-12">
                                    <input type="button" id="btnAlly" class="btn mkn btn-xs" style="width:100%;" value="Offer to Ally" />
                                </div>
                            </div>
                            <div class="row" rv-show="appData.myTurn">
                                <div class="col-xs-12">
                                    <input type="button" id="btnNextPlayer" class="btn mkn btn-xs" style="width:100%;" value="Next Player" />
                                </div>
                            </div>
                            <div class="row" rv-show="appData.playerReady">
                                <div class="col-xs-12">
                                    <input type="button" id="btnScoreboard" class="btn mkn btn-xs" style="width:100%;" value="Score Board" />
                                </div>
                            </div>
                            <div class="row" rv-show="appData.currentGame.currentState | eq 0">
                                <div class="col-xs-12">
                                    <input type="button" id="btnStartGame" class="btn mkn btn-xs" style="width:100%;" value="Start Game" />
                                </div>
                            </div>
                            <div class="row" rv-show="appData.Player.NeedsASeat">
                                <div class="col-xs-12">
                                    <input type="button" id="btnIAmNext" class="btn mkn btn-xs" style="width:100%;" value="I'm Next!" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row ctrlPanel" id="divCtrlPlayerLevel" style="display:none;">
                        <div class="col-xs-12 mkn" style="vertical-align:middle;">
                            <input type="button" id="btnAddLevel" class="btn mkn btn-xs" style="font-size:25px;" value="+" />
                        </div>
                        <div class="col-xs-12 mkn" style="vertical-align:middle;">
                            <h1>{appData.CurrentLevel}</h1><span style="font-size:20px;">Level</span>
                        </div>
                        <div class="col-xs-12 mkn" style="vertical-align:middle;">
                            <input type="button" id="btnSubtractLevel" class="btn mkn btn-xs" style="font-size:25px;" value="-" />
                        </div>
                        <div class="col-xs-12 mkn" style="vertical-align:middle;">
                            <input type="button" class="btn mkn btn-xs dashboard" value="Done" />
                        </div>
                    </div>
                    <div class="row ctrlPanel" id="divCtrlPlayerGear" style="display:none;">
                        <div class="col-xs-12">
                            <div class="row">
                                <div class="col-xs-4 mkn" >
                                    <input type="button" class="btn mkn btn-xs gearUpdate" amount="1" style="font-size:25px;" value="+1" />
                                </div>
                                <div class="col-xs-4 mkn" >
                                    <input type="button" class="btn mkn btn-xs gearUpdate" amount="2" style="font-size:25px;" value="+2" />
                                </div>
                                <div class="col-xs-4 mkn" >
                                    <input type="button" class="btn mkn btn-xs gearUpdate" amount="5" style="font-size:25px;" value="+5" />
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-xs-12 mkn" style="vertical-align:middle;">
                                    <h1>{appData.GearBonus}</h1><span style="font-size:20px;">Gear Bonus</span>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-xs-4 mkn" >
                                    <input type="button" class="btn mkn btn-xs gearUpdate" amount="-1" style="font-size:25px;" value="-1" />
                                </div>
                                <div class="col-xs-4 mkn" >
                                    <input type="button" class="btn mkn btn-xs gearUpdate" amount="-2" style="font-size:25px;" value="-2" />
                                </div>
                                <div class="col-xs-4 mkn" >
                                    <input type="button" class="btn mkn btn-xs gearUpdate" amount="-5" style="font-size:25px;" value="-5" />
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-xs-12 mkn" >
                                    <input type="button" class="btn mkn btn-xs dashboard" value="Done" />
                                </div>
                            </div>
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
                        <div class="col-xs-12 mkn">
                            <input type="button" id="btnChgRace" class="btn mkn" rv-value="appData.Player.CurrentRaceList.0.Description | test" value="Race" />
                        </div>
                        <div class="col-xs-12 mkn">
                            <input type="button" id="btnHalfBreed" class="btn mkn" rv-value="appData.Player.HalfBreed | ite 'Half-Breed' 'Single Race'" />
                        </div>
                        <div class="col-xs-12 mkn" rv-show="appData.Player.HalfBreed">
                            <input type="button" id="btnChgHBRace" class="btn mkn" rv-value="appData.Player.CurrentRaceList.1.Description" value="Other Race" />
                        </div>
                        <div class="col-xs-12 mkn" >
                            <input type="button" class="btn mkn dashboard" value="Go Back" />
                        </div>
                    </div>
                    <div class="row ctrlPanel" id="divCtrlPlayerClass" style="display:none;">
                        <div class="col-xs-12 mkn">
                            <input type="button" id="btnChgClass" class="btn mkn" rv-value="appData.Player.CurrentClassList.0.Description" ="Class" />
                        </div>
                        <div class="col-xs-12 mkn">
                            <input type="button" id="btnSuperMkn" class="btn mkn" rv-value="appData.Player.SuperMunchkin | ite 'Super Munchkin' 'Single Class'" />
                        </div>
                        <div class="col-xs-12 mkn" rv-show="appData.Player.SuperMunchkin">
                            <input type="button" id="btnChgSMClass" class="btn mkn" rv-value="appData.Player.CurrentClassList.1.Description" value="Other Class" />
                        </div>
                        <div class="col-xs-12 mkn" >
                            <input type="button" class="btn mkn dashboard" value="Go Back" />
                        </div>
                    </div>
                    <div class="row ctrlPanel" id="divCtrlPlayerSteed" style="display:none;">
                        <div class="col-xs-12 mkn">
                            <h2>Steeds</h2>
                        </div>
                        <div class="row">&nbsp;
                        </div>
                        <div class="row" rv-show="appData.HasSteeds | neq true">
                            <div class="col-xs-6 mkn">
                                <h3>No Steeds</h3>
                            </div>
                        </div>
                        <div class="row" rv-each-steed="appData.Steeds">
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
                        <div class="col-xs-6 mkn">
                            <input type="button" class="btn mkn btnAddHelper" helperType="steed" value="Add Steed" />
                        </div>
                        <div class="col-xs-6 mkn">
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
                            <div class="col-xs-2 mkn">
                                <h3>Gear</h3>
                            </div>
                            <div class="col-xs-5 mkn">
                                <h3>Race</h3>
                            </div>
                        </div>
                        <div class="row" rv-show="appData.HasHirelings | neq true">
                            <div class="col-xs-6 mkn">
                                <h3>No Hirelings</h3>
                            </div>
                        </div>
                        <div class="row playerRow" rv-each-hireling="appData.Hirelings">
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
                        <div class="col-xs-6 mkn">
                            <input type="button" class="btn mkn btnAddHelper" helperType="hireling" value="Add Hireling" />
                        </div>
                        <div class="col-xs-6 mkn">
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
                    <div class="row ctrlPanel" id="divCtrlPlayerBattle" rv-show="appData.IsInBattle">
                        <div class="col-xs-12 mkn" rv-show="appData.currentBattle.needsOpponent">
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
                        <div class="col-xs-12 mkn" rv-show="appData.currentBattle.hasOpponent">
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
                                        <h3>{appData.DisplayName}</h3>
                                    </div>
                                    <div class="col-xs-2 mkn">
                                        <h3>+{appData.FightingLevel}</h3>
                                    </div>
                                    <div class="col-xs-2 mkn">
                                        <table><tr>
                                            <td><h3>+</h3></td>
                                            <td><input type="button" class="btn btn-xs mkn gearUpdate" value="G" amount="1" /></td>
                                            <td><input type="button" id="btnAddLevel2" class="btn mkn btn-xs" value="L" /></td>
                                        </tr></table>
                                    </div>
                                </div>
                                <div class="row playerRow" rv-show="appData.currentBattle.HasAlly">
                                    <div class="col-xs-6 mkn">
                                        <input type="button" id="btnRemoveAlly" class="btn btn-xs mkn" rv-value="appData.currentBattle.AllyName" />
                                    </div>
                                    <div class="col-xs-6 mkn">
                                        <h3>+{appData.currentBattle.allyFightingLevel}</h3>
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
                                        <h2>{appData.currentBattle.playerOneTimeBonus}</h2><span style="font-size:20px;">Bonus</span>
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
                                <div class="row playerRow" rv-each-monster="appData.currentBattle.opponents">
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
        </div>
    </div>
</asp:Content>
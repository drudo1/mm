<%@ Page Title="Munchkin Player Controller" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Controller.aspx.cs" Inherits="MunchkinMonitor.Controller" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        var appData = { data: null };
        var helperData = null;
        var monsterData = null;
        var idx = -1;
        var mIdx = -1;
        objPing.UpdateState = function () {
            var getUpdate = false;
            if (appData.data == null) {
                appData.data = data.run('GetPlayerState');
                rivets.bind($(document), { appData: appData });
                getUpdate = false;
            }
            else {
                getUpdate = data.run('CheckForStateUpdate', { lastUpdate: new Date(appData.data.stateUpdatedJS) });
            }

            if (getUpdate) {
                objectCopy(data.run('GetPlayerState'), appData.data);
                if (appData.data.GameResults)
                    window.location = "GameResultsMobile.aspx";
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
                $('.pnlAdmin').show();
                $('#btnPlayerRotate').click(function () {
                    objectCopy(data.run('MakeMeNextPlayer'), appData.data);
                });
                $('#btnPlayerNotPlaying').click(function () {
                    objectCopy(data.run('RemovePlayerFromRotation'), appData.data);
                });
                $('#btnEndGame').click(function () {
                    data.run('EndGame');
                    window.location = "GameResultsMobile.aspx";
                });
                $('#btnTest').click(function () {
                    objectCopy(data.run('Fake'), appData.data);
                });
                $('#btnResetGame').click(function () {
                    objectCopy(data.run('ResetGame'), appData.data);
                });
                $('#btnToggleEpic').click(function () {
                    objectCopy(data.run('ToggleEpic'), appData.data);
                });
            }
            $('#btnJoinGame').click(function () {
                var result = data.run('LoginPlayer', { username: $('#txtUserName').val(), password: $('#txtPassword').val() });
                if (result == "LoggedIn") {
                    $('#h3LoginError').html('');
                    objectCopy(data.run('GetPlayerState'), appData.data);
                    $('#txtUserName').val('');
                    $('#txtPassword').val('');
                }
                else
                    $('#h3LoginError').html('Bad username or password.');
            });
            $('#btnJoinGameNewPlayer').click(function () {
                var result = data.run('LoginNewPlayer', { username: $('#txtNewUserName').val(), password: $('#txtNewPassword').val(), firstName: $('#txtFirstName').val(), lastName: $('#txtLastName').val(), nickName: $('#txtNickName').val(), gender: $('#ddlGender').val() });
                objectCopy(data.run('GetPlayerState'), appData.data);
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
                objectCopy(data.run('AddPlayerLevel'), appData.data.CurrentLevel);
            });
            $('#btnSubtractLevel,#btnSubtractLevel2').click(function () {
                objectCopy(data.run('SubtractPlayerLevel'), appData.data.CurrentLevel);
            });
            $('#btnGear').click(function () {
                $('#divPlayerDashboard').hide();
                $('#divCtrlPlayerGear').slideDown();
            });
            $('.gearUpdate').click(function () {
                var amount = $(this).attr('amount');
                objectCopy(data.run('UpdatePlayerGear', { amount: amount }), appData.data);
            });
            $('#btnSell').click(function () {
                $('#divPlayerDashboard').hide();
                $('#divCtrlPlayerSell').slideDown();
            });
            $('#btnSellItem').click(function () {
                objectCopy(data.run('SellPlayerItem', { amount: $('#txtSaleAmount').val() }), appData.data);
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
                objectCopy(data.run('ChangePlayerGender'), appData.data.Gender);
            });
            $('#btnClass').click(function () {
                $('#divPlayerDashboard').hide();
                $('#divCtrlPlayerClass').slideDown();
            });
            $('#btnChgRace').click(function () {
                objectCopy(data.run('NextPlayerRace'), appData.data.Race);
            });
            $('#btnHalfBreed').click(function () {
                objectCopy(data.run('TogglePlayerHalfBreed'), appData.data.Race);
            });
            $('#btnChgHBRace').click(function () {
                objectCopy(data.run('NextPlayerHalfBreed'), appData.data.Race);
            });
            $('#btnChgClass').click(function () {
                objectCopy(data.run('NextPlayerClass'), appData.data.Class);
            });
            $('#btnSuperMkn').click(function () {
                objectCopy(data.run('TogglePlayerSuperMunchkin'), appData.data.Class);
            });
            $('#btnChgSMClass').click(function () {
                objectCopy(data.run('NextPlayerSMClass'), appData.data.Class);
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
                    helperData = appData.data.Player.Hirelings[idx];
                    rivets.bind($('#divEditHelper'), { helper: helperData });
                }
                else {
                    $('#hdnHelperType').val('steed');
                    helperData = appData.data.Player.Steeds[idx];
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
                objectCopy(data.run('AddPlayerHelper', { steed: steed, bonus: $('#txtHelperBonus').val() }), appData.data.Player);
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
                objectCopy(data.run('ChangePlayerHelperRace', { helperID: $('#hdnHelperID').val() }), helperData.Race);
            });
            $('.hlpGearUpdate').click(function () {
                var amount = $(this).attr('amount');
                objectCopy(data.run('UpdatePlayerHelperGear', { helperID: $('#hdnHelperID').val(), amount: amount }), helperData.GearBonus);
            });
            $('#btnKillHelper').click(function () {
                objectCopy(data.run('KillPlayerHelper', { helperID: $('#hdnHelperID').val() }), appData.data);

                if ($('#hdnHelperType').val() == 'hireling')
                    $('#divHirelings').slideDown();
                else
                    $('#divSteeds').slideDown();
                $('#divAddHelper').slideUp();
                $('#divEditHelper').slideUp();
            });
            $('#btnBattle').click(function () {
                objectCopy(data.run('StartEmptyBattle'), appData.data);
            });
            $('#btnAddFirstMonster').click(function () {
                objectCopy(data.run('AddFirstMonster', { level: $('#txtFirstMonsterLevel').val(), levelsToWin: $('#txtFirstMonsterPrizeLevels').val(), treasures: $('#txtFirstMonsterTreasures').val() }), appData.data.currentBattle);
                $('#txtFirstMonsterLevel').val('');
                $('#txtFirstMonsterPrizeLevels').val('');
                $('#txtFirstMonsterTreasures').val('');
            });
            $('#btnRemoveAlly').click(function () {
                objectCopy(data.run('RemoveAlly'), appData.data.currentBattle);
            });
            $('.BattleBonus').click(function () {
                var amount = $(this).attr('amount');
                objectCopy(data.run('BattleBonus', { amount: amount }), appData.data.currentBattle);
            });
            $(document).on('click', '.monsterButton', function () {
                mIdx = $(this).attr('monsterIDX');
                monsterData = appData.data.currentBattle.opponents[mIdx];
                rivets.bind($('#divMonsterEdit'), { curMonster: monsterData });
                $('#divCtrlPlayerBattle').slideUp();
                $('#divMonsterEdit').slideDown();
            });
            $('#btnAddMonster').click(function () {
                monsterData = data.run('AddMonster', { level: 1, levelsToWin: 1, treasures: 1 });
                rivets.bind($('#divMonsterEdit'), { curMonster: monsterData });
                $('#divCtrlPlayerBattle').slideUp();
                $('#divMonsterEdit').slideDown();
            });
            $('#btnCancelBattle').click(function () {
                objectCopy(data.run('CancelBattle'), appData.data);
            });
            $('#btnResolveBattle').click(function () {
                objectCopy(data.run('ResolveBattle'), appData.data);
                setTimeout(function () {
                    objectCopy(data.run('CompleteBattle'), appData.data);
                }, 30000);
            });
            $('.monsterLevel').click(function () {
                var amount = $(this).attr('amount');
                objectCopy(data.run('UpdateMonsterLevel', { monsterIDX: mIdx, amount: amount }), monsterData);
            });
            $('.monsterBonus').click(function () {
                var amount = $(this).attr('amount');
                objectCopy(data.run('UpdateMonsterBonus', { monsterIDX: mIdx, amount: amount }), monsterData);
            });
            $('.updMonsterLTW').click(function () {
                var amount = $(this).attr('amount');
                objectCopy(data.run('UpdateMonsterLTW', { monsterIDX: mIdx, amount: amount }), monsterData);
            });
            $('.updMonsterTreasure').click(function () {
                var amount = $(this).attr('amount');
                objectCopy(data.run('UpdateMonsterTreasures', { monsterIDX: mIdx, amount: amount }), monsterData);
            });
            $('#btnRemoveMonster').click(function () {
                objectCopy(data.run('RemoveMonster', { monsterIDX: mIdx }), appData.data.currentBattle);
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
                objectCopy(data.run('OfferToAlly', { allyTreasures: $('#txtAllyTreasures').val() }), appData.data);
                $('#divCtrlPlayerAlly').hide();
                $('#txtAllyTreasures').val('');
            });
            $('#btnStartGame').click(function ()  {
                objectCopy(data.run('StartGame'), appData.data);
            });
            $('#btnNextPlayer').click(function () {
                objectCopy(data.run('NextPlayer'), appData.data);
            });
            $('#btnScoreboard').click(function () {
                $('#divScoreBoardHeader').after('<div class="row playerRow playerRowBound" rv-class-selected="player.currentPlayer.PlayerID | isCurrentPlayer2" rv-each-player="appData.data.currentGame.playersOrdered"><div class="col-xs-6 mkn" rv-class-col-xs-12="player.CurrentLevel | lt 1" >&nbsp;&nbsp;{player.currentPlayer.DisplayName}</div><div class="col-xs-2 mkn" rv-class-hide="player.CurrentLevel | lt 1" style="text-align:center" >{player.CurrentLevel}</div><div class="col-xs-2 mkn" rv-class-hide="player.CurrentLevel | lt 1" style="text-align:center" >{player.FightingLevel}</div><div class="col-xs-2 mkn" rv-class-hide="player.CurrentLevel | lt 1" style="text-align:center" >{player.AllyLevel}</div></div>');
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
                objectCopy(data.run('PlayerEnterRoom', { id: $(this).attr('RoomID') }), appData.data);
            });

            $(document).on('click', '.removeRoomButton', function () {
                objectCopy(data.run('PlayerLeaveRoom', { id: $(this).attr('RoomID') }), appData.data);
            });

            $('#btnExitRoom').click(function () {
                objectCopy(data.run('PlayerExitRoom'), appData.data);
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
                objectCopy(data.run('GetPlayerState'), appData.data);
                $('#txtNewRoomName').val('');
                $('#txtNewRoomKey').val('');
            });

            $('#btnJoinRoomKey').click(function () {
                result = data.run('PlayerJoinRoom', { key: $('#txtRoomKey').val() });
                if (result != 'RoomJoined')
                    $('#roomJoinError').val(result);
                else
                    $('#roomJoinError').val('');
                objectCopy(data.run('GetPlayerState'), appData.data);
                $('#txtRoomKey').val('');
            });

            $(document).on('click', '.joinGameButton', function () {
                objectCopy(data.run('PlayerJoinGame', { id: $(this).attr('GameID') }), appData.data);
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
                objectCopy(data.run('GetPlayerState'), appData.data);
                $('#txtNewGameName').val('');
                $('#txtNewGameSBName').val('');
            });
            $('#btnIAmNext').click(function () {
                objectCopy(data.run('IAmNext'), appData.data);
            });

            $(document).on('click', '.offerButton', function () {
                objectCopy(data.run('AddAlly', { allyID: $(this).attr('PlayerID'), allyTreasures: $(this).attr("Treasures") }), appData.data);
            });
            $('#btnAdminPanel').click(function () {
                $('#divPlayerDashboard').hide();
                $('#AdminPanel').slideDown();
            });
            $('#btnCloseAdmin').click(function () {
                $('#divPlayerDashboard').slideDown();
                $('#AdminPanel').hide();
            });
        });

    </script>
                <img src="Images/controllerBG.jpg" id="bg" alt="">
    <div class="mkn" style="text-align:right; height:50px;"><h2><span rv-show="appData.data.inGame"><span rv-show="appData.data.Player.Bank | eq 0" style="font-weight:bold;">&nbsp;</span><span rv-hide="appData.data.IsInBattle"><span rv-show="appData.data.Player.Bank | neq 0" style="font-weight:bold;">${appData.data.Player.Bank}</span></span></span></h2></div>
    <div class="row" rv-hide="appData.data.loggedIn">
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
    <div rv-show="appData.data.loggedIn">
        <div class="row" rv-hide="appData.data.inRoom">
            <div class="col-xs-12" id="roomList">
                <div class="row" rv-each-room="appData.data.PlayerRooms">
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
        <div rv-show="appData.data.inRoom">
            <div class="row" rv-hide="appData.data.inGame">
                <div class="col-xs-12" id="gameList">
                    <div class="row" rv-each-game="appData.data.AvailableGames">
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
            <div class="row" rv-show="appData.data.inGame">
                <div id="divPlayer">
                    <div class="row">
                        <div class="col-xs-12 mkn">
                            <h1>{appData.data.DisplayName}</h1>
                        </div>
                    </div>
                    <div class="row" rv-hide="appData.data.IsInBattle">
                        <div class="col-xs-12">
                            <div class="row" rv-hide="appData.data.showBattleResults">
                                <div class="col-xs-4 mkn" style="border-right:black solid 1px;">
                                    <h3>L: {appData.data.CurrentLevel}</h3>
                                </div>
                                <div class="col-xs-4 mkn" style="border-right:black solid 1px;">
                                    <h3>FL: {appData.data.FightingLevel}</h3>
                                </div>
                                <div class="col-xs-4 mkn">
                                    <h3>AL: {appData.data.AllyLevel}</h3>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="AdminPanel" style="display:none;">
                        <div class="row">
                            <div class="col-xs-6 mkn">
                                <input type="button" id="btnPlayerRotate" class="btn mkn btn-xs" value="Rotate Player" />
                            </div>
                            <div class="col-xs-6 mkn">
                                <input type="button" id="btnPlayerNotPlaying" class="btn mkn btn-xs" value="Leave Game" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-xs-6 mkn">
                                <input type="button" id="btnTest" class="btn mkn btn-xs" value="Test" />
                            </div>
                            <div class="col-xs-6 mkn">
                                <input type="button" id="btnToggleEpic" class="btn mkn btn-xs" value="Toggle Epic" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-xs-6 mkn">
                                <input type="button" id="btnResetGame" class="btn mkn btn-xs" value="Reset Game" />
                            </div>
                            <div class="col-xs-6 mkn">
                                <input type="button" id="btnEndGame" class="btn mkn btn-xs" value="End Game" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-xs-12 mkn">
                                <input type="button" id="btnCloseAdmin" class="btn mkn btn-xs" value="Go Back" />
                            </div>
                        </div>
                    </div>
                    <div class="row" rv-show="appData.data.IsInBattle">
                        <div class="col-xs-12" rv-hide="appData.data.currentBattle.needsOpponent">
                            <div class="row">
                                <div class="col-xs-12 mkn" rv-show="appData.data.currentBattle.GoodGuysWin">
                                    <h2>Winning</h2>
                                </div>
                                <div class="col-xs-12 mkn" rv-hide="appData.data.currentBattle.GoodGuysWin">
                                    <h2>Losing</h2>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-xs-4 mkn">
                                    <h2>{appData.data.currentBattle.playerPoints}</h2>
                                </div>
                                <div class="col-xs-4 mkn" rv-show="appData.data.currentBattle.GoodGuysWin">
                                    <img src="Images/playerWins.png" style="height:50px;" />
                                </div>
                                <div class="col-xs-4 mkn" rv-hide="appData.data.currentBattle.GoodGuysWin">
                                    <img src="Images/playerLoses.png" style="height:80px;" />
                                </div>
                                <div class="col-xs-4 mkn">
                                    <h2>{appData.data.currentBattle.opponentPoints}</h2>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row" id="divScoreBoard" style="display:none;">
                        <div rv-hide="appData.data.IsInBattle">
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
                    <div class="row" id="divPlayerDashboard" rv-hide="appData.data.IsInBattle">
                        <div class="col-xs-12">
                            <div class="row" rv-hide="appData.data.showBattleResults">
                                <div class="col-xs-12">
                                    <div class="row pnlAdmin" style="display:none;">
                                        <div class="col-xs-12 mkn">
                                            <input type="button" id="btnAdminPanel" class="btn mkn btn-xs" value="Admin" />
                                        </div>
                                    </div>
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
                                            <input type="button" id="btnRace" class="btn mkn btn-xs" rv-value="appData.data.Race" />
                                        </div>
                                        <div class="col-xs-6 mkn">
                                            <h3>Class</h3>
                                            <input type="button" id="btnClass" class="btn mkn btn-xs" rv-value="appData.data.Class" />
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-xs-4 mkn">
                                            <input type="button" id="btnSteed" class="btn mkn btn-xs" value="Steed" />
                                        </div>
                                        <div class="col-xs-4 mkn">
                                            <input type="button" id="btnGender" class="btn mkn btn-xs" rv-value="appData.data.Gender" />
                                        </div>
                                        <div class="col-xs-4 mkn">
                                            <input type="button" id="btnHireling" class="btn mkn btn-xs" value="Hireling" />
                                        </div>
                                    </div>
                                    <div class="row" rv-show="appData.data.myTurn">
                                        <div class="col-xs-12">
                                            <input type="button" id="btnBattle" class="btn mkn btn-xs" style="width:100%;" value="Battle!" />
                                        </div>
                                    </div>
                                    <div class="row" rv-show="appData.data.CanAlly">
                                        <div class="col-xs-12">
                                            <input type="button" id="btnAlly" class="btn mkn btn-xs" style="width:100%;" value="Offer to Ally" />
                                        </div>
                                    </div>
                                    <div class="row" rv-show="appData.data.myTurn">
                                        <div class="col-xs-12">
                                            <input type="button" id="btnNextPlayer" class="btn mkn btn-xs" style="width:100%;" value="Next Player" />
                                        </div>
                                    </div>
                                    <div class="row" rv-hide="appData.data.IsInBattle">
                                        <div class="col-xs-12">
                                            <input type="button" id="btnScoreboard" class="btn mkn btn-xs" style="width:100%;" value="Score Board" />
                                        </div>
                                    </div>
                                    <div class="row" rv-show="appData.data.GameNotStarted">
                                        <div class="col-xs-12">
                                            <input type="button" id="btnStartGame" class="btn mkn btn-xs" style="width:100%;" value="Start Game" />
                                        </div>
                                    </div>
                                    <div class="row" rv-show="appData.data.Player.NeedsASeat">
                                        <div class="col-xs-12">
                                            <input type="button" id="btnIAmNext" class="btn mkn btn-xs" style="width:100%;" value="I'm Next!" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row" rv-show="appData.data.showBattleResults">
                                <div class="col-xs-12">
                                    <div class="row">
                                        <div class="col-xs-12 mkn playerRow" style="text-align:center;">
                                            <h1 rv-text="appData.data.currentBattle.result.Message"></h1>
                                        </div>
                                    </div>
                                    <div class="row" >
                                        <div class="col-xs-12 mkn" rv-each-result="appData.data.currentBattle.result.battleResults" style="text-align:center;">
                                            <h2 rv-text="result"></h2>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row ctrlPanel" id="divCtrlPlayerLevel" style="display:none;">
                        <div class="col-xs-12 mkn" style="vertical-align:middle;">
                            <input type="button" id="btnAddLevel" class="btn mkn btn-xs" style="font-size:25px;" value="+" />
                        </div>
                        <div class="col-xs-12 mkn" style="vertical-align:middle;">
                            <h1>{appData.data.CurrentLevel}</h1><span style="font-size:20px;">Level</span>
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
                                    <h1>{appData.data.GearBonus}</h1><span style="font-size:20px;">Gear Bonus</span>
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
                            <input type="button" id="btnChgRace" class="btn mkn" rv-value="appData.data.Player.CurrentRaceList.0.Description | test" value="Race" />
                        </div>
                        <div class="col-xs-12 mkn">
                            <input type="button" id="btnHalfBreed" class="btn mkn" rv-value="appData.data.Player.HalfBreed | ite 'Half-Breed' 'Single Race'" />
                        </div>
                        <div class="col-xs-12 mkn" rv-show="appData.data.Player.HalfBreed">
                            <input type="button" id="btnChgHBRace" class="btn mkn" rv-value="appData.data.Player.CurrentRaceList.1.Description" value="Other Race" />
                        </div>
                        <div class="col-xs-12 mkn" >
                            <input type="button" class="btn mkn dashboard" value="Go Back" />
                        </div>
                    </div>
                    <div class="row ctrlPanel" id="divCtrlPlayerClass" style="display:none;">
                        <div class="col-xs-12 mkn">
                            <input type="button" id="btnChgClass" class="btn mkn" rv-value="appData.data.Player.CurrentClassList.0.Description" ="Class" />
                        </div>
                        <div class="col-xs-12 mkn">
                            <input type="button" id="btnSuperMkn" class="btn mkn" rv-value="appData.data.Player.SuperMunchkin | ite 'Super Munchkin' 'Single Class'" />
                        </div>
                        <div class="col-xs-12 mkn" rv-show="appData.data.Player.SuperMunchkin">
                            <input type="button" id="btnChgSMClass" class="btn mkn" rv-value="appData.data.Player.CurrentClassList.1.Description" value="Other Class" />
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
                        <div class="row" rv-show="appData.data.HasSteeds | neq true">
                            <div class="col-xs-6 mkn">
                                <h3>No Steeds</h3>
                            </div>
                        </div>
                        <div class="row" rv-each-steed="appData.data.Steeds">
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
                        <div class="row" rv-show="appData.data.HasHirelings | neq true">
                            <div class="col-xs-6 mkn">
                                <h3>No Hirelings</h3>
                            </div>
                        </div>
                        <div class="row playerRow" rv-each-hireling="appData.data.Hirelings">
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
                    <div class="row ctrlPanel" id="divCtrlPlayerBattle" rv-show="appData.data.IsInBattle">
                        <div class="col-xs-12 mkn" rv-show="appData.data.currentBattle.needsOpponent">
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
                        <div class="col-xs-12 mkn" rv-show="appData.data.currentBattle.hasOpponent">
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
                                        <h3>{appData.data.DisplayName}</h3>
                                    </div>
                                    <div class="col-xs-2 mkn">
                                        <h3>+{appData.data.FightingLevel}</h3>
                                    </div>
                                    <div class="col-xs-2 mkn">
                                        <table><tr>
                                            <td><h3>+</h3></td>
                                            <td><input type="button" class="btn btn-xs mkn gearUpdate" value="G" amount="1" /></td>
                                            <td><input type="button" id="btnAddLevel2" class="btn mkn btn-xs" value="L" /></td>
                                        </tr></table>
                                    </div>
                                </div>
                                <div class="row playerRow" rv-show="appData.data.currentBattle.HasAlly">
                                    <div class="col-xs-6 mkn">
                                        <input type="button" id="btnRemoveAlly" class="btn btn-xs mkn" rv-value="appData.data.currentBattle.AllyName" />
                                    </div>
                                    <div class="col-xs-6 mkn">
                                        <h3>+{appData.data.currentBattle.allyFightingLevel}</h3>
                                    </div>
                                </div>
                                <div class="row" rv-hide="appData.data.currentBattle.HasAlly">
                                    <div class="col-xs-12 mkn">
                                        <div class="row">
                                            <div class="col-xs-12 mkn">
                                                <h3>Potential Allies</h3>
                                            </div>
                                        </div>
                                        <div class="row" rv-each-offer="appData.data.currentBattle.offers">
                                            <div class="col-xs-6 mkn">
                                                <input type="button" class="btn btn-xs mkn offerButton" rv-value="offer | pipeSplit 1" rv-playerID="offer | pipeSplit 0" rv-Treasures="offer | pipeSplit 2" />
                                            </div>
                                            <div class="col-xs-6 mkn">
                                                Treasures: {offer | pipeSplit 2}
                                            </div>
                                        </div>
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
                                        <h2>{appData.data.currentBattle.playerOneTimeBonus}</h2><span style="font-size:20px;">Bonus</span>
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
                                <div class="row playerRow" rv-each-monster="appData.data.currentBattle.opponents">
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
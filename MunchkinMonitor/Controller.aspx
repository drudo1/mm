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
            $('#btnChgRace').click(function () {
                data.run('NexRace');
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('#btnHalfBreed').click(function () {
                data.run('NextHalfBreed');
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('#btnChgClass').click(function () {
                data.run('NexClass');
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('#btnPrevPlayer').click(function () {
                data.run('PrevPlayer');
                objectCopy(data.run('GetCurrentAppState'), appData);
            });
            $('#btnNextPlayer').click(function () {
                data.run('NextPlayer');
                objectCopy(data.run('GetCurrentAppState'), appData);
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
                <input id="btnSaveNewPlayer" type="button" class="btn mkn" value="Add New Player" />
                <input id="btnCancelNewPlayer" type="button" class="btn mkn" value="Cancel New Player" />
            </div>
        </div>
        <div id="divNotBattle" class="mobile mkn2 mkn" rv-show="appData.gameState.currentState | eq 1">
            <div id="divPlayer">
                <div class="row">
                    <div class="col-xs-12">
                        <h1>{appData.gameState.currentPlayer.currentPlayer.DisplayName}</h1>
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-4">
                        <input type="button" id="btnRace" class="btn mkn" value="Race" />
                    </div>
                    <div class="col-xs-4">
                        <input type="button" id="btnGender" class="btn mkn" value="Gender" />
                    </div>
                    <div class="col-xs-4">
                        <input type="button" id="btnClass" class="btn mkn" value="Class" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-4">
                        <input type="button" id="btnSubtractLevel" class="btn mkn" value="<" />
                    </div>
                    <div class="col-xs-4">
                        <h1>{appData.gameState.currentPlayer.CurrentLevel}</h1>
                    </div>
                    <div class="col-xs-4">
                        <input type="button" id="btnAddLevel" class="btn mkn" value=">" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-4" style="padding-top:10px;">
                        <input type="button" class="btn btn-xs mkn gearUpdate" value="5" amount="-5" />
                        <input type="button" class="btn btn-xs mkn gearUpdate" value="2" amount="-2" />
                        <input type="button" class="btn btn-xs mkn gearUpdate" value="1" amount="-1" />
                    </div>
                    <div class="col-xs-4">
                        <h1>-&nbsp;&nbsp;{appData.gameState.currentPlayer.GearBonus}&nbsp;&nbsp;+</h1>
                    </div>
                    <div class="col-xs-4" style="padding-top:10px;">
                        <input type="button" class="btn btn-xs mkn gearUpdate" value="1" amount="1" />
                        <input type="button" class="btn btn-xs mkn gearUpdate" value="2" amount="2" />
                        <input type="button" class="btn btn-xs mkn gearUpdate" value="5" amount="5" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-4">
                        <input type="button" id="btnPrevPlayer" class="btn mkn" value="Last Player" />
                    </div>
                    <div class="col-xs-4">
                        <input type="button" id="btnBattle" class="btn mkn" value="Battle" />
                    </div>
                    <div class="col-xs-4">
                        <input type="button" id="btnNextPlayer" class="btn mkn" value="Next Player" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-6">
                        <input type="button" id="bthHirelings" class="btn mkn" value="Hirelings" />
                    </div>
                    <div class="col-xs-6">
                        <input type="button" id="btnSteeds" class="btn mkn" value="Steeds" />
                    </div>
                </div>
                <div class="row" id="divRace" style="display:none;">
                    <div class="col-xs-4">
                        <input type="button" id="btnChgRace" class="btn mkn" value="Race" />
                    </div>
                    <div class="col-xs-4">
                        <input type="button" id="btnHalfBreed" class="btn mkn" value="Half Breed" />
                    </div>
                    <div class="col-xs-4">
                        <input type="button" id="btnChgHBRace" class="btn mkn" value="Other Race" />
                    </div>
                </div>
                <div class="row" id="divClass" style="display:none;">
                    <div class="col-xs-4">
                        <input type="button" id="btnChgClass" class="btn mkn" value="Class" />
                    </div>
                    <div class="col-xs-4">
                        <input type="button" id="btnSuperMkn" class="btn mkn" value="Super Mkn" />
                    </div>
                    <div class="col-xs-4">
                        <input type="button" id="btnChgSMClass" class="btn mkn" value="Other Class" />
                    </div>
                </div>
                <div class="row" id="divGender" style="display:none;">
                    <div class="col-xs-6">
                        <input type="text" id="txtGenderPenalty" class="form-control" />
                    </div>
                    <div class="col-xs-6">
                        <input type="button" id="btnChgGender" class="btn mkn" value="Change" />
                    </div>
                </div>
                <div class="row" id="divHirelings" style="display:none;">
                    <div class="col-xs-6">
                        <input type="button" id="btnPrevPlayer" class="btn mkn" value="Last Player" />
                    </div>
                    <div class="col-xs-6">
                        <input type="button" id="btnNextPlayer" class="btn mkn" value="Next Player" />
                    </div>
                </div>
                <div class="row" id="divSteeds" style="display:none;">
                    <div class="col-xs-6">
                        <input type="button" id="btnPrevPlayer" class="btn mkn" value="Last Player" />
                    </div>
                    <div class="col-xs-6">
                        <input type="button" id="btnNextPlayer" class="btn mkn" value="Next Player" />
                    </div>
                </div>
            </div>
            <dialog id="divHelpers" style="display:none;">

            </dialog>
            <div id="divHireling" style="display:none;">

            </div>
            <div id="divSteed" style="display:none;">

            </div>
        </div>
        <div id="divBattle" class="mobile mkn2 mkn" rv-show="appData.gameState.currentState | eq 2">
        </div>
        <div id="divPostBattle" class="mobile mkn2 mkn" rv-show="appData.gameState.currentState | eq 3">
        </div>
    </div>
</asp:Content>

﻿<%@ Page Title="Hall of Fame" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ScoreBoard.aspx.cs" Inherits="MunchkinMonitor.ScoreBoard" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        var appData = null;
        var loggedIn = false;
        var paired = false;
        objPing.UpdateState = function () {
            if(loggedIn) {
                var getUpdate = false;
                if (appData == null) {
                    appData = data.run('GetCurrentRoomState');
                    getUpdate = false;
                }
                else {
                    getUpdate = data.run('CheckForStateUpdate', { lastUpdate: new Date(appData.stateUpdatedJS) });
                }
            
                if (getUpdate) {
                    objectCopy(data.run('GetCurrentRoomState'), appData);
                }
                if (appData.PairedToGame)
                    window.location = "Game.aspx";
            }
        };

        $(document).ready(function() {
            $('#btnJoinRoom').click(function () {
                $('.error').remove();
                var state = data.run('LinkScoreBoardToRoom', { boardName: $('#txtBoardName').val(), roomKey: $('#txtRoomKey').val() });//LoadRoomScoreBoard
                if (state == "LoggedIn") {
                    loggedIn = true;
                }
                else if (state == 'paired') {
                    window.location = "Game.aspx";
                }
                else {
                    $('#divJoinRoom').append('<div class="error mkn" style="color:red;"><h3>' + state + '</h3></div>');
                }

            });
            if (loggedIn) {
                $('#divJoinRoom').hide();
                $('#divJoinRoom').after('<div class="scoreboard" style="display:none;"><table><tr><th>&nbsp;</th><th>Victories</th><th>Kills</th><th>Treasures</th></tr><tr rv-each-player="appData.playerStats.players"><td class="title">{player.DisplayName}</td><td>{player.Victories}</td><td>{player.Kills}</td><td>{player.Treasures}</td></tr></table></div>');
                rivets.bind($(document), { appData: appData });
                $('.scoreboard').slideDown();
            }
        });
    </script>
    <img src="Images/scoreboardBG.jpg" id="bg" alt="">
    <div class="row" id="divJoinRoom">
        <div class="col-lg-12">
            <div class="row">
                <div class="col-lg-6 mkn" style="text-align:right;">
                    Score Board Name:
                </div>
                <div class="col-lg-6 mkn">
                    <input id="txtBoardName" type="text" class="form-control" />
                </div>
            </div>
            <div class="row">
                <div class="col-lg-6 mkn" style="text-align:right;">
                    Room Key:
                </div>
                <div class="col-lg-6 mkn">
                    <input id="txtRoomKey" type="text" class="form-control" />
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12 mkn">
                    <input type="button" id="btnJoinRoom" value="Join Room" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>

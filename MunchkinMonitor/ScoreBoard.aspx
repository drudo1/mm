﻿<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ScoreBoard.aspx.cs" Inherits="MunchkinMonitor.ScoreBoard" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
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
            if (appData.currentStateDescription == "Game")
                window.location = "Game.aspx";
        };
        $(document).ready(function () {
            rivets.bind($(document), { appData: appData });
        })
    </script>
    <div class="jumbotron">
        <h1 rv-text="appData.currentStateDescription"></h1>
    </div>

</asp:Content>

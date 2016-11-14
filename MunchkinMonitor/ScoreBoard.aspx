<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ScoreBoard.aspx.cs" Inherits="MunchkinMonitor.ScoreBoard" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        var currentState;
        objPing.UpdateState = function () {
            var newState = data.run('GetCurrentAppState');
            if (currentState != newState) {
                currentState = newState;
                ScoreBoard.LoadState();
            }
        };
        var ScoreBoard = {
            LoadState: function () {
                $('#lblCurrentState').text(currentState);
            }
        };
    </script>
    <div class="jumbotron">
        <h1><label id="lblCurrentState">test</label></h1>
    </div>

</asp:Content>

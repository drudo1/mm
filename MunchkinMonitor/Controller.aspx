<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Controller.aspx.cs" Inherits="MunchkinMonitor.Controller" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            $('#btnNewGame').click(function () {
                data.run('NewGame', { isEpic: 'false' });
            });
            $('#btnNewEpic').click(function () {
                data.run('NewGame', { isEpic: 'true' });
            });
            $('#btnEndGame').click(function () {
                data.run('EndGame');
            });
        });
    </script>
    <input id="btnNewGame" type="button" value="Start New Game" /><br />
    <input id="btnNewEpic" type="button" value="Start New Epic Game" /><br />
    <input id="btnEndGame" type="button" value="End Game" />
</asp:Content>

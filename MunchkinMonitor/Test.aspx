<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Test.aspx.cs" Inherits="MunchkinMonitor.Test" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script>
        var appData;
        $(document).ready(function () {
            $('#btnTest').click(function () {
                data.run('Fake');
                window.location.href = "Controller.aspx";
            });
            $('#btnResetGame').click(function () {
                data.run('ResetGame');
                window.location.href = "Controller.aspx";
            });
            $('#btnReset').click(function () {
                data.run('Reset');
                window.location.href = "Controller.aspx";
            });
        });
    </script>
    <input type="button" id="btnTest" value="Test Data" />
    <input type="button" id="btnResetGame" value="Reset Game" />
    <input type="button" id="btnReset" value="Reset Stats" />
</asp:Content>

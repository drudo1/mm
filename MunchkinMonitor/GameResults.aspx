<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GameResults.aspx.cs" Inherits="MunchkinMonitor.GameResults" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            setTimeout(function () {
                data.run('Reset');
                window.location = "ScoreBoard.aspx";
            });
        });
    </script>
</asp:Content>

<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GameResults.aspx.cs" Inherits="MunchkinMonitor.GameResults" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        var trophies;
        var appData;
        var curTrophy = -1;
        var trophyTemplate = "<div class='col-lg-12 mkn' id='divTrophy_template' style='background-image: url(Images/Certificate.png); height:100%; padding-top:150px; padding-bottom:200px; padding-left:150px; padding-right:150px; background-size:cover;'><div class='row'><div class='col-lg-12 mkn'><h1 rv-text='trophy.Title'></h1></div><br /><div class='col-lg-12 mkn'><h2>Awarded To:</h2></div><div class='col-lg-12 mkn'><h1 rv-text='trophy.player.DisplayName'></h1></div><br /><div class='col-lg-12 mkn'><h3>For Merits:</h3></div><div class='col-lg-12 mkn'><h3 rv-text='trophy.Reason'></h3></div></div></div>";
        $(document).ready(function () {
            setTimeout(function () {
                data.run('ResetGame');
                window.location = "ScoreBoard.aspx";
            }, 600000);
            trophies = data.run('GetTrophies');
            curTrophy = -1;
            DisplayTrophy((curTrophy + 1) % trophies.length);
            setInterval(function () {
                DisplayTrophy((curTrophy + 1) % trophies.length);
            }, 15000);
        });
        function DisplayTrophy (trophyIdx) {
            if ($('#divTrophy_' + curTrophy).length) {
                $('#divTrophy_' + curTrophy).hide('slide', { direction: 'left' }, 500);
                $('#divTrophy_' + curTrophy).remove();
                $('.ui-effects-placeholder').remove();
            }
            $(trophyTemplate.replace('divTrophy_template', 'divTrophy_' + trophyIdx)).prependTo('#divCurrentTrophy');
            rivets.bind($('#divTrophy_' + trophyIdx), { trophy: trophies[trophyIdx] });
            $('#divTrophy_' + trophyIdx).show('slide', { direction: 'right' }, 500);
            curTrophy = trophyIdx;
        }
    </script>
    <img src="Images/scoreboardBG.jpg" id="bg" alt="">
    <div class="scoreboard">
        <div class="row" id="divCurrentTrophy" style="height:100%;">
        </div>
    </div>
</asp:Content>

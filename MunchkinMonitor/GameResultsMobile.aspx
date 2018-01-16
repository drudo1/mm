<%@ Page Title="Game Results" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GameResultsMobile.aspx.cs" Inherits="MunchkinMonitor.GameResultsMobile" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        var trophies;
        var appData;
        var curTrophy = -1;
        var trophyTemplate = "<div class='col-xs-12 mkn' id='divTrophy_template' style='background-image: url(Images/Certificate.png); height:100%; padding-top:25px; margin-top:90px; padding-left:50px; padding-right:50px; background-size:cover;'><div class='row'><div class='col-xs-12 mkn'><h3 rv-text='trophy.Title'></h3></div><br /><div class='col-xs-12 mkn'><h4>Awarded To:</h4></div><div class='col-xs-12 mkn'><h3 rv-text='trophy.player.DisplayName'></h3></div><div class='col-xs-12 mkn'><h4>For Merits:</h4></div><div class='col-xs-12 mkn'><h4 rv-text='trophy.Reason'></h4></div></div></div>";
        $(document).ready(function () {
            setTimeout(function () {
                data.run('ResetGame');
                window.location = "default.aspx";
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
                $('#divTrophy_' + curTrophy).hide('slide', { direction: 'left' });
                $('#divTrophy_' + curTrophy).remove();
                $('.ui-effects-placeholder').remove();
            }
            $(trophyTemplate.replace('divTrophy_template', 'divTrophy_' + trophyIdx)).prependTo('#divCurrentTrophy');
            rivets.bind($('#divTrophy_' + trophyIdx), { trophy: trophies[trophyIdx] });
            $('#divTrophy_' + trophyIdx).show('slide', { direction: 'right' });
            curTrophy = trophyIdx;
        }
    </script>
    <img src="Images/controllerBG.jpg" id="bg" alt="">
    <div >
        <div class="row" id="divCurrentTrophy" style="height:100%;">
        </div>
    </div>
</asp:Content>

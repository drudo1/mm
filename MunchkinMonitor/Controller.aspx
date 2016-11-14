<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Controller.aspx.cs" Inherits="MunchkinMonitor.Controller" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            $('#btnRotateState').click(function () {
                data.run('RotateState');
            });
        });
    </script>
    <input id="btnRotateState" type="button" value="Rotate State" />
</asp:Content>

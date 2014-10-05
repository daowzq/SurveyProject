<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="test.aspx.cs" Inherits="Aim.Examining.Web.EmpWelfare.test" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script type="text/javascript">

        function onPgLoad() {

            var SearchCriterion = {
                DefaultPageSize: 20,
                AutoOrder: true,
                AllowPaging: true,
                CurrentPageIndex: 1,
                GetRecordCount: true,
                PageCount: 1,
                PageSize: 120,
                RecordCount: 96,
                IsDistinct: false,
                Searches: {
                    Searches: [
                    { PropertyName: "Corp", Value: "昆山飞力", SearchMode: 4 },
                    { PropertyName: "WorkNo", Value: "", SearchMode: 4 },
                    { PropertyName: "UserName", Value: "", SearchMode: 4 },
                    { PropertyName: "JobName", Value: "", SearchMode: 4 },
                    { PropertyName: "WorkAge", Value: "", SearchMode: 4}],
                    FTSearches: [],
                    JuncSearches: [],
                    JunctionMode: 1
                }, Orders: [], QueryFields: []
            }

        }

 
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>

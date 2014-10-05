<%@ Page Title="" Language="C#" MasterPageFile="~/Masters/Ext/Site.Master" AutoEventWireup="true"
    CodeBehind="UsrVoiceBoard.aspx.cs" Inherits="Aim.Examining.Web.EmpUserVoice.UsrVoiceBoard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadHolder" runat="server">
    <style type="text/css">
        body
        {
            background: url(../theme/default/images/public/paperbg.jpg);
        }
    </style>

    <script src="/js/ext/ux/TreePanel.js" type="text/javascript"></script>

    <script type="text/javascript">
        var tree, url = "UsrVoiceBoard.aspx?nodeId=1001";
        var frameUrl = "UsrVoiceDataView.aspx";
        var nodeArr = [];   // 数据节点
        function onPgLoad() {
            setPgUI();
        }
        function setPgUI() {
            var Tree = Ext.tree;
            treeLoader = new Tree.TreeLoader({ dataUrl: url });
            treeLoader.on("load", function(tree, node, response) {
                nodeArr = node.childNodes;
            })

            tree = new Tree.TreePanel({
                region: "west",
                width: 150,
                margins: '0 0 10 0',
                collapsible: true, //允许伸缩  
                border: true,
                useArrows: true,
                autoScroll: true,
                animate: false,
                enableDD: false,
                containerScroll: true,
                root: new Tree.AsyncTreeNode({
                    text: '问题分类',
                    draggable: false,
                    expanded: true,
                    id: '1001'
                }),
                loader: treeLoader
            });

            //root.expand();
            tree.expandAll(); //展开所有节点

            //点击事件
            tree.on('click', treeClick);

            // 页面视图
            viewport = new Ext.ux.AimViewport({
                items: [tree, {
                    region: 'center',
                    margins: '-2 0 0 0',
                    cls: 'empty',
                    bodyStyle: 'background:#f1f1f1',
                    html: '<iframe width="100%" height="100%" id="frameContent" name="frameContent" frameborder="0"></iframe>'
}]
                });

                var interval = window.setInterval(function() {
                    var obj = document.getElementById("frameContent");
                    if (obj) {
                        frameContent.location.href = frameUrl;
                        window.clearInterval(interval);
                    }
                }, 200);


            }

            //点击事件
            function treeClick(node, checked) {
                var nodeName = escape(node.text);
                var url = frameUrl + "?nodeName=" + nodeName;
                frameContent.location.href = url;
            }
            
 
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="BodyHolder" runat="server">
</asp:Content>

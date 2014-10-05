<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Test.aspx.cs" Inherits="Aim.Examining.Web.SurveyManage.Test" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .innerblock
        {
            display: inline-block;
        }
        .innerblock
        {
            display: inline;
        }
        .innerblock_two
        {
            display: inline-block;
        }
    </style>

    <script src="/js/lib/jquery-1.4.2.min.js" type="text/javascript"></script>

    <script type="text/javascript">
        $(function() {
            var numbers = [5, 458, 120, -215, 228, 400, 122205, -85411];
            var maxInNumbers = Math.max.call(Math, numbers);
            var minInNumbers = Math.min.call(Math, numbers);
            //alert("最大的值为:" + maxInNumbers);
            //alert("最小的值为:" + minInNumbers);

            var array1 = [12, "foo", { name: "Joe" }, -2458];
            var array2 = ["Doe", 555, 100];

            //Array.prototype.push.apply(array1, array2);

            // alert(array1.push("Doe", 555, 100));
        })
 
    </script>

</head>
<body>
    <form id="form1" runat="server">
    <table>
        <tr>
            <td class='formCtl'>
                <div style='float: left; width: 5px;'>
                    <span></span>
                </div>
                <div style='float: left; width: 300px;'>
                    <div style="float: right">
                        <div>
                            <input type="button" value="上移" onclick="onSelectedUp(this)" />
                        </div>
                        <div style="margin-top: 20px">
                            <input type="button" value="下移" onclick="onSelectedDown(this)" />
                        </div>
                    </div>
                    <div style="float: left">
                        <select name="sort" size="3" style="width: 100px">
                            <option value="">篮球篮球篮球篮球</option>
                            <option value="">排球</option>
                            <option value="">桌球</option>
                        </select>
                    </div>
                    <div style="width: 50px;">
                    </div>
                </div>
            </td>
        </tr>
    </table>
    <div id="updown">
        <select id="where" name="where" size="5">
            <option value="hk" id="where01">Hong Kong</option>
            <option value="tw" id="where02">Taiwan</option>
            <option value="cn" id="where03">China</option>
            <option value="us" id="where04">United States</option>
            <option value="ca" id="where05">Canada</option>
        </select>
    </div>
    <br />
    <input id="tt" type="TEXT" value="上移" onclick="upSelectedOption()" />
    <input type="button" value="上移" onclick="upSelectedOption()" />
    <input type="button" value="下移" onclick="downSelectedOption()" />
    <input type="button" value="删除" onclick="removeSelectedOption()" />
    <input type="button" value="确定" onclick="getSelectedOption()" />
    <input type="button" value="添加" onclick="addSelectedOption()" />
    </form>
</body>
</html>

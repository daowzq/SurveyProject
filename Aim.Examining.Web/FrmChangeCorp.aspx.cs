using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Common;
using Aim.Security;
using Aim.Portal.Model;

using Aim.Portal.Web.UI;
using System.Data;
using Aim.Data;

namespace Aim.Examining.Web
{
    public partial class FrmChangeCorp : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (RequestActionString == "changeCorp")
            {
                string corpId = RequestData.Get<string>("corpdeptId");

                //验证有没有该公司权限
                //判断登陆人有没有在这个公司
                string sql = @"select count(1) from SysUserGroup where UserId='{0}' and GroupId not in (select RoleId from sysRole) and isnull(outdutydate,'')='' and pk_gw is not null and pk_corp='{1}'";
                int corpcount = DataHelper.QueryValue<int>(string.Format(sql, UserInfo.UserID, corpId));
                if (corpcount == 0 && UserInfo.LoginName != "admin")
                {
                    //查询该人员有没有
                    DataTable dtrole = DataHelper.QueryDataTable("select CompanyIds from sysrole where roleid in ( select RoleID from SysUserRole where UserId='" + UserInfo.UserID + "')");
                    bool hasQX = false;
                    foreach (DataRow row in dtrole.Rows)
                    {
                        if ((row["CompanyIds"] + "").Contains(corpId))
                        {
                            hasQX = true;
                            break;
                        }
                    }
                    if (!hasQX)
                    {
                        PageState.Add("error", "您没有该公司的权限，请重新选择公司！");
                        return;
                    }
                }

                UserContext.ExtData["CompanyId"] = corpId;
                Session["CompanyId"] = corpId;

                //公司
                SysGroup group = SysGroup.TryFind(corpId);
                if (group != null)
                {
                    UserContext.ExtData["CompanyName"] = group.Name;
                }
                else
                {
                    UserContext.ExtData["CompanyName"] = "";
                }
                PageState.Add("corpdeptId", corpId);
                return;
            }
            else
            {
                //查询是不是多公司
                SysUser userent = SysUser.Find(UserInfo.UserID);
                string sql = @"select GroupId,GroupId as corpId, GroupId as corpName, GroupId as deptId, GroupId as deptName from SysUserGroup where UserId='{0}' 
                                   and GroupId not in (select RoleId from sysRole) and isnull(outdutydate,'')='' and pk_gw is not null";
                DataTable dtgroup = DataHelper.QueryDataTable(string.Format(sql, userent.UserID));
                string corpId = "";
                string corpName = "";
                string deptId = "";
                string deptName = "";
                foreach (DataRow row in dtgroup.Rows)
                {
                    corpId = "";
                    corpName = "";
                    deptName = "";
                    deptId = row["GroupId"] + "";
                    getDeptInfo(ref corpId, ref corpName, deptId, ref deptName);
                    row["corpId"] = corpId;
                    row["corpName"] = corpName;
                }
                PageState.Add("gsbms", DataHelper.DataTableToDictList(dtgroup));
                PageState.Add("corpdeptId", UserContext.ExtData["CompanyId"]);

                PageState.Add("gsbms2", DataHelper.QueryDictList("select CompanyIds,CompanyNames from sysRole r inner join sysuserrole ur on ur.roleId=r.roleId where userid='" + UserInfo.UserID + "' and [Type]=4 "));
            }
        }

        private void getDeptInfo(ref string corpId, ref string corpName, string deptId, ref string deptName)
        {
            SysGroup group = SysGroup.TryFind(deptId);
            if (group == null)
            {
                return;
            }
            else if (group.ParentID + "" != "" && !group.Name.Contains("公司"))
            {
                deptName = group.Name + '/' + deptName;
                getDeptInfo(ref corpId, ref corpName, group.ParentID, ref deptName);
            }
            else
            {
                corpId = group.GroupID;
                corpName = group.Name;
                deptName = (group.Name + '/' + deptName).TrimEnd('/');
            }
        }
    }
}

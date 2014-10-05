using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal.Model;

namespace Aim.Examining.Web
{
    public partial class Top : ExamBasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (RequestActionString == "changeCorp")
            {
                string corpdeptId = RequestData.Get<string>("corpdeptId");
                UserContext.ExtData["CompanyId"] = corpdeptId;
                Session["CompanyId"] = corpdeptId;

                //公司
                SysGroup group = SysGroup.TryFind(corpdeptId);
                if (group != null)
                {
                    UserContext.ExtData["CompanyName"] = group.Name;
                }
                else
                {
                    UserContext.ExtData["CompanyName"] = "";
                }
                PageState.Add("corpdeptId", corpdeptId);
                return;
            }

            IEnumerable<SysModule> topAuthExamMdls = new List<SysModule>();
            string appcode = EXAMINING_APP_CODE;
            if (this.Request.QueryString["App"] != null && this.Request.QueryString["App"].Trim() != "")
            {
                appcode = this.Request.QueryString["App"];
            }
            if (UserContext.AccessibleApplications.Count > 0)
            {
                SysApplication examApp = UserContext.AccessibleApplications.FirstOrDefault(tent => tent.Code == appcode);
                if (examApp != null && UserContext.AccessibleModules.Count > 0)
                {
                    topAuthExamMdls = UserContext.AccessibleModules.Where(tent => tent.ApplicationID == examApp.ApplicationID && String.IsNullOrEmpty(tent.ParentID));
                    topAuthExamMdls = topAuthExamMdls.OrderBy(tent => tent.SortIndex);
                }
            }

            //查询是不是多公司
            /*SysUser userent = SysUser.Find(UserInfo.UserID);
            string sql = @"select *, GroupId as corpId, GroupId as corpName, GroupId as deptId, GroupId as deptName from SysUserGroup where UserId='{0}' 
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
            PageState.Add("corpdeptId", Session["CompanyId"]);*/

            if (Session["CompanyId"] == null)
            {
                ClientScript.RegisterClientScriptBlock(this.GetType(), "adsf", "window.parent.location.href='/Login.aspx'", true);
            }
            else
            {
                PageState.Add("CompanyName", SysGroup.Find(Session["CompanyId"]).Name);
            }

            //if (this.Request.QueryString["App"] != null && this.Request.QueryString["App"].Trim() != "")
            //{
            //    appcode = this.Request.QueryString["App"];
            //}
            //IList<SysApplication> saEnts = UserContext.AccessibleApplications.OrderBy(tens => tens.SortIndex).Where(ent => ent.Status == 1).ToArray();
            PageState.Add("Modules", topAuthExamMdls);
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

        protected void lnkRelogin_Click(object sender, EventArgs e)
        {
            Aim.Portal.Web.WebPortalService.LogoutAndRedirect();
        }

    }
}

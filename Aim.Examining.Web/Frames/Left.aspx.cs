using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal.Model;
using Aim.Portal.Web.UI;
using Castle.ActiveRecord;
using NHibernate.Criterion;

namespace Aim.Examining.Web
{
    public partial class Left : ExamBasePage
    {
        private string applicationId = "";
        private string applicationName = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            //防止多次添加
            if (!UserContext.ExtData.ContainsKey("CompanyId"))
            {
                //添加公司Id
                UserContext.ExtData.Add("CompanyId", Session["CompanyId"] + "");
                UserContext.ExtData.Add("DeptId", Session["DeptId"] + "");

                //公司
                SysGroup group = SysGroup.TryFind(Session["CompanyId"] + "");
                if (group != null)
                {
                    UserContext.ExtData.Add("CompanyName", group.Name);
                }
                else
                {
                    UserContext.ExtData.Add("CompanyName", "");
                }
                //部门
                group = SysGroup.TryFind(Session["DeptId"] + "");
                if (group != null)
                {
                    UserContext.ExtData.Add("DeptName", group.Name);
                }
                else
                {
                    UserContext.ExtData.Add("DeptName", "");
                }
            }

            applicationId = RequestData.Get<string>("ApplicationId");
            applicationName = Server.UrlDecode(RequestData.Get<string>("Name"));
            treeContainer.InnerHtml += "<script type='text/javascript'>";
            treeContainer.InnerHtml += " d = new dTree('d');";
            treeContainer.InnerHtml += "d.add('44b87eec-c353-4e98-82aa-4483a3ed86c9', -1, '招聘系统');";
            SysAuthType[] authTypeList = SysAuthTypeRule.FindAll();
            if (this.Request.QueryString["Role"] != null && this.Request.QueryString["Role"] == "User")
            {
                authTypeList = SysAuthType.FindAllByProperties(SysAuthType.Prop_AuthTypeID, 1);//&& tent.ParentID == null
            }

            IList<SysModule> ents = Aim.Portal.PortalService.CurrentUserContext.AccessibleModules.Where(tent => tent.ApplicationID == "f35cb450-cb38-4741-b8d7-9f726094b7ef").ToList();
            if (UserContext.ExtData["CompanyId"] != null)
            {
                IEnumerable<string> mids = ents.Select(en => en.ModuleID);
                if (UserContext.ExtData["CompanyId"] + "" == "")
                {
                    ClientScript.RegisterClientScriptBlock(this.GetType(), "adsf", "window.parent.location.href='/Login.aspx'", true);
                    return;
                }
                SysGroup tGroup = SysGroup.Find(UserContext.ExtData["CompanyId"].ToString());

                string[] groupIDs = (tGroup.Path + "." + tGroup.GroupID).Split('.');
                ICriterion hqlCriterion = Expression.In("GroupID", groupIDs);
                hqlCriterion = SearchHelper.UnionCriterions(hqlCriterion, Expression.Sql("Path like '%" + tGroup.GroupID + "%' and GroupID in (Select GroupID from SysUserGroup where UserID='" + this.UserInfo.UserID + "' or GroupID='" + Session["DeptId"] + "')"));
                SysGroup[] groups = SysGroup.FindAll(hqlCriterion);
                using (new SessionScope())
                {
                    SysUser user = SysUser.Find(this.UserInfo.UserID);
                    SysGroup[] grps = user.AllGroup.Where(en => en.Path != null && en.Path.IndexOf(tGroup.GroupID) >= 0||en.GroupID==tGroup.GroupID).ToArray();
                    foreach (SysGroup group in grps)//groups)
                    {
                        SysGroup groupS = SysGroup.Find(group.ID);
                        foreach (SysAuth tAuth in groupS.Auth)
                        {
                            if (tAuth.ModuleID != null && !mids.Contains(tAuth.ModuleID))
                            {
                                ents.Add(SysModule.Find(tAuth.ModuleID));
                            }
                        }
                    }
                }
            }

            ents = ents.OrderBy(ens => ens.SortIndex).ToList();

            foreach (SysModule smEnt in ents)
            {
                if (!string.IsNullOrEmpty(smEnt.ParentID))
                {
                    treeContainer.InnerHtml += "d.add('" + smEnt.ModuleID + "', '" + smEnt.ParentID + "', '" + smEnt.Name + "','" + smEnt.Url + "', '', 'mainShow');";
                }
                else
                {
                    treeContainer.InnerHtml += "d.add('" + smEnt.ModuleID + "', 'f35cb450-cb38-4741-b8d7-9f726094b7ef', '" + smEnt.Name + "','" + smEnt.Url + "', '', 'mainShow');";
                }
            }
            treeContainer.InnerHtml += "document.write(d);";
            treeContainer.InnerHtml += "$('.dtree > .dTreeNode:first-child').css({ display: 'none' });";
            treeContainer.InnerHtml += "</script>";
        }
    }
}

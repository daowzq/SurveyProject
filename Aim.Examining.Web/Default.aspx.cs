using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Aim.Common;
using Aim.Portal;
using Aim.Portal.Web;
using Aim.Portal.Model;
using Aim.Portal.Web.UI;
using NHibernate.Criterion;
using NHibernate;
using Aim.Data;

namespace Aim.Examining.Web
{
    public partial class Default : ExamBasePage
    {
        string id = string.Empty;
        private IList<SysGroup> sysgroupents = null;
        private IList<SysUser> sysuserents = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            SearchCriterion.DefaultPageSize = 50;
            id = RequestData.Get<string>("id", String.Empty);
            if (Request.QueryString["tag"] != null && Request.QueryString["tag"] == "Refresh")
            {
                Response.Write("");
                Response.End();
            }
            switch (RequestActionString)
            {
                case "querychildren":
                    if (String.IsNullOrEmpty(id))
                    {
                        sysgroupents = SysGroup.FindAll("FROM SysGroup as ent WHERE ParentId is null and (Type = 2 or Type = 3) Order By SortIndex asc");
                    }
                    else
                    {
                        sysgroupents = SysGroup.FindAll("FROM SysGroup as ent WHERE ParentId = '" + id + "' and (Type = 2 or Type = 3) Order By SortIndex asc");
                    }
                    this.PageState.Add("DtList", sysgroupents);
                    break;
                case "treerowselect":
                    using (new Castle.ActiveRecord.SessionScope())
                    {
                        ICriterion cirt = Expression.Sql("UserID IN (SELECT UserID FROM SysUserGroup WHERE GroupID = ?)", id, NHibernateUtil.String);
                        sysuserents = SysUserRule.FindAll(SearchCriterion, cirt);
                    }
                    this.PageState.Add("UsrList", sysuserents);
                    break;
                case "sendmessage":
                    SysMessage ent = new SysMessage();
                    ent.SenderId = UserInfo.UserID;
                    ent.SenderName = UserInfo.Name;
                    ent.ReceiverId = RequestData.Get<string>("ReceiverId");
                    ent.ReceiverName = RequestData.Get<string>("ReceiverName");
                    ent.MessageContent = RequestData.Get<string>("MessageContent");
                    ent.Attachment = RequestData.Get<string>("Attachment");
                    ent.SendTime = System.DateTime.Now;
                    ent.DoCreate();
                    this.PageState.Add("entity", ent);
                    break;
                case "chanagestate":
                    IList<string> idList = RequestData.GetList<string>("IdArray");
                    if (idList != null && idList.Count > 0)
                    {
                        foreach (object obj in idList)
                        {
                            DataHelper.ExecSql("update SysMessage set IsRead='True' where Id='" + obj.ToString() + "'");
                        }
                    }
                    break;
                case "unreadmessage":
                    string receiverId = RequestData.Get<string>("ReceiverId");
                    string sql = string.Empty;
                    if (!string.IsNullOrEmpty(receiverId))
                    {
                        sql = "select * from SysMessage where IsRead is null and ReceiverId='{0}' and SenderId='{1}'order by SendTime asc";
                        sql = string.Format(sql, UserInfo.UserID, receiverId);
                    }
                    else
                    {
                        sql = @"select * from SysMessage where IsRead is null and ReceiverId='{0}' and 
                        SenderId=(select top(1) SenderId from  SysMessage where IsRead is null and ReceiverId='{1}' order by SendTime asc) order by SendTime asc";
                        sql = string.Format(sql, UserInfo.UserID, UserInfo.UserID);
                    }
                    IList<EasyDictionary> dicts = DataHelper.QueryDictList(sql);
                    PageState.Add("unreadmessage", dicts);
                    break;
                default:
                    SysGroup[] grpList = SysGroup.FindAll("From SysGroup as ent where ParentId is null and (Type = 2 or Type = 21) Order By SortIndex, CreateDate Desc");
                    this.PageState.Add("DtList", grpList);
                    break;
            }
            IEnumerable<SysModule> topAuthExamMdls = new List<SysModule>();

            if (UserContext.AccessibleApplications.Count > 0)
            {
                SysApplication examApp = UserContext.AccessibleApplications.FirstOrDefault(tent => tent.Code == EXAMINING_APP_CODE);

                if (examApp != null && UserContext.AccessibleModules.Count > 0)
                {
                    topAuthExamMdls = UserContext.AccessibleModules.Where(tent => tent.ApplicationID == examApp.ApplicationID && String.IsNullOrEmpty(tent.ParentID));
                    topAuthExamMdls = topAuthExamMdls.OrderBy(tent => tent.SortIndex);
                }
            }
            this.PageState.Add("Modules", topAuthExamMdls);
        }

        protected void lnkRelogin_Click(object sender, EventArgs e)
        {
            WebPortalService.LogoutAndRedirect();
        }

        protected void lnkGoodway_Click(object sender, EventArgs e)
        {
            // string passcode = GwIntegrateService.GetGwPasscode();
            string passcode = String.Empty;
            string gwPortalUrl = ConfigurationHosting.SystemConfiguration.AppSettings["GoodwayPortalUrl"];
            gwPortalUrl = String.Format(gwPortalUrl + "?PassCode={0}", passcode);
            Response.Redirect(gwPortalUrl);
        }

        protected void lnkExit_Click(object sender, EventArgs e)
        {
            WebPortalService.Exit();
        }
    }
}

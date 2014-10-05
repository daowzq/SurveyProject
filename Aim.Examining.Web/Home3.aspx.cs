using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Aim.Common;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web.UI;

namespace Aim.Examining.Web
{
    public partial class Home3 : ExamBasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string qryString = "SELECT nt.*, nt.TypeName AS title, ISNULL(n.[Count], 0) AS count FROM NewsType nt LEFT JOIN "
                + "(SELECT TypeId, COUNT(Id) AS [Count] FROM News WHERE ReceiveUserId LIKE '%" + UserInfo.UserID + "%' GROUP BY TypeId) AS n "
                + " ON n.TypeId = nt.Id AND AllowQueryId LIKE '%" + UserInfo.UserID + "%'";

            DataTable dtNews = Aim.Data.DataHelper.QueryDataTable(qryString);

            PageState.Add("News", JsonHelper.GetJsonStringFromDataTable(dtNews));

            int msgCount = Aim.Data.DataHelper.QueryValue<int>("SELECT COUNT(Id) AS count FROM SysMessage WHERE ReceiverName LIKE '%" + UserInfo.UserID + "%'");
            PageState.Add("MsgCount", msgCount);
            GetUserCreateMoudles();
        }

        public void GetUserCreateMoudles()
        {
            IEnumerable<SysModule> topAuthEPCMdls = new List<SysModule>();
            IEnumerable<SysModule> ents = new List<SysModule>();
            if (UserContext.AccessibleApplications.Count > 0)
            {
                SysApplication epcApp = UserContext.AccessibleApplications.First(tent => tent.Code == EXAMINING_APP_CODE);

                if (epcApp != null && UserContext.AccessibleModules.Count > 0)
                {
                    topAuthEPCMdls = UserContext.AccessibleModules.Where(tent => tent.IsQuickCreate == true);
                    topAuthEPCMdls = topAuthEPCMdls.OrderBy(tent => tent.SortIndex);
                    ents = UserContext.AccessibleModules.Where(tent => tent.IsQuickSearch == true)
                        .OrderBy(tent => tent.SortIndex);
                }
            }
            this.PageState.Add("ModulesCreate", topAuthEPCMdls);
            this.PageState.Add("ModulesSearch", ents);
        }
    }
}

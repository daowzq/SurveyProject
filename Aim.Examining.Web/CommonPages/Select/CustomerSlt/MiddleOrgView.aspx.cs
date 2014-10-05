using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Text;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using NHibernate.Criterion;
using System.Data;

namespace Aim.Examining.Web.CommonPages.Select.CustomerSlt
{
    public partial class MiddleOrgView : BaseListPage
    {
        public MiddleOrgView()
        {
            this.IsCheckAuth = false;
            this.IsCheckLogon = false;
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (RequestActionString)
            {
                case "AllCorp":
                    GetAllCorp();
                    break;
            }
        }

        private void GetAllCorp()
        {
            string sql = @"select GroupID,Name from FL_PortalHR..sysgroup  
                          where Type=2 and ParentID='1001' and Name like '%公司%' ";
            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
            this.PageState.Add("EntDic", DataHelper.QueryDictList(sql));
        }
    }
}

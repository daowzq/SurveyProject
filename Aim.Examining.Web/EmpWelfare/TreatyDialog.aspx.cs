using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using System.Data;
using System.Data.OleDb;

namespace Aim.Examining.Web.EmpWelfare
{
    public partial class TreatyDialog : ExamBasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (RequestActionString)
            {
                default:
                    DoSelect();
                    break;
            }
        }


        private void DoSelect()
        {
            string title = RequestData.Get("title") + "";
            if (title.Contains("baoxian"))
            {
                Treaty ty = Treaty.FindFirstByProperties(Treaty.Prop_TreatyKey, "Welfare_One");
                this.PageState.Add("Ent", ty);
            }
        }
    }
}

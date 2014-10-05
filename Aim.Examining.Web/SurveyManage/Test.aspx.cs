using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using System.IO;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using NHibernate.Criterion;
using Aim.Security;
using Aspose.Cells;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class Test : BaseListPage
    {
        public Test()
        {
            this.IsCheckLogon = false;
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            // 012012034
            //var User = SysUser.FindFirstByProperties(SysUser.Prop_WorkNo, "012012034", SysUser.Prop_Status, 1);
            //Response.Write(User.UserID);
        }

        private void Page_Init(object sender, EventArgs e)
        {
 
        }

    }
}

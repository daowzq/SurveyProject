using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Portal.Web.UI;

namespace Aim.Portal.Web.CommonPages
{
    public partial class MUsrSelect : BasePage
    {
        #region 构造函数

        public MUsrSelect()
        {
            IsCheckLogon = false;
        }

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        #endregion
    }
}

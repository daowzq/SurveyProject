using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Web.Script.Serialization;

using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;

namespace Aim.Portal.Web.CommonPages
{
    public partial class GrpCatalog : BaseListPage
    {
        public GrpCatalog()
        {
            IsCheckLogon = false;
        }
        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            SysGroupType[] catalogs = SysGroupType.FindAll("from SysGroupType where GroupTypeID=2");
            this.PageState.Add("DtList", catalogs);
        }

        #endregion
    }
}

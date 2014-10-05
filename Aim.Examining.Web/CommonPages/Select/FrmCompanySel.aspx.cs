using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Examining.Model;
using Aim.Portal.Model;
using Aim.Portal.Web.UI;
using NHibernate.Criterion;

namespace Aim.Examining.Web
{
    public partial class FrmCompanySel : BaseListPage
    {
        public FrmCompanySel()
        {
            base.IsCheckLogon = false;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            SysGroup[] ents = SysGroup.FindAll(SearchCriterion, Expression.Sql("corpCode is not null"));
            this.PageState.Add("DataList", ents);
        }
    }
}


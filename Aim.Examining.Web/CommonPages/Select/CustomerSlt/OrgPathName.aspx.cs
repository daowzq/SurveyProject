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
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using NHibernate.Criterion;
namespace Aim.Examining.Web.CommonPages
{
    public partial class OrgPathName : BaseListPage
    {

        public OrgPathName()
        {
            SearchCriterion.DefaultPageSize = 80;
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            DoSelect();
        }

        private void DoSelect()
        {
            SearchCriterion.SetOrder("SortIndex");
            var ents = Model.ManagementGroup.FindAll(SearchCriterion);
            this.PageState.Add("DataList", ents);

        }

    }
}

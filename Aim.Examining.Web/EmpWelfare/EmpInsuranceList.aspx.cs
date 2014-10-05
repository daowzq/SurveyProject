using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Castle.ActiveRecord;
using NHibernate;
using NHibernate.Criterion;
using Aim.Data;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;
using Aim.Examining.Model;

namespace Aim.Examining.Web
{
    public partial class EmpInsuranceList : ExamListPage
    {
        private IList<EmpInsurance> ents = null;
        EmpInsurance ent = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (RequestActionString)
            {
                case "delete":
                    ent = this.GetTargetData<EmpInsurance>();
                    ent.DoDelete();
                    break;
                default:
                    DoSelect();
                    break;
            }
        }
        private void DoSelect()
        {
            SearchCriterion.AddSearch("CreateId", UserInfo.UserID);
            ents = EmpInsurance.FindAll(SearchCriterion);
            PageState.Add("DataList", ents);
        }
    }
}


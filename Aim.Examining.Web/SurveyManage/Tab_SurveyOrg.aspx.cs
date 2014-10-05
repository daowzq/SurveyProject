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
using System.Data.OleDb;
using System.Data;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class Tab_SurveyOrg : BaseListPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            DoSelect();
        }

        private void DoSelect()
        {
            string SurveyId = RequestData.Get("SurveyId") + "";
            string Group1 = string.Empty;
            string Group2 = string.Empty;

            string SQL = @"select  CB.*  from  FL_Culture..SurveyedObj As A
	                        Cross apply (
	                            select * from  FL_Culture..f_splitstr(A.OrgIds,',')  
	                        ) AS CA      
	                        cross apply (
		                        select Name from  FL_PortalHR..SysGroup where GroupID=CA.F1  
	                        ) As CB
                        where A.SurveyId='{0}'";

            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
            SQL = string.Format(SQL, SurveyId);

            string SQL1 = @"select  CB.*  from  FL_Culture..SurveyedObj As A
	                        Cross apply (
	                            select * from  FL_Culture..f_splitstr(A.OrgIds,',')  
	                        ) AS CA      
	                        cross apply (
		                        select Name from  FL_PortalHR..SysGroup where GroupID=CA.F1  
	                        ) As CB
                        where A.SurveyId='{0}'";

            SQL1 = SQL1.Replace("FL_PortalHR", Global.AimPortalDB);
             
            SQL1 = string.Format(SQL1, SurveyId);

            if (!string.IsNullOrEmpty(SurveyId))
            {
                DataTable dt1 = DataHelper.QueryDataTable(SQL);
                DataTable dt2 = DataHelper.QueryDataTable(SQL1);
                for (int i = 0; i < dt1.Rows.Count; i++)
                {
                    Group1 += dt1.Rows[i][0] + "\r\n";
                }

                for (int i = 0; i < dt2.Rows.Count; i++)
                {
                    Group2 += dt2.Rows[i][0] + "\r\n";
                }
                this.SetFormData(new { SurveyOrgNames = Group1, ViewOrgNames = Group2 });
            }
        }
    }
}

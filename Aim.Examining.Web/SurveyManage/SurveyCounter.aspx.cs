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
    public partial class SurveyCounter : BaseListPage
    {

        string SurveyId = String.Empty;   // 对象id
        protected void Page_Load(object sender, EventArgs e)
        {
            SurveyId = RequestData.Get("SurveyId") + "";
            switch (RequestActionString)
            {
                case "Update":
                    DoSetCounter();
                    break;
                default:
                    GetTotoal();
                    break;
            }

        }

        private void GetTotoal()
        {
            if (!string.IsNullOrEmpty(SurveyId))
            {
                string SQL = @"select EffectiveCount ,(select Count(*) from FL_Culture..SurveyFinallyUsr where SurveyId='{0}') As Total  from   
                            FL_Culture..SurveyQuestion As A  where A.Id='{0}'";
                SQL = string.Format(SQL, SurveyId);

                string Total = string.Empty, EffectiveCount = string.Empty;
                DataTable dt = DataHelper.QueryDataTable(SQL);
                if (dt.Rows.Count > 0)
                {
                    Total = dt.Rows[0]["Total"] + "";
                    EffectiveCount = dt.Rows[0]["EffectiveCount"] + "";
                }

                this.SetFormData(new { Total = Total, EffectiveCount = EffectiveCount });
            }
        }

        /// <summary>
        /// 设置问卷有效数量
        /// </summary>
        private void DoSetCounter()
        {
            string EffectiveCount = RequestData.Get("EffectiveCount") + "";
            if (!string.IsNullOrEmpty(SurveyId) && !string.IsNullOrEmpty(EffectiveCount))
            {
                SurveyQuestion Ent = SurveyQuestion.Find(SurveyId);
                Ent.EffectiveCount = int.Parse(EffectiveCount);
                Ent.DoUpdate();
            }
        }


    }
}

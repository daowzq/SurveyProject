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
    public partial class Wizard_Finish : BaseListPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // 配置生成中
            switch (RequestActionString)
            {
                case "Question":
                    CheckQuestion();
                    break;
                case "Close":
                    break;
                case "IsCreate":
                    IsCreate();
                    break;
                default:
                    // CreateUsr();
                    break;
            }
        }


        private void IsCreate()
        {
            string SurveyId = RequestData.Get("SurveyId") + "";
            string sql = "select count(*) from  FL_Culture..SurveyFinallyUsr where SurveyId='{0}' ";
            sql = string.Format(sql, SurveyId);
            object obj = DataHelper.QueryValue(sql);
            if (obj != null && int.Parse(obj.ToString()) > 0)
            {
                this.PageState.Add("IsCreate", "1");
            }
        }
        /// <summary>
        /// 问卷检查
        /// </summary>
        private void CheckQuestion()
        {
            string SurveyId = RequestData.Get("SurveyId") + "";
            string SQL1 = @"select count(*) from FL_Culture..SurveyFinallyUsr where SurveyId='{0}'
                        and UserId not in ( select top 1 CreateId from FL_Culture..SurveyQuestion where Id='{0}' )";
            SQL1 = string.Format(SQL1, SurveyId);

            string SQL2 = @"select count(*) from  FL_Culture..QuestionItem where SurveyId='{0}' ";  //问卷问题项
            SQL2 = string.Format(SQL2, SurveyId);

            if (!string.IsNullOrEmpty(SurveyId))
            {
                string state = "";
                var ent1 = Convert.ToInt32(DataHelper.QueryValue(SQL1));
                var ent2 = Convert.ToInt32(DataHelper.QueryValue(SQL2));
                if (ent1 == 0)//人员
                {
                    state = "1";
                }
                if (ent2 == 0)//问卷内容
                {
                    state = "2";
                }
                this.PageState.Add("State", state);
            }

        }
    }
}

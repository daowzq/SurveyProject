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

namespace Aim.Examining.Web.SurveyManage
{
    public partial class FilterSatictics_graph : ExamListPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (RequestActionString)
            {
                case "GetItemContent":
                    GetItemContent();
                    break;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        private void GetItemContent()
        {
            string sql = @"	select distinct B.Answer,B.SortIndex  from  FL_Culture..QuestionItem  as A
	                         left join FL_Culture..QuestionAnswerItem As B 
		                         on A.SubItemId=B.QuestionItemId and A.SurveyId=B.SurveyId and A.QuestionType <>'填写项'
	                        where 
		                        Answer is not null and A.surveyId='{0}' and A.Content='{1}' 
                            order by B.SortIndex";

            string surveyId = RequestData.Get("SurveyId") + "";
            string Content = RequestData.Get("Title") + "";
            sql = string.Format(sql, surveyId, Content);
            this.PageState.Add("List", DataHelper.QueryDictList(sql));
        }
    }
}

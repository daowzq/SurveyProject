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
using System.Text;
using System.Data;
using Aim.Examining.Web.Common;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class SurveyStatisticResult : BaseListPage
    {
        string Id = string.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            Id = RequestData.Get<string>("Id");
            if (!string.IsNullOrEmpty(Id))
            {
                this.PageState.Add("SurveyQuestion", SurveyQuestion.Find(Id));
                SurveyStatistic(Id);
            }
        }
        public void SurveyStatistic(string SurveyId)
        {

            //sql = string.Format(sql, SurveyId);
            //权限过滤
            var SEnt = SurveyQuestion.TryFind(SurveyId);
            if (SEnt != null && SEnt.IsFixed == "2")
            {
                CommPowerSplit PS = new CommPowerSplit();
                if (PS.IsHR(UserInfo.UserID, UserInfo.LoginName) || PS.IsAdmin(UserInfo.LoginName) || PS.IsInAdminsRole(UserInfo.UserID))
                {

                }
                else
                {
                    UserContextInfo UC = new UserContextInfo();
                    string SQL = "exec FL_Culture..pro_SummarySurvey_Fix '{0}','{1}' ";
                    SQL = string.Format(SQL, SurveyId, UC.GetUserCurrentCorpId(UserInfo.UserID));
                    this.PageState.Add("DataList", DataHelper.QueryDataTable(SQL));
                    return;
                }
            }

            string sql = "";
            sql = "select * from FL_Culture..SummarySurvey where SurveyId='{0}' order by SortIndex ";
            sql = string.Format(sql, SurveyId);
            var Ents = DataHelper.QueryDataTable(sql);
            if (Ents.Rows.Count != 0)
            {
                this.PageState.Add("DataList", Ents);
            }
            else
            {
                sql = "exec FL_Culture..pro_SummarySurvey '{0}'";
                sql = string.Format(sql, SurveyId);
                Ents = DataHelper.QueryDataTable(sql);
                this.PageState.Add("DataList", Ents);
            }
            //  this.PageState.Add("DataList", Ents);

            //if()



            //sql = @"select *  from FL_Culture..QuestionItem  where SurveyId='{0}' and QuestionType like '%填写项%' ";
            //sql = string.Format(sql, Id);
            //this.PageState.Add("FillQuestion", DataHelper.QueryDictList(sql));
        }


        private void RendSurveryView(string Id)
        {
            IList<QuestionItem> qcEnts = QuestionItem.FindAllByProperties(0, QuestionItem.Prop_SortIndex, QuestionItem.Prop_SurveyId, Id);
            if (qcEnts.Count > 0)
            {
                StringBuilder Stb = new StringBuilder();
                for (int i = 0; i < qcEnts.Count; i++)
                {
                    StringBuilder SubStb = new StringBuilder();
                    IList<QuestionAnswerItem> qiEnts = QuestionAnswerItem.FindAllByProperties(0, QuestionAnswerItem.Prop_SortIndex, QuestionAnswerItem.Prop_QuestionItemId, qcEnts[i].SubItemId);
                    for (int k = 0; k < qiEnts.Count; k++)
                    {
                        if (k > 0) SubStb.Append(",");
                        SubStb.Append(JsonHelper.GetJsonString(qiEnts[k]));
                    }
                    qcEnts[i].SubItems = "[" + SubStb.ToString() + "]";
                    if (i > 0) Stb.Append(",");
                    Stb.Append(JsonHelper.GetJsonString(qcEnts[i]));
                }
                this.PageState.Add("ItemList", "[" + Stb.ToString() + "]");
            }

            string sql = @"select * from FL_Culture..SurveyQuestion where Id='{0}' ";
            this.PageState.Add("Survey", DataHelper.QueryDictList(string.Format(sql, Id)));
        }
    }
}

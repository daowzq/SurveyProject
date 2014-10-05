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
using System.Text;
using System.Data;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class SurveyedHistory_1 : BaseListPage
    {
        SurveyQuestion SqEnt = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            string SurveyId = this.RequestData.Get<string>("SurveyId");
            if (!string.IsNullOrEmpty(RequestData.Get("GetInfo") + "") && RequestData.Get("GetInfo") + "" == "1")
            {
                //var ResultEntList = SurveyedResult.FindAllByProperties(SurveyedResult.Prop_SurveyId, SurveyId, SurveyedResult.Prop_UserId, this.RequestData.Get<string>("UserId") + "");
                DataTable dt = DataHelper.QueryDataTable(" select * from FL_Culture..SurveyedResult where SurveyId='" + SurveyId + "' and UserId='" + this.RequestData.Get<string>("UserId") + "' ");
                this.Response.Write(JsonHelper.GetJsonStringFromDataTable(dt));
                this.Response.End();
            }
            else
            {
                RendSurveryView(SurveyId);
            }
        }

        /// <summary>
        /// 问卷视图呈现
        /// </summary>
        /// <param name="Id"></param>
        private void RendSurveryView(string Id)
        {
            SqEnt = SurveyQuestion.Find(Id);
            IList<QuestionItem> Ents = QuestionItem.FindAllByProperties(0, QuestionItem.Prop_SortIndex, QuestionItem.Prop_SurveyId, Id);
            if (Ents.Count > 0)
            {
                StringBuilder Stb = new StringBuilder();
                for (int i = 0; i < Ents.Count; i++)
                {
                    StringBuilder SubStb = new StringBuilder();
                    IList<QuestionAnswerItem> qiEnts = QuestionAnswerItem.FindAllByProperties(0, QuestionAnswerItem.Prop_SortIndex, QuestionAnswerItem.Prop_SurveyId, Ents[i].SurveyId, QuestionAnswerItem.Prop_QuestionItemId, Ents[i].SubItemId);    //SubItemId
                    //IList<QuestionAnswerItem> qiEnts = QuestionAnswerItem.FindAllByProperties(0, QuestionAnswerItem.Prop_SortIndex, QuestionAnswerItem.Prop_QuestionItemId, Ents[i].SubItemId);    //SubItemId
                    for (int k = 0; k < qiEnts.Count; k++)
                    {
                        if (k > 0) SubStb.Append(",");
                        SubStb.Append(JsonHelper.GetJsonString(qiEnts[k]));
                    }
                    Ents[i].SubItems = "[" + SubStb.ToString() + "]";
                    if (i > 0) Stb.Append(",");
                    Stb.Append(JsonHelper.GetJsonString(Ents[i]));
                }
                this.PageState.Add("ItemList", "[" + Stb.ToString() + "]");
            }

            if (SqEnt != null) this.PageState.Add("Survey", SqEnt);

        }
    }
}

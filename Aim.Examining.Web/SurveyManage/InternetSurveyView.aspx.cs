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
    public partial class InternetSurveyView : BaseListPage
    {
        public string header = string.Empty;
        string Id = string.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            Id = RequestData.Get<string>("SurveyId");
            if (!string.IsNullOrEmpty(Id))
            {
                RendSurveryView(Id);
            }
        }

        /// <summary>
        /// 问卷视图呈现
        /// </summary>
        /// <param name="Id"></param>
        private void RendSurveryView(string Id)
        {
            IList<QuestionItem> Ents = QuestionItem.FindAllByProperties(0, QuestionItem.Prop_SortIndex, QuestionItem.Prop_SurveyId, Id);
            if (Ents.Count > 0)
            {
                StringBuilder Stb = new StringBuilder();
                for (int i = 0; i < Ents.Count; i++)
                {
                    StringBuilder SubStb = new StringBuilder();
                    IList<QuestionAnswerItem> qiEnts = QuestionAnswerItem.FindAllByProperties(0, QuestionAnswerItem.Prop_SortIndex, QuestionAnswerItem.Prop_SurveyId, Ents[i].SurveyId, QuestionAnswerItem.Prop_QuestionItemId, Ents[i].SubItemId);    //SubItemId
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

            SurveyQuestion ent = null;
            if (!string.IsNullOrEmpty(Id))
            {
                ent = SurveyQuestion.Find(Id);
                this.PageState.Add("Survey", ent);
            }

        }
    }
}

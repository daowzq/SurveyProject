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

namespace Aim.Examining.Web.SurveyManage
{
    public partial class Wizard_Four : BaseListPage
    {

        string SurveyId = String.Empty;     // SurveyId

        protected void Page_Load(object sender, EventArgs e)
        {
            SurveyId = RequestData.Get<string>("SurveyId") + "";

            switch (this.RequestActionString)
            {
                case "GetId":
                    QuestionItem qItem = new QuestionItem();
                    qItem.SubItemId = Guid.NewGuid().ToString();
                    qItem.DoCreate();
                    this.PageState.Add("SubItemId", qItem.Id + "|" + qItem.SubItemId);
                    break;
                case "Save":
                    DoSave();
                    break;
                default:
                    DoSelect();
                    break;
            }

        }

        private void DoSelect()
        {
            if (!string.IsNullOrEmpty(SurveyId))
            {
                var Ent = SurveyQuestion.Find(SurveyId);
                if (string.IsNullOrEmpty(Ent.TemplateId))
                {
                    string sql = @"select * from  FL_Culture..QuestionItem where SurveyId='{0}' order by SortIndex ";
                    sql = string.Format(sql, SurveyId);
                    this.PageState.Add("DataList", DataHelper.QueryDictList(sql));
                }
                else
                {
                    //判断是否合并过
                    string SQL = "select * from FL_Culture..QuestionItem where SurveyId='{0}' ";
                    SQL = string.Format(SQL, SurveyId);
                    var Ents = DataHelper.QueryDictList(SQL);
                    if (Ents.Count > 0)
                    {
                        string sql = @"select * from  FL_Culture..QuestionItem where SurveyId='{0}' order by SortIndex ";
                        sql = string.Format(sql, SurveyId);
                        this.PageState.Add("DataList", DataHelper.QueryDictList(sql));
                        //SearchCriterion.SetOrder("SortIndex");
                        //IList<QuestionItem> Items = QuestionItem.FindAll(SearchCriterion, Expression.Sql(" SurveyId='" + SurveyId + "'"));
                        //this.PageState.Add("DataList", Items);
                        return;
                    }

                    //合并模板
                    var TemplateId = Ent.TemplateId;
                    var ItemEnts = QuestionItem.FindAllByProperties(QuestionItem.Prop_SurveyId, TemplateId);
                    var SubItemEnts = QuestionAnswerItem.FindAllByProperties(QuestionAnswerItem.Prop_SurveyId, TemplateId);

                    foreach (var ent in ItemEnts)
                    {
                        QuestionItem Item = new QuestionItem();
                        Item = ent;
                        Item.SurveyId = SurveyId;
                        Item.DoCreate();
                    }
                    foreach (var subEnt in SubItemEnts)
                    {
                        QuestionAnswerItem subItem = new QuestionAnswerItem();
                        subItem = subEnt;
                        subItem.SurveyId = SurveyId;
                        subItem.DoCreate();
                    }

                    SearchCriterion.SetOrder("SortIndex");
                    IList<QuestionItem> items = QuestionItem.FindAll(SearchCriterion, Expression.Sql(" SurveyId='" + SurveyId + "'"));
                    this.PageState.Add("DataList", items);
                }
            }
        }

        private void DoSave()
        {
            string imgItems = RequestData.Get("imgItems") + "";
            string[] ImgArr = imgItems.Split(',');

            if (!string.IsNullOrEmpty(SurveyId))
            {
                IList<string> DataList = RequestData.GetList<string>("data");
                if (DataList.Count > 0)
                {
                    IList<QuestionItem> qiEnts = DataList.Select(tent => JsonHelper.GetObject<QuestionItem>(tent) as QuestionItem).ToArray();
                    foreach (QuestionItem itms in qiEnts)
                    {
                        itms.Content = HttpUtility.UrlDecode(itms.Content);
                        itms.DoSave();
                    }
                }
            }
        }
    }
}

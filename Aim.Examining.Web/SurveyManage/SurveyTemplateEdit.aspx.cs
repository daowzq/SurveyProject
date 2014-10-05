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
using System.Data;
namespace Aim.Examining.Web.SurveyManage
{
    public partial class SurveyTemplateEdit : BaseListPage
    {
        string SurveyId = string.Empty;
        SurveyQuestion ent = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            SurveyId = RequestData.Get<string>("id") + "";

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    DoSave();
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<SurveyQuestion>();
                    ent.DoDelete();
                    return;
                default:
                    if (RequestActionString == "GetId")
                    {
                        QuestionItem qItem = new QuestionItem();
                        qItem.SubItemId = Guid.NewGuid().ToString();
                        qItem.DoCreate();
                        this.PageState.Add("SubItemId", qItem.Id + "|" + qItem.SubItemId);
                    }
                    else if (RequestActionString == "Close")
                    {
                        DoClose();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }
        }


        private void DoSelect()
        {
            if (!string.IsNullOrEmpty(SurveyId))
            {
                ent = SurveyQuestion.Find(SurveyId);
                this.SetFormData(ent);
                string sql = @"select * from  FL_Culture..QuestionItem where SurveyId='{0}' order by SortIndex ";
                sql = string.Format(sql, SurveyId);

                this.PageState.Add("DataList", DataHelper.QueryDictList(sql));
            }
            //else
            //{
            //    string code = "WJ" + DateTime.Now.Year + DateTime.Now.Month + DateTime.Now.Day + DateTime.Now.Minute;
            //    this.SetFormData(new { TypeCode = code });
            //}

        }

        private void DoSave()
        {
            ent = this.GetMergedData<SurveyQuestion>();
            ent.IsFixed = "1";   //1 模板问卷
            ent.DoUpdate();

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


        /// <summary>
        /// 删除操作
        /// </summary>
        private void DoClose()
        {

            if (!string.IsNullOrEmpty(SurveyId))
            {
                //SurveyQuestion Ent = SurveyQuestion.Find(SurveyId);

                string sql = "select * from FL_Culture..SurveyQuestion where Id='{0}' ";
                sql = string.Format(sql, SurveyId);
                DataTable Dt = DataHelper.QueryDataTable(sql);

                if (Dt.Rows.Count > 0 && string.IsNullOrEmpty(Dt.Rows[0]["SurveyTitile"] + ""))
                {
                    string SQL = @"delete from  FL_Culture..QuestionAnswerItem  where Id in
                                    (
                                      select id from  FL_Culture..QuestionAnswerItem As A  where not exists (
	                                    select * from FL_Culture..QuestionItem  As B where B.SubItemId=A.QuestionItemId
                                      )    
                                    ) and SurveyId='{0}' ";
                    SQL += " delete from FL_Culture..QuestionItem where SurveyId='{0}' ";
                    SQL += " delete from FL_Culture..SurveyQuestion where Id='{0}' ";
                    SQL = string.Format(SQL, SurveyId);
                    DataHelper.ExecSql(SQL);
                    // Ent.DoDelete();
                }

            }
        }
    }
}

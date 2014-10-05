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
    public partial class SuryQuestionItemEdit : BaseListPage
    {
        string SurveyId = string.Empty;
        string QuestionItemId = string.Empty;

        protected void Page_Load(object sender, EventArgs e)
        {
            SurveyId = RequestData.Get<string>("SurveyId");
            QuestionItemId = RequestData.Get<string>("QuestionItemId");

            switch (RequestActionString)
            {
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
            if (!string.IsNullOrEmpty(QuestionItemId))
            {
                string sql = @" select * from FL_Culture..QuestionAnswerItem where SurveyId='{0}' and QuestionItemId='{1}' order by SortIndex ";
                sql = string.Format(sql, SurveyId, QuestionItemId);
                this.PageState.Add("DataList", DataHelper.QueryDictList(sql));
            }
        }

        private void DoSave()
        {
            if (!string.IsNullOrEmpty(QuestionItemId))
            {

                var QuestionContent = RequestData.Get("QuestionContent") + "";
                var QuestionType = RequestData.Get("QuestionType") + "";
                var IsMustAnswer = RequestData.Get("IsMustAnswer") + "";
                var IsShowScore = RequestData.Get("IsShowScore") + "";
                var IsComment = RequestData.Get("IsComment") + "";
                var SortIndex = RequestData.Get("SortIndex") + "";
                if (String.IsNullOrEmpty(SortIndex)) SortIndex = "0";

                //更新
                string[] ImgArr = (RequestData.Get("imgItems") + "").Split(',');
                QuestionItem Ent = QuestionItem.FindAllByProperties(QuestionItem.Prop_SurveyId, SurveyId, QuestionItem.Prop_SubItemId, QuestionItemId).FirstOrDefault();
                string[] tempArr = SetImgItem(ImgArr, QuestionItemId);
                Ent.ImgIds = tempArr[0];
                Ent.Ext1 = tempArr[1];

                //Ent.Content = HttpUtility.UrlDecode(QuestionContent);
                //Ent.QuestionType = HttpUtility.UrlDecode(QuestionType);
                //Ent.IsMustAnswer = HttpUtility.UrlDecode(IsMustAnswer);
                //Ent.IsShowScore = HttpUtility.UrlDecode(IsShowScore);
                //Ent.IsComment = HttpUtility.UrlDecode(IsComment);
                //Ent.SortIndex = int.Parse(SortIndex);

                Ent.SurveyId = SurveyId;
                Ent.DoUpdate();

                IList<QuestionAnswerItem> qiEnts = QuestionAnswerItem.FindAllByProperties(QuestionAnswerItem.Prop_QuestionItemId, QuestionItemId, QuestionAnswerItem.Prop_SurveyId, SurveyId);
                foreach (QuestionAnswerItem items in qiEnts)
                {
                    items.DoDelete();
                }

                IList<string> DataList = RequestData.GetList<string>("data");
                if (DataList.Count > 0)
                {
                    qiEnts = DataList.Select(tent => JsonHelper.GetObject<QuestionAnswerItem>(tent) as QuestionAnswerItem).ToArray();
                    foreach (QuestionAnswerItem itms in qiEnts)
                    {
                        itms.DoCreate();
                    }
                }
            }
        }

        //子项创建  ( ,问题项 $图片项  | 图片信息)
        private string[] SetImgItem(string[] ImgArr, string SubItemId)
        {
            string[] arr = new string[2];
            for (int i = 0; i < ImgArr.Length; i++)
            {
                if (ImgArr[i].Contains(SubItemId))  //数据与图片匹配
                {
                    string[] SubImgArr = ImgArr[i].Split('$');
                    for (int j = 0; j < SubImgArr.Length; j++)
                    {
                        //返回图片信息
                        if (j > 0)
                        {
                            arr[0] += ","; arr[1] += ",";
                        }
                        arr[0] += SubImgArr[j].Split('|')[1];
                        arr[1] += SubImgArr[j].Split('|')[2];

                    }

                    break;
                }
            }
            return arr;
        }
    }
}

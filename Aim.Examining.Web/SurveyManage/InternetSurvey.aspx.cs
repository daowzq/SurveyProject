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
    public partial class InternetSurvey : BaseListPage
    {

        string Id = string.Empty;
        string type = string.Empty;   // 是否预览
        //string workNo = string.Empty;  //工号
        SurveyQuestion SqEnt = null;

        public InternetSurvey()
        {
            this.IsCheckAuth = false;
            this.IsCheckLogon = false;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Id = RequestData.Get<string>("Id");
            type = RequestData.Get<string>("type") + "";
            string uid = RequestData.Get("uid") + "";
            SqEnt = SurveyQuestion.Find(Id);
            if (string.IsNullOrEmpty(uid))
            {
                uid = UserInfo.UserID;
            }

            switch (RequestActionString)
            {
                case "Commit":
                    CommitSurvey();
                    break;
                default:
                    if (!string.IsNullOrEmpty(Id))
                    {
                        IsHaveUser(uid);//是否存在该用户
                        Auth(Id, uid);
                        IsPastTime(Id);
                        GetFiles();
                        RendSurveryView(Id);
                    }
                    break;
            }

        }



        /// <summary>
        /// 是否过期判断
        /// </summary>
        private void IsPastTime(string SurveyId)
        {
            //标识补填
            string type = RequestData.Get("type") + "";
            if (type == "add") return;

            string sql = @"select * from  FL_Culture..SurveyQuestion where Id='{0}' ";
            sql = string.Format(sql, SurveyId);
            DataTable dt = DataHelper.QueryDataTable(sql);
            if ((dt.Rows[0]["IsFixed"] + "").Contains("1")) //1 模板
            {
                this.PageState.Add("IsPastTime", "0");
            }
            else
            {
                DateTime EndDte = DateTime.Now;
                if (DateTime.TryParse((dt.Rows[0]["EndTime"] + ""), out EndDte))
                {
                    if (DateTime.Now >= DateTime.Parse((dt.Rows[0]["EndTime"] + "")))
                        this.PageState.Add("IsPastTime", "1");
                    else
                        this.PageState.Add("IsPastTime", "0");
                }
            }

            //问卷暂停
            if ((dt.Rows[0]["State"] + "").Contains("3"))
            {
                this.PageState.Add("IsPause", "1");
            }
        }

        private void CommitSurvey()
        /*存储提交的调查问卷数据*/
        {
            string CommitHistory = this.RequestData.Get<string>("CommitHistory");
            IList<string> list = this.RequestData.GetList<string>("commitArr");

            if (list.Count > 0 && !string.IsNullOrEmpty(CommitHistory))
            {
                IList<SurveyedResult> ents = list.Select(ten => JsonHelper.GetObject<SurveyedResult>(ten) as SurveyedResult).ToArray();
                SurveyCommitHistory shEnt = JsonHelper.GetObject<SurveyCommitHistory>(CommitHistory);

                //回滚数据
                try
                {
                    foreach (var v in ents)
                    {
                        v.DoCreate();
                    }
                }
                catch (Exception ex)
                {
                    string SQL = "delete from FL_Culture..SurveyedResult where SurveyId='{0}' and UserId='{1}' ";
                    SQL = string.Format(SQL, Id, shEnt.SurveyedUserId);
                    DataHelper.ExecSql(SQL);
                    return;
                }

                int totalScore = -1;  //计算总分  -1 表示无分值项
                string SocreInfo = string.Empty;// 分值总分

                var Ents = QuestionAnswerItem.FindAllByProperties(QuestionAnswerItem.Prop_SurveyId, shEnt.SurveyId);
                QuestionAnswerItem[] QArr = Ents.Where(ten => ten.Score.HasValue).ToArray();
                if (QArr.Length > 0)
                {
                    string sql = "select FL_Culture.dbo.f_SumSurveyScore('{0}','{1}') As TotalScore";
                    sql = string.Format(sql, shEnt.SurveyId, shEnt.SurveyedUserId);
                    object obj = DataHelper.QueryValue(sql);

                    int tryVal = 0;
                    if (int.TryParse(obj.ToString(), out tryVal))
                    {
                        tryVal = int.Parse(obj.ToString());
                    }
                    totalScore = tryVal;
                    SocreInfo = GetScoreInfo(shEnt.SurveyId, shEnt.SurveyedUserId);
                }

                //添加积分项  
                SurveyQuestion SQ = SurveyQuestion.Find(shEnt.SurveyId);
                if (SQ.Score.HasValue)
                {
                    SurveyScore Score = new SurveyScore();
                    Score.Score = SQ.Score;
                    Score.Sign = "s";
                    Score.UserID = shEnt.SurveyedUserId;
                    Score.UserName = shEnt.SurveyedUserName;
                    Score.Detail = SQ.SurveyTitile;
                    Score.Ext1 = SQ.Id;//SurveyId
                    Score.DoCreate();
                }

                shEnt.TotalScore = totalScore;
                shEnt.ScoreInfo = SocreInfo;

                shEnt.DoCreate();
            }
        }

        /// <summary>
        /// 状态验证,判断是否提交过
        /// </summary>
        public void Auth(string surveyid, string uid)
        {
            //已提交状态
            string sql_commmit = @"select Id from FL_Culture..SurveyCommitHistory where SurveyId='{0}' and SurveyedUserId='{1}'";
            sql_commmit = string.Format(sql_commmit, surveyid, uid);
            object obj = DataHelper.QueryValue(sql_commmit);
            if (obj != null && type != "read")//read 标识预览
            {
                string url = "SurveyedHistory.aspx?op=v&SurveyId=" + Id + "&UserId=" + uid;
                Response.Redirect(url, true);
                return;
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

        /// <summary>
        /// 获取分值信息
        /// </summary>
        private string GetScoreInfo(string strSurveyId, string strSurveyedUserId)
        {
            string SurveyId = string.IsNullOrEmpty(strSurveyId) ? RequestData.Get("SurveyId") + "" : strSurveyId;
            string SurveyedUserId = string.IsNullOrEmpty(strSurveyedUserId) ? RequestData.Get("SurveyedUserId") + "" : strSurveyedUserId;

            string sql = @"select A.QuestionItem,A.Answer, isnull(A.Score,0) Score 
                            --, sum(isnull(A.Score,0)) OVER() as Total
                           from (
		                        select * from FL_Culture..SurveyedResult
		                        where SurveyId='{0}' and UserId='{1}' and QuestionItemId<>''
	                       ) As T
	                       left join FL_Culture..QuestionAnswerItem AS A
	                         on T.QuestionItemId like '%'+A.Id+'%'";

            string Info = string.Empty;  //score info 
            if (!string.IsNullOrEmpty(SurveyId) && !string.IsNullOrEmpty(SurveyedUserId))
            {
                sql = string.Format(sql, SurveyId, SurveyedUserId);
                DataTable dt = DataHelper.QueryDataTable(sql);

                List<string> StrIndex = new List<string>();
                string str = string.Empty;
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    if (str.Contains(dt.Rows[i]["QuestionItem"].ToString())) continue;
                    str += dt.Rows[i]["QuestionItem"].ToString();
                    StrIndex.Add(dt.Rows[i]["QuestionItem"].ToString());
                }

                for (int i = 0; i < StrIndex.Count; i++)
                {
                    if (i > 0) Info += "$|";
                    Info += StrIndex[i].ToString();
                    DataRow[] rows = dt.Select("QuestionItem = '" + StrIndex[i] + "'");
                    for (int j = 0; j < rows.Length; j++)
                    {
                        Info += "," + rows[j]["Answer"] + " (" + rows[j]["Score"] + " 分)";
                    }
                }

                //Info = (dt.Rows.Count > 0 ? dt.Rows[0]["Total"].ToString() : "0") + "^|^" + Info;

            }
            return Info;
            // this.PageState.Add("ScoreInfo", Info);

        }

        /// <summary>
        /// 是否过期 
        /// </summary>
        /// <returns></returns>
        private void IsExpireDate()
        {
            string SQL = "";

            this.PageState.Add("IsExpire", "");
        }

        /// <summary>
        /// 获取本次问卷的附件
        /// </summary>
        public void GetFiles()
        {
            if (SqEnt != null)
            {
                this.PageState.Add("Files", SqEnt.AddFilesName);
            }
            else
            {
                this.PageState.Add("Files", "");
            }
        }



        //用户名
        public string UserName
        {
            get
            {
                string uid = RequestData.Get("uid") + "";
                if (string.IsNullOrEmpty(uid))
                {
                    uid = UserInfo.UserID;
                }
                var Ent = SysUser.TryFind(uid);
                if (Ent != null)
                {
                    return Ent.Name;
                }
                else
                {
                    return "";
                }
            }
        }
        public string WorkNo
        {
            get
            {
                string uid = RequestData.Get("uid") + "";
                if (string.IsNullOrEmpty(uid))
                {
                    uid = UserInfo.UserID;
                }
                var Ent = SysUser.TryFind(uid);
                if (Ent != null)
                {
                    return Ent.WorkNo;
                }
                else
                {
                    return "";
                }
            }
        }

        //是否有该用户
        private void IsHaveUser(string uid)
        {
            if (SysUser.TryFind(uid) != null)
            {
                this.PageState.Add("IsHaveUser", "1");
            }
        }


    }
}

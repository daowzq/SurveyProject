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

namespace Aim.Examining.Web.EmpUserVoice
{
    public partial class UsrProblemSolve : ExamListPage
    {
        string Question = string.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            Question = this.RequestData.Get("id") + "";
            switch (RequestActionString)
            {
                case "Reply":
                    DoRepply();
                    break;
                case "GetCommentPg":
                    GetCommentPg();
                    break;
                case "GetReplyPg":
                    GetReplyPg();
                    break;
                case "RendReply"://默认回复
                    GetDefaultReply();
                    break;
                default:
                    DoSelect();
                    break;

            }
        }

        //回复分页
        private void GetReplyPg()
        {
            string AnswerId = RequestData.Get("AnswerId") + "";
            string CurrentPg = RequestData.Get("CurrentPg") + "";

            string SQL = "select * from  FL_Culture..EmpVoiceAnswerInfo where  ParentId='{0}' and ( IsCheck='1' or IsCheck is null )";
            SQL = string.Format(SQL, AnswerId);
            if (int.Parse(CurrentPg) > 0)
            {
                int currentPg = int.Parse(CurrentPg);
                int start = (currentPg - 1) * 5 + 1;
                int end = currentPg * 5;
                IList<EasyDictionary> Ents = GegPgComment(SQL, start, end);
                this.PageState.Add("ReplyEnts", Ents);
            }
        }

        /// <summary>
        /// 评论分页
        /// </summary>
        private void GetCommentPg()
        {
            string QuestionId = RequestData.Get("QuestionId") + "";
            string CurrentPg = RequestData.Get("CurrentPg") + "";
            string SQL = "select * from  FL_Culture..EmpVoiceAnswerInfo where  QuestionId='{0}' and ( IsCheck='1' or IsCheck is null  ) ";
            SQL = string.Format(SQL, QuestionId);
            if (int.Parse(CurrentPg) > 0)
            {
                int currentPg = int.Parse(CurrentPg);
                int start = (currentPg - 1) * 10 + 1;
                int end = currentPg * 10;
                IList<EasyDictionary> Ents = GegPgComment(SQL, start, end);
                this.PageState.Add("CommentEnts", Ents);
            }

        }

        /// <summary>
        /// 默认回复数据
        /// </summary>
        private void GetDefaultReply()
        {
            string AnswerId = this.RequestData.Get("AnswerId") + "";

            string SQL = @"select top 5 * from  FL_Culture..EmpVoiceAnswerInfo where  ParentId='{0}' and (IsCheck='1' or IsCheck is null ) 
                           order by CreateTime desc ";

            SQL = string.Format(SQL, AnswerId);
            IList<EasyDictionary> Ents = DataHelper.QueryDictList(SQL);
            this.PageState.Add("ReplyEnt", Ents);
        }

        //提交回复
        private void DoRepply()
        {
            string ReplyId = RequestData.Get("ReplyId") + "";
            string Content = RequestData.Get("Content") + "";
            string NikeName = UserInfo.Name + "";

            //var Ent = EmpVoiceAnswerInfo.Find(ReplyId);
            //if (Ent != null)
            //{

            EmpVoiceAskQuestion empQusert = EmpVoiceAskQuestion.Find(ReplyId);
           
            empQusert.AnswerCount = empQusert.AnswerCount.GetValueOrDefault() + 1;

            empQusert.Update();
         //   DataHelper.ExecSql("update FL_Culture..EmpVoiceAskQuestion set AnswerCount='" + empQusert.AnswerCount + "' where id='" + empQusert.Id + "'");

            EmpVoiceAnswerInfo SubEnt = new EmpVoiceAnswerInfo();
            //  SubEnt.ParentId = Ent.Id;
            SubEnt.Answer = Content;
            SubEnt.NikeName = NikeName;
            SubEnt.CreateId = UserInfo.UserID;
            SubEnt.QuestionId = ReplyId;

            SubEnt.DoCreate();

            //Ent.ReplyCount = Ent.ReplyCount.GetValueOrDefault() + 1;
            //if (!string.IsNullOrEmpty(Ent.NoReaderItem))
            //{
            //    Ent.NoReaderItem += "," + SubEnt.Id;
            //}
            //Ent.DoUpdate();
            this.PageState.Add("AnserId", SubEnt.Id);
            //  }

        }

        private void DoSelect()
        {
            //问题浏览项次数+1 
            string UpdateSql = "update FL_Culture..EmpVoiceAskQuestion set ViewCount=ViewCount+1 where Id='{0}' ";
            UpdateSql = string.Format(UpdateSql, Question);
            DataHelper.ExecSql(UpdateSql);

            //
            if (string.IsNullOrEmpty(Question)) return;
            string SQL = @"select A.Id, A.Contents,A.Title,A.Anonymity,A.Category,A.AnswerCount,A.ViewCount,A.NikeName,A.IsCheck,A.CreateTime,A.AcceptAnswerId,
                            B.Id as A_Id, B.Answer,B.Anonymity As A_Anonymity,B.ParentId,B.IsLeaf,B.IsCheck As A_IsCheck,B.NikeName As A_NikeName,
                            B.ReplyCount, B.CreateTime As A_CreateTime
                          from FL_Culture..EmpVoiceAskQuestion  As A  
                            left join  FL_Culture..EmpVoiceAnswerInfo  As B 
                           on A.AcceptAnswerId=B.Id where A.Id='{0}' ";
            SQL = string.Format(SQL, Question);
            EasyDictionary EDic = DataHelper.QueryDictList(SQL).FirstOrDefault();
            this.SetFormData(EDic);

            SQL = @"select  *  from  FL_Culture..EmpVoiceAnswerInfo  where QuestionId='{0}' and ( IsCheck='1' or IsCheck is null) ";
            SQL = string.Format(SQL, Question);
            this.PageState.Add("Comment", GegPgComment(SQL, 1, 10));

            //添加用户基本信息
            string UserInfoSQL = @"select A.UserID ,A.Name As UserName,B.Nickname
                                   from  FL_PortalHR..SysUser  As A
	                                    left join  FL_Culture..EmpVoiceMyBaseInfo  As B 
                                    on A.UserID=B.UserID
	                                    where A.UserID='{0}'";
            UserInfoSQL = UserInfoSQL.Replace("FL_PortalHR", Global.AimPortalDB);
            UserInfoSQL = string.Format(UserInfoSQL, UserInfo.UserID);
            var Ent = DataHelper.QueryDictList(UserInfoSQL);
            this.PageState.Add("UserInfoEnt", Ent);
        }

        private IList<EasyDictionary> GegPgComment(string SQL, int startNum, int EndNum)
        {
            string order = "CreateTime";
            string asc = "desc";
            string pageSql = @"WITH OrderedOrders AS
		                        (SELECT *,
		                        ROW_NUMBER() OVER (order by {0} {1})as RowNumber
		                        FROM ({2}) temp ) 
		                        SELECT * 
		                        FROM OrderedOrders 
		                        WHERE RowNumber between {3} and {4}";

            pageSql = string.Format(pageSql, order, asc, SQL, startNum, EndNum);
            IList<EasyDictionary> dicts = DataHelper.QueryDictList(pageSql);
            return dicts;
        }



    }
}

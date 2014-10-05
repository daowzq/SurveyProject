using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Aim.Data;
using System.Data;
using System.Collections;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Examining.Model;
using NHibernate.Criterion;
using System.Data.SqlClient;

namespace Aim.CommonLib
{
    public class SurveyRemind
    {

        //连接字符串
        private static readonly string ConStr = "";
        //URL
        private static readonly string URL = "";

        /// <summary>
        /// 获取提醒时间点
        /// </summary>
        /// <returns></returns>
        public static RemindEnt[] GetRemindTimes()
        {

            RemindEnt[] Ents = null;
            string SQL = @"select Id,SetTimeout from 
                            FL_Culture..SurveyQuestion where IsFixed='0' and WorkFlowState='End' and getdate()<= EndTime ";
            SqlConnection conn = new SqlConnection(ConStr);
            DataTable SuryDt = DataHelper.QueryDataTable(SQL, conn);
            if (SuryDt.Rows.Count > 0)
            {
                Ents = new RemindEnt[SuryDt.Rows.Count];
                for (int i = 0; i < SuryDt.Rows.Count; i++)
                {
                    Ents[i].SurveyId = SuryDt.Rows[i]["Id"].ToString();
                    Ents[i].TimeOut = SuryDt.Rows[i]["SetTimeout"].ToString();
                }

                return Ents;
            }
            else
            {
                return null;
            }
        }

        /// <summary>
        /// 执行的主方法
        /// </summary>
        /// <returns></returns>
        public static string DoRepeatRemind(string SurveyId, DateTime dte)
        {

            string SQL = "select * from  FL_Culture..SurveyQuestion where Id='{0}'";
            SQL = string.Format(SQL, SurveyId);
            DataTable SQDt = DataHelper.QueryDataTable(SQL);

            SQL = @"select
                        B.UserId,B.Name,B.Email, B.Phone ,B.WorkNo
                   from  FL_Culture..SurveyFinallyUsr As A
                         left join  FL_PortalHR..SysUser As B
                            on A.UserId=B.UserId
                   where  A.SurveyId='{0}' and  (B.Outdutydate is null or B.Outdutydate='' )and 
                        not exists
                        (
                          select * from  FL_Culture..SurveyCommitHistory As T where T.SurveyId='{0}'
                           and 	T.SurveyedUserId=A.UserId  
                        ) ";
            SQL = string.Format(SQL, SurveyId);
            DataTable UsrDt = DataHelper.QueryDataTable(SQL);

            if (SQDt.Rows.Count > 0 && UsrDt.Rows.Count > 0)
            {
                SendNotice(UsrDt, SQDt.Rows[0]["NoticeWay"].ToString(), SQDt.Rows[0]["SurveyTitile"].ToString(), SurveyId, SQDt.Rows[0]["EndTime"].ToString(), URL);
            }

            return "1";
        }

        /// <summary>
        /// 发送通知
        /// </summary>
        /// <param name="dt">User DataTable</param>
        /// <param name="NoticeType">提醒方式</param>
        /// <param name="Title">标题</param>
        /// <param name="SurveyId">问卷SurveyId</param>
        /// <param name="EndTime">截止时间</param>
        private static void SendNotice(DataTable dt, string NoticeType, string Title, string SurveyId, string EndTime, string Url)
        {
            string SurveyUrl = Url;
            string content = @"您好！<br/>     此邮件来自江苏飞力达[企业文化系统]的友情提醒 。
                                     <br/>     您有一份 [{0}] 调查问卷, 问卷截止时间：{1}, 请点击链接或登陆系统及时填写,谢谢配合！
                               <br/> 打开此链接可填写： {2} ";

            string sql = @"insert into FL_Recruitment..Remind
                            (Id,Name,Phone,EmailAddress,RemindContent,RemindTime,SendType,Ext1,CreateTime,state,PhoneState,Title)
                            values(newid(),'{0}','{1}','{2}','{3}','{4}','{5}','{6}',getdate(),'{7}','{8}','{9}')";
            //发送方式
            string Email_SG = string.Empty;
            string Message = string.Empty;
            if (NoticeType.Contains("邮件") || NoticeType.Contains("Email")) Email_SG = "0";
            else if (NoticeType.Contains("短信") || NoticeType.Contains("Message")) Message = "0";

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                string Email = dt.Rows[i]["Email"].ToString();  //电子邮件
                string Phone = dt.Rows[i]["Phone"].ToString();  //手机号
                string UserId = dt.Rows[i]["UserId"].ToString();
                string Name = dt.Rows[i]["Name"].ToString();
                string WorkNo = dt.Rows[i]["WorkNo"].ToString();
                string UrlName = HttpUtility.UrlEncode(Name);

                //URL and content
                string fmt = "?Id={0}&op=r&uid={1}&uname={2}&workno={3}";
                fmt = string.Format(fmt, SurveyId, UserId, UrlName, WorkNo);
                string url = SurveyUrl + fmt;
                var txt = string.Format(content, Title, EndTime, url);

                string RemindTime = DateTime.Now.AddMinutes(i).ToString("yyyy-MM-dd HH:mm:ss");   //发送提醒时间

                string InsertSql = string.Format(sql, Name, Phone, Email, txt, RemindTime, NoticeType, "S" + "|" + SurveyId,
    Email_SG, Message, "调查问卷提醒 [" + Title + "]");

                SqlConnection conn = new SqlConnection(ConStr);
                DataHelper.ExecSql(InsertSql, conn);
            }

        }
    }

    public class RemindEnt
    {
        public string SurveyId { get; set; }
        public string TimeOut { get; set; }
    }
}

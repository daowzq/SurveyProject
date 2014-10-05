using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Aim.Data;
using System.Data;
using Aim.Examining.Model;
using System.Configuration;
using System.IO;

namespace Aim.Examining.Web
{
    public class StartSurveyQuestion
    {
        /// <summary>
        /// 问卷相关配置项启动 是否定时发送
        /// </summary>
        /// <returns></returns>
        public bool SurveyQuestionStart(SurveyQuestion Ent)
        {
            if (Ent != null && Ent.State == "0")   //0 表示创建
            {
                string SurveyId = Ent.Id;
                string Title = Ent.SurveyTitile;

                //启动随机推送
                if (Ent.IsSendRandom == "1" && Ent.EffectiveCount.HasValue)
                {
                    int? EffectiveCount = Ent.EffectiveCount;    //实际有效数量*   包涵只有工号情况 ActualSurveyed='1'  
                    string SQL = @"update FL_Culture..SurveyFinallyUsr  set ActualSurveyed='1' where Id in (
                                   select top {1} Id from FL_Culture..SurveyFinallyUsr where SurveyId='{0}' order by newid() )";
                    SQL = string.Format(SQL, SurveyId, EffectiveCount);
                    DataHelper.ExecSql(SQL);
                }
                else
                {
                    string SQL = @"update FL_Culture..SurveyFinallyUsr set ActualSurveyed='1' where SurveyId='{0}'";
                    SQL = string.Format(SQL, SurveyId);
                    DataHelper.ExecSql(SQL);
                }

                //通知方式  
                string NoticeType = Ent.NoticeWay;

                //send user
                string tempSQL = @"select distinct B.*  from FL_Culture..SurveyFinallyUsr  As A
                                     left join FL_PortalHR..SysUser  As B
                                     on A.UserId=B.UserID 
                                     where A.ActualSurveyed='1' and A.SurveyId='{0}'  ";
                tempSQL = tempSQL.Replace("FL_PortalHR", Global.AimPortalDB);
                tempSQL = string.Format(tempSQL, SurveyId);
                DataTable dt = DataHelper.QueryDataTable(tempSQL);

                SendNotice(dt, NoticeType, Ent.SurveyTitile, Ent.Id, Ent.StartTime.GetValueOrDefault().ToString("yyyy-MM-dd"), Ent.EndTime.GetValueOrDefault().ToString("yyyy-MM-dd"), Ent.Description);
            }
            return true;

        }


        /// <summary> DescRipt 描述
        /// 发送通知
        /// </summary>
        /// <param name="dt">User DataTable</param>
        /// <param name="NoticeType">提醒方式</param>
        /// <param name="Title">标题</param>
        /// <param name="SurveyId">问卷SurveyId</param>
        /// <param name="EndTime">截止时间</param>
        private void SendNotice(DataTable dt, string NoticeType, string Title, string SurveyId, string StartTime, string EndTime, string DescRipt)
        {
            string SurveyUrl = ConfigurationManager.AppSettings["SurveyUrl"].ToString();
            string SurveyUrl_bak = ConfigurationManager.AppSettings["SurveyUrl_bak"].ToString();

            //            string content = @"您好！<br/> 此邮件来自江苏飞力达(调查问卷)的友情提醒 。
            //                                     <br/>您有一份 [{0}] 调查问卷, 问卷截止时间：{1}, 请点击链接或登陆系统及时填写,谢谢配合！
            //                               <br/> 打开此链接可填写： {2} ";

            string content = @" {0}
                               <br/>打开此链接可直接填写问卷：<br/> {1} </br>如不能打开上述链接，请复制链接地址到浏览器中打开。</br>请勿回复此邮件!";
            string MessageContent = @"{1},您好! \r\n 此短信来自江苏飞力达[问卷调查]提醒 。您有一份 [{0}] 调查问卷,请及时登陆系统填写或可查看邮件进行处理。谢谢！{2}";

            string sql = @"insert into FL_Recruitment..Remind
                            (Id,Name,Phone,EmailAddress,RemindContent,RemindTime,SendType,Ext1,CreateTime,state,PhoneState,Title,MessageContent,UserId)
                            values(newid(),'{0}','{1}','{2}','{3}','{4}','{5}','{6}',getdate(),'{7}','{8}','{9}','{10}','{11}')";
            sql = sql.Replace("FL_Recruitment", Global.FL_Recruitment);

            //发送方式
            string Email_SG = string.Empty;
            string Message = string.Empty;
            if (NoticeType.Contains("邮件") || NoticeType.Contains("Email")) Email_SG = "0";
            if (NoticeType.Contains("短信") || NoticeType.Contains("Message")) Message = "0";


            for (int i = 0; i < dt.Rows.Count; i++)
            {
                string Email = dt.Rows[i]["Email"].ToString();  //电子邮件
                string Phone = dt.Rows[i]["Phone"].ToString();  //手机号
                string UserId = dt.Rows[i]["UserId"] + "";
                string Name = dt.Rows[i]["Name"].ToString();
                string WorkNo = dt.Rows[i]["WorkNo"].ToString();
                string UrlName = HttpUtility.UrlEncodeUnicode(Name);  //*

                //URL and content
                //string fmt = "?Id={0}&uid={1}&uname={2}&workno={3}&op=r";
                //fmt = string.Format(fmt, SurveyId, UserId, UrlName, WorkNo);
                //string fmt = "?Id={0}&uid={1}&op=r";

                //string url = SurveyUrl + string.Format("?Id={0}&uid={1}&op=r", SurveyId, UserId);
                //url += @"<br/>  如果您处在公网环境中,请使用下面链接地址:<br/> " + SurveyUrl_bak + string.Format("?Id={0}&uid={1}&op=r", SurveyId, UserId);
                //var txt = string.Format(content, DescRipt, url);

                //2014-2-13
                string EncryUid = WebSecurity.EncryptorEencrypt.Des3EncrypStrForHtml(WorkNo);
                string url = SurveyUrl + string.Format("?Id={0}&uid={1}&op=r", SurveyId, EncryUid);
                url += @" <br/>  如果您处在公网环境中,请使用下面链接地址:<br/> " + SurveyUrl_bak + string.Format("?Id={0}&uid={1}&op=r", SurveyId, EncryUid);
                // DescRipt.Replace("'", "''") 2014 7 16 修复SQL语句生成bug
                var txt = string.Format(content, DescRipt.Replace("'", "''"), url);

                //message content
                string MsgCont = string.Empty;
                if (Message == "0")
                {
                    string msgUrl = url.Replace("<br/>", "     \r\n");
                    MsgCont = string.Format(MessageContent, Title, Name, msgUrl);
                }

                //提醒时间
                string RemindTime = string.Empty;
                if (DateTime.Now.ToString("yyyy-MM-dd").Trim() == StartTime.Trim())  //当天
                {
                    //210s 处理服务器间的时间差异
                    RemindTime = DateTime.Now.AddSeconds(210).ToString("yyyy-MM-dd HH:mm:ss");   //发送提醒时间 1s 排队
                }
                else if (!string.IsNullOrEmpty(StartTime) && !string.IsNullOrEmpty(EndTime) && DateTime.Now >= DateTime.Parse(StartTime) && DateTime.Now <= DateTime.Parse(EndTime))
                {
                    RemindTime = DateTime.Now.AddSeconds(210).ToString("yyyy-MM-dd HH:mm:ss");   //发送提醒时间 1s 排队
                }
                else  //提前情况
                {
                    RemindTime = DateTime.Parse(StartTime.Trim() + " 09:30").AddSeconds(i).ToString("yyyy-MM-dd HH:mm:ss");
                }

                string InsertSql = string.Empty;
                try
                {
                    InsertSql = string.Format(sql, Name, Phone, Email, txt, RemindTime, NoticeType, "S|" + SurveyId,
  Email_SG, Message, Title, MsgCont, UserId);
                    DataHelper.ExecSql(InsertSql);
                }
                catch (Exception ex)
                {
                    throw new Exception("问卷启用异常:\r\n" + InsertSql);
                    WritterLog("---------\r\n" + DateTime.Now + "\r\n" + InsertSql + "|" + ex.StackTrace);
                    string exSQL = "insert into FL_PortalHR..SysEvent(UserID,Type,Record,DateTime) values('{0}','问卷通知异常','{1}',getdate())";
                    exSQL = string.Format(exSQL, UserId, ex.StackTrace);
                    exSQL = exSQL.Replace("FL_PortalHR", Global.AimPortalDB);
                    DataHelper.ExecSql(exSQL);
                }
            }

        }

        /// <summary>
        /// 发送通知(催办)
        /// </summary>
        /// <param name="dt">User DataTable</param>
        /// <param name="NoticeType">提醒方式</param>
        /// <param name="Title">标题</param>
        /// <param name="SurveyId">问卷SurveyId</param>
        /// <param name="EndTime">截止时间</param>
        public void SendNotice_Nosubmit(Aim.Portal.Model.SysUser UsrEnt, string NoticeType, string Title, string SurveyId, string StartTime, string EndTime, string DescRipt)
        {
            string SurveyUrl = ConfigurationManager.AppSettings["SurveyUrl"].ToString();
            string SurveyUrl_bak = ConfigurationManager.AppSettings["SurveyUrl_bak"].ToString();

            string content = @" {0}
                               <br/>点击此链接可直接填写问卷：<br/> {1} </br>如不能打开上述链接，请复制链接地址到浏览器中打开。</br>请勿回复此邮件!";

            string MessageContent = @"{1},您好! \r\n 此短信来自江苏飞力达[问卷调查]提醒 。您有一份 [{0}] 调查问卷,请及时登陆系统填写或可查看邮件进行处理。谢谢！{2}";

            string sql = @"insert into FL_Recruitment..Remind
                            (Id,Name,Phone,EmailAddress,RemindContent,RemindTime,SendType,Ext1,CreateTime,state,PhoneState,Title,MessageContent,UserId)
                            values(newid(),'{0}','{1}','{2}','{3}','{4}','{5}','{6}',getdate(),'{7}','{8}','{9}','{10}','{11}')";
            sql = sql.Replace("FL_Recruitment", Global.FL_Recruitment);

            //发送方式
            string Email_SG = string.Empty;
            string Message = string.Empty;
            if (NoticeType.Contains("邮件") || NoticeType.Contains("Email")) Email_SG = "0";
            if (NoticeType.Contains("短信") || NoticeType.Contains("Message")) Message = "0";


            string Email = UsrEnt.Email + "";  //电子邮件
            string Phone = UsrEnt.Phone + "";  //手机号
            string UserId = UsrEnt.UserID + "";
            string Name = UsrEnt.Name;
            string WorkNo = UsrEnt.WorkNo.ToString();
            string UrlName = HttpUtility.UrlEncodeUnicode(Name);  //*

            //URL and content
            string txt = string.Empty, MesgUrl = string.Empty;
            if (Email_SG == "0")
            {
                //string fmt = "?Id={0}&op=r&uid={1}&uname={2}&workno={3}";
                //fmt = string.Format(fmt, SurveyId, UserId, UrlName, WorkNo);
                //string fmt = "?Id={0}&uid={1}&op=r";
                //fmt = string.Format(fmt, SurveyId, UserId);
                //string url = SurveyUrl + fmt;

                //string url = SurveyUrl + string.Format("?Id={0}&uid={1}&op=r", SurveyId, UserId);
                //url += @"<br/>  如果您处在公网环境中,请使用下面链接地址:<br/> " + SurveyUrl_bak + string.Format("?Id={0}&uid={1}&op=r", SurveyId, UserId);
                //MesgUrl = url;
                //txt = string.Format(content, DescRipt, url);

                //2014-2-13
                string EncryUid = WebSecurity.EncryptorEencrypt.Des3EncrypStrForHtml(WorkNo);
                string url = SurveyUrl + string.Format("?Id={0}&uid={1}&op=r", SurveyId, EncryUid);
                url += @" <br/>  如果您处在公网环境中,请使用下面链接地址:<br/> " + SurveyUrl_bak + string.Format("?Id={0}&uid={1}&op=r", SurveyId, EncryUid);
                MesgUrl = url;
                //DescRipt.Replace("'", "''")  替换为了避免SQL语句拼接错误bug
                txt = string.Format(content, (DescRipt + "").Replace("'", "''"), url);
            }

            //message content
            string MsgCont = string.Empty;
            if (Message == "0")
            {
                MesgUrl = MesgUrl.Replace("<br/>", "     \r\n");
                MsgCont = string.Format(MessageContent, Title, Name, MesgUrl);
            }

            //提醒时间
            string RemindTime = string.Empty;
            if (Message == "0") //短信
            {
                RemindTime = DateTime.Now.AddSeconds(20).ToString("yyyy-MM-dd HH:mm:ss");  //add 2s
            }
            else   //Email
            {
                RemindTime = DateTime.Now.AddSeconds(2).ToString("yyyy-MM-dd HH:mm:ss");  //add 2s
            }


            string InsertSql = string.Empty;

            try
            {
                InsertSql = string.Format(sql, Name, Phone, Email, txt, RemindTime, NoticeType, "S_Nosubmit|" + SurveyId,
Email_SG, Message, Title, MsgCont, UserId);
                DataHelper.ExecSql(InsertSql);
            }
            catch (Exception ex)
            {
                throw new Exception("执行异常:\r\n" + InsertSql);
                WritterLog("---------\r\n" + DateTime.Now + "\r\n" + InsertSql + "|" + ex.StackTrace);
                string exSQL = "insert into FL_PortalHR..SysEvent(UserID,Type,Record,DateTime) values('{0}','问卷通知异常','{1}',getdate())";
                exSQL = string.Format(exSQL, UserId, ex.StackTrace);
                exSQL = exSQL.Replace("FL_PortalHR", Global.AimPortalDB);
                DataHelper.ExecSql(exSQL);
            }

        }


        /// <summary>
        /// 写日志
        /// </summary>
        /// <param name="log"></param>
        private void WritterLog(string log)
        {

            string pt = HttpContext.Current.Server.MapPath("/");
            FileStream fs = new FileStream(pt + "\\" + DateTime.Now.ToString("yyyyMMdd") + "log.txt", FileMode.OpenOrCreate, FileAccess.Write);
            StreamWriter m_streamWriter = new StreamWriter(fs);
            m_streamWriter.BaseStream.Seek(0, SeekOrigin.End);
            m_streamWriter.WriteLine(log);
            m_streamWriter.Flush();
            m_streamWriter.Close();
            fs.Close();
        }

    }
}

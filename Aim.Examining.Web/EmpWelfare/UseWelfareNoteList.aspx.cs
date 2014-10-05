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
using System.Data;
using System.Configuration;
using Aim.Examining.Web.Common;

namespace Aim.Examining.Web
{
    public partial class UseWelfareNoteList : ExamListPage
    {

        private IList<UseWelfareNote> ents = null;
        private readonly string HostUrl = ConfigurationManager.AppSettings["SurveyUrl"].ToString().Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries)[1];
        protected void Page_Load(object sender, EventArgs e)
        {
            UseWelfareNote ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<UseWelfareNote>();
                    ent.DoDelete();
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        DoBatchDelete();
                    }
                    else if (RequestActionString == "Publish")
                    {
                        DoPublish();
                    }
                    else if (RequestActionString == "Undo")
                    {
                        Undo();
                    }
                    else if (RequestActionString == "GetApprove")
                    {
                        GetApproveUser();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }

        }

        /// <summary>
        /// 发起通知
        /// </summary>
        private void DoPublish()
        {
            string Id = RequestData.Get("Id") + "";
            if (!String.IsNullOrEmpty(Id))
            {
                UseWelfareNote Ent = UseWelfareNote.Find(Id);
                Ent.State = "1";   //1 发起
                if (!string.IsNullOrEmpty(Ent.DeptId))
                {
                    SendNotices(Ent);
                }
                Ent.DoUpdate();
            }
        }


        private void SendNotices(UseWelfareNote Ent)
        {
            string IP = HostUrl;
            string wherPat = "";
            string content = @"您好！
                                    <br/> 此邮件来自江苏飞力达[企业文化系统]的友情提醒 。
                                    <br/> 请根据 您有一份 [{0}] 福利申报通知,开始时间：{3}, 截止时间：{1}。 
                                    <br/> {4}
                                    <br/> 请点击链接或登陆系统及时填写,谢谢配合！ 
                                    <br/> 打开此链接可填写： {2} ";

            string MsgContent = @"{3},您好！
                                    <br/> 此短信来自江苏飞力达[企业文化系统]的友情提醒 。
                                    <br/> 请根据 您有一份 [{0}] 福利申报通知,开始时间：{1}, 截止时间：{2}。
                                    <br/> 请查看邮件或登陆系统及时处理,谢谢配合！ ";

            string content1 = @"您好！
                                    <br/> 此邮件来自江苏飞力达[企业文化系统]的友情提醒 。
                                    <br/> 请根据 您有一份 [{0}] 福利申报通知,开始时间：{1}, 截止时间：{2}。 
                                        <br/> 请登陆系统及时填写,谢谢配合！ ";

            string MsgContent1 = @"{3},您好！
                                    <br/> 此短信来自江苏飞力达[企业文化系统]的友情提醒 。
                                    <br/> 请根据 您有一份 [{0}] 福利申报通知,开始时间：{1}, 截止时间：{2}。
                                    <br/> 请查看登陆系统及时处理,谢谢配合！ ";

            string[] Patid = Ent.DeptId.Split(',');
            for (int i = 0; i < Patid.Length; i++)
            {
                if (i == (Patid.Length - 1))
                    wherPat += " Path like '%" + Patid[i] + "%'";
                else
                    wherPat += " Path like '%" + Patid[i] + "%' or";
            }

            string sql = @" select * from  SysUser where  UserID IN 
                            (SELECT UserID FROM FL_PortalHR..SysUserGroup 
                                WHERE GroupID in (select GroupID from FL_PortalHR..SysGroup where {0})
                            )  and Status=1 and len(Outdutydate)=0 ";
            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
            sql = string.Format(sql, wherPat);
            DataTable dt = DataHelper.QueryDataTable(sql);


            int index = 0;
            foreach (DataRow dr in dt.Rows)
            {
                string NoticeTxt = string.Empty;
                string msgtxt = string.Empty;

                if (Ent.TypeName == "员工旅游")
                {
                    string url = "http://" + IP + "/EmpWelfare/UsrTravelWelfareEdit.aspx?op=c&userid=" + dr["UserId"] + "&noticeid=" + Ent.Id;
                    NoticeTxt = string.Format(content, Ent.Title, Ent.EndTime, url, Ent.StartTime, Ent.Condition);
                    //短信内容
                    msgtxt = string.Format(MsgContent, Ent.Title, Ent.StartTime, Ent.EndTime, dr["Name"].ToString());
                }
                else if (Ent.TypeName.Contains("保险"))
                {
                    NoticeTxt = string.Format(content1, Ent.Title, Ent.StartTime, Ent.EndTime);
                    //短信内容
                    msgtxt = string.Format(MsgContent1, Ent.Title, Ent.StartTime, Ent.EndTime, dr["Name"].ToString());
                }

                string email = string.Empty, phone = string.Empty;
                if (Ent.NoticeWay.IndexOf("Email") != -1) email = "0";
                if (Ent.NoticeWay.IndexOf("Message") != -1) phone = "0";

                //提醒时间
                string RemindDte = string.Empty;
                if (DateTime.Now.ToString("yyyy-MM-dd").Trim() == Ent.StartTime.GetValueOrDefault().ToString("yyyy-MM-dd"))  //当天
                {
                    RemindDte = DateTime.Now.AddSeconds(1).ToString("yyyy-MM-dd HH:mm:ss");   //发送提醒时间 1s
                }
                else  //提前情况
                {
                    RemindDte = DateTime.Parse(Ent.StartTime.GetValueOrDefault().ToString("yyyy-MM-dd") + " 09:30").AddSeconds(index).ToString("yyyy-MM-dd HH:mm:ss");
                }


                string tempSql = @"insert into FL_Recruitment..Remind (ID,UserId,Name,Phone,EmailAddress,RemindContent,State,PhoneState,EXT1,Title,attachment,RemindTime,createTime,MessageContent)
                                 values('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}','{13}')";
                tempSql = string.Format(tempSql, Guid.NewGuid().ToString(), dr["UserId"].ToString(), dr["Name"].ToString(), dr["Phone"].ToString(), dr["Email"].ToString(), NoticeTxt, email, phone, "N|" + dr["UserId"].ToString(), Ent.Title, Ent.AddFiles, RemindDte, DateTime.Now, msgtxt);

                try
                {
                    DataHelper.ExecSql(tempSql);
                }
                catch (Exception ex)
                {
                    throw new Exception(ex.Message + "|" + ex.StackTrace + "|" + tempSql);
                }
                index++;
            }
        }
        /// <summary>
        /// 撤销通知
        /// </summary>
        private void Undo()
        {
            string Id = RequestData.Get("Id") + "";
            if (!String.IsNullOrEmpty(Id))
            {
                UseWelfareNote Ent = UseWelfareNote.Find(Id);
                Ent.State = "2";   //2 撤销
                Ent.DoUpdate();
            }
        }

        #region 私有方法

        /// <summary>
        /// 查询
        /// </summary>
        private void DoSelect()
        {

            var UserEnt = SysUser.Find(UserInfo.UserID);
            string CorpIds = string.Empty;

            CommPowerSplit ps = new CommPowerSplit();
            if (ps.IsNoticeRole(UserInfo.UserID, UserInfo.LoginName))
            {
                ents = UseWelfareNote.FindAll(SearchCriterion);
            }
            else
            {
                // 判断公司登陆
                UserContextInfo UC = new UserContextInfo();
                CorpIds = UC.GetUserCurrentCorpId(UserInfo.UserID);

                SearchCriterion.SetSearch("CreateCorp", CorpIds);
                ents = UseWelfareNote.FindAll(SearchCriterion);
            }
            this.PageState.Add("UseWelfareNoteList", ents);
        }

        /// <summary>
        /// 审批人配置判断
        /// </summary>
        private void GetApproveUser()
        {
            var UsrEnt = SysUser.Find(UserInfo.UserID);
            string SQL = @"with GetTree
                                as
                                (
	                                select * from HR_OA_MiddleDB..fld_bmml where pk_deptdoc='{0}'
	                                union all
	                                select A.*
	                                from HR_OA_MiddleDB..fld_bmml As A 
	                                join GetTree as B 
	                                on  A.pk_deptdoc=B.pk_fathedept
                                )
	                           select deptname+',' as [text()] from getTree FOR XML PATH('') ";
            SQL = SQL.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            SQL = string.Format(SQL, UsrEnt.Pk_deptdoc);
            string DeptPathStr = DataHelper.QueryValue(SQL) + "";

            // 判断公司登陆
            string CorpIds = string.Empty;
            UserContextInfo UC = new UserContextInfo();
            CorpIds = UC.GetUserCurrentCorpId(UserInfo.UserID);

            //选取配置最近的配置  HR经理
            SQL = @"select top 1 HRManagerId As UserID,HRManagerName As Name ,
	                                case when patindex('%'+DeptName+'%','{1}')=0  then 100
		                                 else  patindex('%'+DeptName+'%','{1}') 
	                                end  As SortIndex 
                                from FL_Culture..SysApproveConfig As A
                                where A.CompanyId='{0}'  and HRManagerId is not null  order by SortIndex";
            SQL = string.Format(SQL, CorpIds, DeptPathStr);

            DataTable AppUsrDt = DataHelper.QueryDataTable(SQL);
            string status = AppUsrDt.Rows.Count > 0 ? "1" : "0";
            this.PageState.Add("Status", status);
        }


        /// <summary>
        /// 批量删除
        /// </summary>
        [ActiveRecordTransaction]
        private void DoBatchDelete()
        {
            IList<object> idList = RequestData.GetList<object>("IdList");

            if (idList != null && idList.Count > 0)
            {
                UseWelfareNote.DoBatchDelete(idList.ToArray());
            }
        }

        #endregion
    }
}


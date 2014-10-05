using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using Aim.WorkFlow;
using System.Data;
using System.Text;
using Aim.Examining.Web.Common;

namespace Aim.Examining.Web
{
    public partial class UseWelfareNoteEdit : ExamBasePage
    {
        #region 变量

        string op = String.Empty; // 用户编辑操作
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 对象类型

        #endregion


        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op");
            id = RequestData.Get<string>("id");
            type = RequestData.Get<string>("type");
            string NoticeWay = RequestData.Get("NoticeWay") + "";

            UseWelfareNote ent = null;

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<UseWelfareNote>();
                    ent.NoticeWay = NoticeWay;
                    ent.DoUpdate();
                    break;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<UseWelfareNote>();
                    ent.NoticeWay = NoticeWay;
                    ent.State = "0";   //0  创建 1 发起 2 撤销
                    ent.CreateTime = DateTime.Now;
                   
                    // 判断公司登陆
                    string CorpIds = string.Empty;
                    UserContextInfo UC = new UserContextInfo();
                    CorpIds = UC.GetUserCurrentCorpId(UserInfo.UserID);

                    ent.CreateCorp = CorpIds;
                    ent.DoCreate();
                    break;
                default:
                    if (RequestActionString == "GetNextUsers")
                    {
                        GetNextUsers();
                    }
                    else if (RequestActionString == "submitfinish")
                    {
                        SubmitFinish();
                    }
                    else
                    {
                        Doselect();
                    }
                    break;
            }

        }


        /// <summary>
        /// 默认查询
        /// </summary>
        private void Doselect()
        {
            UseWelfareNote ent = null;
            if (op != "c" && op != "cs")
            {
                if (!String.IsNullOrEmpty(id))
                {
                    ent = UseWelfareNote.Find(id);
                }
                this.SetFormData(ent);
            }
            if (op == "c")
            {   //生成编号 日期HR
                Random rd = new Random();
                string DateFt = "HR_TZ" + DateTime.Now.ToString("yyyyMMdd") + rd.Next(0, 10);
                this.SetFormData(new { Code = DateFt });
            }
            //审批意见
            if (!string.IsNullOrEmpty(id))
            {
                string sql = @"select * from Task where PatIndex('%{0}%',EFormName)>0  and Status='4' order by FinishTime asc";
                sql = string.Format(sql, id);
                IList<EasyDictionary> taskDics = DataHelper.QueryDictList(sql);
                PageState.Add("Opinion", taskDics);
                string taskId = RequestData.Get<string>("TaskId");//取审批暂存时所填写的意见
                if (!string.IsNullOrEmpty(taskId))
                {
                    Task tEnt = Task.Find(taskId);
                    if (tEnt.Status != 4 && !string.IsNullOrEmpty(tEnt.Description))
                    {
                        PageState.Add("UnSubmitOpinion", tEnt.Description);
                    }
                }
            }

            //福利申报类型
            //this.PageState.Add("ThingsType", SysEnumeration.GetEnumDict("EmpUsrWelfare"));

            ////获取系统枚举流程
            //string WFSQL = "select Code,TemplateName from  FL_Culture_AimPortal..WorkflowTemplate";
            //this.PageState.Add("WFEnum", DataHelper.QueryDict(WFSQL));
        }

        private void GetNextUsers()
        {
            UseWelfareNote SEnt = UseWelfareNote.Find(id);

            string CurrentNode = RequestData.Get<string>("taskName");
            string nextName = RequestData.Get<string>("nextName");
            string nextUserId = "";
            string nextUserName = "";

            if (CurrentNode == "申请人")
            {
                string[] User = UserChoice()[0].Split('|');
                if (User.Length > 0)
                {
                    nextUserId = User[0];
                    nextUserName = User[1];
                }
            }
            else if (CurrentNode == "第一步" && nextName == "不同意")
            {
                if (SEnt != null)
                {
                    nextUserId = SEnt.CreateId;
                    nextUserName = SEnt.CreateName;
                }
            }

            else if (CurrentNode == "第一步" && nextName != "不同意")
            {
                string[] User = UserChoice()[1].Split('|');
                if (User.Length > 0)
                {
                    nextUserId = User[0];
                    nextUserName = User[1];
                }
            }

            else if (CurrentNode == "第二步" && nextName != "退回上一步")
            {
                string[] User = UserChoice()[2].Split('|');
                if (User.Length > 0)
                {
                    nextUserId = User[0];
                    nextUserName = User[1];
                }
            }
            else if (CurrentNode == "第三步" && nextName != "退回上一步")
            {
                string[] User = UserChoice()[3].Split('|');
                if (User.Length > 0)
                {
                    nextUserId = User[0];
                    nextUserName = User[1];
                }
            }
            else if (CurrentNode == "第四步" && nextName != "退回上一步")
            {
                string[] User = UserChoice()[4].Split('|');
                if (User.Length > 0)
                {
                    nextUserId = User[0];
                    nextUserName = User[1];
                }
            }
            else if (CurrentNode == "第五步" && nextName != "退回上一步")
            {
                string[] User = UserChoice()[5].Split('|');
                if (User.Length > 0)
                {
                    nextUserId = User[0];
                    nextUserName = User[1];
                }
            }
            PageState.Add("NextUsers", new { nextUserId = nextUserId, nextUserName = nextUserName });
        }
        private string[] UserChoice()
        {
            //审批人
            //            string SQL = @"select UserId1+'|'+UserName1+','+UserId2 +'|'+UserName2+','+UserId3+'|'+UserName3+','+UserId4+'|'+UserName4+','+UserId5+'|'+UserName5
            //                           from FL_Culture..SurveyWFUserSet where SurveyId='{0}'";
            //            SQL = string.Format(SQL, SurveyId);


            //Change by WGM 7/23  UserId1 
            SysWFUserSet Ent = SysWFUserSet.FindFirstByProperties("SurveyId", id);
            var UserIds = Ent.UserId1.Split(',');
            var UserNames = Ent.UserName1.Split(',');

            //string UsrTemp = DataHelper.QueryValue(SQL).ToString();
            string UsrTemp = string.Empty;
            for (int i = 0; i < UserIds.Length; i++)
            {
                if (i > 0) UsrTemp += ",";
                UsrTemp += UserIds[i] + "|" + UserNames[i];
            }
            string[] User = UsrTemp.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries).Where(ten => ten.Replace("|", "").Length > 0).ToArray();
            return User;
        }


        /// <summary>
        /// 审批完成
        /// </summary>
        private void SubmitFinish()
        {
            if (!string.IsNullOrEmpty(id))
            {
                UseWelfareNote Ent = UseWelfareNote.Find(id);
                Ent.WorkFlowState = "End";
                Ent.WorlFlowResult = RequestData.Get<string>("ApproveResult");
                Ent.DoUpdate();
            }
        }



        /// <summary>
        ///默认选中的公司Id
        /// </summary>
        public string nodeId
        {
            get
            {
                //问卷角色或管理员
                CommPowerSplit Role = new CommPowerSplit();
                bool bl = Role.IsNoticeRole(UserInfo.UserID, UserInfo.LoginName);
                if (bl)
                {
                    string SQL = "select top 1 GroupID from FL_PortalHR..sysgroup where type='2' and Name='飞力集团' ";
                    SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
                    object obj = DataHelper.QueryValue(SQL);
                    return obj.ToString();
                }
                else
                {

                    CommPowerSplit ps = new CommPowerSplit();
                    string corps = ps.GetRoleCorps(UserInfo.UserID); //角色所在公司id

                    StringBuilder strb = new StringBuilder();
                    if (Session["CompanyId"] != null)           //判断公司登陆
                    {
                        strb.Append(Session["CompanyId"].ToString());

                    }
                    else
                    {
                        string sql = @"select B.GroupID, B.Name from sysuser As A 
	                               left join Sysgroup As B
                                        on A.Pk_corp=B.GroupID
	                               where A.UserID='{0}' ";
                        sql = string.Format(sql, UserInfo.UserID);
                        DataTable dt = DataHelper.QueryDataTable(sql);

                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            if (i > 0) strb.Append(",");
                            strb.Append(dt.Rows[i]["GroupID"].ToString());
                        }
                    }

                    if (strb.Length > 0)
                        strb.Append("," + corps);
                    else
                        strb.Append(corps);

                    return strb.ToString();
                }
            }
        }

    }
}


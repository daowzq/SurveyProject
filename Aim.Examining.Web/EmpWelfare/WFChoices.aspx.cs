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
using System.Data;
using Aim;
using Aim.WorkFlow;
using System.Text;
namespace Aim.Examining.Web.EmpWelfare
{
    public partial class WFChoices : BaseListPage
    {

        public string Attr = ""; //seltype=ApproveRoleId|"
        SysWFUserSet ent = null;
        string SurveyId = string.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            SurveyId = RequestData.Get("SurveyId") + "";
            //SetApproveAttr(SurveyId);

            SysWFUserSet ent = null;

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<SysWFUserSet>();
                    ent.DoUpdate();
                    StartFlow(SurveyId);
                    return;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<SysWFUserSet>();
                    ent.Type = "Welfare";  //标识福利申报通知
                    ent.DoCreate();
                    StartFlow(ent.SurveyId);
                    break;
                default:
                    if (RequestActionString == "AutoExecuteFlow")
                    {
                        AutoExecuteFlow();
                    }
                    else if (RequestActionString == "getUserInfo")
                    {
                        GetUserInfo();
                    }
                    else
                    {
                        if (!String.IsNullOrEmpty(SurveyId))
                        {
                            string approve = CheckFL();  //获取审批人
                            ent = SysWFUserSet.FindFirstByProperties(SysWFUserSet.Prop_SurveyId, SurveyId);
                            if (ent == null) ent = new SysWFUserSet();

                            if (approve.Split('|').Length > 3) //默认审批人
                            {
                                //ent.UserId1
                                string UserId1 = string.IsNullOrEmpty(approve.Split('|')[4]) ? "" : approve.Split('|')[4];
                                string UserName1 = string.IsNullOrEmpty(approve.Split('|')[5]) ? "" : approve.Split('|')[5];

                                if (UserId1.Split(',').Length > 1)
                                {
                                    int rd = new Random().Next(UserId1.Split(',').Length);
                                    UserId1 = UserId1.Split(',')[rd];
                                    UserName1 = UserName1.Split(',')[rd];
                                }
                                else
                                {
                                    UserId1 = UserId1.Split(',')[0];
                                    UserName1 = UserName1.Split(',')[0];
                                }
                                ent.UserId1 = UserId1;
                                ent.UserName1 = UserName1;
                            }
                            this.PageState.Add("ChState", approve);
                        }
                        this.SetFormData(ent);
                    }
                    break;
            }

        }

        //创建流程
        private void StartFlow(string SurveyId)
        {

            string state = RequestData.Get<string>("state");
            string formtype = RequestData.Get("formtype") + "";

            UseWelfareNote Ent = UseWelfareNote.Find(SurveyId);
            string FlowKey = "questionnaire_";                 //工作流key
            string NextUsr = string.Empty;                     //下一个审批人

            SysWFUserSet UsrEnt = SysWFUserSet.FindFirstByProperties("SurveyId", SurveyId);
            int lg = UsrEnt.UserId1.Split(',').Length;
            FlowKey = FlowKey + lg;

            NextUsr += UsrEnt.UserId1.Split(',')[0] + "|" + UsrEnt.UserName1.Split(',')[0];

            //指定流程Key
            //if (!string.IsNullOrEmpty(Ent.WorkFlowCode))
            //{
            //    FlowKey = Ent.WorkFlowCode;
            //}
            //else
            //{
            // 根据人员 获取工作流key
            //SQL = @"select  Code  from WorkflowTemplate where TemplateName like '调查问卷%' ";
            //DataTable FlDt = DataHelper.QueryDataTable(SQL);
            //if (!string.IsNullOrEmpty(FlDt.Rows[0][0] + ""))
            //{
            //    FlowKey = (FlDt.Rows[0][0] + "").Substring(0, (FlDt.Rows[0][0] + "").Length - 1) + UserCount.Length;
            //}


            if (!string.IsNullOrEmpty(FlowKey))
            {
                string formUrl = string.Empty;
                //if (formtype.Contains("onlyView"))  //onlyView 表示固定问卷
                //{
                //formUrl = "/SurveyManage/InternetSurvey.aspx?flow=y&op=v&type=read&Id=" + SurveyId;
                //}
                //else
                //{
                formUrl = "/EmpWelfare/UseWelfareNoteEdit.aspx?op=r&id=" + SurveyId;
                //}

                Guid guid = Aim.WorkFlow.WorkFlow.StartWorkFlow(SurveyId, formUrl, "福利申报通知", FlowKey, UserInfo.UserID, UserInfo.Name);
                Ent.WorkFlowState = "Start";
                Ent.WorkFlowCode = guid.ToString(); //InstanceId
                Ent.DoUpdate();
                this.PageState.Add("NextInfo", guid.ToString() + "$" + NextUsr);
            }
        }

        private void AutoExecuteFlow()
        {
            string NextInfo = this.RequestData.Get("NextInfo") + "";
            string IntanceId = NextInfo.Split('$')[0];
            string[] UserArr = NextInfo.Split('$')[1].Split('|');

            IList<Task> tasks = Task.FindAllByProperty(Task.Prop_WorkflowInstanceID, IntanceId);
            Aim.WorkFlow.WorkFlow.AutoExecute(tasks[0], UserArr);
        }

        /// <summary>
        /// 获取审批人信息
        /// </summary>
        private void GetUserInfo()
        {
            string userids = RequestData.Get("userids") + "";
            string sql = @"select 
                            A.Name +'('+ A.WorkNo+')  ' + '['+B.Name+'/'+C.Name+ 
                             case when D.name is not null then '  '+ D.Name else '' end  + ']'
                            As UserInfo
                             from  Sysuser A 
                            left join  Sysgroup As B
                              on A.Pk_corp=B.GroupID 
                            left join  SysGroup As C
                              on A.Pk_deptdoc=C.GroupID 
                            left join  SysGroup As D
                              on A.Pk_gw =D.GroupID
                            where A.UserID in {0}";
            sql = string.Format(sql, userids);
            DataTable dt = DataHelper.QueryDataTable(sql);
            StringBuilder strb = new StringBuilder();
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (i > 0) strb.Append("|");
                strb.Append(dt.Rows[i][0]);
            }
            this.PageState.Add("AppUserInfo", strb.ToString());
        }

        /// <summary>
        /// check 审批对象 
        /// </summary>
        private string CheckFL()
        {
            string data = string.Empty;
            string SQL = string.Empty;

            //            if (!string.IsNullOrEmpty(SurveyId))
            //            {
            //                data = "1|||HR经理";
            //                var UsrEnt = SysUser.Find(UserInfo.UserID);

            //                //获取人员部门
            //                SQL = @"with GetTree
            //                                as
            //                                (
            //	                                select * from HR_OA_MiddleDB..fld_bmml where pk_deptdoc='{0}'
            //	                                union all
            //	                                select A.*
            //	                                from HR_OA_MiddleDB..fld_bmml As A 
            //	                                join GetTree as B 
            //	                                on  A.pk_deptdoc=B.pk_fathedept
            //                                )
            //	                           select deptname+',' as [text()] from getTree FOR XML PATH('') ";
            //                SQL = SQL.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            //                SQL = string.Format(SQL, UsrEnt.Pk_deptdoc);

            //                string DeptPathStr = DataHelper.QueryValue(SQL) + "";

            //                //选取配置最近的配置
            //                SQL = @"select top 1 HRManagerId As UserID,HRManagerName As Name ,
            //	                                case when patindex('%'+DeptName+'%','{1}')=0  then 100
            //		                                 else  patindex('%'+DeptName+'%','{1}') 
            //	                                end  As SortIndex 
            //                                from FL_Culture..SysApproveConfig As A
            //                                where A.CompanyId='{0}'  and HRManagerId is not null   order by SortIndex";
            //                SQL = string.Format(SQL, UsrEnt.Pk_corp, DeptPathStr);

            //                DataTable AppUsrDt = DataHelper.QueryDataTable(SQL);
            //                StringBuilder StrUserID = new StringBuilder();
            //                StringBuilder StrUserName = new StringBuilder();

            //                for (int i = 0; i < AppUsrDt.Rows.Count; i++)
            //                {
            //                    if (i > 0)
            //                    {
            //                        StrUserID.Append(",");
            //                        StrUserName.Append(",");
            //                    }
            //                    StrUserID.Append(AppUsrDt.Rows[i]["UserID"].ToString());
            //                    StrUserName.Append(AppUsrDt.Rows[i]["Name"].ToString());
            //                }
            //                data += "|" + StrUserID.ToString() + "|" + StrUserName.ToString();
            //            }
            //  this.PageState.Add("ChState", data);
            data = "1|||HR经理||";
            return data;
        }
    }
}

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
using Aim.Examining.Web.Common;
namespace Aim.Examining.Web.SurveyManage
{
    public partial class WorkFlowChoices : BaseListPage
    {

        public string Attr = ""; //seltype=ApproveRoleId|"
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
                    else if (RequestActionString == "CheckUsr")
                    {
                        CheckUsr();
                    }
                    else
                    {
                        if (!String.IsNullOrEmpty(SurveyId))
                        {
                            string approve = CheckFL();
                            //ent = SysWFUserSet.FindFirstByProperties(SysWFUserSet.Prop_SurveyId, SurveyId);
                            //if (ent == null) ent = new SysWFUserSet();
                            //if (approve.Split('|').Length > 3) //默认审批人
                            //{
                            //    //ent.UserId1
                            //    string UserId1 = string.IsNullOrEmpty(approve.Split('|')[4]) ? "" : approve.Split('|')[4];
                            //    string UserName1 = string.IsNullOrEmpty(approve.Split('|')[5]) ? "" : approve.Split('|')[5];

                            //    if (UserId1.Split(',').Length > 1)
                            //    {
                            //        int rd = new Random().Next(UserId1.Split(',').Length);
                            //        UserId1 = UserId1.Split(',')[rd];
                            //        UserName1 = UserName1.Split(',')[rd];
                            //    }
                            //    else
                            //    {
                            //        UserId1 = UserId1.Split(',')[0];
                            //        UserName1 = UserName1.Split(',')[0];
                            //    }
                            //    ent.UserId1 = UserId1;
                            //    ent.UserName1 = UserName1;
                            //}
                            this.PageState.Add("ChState", approve);
                        }
                        this.SetFormData(ent);
                    }
                    break;

            }


        }

        private void CheckUsr()
        {
            string CheckUsr = RequestData.Get("UserIds") + "";
            string SurveyId = RequestData.Get("SurveyId") + "";

            string SQL = @"select  top 1  A.WorkFlowName, B.MustCheckFlow,B.ApproveRoleId,B.ApproveRoleName from  FL_Culture..SurveyQuestion As A
                           left join FL_Culture..SurveyType As B 
                         on B.Id=A.SurveyTypeId  where A.Id='{0}' ";
            SQL = string.Format(SQL, SurveyId);
            DataTable Dt = DataHelper.QueryDataTable(SQL);
            string rolename = string.Empty;
            if (DataHelper.QueryDataTable(SQL).Rows.Count > 0)
            {
                rolename = Dt.Rows[0]["ApproveRoleName"] + "";
            }

            //获取公司
            string Corp = string.Empty;
            UserContextInfo UC = new UserContextInfo();
            Corp = UC.GetUserCurrentCorpId(UserInfo.UserID);//判断公司登陆

            SQL = @"select top 1  UserNames   from  FL_Culture..ManagementGroup As A
	                            inner join  FL_Culture..ManagementInfo AS B
                            on A.Id=B.PId 
                            where  A.MName='{0}' and  B.CompanyId='{1}' order by B.CreateTime desc   ";
            SQL = string.Format(SQL, rolename, Corp);

            string configRoleName = DataHelper.QueryValue(SQL) + "";//审批职位

            SQL = @"select * from sysuser where charindex(UserId, '{0}')>0";
            SQL = string.Format(SQL, CheckUsr);
            DataTable UDt = DataHelper.QueryDataTable(SQL);
            bool Has = false;
            for (int i = 0; i < UDt.Rows.Count; i++)
            {
                string sql = @"select B.jobname from HR_OA_MiddleDB..fld_ryxx as A
	                            left join HR_OA_MiddleDB..fld_gw AS B
                               on A.pk_gw=B.pk_jobcode where A.psncode='{0}'  
                                and (outdutydate is null or outdutydate='')  
                                and  B.pk_corp='{1}'  ";

                sql = string.Format(sql, UDt.Rows[i]["WorkNo"] + "", Corp);
                sql = sql.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
                DataTable tempdt = DataHelper.QueryDataTable(sql);

                for (int j = 0; j < tempdt.Rows.Count; j++)
                {
                    if (!string.IsNullOrEmpty(tempdt.Rows[j]["jobname"] + "") && configRoleName.Contains(tempdt.Rows[j]["jobname"] + ""))
                    {
                        string[] tmArr = configRoleName.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                        for (int k = 0; k < tmArr.Length; k++)
                        {
                            if (tmArr[k] == tempdt.Rows[j]["jobname"] + "")
                            {
                                Has = true;
                                break;
                            }
                        }
                    }
                    if (Has) break;
                }
                if (Has) break;
            }
            this.PageState.Add("State", Has ? "1" : "0");
        }

        //创建流程
        private void StartFlow(string SurveyId)
        {

            string state = RequestData.Get<string>("state");
            string formtype = RequestData.Get("formtype") + "";

            SurveyQuestion Ent = SurveyQuestion.Find(SurveyId);
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
                formUrl = "/SurveyManage/WorkFlowTab.aspx?op=r&SurveyId=" + SurveyId;
                //}

                Guid guid = Aim.WorkFlow.WorkFlow.StartWorkFlow(SurveyId, formUrl, "调查问卷审批", FlowKey, UserInfo.UserID, UserInfo.Name);
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
        /// check 审批对象  1|||总经理|UserID|UserName
        /// </summary>
        private string CheckFL()
        {
            string data = string.Empty;
            if (String.IsNullOrEmpty(SurveyId)) return "";

            string SQL = @"select  A.WorkFlowName, B.MustCheckFlow,B.ApproveRoleId,B.ApproveRoleName from  FL_Culture..SurveyQuestion As A
                           left join FL_Culture..SurveyType As B 
                         on B.Id=A.SurveyTypeId  where A.Id='{0}'";
            SQL = string.Format(SQL, SurveyId);

            //是否审批(1)|WorkFlowName|ApproveRoleId|ApproveRoleName     1|||总经理|UserID|UserName
            DataTable dt = DataHelper.QueryDataTable(SQL);
            if (dt.Rows.Count <= 0) return "";

            data = dt.Rows[0]["MustCheckFlow"].ToString() + "|" + dt.Rows[0]["WorkFlowName"].ToString();

            //关联审批角色人员 ApproveRoleName
            if (!string.IsNullOrEmpty(dt.Rows[0]["ApproveRoleName"] + ""))
            {
                //data += "|" + dt.Rows[0]["ApproveRoleId"] + "|" + dt.Rows[0]["ApproveRoleName"];

                //                //获取人员部门
                //                var UsrEnt = SysUser.Find(UserInfo.UserID);
                //                SQL = @"with GetTree
                //                            as
                //                            (
                //                                select * from HR_OA_MiddleDB..fld_bmml where pk_deptdoc='{0}'
                //                                union all
                //                                select A.*
                //                                from HR_OA_MiddleDB..fld_bmml As A 
                //                                join GetTree as B 
                //                                on  A.pk_deptdoc=B.pk_fathedept
                //                            )
                //                           select deptname+',' as [text()] from getTree FOR XML PATH('') ";
                //                SQL = SQL.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
                //                SQL = string.Format(SQL, UsrEnt.Pk_deptdoc);

                //                string DeptPathStr = DataHelper.QueryValue(SQL) + "";

                //                //先查看是否有配置,问卷审批人ManagerName 这是有排序
                //                SQL = @"select top 1 ManagerId As UserID,ManagerName As Name ,
                //                    	                                case when patindex('%'+DeptName+'%','{1}')=0  then 100
                //                    		                                 else  patindex('%'+DeptName+'%','{1}') 
                //                    	                                end  As SortIndex 
                //                                                    from FL_Culture..SysApproveConfig As A
                //                                                    where A.CompanyId='{0}' and ManagerId is not null and ManagerId<>''
                //                                                          order by SortIndex";
                //                SQL = string.Format(SQL, UsrEnt.Pk_corp, DeptPathStr);

                //                DataTable AppUsrDt = DataHelper.QueryDataTable(SQL);
                //                StringBuilder StrUserID = new StringBuilder();
                //                StringBuilder StrUserName = new StringBuilder();

                //                //no config 模糊匹配
                //                if (AppUsrDt.Rows.Count <= 0)
                //                {
                //                    SQL = @"select distinct D.UserID,D.WorkNo,D.Name from  HR_OA_MiddleDB..fld_ryxx As A
                //                                                     left join  HR_OA_MiddleDB..fld_gw As B 
                //                                                      on A.Pk_corp=B.pk_corp --or A.pk_gw=B.pk_fld_gw 
                //                                                    left join HR_OA_MiddleDB..fld_ryxx As C
                //                                                     on C.pk_gw=B.pk_jobcode
                //                                                    left join  FL_PortalHR..SysUser  As D
                //                                                    	on D.WorkNo=C.psncode 
                //                                                    where  A.psncode='{0}' and  B.jobName like '{1}' and C.id is not null ";

                //                    SQL = SQL.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
                //                    SQL = string.Format(SQL, UsrEnt.WorkNo, dt.Rows[0]["ApproveRoleName"]);
                //                    AppUsrDt = DataHelper.QueryDataTable(SQL);
                //                }


                //-----------------------------------change by WGM 10/24----
                StringBuilder StrUserID = new StringBuilder();
                StringBuilder StrUserName = new StringBuilder();
                //审批角色名称
                string RoleName = dt.Rows[0]["ApproveRoleName"] + "";
                //获取公司
                string Corp = string.Empty;
                UserContextInfo UC = new UserContextInfo();
                Corp = UC.GetUserCurrentCorpId(UserInfo.UserID); //判断公司登陆

                SQL = @"select top 1  UserNames   from  FL_Culture..ManagementGroup As A
	                            inner join  FL_Culture..ManagementInfo AS B
                            on A.Id=B.PId 
                            where  A.MName='{0}' and  B.CompanyId='{1}' order by B.CreateTime desc   ";
                SQL = string.Format(SQL, RoleName, Corp);

                string ApproveRoleName = DataHelper.QueryValue(SQL) + "";
                //data += "|" + dt.Rows[0]["ApproveRoleId"] + "|" + ApproveRoleName;
                data += "|" + dt.Rows[0]["ApproveRoleId"] + "|" + dt.Rows[0]["ApproveRoleName"];

                //                //职位关联人员
                //                SQL = @" declare @Gw nvarchar(1000)
                //                            select  top 1 @Gw=UserNames 
                //                               from  FL_Culture..ManagementGroup As A
                //	                            inner join  FL_Culture..ManagementInfo AS B
                //                            on A.Id=B.PId 
                //                            where  A.MName='{0}' and  B.CompanyId='{1}' ;
                //                            select * from FL_PortalHR..SysUser where WorkNo in
                //                             (
                //	                            select top 2 B.psncode  from  HR_OA_MiddleDB..fld_gw AS A
                //	                               left join  HR_OA_MiddleDB..fld_ryxx  AS B
                //	                            on A.pk_jobcode=B.pk_gw
                //	                            where A.isabort='N' and (B.outdutydate is null or B.outdutydate='' )
                //		                            and
                //	                            B.pk_corp='{1}' and (@Gw like '%'+ jobname+'%' or jobname like '%'+@Gw+'%' )
                //                            )";

                //                SQL = string.Format(SQL, RoleName, Corp);
                //                SQL = SQL.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
                //                SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

                //                DataTable AppUsrDt = DataHelper.QueryDataTable(SQL);
                //                ////拼接审批人员
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
                //data = "1|||总经理|UserID|UserName";
                //--------------------------------------------------------------------------
                //this.PageState.Add("ChState", data);
            }

            return data;
        }

    }
}

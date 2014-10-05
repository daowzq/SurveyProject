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
    public partial class UsrAppealListEdit : ExamBasePage
    {
        #region 变量

        string op = String.Empty; // 用户编辑操作
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 对象类型

        #endregion

        UsrAppealList ent = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op");
            id = RequestData.Get<string>("id");
            type = RequestData.Get<string>("type");

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<UsrAppealList>();
                    ent.DoUpdate();
                    break;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<UsrAppealList>();
                    ent.DoCreate();
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<UsrAppealList>();
                    ent.DoDelete();
                    return;
                default:
                    if (RequestActionString == "select")
                    {
                        string UserId = RequestData.Get<string>("UserId");
                        string sql = @"  select T1.WorkNo,T1.Name AS UserName,T3.Name,T2.GroupID from 
                        dbo.SysUser T1 left join dbo.SysUserGroup T2 on T1.UserID = T2.UserID 
                        left join dbo.SysGroup T3 on T2.GroupID = T3.GroupID where Type='2' and T1.UserID='" + UserId + "' ";
                        PageState.Add("getUserByWo", DataHelper.QueryDictList(sql));
                    }
                    else if (RequestActionString == "Submit")
                    {
                        StartFlow();
                    }
                    else if (RequestActionString == "AutoExecuteFlow")
                    {
                        AutoExecuteFlow();
                    }
                    else if (RequestActionString == "GetAcceptName")
                    {
                        GetNextUsers();
                    }
                    else if (RequestActionString == "GetNextUsers")
                    {
                        GetNextUsers();
                    }
                    else if (RequestActionString == "submitfinish")
                    {
                        SubmitFinish();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }

        }

        #region 流程审批

        //创建流程
        private void StartFlow()
        {
            UsrAppealList Ent = null;
            if (string.IsNullOrEmpty(id))
            {
                Ent = this.GetPostedData<UsrAppealList>();
                Ent.SubmitCount = 0;
                Ent.SubmitTime = DateTime.Now;
                Ent.DoCreate();
            }
            else
            {
                Ent = UsrAppealList.Find(id);
            }

            string FlowKey = "EmpUsrAppeal_1";                                    //工作流key
            string UserId = RequestData.Get("UserId") + "";                       //申诉受理人
            string UserName = RequestData.Get("UserName") + "";
            string ApproveType = "";
            string submitUsrId = string.Empty, submitUsrName = string.Empty;      //当前申诉人

            if (Ent.IsNoName == "1")//匿名状态
            {
                submitUsrId = UserInfo.UserID;
                submitUsrName = "匿名";
            }
            else                    //非匿名
            {
                submitUsrId = UserInfo.UserID;
                submitUsrName = UserInfo.Name;
            }
            ApproveType = "_【" + Ent.AppealTypeName + "】";

            if (!string.IsNullOrEmpty(FlowKey))
            {
                string formUrl = "/EmpUserAppeal/UsrAppealListEdit.aspx?op=r&id=" + Ent.Id;
                Guid guid = Aim.WorkFlow.WorkFlow.StartWorkFlow(Ent.Id, formUrl, "员工申诉" + ApproveType, FlowKey, submitUsrId, submitUsrName);
                Ent.WorkFlowState = "Start";
                Ent.WorkFlowCode = guid.ToString(); //InstanceId
                Ent.DoUpdate();
                this.PageState.Add("NextInfo", guid.ToString() + "$" + UserId + "|" + UserName);
            }

        }
        private void AutoExecuteFlow()
        {
            string NextInfo = this.RequestData.Get("NextInfo") + "";
            string IntanceId = NextInfo.Split('$')[0];
            string[] UserArr = NextInfo.Split('$')[1].Split('|');

            IList<Task> tasks = Task.FindAllByProperty(Task.Prop_WorkflowInstanceID, IntanceId);
            Aim.WorkFlow.WorkFlow.AutoExecute(tasks[0], "HR专员", UserArr);  //第一步跳到HR专员
        }

        /// <summary>
        /// 获取人员
        /// </summary>
        private void GetNextUsers()
        {
            string CurrentNode = RequestData.Get<string>("taskName");
            string nextName = RequestData.Get<string>("nextName");
            string UserId = string.Empty, UserName = string.Empty;
            string CorpIds = string.Empty;   //公司ID

            // according id find create user
            SysUser UsrEnt = null;
            UsrAppealList AppEnt = UsrAppealList.TryFind(id);
            if (AppEnt != null)
            {
                UsrEnt = SysUser.Find(AppEnt.UserId);
                CorpIds = UsrEnt.Pk_corp;
            }
            else
            {
                // 判断公司登陆
                UserContextInfo UC = new UserContextInfo();
                CorpIds = UC.GetUserCurrentCorpId(UserInfo.UserID);
                UsrEnt = SysUser.Find(UserInfo.UserID);
            }

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
            string DeptPathStr = DataHelper.QueryValue(SQL).ToString();
            DeptPathStr = string.IsNullOrEmpty(DeptPathStr) ? "" : DeptPathStr;

            SQL = @"select top 1 *,
                    case when patindex('%'+DeptName+'%','{1}')=0  then 100
                         else  patindex('%'+DeptName+'%','{1}') 
                    end  As SortIndex 
                from FL_Culture..SysApproveConfig As A
                where A.CompanyId='{0}' and HRUsrId is not null  order by SortIndex";
            SQL = string.Format(SQL, CorpIds, DeptPathStr);

            DataTable dt = DataHelper.QueryDataTable(SQL);
            if (dt == null || dt.Rows.Count == 0) return;


            //HR专员-->HR经理(一级组织负责人)-->总部HR专员--->总部HR经理
            if (CurrentNode == "AppealUsr" && string.IsNullOrEmpty(nextName))//申诉人
            {
                if (!string.IsNullOrEmpty(id))
                {
                    var Ent = UsrAppealList.Find(id);
                    if (ent != null)
                    {
                        UserId = Ent.UserId;
                        UserName = Ent.UserName;
                    }
                }
            }
            else if (CurrentNode == "AppealUsr" && nextName == "提交") //申诉人-->HR专员
            {
                UserId = dt.Rows[0]["HRUsrId"].ToString();
                UserName = dt.Rows[0]["HRUserName"].ToString();
            }
            else if (CurrentNode == "AppealUsr" && nextName == "上诉") //申诉人-->总部HR专员
            {
                //需跳环节
                //                string sql = @"select * from Task where PatIndex('%{0}%',EFormName)>0  and Status='4' 
                //                             and ApprovalNodeName='总部HR经理' order by FinishTime asc";
                //                sql = string.Format(sql, id);
                //                DataTable rowDt = DataHelper.QueryDataTable(sql);
                //                if (rowDt.Rows.Count > 0)                               //申诉人-->总部HR经理-->HR总监
                //                {
                //                    UserId = dt.Rows[0]["HQHRMajorId"].ToString();
                //                    UserName = dt.Rows[0]["HQHRMajorName"].ToString();
                //                }
                //                else
                //                {
                UserId = dt.Rows[0]["HQHRUserId"].ToString();
                UserName = dt.Rows[0]["HQHRUserName"].ToString();
                // }

            }
            else if (CurrentNode == "HRUsr" && string.IsNullOrEmpty(nextName)) //申诉人-->HR专员
            {
                UserId = dt.Rows[0]["HRUsrId"].ToString();
                UserName = dt.Rows[0]["HRUserName"].ToString();
            }
            else if (CurrentNode == "HRUsr" && nextName == "提交上一级")    //Hr专员--> HR经理
            {
                UserId = dt.Rows[0]["HRManagerId"].ToString();
                UserName = dt.Rows[0]["HRManagerName"].ToString();
            }
            else if (CurrentNode == "HQHRUser" && nextName == "提交上一级") //总部HR专员--> 总部HR经理
            {
                UserId = dt.Rows[0]["HQHRManagerId"].ToString();
                UserName = dt.Rows[0]["HQHRManagerName"].ToString();
            }
            else if (CurrentNode == "HQHRManager" && nextName == "提交上一级") // 总部HR经理---->总部HR总监
            {
                UserId = dt.Rows[0]["HQHRMajorId"].ToString();
                UserName = dt.Rows[0]["HQHRMajorName"].ToString();
            }

            //else if (CurrentNode == "CompanyLeader")   //一级组织负责人
            //{
            //    UserId = dt.Rows[0]["CompanyLeaderId"].ToString();
            //    UserName = dt.Rows[0]["CompanyLeaderName"].ToString();

            PageState.Add("NextUsers", new { nextUserId = UserId, nextUserName = UserName });
        }



        private void SubmitFinish()
        {
            if (!string.IsNullOrEmpty(id))
            {
                UsrAppealList Ent = UsrAppealList.Find(id);
                Ent.WorkFlowState = "End";
                Ent.DealResult = RequestData.Get<string>("ApproveResult"); //处理结果
                Ent.DoUpdate();
            }
        }
        #endregion


        /// <summary>
        /// 信息初始化
        /// </summary>
        private void DoSelect()
        {
            if (op != "c" && op != "cs")
            {
                if (!String.IsNullOrEmpty(id))
                {
                    ent = UsrAppealList.Find(id);
                }

                this.SetFormData(ent);
            }
            if (op == "c" || op == "create")
            {
                //var Ent = SysUser.FindFirstByProperties("UserID", UserInfo.UserID);
                string config = @"select A.*,B.GroupID as CropId,B.Name as CropName,
                                    C.GroupID as DeptId,C.Name as DeptName
                             from FL_PortalHR..SysUser As A
	                            left join FL_PortalHR..SysGroup As B
                              on  A.Pk_corp=B.GroupID
	                            left join  FL_PortalHR..SysGroup As C
                              on A.Pk_deptdoc=C.GroupID
                            where UserID='{0}'";

                config = config.Replace("FL_PortalHR", Global.AimPortalDB);

                config = string.Format(config, UserInfo.UserID);
                DataTable dt = DataHelper.QueryDataTable(config);

                string OrgPath = dt.Rows[0]["DeptName"] + "";
                OrgPath = !string.IsNullOrEmpty(OrgPath) ? "/" + OrgPath : "";

                var Obj = new
                {
                    UserId = dt.Rows[0]["UserID"],
                    UserName = dt.Rows[0]["Name"],
                    Sex = dt.Rows[0]["Sex"],
                    Age = dt.Rows[0]["Age"],
                    WorkNo = dt.Rows[0]["WorkNo"],
                    DeptId = dt.Rows[0]["DeptId"],
                    DeptName = dt.Rows[0]["DeptName"],
                    CompanyId = dt.Rows[0]["CropId"],
                    CompanyName = dt.Rows[0]["CropName"] + OrgPath   //Change 2012/10/31
                };
                this.SetFormData(Obj);

                //if (Ent != null)
                //{
                //    var Obj = new
                //    {
                //        UserId = Ent.UserID,
                //        UserName = Ent.Name,
                //        Sex = Ent.Sex,
                //        Age = Ent.Age,
                //        WorkNo = Ent.WorkNo
                //    };
                //    this.SetFormData(Obj);
                //}
            }
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
            PageState.Add("AppealTypeName", SysEnumeration.GetEnumDict("EmpAppeal"));

        }
    }


}



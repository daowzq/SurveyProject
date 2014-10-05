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
using Aim.Examining.Web.EmpWelfare;
using Aim.WorkFlow;
using System.Data;

namespace Aim.Examining.Web
{
    public partial class UsrWomanWelfareEdit : ExamBasePage
    {
        #region 变量

        string op = String.Empty; // 用户编辑操作
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 对象类型

        #endregion

        UsrWomanWelfare ent = null;

        public UsrWomanWelfareEdit()
        {
            this.IsCheckAuth = false;
            this.IsCheckLogon = false;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op");
            id = RequestData.Get<string>("id");
            type = RequestData.Get<string>("type");

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<UsrWomanWelfare>();
                    ent.DoUpdate();
                    this.SetMessage("修改成功！");
                    break;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<UsrWomanWelfare>();
                    ent.ApplyTime = DateTime.Now;


                    string userid = "";
                    if (UserInfo != null)
                        userid = UserInfo.UserID;
                    else
                        userid = RequestData.Get<string>("userid");

                    ent.NoticeId = RequestData.Get<string>("noticeid");

                    ent.CreateId = userid;
                    ent.CreateName = "";
                    ent.CreateTime = DateTime.Now;

                    ent.DoCreate();

                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<UsrWomanWelfare>();
                    ent.DoDelete();

                    return;
                default:
                    if (RequestActionString == "GetWorkNo")
                    {

                        string UserID = RequestData.Get("UserID") + "";
                        ComUtility Ut = new ComUtility();
                        this.PageState.Add("WorkNo", Ut.GetWorkNo(UserID));
                    }
                    else if (RequestActionString == "ckNotice")  //通知检查
                    {
                        CKSubmit();
                    }
                    else if (RequestActionString == "Submit")  //提交流程
                    {
                        StartFlow();
                    }
                    else if (RequestActionString == "AutoExecuteFlow")
                    {
                        AutoExecuteFlow();
                    }
                    else if (RequestActionString == "submitfinish")
                    {
                        SubmitFinish();
                    }
                    else if (RequestActionString == "GetNextUsers")
                    {
                        GetNextUsers();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }

        }

        /// <summary>
        /// 发起通知 是否在通知时间范围内
        /// </summary>
        private void CKSubmit()
        {
            string Id = RequestData.Get("Id") + "";

            string CorpIds = string.Empty;
            var UsrEnt = SysUser.Find(Id);

            if (Session["CompanyId"] != null)
            {
                CorpIds = Session["CompanyId"] + "";
            }
            else
            {
                CorpIds = UsrEnt.Pk_corp;
            }

            ComUtility Ut = new ComUtility();
            string UsrId = Ut.CheckApply("三八妇女节", UserInfo.UserID, CorpIds);
            this.PageState.Add("State", UsrId);
        }

        #region 流程审批

        //创建流程
        private void StartFlow()
        {
            if (op == "c" || op == "create")
            {
                ent = this.GetPostedData<UsrWomanWelfare>();
                ent.ApplyTime = DateTime.Now;
                ent.DoCreate();
                id = ent.Id;
            }
            else
            {
                ent = UsrWomanWelfare.Find(id);
            }

            //受理人
            string UserId = ent.ApproveUserId;
            string UserName = ent.ApproveName;

            string FlowKey = "EmpUsrWelfare";   //工作流key

            if (!string.IsNullOrEmpty(FlowKey))
            {
                string formUrl = "/EmpWelfare/UsrWomanWelfareEdit.aspx?op=r&id=" + id;
                Guid guid = Aim.WorkFlow.WorkFlow.StartWorkFlow(id, formUrl, "三八妇女节福利申请", FlowKey, UserInfo.UserID, UserInfo.Name);
                ent.WorkFlowState = "Start";
                ent.WorkFlowCode = guid.ToString(); //InstanceId
                ent.DoUpdate();
                this.PageState.Add("NextInfo", guid.ToString() + "$" + UserId + "|" + UserName);
            }

        }

        //获取下一节点人
        private void GetNextUsers()
        {
            //  taskName id   nextUserName
            string id = this.RequestData.Get("id") + "";
            string taskName = this.RequestData.Get("taskName") + "";
            string nextName = this.RequestData.Get("nextName") + "";
            if (!string.IsNullOrEmpty(id))
            {
                var Ent = UsrWomanWelfare.Find(id);
                if (nextName == "审批人")
                {
                    this.PageState.Add("NextUsers", new { nextUserId = Ent.ApproveUserId, nextUserName = Ent.ApproveName });
                }
            }

        }

        private void AutoExecuteFlow()
        {
            string NextInfo = this.RequestData.Get("NextInfo") + "";
            string IntanceId = NextInfo.Split('$')[0];
            string[] UserArr = NextInfo.Split('$')[1].Split('|');

            IList<Task> tasks = Task.FindAllByProperty(Task.Prop_WorkflowInstanceID, IntanceId);
            Aim.WorkFlow.WorkFlow.AutoExecute(tasks[0], UserArr);  //制定节点
        }

        /// <summary>
        /// 审批完成
        /// </summary>
        private void SubmitFinish()
        {
            if (!string.IsNullOrEmpty(id))
            {
                UsrWomanWelfare Ent = UsrWomanWelfare.Find(id);
                Ent.WorkFlowState = "End";
                Ent.Result = RequestData.Get<string>("ApproveResult"); //处理结果
                Ent.DoUpdate();
            }
        }

        #endregion


        private void DoSelect()
        {
            if (op != "c" && op != "cs")
            {
                if (!String.IsNullOrEmpty(id))
                {
                    ent = UsrWomanWelfare.Find(id);
                }
                this.SetFormData(ent);
            }

            if (op == "c" || op == "create")
            {


                string userid = "";
                if (UserInfo != null)
                    userid = UserInfo.UserID;
                else
                    userid = RequestData.Get<string>("userid");



                //  string sql = "select * from UsrTravelWelfare";

                UsrWomanWelfare[] TWEnt = UsrWomanWelfare.FindAllByProperties(UsrWomanWelfare.Prop_UserId, RequestData.Get<string>("userid"), UsrWomanWelfare.Prop_NoticeId, RequestData.Get<string>("noticeid"));
                if (TWEnt.Length != 0)
                {
                    this.SetFormData(TWEnt[0]);
                }
                else
                {

                    var Ent = SysUser.FindFirstByProperties("UserID", userid);

                    //用来获取配置的审批人
                    string SQL = "select top 1 * from  FL_Culture..SysApproveConfig where CompanyId='{0}' and len(WomanWelfareId)>0 ";
                    SQL = string.Format(SQL, Ent.Pk_corp);
                    DataTable Dt = DataHelper.QueryDataTable(SQL);

                    //公司与部门
                    SQL = @"select B.GroupID As CompanyId,B.Name As CompanyName,C.GroupID AS DeptId,C.Name As DeptName
                        from  sysuser As A
	                        left join sysgroup As B
	                        on A.pk_corp=B.groupID
                        left join sysgroup As C
	                        on C.GroupID=A.pk_deptdoc
                        where A.UserID='{0}'";
                    SQL = string.Format(SQL, userid);
                    DataTable Dt1 = DataHelper.QueryDataTable(SQL);

                    string CompanyName = string.Empty, CompanyId = string.Empty;
                    string DeptName = string.Empty, DeptId = string.Empty;

                    if (Dt1.Rows.Count > 0)
                    {
                        CompanyName = Dt1.Rows[0]["CompanyName"].ToString();
                        CompanyId = Dt1.Rows[0]["CompanyId"].ToString();
                        DeptId = Dt1.Rows[0]["DeptId"].ToString();
                        DeptName = Dt1.Rows[0]["DeptName"].ToString();
                    }

                    if (Ent != null)
                    {
                        var Obj = new
                        {
                            UserId = Ent.UserID,
                            UserName = Ent.Name,
                            Sex = Ent.Sex,
                            Age = Ent.Wage,
                            WorkNo = Ent.WorkNo,
                            IndutyData = Ent.Indutydate,

                            CompanyName = CompanyName,
                            CompanyId = CompanyId,
                            DeptId = DeptId,
                            DeptName = DeptName,

                            ApproveName = Dt == null ? "" : Dt.Rows.Count > 0 ? Dt.Rows[0]["WomanWelfareName"].ToString() : "",
                            ApproveUserId = Dt == null ? "" : Dt.Rows.Count > 0 ? Dt.Rows[0]["WomanWelfareId"].ToString() : ""
                        };
                        this.SetFormData(Obj);
                    }
                }
            }
        }

    }
}


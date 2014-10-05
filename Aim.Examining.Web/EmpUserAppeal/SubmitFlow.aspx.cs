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

namespace Aim.Examining.Web.EmpUserAppeal
{
    public partial class SubmitFlow : BaseListPage
    {
        //public string UserOne,UserTwo,UserOne,UserOne
        protected void Page_Load(object sender, EventArgs e)
        {
            //提交  保存
            // UsrAppealList Ent=
            //逗号分割,

            //SubmitUser Ent = this.GetPostedData<SubmitUser>();

            switch (RequestActionString)
            {
                case "UserCk":
                    // UserCheck();
                    break;
                case "Submit"://提交流程
                    StartFlow();
                    break;
                case "AutoExecuteFlow":
                    AutoExecuteFlow();
                    break;
                default:
                    SetTreaty();
                    break;
            }
            // Ent.ResolveUser=
        }

        private void SetTreaty()
        {
            var TreatyEnt = UsrAppealTreaty.FindAll(" from UsrAppealTreaty where  State='1'").FirstOrDefault();
            this.PageState.Add("Treaty", TreatyEnt.Treaty);
        }

        //创建流程
        private void StartFlow()
        {
            string AppealId = RequestData.Get("AppealId") + "";
            //受理人
            string UserId = RequestData.Get("UserId") + "";
            string UserName = RequestData.Get("UserName") + "";
            //当前申诉人
            string submitUsrId = string.Empty, submitUsrName = string.Empty;

            UsrAppealList Ent = UsrAppealList.Find(AppealId);
            Ent.SubmitTime = DateTime.Now;
            if (Ent.IsNoName == "1")//匿名状态
            {
                submitUsrId = UserInfo.UserID;
                submitUsrName = "匿名";
            }
            else   //非匿名
            {
                submitUsrId = UserInfo.UserID;
                submitUsrName = UserInfo.Name;
            }

            string FlowKey = "EmpUsrAppeal";   //工作流key

            if (!string.IsNullOrEmpty(FlowKey))
            {
                string formUrl = "/EmpUserAppeal/UsrAppealListEdit.aspx?op=r&id=" + AppealId;
                Guid guid = Aim.WorkFlow.WorkFlow.StartWorkFlow(AppealId, formUrl, "员工申诉", FlowKey, submitUsrId, submitUsrName);
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
            Aim.WorkFlow.WorkFlow.AutoExecute(tasks[0], "受理人", UserArr);  //制定节点
        }
    }


}

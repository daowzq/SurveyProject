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
using Aim.Examining.Web.EmpWelfare;
using Aim.WorkFlow;

namespace Aim.Examining.Web
{
    public partial class UsrTravelWelfareList : ExamListPage
    {


        private IList<UsrTravelWelfare> ents = null;
        UsrTravelWelfare ent = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<UsrTravelWelfare>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        DoBatchDelete();
                    }
                    else if (RequestActionString == "CheckApply")
                    {
                        CKSubmit();
                    }
                    else if (RequestActionString == "Submit")
                    {
                        DoSubmitApply();
                    }
                    else if (RequestActionString == "AutoExecuteFlow")
                    {
                        AutoExecuteFlow();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }

        }

        //通知范围检查
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
            string UsrId = Ut.CheckApply("员工旅游", UserInfo.UserID, CorpIds);
            this.PageState.Add("State", UsrId);
        }

        //提交申诉
        private void DoSubmitApply()
        {
            string Id = RequestData.Get("Id") + "";
            var Ent = UsrTravelWelfare.TryFind(Id);
            if (Ent != null)
            {
                Ent.WorkFlowState = "1"; //提交申诉
                Ent.DoUpdate();
                this.PageState.Add("State", "1");
            }
        }

        #region 工作流
        private void StartFlow()
        {

            string id = RequestData.Get("Id") + "";
            if (!string.IsNullOrEmpty(id))
            {
                ent = UsrTravelWelfare.Find(id);
            }
            //受理人
            string UserId = ent.ApproveUserId;
            string UserName = ent.ApproveName;

            string FlowKey = "EmpUsrWelfare";   //工作流key

            if (!string.IsNullOrEmpty(FlowKey))
            {
                string formUrl = "/EmpWelfare/UsrTravelWelfareEdit.aspx?op=r&id=" + id;
                Guid guid = Aim.WorkFlow.WorkFlow.StartWorkFlow(id, formUrl, "员工旅游申请", FlowKey, UserInfo.UserID, UserInfo.Name);
                ent.WorkFlowState = "Start";
                ent.WorkFLowCode = guid.ToString(); //InstanceId WorkFlowCode WorkFLowCode
                ent.DoUpdate();
                this.PageState.Add("NextInfo", guid.ToString() + "$" + UserId + "|" + UserName);
            }

        }
        private void AutoExecuteFlow()
        {
            string NextInfo = this.RequestData.Get("NextInfo") + "";
            string IntanceId = NextInfo.Split('$')[0];
            string[] UserArr = NextInfo.Split('$')[1].Split('|');

            IList<Task> tasks = Task.FindAllByProperty(Task.Prop_WorkflowInstanceID, IntanceId);
            Aim.WorkFlow.WorkFlow.AutoExecute(tasks[0], UserArr);  //指定节点
        }
        #endregion

        #region 私有方法

        /// <summary>
        /// 查询
        /// </summary>
        private void DoSelect()
        {
            SearchCriterion.AddSearch("UserId", UserInfo.UserID);
            ents = UsrTravelWelfare.FindAll(SearchCriterion);
            this.PageState.Add("UsrTravelWelfareList", ents);
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
                UsrTravelWelfare.DoBatchDelete(idList.ToArray());
                foreach (var v in idList.ToArray())
                {
                    string sql = " delete from FL_Culture..UsrTravelInfo where WelfareTravelId='" + v + "'";
                    DataHelper.ExecSql(sql);
                }
            }
        }

        #endregion
    }
}


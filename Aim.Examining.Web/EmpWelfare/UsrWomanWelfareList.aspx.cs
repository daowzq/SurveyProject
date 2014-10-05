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
    public partial class UsrWomanWelfareList : ExamListPage
    {

        private IList<UsrWomanWelfare> ents = null;
        UsrWomanWelfare ent = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<UsrWomanWelfare>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        DoBatchDelete();
                    }
                    else if (RequestActionString == "ckNotice")
                    {
                        CKSubmit();
                    }
                    else if (RequestActionString == "Submit")
                    {
                        StartFlow();
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
            ComUtility Ut = new ComUtility();
            string NoticeId = Ut.CheckApply("三八妇女节", UserInfo.UserID, "");
            this.PageState.Add("NoticeState", NoticeId);
        }

        //创建流程
        private void StartFlow()
        {

            string id = RequestData.Get("Id") + "";
            if (!string.IsNullOrEmpty(id))
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
        private void AutoExecuteFlow()
        {
            string NextInfo = this.RequestData.Get("NextInfo") + "";
            string IntanceId = NextInfo.Split('$')[0];
            string[] UserArr = NextInfo.Split('$')[1].Split('|');

            IList<Task> tasks = Task.FindAllByProperty(Task.Prop_WorkflowInstanceID, IntanceId);
            Aim.WorkFlow.WorkFlow.AutoExecute(tasks[0], UserArr);  //指定节点
        }

        #region 私有方法

        /// <summary>
        /// 查询
        /// </summary>
        private void DoSelect()
        {
            SearchCriterion.AddSearch("UserId", UserInfo.UserID);
            ents = UsrWomanWelfare.FindAll(SearchCriterion);
            this.PageState.Add("UsrWomanWelfareList", ents);
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
                UsrWomanWelfare.DoBatchDelete(idList.ToArray());
            }
        }

        #endregion
    }
}


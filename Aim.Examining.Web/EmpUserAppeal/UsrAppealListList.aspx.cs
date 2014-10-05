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
using Aim.WorkFlow;
using System.Data;

namespace Aim.Examining.Web
{
    public partial class UsrAppealListList : ExamListPage
    {


        private IList<UsrAppealList> ents = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            UsrAppealList ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<UsrAppealList>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        DoBatchDelete();
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

        #region 流程审批
        //创建流程
        private void StartFlow()
        {
            string Id = RequestData.Get("id") + "";
            string UserId = string.Empty, UserName = string.Empty;          //受理人
            string submitUsrId = string.Empty, submitUsrName = string.Empty;//当前申诉人
            string FlowKey = "EmpUsrAppeal_1";   //工作流key
            string ApproveType = "";

            UsrAppealList Ent = UsrAppealList.Find(Id);
            if (Ent == null) return;
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
            UserId = Ent.FristAcceptUserID;
            UserName = Ent.FristAcceptUserName;
            ApproveType = "_【" + Ent.AppealTypeName + "】";

            if (!string.IsNullOrEmpty(FlowKey))
            {
                string formUrl = "/EmpUserAppeal/UsrAppealListEdit.aspx?op=r&id=" + Id;
                Guid guid = Aim.WorkFlow.WorkFlow.StartWorkFlow(Id, formUrl, "员工申诉" + ApproveType, FlowKey, submitUsrId, submitUsrName);
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
            Aim.WorkFlow.WorkFlow.AutoExecute(tasks[0], "HR专员", UserArr);  //制定节点
        }

        #endregion

        /// <summary>
        /// 查询
        /// </summary>
        private void DoSelect()
        {
            SearchCriterion.SetSearch(UsrAppealList.Prop_UserId, UserInfo.UserID);
            ents = UsrAppealList.FindAll(SearchCriterion);
            this.PageState.Add("UsrAppealListList", ents);

            EasyDictionary dic = SysEnumeration.GetEnumDict("EmpAppeal");
            dic.Add("%%", "请选择...");
            PageState.Add("AppealTypeName", dic);
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
                UsrAppealList.DoBatchDelete(idList.ToArray());
            }
        }

    }
}


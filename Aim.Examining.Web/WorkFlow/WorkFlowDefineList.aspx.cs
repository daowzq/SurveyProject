using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Aim.Data;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;
using Aim.WorkFlow;

namespace Aim.Portal.Web.WorkFlow
{
    public partial class TaskDefineList : BaseListPage
    {
        #region 属性

        #endregion

        #region 变量

        private IList<WorkflowTemplate> ents = null;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            WorkflowTemplate ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<WorkflowTemplate>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                case RequestActionEnum.Custom:
                    //启动流程
                    if (this.RequestActionString.ToLower() == "startflow")
                    {
                        Aim.WorkFlow.WorkflowTemplate ne = Aim.WorkFlow.WorkflowTemplate.Find(this.RequestData["Id"].ToString());
                        //启动流程
                        string key = ne.Code;// "NewsPub";
                        //表单路径,后面加上参数传入
                        string formUrl = "/WorkFlow/WorkFlowDefineEdit.aspx?op=u&&Id=" + ne.ID;
                        Aim.WorkFlow.WorkFlow.StartWorkFlow(ne.ID, formUrl, ne.TemplateName, key, this.UserInfo.UserID, this.UserInfo.Name);
                        PageState.Add("message", "启动成功");
                    } 
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        IList<object> idList = RequestData.GetList<object>("IdList");

                        if (idList != null && idList.Count > 0)
                        {
                            WorkflowTemplate.DoBatchDelete(idList.ToArray());
                        }
                    }
                    else
                    {
                        ents = WorkflowTemplateRule.FindAll(SearchCriterion);
                        this.PageState.Add("SysWorkFlowDefineList", ents);
                    }
                    break;
            }

        }

        #endregion

        #region 私有方法

        #endregion
    }
}


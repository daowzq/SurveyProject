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
    public partial class FlowTrace : BaseListPage
    {
        #region 属性

        #endregion

        #region 变量

        private IList<Aim.WorkFlow.Task> ents = null;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            Aim.WorkFlow.Task ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<Aim.WorkFlow.Task>();
                    ent.Delete();
                    this.SetMessage("删除成功！");
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        IList<object> idList = RequestData.GetList<object>("IdList");

                        if (idList != null && idList.Count > 0)
                        {
                            SysWorkFlowTask.DoBatchDelete(idList.ToArray());
                        }
                    }
                    else
                    {
                        SearchCriterion.SetSearch("EFormName", this.RequestData["FormId"].ToString(), SearchModeEnum.Like);
                        //SearchCriterion.SetOrder("CreatedTime", true);
                        //SearchCriterion.SetOrder("FinishTime", true);
                        ents = Aim.WorkFlow.TaskRule.FindAll(SearchCriterion).OrderBy(ens => !ens.FinishTime.HasValue ? DateTime.Now : ens.FinishTime).OrderBy(ens => ens.CreatedTime).ToArray();
                        this.PageState.Add("SysWorkFlowTaskList", ents);
                    }
                    break;
            }

        }

        #endregion

        #region 私有方法

        #endregion
    }
}


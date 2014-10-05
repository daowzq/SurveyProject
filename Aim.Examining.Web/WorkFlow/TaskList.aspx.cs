using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;

using Aim.Data;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;
using Aim.WorkFlow;
using Aim.WorkFlow.WinService;

namespace Aim.Portal.Web.WorkFlow
{
    public partial class TaskList : BaseListPage
    {
        #region 属性

        #endregion

        #region 变量

        private IList<V_Task> ents = null;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            V_Task ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<V_Task>();
                    ent.Delete();
                    this.SetMessage("删除成功！");
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        IList<object> idList = RequestData.GetList<object>("IdList");

                        if (idList != null && idList.Count > 0)
                        {
                            Aim.WorkFlow.Task.DoBatchDelete(idList.ToArray());
                        }
                    }
                    else if (this.RequestActionString.ToLower() == "startflow")
                    {
                        //启动流程
                        /*string key = "FirstFlow";
                        //表单路径,后面加上参数传入
                        string formUrl = "/EPC/PrjBasic/PrjBasicEdit.aspx?op=u";
                        Aim.WorkFlow.WorkFlow.StartWorkFlow("", formUrl, "流程的标题", key, this.UserInfo.UserID, this.UserInfo.Name);*/
                        string key = this.RequestData.Get<string>("flowkey");
                        Aim.WorkFlow.WorkflowTemplate ne = Aim.WorkFlow.WorkflowTemplate.FindAllByProperty("Code", key)[0];
                        //启动流程
                        //表单路径,后面加上参数传入
                        string formUrl = "/WorkFlow/flowdemo.htm";
                        Aim.WorkFlow.WorkFlow.StartWorkFlow(ne.ID, formUrl, ne.TemplateName, key, this.UserInfo.UserID, this.UserInfo.Name);
                        PageState.Add("message", "启动成功");
                    }
                    else
                    {
                        if (int.Parse(this.RequestData["Status"].ToString()) == 1)
                        {
                            SearchCriterion.SetSearch("Status", 4);
                            SearchCriterion.SetSearch(V_Task.Prop_FlowStatus, "Processing");
                        }
                        else if (int.Parse(this.RequestData["Status"].ToString()) == 4)
                        {
                            SearchCriterion.SetSearch("Status", 4);
                            SearchCriterion.SetSearch(V_Task.Prop_FlowStatus, "Completed");
                        }
                        else
                        {
                            SearchCriterion.SetSearch("Status", int.Parse(this.RequestData["Status"].ToString()));
                        }
                        SearchCriterion.SetSearch("OwnerId", this.UserInfo.UserID);
                        SearchCriterion.SetOrder("CreatedTime", false);
                        string dateFlag = this.RequestData["Date"] == null ? "3" : this.RequestData["Date"].ToString();
                        switch (dateFlag)
                        {
                            case "3":
                                SearchCriterion.SetSearch("CreatedTime", DateTime.Now.AddDays(-3), SearchModeEnum.GreaterThanEqual);
                                break;
                            case "7":
                                SearchCriterion.SetSearch("CreatedTime", DateTime.Now.AddDays(-7), SearchModeEnum.GreaterThanEqual);
                                break;
                            case "14":
                                SearchCriterion.SetSearch("CreatedTime", DateTime.Now.AddDays(-14), SearchModeEnum.GreaterThanEqual);
                                break;
                            case "30":
                                SearchCriterion.SetSearch("CreatedTime", DateTime.Now.AddMonths(-1), SearchModeEnum.GreaterThanEqual);
                                break;
                            case "31":
                                SearchCriterion.SetSearch("CreatedTime", DateTime.Now.AddMonths(-1), SearchModeEnum.LessThanEqual);
                                break;
                            case "100":
                                SearchCriterion.SetSearch("CreatedTime", DateTime.Now.AddMonths(100), SearchModeEnum.LessThanEqual);
                                break;
                        }
                        if (int.Parse(this.RequestData["Status"].ToString()) == 0)
                        {
                            //                            string sql = @"select * from (
                            //select ID,Title,WorkFlowInstanceId,WorkFlowName,ApprovalNodeName,CreatedTime,FinishTime,
                            //'' RelateName,'' System,'' Type,'' ExecUrl,'' RelateType,'' OwnerUserId from Task where status=0 and OwnerId='{0}') a
                            //union
                            //select * from (
                            //select Id,TaskName Title,FlowId WorkFlowInstanceId,FlowName WorkFlowName,TaskName ApprovalNodeName,CreateTime,FinishTime,RelateName,System,Type,
                            //ExecUrl,RelateType,OwnerUserId from BJKY_BeAdmin..WfWorkList where (State='New') and IsSign='{0}') b";

                            string sql = @"select * from (
select ID,Title,WorkFlowInstanceId,WorkFlowName,ApprovalNodeName,CreatedTime,FinishTime,
'' RelateName,'' System,'' Type,'' ExecUrl,'' RelateType,'' OwnerUserId from Task where status=0 and OwnerId='{0}') a";
                            sql = string.Format(sql, this.UserInfo.UserID);
                            this.PageState.Add("SysWorkFlowTaskList", GetPageData(sql, SearchCriterion));
                        }
                        else
                        {
                            ents = V_Task.FindAll(SearchCriterion);
                            this.PageState.Add("SysWorkFlowTaskList", ents);
                        }
                    }
                    break;
            }

        }

        #endregion

        #region 私有方法
        private IList<EasyDictionary> GetPageData(String sql, SearchCriterion search)
        {
            SearchCriterion.RecordCount = DataHelper.QueryValue<int>("select count(*) from (" + sql + ") t");
            string order = search.Orders.Count > 0 ? search.Orders[0].PropertyName : "CreateTime";
            string asc = search.Orders.Count <= 0 || !search.Orders[0].Ascending ? " desc" : " asc";
            string pageSql = @"
		    WITH OrderedOrders AS
		    (SELECT *,
		    ROW_NUMBER() OVER (order by {0} {1})as RowNumber
		    FROM ({2}) temp ) 
		    SELECT * 
		    FROM OrderedOrders 
		    WHERE RowNumber between {3} and {4}";
            pageSql = string.Format(pageSql, order, asc, sql, (search.CurrentPageIndex - 1) * search.PageSize + 1, search.CurrentPageIndex * search.PageSize);
            IList<EasyDictionary> dicts = DataHelper.QueryDictList(pageSql);
            return dicts;
        }
        #endregion
    }
}


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

namespace Aim.Examining.Web
{
    public partial class UsrChildWelfareList : ExamListPage
    {
        #region 变量

        private IList<UsrChildWelfare> ents = null;

        #endregion

        #region 构造函数

        #endregion


        UsrChildWelfare ent = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<UsrChildWelfare>();
                    ent.DoDelete();
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        DoBatchDelete();
                    }
                    else if (RequestActionString == "Submit")
                    {
                        DoSubmitApply();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }

        }

        //提交申诉
        private void DoSubmitApply()
        {
            string Id = RequestData.Get("Id") + "";
            var Ent = UsrChildWelfare.TryFind(Id);
            if (Ent != null)
            {
                Ent.WorkFlowState = "1"; //提交申诉
                Ent.DoUpdate();
                this.PageState.Add("State", "1");
            }
        }
        /// <summary>
        /// 查询
        /// </summary>
        private void DoSelect()
        {
            SearchCriterion.AddSearch("UserId", UserInfo.UserID);
            string where = "";
            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                if (!String.IsNullOrEmpty(item.Value.ToString()) && item.PropertyName == "Month")
                {
                    where += " month(ApplyTime)=" + item.Value.ToString() + " ";
                }
                if (!String.IsNullOrEmpty(item.Value.ToString()) && item.PropertyName == "Year")
                {
                    where += " Year(ApplyTime)=" + item.Value.ToString() + " ";
                }
            }
            if (!string.IsNullOrEmpty(where))
            {
                SearchCriterion.Searches.RemoveSearch("Month");
                SearchCriterion.Searches.RemoveSearch("Year");
                ents = UsrChildWelfare.FindAll(SearchCriterion, Expression.Sql(where));
            }
            else
            {
                ents = UsrChildWelfare.FindAll(SearchCriterion);
            }

            this.PageState.Add("UsrChildWelfareList", ents);
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
                UsrChildWelfare.DoBatchDelete(idList.ToArray());
                foreach (var v in idList.ToArray())
                {
                    string sql = " delete from FL_Culture..UsrWelfareChildInfo where ChildWelfareId='" + v + "'";
                    DataHelper.ExecSql(sql);
                }
            }
        }
    }
}


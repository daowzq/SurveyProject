using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Web.Script.Serialization;
using NHibernate.Criterion;

using Aim.Data;
using Aim.Common;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;


namespace Aim.Portal.Web.Modules.SysApp.SiteMag
{
    public partial class ParamManage : BaseListPage
    {
        #region 属性

        private SysParameterCatalog[] ents = null;

        #endregion

        #region 变量

        string id = String.Empty;   // 对象id
        IList<string> ids = null;   // 节点列表
        IList<string> pids = null;   // 父节点列表

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            id = RequestData.Get<string>("id", String.Empty);
            ids = RequestData.GetList<string>("ids");
            pids = RequestData.GetList<string>("pids");

            SysParameterCatalog ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<SysParameterCatalog>();
                    ent.ParentID = String.IsNullOrEmpty(ent.ParentID) ? null : ent.ParentID;
                    ent.Update();
                    this.SetMessage("更新成功！");
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        IList<object> idList = RequestData.GetList<object>("IdList");
                        if (idList != null && idList.Count > 0)
                        {
                            SysParameterCatalog.DoBatchDelete(idList.ToArray());
                        }
                    }
                    else
                    {
                        // 构建查询表达式
                        SearchCriterion sc = new HqlSearchCriterion();

                        // sc.SetOrder("SortIndex");
                        sc.SetOrder("CreatedDate");

                        ICriterion crit = null;

                        if (RequestActionString == "querychildren")
                        {
                            if (ids != null && ids.Count > 0 || pids != null && pids.Count > 0)
                            {
                                if (ids != null && ids.Count > 0)
                                {
                                    IEnumerable<string> distids = ids.Distinct().Where(tent => !String.IsNullOrEmpty(tent));
                                    crit = Expression.In("ParameterCatalogID", distids.ToArray());
                                }

                                if (pids != null && pids.Count > 0)
                                {
                                    IEnumerable<string> dispids = pids.Distinct().Where(tent => !String.IsNullOrEmpty(tent));

                                    if (crit != null)
                                    {
                                        crit = SearchHelper.UnionCriterions(crit, Expression.In("ParentID", dispids.ToArray()));
                                    }
                                    else
                                    {
                                        crit = Expression.In("ParentID", dispids.ToArray());
                                    }
                                }
                            }
                        }
                        else
                        {
                            crit = SearchHelper.UnionCriterions(Expression.IsNull("ParentID"),
                                Expression.Eq("ParentID", String.Empty));
                        }

                        if (crit != null)
                        {
                            ents = SysParameterCatalogRule.FindAll(sc, crit);
                        }
                        else
                        {
                            ents = SysParameterCatalogRule.FindAll(sc);
                        }

                        this.PageState.Add("DtList", ents);
                    }

                    break;
            }
        }

        #endregion
    }
}

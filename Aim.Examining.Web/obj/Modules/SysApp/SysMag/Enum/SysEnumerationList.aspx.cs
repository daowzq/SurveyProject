using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;


namespace Aim.Portal.Web.Modules.SysApp.SysMag
{
    public partial class SysEnumerationList : BaseListPage
    {
        #region 属性

        #endregion

        #region 变量

        string cid = String.Empty;   // 对象分类id

        private SysParameter[] ents = null;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            cid = RequestData.Get<string>("cid");

            SysParameter ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<SysParameter>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                case RequestActionEnum.Custom:
                    IList<object> idList = RequestData.GetList<object>("IdList");

                    if (idList != null && idList.Count > 0)
                    {
                        if (RequestActionString == "batchdelete")
                        {                            
                            SysParameter.DoBatchDelete(idList.ToArray());
                        }
                    }
                    break;
                default:
                    if (!String.IsNullOrEmpty(cid))
                    {
                        SearchCriterion.SetOrder("SortIndex");
                        SearchCriterion.SetSearch("CatalogID", cid);

                        ents = SysParameterRule.FindAll(SearchCriterion);
                        this.PageState.Add("SysEnumerationList", ents);
                    }
					break;
            }
            
        }

        #endregion

        #region 私有方法

        /// <summary>
        /// 查询
        /// </summary>
        private void DoSelect()
        {
        }

        #endregion
    }
}


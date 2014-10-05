using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Text;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using NHibernate.Criterion;
using System.Data;
namespace Aim.Portal.Web.CommonPages
{
    public partial class RolSelView : BaseListPage
    {
        #region 变量

        string op = String.Empty;
        string cid = String.Empty;   // 对象id
        string type = String.Empty; // 查询类型
        string ctype = String.Empty; // 分类类型

        private IList<SysRole> ents = new List<SysRole>();

        #endregion

        #region 构造函数

        public RolSelView()
        {
            SearchCriterion.CurrentPageIndex = 1;
            SearchCriterion.PageSize = 100; // 一次最多显示100个角色
        }

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            cid = RequestData.Get<string>("cid", String.Empty);
            type = RequestData.Get<string>("type", String.Empty).ToLower();
            ctype = RequestData.Get<string>("ctype", "role").ToLower();

            if (!String.IsNullOrEmpty(cid))
            {
                try
                {
                    int icid = Convert.ToInt32(cid);

                    SearchCriterion.AddSearch("Type", icid);

                    ents = SysRoleRule.FindAll(SearchCriterion);
                }
                catch { }
            }
            else
            {
                ents = SysRoleRule.FindAll(SearchCriterion);
            }

            this.PageState.Add("DtList", ents);
        }

        #endregion

        #region 私有方法

        #endregion
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using Aim.Examining.Web;

namespace Aim.Portal.Web.CommonPages
{
    public partial class FrmRoleSelView : ExamBasePage
    {
        #region 变量

        private SysRole[] ents = null;

        #endregion

        #region 构造函数

        public FrmRoleSelView()
        {
            IsCheckLogon = false;
        }

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            // 若未对SortIndex和CreateTime进行排序，在这里进行排序
            if (!SearchCriterion.HasOrdered("SortIndex") && SearchCriterion.HasOrdered("CreateTime"))
            {
                SearchCriterion.SetOrder("SortIndex");
                SearchCriterion.SetOrder("CreateTime");
            }

            ents = SysRole.FindAll(SearchCriterion);

            this.PageState.Add("DtList", ents);
        }

        #endregion
    }
}

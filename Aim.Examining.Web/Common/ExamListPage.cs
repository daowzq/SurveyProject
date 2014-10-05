using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Newtonsoft.Json;
using Aim.Common;
using Aim.Common.Authentication;
using Aim.Data;
using Aim.Portal.Model;
using Aim.Portal.Web.UI;

namespace Aim.Examining.Web
{
    public class ExamListPage : ExamBasePage
    {
        #region 私有成员

        #endregion

        #region 属性

        /// <summary>
        /// 是否允许分页
        /// </summary>
        public bool AllowPaging
        {
            get { return SearchCriterion.AllowPaging; }
            set { SearchCriterion.AllowPaging = value; }
        }

        #endregion

        #region 构造函数

        public ExamListPage()
        {
            SearchCriterion.AllowPaging = true;
            SearchCriterion.GetRecordCount = true;
        }

        #endregion

        #region 事件

        protected override void Page_PreRender(object sender, EventArgs e)
        {
            PageState.Add(SearchCriterionStateKey, SearchCriterion);

            base.Page_PreRender(sender, e);
        }

        #endregion
    }
}

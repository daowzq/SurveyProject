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
    public partial class FrmUsrSelView : BaseListPage
    {
        #region 变量

        string op = String.Empty;
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 查询类型
        string ctype = String.Empty; // 分类类型

        private IList<SysUser> users = new List<SysUser>();

        #endregion

        #region 构造函数

        public FrmUsrSelView()
        {
            IsCheckLogon = false;

            SearchCriterion.CurrentPageIndex = 1;
            SearchCriterion.PageSize = 100; // 一次最多显示100人
        }

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            id = RequestData.Get<string>("id", String.Empty);
            type = RequestData.Get<string>("type", String.Empty).ToLower();
            ctype = RequestData.Get<string>("ctype", "user").ToLower();

            if (ctype == "group")
            {
                if (!String.IsNullOrEmpty(id))
                {
                    ICriterion cirt = null;

                    if (type == "gtype")
                    {
                        cirt = Expression.Sql("UserID IN (SELECT UserID FROM SysUserGroup WHERE GroupID IN (SELECT GroupID FROM SysGroup WHERE Type = ?))", id, NHibernateUtil.String);
                    }
                    else
                    {
                        // 应该同时获取子组用户
                        cirt = Expression.Sql("UserID IN (SELECT UserID FROM SysUserGroup WHERE GroupID IN (SELECT GroupID FROM SysGroup WHERE GroupID = ? OR Path LIKE '%" + id + "%'))",
                            id, NHibernateUtil.String);
                    }
                    SearchCriterion.AutoOrder = false;
                    SearchCriterion.SetOrder(SysUser.Prop_WorkNo);
                    users = SysUserRule.FindAll(SearchCriterion, cirt);
                }
                this.PageState.Add("UsrList", users);
            }
            else
            {
                SearchCriterion.AutoOrder = false;

                string dName = SearchCriterion.GetSearchValue<string>("Name");
                string workNo = SearchCriterion.GetSearchValue<string>("WorkNo");
                SearchCriterion.SetOrder(SysUser.Prop_WorkNo);
                if (dName != null && dName.Trim() != "")
                {
                    string where = "select * from SysUser where " + GetPinyinWhereString("Name", dName);
                    where += " and WorkNo like '%" + workNo + "%'";
                    this.PageState.Add("UsrList", DataHelper.QueryDictList(where));
                }
                else
                {
                    users = SysUserRule.FindAll(SearchCriterion);
                    this.PageState.Add("UsrList", users);
                }
            }

        }
        public string GetPinyinWhereString(string fieldName, string pinyinIndex)
        {
            string[,] hz = Tool.GetHanziScope(pinyinIndex);
            string whereString = "(";
            for (int i = 0; i < hz.GetLength(0); i++)
            {
                whereString += "(SUBSTRING(" + fieldName + ", " + (i + 1) + ", 1) >= '" + hz[i, 0] + "' AND SUBSTRING(" + fieldName + ", " + (i + 1) + ", 1) <= '" + hz[i, 1] + "') AND ";
            }
            if (whereString.Substring(whereString.Length - 4, 4) == "AND ")
                return whereString.Substring(0, whereString.Length - 4) + ")";
            else
                return "(1=1)";
        }
        #endregion

        #region 私有方法

        #endregion
    }
}

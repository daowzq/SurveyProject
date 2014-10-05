using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Web.Script.Serialization;

using Aim.Data;
using Aim.Common;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;
using Aim.Utilities;


namespace Aim.Portal.Web.Modules.SysApp.MdlMag
{
    public partial class AuthUser : BaseListPage
    {
        #region 属性

        private SysUser[] ents = null;

        #endregion

        #region 变量

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            SearchCriterion.AutoOrder = false;
            SearchCriterion.SetOrder(SysUser.Prop_WorkNo);
            string dName = SearchCriterion.GetSearchValue<string>("Name");
            if (dName != null && dName.Trim() != "")
            {
                string where = "select * from SysUser where " + GetPinyinWhereString("Name", dName);
                this.PageState.Add("UsrList", DataHelper.QueryDictList(where));
            }
            else
            {
                ents = SysUserRule.FindAll(SearchCriterion);
                this.PageState.Add("UsrList", ents);
            }
            if (this.IsAsyncRequest)
            {
                switch (this.RequestAction)
                {
                    case RequestActionEnum.Custom:
                        if (RequestActionString == "querychildren")
                        {
                            string id = (RequestData.ContainsKey("ID") ? RequestData["ID"].ToString() : String.Empty);
                            string ttype = RequestData["Type"].ToString().ToLower();

                            if (RequestData.ContainsKey("Type"))
                            {
                                if (ttype == "atype")  // 1为入口权限
                                {
                                    SysAuth[] auths = SysAuth.FindAll("FROM SysAuth as ent WHERE ent.Type = ?", id);

                                    this.PageState.Add("DtList", auths);
                                }
                            }
                        }
                        break;
                    default:
                        break;
                }
            }
            else
            {
                SysAuthType[] authTypeList = SysAuthTypeRule.FindAll();
                this.PageState.Add("DtList", authTypeList);
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
    }
}

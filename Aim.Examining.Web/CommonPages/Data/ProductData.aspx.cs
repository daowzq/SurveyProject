using System;
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
using Aim.Utilities;
using System.Configuration;

namespace Aim.Examining.Web.CommonPages.Data
{
    public partial class ProductData : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (this.Request["cmd"] != null && this.Request["cmd"] == "GETUSERS")
            {
                if (this.Request["query"] != "")
                {
                    string db = ConfigurationManager.AppSettings["ExamineDB"];
                    string where = "select *," + db + ".dbo.fun_getProQuantity(Id) as StockQuantity, " + db + ".dbo.fun_getDestinePro(Id,'') as DestineCount from " + db + "..Products where " + GetPinyinWhereString("Name", this.Request["query"]);
                    Response.Write("{success:true,rows:" + JsonHelper.GetJsonString(DataHelper.QueryDictList(where)) + "}");
                    Response.End();
                }
                else
                {
                    Response.Write("{success:true,rows:[]}");
                    Response.End();
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
    }
}

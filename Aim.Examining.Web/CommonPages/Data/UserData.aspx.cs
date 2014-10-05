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

namespace Aim.Examining.Web.CommonPages.Data
{
    public partial class UserData : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            if (this.Request["cmd"] != null && this.Request["cmd"] == "GETUSERS")
            {
                // string querytype = Request["querytype"] + "";   //扩展查询参数
                //querytype:ApproveRoleId|1007571000000014O6J5;
                string querytype = "";
                if (this.Request["query"] != "")
                {
                    string sexsql = "";

                    string where = string.Empty;

                    if (querytype.Contains("selsex"))
                    {
                        sexsql = " and Sex='" + querytype.Split('|')[1] + "'";
                    }
                    if (querytype.Contains("ApproveRoleId"))
                    {
                        where = @"select top 30 * from SysUser where UserID in
	                                (
	                                select B.UserID from  SysRole As A
		                                left join  SysUserGroup As B
			                                on  A.RoleID=B.GroupID
		                                where A.RoleID='{0}'
	                                ) 
                                 and  (" + GetPinyinWhereString("Name", this.Request["query"]);
                        where += " or workno like '%" + this.Request["query"] + "%')";
                        where += "  and isnull(outdutydate,'')='' and Status='1' ";
                        where = string.Format(where, querytype.Split('|')[1]);

                    }
                    else
                    {
                        where = "select top 30 * from SysUser where (" + GetPinyinWhereString("Name", this.Request["query"]);
                        where += " or workno like '%" + this.Request["query"] + "%')";
                        where += " and isnull(outdutydate,'')='' and Status='1' ";
                        where += where + sexsql;
                    }

                    //where = "select * from SysUser where " + GetPinyinWhereString("Name", this.Request["query"]) + sexsql;
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

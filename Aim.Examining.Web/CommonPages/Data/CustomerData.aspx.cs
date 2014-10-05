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
using System.Text.RegularExpressions;

namespace Aim.Examining.Web.CommonPages.Data
{
    public partial class CustomerData : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (this.Request["cmd"] != null && this.Request["cmd"] == "GetCustomer")
            {
                string input = this.Request["query"];
                //if (input != "" && !Regex.IsMatch(input, @"^[\u4e00-\u9fa5]+$"))
                if (true)
                {
                    string sql = Request["selsql"];
                    string selColName = Request["selColName"];
                    string SelData = Request["SelData"];
                    //string db = System.Configuration.ConfigurationManager.AppSettings["PurchaseDB"];

                    string where = "";
                    //要按公司过滤的
                    if (SelData == "P_Supplier" || SelData == "CostItem" || SelData == "BusinessItem" || SelData == "BankAccount")
                    {
                        string where2 = selColName + " like '%" + input + "%' ";
                        if (selColName.Contains(','))
                        {
                            where2 = " (";
                            int i = 0;
                            foreach (string streach in selColName.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                            {
                                if (i == 0)
                                {
                                    where2 += streach + " like '%" + input + "%' ";
                                }
                                else
                                {
                                    where2 += " or " + streach + " like '%" + input + "%' ";
                                }
                                i++;
                            }
                            where2 += ") ";
                        }

                        string pk_corp = Request["CompanyId"] + "";
                        if (pk_corp.Length > 20)
                        {
                            pk_corp = DataHelper.QueryValue("select PK_YY from SysGroup where GroupId='" + pk_corp + "'") + "";
                        }

                        where = sql + " where (pk_corp='" + pk_corp + "' or pk_corp='0001' or pk_corp='1001') and " + where2;
                        if (SelData == "CostItem")
                        {
                            //收支项目只取当前公司数据
                            where = sql + " where (pk_corp='" + pk_corp + "') and " + where2;
                        }
                        /*if (string.IsNullOrEmpty(pk_corp))
                        {
                            where = sql + " where (pk_corp='" + pk_corp + "' or pk_corp='0001' or pk_corp='1001') and " + where2;
                        }
                        else
                        {
                            where = sql + " where (pk_corp='" + pk_corp + "') and " + where2;
                        }*/

                        if (SelData == "BankAccount")
                        {
                            where = where.Replace("pk_corp", "OwnerCorp");
                        }
                    }
                    else
                    {
                        if (selColName.Contains(','))
                        {
                            if (!sql.Contains("where"))
                            {
                                where = sql + " where ";
                            }
                            else
                            {
                                where = sql + " and ";
                            }
                            int i = 0;
                            where += " ( ";
                            foreach (string streach in selColName.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                            {
                                if (i == 0)
                                {
                                    where += streach + " like '%" + input + "%' ";
                                }
                                else
                                {
                                    where += " or " + streach + " like '%" + input + "%' ";
                                }
                                i++;
                            }
                            where += " ) ";
                        }
                        else
                        {
                            if (!sql.Contains("where"))
                            {
                                where = sql + " where " + selColName + " like '%" + input + "%' or  (" + GetPinyinWhereString("Name", this.Request["query"]) + " and corpCode is not null )";
                            }
                            else
                            {
                                where = sql + " and " + selColName + " like '%" + input + "%' or  (" + GetPinyinWhereString("Name", this.Request["query"]) + " and corpCode is not null )";
                            }
                        }
                    }
                    Response.Write("{success:true,rows:" + JsonHelper.GetJsonString(DataHelper.QueryDictList(where)) + "}");
                    Response.End();
                }

                //else if (this.Request["query"] != "")
                //{
                //    string db = System.Configuration.ConfigurationManager.AppSettings["ExamineDB"];
                //    string where = "select * from " + db + "..Customers where " + GetPinyinWhereString("Name", this.Request["query"]);
                //    Response.Write("{success:true,rows:" + JsonHelper.GetJsonString(DataHelper.QueryDictList(where)) + "}");
                //    Response.End();
                //}
                //else
                //{
                //    Response.Write("{success:true,rows:[]}");
                //    Response.End();
                //}
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

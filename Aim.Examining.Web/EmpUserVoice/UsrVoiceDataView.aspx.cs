using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using NHibernate.Criterion;
using System.Data;
using Aim.Examining.Web.Common;

namespace Aim.Examining.Web.EmpUserVoice
{
    public partial class UsrVoiceDataView : ExamListPage
    {
        string nodeName = string.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            nodeName = HttpUtility.UrlDecode(RequestData.Get<string>("nodeName")) + "";
            DoSelect();
        }

        private void DoSelect()
        {
            // 角色 根据公司,部门找到配置的HR,然后具有查看权限
            string where = string.Empty, Company = string.Empty;
            string sql = @"select B.WorkNo,A.*,A.CorpName+'/'+A.DeptName As Org from FL_Culture..EmpVoiceAskQuestion As A
                        left join FL_PortalHR..SysUser As B
                        on A.CreateId=B.UserID
                        where 1=1 and Category<>''  ";
            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);

            //公司权限
            CommPowerSplit ps = new CommPowerSplit();
            if (!ps.IsEmpVoiceRole(UserInfo.UserID, UserInfo.LoginName))
            {
                //获取人员部门
                var UsrEnt = SysUser.Find(UserInfo.UserID);
                string SQL = @"with GetTree
                                as
                                (
	                                select * from HR_OA_MiddleDB..fld_bmml where pk_deptdoc='{0}'
	                                union all
	                                select A.*
	                                from HR_OA_MiddleDB..fld_bmml As A 
	                                join GetTree as B 
	                                on  A.pk_deptdoc=B.pk_fathedept
                                )
	                           select deptname+',' as [text()] from getTree FOR XML PATH('') ";
                SQL = SQL.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
                SQL = string.Format(SQL, UsrEnt.Pk_deptdoc);
                string DeptPathStr = DataHelper.QueryValue(SQL).ToString();
                DeptPathStr = string.IsNullOrEmpty(DeptPathStr) ? "" : DeptPathStr;


                //找到配置的HR专员(HRUsrId)
                SQL = @"select top 1 *,
                                case when patindex('%'+DeptName+'%','{1}')=0  then 100
                                     else  patindex('%'+DeptName+'%','{1}') 
                                end  As SortIndex 
                                from FL_Culture..SysApproveConfig As A
                                where A.CompanyId='{0}' and HRUsrId is not null
                                and ( HRUsrId='{2}' or HRManagerId='{2}'  ) order by SortIndex";

                // 判断公司登陆
                UserContextInfo UC = new UserContextInfo();
                Company = UC.GetUserCurrentCorpId(UserInfo.UserID);
                
                SQL = string.Format(SQL, Company, DeptPathStr, UserInfo.UserID);

                DataTable dt = DataHelper.QueryDataTable(SQL);
                if (dt.Rows.Count > 0)
                {
                    where += "  and  CorpId= '" + Company + "' ";
                }
                else
                {
                    where += "  and  1<>1 ";
                }
            }
            //分类
            if (!string.IsNullOrEmpty(nodeName) && (nodeName != "所有分类") && nodeName != "null")
            {
                sql += " and Category='" + nodeName + "' ";
            }
            sql += where;

            string qry = "";
            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                if (!String.IsNullOrEmpty(item.Value.ToString()))
                {
                    switch (item.PropertyName)
                    {
                        case "StartTime":
                            qry += " and CreateTime>='" + item.Value + "' ";
                            break;
                        case "EndTime":
                            qry += " and CreateTime<='" + (item.Value.ToString()).Replace(" 0:00:00", " 23:59:59") + "' ";
                            break;
                        default:
                            qry += " and " + item.PropertyName + " like '%" + item.Value + "%' ";
                            break;
                    }
                }
            }
            sql += qry;
            SearchCriterion.SetOrder(EmpVoiceAskQuestion.Prop_CreateTime);
            OrderCriterionItem oci1 = new OrderCriterionItem(EmpVoiceAskQuestion.Prop_CreateTime);
            SearchCriterion.Orders.Add(oci1);
            this.PageState.Add("DataList", GetPageData(sql, SearchCriterion));
        }

        private IList<EasyDictionary> GetPageData(String sql, SearchCriterion search)
        {
            SearchCriterion.RecordCount = DataHelper.QueryValue<int>("select count(*) from (" + sql + ") t");
            //string order = search.Orders.Count > 0 ? search.Orders[0].PropertyName : "CreateTime";
            //string asc = search.Orders.Count <= 0 || !search.Orders[0].Ascending ? " desc" : " asc";

            int ids = 0;
            string orderSql = "";
            foreach (OrderCriterionItem ord in search.Orders)
            {

                if (ids != 0) orderSql += ",";
                string asc = ord.Ascending ? "desc" : "asc";
                orderSql += ord.PropertyName + " " + asc;
                ids++;

            }
            if (string.IsNullOrEmpty(orderSql))
            {
                orderSql += " CreateTime desc ";
            }

            string pageSql = @"
		    WITH OrderedOrders AS
		    (SELECT *,
		    ROW_NUMBER() OVER (order by {0} {1})as RowNumber
		    FROM ({2}) temp ) 
		    SELECT * 
		    FROM OrderedOrders 
		    WHERE RowNumber between {3} and {4}";
            pageSql = string.Format(pageSql, orderSql, "", sql, (search.CurrentPageIndex - 1) * search.PageSize + 1, search.CurrentPageIndex * search.PageSize);
            IList<EasyDictionary> dicts = DataHelper.QueryDictList(pageSql);
            return dicts;
        }


        public ArrayList getCompany()
        {
            var Ent = SysUser.FindFirstByProperties("UserID", UserInfo.UserID);
            //公司与部门
            string SQL = @"select B.GroupID As CompanyId,B.Name As CompanyName,C.GroupID AS DeptId,C.Name As DeptName
                        from  sysuser As A
	                        left join sysgroup As B
	                        on A.pk_corp=B.groupID
                        left join sysgroup As C
	                        on C.GroupID=A.pk_deptdoc
                        where A.UserID='{0}'";
            SQL = string.Format(SQL, UserInfo.UserID);
            System.Data.DataTable Dt1 = DataHelper.QueryDataTable(SQL);

            string CompanyName = string.Empty, CompanyId = string.Empty;
            string DeptName = string.Empty, DeptId = string.Empty;
            ArrayList arr = new ArrayList();
            if (Dt1.Rows.Count > 0)
            {
                CompanyName = Dt1.Rows[0]["CompanyName"].ToString();
                CompanyId = Dt1.Rows[0]["CompanyId"].ToString();
                DeptId = Dt1.Rows[0]["DeptId"].ToString();
                DeptName = Dt1.Rows[0]["DeptName"].ToString();
                arr.Add(CompanyName);       //公司名称
                arr.Add(CompanyId);          //公司ID
                arr.Add(DeptId);             //部门名称
                arr.Add(DeptName);           //部门ID

            }
            return arr;

        }
    }
}

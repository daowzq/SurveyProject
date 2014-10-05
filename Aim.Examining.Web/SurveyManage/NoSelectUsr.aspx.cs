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
using System.Text;
using System.Data;
namespace Aim.Examining.Web.SurveyManage
{
    public partial class NoSelectUsr : BaseListPage
    {
        public NoSelectUsr()
        {
            SearchCriterion.PageSize = 60;
        }
        //传递的参数
        string OrgIds, PostionNames, Sex, AgeRange, StartWorkTime, UntileWorkTime, WorkAge;
        protected void Page_Load(object sender, EventArgs e)
        {
            Sex = RequestData.Get("Sex") + "";
            OrgIds = RequestData.Get("OrgIds") + "";
            PostionNames = RequestData.Get("PostionNames") + "";
            AgeRange = RequestData.Get("AgeRange") + "";
            StartWorkTime = RequestData.Get("StartWorkTime") + "";
            UntileWorkTime = RequestData.Get("UntileWorkTime") + "";
            WorkAge = RequestData.Get("WorkAge") + "";

            DoSelect();
        }


        private void DoSelect()
        {

            //处理查询条件
            StringBuilder where = new StringBuilder();
            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                if (!String.IsNullOrEmpty(item.Value.ToString()))
                {
                    where.Append(" and " + item.PropertyName + " like '%" + item.Value + "%' ");
                }
            }

            if (!string.IsNullOrEmpty(Sex)) //性别
            {
                if (Sex == "man")
                    where.Append(" and Sex='男' ");
                else if (Sex == "woman")
                    where.Append(" and Sex='女' ");
            }

            // 入职日期判断
            if (!string.IsNullOrEmpty(StartWorkTime) && !string.IsNullOrEmpty(UntileWorkTime))
            {
                where.Append(" and ( C.IndutyDate >= '" + StartWorkTime + "' and C.IndutyDate <= '" + UntileWorkTime + "' )");
            }
            else if (!string.IsNullOrEmpty(StartWorkTime) && string.IsNullOrEmpty(UntileWorkTime))
            {
                where.Append(" and ( C.IndutyDate >= '" + StartWorkTime + "' )");
            }
            else if (string.IsNullOrEmpty(StartWorkTime) && !string.IsNullOrEmpty(UntileWorkTime))
            {
                where.Append(" and ( C.IndutyDate <= '" + UntileWorkTime + "' )");
            }

            if (!string.IsNullOrEmpty(AgeRange) && AgeRange != "0")     // 年龄范围
            {
                string tempQry = string.Empty;
                string[] arr = AgeRange.Split(',');
                for (int i = 0; i < arr.Length; i++)
                {
                    if (i > 0) tempQry += " Or ";
                    if ((arr[i] + "").Contains(">50"))
                    {
                        tempQry += "  Age>50  ";
                    }
                    else
                    {
                        if (arr[i].Contains("-"))
                        {
                            string[] temp = (arr[i] + "").Split('-');
                            tempQry += " Age between " + temp[0] + " and " + temp[1] + " ";
                        }
                    }
                }
                if (!string.IsNullOrEmpty(tempQry))
                    where.Append(" and (" + tempQry + ") ");
            }
            if (!string.IsNullOrEmpty(WorkAge) && WorkAge != "0")    //工作年限
            {
                if (WorkAge == ">3")
                {
                    where.Append(" and datediff(year,C.IndutyDate,getdate()) > 3 ");
                }
                else if (WorkAge == ">5")
                {
                    where.Append(" and datediff(year,C.IndutyDate,getdate()) > 5 ");
                }
            }

            // 最后去除离职的 
            where.Append(" and ( C.OutdutyDate is null or C.OutdutyDate='' ) ");

            //组织结构
            string GroupIDSQL = string.Empty, PathSQL = string.Empty;
            if (!string.IsNullOrEmpty(OrgIds))
            {
                string[] temArr = OrgIds.Split(',');
                GroupIDSQL = " and ( ";
                PathSQL = " and ( ";
                for (int i = 0; i < temArr.Length; i++)
                {
                    if (i > 0)
                    {
                        GroupIDSQL += " OR ";
                        PathSQL += " OR ";
                    }
                    GroupIDSQL += "  GroupID = '" + temArr[i] + "' ";
                    PathSQL += "  Path like '%" + temArr[i] + "%' ";
                }
                GroupIDSQL += " ) ";
                PathSQL += " ) ";
            }

            //  string SQL = @"select distinct *  from  (
            //                          select newid() as Id, C.UserID,C.Name from  
            //  	                        (
            //  		                        select GroupID,Name,Type from FL_PortalHR..SysGroup where 1=1  ##GroupID##   
            //  		                        union 
            //  		                        select GroupID,Name,Type from FL_PortalHR..SysGroup where 1=1  ##Path##
            //  	                        ) As A
            //  		                 left join FL_PortalHR..SysUserGroup  As B 
            //  		                        on A.GroupID=B.GroupID
            //  	                     left join FL_PortalHR..SysUser  As C	
            //  		                        on C.UserID=B.UserID
            //                            where 1=1  ##where##  
            //                         ) As T
            //                         cross Apply ( --  获取人员组织
            //                           select  STUFF((
            //                          select  ',' +G.Name  As [text()] from FL_PortalHR..sysuser As A 
            //                          left join FL_PortalHR..SysUserGroup As B 
            //  	                        on A.UserID=B.UserID
            //                          left join FL_PortalHR..sysgroup As G
            //  	                        on G.GroupID=B.GroupID
            //                          where A.UserID=T.UserID
            //                          for xml path('')),1,1,'')  As GroupName
            //                         	 
            //                         ) As CA        
            //                         where UserID is not null ";

            string SQL = @" select newid() AS Id, C.UserID,C.Name,C.WorkNo,T.jobname As JobName 
                            from
   		                        (
   			                         select GroupID,Name,Type from FL_PortalHR..SysGroup where 1=1  ##GroupID##   
   										union 
   			                        select GroupID,Name,Type from FL_PortalHR..SysGroup where 1=1  ##Path##   
   		                        ) As A
   			                 left join FL_PortalHR..SysUserGroup  As B 
   			                        on A.GroupID=B.GroupID
   		                     left join FL_PortalHR..SysUser  As C	
   			                        on C.UserID=B.UserID
                             left join HR_OA_MiddleDB..fld_gw AS T
	                                    on C.Pk_gw=T.pk_jobcode
   	                         where C.UserID is not null  ##where##  ";


            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
            SQL = SQL.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);

            SQL = SQL.Replace("##GroupID##", GroupIDSQL);
            SQL = SQL.Replace("##Path##", PathSQL);
            SQL = SQL.Replace("##where##", where.ToString());
            //DataHelper.ExecSql(SQL);

            //筛选职位
            string split = string.Empty;
            if (!string.IsNullOrEmpty(PostionNames))
            {
                string[] tempArr = PostionNames.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                for (int j = 0; j < tempArr.Length; j++)
                {
                    if (j > 0) split += " or ";
                    split += " JobName like  '%" + tempArr[j] + "%' ";
                }
                SQL += " and " + split;
            }

            this.PageState.Add("DataList", GetPageData(SQL, SearchCriterion));
            //this.PageState.Add("DataList", SysGroup.FindAll(SearchCriterion, Expression.Sql(SQL)));

        }
        private IList<EasyDictionary> GetPageData(String sql, SearchCriterion search)
        {
            SearchCriterion.RecordCount = DataHelper.QueryValue<int>("select count(*) from (" + sql + ") t");
            string pageSql = @"
		    WITH OrderedOrders AS
		    (SELECT *,
		    ROW_NUMBER() OVER (order by {0} )as RowNumber
		    FROM ({1}) temp ) 
		    SELECT * 
		    FROM OrderedOrders 
		    WHERE RowNumber between {2} and {3}";
            pageSql = string.Format(pageSql, "Id", sql, (search.CurrentPageIndex - 1) * search.PageSize + 1, search.CurrentPageIndex * search.PageSize);
            IList<EasyDictionary> dicts = DataHelper.QueryDictList(pageSql);
            return dicts;
        }


    }
}

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
using Aspose.Cells;
using Aim.Examining.Web.Common;

namespace Aim.Examining.Web.ReportSheet
{
    public partial class Welfare_Child : BaseListPage
    {
        public Welfare_Child()
        {
            SearchCriterion.PageSize = 60;
        }
        private string type = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            type = RequestData.Get("type") + "";
            switch (RequestActionString)
            {
                case "AppSubmit":
                    AppSubmit();
                    break;
                case "ImpExcel":
                    ImpExcel();
                    break;
                default:
                    DoSelect();
                    break;
            }
        }

        private void ImpExcel()
        {
            var year = RequestData.Get("year") + "";
            var WorkFlowState = RequestData.Get("WorkFlowState") + "";
            var WelfareType = RequestData.Get("WelfareType") + "";
            var month = RequestData.Get("month") + "";
            var type = RequestData.Get("type") + "";
            var DealState = RequestData.Get("DealState") + "";

            string where = string.Empty;
            if (string.IsNullOrEmpty(year))
            {
                year = DateTime.Now.Year + "";
                where += " and Year(ApplyTime)=" + year + " ";
            }
            else
            {
                where += " and Year(ApplyTime)=" + year + " ";
            }
            //处理结果
            if (!string.IsNullOrEmpty(DealState))
            {
                where += " and WorkFlowState='" + DealState + "' ";
            }

            //月份
            if (!string.IsNullOrEmpty(month))
            {
                where += " and Month(ApplyTime)=" + month + " ";
            }

            //未处理
            if (type == "n")
            {
                where += " and  A.WorkFlowState='1' ";
            }
            else //已处理
            {
                where += " and (WorkFlowState='2' or WorkFlowState='-1') ";
            }


            //审批意见 
            if (!string.IsNullOrEmpty(WorkFlowState))
            {
                where += " and  A.WorkFlowState='" + WorkFlowState + "' ";
            }

            CommPowerSplit ps = new CommPowerSplit();
            if (!ps.IsNoticeRole(UserInfo.UserID, UserInfo.LoginName))
            {
                where += AppealUsrAuth();
            }

            string SQL = @" select  distinct
                                 Year(A.ApplyTime) As Year,Month(A.ApplyTime) As Month, A.UserName,A.WorkNo,A.CompanyName,A.DeptName,
                                 convert(varchar(10),A.IndutyData,120) As IndutyDate,
                                 A.Sex,A.OtherUserName,A.OtherIdentityCard,A.OSex,
                                 C.UsrName as  ChildName,C.Sex As ChildSex,C.IDCartNo AS  ChildIDCard,C.IDType,
                                 case   
                                    when  A.WorkFlowState='2'  then '同意'
                                    when  A.WorkFlowState='-1'  then '不同意'
                                 end  As State,
	                             case
		                            when A.IsSingleChild='Y' then '是'
		                            when A.IsSingleChild='N' then '否'
	                             end As IsSingleChild,
                                  case 
									when A.IsDoubleWorker='Y' then '是'
									when A.IsDoubleWorker='N' then '否'
								 end As IsDoubleWorker,
								 OtherUserWorkNo
                           from  FL_Culture..UsrChildWelfare As A
                            left join  FL_Culture..UsrWelfareChildInfo As C
                              on C.ChildWelfareId=A.Id 
                           where A.Id is not null ";
            SQL += where;

            //导出SQL
            string childSQL = string.Empty, dbleSQL = string.Empty;
            if (WelfareType == "double")
            {
                dbleSQL = SQL + " and C.BeRelation='配偶' ";
            }
            else if (WelfareType == "child")
            {
                childSQL = SQL + " and C.BeRelation='子女' ";
            }
            else
            {
                dbleSQL = SQL + " and C.BeRelation='配偶' ";
                childSQL = SQL + " and C.BeRelation='子女' ";
            }

            string xlsNameDouble = "员工保险汇总表_配偶保险" + "_" + System.DateTime.Now.ToString("yyyMMddhhmmss");
            string xlsNameChild = "员工保险汇总表_子女保险" + "_" + System.DateTime.Now.ToString("yyyMMddhhmmss");

            DataTable dble = null;
            DataTable child = null;

            string url = System.Configuration.ConfigurationManager.AppSettings["SurveyUrl"] + "";
            if (string.IsNullOrEmpty(WelfareType))
            {
                child = DataHelper.QueryDataTable(childSQL);
                dble = DataHelper.QueryDataTable(dbleSQL);

                string fileName = string.Empty;
                {
                    string FullPath = @"/Excel/EmpChild.xls";
                    if (url.Contains("FD")) FullPath = @"/FD/Excel/EmpChild.xls";

                    child.TableName = "data";
                    WorkbookDesigner designer = new WorkbookDesigner();
                    string xlsMdlPath = Server.MapPath(FullPath);
                    designer.Open(xlsMdlPath);
                    designer.SetDataSource(child);
                    designer.Process();
                    Aspose.Cells.Worksheet ws = designer.Workbook.Worksheets.GetSheetByCodeName("子女保险");


                    string newXls = xlsNameChild + ".xls";
                    System.IO.DirectoryInfo xlspath = new System.IO.DirectoryInfo(Server.MapPath("../Excel/tempexcel"));
                    ExcelHelper.deletefile(xlspath);
                    designer.Save(Server.MapPath("../Excel/tempexcel") + "\\" + newXls, FileFormatType.Excel2003);
                    if (!string.IsNullOrEmpty(fileName))
                    {
                        fileName += "|" + "/Excel/tempexcel/" + newXls; // | 文件分割
                    }
                    else
                    {
                        fileName += "/Excel/tempexcel/" + newXls;
                    }
                }
                {   //double
                    string FullPath = @"../Excel/EmpDouble.xls";
                    if (url.Contains("FD")) FullPath = @"/FD/Excel/EmpDouble.xls";

                    dble.TableName = "data";
                    WorkbookDesigner designer = new WorkbookDesigner();
                    string xlsMdlPath = Server.MapPath(FullPath);
                    designer.Open(xlsMdlPath);
                    designer.SetDataSource(dble);
                    designer.Process();
                    Aspose.Cells.Worksheet ws = designer.Workbook.Worksheets.GetSheetByCodeName("配偶保险");

                    string newXls = xlsNameDouble + ".xls";

                    System.IO.DirectoryInfo xlspath = new System.IO.DirectoryInfo(Server.MapPath("../Excel/tempexcel"));
                    if (xlspath.GetFiles(xlsNameChild + ".xls").Length <= 0)
                    {
                        ExcelHelper.deletefile(xlspath);
                    }
                    designer.Save(Server.MapPath("../Excel/tempexcel") + "\\" + newXls, FileFormatType.Excel2003);
                    if (!string.IsNullOrEmpty(fileName))
                    {
                        fileName += "|" + "/Excel/tempexcel/" + newXls;
                    }
                    else
                    {
                        fileName += "/Excel/tempexcel/" + newXls;
                    }
                }

                this.PageState.Add("fileName", fileName);

            }
            else if (WelfareType == "double")
            {
                string FullPath = @"/Excel/EmpDouble.xls";
                if (url.Contains("FD")) FullPath = @"/FD/Excel/EmpDouble.xls";

                dble = DataHelper.QueryDataTable(dbleSQL);
                CrateExcel(dble, "配偶保险", FullPath, xlsNameDouble);
            }
            else if (WelfareType == "child")
            {
                string FullPath = @"/Excel/EmpChild.xls";
                if (url.Contains("FD")) FullPath = @"/FD/Excel/EmpChild.xls";
                child = DataHelper.QueryDataTable(childSQL);
                CrateExcel(child, "子女保险", FullPath, xlsNameChild);
            }
        }

        //
        private void CrateExcel(DataTable forExcelDt, string SheetName, string FullPath, string xlsName)
        {
            forExcelDt.TableName = "data";
            WorkbookDesigner designer = new WorkbookDesigner();
            string xlsMdlPath = Server.MapPath(FullPath);
            designer.Open(xlsMdlPath);
            designer.SetDataSource(forExcelDt);
            designer.Process();
            Aspose.Cells.Worksheet ws = designer.Workbook.Worksheets.GetSheetByCodeName(SheetName);

            string newXls = xlsName + ".xls";
            System.IO.DirectoryInfo xlspath = new System.IO.DirectoryInfo(Server.MapPath("../Excel/tempexcel"));
            ExcelHelper.deletefile(xlspath);
            designer.Save(Server.MapPath("../Excel/tempexcel") + "\\" + newXls, FileFormatType.Excel2003);
            this.PageState.Add("fileName", "../Excel/tempexcel/" + newXls);
        }

        //审批处理
        private void AppSubmit()
        {
            string result = RequestData.Get("result") + "";
            string ids = RequestData.Get("ids") + "";
            string state = RequestData.Get("state") + "";
            string sql = "update FL_Culture..UsrChildWelfare set WorkFlowState='{0}',Result='{1}' where charindex(Id,'{2}')>0 ";
            sql = string.Format(sql, state, result, ids);
            DataHelper.ExecSql(sql);
            this.PageState.Add("State", "1");
        }


        //
        private void DoSelect()
        {
            string where = "";
            CommPowerSplit ps = new CommPowerSplit();
            if (!ps.IsNoticeRole(UserInfo.UserID, UserInfo.LoginName))
            {
                where += AppealUsrAuth();
            }


            if (SearchCriterion.Searches.Searches.Count == 0)
            {
                where += "  and year(A.ApplyTime)=" + DateTime.Now.Year.ToString() + " ";
            }

            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                if (!String.IsNullOrEmpty(item.Value.ToString()) || item.PropertyName == "Year")  //默认本年度
                {
                    switch (item.PropertyName)
                    {
                        case "Year":
                            string tempVal = string.IsNullOrEmpty(item.Value.ToString()) ? DateTime.Now.Year.ToString() : item.Value.ToString();
                            //where += "  and Year='" + tempVal + "'";
                            where += "  and year(A.ApplyTime)=" + tempVal + " ";
                            break;
                        case "Month":
                            //where += " and Month=" + item.Value.ToString() + " ";
                            where += " and month(A.ApplyTime)=" + item.Value.ToString() + " ";
                            break;
                        case "CompanyName":
                            if (!string.IsNullOrEmpty(item.Value.ToString()))
                                where += " and CompanyName like '%" + item.Value + "%' ";
                            break;
                        case "WelfareType":
                            if (item.Value.ToString() == "child")
                            {
                                where += " and BeRelation='子女' ";
                            }
                            if (item.Value.ToString() == "double")
                            {
                                where += " and BeRelation='配偶' ";
                            }
                            break;
                        case "WorkFlowState":
                            if (item.Value.ToString() == "2,-1")
                            {
                                where += " and (WorkFlowState='2' or WorkFlowState='-1' )  ";
                            }
                            else
                            {
                                where += " and " + item.PropertyName + "='" + item.Value + "' ";
                            }
                            break;
                        default:
                            where += " and " + item.PropertyName + " like '%" + item.Value + "%' ";
                            break;
                    }
                }
            }

            string SQL = @"select year(A.ApplyTime) Year,month(A.ApplyTime) Month, 
		                            A.*,C.UsrName As ChildName ,C.IDCartNo as ChildIdCart,C.Sex As ChlidSex,C.IDType
                           from  FL_Culture..UsrChildWelfare As A
                           left join  FL_Culture..UsrWelfareChildInfo As C
                              on C.ChildWelfareId=A.Id 
                           where A.Id is not null  ##Query## ";
            //未处理
            if (type == "n")
            {
                where += " and WorkFlowState='1' ";
            }
            else//已处理
            {
                where += " and (WorkFlowState='-1' or WorkFlowState='2' ) ";
            }

            SQL = SQL.Replace("##Query##", where);
            SearchCriterion.SetOrder("CreateTime", false);
            //var Ent = DataHelper.QueryDictList(SQL);
            this.PageState.Add("DataList", GetPageData(SQL, SearchCriterion));

        }

        /// <summary>
        /// 审批人验证 审批人必须pk_corp在该公司才能审批
        /// </summary>
        /// <returns>SQL string</returns>
        private string AppealUsrAuth()
        {
            string CorpId = "";
            // 判断公司登陆
            UserContextInfo UC = new UserContextInfo();
            CorpId = UC.GetUserCurrentCorpId(UserInfo.UserID);

            string SQL = @"select top 1 ChildWelfareId,ChildWelfareName from  FL_Culture..SysApproveConfig where DeptId is null and CompanyId='{0}' ";
            SQL = string.Format(SQL, CorpId);
            DataTable Dt = DataHelper.QueryDataTable(SQL);
            if (Dt.Rows.Count > 0)
            {
                if ((Dt.Rows[0]["ChildWelfareId"] + "").Contains(UserInfo.UserID))
                {
                    return " and A.CompanyId='" + CorpId + "' ";  //*
                }
                else
                {
                    return " and 1<>1 ";
                }
            }
            else
            {
                return " and 1<>1 ";
            }
        }

        private IList<EasyDictionary> GetPageData(String sql, SearchCriterion search)
        {
            SearchCriterion.RecordCount = DataHelper.QueryValue<int>("select count(*) from (" + sql + ") t");
            string order = search.Orders.Count > 0 ? search.Orders[0].PropertyName : "CompanyId";
            string asc = search.Orders.Count <= 0 || !search.Orders[0].Ascending ? " desc" : " asc";

            string pageSql = @"WITH OrderedOrders AS
		    (SELECT *,
		    ROW_NUMBER() OVER (order by {0} {1})as RowNumber
		    FROM ({2}) temp ) 
		    SELECT * 
		    FROM OrderedOrders 
		    WHERE RowNumber between {3} and {4}";
            pageSql = string.Format(pageSql, order, asc, sql, (search.CurrentPageIndex - 1) * search.PageSize + 1, search.CurrentPageIndex * search.PageSize);
            IList<EasyDictionary> dicts = DataHelper.QueryDictList(pageSql);
            return dicts;
        }
    }
}

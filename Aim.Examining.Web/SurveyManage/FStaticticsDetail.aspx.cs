using System;
using System.Collections;
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
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using Aspose.Cells;
using Aim.Examining.Web.Common;
namespace Aim.Examining.Web.SurveyManage
{
    public partial class FStaticticsDetail : BaseListPage
    {
        public string tmpSQL = @"IF (OBJECT_ID('tempdb..#ST') IS NOT NULL)
                                    DROP TABLE tempdb..#ST;
                            select    
                                 A.*, convert(varchar(10),A.Indutydate,120) As IDate,
                                 convert(varchar(10),A.BornDate,120) As BDate,
                                 B.SortIndex As P, C.SortIndex As S 
                            from  FL_Culture..SummarySurvey_detail As A 
                             left join FL_Culture..QuestionItem As B 
                                on B.Id=A.QuestionId and A.SurveyId=B.SurveyId
                             left join FL_Culture..QuestionAnswerItem As C 
                                on A.SurveyId=C.SurveyId and  A.QuestionItemId=C.Id
                             left join FL_PortalHR..SysUser As D
								on A.WorkNo=D.WorkNo
                            where  A.SurveyId='{0}' and  A.WorkNo is not null  ##QUERY##
                            order by A.UserId, P,S ";


        public string SurveyId = string.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            SurveyId = RequestData.Get("SurveyId") + "";
            SetPageSize();
            switch (RequestActionString)
            {
                case "Quesry":
                    break;
                case "ImpExcel":
                    ImpExcel();
                    break;
                default:
                    DefaultSelect();
                    break;
            }
        }

        private void ImpExcel()
        {
            string where = string.Empty;
            //权限过滤
            var Ent = SurveyQuestion.TryFind(SurveyId);
            if (Ent != null && Ent.IsFixed == "2")
            {
                CommPowerSplit PS = new CommPowerSplit();
                if (PS.IsInAdminsRole(UserInfo.UserID) || PS.IsAdmin(UserInfo.LoginName) || PS.IsHR(UserInfo.UserID, UserInfo.LoginName))
                {
                }
                else
                {
                    UserContextInfo UC = new UserContextInfo();
                    where += " and D.Pk_corp='" + UC.GetUserCurrentCorpId(UserInfo.UserID) + "' ";
                }
            }

            tmpSQL = tmpSQL.Replace("##QUERY##", where);
            tmpSQL = tmpSQL.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            string sql = string.Format(tmpSQL, SurveyId);
            string path = RequestData.Get<string>("path");
            string fileName = RequestData.Get<string>("fileName");
            string xlsName = fileName + "_" + System.DateTime.Now.ToString("yyyMMddhhmmss");
            DataTable forExcelDt = DataHelper.QueryDataTable(sql);

            if (forExcelDt.Rows.Count > 0)
            {
                forExcelDt.TableName = "data";
                WorkbookDesigner designer = new WorkbookDesigner();
                string xlsMdlPath = Server.MapPath(path);
                designer.Open(xlsMdlPath);
                designer.SetDataSource(forExcelDt);
                designer.Process();
                Aspose.Cells.Worksheet ws = designer.Workbook.Worksheets.GetSheetByCodeName(fileName);

                string newXls = xlsName + ".xls";
                System.IO.DirectoryInfo xlspath = new System.IO.DirectoryInfo(Server.MapPath("../Excel/tempexcel"));
                ExcelHelper.deletefile(xlspath);
                designer.Save(Server.MapPath("../Excel/tempexcel") + "\\" + newXls, FileFormatType.Excel2003);
                this.PageState.Add("fileName", "/Excel/tempexcel/" + newXls);
            }
        }

        public void SetPageSize()
        {
            string sizeSql = "select count(*) from FL_Culture..QuestionItem where SurveyId='{0}' ";
            sizeSql = string.Format(sizeSql, SurveyId);
            int count = DataHelper.QueryValue<int>(sizeSql);
            int PageSize = count > 0 ? count * 5 : 20;
            SearchCriterion.PageSize = PageSize;
        }

        private void DefaultSelect()
        {
            string where = "";
            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                if (!String.IsNullOrEmpty(item.Value.ToString()))
                {
                    switch (item.PropertyName)
                    {
                        case "WorkNo":
                            where += " and A." + item.PropertyName + " like '%" + item.Value + "%' ";
                            break;
                        default:
                            where += " and " + item.PropertyName + " like '%" + item.Value + "%' ";
                            break;
                    }
                }
            }

            //权限过滤
            var Ent = SurveyQuestion.TryFind(SurveyId);
            if (Ent != null && Ent.IsFixed == "2")
            {
                CommPowerSplit PS = new CommPowerSplit();
                if (PS.IsInAdminsRole(UserInfo.UserID) || PS.IsAdmin(UserInfo.LoginName) || PS.IsHR(UserInfo.UserID, UserInfo.LoginName))
                {
                }
                else
                {
                    UserContextInfo UC = new UserContextInfo();
                    where += " and D.Pk_corp='" + UC.GetUserCurrentCorpId(UserInfo.UserID) + "' ";
                }
            }

            string sql = @" IF (OBJECT_ID('tempdb..#ST') IS NOT NULL)
                                    DROP TABLE tempdb..#ST;
                            select    
                                 A.*, B.SortIndex As P, C.SortIndex As S 
                                 into #ST
                            from  FL_Culture..SummarySurvey_detail As A 
                             left join FL_Culture..QuestionItem As B 
                                on B.Id=A.QuestionId and A.SurveyId=B.SurveyId
                             left join FL_Culture..QuestionAnswerItem As C 
                                on A.SurveyId=C.SurveyId and  A.QuestionItemId=C.Id
							 left join FL_PortalHR..SysUser As D
							    on  A.UserId=D.UserId
                            where  A.SurveyId='{0}' and  A.WorkNo is not null ##query##
                            order by A.UserId, P,S ";

            if (!string.IsNullOrEmpty(where))
            {
                sql = sql.Replace("##query##", where);
            }
            else
            {
                sql = sql.Replace("##query##", "");
            }
            sql = string.Format(sql, SurveyId);
            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
            sql = sql.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            this.PageState.Add("DataList", GetPageData(sql, SearchCriterion));
        }

        private DataTable GetPageData(String sql, SearchCriterion search)
        {
            string constr = ConfigurationManager.AppSettings["conStr"] + "";
            using (SqlConnection con = new SqlConnection(constr))
            {
                con.Open();
                using (SqlCommand sqlcmd = new SqlCommand())
                {
                    SqlCommand cmd = new SqlCommand(sql, con);
                    int k = cmd.ExecuteNonQuery();
                    cmd.CommandText = @"select count(1) from #ST";
                    k = int.Parse(cmd.ExecuteScalar() + "");

                    cmd.CommandText = @"select * from 
                                        (
                                          select  ROW_NUMBER() OVER (order by SurveyId)as RN ,#ST.*
                                         from #ST
                                        )T where RN Between {0} and {1} ";
                    cmd.CommandText = string.Format(cmd.CommandText, (search.CurrentPageIndex - 1) * search.PageSize + 1, search.CurrentPageIndex * search.PageSize);

                    DataTable dt = new DataTable();
                    SqlDataAdapter dap = new SqlDataAdapter(cmd);
                    dap.Fill(dt);
                    SearchCriterion.RecordCount = k;

                    return dt;
                }
            }
        }


    }
}

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
using System.Drawing;
using Aim.Examining.Web.Common;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class FStaticticsDetailTwo : BaseListPage
    {
        public FStaticticsDetailTwo()
        {
            SearchCriterion.PageSize = 120;
        }

        public string SurveyId = string.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {

            SurveyId = RequestData.Get("SurveyId") + "";
            switch (RequestActionString)
            {
                case "Query":
                    break;
                case "ImpExcel":
                    QryAndImpExcel();
                    break;
                default:
                    DefaultSelect();
                    break;
            }
        }

        #region query
        private void DefaultSelect()
        {
            string where = "";
            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                if (!String.IsNullOrEmpty(item.Value.ToString()))
                {
                    switch (item.PropertyName)
                    {
                        default:
                            where += " and A." + item.PropertyName + " like '%" + item.Value + "%' ";
                            break;
                    }
                }
            }
            //iframe
            string qstSQl = string.Empty;
            if (!string.IsNullOrEmpty(RequestData.Get("type") + ""))
            {
                if (!string.IsNullOrEmpty(RequestData.Get("Qty") + ""))
                {
                    string Qty = RequestData.Get("Qty") + "";
                    switch ((RequestData.Get("GroupType") + "").Trim().ToLower())
                    {
                        case "corp": //公司维度
                            where += " and A.Corp='" + Qty + "' ";
                            break;
                        case "sex":
                            where += " and A.Sex='" + Qty + "' ";
                            break;
                        case "workage":
                            if (Qty.Contains("未知"))
                            {
                                where += " and A.WorkAge is  null ";
                            }
                            else
                            {
                                where += " and A.WorkAge=" + Qty + " ";
                            }
                            break;
                        case "ageseg":
                            {
                                string OraStr = Qty;
                                string[] Arr = Qty.Split('-');
                                if (Arr.Length > 1)
                                {
                                    where += " and A.Age between " + Arr[0] + " and " + Arr[1] + " ";
                                }
                                else
                                {
                                    where += " and A.age " + Arr[0] + " ";
                                }
                            }
                            break;
                    }

                    string QuestionId = RequestData.Get("QuestionId") + "";
                    string QuestionItemId = RequestData.Get("QuestionItemId") + "";
                    if (!String.IsNullOrEmpty(QuestionId) && !string.IsNullOrEmpty(QuestionItemId))
                    {
                        string tmpSQL = @"  and A.WorkNo in 
		                            (
			                            select Distinct WorkNo from FL_Culture..SummarySurvey_detail As A
			                            where  A.SurveyId='{0}'
			                            and QuestionId='{1}' 
			                            and QuestionItemId='{2}'
		                            ) ";
                        qstSQl = string.Format(tmpSQL, SurveyId, QuestionId, QuestionItemId);

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
                    where += " and B.Pk_corp='" + UC.GetUserCurrentCorpId(UserInfo.UserID) + "' ";
                }
            }

            //查询SQL
            string sql = @"select * from FL_Culture..SummarySurvey_detail As A
                            left join FL_PortalHR..SysUser As B 
			                     on A.WorkNo=B.WorkNo
                            where SurveyId='{0}' and 1=1  ";

            sql = sql + where + qstSQl;
            sql = string.Format(sql, SurveyId);
            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
            DataTable OrigDt = DataHelper.QueryDataTable(sql);

            DataTable newDt = CreateNewTable(OrigDt, SurveyId, "");
            DataTable dt = GetPagedTable(newDt, SearchCriterion.CurrentPageIndex, SearchCriterion.PageSize);
            SearchCriterion.RecordCount = newDt.Rows.Count;
            PageState.Add("DataList", dt);

        }
        #endregion

        /// <summary>
        /// 查询导出
        /// </summary>
        private void QryAndImpExcel()
        {
            string where = "";
            string Corp = RequestData.Get("Corp") + "";
            string WorkNo = RequestData.Get("WorkNo") + "";
            string UserName = RequestData.Get("UserName") + "";
            string JobName = RequestData.Get("JobName") + "";
            string WorkAge = RequestData.Get("WorkAge") + "";
            string SurveyId = RequestData.Get("SurveyId") + "";
            string title = RequestData.Get("title") + "";

            if (!string.IsNullOrEmpty(Corp))
            {
                where += " and A.Corp like '%" + Corp + "%' ";
            }
            if (!string.IsNullOrEmpty(WorkNo))
            {
                where += " and A.WorkNo like '%" + WorkNo + "%' ";
            }
            if (!string.IsNullOrEmpty(UserName))
            {
                where += " and A.UserName like '%" + UserName + "%' ";
            }
            if (!string.IsNullOrEmpty(JobName))
            {
                where += " and A.JobName like '%" + JobName + "%' ";
            }
            if (!string.IsNullOrEmpty(WorkAge))
            {
                where += " and A.WorkAge like '%" + WorkAge + "%' ";
            }

            string sql = @"select 
	                              newid() '编号',
                                  A.WorkNo '工号', UserName '姓名',A.Sex '性别',Corp '公司',Dept '部门',convert(varchar(10),A.Indutydate,120) '入职日期',WorkAge '工龄',Crux '关键岗位',
                                  convert(varchar(10), BornDate,120) '出生日期',A.Age '年龄',JobName '岗位',JobDegree '岗位等级',JobSeq '岗位序列',Skill '技能',A.Content, A.QuestionType,
                                  Case when Explanation<>'' then A.Answer+'(' + Explanation+')'  else A.Answer End As Answer,
	                              B.SortIndex As P, C.SortIndex As S 
                            from  FL_Culture..SummarySurvey_detail As A 
                             left join FL_Culture..QuestionItem As B 
	                            on B.Id=A.QuestionId and A.SurveyId=B.SurveyId
                             left join FL_Culture..QuestionAnswerItem As C 
	                            on A.SurveyId=C.SurveyId and  A.QuestionItemId=C.Id
                             left join FL_PortalHR..SysUser As D
	                            on A.WorkNo=D.WorkNo
                            where  A.SurveyId='{0}' and  A.WorkNo is not null ##query##
                            order by A.UserId, P,S ";

            //权限过滤
            var SEnt = SurveyQuestion.TryFind(SurveyId);
            if (SEnt != null && SEnt.IsFixed == "2") //IsFixed "2" 常用问卷
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

            if (!string.IsNullOrEmpty(where))
            {
                sql = sql.Replace("##query##", where);
            }
            else
            {
                sql = sql.Replace("##query##", "");
            }

            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
            sql = sql.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            sql = string.Format(sql, SurveyId);
            DataTable OrigDt = DataHelper.QueryDataTable(sql);

            DataTable newDt = CreateNewTable(OrigDt, SurveyId, "IMP");
            newDt.Columns.Remove("编号");
            newDt.Columns.Remove("Content");
            newDt.Columns.Remove("QuestionType");
            newDt.Columns.Remove("Answer");

            if (title.Contains("内部服务评分"))
            {
                string CorpStr = string.Empty;
                for (int i = 0; i < newDt.Rows.Count; i++)
                {
                    if (i > 0) CorpStr += ",";
                    CorpStr += newDt.Rows[i]["公司"] + "";
                }
                string[] CorpArr = CorpStr.Split(',');

                string DeptStr = @"财务管理中心,信息管理中心,综合管理中心,物流研发中心,物流事业部,法务稽核部,营销服务中心,人力资源中心,海运事业部,空运事业部,商业发展部";
                string[] DeptArr = DeptStr.Split(',');

                ExportExcel(DeptArr, CorpArr, title);
                return;
            }
            else
            {

                string xlsName = title + "_" + System.DateTime.Now.ToString("yyyMMddhhmm") + ".xls";
                string FilnalName = Server.MapPath("../Excel/tempexcel") + "/" + xlsName;

                OutFileToDisk(newDt, "DataSource2", FilnalName);
                this.PageState.Add("fileName", "/Excel/tempexcel/" + xlsName);
            }

        }


        /// <summary>
        /// 导出Excel
        /// </summary>
        /// <param name="DeptArr">只能部门等级</param>
        /// <param name="CorpArr">公司</param>
        /// <param name="Score">分数</param>
        /// <param name="Txt"></param>
        private void ExportExcel(string[] DeptArr, string[] CorpArr, string title)
        {
            Workbook workBook = new Workbook();
            workBook.Open(MapPath("../Excel/TestTmp.xls"));
            Worksheet sheet = workBook.Worksheets[0];
            Cells cells = workBook.Worksheets[0].Cells;
            sheet.AutoFitColumns();

            //Insert Rows
            Aspose.Cells.Style A5Style = cells["A5"].Style;
            for (int i = 0; i < DeptArr.Length - 1; i++)
            {
                sheet.Cells.InsertRows(i + 5, 1);
            }
            for (int i = 0; i < DeptArr.Length; i++)
            {
                cells[i + 4, 0].Style = A5Style;
                cells[i + 4, 0].PutValue(DeptArr[i]);
            }

            //Insert column 
            for (int i = 0; i < (CorpArr.Length - 1) * 2; i++)
            {
                sheet.Cells.InsertColumn(i + 3);
            }

            //合并单元格
            for (int i = 1; i < CorpArr.Length; i++)
            {
                cells.Merge(2, 2 * i + 1, 1, 2);
            }
            for (int i = 0; i < CorpArr.Length; i++)
            {
                cells[2, 2 * i + 1].PutValue(CorpArr[i]);
                cells[3, 2 * i + 1].PutValue("得分");
                cells[3, 2 * i + 2].PutValue("低于8分填写不满意项");
                cells.SetColumnWidth(2 * i + 2, 30);                    //设宽
                cells.SetColumnWidth(2 * i + 1, 8);                    //设宽
                //cells.GroupColumns(2 * i + 1, 2 * i + 2, true);         //组合
            }

            //平均得分公式
            for (int i = 0; i < DeptArr.Length; i++)
            {
                string lastName = cells[i + 4, CorpArr.Length * 2].Name;
                string headName = cells[i + 4, 1].Name;
                cells[i + 4, CorpArr.Length * 2 + 1].Formula = "=AVERAGE(" + headName + ":" + lastName + ")";
            }

            //合计公式
            for (int i = 1; i <= CorpArr.Length; i++)
            {

                string hName = cells[4, i * 2 - 1].Name;
                string leadName = cells[(DeptArr.Length - 1) + 4, i * 2 - 1].Name;
                //=SUM(B5:B15)
                cells[DeptArr.Length + 4, i * 2 - 1].Formula = "=SUM(" + hName + ":" + leadName + ")";
            }


            //设置title
            cells["B1"].PutValue(title);

            //开始填值 得分,建议
            string sql = @"select * from FL_Culture..SummarySurvey_detail where surveyid='{0}'";
            sql = string.Format(sql, SurveyId);
            DataTable InnerDt = DataHelper.QueryDataTable(sql);
            for (int i = 0; i < DeptArr.Length; i++)
            {
                for (int j = 0; j < CorpArr.Length; j++)
                {
                    // Aspose.Cells.Style style = workBook.Styles[workBook.Styles.Add()];//新增样式

                    //cells[i + 4, j * 2 + 1].SetStyle();
                    //cells[i + 4, j * 2 + 1].DoubleValue = double.Parse(GetValue(InnerDt, CorpArr[j], DeptArr[i], "score"));
                    double dd = 0.0;
                    if (double.TryParse(GetValue(InnerDt, CorpArr[j], DeptArr[i], "score"), out dd))
                    {
                        cells[i + 4, j * 2 + 1].PutValue(dd);
                    }
                    else
                    {
                        cells[i + 4, j * 2 + 1].PutValue(0.0);
                    }
                    //cells[i + 4, j * 2 + 1].PutValue(9.8);            //填充分值
                    //cells[i + 4, j * 2 + 1].PutValue(GetValue(InnerDt, CorpArr[j], DeptArr[i], "score"));            //填充分值
                    cells[i + 4, j * 2 + 2].PutValue(GetValue(InnerDt, CorpArr[j], DeptArr[i], "txt"));              //意见
                }
            }

            //保存
            string FileName = "内部服务评分_" + DateTime.Now.ToString("yyyyMMdd") + ".xls";
            try
            {
                System.IO.DirectoryInfo xlspath = new System.IO.DirectoryInfo(Server.MapPath("../Excel/tempexcel"));
                ExcelHelper.deletefile(xlspath);
            }
            catch { }
            workBook.Save(Server.MapPath("../Excel/tempexcel") + "\\" + FileName, FileFormatType.Excel2003);
            this.PageState.Add("fileName", "/Excel/tempexcel/" + FileName);
        }

        private string GetValue(DataTable dt, string CorpFiled, string DeptFiled, string sign)
        {

            DataRow[] rows = null;
            if (sign == "txt")
            {
                rows = dt.Select(" Corp='" + CorpFiled + "' and  Content like '%" + DeptFiled + "%' and Content like '%不满意%' ");
            }
            else
            {
                rows = dt.Select(" Corp='" + CorpFiled + "' and  Content like '%" + DeptFiled + "%' and Content not like '%不满意%' ");
            }
            string rtnVal = string.Empty;
            if (rows == null || rows.Length == 0)
            {
                rtnVal = "";
            }
            else
            {
                rtnVal = rows[0]["Answer"] + "";
            }
            return rtnVal;
        }



        /// <summary>
        /// type="IMP" 导出
        /// </summary>
        private DataTable CreateNewTable(DataTable OrigDt, string surveyId, string type)
        {
            //Create DataTable and dynamic create columns  
            DataTable NewDt = new DataTable();

            IList<string> ClnList = new List<string>();
            int fixedIndex = 0;
            foreach (DataColumn dc in OrigDt.Columns)
            {
                if (dc.ColumnName.ToLower().Contains("skill"))//技能
                {
                    ClnList.Add(dc.ColumnName + "");
                    fixedIndex++;
                    break;
                }
                else
                {
                    ClnList.Add(dc.ColumnName + "");
                    fixedIndex++;
                }
            }

            string clnSQL = @"select *  from  FL_Culture..QuestionItem  where SurveyId='" + surveyId + "' order by SortIndex ";
            DataTable TmpClndt = DataHelper.QueryDataTable(clnSQL);
            for (int i = 0; i < TmpClndt.Rows.Count; i++)
            {
                ClnList.Add(TmpClndt.Rows[i]["Content"] + "");
            }

            //判断是否有分值
            string hasScoreSQL = @"select count(*) As Qst
                                   from FL_Culture..QuestionAnswerItem  where surveyid='" + surveyId + "' and Score is not null ";
            int hasScore = DataHelper.QueryValue<int>(hasScoreSQL); //hasScore 分值标志
            if (hasScore > 0)
            {
                ClnList.Add("总分");
            }
            PageState.Add("ClnList", ClnList);   //动态生成的列

            for (int i = 0; i < ClnList.Count; i++)
            {
                DataColumn dc = new DataColumn(ClnList[i]);
                NewDt.Columns.Add(dc);
            }

            //commit user
            string comitUserSQL = @"select SurveyedUserId as UserId,SurveyedUserName as UserName, WorkNo 
                                    from FL_Culture..SurveyCommitHistory where SurveyId='" + surveyId + "'";
            DataTable CommitDt = DataHelper.QueryDataTable(comitUserSQL);

            //commit user total score  
            //   string commmitUserScore = @"select  C.WorkNo, A.*,B.*
            //                           from FL_Culture..SurveyedResult As A 
            //                           cross apply( 
            //                               select 
            //	                               Sum(isnull(Score ,0)) As TotalScore
            //	                           from FL_Culture..QuestionAnswerItem As T
            //	                               where T.SurveyId=A.SurveyId and A.QuestionItemId=T.Id
            //                           ) As B
            //                           left join FL_PortalHR..sysuser as C 
            //	                           on C.UserID=A.UserID
            //                            where A.surveyid='" + surveyId + "'";

            string commmitUserScore = @"select WorkNo,SurveyedUserId As UserID,SurveyedUserName,TotalScore 
                                        from FL_Culture..SurveyCommitHistory  where SurveyId='" + surveyId + "' ";

            DataTable ScoreDt = null;
            if (hasScore > 0)
            {
                comitUserSQL = comitUserSQL.Replace("FL_PortalHR", Global.AimPortalDB);
                ScoreDt = DataHelper.QueryDataTable(commmitUserScore);
            }

            for (int i = 0; i < CommitDt.Rows.Count; i++)
            {
                DataRow[] rows = null;

                if (type == "IMP")
                {
                    rows = OrigDt.Select(" 工号='" + CommitDt.Rows[i]["WorkNo"] + "'  ");
                }
                else
                {
                    rows = OrigDt.Select(" WorkNo='" + CommitDt.Rows[i]["WorkNo"] + "' ");
                }

                DataRow dr = NewDt.NewRow();
                if (rows.Length > 0)
                {
                    for (int j = 0; j < fixedIndex; j++)//fixed columns
                    {
                        dr[j] = rows[0][j];
                    }
                    //NewDt.Columns.Count - 1 - fixedIndex;
                    for (int k = 0; k < rows.Length; k++)
                    {
                        if (k == 0)
                        {
                            dr[(rows[k]["content"] + "")] = dr[(rows[k]["content"] + "")] + "" + rows[k]["Answer"] + ""; //无空格
                        }
                        else
                        {
                            dr[(rows[k]["content"] + "")] = dr[(rows[k]["content"] + "")] + "" + rows[k]["Answer"] + "   "; //有空格,作为分割
                        }
                    }
                    NewDt.Rows.Add(dr);
                }

                //统计总分值 
                DataRow[] ScoreRows = null;
                if (hasScore > 0 && ScoreDt != null)
                {
                    ScoreRows = ScoreDt.Select(" WorkNo='" + CommitDt.Rows[i]["WorkNo"] + "' ");
                    if (ScoreRows.Length > 0)
                    {
                        dr["总分"] = ScoreRows[0]["TotalScore"] + "";
                    }
                }
            }
            return NewDt;
        }
        //------

        /// <summary>
        /// DataTable分页
        /// </summary>
        /// <param name="dt">DataTable</param>
        /// <param name="PageIndex">页索引,注意：从1开始</param>
        /// <param name="PageSize">每页大小</param>
        /// <returns>分好页的DataTable数据</returns>
        public static DataTable GetPagedTable(DataTable dt, int PageIndex, int PageSize)
        {
            if (PageIndex == 0) { return dt; }
            DataTable newdt = dt.Copy();
            newdt.Clear();
            int rowbegin = (PageIndex - 1) * PageSize;
            int rowend = PageIndex * PageSize;

            if (rowbegin >= dt.Rows.Count)
            { return newdt; }

            if (rowend > dt.Rows.Count)
            { rowend = dt.Rows.Count; }
            for (int i = rowbegin; i <= rowend - 1; i++)
            {
                DataRow newdr = newdt.NewRow();
                DataRow dr = dt.Rows[i];
                foreach (DataColumn column in dt.Columns)
                {
                    newdr[column.ColumnName] = dr[column.ColumnName];
                }
                newdt.Rows.Add(newdr);
            }
            return newdt;
        }

        /// 导出数据到本地
        /// </summary>
        /// <param name="dt">要导出的数据</param>
        /// <param name="tableName">表格标题</param>
        /// <param name="path">保存路径</param>
        public static void OutFileToDisk(DataTable dt, string tableName, string path)
        {
            Workbook workbook = new Workbook(); //工作簿
            Worksheet sheet = workbook.Worksheets[0]; //工作表
            sheet.FreezePanes(1, 1, 1, dt.Columns.Count); //冻结首行
            Cells cells = sheet.Cells;//单元格

            //为标题设置样式    title
            Aspose.Cells.Style styleTitle = workbook.Styles[workbook.Styles.Add()];//新增样式
            styleTitle.HorizontalAlignment = TextAlignmentType.Center;//文字居中
            styleTitle.Font.Name = "宋体";//文字字体
            styleTitle.Font.Size = 18;//文字大小
            styleTitle.Font.IsBold = true;//粗体

            //样式2 columns
            Aspose.Cells.Style style2 = workbook.Styles[workbook.Styles.Add()];//新增样式
            style2.HorizontalAlignment = TextAlignmentType.Center;//文字居中
            style2.Font.Name = "宋体";//文字字体
            style2.Font.Size = 12;//文字大小
            style2.Font.IsBold = true;//粗体
            style2.IsTextWrapped = true;//单元格内容自动换行
            // style2.BackgroundColor = Color.CadetBlue; //Color.FromArgb(0, 176, 240);
            //style2.ForegroundColor = Color.FromArgb(0, 176, 240);
            style2.Borders[BorderType.LeftBorder].LineStyle = CellBorderType.Thin;
            style2.Borders[BorderType.RightBorder].LineStyle = CellBorderType.Thin;
            style2.Borders[BorderType.TopBorder].LineStyle = CellBorderType.Thin;
            style2.Borders[BorderType.BottomBorder].LineStyle = CellBorderType.Thin;

            //样式3
            Aspose.Cells.Style style3 = workbook.Styles[workbook.Styles.Add()];//新增样式
            style3.HorizontalAlignment = TextAlignmentType.Center;//文字居中
            style3.Font.Name = "宋体";//文字字体
            style3.Font.Size = 12;//文字大小
            style3.Borders[BorderType.LeftBorder].LineStyle = CellBorderType.Thin;
            style3.Borders[BorderType.RightBorder].LineStyle = CellBorderType.Thin;
            style3.Borders[BorderType.TopBorder].LineStyle = CellBorderType.Thin;
            style3.Borders[BorderType.BottomBorder].LineStyle = CellBorderType.Thin;

            int Colnum = dt.Columns.Count;//表格列数
            int Rownum = dt.Rows.Count;//表格行数

            //生成行1 标题行   
            //cells.Merge(0, 0, 1, Colnum);//合并单元格
            //cells[0, 0].PutValue(tableName);//填写内容
            //cells[0, 0].SetStyle(styleTitle);
            cells.SetRowHeight(0, 28);

            //生成行2 列名行
            for (int i = 0; i < Colnum; i++)
            {
                cells[0, i].PutValue(dt.Columns[i].ColumnName);
                // cells[1, i].PutValue(dt.Columns[i].ColumnName);
                cells.SetColumnWidth(i, 20);
                cells[0, i].SetStyle(style2);
            }

            //生成数据行
            for (int i = 0; i < Rownum; i++)
            {
                for (int k = 0; k < Colnum; k++)
                {
                    string Ctxt = dt.Rows[i][k].ToString();
                    Ctxt = Ctxt.Length > 500 ? (Ctxt.Substring(0, 500) + "...") : Ctxt;
                    cells[1 + i, k].PutValue(Ctxt);
                    cells[1 + i, k].SetStyle(style3);
                }
                cells.SetRowHeight(1 + i, 24);
            }

            workbook.Save(path);
        }

        /// <summary>
        /// ImpExcel
        /// </summary>
        private void ImpExcel()
        {
            string sql = string.Empty;
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
                System.IO.DirectoryInfo xlspath = new System.IO.DirectoryInfo(Server.MapPath("/Excel/tempexcel"));
                ExcelHelper.deletefile(xlspath);
                designer.Save(Server.MapPath("/Excel/tempexcel") + "\\" + newXls, FileFormatType.Excel2003);
                this.PageState.Add("fileName", "/Excel/tempexcel/" + newXls);
            }
        }
    }
}

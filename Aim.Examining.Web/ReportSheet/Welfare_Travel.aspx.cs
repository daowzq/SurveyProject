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
using Aim.Examining.Web.EmpWelfare;
using Aim.WorkFlow;
using System.Data;
using Aspose.Cells;
using Aim.Examining.Web.Common;

namespace Aim.Examining.Web.ReportSheet
{
    public partial class Welfare_Travel : ExamListPage
    {

        private IList<UsrTravelWelfare> ents = null;
        UsrTravelWelfare ent = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (this.RequestActionString)
            {
                case "AppSubmit":
                    AppSubmit();
                    break;
                case "ImpExcel":
                    ImpExcel();
                    break;
                case "ImpUser":
                    DoImpUser();
                    break;
                default:
                    DoSelect();
                    break;
            }

        }


        private void ImpExcel()
        {
            string WorkFlowState = RequestData.Get<string>("WorkFlowState");
            string where = string.Empty;
            //审批意见 
            if (!string.IsNullOrEmpty(WorkFlowState))
            {
                where += " and  A.WorkFlowState='" + WorkFlowState + "' ";
            }
            CommPowerSplit ps = new CommPowerSplit();
            if (ps.IsNoticeRole(UserInfo.UserID, UserInfo.LoginName) || ps.IsHR(UserInfo.UserID, UserInfo.LoginName))
            { //管理员或HR组
            }
            else
            {
                where += AppealUsrAuth();
            }

                                         //A.TravelMoney, 旅游费用/每人
            string sql = @"select distinct
	                        A.UserName,A.WorkNo,A.CompanyName,A.DeptName,A.Sex,
	                        A.TravelAddr,A.TravelTime as TimeSeg, A.XLMoney as TravelMoney,
	                        case  
			                        when   HaveFamily='Y' then '是'
			                        when   HaveFamily='N' then '否'
                            end As IsFamily, convert(varchar(10),A.ApplyTime ,120) As ApplyTime,
	                        C.Indutydate As IndutyDate,
	                        datediff(year,C.Indutydate,getdate()) As WorkYear,
	                        B.Name As Fname,B.Sex As OSex, B.Age As OAge,cast(B.Height as varchar(10))  Height,
                            Case 
								when WorkFlowState='1' then '未处理'
								when WorkFlowState='-1' then '不同意'
								when WorkFlowState='2' then '同意'
                                when WorkFlowState='Exception' then '异常'
							End As State
                        from  FL_Culture..UsrTravelWelfare As A
                           left join FL_Culture..UsrTravelInfo As B 
		                        on  A.Id=B.WelfareTravelId
                           left  join FL_PortalHR..SysUser As C
                               on C.UserID=A.UserId
                        where (WorkFlowState='1' or WorkFlowState='2' or WorkFlowState='-1') and  A.Id is not null";
            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
            sql += where;

            string path = RequestData.Get<string>("path");
            string fileName = RequestData.Get<string>("fileName");
            string xlsName = fileName + "_" + System.DateTime.Now.ToString("yyyMMddhhmmss");
            DataTable forExcelDt = DataHelper.QueryDataTable(sql);
            forExcelDt = DtDetail(forExcelDt);

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
                this.PageState.Add("fileName", "../Excel/tempexcel/" + newXls);
            }
        }

        private DataTable DtDetail(DataTable dt)
        {
            if (dt.Rows.Count <= 0) return dt;
            DataTable newDt = new DataTable();
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                DataColumn dc = new DataColumn(dt.Columns[i].ColumnName);
                newDt.Columns.Add(dc);
            }

            //根据 工号 申请日期 判断
            string WorkNo = string.Empty, Date = string.Empty;
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (dt.Rows[i]["WorkNo"] + "" == WorkNo && dt.Rows[i]["ApplyTime"] + "" == Date)
                {
                    DataRow dr = newDt.NewRow();
                    for (int k = dt.Columns.IndexOf("Fname"); k < dt.Columns.Count; k++)  // Fname 家属姓名
                    {
                        dr[dt.Columns[k].ColumnName] = dt.Rows[i][k] + "";
                    }
                    newDt.Rows.Add(dr);
                }
                else
                {
                    DataRow dr = newDt.NewRow();
                    for (int j = 0; j < dt.Columns.Count; j++)
                    {
                        dr[dt.Columns[j].ColumnName] = dt.Rows[i][j];
                    }
                    newDt.Rows.Add(dr);
                    WorkNo = dt.Rows[i]["WorkNo"] + "";
                    Date = dt.Rows[i]["ApplyTime"] + "";
                }
            }
            return newDt;
        }


        //审批处理
        private void AppSubmit()
        {
            string result = RequestData.Get("result") + "";
            string ids = RequestData.Get("ids") + "";
            string state = RequestData.Get("state") + "";
            string sql = "update FL_Culture..UsrTravelWelfare set WorkFlowState='{0}',Result='{1}' where charindex(Id,'{2}')>0 ";
            sql = string.Format(sql, state, result, ids);
            DataHelper.ExecSql(sql);
            this.PageState.Add("State", "1");
        }

        /// <summary>
        /// 查询
        /// </summary>
        private void DoSelect()
        {
            string CorpId = string.Empty;
            string where = string.Empty;
            var UsrEnt = SysUser.Find(UserInfo.UserID);

            CommPowerSplit ps = new CommPowerSplit();
            if (ps.IsNoticeRole(UserInfo.UserID, UserInfo.LoginName))
            {
                where += " (WorkFlowState='1' or WorkFlowState='2' or WorkFlowState='-1') ";
                if (!string.IsNullOrEmpty(SearchCriterion.GetSearchValue("Year") + ""))
                {
                    where += "  and  year(ApplyTime)= " + SearchCriterion.GetSearchValue("Year") + " ";
                }
                SearchCriterion.RemoveSearch("Year");
                ents = UsrTravelWelfare.FindAll(SearchCriterion, Expression.Sql(where));
                this.PageState.Add("UsrTravelWelfareList", ents);
            }
            else
            {
                // 判断公司登陆
                UserContextInfo UC = new UserContextInfo();
                CorpId = UC.GetUserCurrentCorpId(UserInfo.UserID);

                //SearchCriterion.AddSearch("CompanyId", CorpId);
                where += " (WorkFlowState='1' or WorkFlowState='2' or WorkFlowState='-1') " + AppealUsrAuth();
                if (!string.IsNullOrEmpty(SearchCriterion.GetSearchValue("Year") + ""))
                {
                    where += "  and  year(ApplyTime)= " + SearchCriterion.GetSearchValue("Year") + " ";
                }
                SearchCriterion.RemoveSearch("Year");
                SearchCriterion.SetOrder("CompanyId", true);
                ents = UsrTravelWelfare.FindAll(SearchCriterion, Expression.Sql(where));
                this.PageState.Add("UsrTravelWelfareList", ents);
            }
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

            //判断是否为员工旅游审批人
            string SQL = @"select top 1 TravelWelfareId,TravelWelfareName from  FL_Culture..SysApproveConfig where DeptId is null and CompanyId='{0}'";
            SQL = string.Format(SQL, CorpId);
            DataTable Dt = DataHelper.QueryDataTable(SQL);
            if (Dt.Rows.Count > 0)
            {
                if (Dt.Rows[0]["TravelWelfareId"] + "" == UserInfo.UserID)
                {
                    return " and CompanyId='" + CorpId + "' ";  //*
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

        /// <summary>
        /// 批量删除
        /// </summary>
        [ActiveRecordTransaction]
        private void DoBatchDelete()
        {
            IList<object> idList = RequestData.GetList<object>("IdList");

            if (idList != null && idList.Count > 0)
            {
                UsrTravelWelfare.DoBatchDelete(idList.ToArray());
            }
        }

        /// <summary>
        /// 导入人员
        /// </summary>
        private void DoImpUser()
        {
            string prefix = FileModule.FindFirstByProperties("Name", "Portal").RootPath + "\\Default\\";
            string FilePath = RequestData.Get("FileId") + "";
            FilePath = prefix + FilePath;
            DataTable SourDt = ExcelToDataTable(FilePath);
            AnalysUser(SourDt);  //创建人员

            this.PageState.Add("State", "1");

        }

        private void AnalysUser(DataTable Dt)
        {
            //判断文件是否为模板格式
            if (Dt.Columns.Count != 11 && Dt.Columns[0].ColumnName != "姓名")
            {
                throw new Exception("文件内容格式不符合模板定义的格式!");
            }

            string guid = string.Empty; //guid 
            for (int i = 0; i < Dt.Rows.Count; i++)
            {
                SysUser UserEnt = null; //

                try
                {
                    if (!string.IsNullOrEmpty(Dt.Rows[i]["姓名"] + ""))
                    {
                        UsrTravelWelfare UW = new UsrTravelWelfare();
                        UW.DoCreate();

                        //guid = Guid.NewGuid().ToString();                  //guid
                        guid = UW.Id;                                        //guid
                        UserEnt = SysUser.FindFirstByProperties(SysUser.Prop_WorkNo, Dt.Rows[i]["工号"]);

                        UW.Id = guid;
                        UW.UserId = UserEnt.UserID;
                        UW.WorkNo = UserEnt.WorkNo;
                        if (UserEnt.Name != Dt.Rows[i]["姓名"] + "")
                        {
                            UW.UserName = Dt.Rows[i]["姓名"] + "/[" + UserEnt.Name + "]";
                        }
                        else
                        {
                            UW.UserName = UserEnt.Name;
                        }
                        UW.Sex = UserEnt.Sex;
                        UW.ImpState = "1";           //导入状态 1成功
                        UW.WorkFlowState = "2";      //标识 同意
                        UW.Result = "同意";
                        UW.ApplyTime = DateTime.Now; //申请日期

                        //公司
                        SysGroup GroupEnt = SysGroup.TryFind(UserEnt.Pk_corp);
                        if (GroupEnt != null)
                        {
                            UW.CompanyName = Dt.Rows[i]["公司"] + "";
                            UW.CompanyId = GroupEnt.GroupID;   //通过工号 强制关联公司和部门
                        }
                        //部门
                        GroupEnt = SysGroup.TryFind(UserEnt.Pk_deptdoc);
                        if (GroupEnt != null)
                        {
                            UW.DeptId = GroupEnt.GroupID;
                            UW.DeptName = Dt.Rows[i]["部门"] + "";
                        }

                        UW.TravelAddr = Dt.Rows[i]["旅游地点"] + "";    //旅游地点
                        UW.TravelTime = Dt.Rows[i]["出行时间"] + "";    //出行时间
                        UW.TravelMoney = (decimal)GetMoney(UserEnt, "");//旅游金额

                        //入职日期
                        if (!string.IsNullOrEmpty(UserEnt.Indutydate)) UW.IndutyDate = DateTime.Parse(UserEnt.Indutydate);

                        //员工类型 正式员工,实习生
                        string WorkerType = DataHelper.QueryValue("select psnclassname from HR_OA_MiddleDB..fld_rylb where pk_fld_rylb='" + UserEnt.Pk_rylb + "'") + "";
                        UW.WorkerType = WorkerType;

                        //HaveFamily Y
                        if (!string.IsNullOrEmpty(Dt.Rows[i]["家属姓名"] + ""))
                        {
                            UW.HaveFamily = "Y";
                            UsrTravelInfo UT = new UsrTravelInfo();

                            //家属姓名
                            if (!string.IsNullOrEmpty(Dt.Rows[i]["家属姓名"] + ""))
                            {
                                UT.Name = Dt.Rows[i]["家属姓名"] + "";
                                UT.WelfareTravelId = guid;     //* 关联的主键ID
                                UT.CreateTime = DateTime.Now;
                            }
                            //家属年龄
                            int age = 0;
                            if (int.TryParse(Dt.Rows[i]["家属年龄"] + "", out age))
                            {
                                UT.Age = age;
                                if (age <= 13)  //14 岁为标志
                                {
                                    UT.IsChild = "是";
                                }
                            }

                            //家属性别
                            if (!string.IsNullOrEmpty(Dt.Rows[i]["家属性别"] + ""))
                            {
                                UT.Sex = Dt.Rows[i]["家属性别"] + "";
                            }

                            //家属身高
                            if (!string.IsNullOrEmpty(Dt.Rows[i]["家属身高"] + ""))
                            {
                                Decimal dlb = 0;
                                if (Decimal.TryParse(Dt.Rows[i]["家属身高"] + "", out dlb))
                                {
                                    UT.Height = dlb;
                                }
                            }
                            UT.DoCreate();  //创建家属记录
                        }
                        //计算金额
                        UW.CreateId = UserInfo.UserID;
                        UW.CreateName = UserInfo.Name;
                        UW.CreateTime = DateTime.Now;
                        UW.DoUpdate();
                    }
                    else
                    {  //家属信息

                        UsrTravelInfo UT = null;
                        if (!string.IsNullOrEmpty(Dt.Rows[i]["家属姓名"] + ""))
                        {
                            UT = new UsrTravelInfo();

                            //家属姓名
                            if (!string.IsNullOrEmpty(Dt.Rows[i]["家属姓名"] + ""))
                            {
                                UT.Name = Dt.Rows[i]["家属姓名"] + "";
                                UT.WelfareTravelId = guid;     //* 关联的主键ID
                                UT.CreateTime = DateTime.Now;
                            }
                            //家属年龄
                            int age = 0;
                            if (int.TryParse(Dt.Rows[i]["家属年龄"] + "", out age))
                            {
                                UT.Age = age;
                                if (age <= 13)  //14 岁为标志
                                {
                                    UT.IsChild = "是";
                                }
                            }

                            //家属性别
                            if (!string.IsNullOrEmpty(Dt.Rows[i]["家属性别"] + ""))
                            {
                                UT.Sex = Dt.Rows[i]["家属性别"] + "";
                            }

                            //家属身高
                            if (!string.IsNullOrEmpty(Dt.Rows[i]["家属身高"] + ""))
                            {
                                Decimal dlb = 0;
                                if (Decimal.TryParse(Dt.Rows[i]["家属身高"] + "", out dlb))
                                {
                                    UT.Height = dlb;
                                }
                            }
                            UT.DoCreate();  //创建家属记录
                        }
                    }
                }
                catch
                {
                    UsrTravelWelfare UW = new UsrTravelWelfare();
                    UW.ImpState = "0"; //无该人员或异常
                    UW.WorkFlowState = "Exception"; //异常标识

                    UW.UserName = Dt.Rows[i]["姓名"] + " [异常]";
                    UW.WorkNo = Dt.Rows[i]["工号"] + "";
                    UW.CompanyName = Dt.Rows[i]["公司"] + "";
                    UW.DeptName = Dt.Rows[i]["部门"] + "";
                    UW.TravelAddr = Dt.Rows[i]["旅游地点"] + "";
                    UW.TravelTime = Dt.Rows[i]["出行时间"] + "";
                    UW.OtherName = Dt.Rows[i]["家属姓名"] + " [异常]";
                    UW.CreateTime = DateTime.Now;
                    UW.DoCreate();
                }

            }
        }

        /// <summary> 
        /// Excel导入DataTable 
        /// </summary> 
        /// <param name="ExcelPath">Excel绝对路径</param> 
        /// <returns>DataTable</returns> 
        protected DataTable ExcelToDataTable(string ExcelPath)
        {
            Cells cells;
            Workbook workbook = new Workbook();
            try
            {
                workbook.Open(ExcelPath);
                cells = workbook.Worksheets[0].Cells;
            }
            catch (Exception e)
            {
                throw new Exception("打开文件错误[01]!");
            }
            DataTable dtnew = new DataTable("dtnew");//创建数据表 
            //auto fit columns 
            for (int i = 0; i < cells.MaxDataColumn; i++)
            {
                dtnew.Columns.Add(new DataColumn(cells[i].StringValue));
            }
            DataRow dr;
            for (int k = 1; k < cells.MaxDataRow + 1; k++)
            {
                dr = dtnew.NewRow();
                for (int j = 0; j < cells.MaxDataColumn; j++)
                {
                    string s = cells[k, j].StringValue.Trim();
                    //一行行的读取数据 
                    dr[j] = s;
                }
                dtnew.Rows.Add(dr);
            }
            return dtnew;
        }

        /// <summary>
        /// 获取金额
        /// </summary>
        /// <returns></returns>
        private double GetMoney(SysUser Ent, string WorkerType)
        {
            /*
             *  工龄:   >1<5	0   >=5<10	500     >=10<15	1000    >=15<20	2000
             *  正式工: <1年	0   >1年，且为正式员工800
             */
            //            string sql = @"select YearMoney+WorkMoney As Total
            //                            from
            //                            (
            //	                            select  top 1
            //		                            case 
            //		                             when 1<datediff(year, Indutydate,getdate())and datediff(year,Indutydate,getdate())<5 then 0  
            //		                             when 5<=datediff(year,Indutydate,getdate())and datediff(year,Indutydate,getdate())<10 then 500   
            //		                             when 10<=datediff(year,Indutydate,getdate())and datediff(year,Indutydate,getdate())<15 then 1000   
            //		                             when 15<=datediff(year,Indutydate,getdate())and datediff(year,Indutydate,getdate())<20 then 2000 
            //                                     else 0
            //		                            end  As YearMoney,
            //		                            case 
            //			                            when  charindex('正式工',psnclassname)>0 and year(Indutydate)>1 then 800
            //			                            else 0
            //		                            end As WorkMoney ,psnclassname
            //	                            from FL_PortalHR..sysuser As A  
            //	                              left join HR_OA_MiddleDB..fld_rylb As B
            //		                            on B.pk_fld_rylb=A.Pk_rylb 
            //	                            where workno='{0}'
            //                            ) As T";


            //string sql = "select  FL_Culture.dbo.F_GetTravelMoney('{0}') As Total";  //注意更改数据库名称
            //  sql = string.Format(sql, Ent.WorkNo);
            // double Total = DataHelper.QueryValue<double>(sql);

            //ComUtility CU = new ComUtility();
            double Total = 0.0d;
            //Double.TryParse(CU.GetTravelAllMoney(Ent.WorkNo), out Total);


            string sql = @"select 
	                            top 1  BaseMoney+[Money]  As Total 
                            from FL_Culture..TravelMoneyConfig where WorkNo='{0}' order by CreateTime desc ";
            sql = string.Format(sql, Ent.WorkNo);
            string val = DataHelper.QueryValue(sql) + "";
            if (!string.IsNullOrEmpty(val))
            {
                Double.TryParse(val, out Total);
            }
            return Total;

        }

    }
}

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
using Aspose.Cells;
using Aim.Examining.Web.EmpWelfare;
using Aim.Examining.Web.Common;

namespace Aim.Examining.Web
{
    public partial class TravelMoneyConfigList : ExamListPage
    {

        private IList<TravelMoneyConfig> ents = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            SearchCriterion.PageSize = 40;
            TravelMoneyConfig ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<TravelMoneyConfig>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        DoBatchDelete();
                    }
                    else if (RequestActionString == "ImpUser")
                    {
                        DoImpData();
                    }
                    else if (RequestActionString == "EditMoney")
                    {
                        DoEditMoney();
                    }
                    else if (RequestActionString == "CreateMoney")
                    {
                        CreateMoney();
                    }
                    else if (RequestActionString == "CreateCheck")
                    {
                        CreateCheck();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }

        }


        /// <summary>
        /// 查询
        /// </summary>
        private void DoSelect()
        {
            string where = string.Empty;
            foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
            {
                if (!String.IsNullOrEmpty(item.Value.ToString()))
                {
                    switch (item.PropertyName)
                    {
                        case "CreateTime":

                            where += " year(CreateTime)=" + item.Value + " ";
                            break;
                    }
                }
            }
            SearchCriterion.RemoveSearch("CreateTime");
            SearchCriterion.SetOrder(TravelMoneyConfig.Prop_Corp); //公司
            SearchCriterion.SetOrder(TravelMoneyConfig.Prop_Indutydate, true); //日期

            CommPowerSplit PS = new CommPowerSplit();
            SysUser UsrEnt = SysUser.Find(UserInfo.UserID);
            if (PS.TraveMoneyConfig(UserInfo.UserID, UserInfo.LoginName)) //总部HR权限  HR1
            {
                if (!string.IsNullOrEmpty(where))
                {
                    ents = TravelMoneyConfig.FindAll(SearchCriterion, Expression.Sql(where));
                    this.PageState.Add("TravelMoneyConfigList", ents);
                }
                else
                {
                    ents = TravelMoneyConfig.FindAll(SearchCriterion);
                    this.PageState.Add("TravelMoneyConfigList", ents);
                }
            }
            else
            {
                //公司权限
                UserContextInfo UC = new UserContextInfo();
                SearchCriterion.SetSearch(TravelMoneyConfig.Prop_Corp, UC.GetUserCurrentCorpId(UserInfo.UserID));

                if (!string.IsNullOrEmpty(where))
                {
                    ents = TravelMoneyConfig.FindAll(SearchCriterion, Expression.Sql(where));
                    this.PageState.Add("TravelMoneyConfigList", ents);
                }
                else
                {
                    ents = TravelMoneyConfig.FindAll(SearchCriterion);
                    this.PageState.Add("TravelMoneyConfigList", ents);
                }
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
                TravelMoneyConfig.DoBatchDelete(idList.ToArray());
            }
        }

        /// <summary>
        /// 生成状态检查
        /// </summary>
        private void CreateCheck()
        {
            string CorpId = string.Empty;
            UserContextInfo UC = new UserContextInfo();
            CorpId = UC.GetUserCurrentCorpId(UserInfo.UserID);

            string sql = string.Empty;

            string CheckStr = "C|" + CorpId + "_" + UserInfo.UserID + "";  //生成标志
            sql = @"select sum(T) As T from 
                    (
	                    select count(*) As T from  FL_Culture..TravelMoneyConfig where year(createtime)={0} and Ext1='{1}'
	                    union all
	                    select count(*) As T from  FL_Culture..TravelMoneyConfig where year(createtime)={0} and Corp='{2}'
                    ) As T";
            sql = string.Format(sql, DateTime.Now.Year, CheckStr, CorpId);

            try
            {
                int a = DataHelper.QueryValue<int>(sql);
                if (a > 0)
                {
                    this.PageState.Add("staus", "0");
                }
                else
                {
                    this.PageState.Add("staus", "1");
                }
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }

        }

        /// <summary>
        /// 生成旅游金额
        /// </summary>
        private void CreateMoney()
        {
            string CorpId = string.Empty;
            UserContextInfo UC = new UserContextInfo();
            CorpId = UC.GetUserCurrentCorpId(UserInfo.UserID);

            EasyDictionary LimitDate = SysEnumeration.GetEnumDict("TravelLimitDate");
            string limitDateStr = string.Empty;
            if ((LimitDate["LimitDate"] + "").ToUpper() == "2L") //2 月最后一天
            {
                limitDateStr = "'" + GetLastDayOfMonth(DateTime.Now.Year, 2).ToString("yyyy-MM-dd") + "'";
            }
            else
            {
                string prefix = LimitDate["LimitDate"] + "";
                limitDateStr = "'" + DateTime.Now.Year + "-" + prefix + "'";
            }

            EasyDictionary Dic = SysEnumeration.GetEnumDict("BaseMoney");
            string One = Dic[">1<5"] + "";
            string Two = Dic[">=5<10"] + "";
            string Three = Dic[">=10<15"] + "";
            string Four = Dic[">=15<20"] + "";

            EasyDictionary DicBase = SysEnumeration.GetEnumDict("WorkYearMoney");
            string BaseMoney_One = DicBase["<1年"] + "";
            string BaseMoney_two = DicBase[">1年"] + "";

            string SQL = @"select A.* ,
                            case 
                                when 1<datediff(year, Indutydate,getdate())and datediff(year,Indutydate,getdate())<5 then {0}  
                                when 5<=datediff(year,Indutydate,getdate())and datediff(year,Indutydate,getdate())<10 then {1}   
                                when 10<=datediff(year,Indutydate,getdate())and datediff(year,Indutydate,getdate())<15 then {2}   
                                when 15<=datediff(year,Indutydate,getdate())and datediff(year,Indutydate,getdate())<20 then {3} 
                                else 0
                            end  As YearMoney,
                            case 
                                when  charindex('正式工',B.psnclassname)>0 and year(Indutydate)>1 then {5}
                               else {4}
                            end As BaseMoney ,C.GroupID as CorpId,C.Name As CorpName,D.GroupID As DeptId,D.Name As DeptName
                         from FL_PortalHR..sysuser  As A
                             left join HR_OA_MiddleDB..fld_rylb As B
                                on B.pk_fld_rylb=A.Pk_rylb 
                            left join FL_PortalHR..SysGroup As C
                                on C.GroupID=A.PK_Corp
                            left join FL_PortalHR..SysGroup As D
                                on D.GroupID=A.Pk_deptdoc
                         where 
                            (OutdutyDate='' or OutdutyDate is null) and A.Status=1 and A.Indutydate<>''  ##QUERY## ";
            SQL = string.Format(SQL, One, Two, Three, Four, BaseMoney_One, BaseMoney_two);
            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
            SQL = SQL.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            SQL = SQL.Replace("getdate()", limitDateStr);
            string where = string.Empty;
            CommPowerSplit PS = new CommPowerSplit();
            if (PS.IsAdmin(UserInfo.LoginName) || PS.IsHR(UserInfo.UserID, UserInfo.LoginName))
            {
            }
            else
            {
                where += " and A.Pk_corp='" + CorpId + "' ";
            }
            SQL = SQL.Replace("##QUERY##", where);

            DataTable UDt = DataHelper.QueryDataTable(SQL);

            for (int i = 0; i < UDt.Rows.Count; i++)
            {
                try
                {
                    TravelMoneyConfig TM = new TravelMoneyConfig();
                    string YearMoney = UDt.Rows[i]["YearMoney"] + "", BaseMoney = UDt.Rows[i]["BaseMoney"] + "";
                    if (!string.IsNullOrEmpty(YearMoney))
                    {
                        decimal M = 0.0m;
                        if (decimal.TryParse(YearMoney, out M))
                        {
                            TM.Money = M;
                        }
                    }
                    else
                    {
                        TM.Money = 0;
                    }

                    //基本津贴
                    if (!string.IsNullOrEmpty(BaseMoney))
                    {
                        decimal M = 0.0m;
                        if (decimal.TryParse(BaseMoney, out M))
                        {
                            TM.BaseMoney = M;
                        }
                    }
                    else
                    {
                        TM.BaseMoney = 0;
                    }

                    TM.UserId = UDt.Rows[i]["UserID"] + "";
                    TM.UserName = UDt.Rows[i]["Name"] + "";
                    TM.WorkNo = UDt.Rows[i]["WorkNo"] + "";

                    DateTime DTime = new DateTime();
                    if (DateTime.TryParse(UDt.Rows[i]["Indutydate"] + "", out DTime))
                    {
                        TM.Indutydate = DTime;
                    }

                    TM.HaveUsed = "N";
                    TM.Corp = UDt.Rows[i]["CorpId"] + "";
                    TM.CorpName = UDt.Rows[i]["CorpName"] + "";
                    TM.DeptId = UDt.Rows[i]["DeptId"] + "";
                    TM.DeptName = UDt.Rows[i]["DeptName"] + "";
                    TM.CreateTime = DateTime.Now;
                    TM.Ext1 = "C|" + CorpId + "_" + UserInfo.UserID + "";  //生成标志
                    TM.Create();
                }
                catch { }
            }
            this.PageState.Add("State", "1");

        }
        private DateTime GetLastDayOfMonth(int Year, int Month)
        {
            //这里的关键就是 DateTime.DaysInMonth 获得一个月中的天数
            int Days = DateTime.DaysInMonth(Year, Month);
            return Convert.ToDateTime(Year.ToString() + "-" + Month.ToString() + "-" + Days.ToString());

        }

        /// <summary>
        /// 服务年限奖励金额修正
        /// </summary>
        private void DoEditMoney()
        {
            string prefix = FileModule.FindFirstByProperties("Name", "Portal").RootPath + "\\Default\\";
            string FilePath = RequestData.Get("FileId") + "";
            FilePath = prefix + FilePath;
            DataTable Dt = ExcelToDataTable(FilePath, 4);
            CommPowerSplit Ps = new CommPowerSplit();

            bool IsPower = false;
            if (Ps.IsHR(UserInfo.UserID, UserInfo.LoginName) || Ps.IsAdmin(UserInfo.LoginName) || Ps.IsInAdminsRole(UserInfo.LoginName))
            {
                IsPower = true;
            }

            for (int i = 0; i < Dt.Rows.Count; i++)
            {
                try
                {
                    string workno = Dt.Rows[i]["工号"] + "";
                    SysUser UserEnt = SysUser.FindFirstByProperties(SysUser.Prop_WorkNo, Dt.Rows[i]["工号"]);
                    SysGroup Group = SysGroup.TryFind(UserEnt.Pk_corp);

                    TravelMoneyConfig TM = new TravelMoneyConfig();
                    decimal Money = 0.0m;

                    if (!string.IsNullOrEmpty(Dt.Rows[i]["服务年限奖励金"] + ""))
                    {
                        decimal M = 0.0m;
                        if (decimal.TryParse(Dt.Rows[i]["服务年限奖励金"] + "", out M))
                        {
                            Money = M;
                        }
                    }

                    string HasUsed = string.Empty;
                    if (!string.IsNullOrEmpty(Dt.Rows[i]["是否已用"] + ""))
                    {
                        HasUsed = ((Dt.Rows[i]["是否已用"] + "") == "是" || (Dt.Rows[i]["是否已用"] + "") == "Y") ? "Y" : "N";
                    }

                    string UpdateSQL = @"declare @id varchar(36)
                                        select top 1 @id=Id from FL_Culture..TravelMoneyConfig where WorkNo='{0}' and {3}
                                        order by CreateTime desc ;
                                        update FL_Culture..TravelMoneyConfig set Money={1}, HaveUsed='{2}'
                                        where Id=@id";
                    //权限
                    string Condition = string.Empty;
                    Condition = IsPower ? " 1=1 " : " Corp ='" + Group.GroupID + "'  ";
                    UpdateSQL = string.Format(UpdateSQL, workno, Money, HasUsed, Condition);
                    DataHelper.ExecSql(UpdateSQL);
                }
                catch (Exception e)
                {
                    //throw new Exception(e.Message);
                }
            }
            this.PageState.Add("State", "1");
        }

        /// <summary>
        /// 导入数据
        /// </summary>
        private void DoImpData()
        {
            string prefix = FileModule.FindFirstByProperties("Name", "Portal").RootPath + "\\Default\\";
            string FilePath = RequestData.Get("FileId") + "";
            FilePath = prefix + FilePath;
            DataTable Dt = ExcelToDataTable(FilePath, 4);

            for (int i = 0; i < Dt.Rows.Count; i++)
            {
                try
                {
                    string workno = Dt.Rows[i]["工号"] + "";
                    SysUser UserEnt = SysUser.FindFirstByProperties(SysUser.Prop_WorkNo, Dt.Rows[i]["工号"]);
                    SysGroup Group = SysGroup.TryFind(UserEnt.Pk_corp);
                    SysGroup DeptGroup = SysGroup.TryFind(UserEnt.Pk_deptdoc); //Dept

                    TravelMoneyConfig TM = new TravelMoneyConfig();
                    ComUtility Utility = new ComUtility();
                    string Money = string.Empty;

                    if (string.IsNullOrEmpty(Dt.Rows[i]["服务年限奖励金"] + ""))
                    {
                        Money = Utility.GetTravelMoney(workno);
                        decimal M = 0.0m;
                        if (decimal.TryParse(Money, out M))
                        {
                            TM.Money = M;
                        }
                    }
                    else
                    {
                        decimal M = 0.0m;
                        if (decimal.TryParse(Dt.Rows[i]["服务年限奖励金"] + "", out M))
                        {
                            TM.Money = M;
                        }
                    }

                    //基本津贴
                    decimal MK = 0.0m;
                    string BaseMoney = Utility.GetTravelBaseMoney(workno);
                    if (decimal.TryParse(BaseMoney, out MK))
                    {
                        TM.BaseMoney = MK;
                    }

                    TM.UserId = UserEnt.UserID;
                    TM.UserName = UserEnt.Name;
                    TM.WorkNo = UserEnt.WorkNo;

                    DateTime DTime = new DateTime();
                    if (DateTime.TryParse(UserEnt.Indutydate, out DTime))
                    {
                        TM.Indutydate = DTime;
                    }

                    if (!string.IsNullOrEmpty(Dt.Rows[i]["是否已用"] + ""))
                    {
                        string val = string.Empty;
                        val = ((Dt.Rows[i]["是否已用"] + "") == "是" || (Dt.Rows[i]["是否已用"] + "") == "Y") ? "Y" : "N";
                        TM.HaveUsed = val;
                    }

                    if (Group != null)
                    {
                        TM.Corp = Group.GroupID;
                        TM.CorpName = Group.Name;

                    }
                    if (DeptGroup != null)
                    {
                        TM.DeptId = DeptGroup.GroupID;
                        TM.DeptName = DeptGroup.Name;
                    }

                    TM.CreateTime = DateTime.Now;
                    TM.UserId = UserEnt.UserID;
                    TM.Create();

                }
                catch { }
            }
            this.PageState.Add("State", "1");
        }

        /// <summary> 
        ///  Excel导入DataTable 
        /// </summary> 
        /// <param name="ExcelPath">Excel绝对路径</param> 
        /// <param name="DataColumn">要计算的数据列</param> 
        /// <returns>DataTable</returns> 
        protected DataTable ExcelToDataTable(string ExcelPath, int DataColumn)
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
            int MaxDataColumn = DataColumn;
            for (int i = 0; i < MaxDataColumn; i++)
            {
                dtnew.Columns.Add(new DataColumn(cells[i].StringValue));
            }
            DataRow dr;
            for (int k = 1; k < cells.MaxDataRow + 1; k++)
            {
                dr = dtnew.NewRow();
                for (int j = 0; j < MaxDataColumn; j++)
                {
                    string s = cells[k, j].StringValue.Trim();
                    //一行行的读取数据 
                    dr[j] = s;
                }
                dtnew.Rows.Add(dr);
            }
            return dtnew;
        }
    }
}


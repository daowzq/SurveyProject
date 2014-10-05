using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using System.Data.OleDb;
using System.Data;
using System.IO;

namespace Aim.Examining.Web.EmpWelfare
{
    public class ComUtility
    {
        internal string GetWorkNo(string UserId)
        {
            if (!string.IsNullOrEmpty(UserId))
            {
                var Ent = SysUser.FindFirstByProperties("UserID", UserId);
                return Ent.WorkNo + "|" + Ent.Sex + "|" + Ent.Indutydate;
            }
            else
            {
                return "";
            }
        }

        /// <summary>
        /// 获取服务年限金额
        /// </summary>
        /// <param name="workno">工号</param>
        /// <returns></returns>
        public string GetTravelMoney(string workno)
        {
            EasyDictionary Dic = SysEnumeration.GetEnumDict("BaseMoney");
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

            string One = Dic[">1<5"] + "";
            string Two = Dic[">=5<10"] + "";
            string Three = Dic[">=10<15"] + "";
            string Four = Dic[">=15<20"] + "";

            string sql = @"select YearMoney As Total
		                    from
		                    (
			                    select  top 1
				                case 
				                    when 1<datediff(year, Indutydate,getdate())and datediff(year,Indutydate,getdate())<5 then {1}  
				                    when 5<=datediff(year,Indutydate,getdate())and datediff(year,Indutydate,getdate())<10 then {2}   
				                    when 10<=datediff(year,Indutydate,getdate())and datediff(year,Indutydate,getdate())<15 then {3}   
				                    when 15<=datediff(year,Indutydate,getdate())and datediff(year,Indutydate,getdate())<20 then {4} 
				                    else 0
				                end  As YearMoney,
				               -- case 
					           --     when  charindex('正式工',psnclassname)>0 and year(Indutydate)>1 then 800
					           --     else 0
				               -- end As WorkMoney ,
                                psnclassname
			                    from FL_PortalHR..sysuser As A  
				                    left join HR_OA_MiddleDB..fld_rylb As B
				                on B.pk_fld_rylb=A.Pk_rylb 
			                    where workno='{0}'
		                    ) As T";

            sql = sql.Replace("getdate()", limitDateStr);
            sql = string.Format(sql, workno, One, Two, Three, Four);
            sql = sql.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
            return DataHelper.QueryValue(sql) + "";
        }

        private DateTime GetLastDayOfMonth(int Year, int Month)
        {
            //这里的关键就是 DateTime.DaysInMonth 获得一个月中的天数
            int Days = DateTime.DaysInMonth(Year, Month);
            return Convert.ToDateTime(Year.ToString() + "-" + Month.ToString() + "-" + Days.ToString());

        }


        /// <summary>
        /// 获取服务年限+基本津贴
        /// </summary>
        /// <param name="workno">工号</param>
        /// <returns></returns>
        public string GetTravelAllMoney(string workno)
        {
            EasyDictionary Dic = SysEnumeration.GetEnumDict("BaseMoney");

            string One = Dic[">1<5"] + "";
            string Two = Dic[">=5<10"] + "";
            string Three = Dic[">=10<15"] + "";
            string Four = Dic[">=15<20"] + "";

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

            EasyDictionary DicBase = SysEnumeration.GetEnumDict("WorkYearMoney");
            string BaseMoney_One = DicBase["<1年"] + "";
            string BaseMoney_two = DicBase[">1年"] + "";

            string sql = @"select YearMoney + WorkMoney As Total
		                    from
		                    (
			                    select  top 1
				                case 
				                    when 1<datediff(year, Indutydate,getdate())and datediff(year,Indutydate,getdate())<5 then {1}  
				                    when 5<=datediff(year,Indutydate,getdate())and datediff(year,Indutydate,getdate())<10 then {2}   
				                    when 10<=datediff(year,Indutydate,getdate())and datediff(year,Indutydate,getdate())<15 then {3}   
				                    when 15<=datediff(year,Indutydate,getdate())and datediff(year,Indutydate,getdate())<20 then {4} 
				                    else 0
				                end  As YearMoney,
				                case 
					                when  charindex('正式工',psnclassname)>0 and year(Indutydate)>1 then {6}
					               else {5}
				                end As WorkMoney ,
                                psnclassname
			                    from FL_PortalHR..sysuser As A  
				                    left join HR_OA_MiddleDB..fld_rylb As B
				                on B.pk_fld_rylb=A.Pk_rylb 
			                    where workno='{0}'
		                    ) As T";

            sql = sql.Replace("getdate()", limitDateStr);
            sql = string.Format(sql, workno, One, Two, Three, Four, BaseMoney_One.Replace("NULL", "0"), BaseMoney_two);
            sql = sql.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
            return DataHelper.QueryValue(sql) + "";
        }

        /// <summary>
        ///  基本津贴
        /// </summary>
        /// <param name="workno">工号</param>
        /// <returns></returns>
        public string GetTravelBaseMoney(string workno)
        {
            EasyDictionary DicBase = SysEnumeration.GetEnumDict("WorkYearMoney");
            string BaseMoney_One = DicBase["<1年"] + "";
            string BaseMoney_two = DicBase[">1年"] + "";

            string sql = @"select  WorkMoney As Total
		                    from
		                    (
			                    select  top 1
				                case 
					                when  charindex('正式工',psnclassname)>0 and year(Indutydate)>1 then {2}
					               else {1}
				                end As WorkMoney ,
                                psnclassname
			                    from FL_PortalHR..sysuser As A  
				                    left join HR_OA_MiddleDB..fld_rylb As B
				                on B.pk_fld_rylb=A.Pk_rylb 
			                    where workno='{0}'
		                    ) As T";

            sql = string.Format(sql, workno, BaseMoney_One.Replace("NULL", "0"), BaseMoney_two);
            sql = sql.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
            return DataHelper.QueryValue(sql) + "";
        }

        /// <summary>
        /// 判断该用户是否在通知范围内
        /// </summary>
        /// <param name="TypeName">类型名称</param>
        /// <param name="UserId">用户ID</param>
        /// <returns>用户ID</returns>
        public string CheckApply(string TypeName, string UserId, string corpId)
        {

            /* 
             * string SQL = @"With NoticeDpt 
                             As
                             (
                                  select F1 As GroupID  from  FL_Culture..f_splitstr (
                                   (select DeptId  from  FL_Culture..UseWelfareNote 
                                       where  State='1' 
                                       and  cast( convert(varchar(10), getdate(),120) as Datetime) between  StartTime and EndTime
                                       and  TypeName='{0}'
                                   ),',')
                             ),
                             NoticeUsr As
                             (
                                 select U.UserID  from NoticeDpt  As T
                                 cross Apply(
                                     select GroupID from FL_PortalHR..SysGroup As A  
                                     where A.Status=1 and  A.Path like '%'+T.GroupID+'%' or A.GroupID=T.GroupID
                                 ) As CA 
                                 left join  FL_PortalHR..SysUserGroup As U
                                     on CA.GroupID=U.GroupID
                             ),
                             IsExistsUsr As 
                             (
                                 select * from NoticeUsr where UserID='{1}'
                             )
                             select * from IsExistsUsr";   */
            //comment by WGM 8/13
            string SQL = @"With NoticeDpt 
                            As
                            (
                                select Id As NoticeId, CA.F1 As GroupID,CreateTime from  FL_Culture..UseWelfareNote As A
                                    Cross apply
                                    ( 
                                        select  *  from  FL_Culture..f_splitstr (A.DeptId,',')
                                    )As CA
                                where  State='1'  --已发布状态
                                      and  getdate() between  StartTime and EndTime
                                      and  TypeName='{0}'  
                            ),
                            NoticeUsr As
                            (
                                select U.UserID,T.CreateTime,T.NoticeId from NoticeDpt  As T
                                cross Apply(
                                    select GroupID from FL_PortalHR..SysGroup As A  
                                    where A.Status=1 and  A.Path like '%'+T.GroupID+'%' or A.GroupID=T.GroupID
                                ) As CA 
                                left join  FL_PortalHR..SysUserGroup As U
                                    on CA.GroupID=U.GroupID
                              where UserID='{1}'
                            )
                            select top 1 NoticeId from NoticeUsr order by createTime desc  ";

            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

            SQL = string.Format(SQL, TypeName, UserId);
            object obj = DataHelper.QueryValue(SQL);
            return obj == null ? "" : obj.ToString();
        }

        /// <summary>
        /// 
        /// </summary>
        internal void InputExcel()
        {

        }

        #region 导入用户
        /// <summary>
        /// Excel转成DataTable
        /// </summary>
        /// <param name="FileName">文件全路径</param>
        /// <returns></returns>
        public DataTable ExcelToDataTable(string FileName)
        {
            string Extend = string.Empty;   //文件扩展名
            string strConn = string.Empty;

            if (FileName.Contains(","))
            {
                FileName = FileName.Substring(0, FileName.Length - 1);
                Extend = FileName.Split(new string[] { "." }, StringSplitOptions.RemoveEmptyEntries)[1];
            }
            else
            {
                Extend = FileName.Split(new string[] { "." }, StringSplitOptions.RemoveEmptyEntries)[1];
            }

            strConn = ComUtility.GetConStr(FileName);  //获取Excel连接字符串 

            OleDbConnection XLSconn = new OleDbConnection(strConn);
            OleDbDataAdapter da = new OleDbDataAdapter("select * from [Sheet1$]", XLSconn);
            DataTable dt = new DataTable();
            da.Fill(dt);


            if (dt.Rows.Count > 0)
            {
                try
                {
                    if (File.Exists(FileName))
                        File.Delete(FileName);
                }
                catch
                {
                }
            }

            return dt;
        }

        public static string GetConStr(string Path)
        {
            string strConn = string.Empty;
            if (Path.Contains("xlsx")) //2007的链接参数
            {
                strConn = "Provider=Microsoft.ACE.OLEDB.12.0;" + "Data Source=" + Path + ";" + "Extended Properties=Excel 12.0 Xml;Persist Security Info=False";
            }
            else  //2003的链接参数
            {
                strConn = "Provider=Microsoft.Jet.OLEDB.4.0;" + "Data Source=" + Path + ";" + "Extended Properties=Excel 8.0;Persist Security Info=False";
            }
            return strConn;
        }
        #endregion
    }
}

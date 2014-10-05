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

namespace Aim.Examining.Web
{
    public class CommPowerSplit
    {


        /// <summary>
        /// 获取所在角色关联的公司
        /// </summary>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public string GetRoleCorps(string UserID)
        {
            //跟配置角色关联
            string sql = @"select CompanyIds from sysrole where CompanyIds is not null and 
                                roleid in ( select RoleID from SysUserRole where UserId='{0}') ";
            return DataHelper.QueryValue(string.Format(sql, UserID)) + "";
        }

        /// <summary>
        /// 获取配置的公司权限
        /// </summary>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public string GetCorps(string UserID)
        {
            string sql = @"select CompanyIds from SysRole As A
                            left join SysUserRole As B
	                            on A.RoleID=B.RoleID 
                            where A.CompanyIds is not null and UserID='{0}' ";
            return DataHelper.QueryValue(string.Format(sql, UserID)) + "";
        }

        /// <summary>
        /// 判断是否为管理员或者问卷角色
        /// </summary>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public bool IsSurveyRole(string UserID, string LoginName)
        {
            if (LoginName.ToLower().Contains("admin") || IsInAdminsRole(UserID))
            {
                return true;
            }
            else
            {
                string SQL = @"select  * from  FL_PortalHR..SysRole  As A
		                            inner join FL_PortalHR..SysUserRole As B
		                                on  A.RoleID=B.RoleID 
                                  where A.Code='PubSurvey' and B.UserID='{0}'";
                SQL = string.Format(SQL, UserID);
                SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

                object obj = DataHelper.QueryValue(SQL);
                if (obj != null)
                {
                    return true;
                }

                else
                {
                    return false;
                }
            }
        }

        /// <summary>
        /// 判断是否为管理员或者员工申诉角色
        /// </summary>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public bool IsAppealRole(string UserID, string LoginName)
        {
            if (LoginName.ToLower().Contains("admin") || IsInAdminsRole(UserID))
            {
                return true;
            }
            else
            {
                string SQL = @"select  * from  FL_PortalHR..SysRole  As A
		                            inner join FL_PortalHR..SysUserRole As B
		                                on  A.RoleID=B.RoleID 
                                  where A.Code='EmpAppealRole' and B.UserID='{0}'";
                SQL = string.Format(SQL, UserID);
                SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

                object obj = DataHelper.QueryValue(SQL);
                if (obj != null)
                {
                    return true;
                }

                else
                {
                    return false;
                }
            }
        }

        /// <summary>
        /// 判断是否为管理员或者旅游金额配置权限
        /// </summary>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public bool TraveMoneyConfig(string UserID, string LoginName)
        {
            if (LoginName.ToLower().Contains("admin") || IsInAdminsRole(UserID))
            {
                return true;
            }
            else
            {
                string SQL = @"select  * from  FL_PortalHR..SysRole  As A
		                            inner join FL_PortalHR..SysUserRole As B
		                                on  A.RoleID=B.RoleID 
                                  where A.Code='HR1' and B.UserID='{0}'";
                SQL = string.Format(SQL, UserID);
                SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

                object obj = DataHelper.QueryValue(SQL);
                if (obj != null)
                {
                    return true;
                }

                else
                {
                    return false;
                }
            }
        }

        /// <summary>
        /// 判断是否为管理员或者福利申报通知角色
        /// </summary>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public bool IsNoticeRole(string UserID, string LoginName)
        {
            if (LoginName.ToLower().Contains("admin") || IsInAdminsRole(UserID))
            {
                return true;
            }
            else
            {
                string SQL = @"select  * from  FL_PortalHR..SysRole  As A
		                            inner join FL_PortalHR..SysUserRole As B
		                                on  A.RoleID=B.RoleID 
                                    where A.Code='WelfareNotice' and B.UserID='{0}'";
                SQL = string.Format(SQL, UserID);
                SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

                object obj = DataHelper.QueryValue(SQL);
                if (obj != null)
                {
                    return true;
                }

                else
                {
                    return false;
                }
            }
        }


        /// <summary>
        /// 员工心声角色或管理员
        /// </summary>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public bool IsEmpVoiceRole(string UserID, string LoginName)
        {
            if (LoginName.ToLower().Contains("admin") || IsInAdminsRole(UserID))
            {
                return true;
            }
            else
            {
                string SQL = @"select  * from  FL_PortalHR..SysRole  As A
		                            inner join FL_PortalHR..SysUserRole As B
		                                on  A.RoleID=B.RoleID 
                                    where A.Code='EmpVoiceRole' and B.UserID='{0}'";
                SQL = string.Format(SQL, UserID);
                SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

                object obj = DataHelper.QueryValue(SQL);
                if (obj != null)
                {
                    return true;
                }

                else
                {
                    return false;
                }
            }
        }

        /// <summary>
        /// 设置管理  
        /// </summary>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public bool IsSetMgrRole(string UserID, string LoginName)
        {
            if (LoginName.ToLower().Contains("admin") || IsInAdminsRole(UserID))
            {
                return true;
            }
            else
            {
                string SQL = @"select  * from  FL_PortalHR..SysRole  As A
		                            inner join FL_PortalHR..SysUserRole As B
		                                on  A.RoleID=B.RoleID 
                                    where A.Code='setmgr'  and B.UserID='{0}'";
                SQL = string.Format(SQL, UserID);
                SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

                object obj = DataHelper.QueryValue(SQL);
                if (obj != null)
                {
                    return true;
                }

                else
                {
                    return false;
                }
            }
        }


        /// <summary>
        /// 是否总部HR  
        /// </summary>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public bool IsHR(string UserID, string LoginName)
        {
            if (LoginName.ToLower().Contains("admin") || IsInAdminsRole(UserID))
            {
                return true;
            }
            else
            {
                string SQL = @"select  * from  FL_PortalHR..SysRole  As A
		                            inner join FL_PortalHR..SysUserRole As B
		                                on  A.RoleID=B.RoleID 
                                    where A.Code='HR1'  and B.UserID='{0}'";
                SQL = string.Format(SQL, UserID);
                SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

                object obj = DataHelper.QueryValue(SQL);
                if (obj != null)
                {
                    return true;
                }

                else
                {
                    return false;
                }
            }
        }

        /// <summary>
        /// 积分维护
        /// </summary>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public bool IsScoreRole(string UserID, string LoginName)
        {
            if (LoginName.ToLower().Contains("admin") || IsInAdminsRole(UserID))
            {
                return true;
            }
            else
            {
                string SQL = @"select  * from  FL_PortalHR..SysRole  As A
		                            inner join FL_PortalHR..SysUserRole As B
		                                on  A.RoleID=B.RoleID 
                                    where A.Code='ScoreMagr' and B.UserID='{0}'";
                SQL = string.Format(SQL, UserID);
                SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

                object obj = DataHelper.QueryValue(SQL);
                if (obj != null)
                {
                    return true;
                }

                else
                {
                    return false;
                }
            }
        }


        #region  判断管理员
        /// <summary>
        /// 判断是否为管理员 
        /// </summary>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public bool IsAdmin(string LoginName)
        {
            if (LoginName.ToLower().Contains("admin"))
            {
                return true;
            }
            else
            {
                return false;
            }

        }

        /// <summary>
        /// 判断是否在管理员权限组 
        /// </summary>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public bool IsInAdminsRole(string UserId)
        {
            string SQL = @"select  * from  FL_PortalHR..SysRole  As A
		                            inner join FL_PortalHR..SysUserRole As B
		                                on  A.RoleID=B.RoleID 
                                    where A.Code='AdminRole' and B.UserID='{0}'";
            SQL = string.Format(SQL, UserId);
            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

            object obj = DataHelper.QueryValue(SQL);
            if (obj != null)
            {
                return true;
            }

            else
            {
                return false;
            }
        }
        #endregion
    }
}

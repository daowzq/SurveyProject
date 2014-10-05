using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Aim.Data;
using System.Data;
using Aim.Portal.Model;
using Aim.Examining.Model;
using System.Configuration;
using System.Data.SqlClient;
using NHibernate.Criterion;

namespace Aim.Examining.Web
{
    public static class WFHelper
    {
        static string MiddleCon = ConfigurationManager.AppSettings["FlJKDB"];
        static SysGroup group = null;

        /// <summary>
        /// 获取分支HR
        /// </summary>
        /// <param name="UserId">人员Id</param>
        /// <param name="DeptId">部门Id</param>
        /// <param name="Type">HR类型(专员、经理)</param>
        /// <param name="formType">表单类型(加班、请假)</param>
        /// <param name="hrId">HRId</param>
        /// <param name="hrName">HRName</param>
        public static void getFzHR(string UserId, string DeptId, string Type, string formType, ref string hrId, ref string hrName)
        {

        }

        /// <summary>
        /// 检测task有没有人员重复
        /// </summary>
        /// <param name="UserId"></param>
        /// <param name="NextNodeName">下一环节名称</param>
        /// <param name="WorkFlowInstanceId"></param>
        /// <returns></returns>
        public static bool CheckUserRepeat(string UserId, string NextNodeName, string WorkFlowInstanceId)
        {
            string sql = @"select count(1) from task where workFlowInstanceID='{0}'
                        and OwnerId='{1}' and ApprovalNodeName<>'{2}'
                        and CreatedTime < (select isnull(min(CreatedTime),'2099-10-10') from task where WorkFlowInstanceID='{0}' 
                        and ApprovalNodeName='{2}')";

            sql = string.Format(sql, WorkFlowInstanceId, UserId, NextNodeName);
            int count = DataHelper.QueryValue<int>(sql);
            return count > 0 ? true : false;
        }



        /// <summary>
        /// 获取入集团日期
        /// </summary>
        /// <param name="workNo"></param>
        /// <returns></returns>
        public static string getIndutydate(string workNo)
        {
            string indutydate = "";
            indutydate = ExecuteScalar("select min(indutydate) from fld_ryxx where psncode='" + workNo + "'", MiddleCon);
            return indutydate;
        }


        /// <summary>
        /// 获取岗位等级
        /// </summary>
        /// <returns>int</returns>
        private static int getRoleCode(string roleName)
        {
            int result = 0;

            if (roleName.Contains("副组长"))
            {
                result = 1;
            }
            if (roleName.Contains("组长"))
            {
                result = 2;
            }
            else if (roleName.Contains("副科长"))
            {
                result = 3;
            }
            else if (roleName.Contains("科长"))
            {
                result = 4;
            }

            else if (roleName == "部门副经理" || roleName.Contains("部副经理") || roleName == "副经理")
            {
                result = 5;
            }
            else if (roleName == "部门经理" || roleName.Contains("部经理") || roleName == "经理")
            {
                result = 6;
            }

            /*else if (roleName.Contains("经理") && !roleName.Contains("总经理"))
            {
                result = 5;
            }*/

            else if (roleName.Contains("助理总经理"))
            {
                result = 7;
            }
            else if (roleName.Contains("副总经理"))
            {
                result = 8;
            }
            else if (roleName.Contains("总经理"))
            {
                result = 9;
            }

            return result;
        }



        /// <summary>
        /// 获取上级主管
        /// </summary>
        /// <param name="UserId">UserId</param>
        /// <param name="cengshu">层数</param>
        /// <returns>SysUser</returns>
        public static SysUser GetParentUsers(string UserId, int cengshu, string DeptId)
        {
            //先更具人和部门获取
            string sql = "";
            DataTable dt = new DataTable();
            if (!string.IsNullOrEmpty(DeptId))
            {
                sql = @"select psncode1,psncode2,psncode3,psncode4,psncode5,psncode6 from V_GWRelation where pk_JobCode in
                        (select top 1 pk_gw from fld_ryxx where psncode='{0}' and pk_deptdoc='" + DeptId + "')";

                SysUser userent = SysUser.Find(UserId);
                sql = string.Format(sql, userent.WorkNo);
                dt = GetData(sql, MiddleCon);
            }
            if (dt == null || dt.Rows.Count == 0)
            {
                sql = @"select psncode1,psncode2,psncode3,psncode4,psncode5,psncode6 from V_GWRelation where pk_JobCode in
                        (select top 1 pk_gw from fld_ryxx where psncode='{0}' and pk_gw is not null and isnull(outdutydate,'')='' order by indutydate desc)";

                SysUser userent = SysUser.Find(UserId);
                sql = string.Format(sql, userent.WorkNo);
                dt = GetData(sql, MiddleCon);
            }
            List<EasyDictionary> ess = new List<EasyDictionary>();
            int count = 0;
            SysUser user = null;
            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                for (var i = 1; i < 7; i++)
                {
                    if (row["psncode" + i] != System.DBNull.Value && row["psncode" + i].ToString().Trim() != "")
                    {
                        count++;
                        if (count == cengshu)
                        {
                            string workNo = row["psncode" + i] + "";
                            user = SysUser.FindAll(Expression.Sql(" WorkNo='" + workNo + "' and isnull(outdutydate,'')='' ")).FirstOrDefault();
                            if (user == null)
                            {
                                cengshu++;
                            }
                            else
                            {
                                break;
                            }
                        }
                    }
                }

                //if (li != 0)
                //{
                //    string workNo = row["psncode" + li].ToString();
                //    user = SysUser.FindAllByProperties(SysUser.Prop_WorkNo, workNo)[0];
                //    return user;
                //}
            }
            return user;
        }



        #region 获取流程类型


        /// <summary>
        /// 递归获取第二层组织结构
        /// </summary>
        /// <param name="ParentId"></param>
        /// <returns></returns>
        public static string getCzlxDG(string ParentId)
        {
            group = SysGroup.TryFind(ParentId);
            if (group == null)
            {
                return "";
            }
            else if (group.PathLevel != 2)
            {
                return getCzlxDG(group.ParentID);
            }
            else
            {
                return group.Description;
            }
        }
        #endregion

        /// <summary>
        /// 获取职位等级
        /// </summary>
        /// <param name="PostGrade">等级</param>
        /// <returns></returns>
        public static string GetPostGrade(string PostGrade)
        {
            string result = "";

            return result;
        }

        /// <summary>
        /// 获取人员领导层数
        /// </summary>
        /// <param name="workno"></param>
        /// <param name="deptid"></param>
        /// <returns></returns>
        public static int GetParentRoleLength(string workno, ref string nextUserId, ref string nextUserName, string DeptId)
        {
            int length = 0;

            string sql = "";
            DataTable dt = new DataTable();
            if (!string.IsNullOrEmpty(DeptId))
            {
                string MiddleDBName = ConfigurationManager.AppSettings["MiddleDBName"];
                int gws = DataHelper.QueryValue<int>("select count(1) from " + MiddleDBName + "..fld_ryxx where psncode='" + workno + "' and pk_corp=(select top 1 pk_corp from " + MiddleDBName + "..fld_bmml where pk_deptdoc='" + DeptId + "')");
                if (gws > 1)
                {
                    string path = DataHelper.QueryValue("select [path]+GroupId from SysGroup where GroupId='" + DeptId + "'") + "";
                    sql = @"select psncode1,psncode2,psncode3,psncode4,psncode5,psncode6 from V_GWRelation where pk_JobCode in
                       (select top 1 pk_gw from fld_ryxx where psncode='{0}' and '" + path + "' like '%'+ pk_deptdoc+'%')";
                }
                else
                {
                    sql = @"select psncode1,psncode2,psncode3,psncode4,psncode5,psncode6 from V_GWRelation where pk_JobCode in
                       (select top 1 pk_gw from fld_ryxx where psncode='{0}' and pk_corp=(select top 1 pk_corp from fld_bmml where pk_deptdoc='" + DeptId + "'))";
                }
                sql = string.Format(sql, workno);
                dt = GetData(sql, MiddleCon);
            }
            if (dt == null || dt.Rows.Count == 0)
            {
                sql = @"select psncode1,psncode2,psncode3,psncode4,psncode5,psncode6 from V_GWRelation where pk_JobCode in
                        (select top 1 pk_gw from fld_ryxx where psncode='{0}' and pk_gw is not null and isnull(outdutydate,'')='' order by indutydate desc)";

                sql = string.Format(sql, workno);
                dt = GetData(sql, MiddleCon);
            }
            bool hasuser = false;
            SysUser userent = null;
            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                for (var i = 1; i < 7; i++)
                {
                    if (row["psncode" + i] != System.DBNull.Value && row["psncode" + i].ToString().Trim() != "")
                    {
                        if (length == 0 || userent == null)
                        {
                            userent = SysUser.FindAllByProperty(SysUser.Prop_WorkNo, row["psncode" + i] + "").FirstOrDefault();
                            if (userent != null)
                            {
                                nextUserId = userent.UserID;
                                nextUserName = userent.Name;
                                hasuser = true;
                            }
                        }
                        length++;
                    }
                }
            }
            if (!hasuser)
            {
                nextUserId = "";
                nextUserName = "";
            }
            return length;
        }

        /// <summary>
        /// 获取人员领导层数
        /// </summary>
        /// <param name="workno"></param>
        /// <param name="CompanyId">公司Id</param>
        /// <returns></returns>
        public static int GetParentRoleLength(string workno, ref string nextUserId, ref string nextUserName, string CompanyId, string type)
        {
            int length = 0;

            string sql = "";
            DataTable dt = new DataTable();
            if (!string.IsNullOrEmpty(CompanyId))
            {
                sql = @"select psncode1,psncode2,psncode3,psncode4,psncode5,psncode6 from V_GWRelation where pk_JobCode in
                        (select top 1 pk_gw from fld_ryxx where psncode='{0}' and pk_corp='" + CompanyId + "')";

                sql = string.Format(sql, workno);
                dt = GetData(sql, MiddleCon);
            }
            if (dt == null || dt.Rows.Count == 0)
            {
                sql = @"select psncode1,psncode2,psncode3,psncode4,psncode5,psncode6 from V_GWRelation where pk_JobCode in
                        (select top 1 pk_gw from fld_ryxx where psncode='{0}' and pk_gw is not null and isnull(outdutydate,'')='' order by indutydate desc)";

                sql = string.Format(sql, workno);
                dt = GetData(sql, MiddleCon);
            }

            bool hasuser = false;
            SysUser userent = null;
            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                for (var i = 1; i < 7; i++)
                {
                    if (row["psncode" + i] != System.DBNull.Value && row["psncode" + i].ToString().Trim() != "")
                    {
                        if (length == 0 || userent == null)
                        {
                            userent = SysUser.FindAllByProperty(SysUser.Prop_WorkNo, row["psncode" + i] + "").FirstOrDefault();
                            if (userent != null)
                            {
                                nextUserId = userent.UserID;
                                nextUserName = userent.Name;
                                hasuser = true;
                            }
                        }
                        length++;
                    }
                }
            }
            if (!hasuser)
            {
                nextUserId = "";
                nextUserName = "";
            }
            return length;
        }

        /// <summary>
        /// 获取人员的部门数
        /// </summary>
        /// <param name="UserId">UserId</param>
        /// <returns>部门数</returns>
        public static int getDeptCount(string UserId)
        {
            int result = 0;
            string sql = "select count(1) from sysusergroup m inner join sysgroup g on g.groupid=m.groupid where UserId='" + UserId + "' and g.Type='2' and isnull(outdutydate,'')=''";
            result = DataHelper.QueryValue<int>(sql);
            return result;
        }

        #region 获取部门
        /// <summary>
        /// 获取全部组织结构
        /// </summary>
        /// <param name="UserId"></param>
        /// <returns></returns>
        public static string getZzjg(string UserId, bool flag)
        {

            string result = "";
            string sql = @"select A.* from FL_PortalHR..SysGroup  As A
                            left join FL_PortalHR..SysUser As B 
                            On A.GroupID=B.Pk_deptdoc  
                            where B.UserID='{0}'";
            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
            sql = string.Format(sql, UserId);

            DataTable dtGroup = DataHelper.QueryDataTable(sql);

            if (dtGroup.Rows.Count > 0 && dtGroup.Rows[0]["Type"] + "" != "3")
            {
                result += dtGroup.Rows[0]["Name"] + "/";
            }

            if (dtGroup.Rows.Count > 0 && dtGroup.Rows[0]["ParentID"] + "" != "")
            {
                result = getCzlxDG(dtGroup.Rows[0]["ParentId"] + "", ref result);
            }

            //公司名称
            string CropName = string.Empty;
            sql = @"select A.* from FL_PortalHR..SysGroup  As A
                            left join FL_PortalHR..SysUser As B 
                            On A.GroupID=B.Pk_corp  
                            where B.UserID='{0}'";

            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
            sql = string.Format(sql, UserId);


            DataTable DtCrop = DataHelper.QueryDataTable(sql);

            if (DtCrop.Rows.Count > 0)
            {
                CropName = DtCrop.Rows[0]["Name"] + "/";
            }
            return CropName + result;

            //if (flag && dtGroup.Rows.Count > 0)
            //{
            //    result += dtGroup.Rows[0]["Name"] + "/";
            //}
        }

        /// <summary>
        /// 获取岗位
        /// </summary>
        /// <param name="UserId">人员Id</param>
        /// <returns>岗位</returns>
        public static string getPost(string UserId, string DeptId, string type)
        {
            string result = "";
            string pk_gw = "";
            if (string.IsNullOrEmpty(UserId))
                return "";

            string MiddleDBName = ConfigurationManager.AppSettings["MiddleDBName"];
            string workNo = SysUser.Find(UserId).WorkNo;
            if (type == "CompanyId")
            {
                pk_gw = DataHelper.QueryValue("select top 1 PK_gw from " + MiddleDBName + "..fld_ryxx where psncode='" + workNo + "' and pk_corp='" + DeptId + "'") + "";
            }
            else
            {
                //有可能一个公司有多条，根据部门Path取
                int gws = DataHelper.QueryValue<int>("select count(1) from " + MiddleDBName + "..fld_ryxx where psncode='" + workNo + "' and pk_corp=(select top 1 pk_corp from " + MiddleDBName + "..fld_bmml where pk_deptdoc='" + DeptId + "')");
                if (gws > 1)
                {
                    string path = DataHelper.QueryValue("select [path]+GroupId from SysGroup where GroupId='" + DeptId + "'") + "";
                    pk_gw = DataHelper.QueryValue("select top 1 pk_gw from " + MiddleDBName + "..fld_ryxx where psncode='" + workNo + "' and '" + path + "' like '%'+ pk_deptdoc+'%'") + "";
                }
                else
                {
                    pk_gw = DataHelper.QueryValue("select top 1 PK_gw from " + MiddleDBName + "..fld_ryxx where psncode='" + workNo + "' and pk_corp=(select top 1 pk_corp from " + MiddleDBName + "..fld_bmml where pk_deptdoc='" + DeptId + "')") + "";
                }
            }

            if (string.IsNullOrEmpty(pk_gw))
            {
                pk_gw = DataHelper.QueryValue("select top 1 PK_gw from SysUser where UserId='" + UserId + "' and isnull(outdutydate,'')=''") + "";
            }
            SysRole role = SysRole.TryFind(pk_gw);
            if (role != null)
            {
                result = role.Name;
            }
            return result;
        }

        /// <summary>
        /// 获取岗位
        /// </summary>
        /// <param name="UserId">人员Id</param>
        /// <returns>岗位</returns>
        public static string getPost(string UserId, int type)
        {
            string result = "";
            if (string.IsNullOrEmpty(UserId))
                return "";

            string pk_gw = DataHelper.QueryValue("select top 1 PK_gw from SysUser where UserId='" + UserId + "' and isnull(outdutydate,'')=''") + "";

            if (type == 1)
                return pk_gw;

            SysRole role = SysRole.TryFind(pk_gw);
            if (role != null)
            {
                result = role.Name;
            }
            return result;
        }

        /// <summary>
        /// 获取岗位
        /// </summary>
        /// <param name="UserId">人员Id</param>
        /// <returns>岗位</returns>
        public static string[] getPost(string UserId)
        {
            string[] result = new string[] { "", "" };
            if (string.IsNullOrEmpty(UserId))
                return result;

            string pk_gw = DataHelper.QueryValue("select top 1 PK_gw from SysUser where UserId='" + UserId + "' and isnull(outdutydate,'')=''") + "";
            SysRole role = SysRole.TryFind(pk_gw);
            if (role != null)
            {
                result = new string[] { role.RoleID, role.Name };
            }
            return result;
        }

        /// <summary>
        /// 递归获取第二层组织结构
        /// </summary>
        /// <param name="ParentId"></param>
        /// <returns></returns>
        public static string getCzlxDG(string ParentId, ref string result)
        {
            //SysGroup group = SysGroup.TryFind(ParentId);

            //Modify By WGM 8/9
            string SQL = "select * from  FL_PortalHR..SysGroup where GroupID='" + ParentId + "'";
            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
            //SysGroup group = JsonHelper.GetObject<SysGroup>(JsonHelper.GetJsonString(DataHelper.QueryDictList(SQL).FirstOrDefault()));
            EasyDictionary group = DataHelper.QueryDictList(SQL).FirstOrDefault();

            if (group == null)
            {
                return "";
            }
            else if (group["ParentID"] + "" != "" && !(group["Name"] + "").Contains("公司"))
            {
                result = (group["Name"] + "") + '/' + result;
                return getCzlxDG(group["ParentID"] + "", ref result);
            }
            else
            {
                return result.TrimEnd('/');
            }
        }

        /// <summary>
        /// 递归获取到公司级全路径
        /// </summary>
        /// <param name="ParentId"></param>
        /// <returns></returns>
        public static string getCzlxDG1(string ParentId, ref string result)
        {
            //SysGroup group = SysGroup.TryFind(ParentId);

            //Modify By WGM 8/9
            string SQL = "select * from  FL_PortalHR..SysGroup where GroupID='" + ParentId + "'";
            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
            //SysGroup group = JsonHelper.GetObject<SysGroup>(JsonHelper.GetJsonString(DataHelper.QueryDictList(SQL).FirstOrDefault()));
            EasyDictionary group = DataHelper.QueryDictList(SQL).FirstOrDefault();

            if (group == null)
            {
                return "";
            }
            else if (group["ParentID"] + "" != "" && !(group["Name"] + "").Contains("公司"))
            {
                result = (group["Name"] + "") + '/' + result;
                return getCzlxDG1(group["ParentID"] + "", ref result);
            }
            else
            {
                result = (group["Name"] + "") + "/" + result;
                return result.TrimEnd('/');
            }
        }

        #endregion

        #region DataHelper操作方法
        public static DataTable GetData(string sql, string constr)
        {
            DataTable dt = new DataTable();
            SqlDataAdapter dap = new SqlDataAdapter(sql, constr);
            dap.Fill(dt);
            dap.Dispose();
            return dt;
        }

        /// <summary>
        /// 执行sql
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="constr"></param>
        /// <returns></returns>
        public static int ExecuteSql(string sql, string constr)
        {
            if (sql == "")
            {
                return 0;
            }
            int i = 0;
            SqlConnection con = new SqlConnection(constr);
            SqlCommand cmd = new SqlCommand(sql, con);

            con.Open();
            i = cmd.ExecuteNonQuery();
            cmd.Dispose();
            con.Close();

            return i;
        }

        /// <summary>
        /// 执行sql
        /// </summary>
        /// <param name="sql">sql语句</param>
        /// <param name="constr">连接字符串</param>
        /// <returns>受影响行数</returns>
        public static int ExecuteSql2(string sql, string constr)
        {
            if (sql == "")
            {
                return 0;
            }

            int i = -1;
            SqlConnection con = new SqlConnection(constr);
            SqlCommand cmd = new SqlCommand(sql, con);

            con.Open();

            //启动事务
            SqlTransaction transaction = con.BeginTransaction();
            cmd.Transaction = transaction;
            try
            {
                i = cmd.ExecuteNonQuery();
                transaction.Commit();
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                i = -1;
            }
            finally
            {
                cmd.Dispose();
                con.Close();
                con.Dispose();
            }
            return i;
        }

        /// <summary>
        /// ExecuteScalar
        /// </summary>
        /// <param name="sql">查询语句</param>
        /// <param name="constr">连接字符串</param>
        /// <returns>查询结果</returns>
        public static string ExecuteScalar(string sql, string constr)
        {
            SqlConnection con = new SqlConnection(constr);
            SqlCommand cmd = new SqlCommand(sql, con);
            con.Open();
            string result = cmd.ExecuteScalar() + "";
            cmd.Dispose();
            con.Close();
            return result;
        }
        #endregion


    }
}

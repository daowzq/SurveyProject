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
    public class StatisticsUser
    {
        #region  查询SQL 初始化

        //Modify by WGM 8/9
        private string Prop_FilterSQL = @"With ParGroup As
                                            (
                                                select  F1 As GroupId from  
                                                  f_splitstr((select OrgIds from  FL_Culture..SurveyedObj where SurveyId='{0}'),',')
                                            ),SubOrGroup As
                                            (
                                                --子组织
                                                select A.* from FL_PortalHR..sysgroup As A 
                                                 join ParGroup  As B 
                                                        on A.type=2 and A.Status=1 and ( A.Path like '%'+ B.GroupId+'%' or A.GroupID =B.GroupId )  
                                                     and ( A.Hrcanceled<>'Y' or  A.Hrcanceled is null)
                                            ),GroupAndUser As 
                                            (
                                              --组织下的人员
                                             select A.*,G.GroupID,G.Name As GroupName from FL_PortalHR..sysuser As A 
                                                    left join FL_PortalHR..SysUserGroup As B 
                                                on A.UserID=B.UserID
                                                    left join FL_PortalHR..Sysgroup As G
                                                on G.GroupID=B.GroupID
                                              where B.GroupId in ( select GroupID from SubOrGroup ) and A.Status=1 
                                            ),FilterUser As 
                                            (
                                               --  获取人员详细信息
                                               select T.UserID,T.Name As UserName,T.WorkNo,A.jobname As JobName
	                                            --,CA.GroupName,CA1.GroupID
                                               from  GroupAndUser as T  
													 left join HR_OA_MiddleDB..fld_gw AS A
												on T.Pk_gw=A.pk_jobcode

                                               where ( OutdutyDate is null or OutdutyDate='' ) ##Query##
                                            )
                                            select distinct * from FilterUser";

        /*  private string Prop_ReadSQL = @"With ParGroup As
                                          (
                                              select  F1 As GroupId from  
                                                f_splitstr((select OrgIds from  FL_Culture..SurveyReaderObj where SurveyId='{0}'),',')
                                          ),SubOrGroup As
                                          (
                                              --子组织
                                              select A.* from FL_PortalHR..sysgroup As A 
                                               join ParGroup  As B 
                                              on A.Path like  '%'+ B.GroupId+'%' or A.GroupID =B.GroupId
                                          ),GroupAndUser As 
                                          (
                                            --组织下的人员
                                           select A.*,G.GroupID,G.Name As GroupName from FL_PortalHR..sysuser As A 
                                                  left join FL_PortalHR..SysUserGroup As B 
                                              on A.UserID=B.UserID
                                                  left join FL_PortalHR..Sysgroup As G
                                              on G.GroupID=B.GroupID
                                            where B.GroupId in ( select GroupID from SubOrGroup ) and A.Status=1 
                                          ),FilterUser As 
                                          (
                                             --  获取人员详细信息
                                             select T.UserID,T.Name As UserName,CA.GroupName,CA1.GroupID
                                             from  GroupAndUser as T 
                                             cross Apply (             
                                                select  STUFF((
                                                  select  ',' +G.Name  As [text()] from FL_PortalHR..sysuser As A 
                                                  left join FL_PortalHR..SysUserGroup As B 
                                                      on A.UserID=B.UserID
                                                  left join FL_PortalHR..sysgroup As G
                                                      on G.GroupID=B.GroupID
                                                  where A.UserID=T.UserID
                                                  for xml path('')),1,1,'')  As GroupName
                                               ) As CA  
                                               cross apply(             
                                                   select  STUFF((
                                                  select  ',' +G.GroupID  As [text()] from FL_PortalHR..sysuser As A 
                                                  left join FL_PortalHR..SysUserGroup As B 
                                                      on A.UserID=B.UserID
                                                  left join FL_Culture_AimPortal..sysgroup As G
                                                      on G.GroupID=B.GroupID
                                                  where A.UserID=T.UserID   ##Query##
                                                  for xml path('')),1,1,'')  As GroupID
                                              ) As  CA1
                                          )
                                          select * from FilterUser";  */
        private string Prop_ReadSQL = @"With ParGroup As
                                          (
                                              select  F1 As GroupId from  
                                                f_splitstr((select OrgIds from  FL_Culture..SurveyReaderObj where SurveyId='{0}'),',')
                                          ),SubOrGroup As
                                          (
                                              --子组织
                                              select A.* from FL_PortalHR..sysgroup As A 
                                               join ParGroup  As B 
                                               on A.type=2 and ( A.Path like  '%'+ B.GroupId+'%' or A.GroupID =B.GroupId ) 
                                               and A.Status='1' and ( A.Hrcanceled<>'Y' or  A.Hrcanceled is null)
                                          ),GroupAndUser As 
                                          (
                                            --组织下的人员
                                           select A.*,G.GroupID,G.Name As GroupName from FL_PortalHR..sysuser As A 
                                                  left join FL_PortalHR..SysUserGroup As B 
                                              on A.UserID=B.UserID
                                                  left join FL_PortalHR..Sysgroup As G
                                              on G.GroupID=B.GroupID
                                            where B.GroupId in ( select GroupID from SubOrGroup ) and A.Status=1 
                                          ),FilterUser As 
                                          (
                                             --  获取人员详细信息
                                             select T.UserID,T.Name As UserName,T.WorkNo
                                             from  GroupAndUser as T 
                                             where ( OutdutyDate is null or OutdutyDate='' ) ##Query##
                                          )
                                          select distinct * from FilterUser";

        public string FilterSQL
        {
            get
            {
                return Prop_FilterSQL;
            }
        }

        public string ReadSQL
        {
            get
            {
                return Prop_ReadSQL;
            }
        }
        #endregion



        /// <summary>
        /// 解析SQL语句
        /// </summary>
        /// <param name="SQ"></param>
        /// <returns></returns>
        public string AnalyzeSQL(SurveyedObj SQ)
        {
            if (SQ == null) return "";

            string Sex = SQ.Sex;
            string ManagerNames = SQ.ManagerNames;
            string AgeRang = SQ.AgeRange;
            string WorkAge = SQ.WorkAge;
            string StartWorkTime = SQ.StartWorkTime.ToString();
            string UntileWorkTime = SQ.UntileWorkTime.ToString();
            string PostionNames = SQ.PostionNames;

            StringBuilder strb = new StringBuilder();
            strb.Append(" and 1=1 ");
            if (!string.IsNullOrEmpty(Sex))                    //性别 
            {
                if (Sex == "man")
                    strb.Append(" and Sex ='男' ");
                else if (Sex == "woman")
                    strb.Append(" and Sex ='女' ");
            }
            if (!string.IsNullOrEmpty(AgeRang) && AgeRang != "0") //年龄
            {
                string[] temp = AgeRang.Split(',');
                strb.Append(" and  ( ");
                for (var v = 0; v < temp.Length; v++)
                {
                    if (v > 0) strb.Append("  or ");
                    if (temp[v].ToString().Contains("-"))
                    {
                        // strb.Append(" ( AgeRang between " + temp[v].Split('-')[0] + " and " + temp[v].Split('-')[1] + " ) ");
                        strb.Append(" ( age between " + temp[v].Split('-')[0] + " and " + temp[v].Split('-')[1] + " ) ");
                    }
                    else if (temp[v].ToString().Contains(">"))
                    {
                        //strb.Append(" ( AgeRang  " + temp[v] + " ) ");
                        strb.Append(" ( age  " + temp[v] + " ) ");
                    }
                }
                strb.Append(" ) ");
            }

            if (!string.IsNullOrEmpty(WorkAge) && WorkAge != "0") //工作年限
            {
                // datediff(year,' 2010/7/12 0:00:00',getdate())
                strb.Append(" and datediff(year,IndutyDate,getdate()) " + WorkAge + " ");
            }

            // 入职日期判断
            if (!string.IsNullOrEmpty(StartWorkTime) && !string.IsNullOrEmpty(UntileWorkTime))
            {
                strb.Append(" and ( IndutyDate >=cast('" + StartWorkTime + "' as datetime) and IndutyDate <= cast('" + UntileWorkTime + "' as datetime  ) )");
            }
            else if (!string.IsNullOrEmpty(StartWorkTime) && string.IsNullOrEmpty(UntileWorkTime))
            {
                strb.Append(" and ( IndutyDate >=cast('" + StartWorkTime + "' as datetime) )");
            }
            else if (string.IsNullOrEmpty(StartWorkTime) && !string.IsNullOrEmpty(UntileWorkTime))
            {
                strb.Append(" and ( IndutyDate <=cast('" + UntileWorkTime + "' as datetime) )");
            }
            //职位
            if (!string.IsNullOrEmpty(PostionNames)) // 职位
            {
                //strb.Append(" and FL_Culture.dbo.PostionCk('" + PostionNames + "',UserID)=1 "); //old 
                // strb.Append(" and FL_Culture.dbo.PostionCk1('" + PostionNames + "',GroupName)=1 ");
            }

            string where = strb.ToString();
            return where;


        }

        /// <summary>
        /// 根据条件筛选人员
        /// </summary>
        /// <param name="SurveyId">SurveyId</param>
        /// <param name="Query"> 查询条件(where后语句)</param>
        /// <returns>人员DataTable</returns>
        public DataTable FilterUser(string SurveyId, string Query)
        {
            string SQL = this.FilterSQL;
            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
            SQL = SQL.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);

            SQL = string.Format(SQL, SurveyId);
            SQL = SQL.Replace("##Query##", Query);
            DataTable dt = DataHelper.QueryDataTable(SQL);
            return dt;
        }

        /// <summary>
        /// 生成被调查人员
        /// </summary>
        /// <param name="SurveyId"></param>
        /// <returns></returns>
        public bool CreateSurveyedUser(string SurveyId)
        {
            SurveyedObj Ent = SurveyedObj.FindFirstByProperties(SurveyedObj.Prop_SurveyId, SurveyId);

            // 根据条件筛选的人员
            string where = string.Empty;
            if (string.IsNullOrEmpty(Ent.OrgIds) || string.IsNullOrEmpty(Ent.OrgNames))
            {
                where = " and 1<>1 ";  //组织结构为空情况
            }
            else
            {
                where = AnalyzeSQL(Ent);
            }

            var FilterUsrDt = FilterUser(SurveyId, where);

            //筛选职位
            if (!string.IsNullOrEmpty(Ent.PostionNames))
            {
                string split = string.Empty;
                string[] tempArr = Ent.PostionNames.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                for (int j = 0; j < tempArr.Length; j++)
                {
                    if (j > 0) split += " or ";
                    split += " JobName like  '%" + tempArr[j] + "%' ";
                }

                DataRow[] rows = FilterUsrDt.Select(split);  //查询gw
                DataTable tempDt = new DataTable();
                DataColumn D_UserId = new DataColumn("UserId"); tempDt.Columns.Add(D_UserId);
                DataColumn D_UserName = new DataColumn("UserName"); tempDt.Columns.Add(D_UserName);
                DataColumn D_WorkNo = new DataColumn("WorkNo"); tempDt.Columns.Add(D_WorkNo);
                DataColumn D_JobName = new DataColumn("JobName"); tempDt.Columns.Add(D_JobName);
                for (int i = 0; i < rows.Length; i++)
                {
                    DataRow dr = tempDt.NewRow();
                    dr["UserId"] = rows[i]["UserId"];
                    dr["UserName"] = rows[i]["UserName"];
                    dr["WorkNo"] = rows[i]["WorkNo"];
                    dr["JobName"] = rows[i]["JobName"];
                    tempDt.Rows.Add(dr);
                }
                if (tempDt.Rows.Count > 0)
                {
                    FilterUsrDt = tempDt;
                }

            }


            //Modify By WGM 8/9
            string SQL = @"with SurObjUsr As 
                            (
                                select CA.* from
                                FL_Culture..SurveyedObj As A 
                                cross apply(
                                     select Filed As UsrID from FL_Culture..GetTblByJson(A.AddUserNames,'Id')
                                ) As CA
                                where SurveyId='{0}'
                            ),
                            UserInfo As (
                              select T.UserID,T.Name,T.WorkNo from SurObjUsr As A 
                                left join FL_PortalHR..Sysuser As T 
                                on A.UsrID=T.UserID 
                            )
                            select distinct * from UserInfo";

            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
            SQL = string.Format(SQL, SurveyId);

            SQL = "select '' where  1<>1  ";  //Change BY WGM 9-30
            DataTable AddUsrDt = DataHelper.QueryDataTable(SQL);

            //排除的人员 
            string ReMoveSQL = @" select CA.* from
                        FL_Culture..SurveyedObj As A 
                        cross apply(
                             select Filed As UserID from FL_Culture..GetTblByJson(A.AddUserNames,'Id')
                        ) As CA
                        where SurveyId='{0}'";

            ReMoveSQL = string.Format(ReMoveSQL, SurveyId);
            ReMoveSQL = "select '' where  1<>1  ";  //Change BY WGM 9-30

            DataTable RemoveDt = DataHelper.QueryDataTable(ReMoveSQL);

            if (RemoveDt.Rows.Count > 0)
            {
                for (int i = 0; i < FilterUsrDt.Rows.Count; i++)
                {
                    for (int j = 0; j < RemoveDt.Rows.Count; j++)
                    {
                        if (FilterUsrDt.Rows[i]["UserID"].ToString() == RemoveDt.Rows[j]["UserID"].ToString())
                        {
                            FilterUsrDt.Rows.Remove(FilterUsrDt.Rows[i]);
                        }
                    }
                }
            }

            //---------------------------生成DataTable-----------------------------

            DataTable FinalDt = new DataTable();
            DataColumn Dc_UserId = new DataColumn("UserId"); FinalDt.Columns.Add(Dc_UserId);
            DataColumn Dc_UserName = new DataColumn("UserName"); FinalDt.Columns.Add(Dc_UserName);
            DataColumn Dc_DeptId = new DataColumn("DeptId"); FinalDt.Columns.Add(Dc_DeptId);
            DataColumn Dc_DeptName = new DataColumn("DeptName"); FinalDt.Columns.Add(Dc_DeptName);
            DataColumn Dc_WorkNo = new DataColumn("WorkNo"); FinalDt.Columns.Add(Dc_WorkNo);

            // string FindSQL = @"select FL_Culture.dbo.GetGroupIds('{0}') As DeptId,FL_Culture.dbo.GetGroupNames('{0}') As DeptName";
            for (int i = 0; i < FilterUsrDt.Rows.Count; i++)
            {
                //string tempSQL = string.Format(FindSQL, FilterUsrDt.Rows[i]["UserID"].ToString());
                //DataTable tempDt = DataHelper.QueryDataTable(tempSQL);
                DataRow dr = FinalDt.NewRow();
                //dr["DeptId"] = FilterUsrDt.Rows[i]["GroupIds"];
                //dr["DeptName"] = FilterUsrDt.Rows[i]["GroupNames"];

                string FullDept = WFHelper.getZzjg(FilterUsrDt.Rows[i]["UserID"].ToString(), true);
                dr["DeptName"] = FullDept;
                dr["UserId"] = FilterUsrDt.Rows[i]["UserID"];  //*
                dr["UserName"] = FilterUsrDt.Rows[i]["UserName"];  //*
                dr["WorkNo"] = FilterUsrDt.Rows[i]["WorkNo"];

                FinalDt.Rows.Add(dr);
            }

            for (int i = 0; i < AddUsrDt.Rows.Count; i++)
            {
                DataRow dr = FinalDt.NewRow();
                //dr["DeptId"] = AddUsrDt.Rows[i]["GroupID"];
                //dr["DeptName"] = AddUsrDt.Rows[i]["GroupName"];

                string FullDept = WFHelper.getZzjg(AddUsrDt.Rows[i]["UserID"].ToString(), true);
                dr["DeptName"] = FullDept;
                dr["UserId"] = AddUsrDt.Rows[i]["UserID"];  //*
                dr["UserName"] = AddUsrDt.Rows[i]["Name"];  //*
                dr["WorkNo"] = AddUsrDt.Rows[i]["WorkNo"];
                FinalDt.Rows.Add(dr);
            }
            //添加问卷发起者
            DataRow CreateRow = FinalDt.NewRow();
            CreateRow["UserId"] = Ent.CreateId;
            CreateRow["UserName"] = Ent.CreateName;
            FinalDt.Rows.Add(CreateRow);

            //----------------------------------------------------------------------------

            //生成调查用户
            for (int i = 0; i < FinalDt.Rows.Count; i++)
            {
                SurveyFinallyUsr UserEnt = new SurveyFinallyUsr();
                UserEnt.CreateWay = "1";      //1 表示生成的用户而非创建
                UserEnt.SurveyId = SurveyId;
                UserEnt.DeptName = FinalDt.Rows[i]["DeptName"].ToString();
                //UserEnt.DeptId = FinalDt.Rows[i]["DeptId"].ToString();
                UserEnt.WorkNo = FinalDt.Rows[i]["WorkNo"].ToString();
                UserEnt.UserId = FinalDt.Rows[i]["UserId"].ToString();
                UserEnt.UserName = FinalDt.Rows[i]["UserName"].ToString();
                UserEnt.DoCreate();
            }

            return true;

        }

        /// <summary>
        /// 生成查看人员
        /// </summary>
        /// <param name="SurveyId"></param>
        /// <returns></returns>
        public bool CreateReadUser(string SurveyId)
        {
            SurveyReaderObj SrEnt = SurveyReaderObj.FindFirstByProperties(SurveyReaderObj.Prop_SurveyId, SurveyId);
            //组织下的人员
            string RdSQL = this.ReadSQL;
            if (string.IsNullOrEmpty(SrEnt.OrgIds) || string.IsNullOrEmpty(SrEnt.OrgNames))
            {
                RdSQL = RdSQL.Replace("##Query##", " and 1<>1 ");   //组织为空情况
                RdSQL = string.Format(RdSQL, SurveyId);
            }
            else
            {
                RdSQL = RdSQL.Replace("##Query##", " ");
                RdSQL = string.Format(RdSQL, SurveyId);
            }

            DataTable FilterUsrDt = DataHelper.QueryDataTable(RdSQL);

            // 添加的人员
            string SQL = @"with SurObjUsr As 
                             (
                                 select CA.* from
                                 FL_Culture..SurveyReaderObj As A 
                                 cross apply(
                                      select Filed As UsrID from FL_Culture..GetTblByJson(A.AllowUser,'Id')
                                 ) As CA
                                 where SurveyId='{0}'
                             ),
                             UserInfo As (
                               select T.UserID,T.Name, T.WorkNo from SurObjUsr As A 
                                 left join FL_PortalHR..Sysuser As T 
                                 on A.UsrID=T.UserID 

                            )
                          select distinct * from UserInfo ";

            SQL = "select '' where  1<>1  ";  //Change BY WGM 9-30

            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
            SQL = string.Format(SQL, SurveyId);
            DataTable AddUsrDt = DataHelper.QueryDataTable(SQL);

            //排除的人员
            string ReMoveSQL = @" select CA.* from
                        FL_Culture..SurveyReaderObj As A 
                        cross apply(
                             select Filed As UserID from FL_Culture..GetTblByJson(A.NoAllowUser,'Id')
                        ) As CA
                        where SurveyId='{0}'";

            ReMoveSQL = string.Format(ReMoveSQL, SurveyId);

            ReMoveSQL = "select '' where  1<>1  ";  //Change BY WGM 9-30
            DataTable RemoveDt = DataHelper.QueryDataTable(ReMoveSQL);

            //排除人员
            if (RemoveDt.Rows.Count > 0)
            {
                for (int i = 0; i < FilterUsrDt.Rows.Count; i++)
                {
                    for (int j = 0; j < RemoveDt.Rows.Count; j++)
                    {
                        if (FilterUsrDt.Rows[i]["UserID"].ToString() == RemoveDt.Rows[j]["UserID"].ToString())
                        {
                            FilterUsrDt.Rows.Remove(FilterUsrDt.Rows[i]);
                        }
                    }
                }
            }

            // 合并

            DataTable FinalDt = new DataTable();
            DataColumn Dc_UserId = new DataColumn("UserId"); FinalDt.Columns.Add(Dc_UserId);
            DataColumn Dc_UserName = new DataColumn("UserName"); FinalDt.Columns.Add(Dc_UserName);
            DataColumn Dc_DeptId = new DataColumn("DeptId"); FinalDt.Columns.Add(Dc_DeptId);
            DataColumn Dc_DeptName = new DataColumn("DeptName"); FinalDt.Columns.Add(Dc_DeptName);
            DataColumn Dc_WorkNo = new DataColumn("WorkNo"); FinalDt.Columns.Add(Dc_WorkNo);

            for (int i = 0; i < FilterUsrDt.Rows.Count; i++)
            {
                DataRow dr = FinalDt.NewRow();
                //dr["DeptId"] = FilterUsrDt.Rows[i]["GroupId"];
                //dr["DeptName"] = FilterUsrDt.Rows[i]["GroupName"];
                string FullDept = WFHelper.getZzjg(FilterUsrDt.Rows[i]["UserID"].ToString(), true);
                dr["DeptName"] = FullDept;
                dr["WorkNo"] = FilterUsrDt.Rows[i]["WorkNo"];
                dr["UserId"] = FilterUsrDt.Rows[i]["UserID"];  //*
                dr["UserName"] = FilterUsrDt.Rows[i]["UserName"];  //*

                FinalDt.Rows.Add(dr);
            }
            //Add
            for (int i = 0; i < AddUsrDt.Rows.Count; i++)
            {
                DataRow dr = FinalDt.NewRow();
                //dr["DeptId"] = AddUsrDt.Rows[i]["GroupID"];
                //dr["DeptName"] = AddUsrDt.Rows[i]["GroupName"];
                string FullDept = WFHelper.getZzjg(AddUsrDt.Rows[i]["UserID"].ToString(), true);
                dr["DeptName"] = FullDept;
                dr["WorkNo"] = AddUsrDt.Rows[i]["WorkNo"];
                dr["UserId"] = AddUsrDt.Rows[i]["UserID"];  //*
                dr["UserName"] = AddUsrDt.Rows[i]["Name"];  //*

                FinalDt.Rows.Add(dr);
            }

            SurveyQuestion Ent = SurveyQuestion.Find(SurveyId);
            if (Ent != null)
            {
                //添加问卷创建者
                DataRow CreateRow = FinalDt.NewRow();
                CreateRow["UserId"] = Ent.CreateId;
                CreateRow["UserName"] = Ent.CreateName;
                FinalDt.Rows.Add(CreateRow);
            }
            //---------------------------------------------------------------
            //生成调查用户
            for (int i = 0; i < FinalDt.Rows.Count; i++)
            {
                SurveyCanReaderUsr UserEnt = new SurveyCanReaderUsr();
                UserEnt.CreateWay = "1";      //1 表示生成的用户而非创建
                UserEnt.SurveyId = SurveyId;
                UserEnt.DeptName = FinalDt.Rows[i]["DeptName"].ToString();
                //UserEnt.DeptId = FinalDt.Rows[i]["DeptId"].ToString();
                UserEnt.UserId = FinalDt.Rows[i]["UserId"].ToString();
                UserEnt.UserName = FinalDt.Rows[i]["UserName"].ToString();
                UserEnt.WorkNo = FinalDt.Rows[i]["WorkNo"].ToString();
                UserEnt.DoCreate();
            }

            return true;

        }

    }
}

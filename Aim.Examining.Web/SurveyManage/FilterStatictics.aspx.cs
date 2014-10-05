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
using System.Net;
using System.IO;
using Aim.Examining.Web.Common;
namespace Aim.Examining.Web.SurveyManage
{
    public partial class FilterStatictics : ExamListPage
    {
        string surveyId = string.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            surveyId = this.RequestData.Get("SurveyId") + "";
            switch (RequestActionString)
            {
                case "QueryData":
                    QueryData();
                    break;
                case "GetDept":
                    GetDept();
                    break;
                case "OutputExcel":
                    ExportExcel();
                    break;
                default:
                    DoDefaultSelect();
                    break;
            }
            if (!string.IsNullOrEmpty(Request["content"] + ""))
            {
                ExportExcel();
            }
        }

        /// <summary>
        ///获取部门 
        /// </summary>
        public void GetDept()
        {
            string CropId = RequestData.Get("CropId") + "";
            if (!string.IsNullOrEmpty(CropId))
            {
                string sql = @"select GroupID, Name from  FL_PortalHR..SysGroup 
                               where type=2 and status=1 and  
                                     ((GroupID='{0}' and Name not like '%公司%' ) or Path like '%{0}%' )
                                   and  GroupID in (
	                                select distinct C.groupId from FL_Culture..SurveyCommitHistory As A
		                                left join  FL_PortalHR..sysuser  As B
			                                on A.SurveyedUserId=B.UserId
		                                left join FL_PortalHR..SysUserGroup As C
			                                on B.UserID=C.UserID
	                                where A.SurveyId='{1}'
                                )";

                sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
                sql = string.Format(sql, CropId, surveyId);

                var deptEnt = DataHelper.QueryDictList(sql);
                this.PageState.Add("detpDic", deptEnt);
            }
        }


        //
        private void ExportExcel()
        {

            //Response.Redirect("WebForm1.aspx");
            string content = RequestData.Get("content") + "";
            string FileName = MapPath("temp") + "/t_" + DateTime.Now.ToString("yyyyMMdd-hhmmss") + ".xls";
            StreamWriter sw = new StreamWriter(FileName);
            sw.Write(content);
            sw.Close();

            //string url = HttpContext.Current.Request.Url.AbsoluteUri;
            //HttpWebRequest myReq = HttpWebRequest.Create(url) as HttpWebRequest;

            //string strFileName = DateTime.Now.ToString("yyyyMMdd-hhmmss");
            //System.Web.HttpContext HC = System.Web.HttpContext.Current;
            //HC.Response.Clear();
            //HC.Response.Buffer = true;
            //HC.Response.ContentEncoding = System.Text.Encoding.UTF8;//设置输出流为简体中文

            ////---导出为Excel文件
            //HC.Response.AddHeader("Content-Disposition", "attachment;filename=" + HttpUtility.UrlEncode(FileName, System.Text.Encoding.UTF8));
            //HC.Response.ContentType = "application/ms-excel";//设置输出文件类型为excel文件。

            ////System.IO.StringWriter sw = new System.IO.StringWriter();
            ////System.Web.UI.HtmlTextWriter htw = new System.Web.UI.HtmlTextWriter(sw);
            Response.WriteFile(FileName);
            Response.End();


        }

        /// <summary>
        /// 根据条件筛选数据
        /// </summary>
        private void QueryData()
        {
            //查询条件
            string SurveyId = this.RequestData.Get("SurveyId") + "";
            string CropId = this.RequestData.Get("cropId") + "";
            string DeptId = this.RequestData.Get("deptId") + "";
            string Year = this.RequestData.Get("year") + "";
            string Sex = this.RequestData.Get("sex") + "";
            string AgeSegment = RequestData.Get("age") + "";
            string ationType = this.RequestData.Get("ationType") + "";

            string where = string.Empty;
            //sex
            where += !string.IsNullOrEmpty(Sex) ? " and sex='" + Sex + "'" : "";
            //OrgId
            string OrgId = string.IsNullOrEmpty(DeptId) ? CropId : DeptId;

            //year
            if (!string.IsNullOrEmpty(Year) && Year.Split('-').Length > 1)
            {
                string[] tmpArr = Year.Split('-');
                // where += " and  datepart(year,getdate())- datepart(year,Indutydate) between " + tmpArr[0] + " and " + tmpArr[1] + " ";
                where += " and datepart(year,getdate())- datepart(year,Indutydate) >= " + tmpArr[0] + " and datepart(year,getdate())- datepart(year,Indutydate) < " + tmpArr[1] + " ";
            }
            else if (!string.IsNullOrEmpty(Year))
            {
                if (!string.IsNullOrEmpty(OrgId))
                {
                    where += " and datepart(year,getdate())- datepart(year,Indutydate) " + Year + " ";
                }
                else
                {
                    where += " and datepart(year,getdate())- datepart(year,Indutydate) " + Year + " ";
                }
            }
            //Age segment  ryxl D.def4 年龄段
            if (!string.IsNullOrEmpty(AgeSegment) && AgeSegment.Split('-').Length > 1)
            {
                string[] tmpArr = AgeSegment.Split('-');
                where += " and datediff(year,D.def4,getdate()) >= " + tmpArr[0] + " and datediff(year,D.def4,getdate()) < " + tmpArr[1] + " ";
            }
            else if (!string.IsNullOrEmpty(AgeSegment))
            {
                where += " and datediff(year,D.def4,getdate()) " + AgeSegment + " ";
            }
            //-----------------condition end---------------------------------------------


            //空组织
            string IndutySql = string.Empty;
            if (string.IsNullOrEmpty(OrgId))
            {
                IndutySql = @" select UserID  from FL_PortalHR..Sysuser where Status=1 and (Outdutydate is null or Outdutydate='' ) ##Query##";
            }

            //有年龄段
            if (!string.IsNullOrEmpty(AgeSegment))
            {
                IndutySql = @"select UserID  
                               from FL_PortalHR..Sysuser As A
	                                left join HR_OA_MiddleDB..fld_ryxx As D
	                                 on A.WorkNo=D.psncode and A.Name=D.psnname
                              where Status=1 and (A.Outdutydate is null or A.Outdutydate='' ) ##Query## ";
                where = where.Replace("Indutydate", "A.Indutydate");
                // IndutySql = @" select UserID  from FL_PortalHR..Sysuser where Status=1 and (Outdutydate is null or Outdutydate='' ) ##Query##";
            }
            //组织部门
            if (!string.IsNullOrEmpty(OrgId))
            {
                IndutySql = @"select distinct  C.UserID from  (
                               select GroupID,Name from FL_PortalHR..SysGroup where  
                                    GroupID='{0}' or Path like '%{0}%' and Status='1'
                            ) As A
                            left join  FL_PortalHR..SysUserGroup As B
                                 on A.GroupID=B.GroupID  
                            left  join FL_PortalHR..SysUser As C
                                 on C.UserID=B.UserID
                            left  join HR_OA_MiddleDB..fld_ryxx As D
								  on D.psncode=C.WorkNo and D.pk_gw is not null and D.def3 is null 
                            where C.UserID is not null and C.Status=1 and 
                            ( C.Outdutydate is null or C.Outdutydate='') ##Query## ";

                IndutySql = string.Format(IndutySql, OrgId);

                where = where.Replace("A.Indutydate", "Indutydate");  //上面关联 A.Indutydate 年龄段
                where = where.Replace("Indutydate", "C.Indutydate");
            }

            IndutySql = IndutySql.Replace("FL_PortalHR", Global.AimPortalDB);
            IndutySql = IndutySql.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);


            //权限过滤
            string CorpId = string.Empty;
            var SEnt = SurveyQuestion.TryFind(SurveyId);
            if (SEnt != null && SEnt.IsFixed == "2")
            {
                CommPowerSplit PS = new CommPowerSplit();
                if (PS.IsHR(UserInfo.UserID, UserInfo.LoginName) || PS.IsAdmin(UserInfo.LoginName) || PS.IsInAdminsRole(UserInfo.UserID))
                {

                }
                else
                {
                    UserContextInfo UC = new UserContextInfo();
                    where += " and  pk_corp='" + UC.GetUserCurrentCorpId(UserInfo.UserID) + "' ";
                    CorpId = UC.GetUserCurrentCorpId(UserInfo.UserID);
                }
            }
            IndutySql = IndutySql.Replace("##Query##", where);

            //------------------------end-------------------------------------------

            if (ationType == "GetCount")  //获取人数
            {
                string total = @"select count(1) As Qt from 
                                 (
	                                select UserID from  FL_Culture..SurveyedResult
	                                where SurveyId='{0}' and 
	                                UserId IN ({1}) group by UserID
                                ) As A";
                total = string.Format(total, surveyId, IndutySql);
                this.PageState.Add("Total", DataHelper.QueryValue(total));
            }
            else
            {
                string sql = @"-----删除临时表
                            IF (OBJECT_ID('tempdb..#T1') IS NOT NULL)
                              DROP TABLE tempdb..#T1;
                            IF (OBJECT_ID('tempdb..#PerTbl') IS NOT NULL)
                              DROP TABLE tempdb..#PerTbl;
                            IF (OBJECT_ID('tempdb..#SurveyedResult') IS NOT NULL)
                              DROP TABLE tempdb..#SurveyedResult;

                            ---所有问题项
                            select A.*, B.Id As ItemId ,B.Answer,B.IsExplanation,B.SortIndex  As SubIndex 
	                            into #T1
                            from FL_Culture..QuestionItem  As A
                            left join  FL_Culture..QuestionAnswerItem 	As B
	                            on A.SubItemId=B.QuestionItemId  and A.SurveyId=B.SurveyId
                            where A.SurveyId='{0}' ;
                            ----筛选人数----
                            select * into  #SurveyedResult from  FL_Culture..SurveyedResult
                            where SurveyId='{0}' and 
                            UserId IN ({1});

                            --计算百分比
                            With PerTbl As
                            (
                                select  distinct
		                             A.QuestionId,Items,T.Tol As total,
		                            cast ((100.* CA.total/T.Tol) as Decimal(8,2)) as Per
                                from 
	                             FL_Culture..SurveyedResult  As A
	                             inner join (
			                            ---每一题选择总次数
			                            select QuestionId, sum(Tol) As Tol
			                            from #SurveyedResult As A
				                            Cross Apply(
					                             select Count(*) As Tol from 
						                             FL_Culture..f_splitstr(A.QuestionItemId,',')
				                            ) As CA
			                            left join FL_PortalHR..SysUser As B
				                            on A.UserId=B.UserID
			                            where SurveyId='{0}' ##FIX##
			                            group  by QuestionId 
	                            )As T 
		                            on A.QuestionId=T.QuestionId
	                            cross Apply(
		                                --选项的次数
			                            select distinct QuestionId,Items,  
			                               count(*) over (partition by Items)  As total 
			                            from #SurveyedResult  As Tt
			                            cross apply
			                            (
				                            select F1 AS Items from  FL_Culture.dbo.f_splitstr( Tt.QuestionItemId,',')
			                            ) As CA
			                            left join FL_PortalHR..SysUser As B
				                            on Tt.UserId=B.UserID
			                            where SurveyId='{0}' and Tt.QuestionId= A.QuestionId ##FIX##
	                            ) AS CA 
                            )
                            select * into #PerTbl from   PerTbl;

                            ---组合结果
                            With Final As
                            (
		                            select distinct T1.*, isnull(T2.total,0) As  Total ,isnull(T2.Per,0.00) As Per 
			                            from #T1 AS T1
		                            left join #PerTbl As T2
			                            on T1.itemId=T2.Items 
                            ),
                            Final1 As
                            (
	                            select Id As QuestionId ,Content, QuestionType,IsMustAnswer,IsComment,
	                             Case when ImgIds is not null and ImgIds<>'' then 'Y' else 'N' end As HasImg,
	                             Answer+'|'+cast(Per as varchar(10)) +'|'+IsExplanation+'|'+ItemId  As Integ,
	                             Total As Qty,SortIndex,SubIndex
	                            from  Final
                            ) 
                            ---合并item项
                            select distinct G1.QuestionId,Content,QuestionType,IsMustAnswer,IsComment,HasImg,SortIndex,Qty,
	                            STUFF((
		                            select '$'+ Integ As [text()] from  Final1 As G2
		                            where G2.QuestionId=G1.QuestionId
		                             order by SubIndex
		                            for xml path('')), 1, 1, '')
	                            AS ItemSet
                            from Final1 As G1 
	                            order by SortIndex";

                if (SEnt != null && SEnt.IsFixed == "2")
                {
                    sql = sql.Replace("##FIX##", " and B.pk_corp=" + CorpId + " ");
                }
                else
                {
                    sql = sql.Replace("##FIX##", "");
                }

                sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
                sql = string.Format(sql, SurveyId, IndutySql);

                DataTable Dt = DataHelper.QueryDataTable(sql);
                Dt = GetTreeData(Dt);
                this.PageState.Add("DataList", Dt);
            }

        }

        /// <summary>
        /// 默认查询
        /// </summary>
        private void DoDefaultSelect()
        {
            if (this.RequestData.Get("ation") + "" == "query")
            {
                QueryData();
                return;
            }

            //权限过滤
            var SEnt = SurveyQuestion.TryFind(surveyId);
            if (SEnt != null && SEnt.IsFixed == "2")
            {
                CommPowerSplit PS = new CommPowerSplit();
                if (PS.IsHR(UserInfo.UserID, UserInfo.LoginName) || PS.IsAdmin(UserInfo.LoginName) || PS.IsInAdminsRole(UserInfo.UserID))
                {
                }
                else
                {
                    UserContextInfo UC = new UserContextInfo();
                    string where = string.Empty, CorpId = string.Empty;
                    where += " and  C.GroupID='" + UC.GetUserCurrentCorpId(UserInfo.UserID) + "' ";
                    CorpId = UC.GetUserCurrentCorpId(UserInfo.UserID) + "";

                    //  获取公司枚举 
                    string SQL = @"select distinct C.GroupID, C.Name from  FL_Culture..SurveyCommitHistory As A
                        left join  FL_PortalHR..SysUser As B
                            on A.SurveyedUserId=B.UserId
                        left join  FL_PortalHR..SysGroup As C
                          on B.Pk_corp=C.GroupID
                        where C.type=2 and A.SurveyId='{0}' and C.Name like '%公司%' ";
                    SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
                    SQL = string.Format(SQL, surveyId);
                    SQL += where;
                    var CropEnt = DataHelper.QueryDict(SQL);
                    this.PageState.Add("CropEnum", CropEnt);

                    SQL = "exec FL_Culture..pro_SummarySurvey_Choices_Fix '{0}','{1}' ";
                    SQL = string.Format(SQL, surveyId, CorpId);

                    DataTable MtDt = DataHelper.QueryDataTable(SQL);
                    this.PageState.Add("DataList", GetTreeData(MtDt));
                    return;
                }
            }

            string sql = string.Empty;
            if (!string.IsNullOrEmpty(surveyId))
            {
                //  获取公司枚举 
                sql = @"select distinct C.GroupID, C.Name from  FL_Culture..SurveyCommitHistory As A
                        left join  FL_PortalHR..SysUser As B
                            on A.SurveyedUserId=B.UserId
                        left join  FL_PortalHR..SysGroup As C
                          on B.Pk_corp=C.GroupID
                        where C.type=2 and A.SurveyId='{0}' and C.Name like '%公司%' ";

                sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
                sql = string.Format(sql, surveyId);
                var CropEnt = DataHelper.QueryDict(sql);
                this.PageState.Add("CropEnum", CropEnt);
            }
            //if (IsPostBack)
            //{
            sql = "exec FL_Culture..pro_SummarySurvey_Choices '{0}'";
            sql = string.Format(sql, surveyId);

            DataTable Dt = DataHelper.QueryDataTable(sql);
            Dt = GetTreeData(Dt);
            this.PageState.Add("DataList", Dt);
            //}

        }

        /// <summary>
        /// 获取TreeData
        /// </summary>
        public DataTable GetTreeData(DataTable tDt)
        {
            DataTable Dt = tDt;
            //treegrid 
            DataTable TreeDt = new DataTable();
            DataColumn C_Id = new DataColumn("Id"); TreeDt.Columns.Add(C_Id);
            DataColumn C_Content = new DataColumn("Content"); TreeDt.Columns.Add(C_Content);
            DataColumn C_Value = new DataColumn("Value"); TreeDt.Columns.Add(C_Value);
            DataColumn C_parent = new DataColumn("ParentID"); TreeDt.Columns.Add(C_parent);
            DataColumn C_IsLeaf = new DataColumn("IsLeaf"); TreeDt.Columns.Add(C_IsLeaf);
            DataColumn C_Index = new DataColumn("Index"); TreeDt.Columns.Add(C_Index);
            DataColumn C_Item = new DataColumn("Item"); TreeDt.Columns.Add(C_Item);
            DataColumn C_Type = new DataColumn("QuestionType"); TreeDt.Columns.Add(C_Type);
            DataColumn C_Qty = new DataColumn("Qty"); TreeDt.Columns.Add(C_Qty);

            //root
            DataRow drRoot = TreeDt.NewRow();
            drRoot["Id"] = Guid.NewGuid().ToString();
            drRoot["Content"] = "问卷结果统计数据";
            drRoot["Value"] = string.Empty;
            drRoot["ParentID"] = "null";
            drRoot["IsLeaf"] = true;
            drRoot["Index"] = "0";
            TreeDt.Rows.Add(drRoot);

            //subitems
            for (int i = 0; i < Dt.Rows.Count; i++)
            {
                if (string.IsNullOrEmpty(Dt.Rows[i]["ItemSet"] + "")) continue;

                DataRow dr = TreeDt.NewRow();
                dr["QuestionType"] = Dt.Rows[i]["QuestionType"].ToString();
                dr["Id"] = Dt.Rows[i]["QuestionId"].ToString();
                dr["Content"] = Dt.Rows[i]["Content"].ToString();
                dr["Value"] = string.Empty;
                dr["ParentID"] = drRoot["Id"];   //******
                dr["IsLeaf"] = false;
                dr["Index"] = i + 1;
                TreeDt.Rows.Add(dr);

                string Qty = Dt.Rows[i]["Qty"].ToString();
                string SubItem = Dt.Rows[i]["ItemSet"] + "";
                string[] SubItemArr = SubItem.Split(new string[] { "$" }, StringSplitOptions.RemoveEmptyEntries);

                for (int j = 0; j < SubItemArr.Length; j++)
                {
                    //Eg:非常同意|20.00|否|0dd390d1-8d09-4392-83d8-54a8d71ea65e
                    string[] NextItem = (SubItemArr[j] + "").Split('|');

                    DataRow ItemDr = TreeDt.NewRow();
                    ItemDr["Id"] = NextItem[3];
                    ItemDr["Qty"] = Qty;
                    //ItemDr["Content"] = NextItem[0];
                    ItemDr["Item"] = NextItem[0];
                    ItemDr["Value"] = NextItem[1];
                    ItemDr["ParentID"] = dr["Id"];             //****
                    ItemDr["IsLeaf"] = true;
                    ItemDr["Index"] = (i + 1) + "_" + (j + 1);
                    TreeDt.Rows.Add(ItemDr);
                }

            }

            return TreeDt;
        }
    }
}

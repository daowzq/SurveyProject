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
using System.Text;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class FDimension : BaseListPage
    {
        private string SurveyId = string.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            SurveyId = RequestData.Get("SurveyId") + "";
            GetChoices();    //
            GetTotalSubmit();//提交的人数

            switch (RequestActionString)
            {
                case "Quesry":
                    break;
                case "SummaryChart": //概要报表
                    SummaryChart();
                    break;
                case "GetQstInfo":
                    GetQstInfo();
                    break;
                case "getAllNode":   //tree 查询
                    SurveyDetial();
                    break;
                case "GroupDetial":
                    SurveyDetial();
                    break;
                case "RBackQst":    //根据题反推人数
                    RebackQstInfo();
                    break;
                default:
                    DefaultSelect();
                    SurveyDetial();//
                    break;
            }
        }

        /// <summary>
        /// 问卷总的题统计
        /// </summary>
        private void DefaultSelect()
        {
            string sql = "select * from FL_Culture..SummarySurvey where SurveyId='{0}' order by SortIndex ";
            sql = string.Format(sql, SurveyId);

            DataTable Ents = DataHelper.QueryDataTable(sql);
            if (Ents.Rows.Count == 0)
            {
                sql = "exec FL_Culture..pro_SummarySurvey '{0}'";
                sql = string.Format(sql, SurveyId);
                Ents = DataHelper.QueryDataTable(sql);
            }

            this.PageState.Add("QstDataList", Ents);
        }

        /// <summary>
        /// 概要图表呈现
        /// </summary>
        private void SummaryChart()
        {

            string CorpSql = @"select distinct Corp ,count(*) over (partition by Corp)  As ItemTotal ,
	                                 count(*)over () As Total
                                from  
                                (
	                                select 
		                                WorkNo,Min(Id) As Id
	                                from FL_Culture..SummarySurvey_detail
	                                where SurveyId='{0}'
	                                group by WorkNo
                                )AS T 
                                left join  FL_Culture..SummarySurvey_detail As A
	                                on A.Id=T.Id
                                where A.SurveyId='{0}'";
            CorpSql = string.Format(CorpSql, SurveyId);

            //sex 分组
            string SexSql = @"select distinct Sex ,count(*) over (partition by Sex)  As ItemTotal ,
	                                 count(*)over () As Total
                                from  
                                (
	                                select 
		                                WorkNo,Min(Id) As Id
	                                from FL_Culture..SummarySurvey_detail
	                                where SurveyId='{0}'
	                                group by WorkNo
                                )AS T 
                                left join  FL_Culture..SummarySurvey_detail As A
	                                on A.Id=T.Id
                                where A.SurveyId='{0}' ";
            SexSql = string.Format(SexSql, SurveyId);

            string WorkAgeSql = @"select  
	                                distinct isnull(cast(WorkAge as nvarchar(10)),'未知') As WorkAge ,
	                                count(*) over (partition by WorkAge)  As ItemTotal , count(*)over () As Total,
                                    isnull(WorkAge,100) As T
                                from  
                                (
                                    select 
                                        WorkNo,Min(Id) As Id
                                    from FL_Culture..SummarySurvey_detail
                                    where SurveyId='{0}'
                                    group by WorkNo
                                )AS T 
                                left join  FL_Culture..SummarySurvey_detail As A
                                    on A.Id=T.Id
                                where A.SurveyId='{0}' ##AppendSQL## order by T ";
            WorkAgeSql = string.Format(WorkAgeSql, SurveyId);

            string AgeSegSQL = @"IF (OBJECT_ID('tempdb..#SummarySurvey_detail') IS NOT NULL)
                                    DROP TABLE tempdb..#SummarySurvey_detail;
                                -----处理后的数据
                                select 
	                                cast(newid() as varchar(36)) As Id, CA.Corp,
	                                A.SurveyId,A.WorkNo,A.UserId,A.UserName,A.Sex,A.Corp As Corp_1,
	                                A.Dept,A.Indutydate,A.WorkAge,A.Crux,A.BornDate,A.Age,
	                                A.JobName,A.JobDegree,A.JobSeq,A.Skill,A.Content,A.QuestionType,
	                                A.Answer,A.Explanation,A.QuestionId,A.QuestionItemId
	                                into #SummarySurvey_detail
                                from  FL_Culture..SummarySurvey_detail As A
                                Cross Apply(
                                    ##Age##
                                )As CA
                                where A.SurveyId='{0}' ;
                                -----
                                With Guid 
                                As (
		                                select Name,Value,SortIndex from FL_PortalHR..SysEnumeration where 
	                                ParentID in(select EnumerationID from  FL_PortalHR..SysEnumeration where Code='AgeSeg' ) 
                                ),
                                Detail As 
                                (
	                                select  
		                                distinct Corp ,count(*) over(partition by Corp) As ItemTotal , count(*)over() As Total
	                                from 
	                                (
		                                select WorkNo,Min(cast(Id as varchar(36))) As Id
		                                 from #SummarySurvey_detail
		                                group by WorkNo,Corp
	                                )AS T 
	                                left join #SummarySurvey_detail As A
		                                on A.Id=T.Id
                                )
                                select 
	                                A.Name As Corp,isnull(B.ItemTotal,0) As ItemTotal, isnull(B.Total,-1) As Total
                                 from Guid As A
	                                left join Detail As B  on A.Name=B.Corp";

            AgeSegSQL = string.Format(AgeSegSQL, SurveyId);
            AgeSegSQL = AgeSegSQL.Replace("FL_PortalHR", Global.AimPortalDB);

            string pType = RequestData.Get("pType") + ""; //筛选模式
            IList<EasyDictionary> DList = null;

            if (pType == "usr")
            {
                switch (RequestData.Get("GroupType") + "")
                {
                    case "Sex":
                        DList = DataHelper.QueryDictList(SexSql);
                        break;
                    case "WorkAge":
                        WorkAgeSql = WorkAgeSql.Replace("##AppendSQL##", "");
                        DList = DataHelper.QueryDictList(WorkAgeSql);
                        break;
                    case "AgeSeg":
                        AgeSegSQL = AgeSegSQL.Replace("##Age##", GetAgeSeg("A.Age"));
                        DList = DataHelper.QueryDictList(AgeSegSQL);
                        break;
                    case "Corp":
                        DList = DataHelper.QueryDictList(CorpSql);
                        break;
                    default:
                        DList = DataHelper.QueryDictList(CorpSql);
                        break;
                }
            }

            if (pType == "qst")
            {
                string QuestionId = RequestData.Get("QuestionId") + "";
                string QuestionItemId = RequestData.Get("QuestionItemId") + "";

                string AppendSql = @" and ##WorkNo## in 
		                            (
			                            select Distinct WorkNo from FL_Culture..SummarySurvey_detail As A
			                            where  A.SurveyId='{0}'
			                            and QuestionId='{1}' 
			                            and QuestionItemId='{2}'
		                            ) ";
                AppendSql = string.Format(AppendSql, SurveyId, QuestionId, QuestionItemId);

                switch (RequestData.Get("GroupType") + "")
                {
                    case "Sex":
                        AppendSql = AppendSql.Replace("##WorkNo##", " A.WorkNo ");
                        SexSql = SexSql + AppendSql;
                        DList = DataHelper.QueryDictList(SexSql);
                        break;
                    case "WorkAge":
                        AppendSql = AppendSql.Replace("##WorkNo##", " A.WorkNo ");
                        //WorkAgeSql = WorkAgeSql + AppendSql;
                        WorkAgeSql = WorkAgeSql.Replace("##AppendSQL##", AppendSql);
                        DList = DataHelper.QueryDictList(WorkAgeSql);
                        break;
                    case "AgeSeg":
                        AppendSql = AppendSql.Replace("##WorkNo##", " WorkNo ");
                        AgeSegSQL = AgeSegSQL.Replace("##Age##", GetAgeSeg("A.Age"));
                        AgeSegSQL = AgeSegSQL + AppendSql;
                        DList = DataHelper.QueryDictList(AgeSegSQL);
                        break;
                    case "Corp":
                        AppendSql = AppendSql.Replace("##WorkNo##", " A.WorkNo ");
                        CorpSql = CorpSql + AppendSql;
                        DList = DataHelper.QueryDictList(CorpSql);
                        break;
                    default:
                        AppendSql = AppendSql.Replace("##WorkNo##", " A.WorkNo ");
                        CorpSql = CorpSql + AppendSql;
                        DList = DataHelper.QueryDictList(CorpSql);
                        break;
                }
            }
            this.PageState.Add("SummaryChart", DList);
        }

        /// <summary>
        /// 获取每题选择情况
        /// </summary>
        private void GetChoices()
        {
            //            string sql = @"select QuestionId, sum(Tol) As Tol
            //                            from FL_Culture..SurveyedResult As A
            //                                Cross Apply(
            //                                     select Count(*) As Tol from 
            //                                         FL_Culture..f_splitstr(A.QuestionItemId,',')
            //                            ) As CA
            //                        where SurveyId='{0}'
            //                        Group  by QuestionId 
            //                        union 
            //                        select distinct Items As ItemId,  
            //                           count(*) over (partition by Items)  As total 
            //	                        from FL_Culture..SurveyedResult  As Tt
            //	                        cross apply
            //	                        (
            //		                        select F1 AS Items from  FL_Culture.dbo.f_splitstr( Tt.QuestionItemId,',')
            //	                        ) As CA
            //                        where SurveyId='{0}' 
            //	                        and Tt.QuestionId in
            //	                        (
            //	                          select Id from  FL_Culture..QuestionItem 
            //	                          where SurveyId='{0}' and QuestionType not like '填写项%'
            //	                        )";

            // WGM 2013-12-26 优化
            string sql = @"select QuestionId, count(*) As total 
                    from FL_Culture..SummarySurvey_detail As A
                    where SurveyId='{0}'
                    group by QuestionId
                    union 
                    select 
	                    QuestionItemId,count(*) As total
                    from  
	                    FL_Culture..SummarySurvey_detail As A
                    where SurveyId='{0}' and QuestionItemId is not null
                    group by QuestionItemId ";

            sql = string.Format(sql, SurveyId);
            this.PageState.Add("VoteInfo", DataHelper.QueryDict(sql));
        }

        /// <summary>
        /// 分组下的详细统计
        /// </summary>
        private void SurveyDetial()
        {
            string pType = RequestData.Get("pType") + "";
            string BeforeSQL = @"IF (OBJECT_ID('tempdb..#TotalCount') IS NOT NULL)
                                DROP TABLE tempdb..#TotalCount;
                            IF (OBJECT_ID('tempdb..#SubCount') IS NOT NULL)
                                DROP TABLE tempdb..#SubCount;
                            IF (OBJECT_ID('tempdb..#ThirdCount') IS NOT NULL)
                                DROP TABLE tempdb..#ThirdCount;
	                        IF (OBJECT_ID('tempdb..#Guid') IS NOT NULL)
                                DROP TABLE tempdb..#Guid;
	                         
                            select		
		                        A.Id As QuestionId,Content,QuestionType,
		                        B.Id As QuestionItemId,B.Answer
		                        into #Guid
	                         from  FL_Culture..QuestionItem As A 
		                        left join  FL_Culture..QuestionAnswerItem As B
			                        on A.SubItemId=B.QuestionItemId and A.SurveyId=B.SurveyId
	                        where  A.SurveyId='{0}' 
		                           and QuestionType not like '填写项%' 
	                        order  by A.SortIndex, B.SortIndex ;

                            ----该题选择人数
	                        select
		                        distinct 
		                        QuestionId ,QuestionType,Content, count(*) over (partition by QuestionId)  As total 
		                        into #TotalCount
	                         from FL_Culture..SummarySurvey_detail   As A
	                         -- Cross Apply(
				             --    select 1 As Tol from 
					         --         FL_Culture..f_splitstr(A.QuestionItemId,',')
	                         -- ) As CA
	                        where A.SurveyId='{0}'
		                        and QuestionType not like '填写项%' ";


            if (!string.IsNullOrEmpty(pType) && pType == "qst")  //以题模式进行统计
            {
                string QuestionId = RequestData.Get("QuestionId") + "";
                string QuestionItemId = RequestData.Get("QuestionItemId") + "";
                string tmpSQL = @" and A.WorkNo in 
		                            (
			                            select Distinct WorkNo from FL_Culture..SummarySurvey_detail As A
			                            where  A.SurveyId='{0}'
			                            and QuestionId='{1}' 
			                            and QuestionItemId='{2}'
		                            ) ";
                tmpSQL = string.Format(tmpSQL, SurveyId, QuestionId, QuestionItemId);
                BeforeSQL = BeforeSQL + tmpSQL;
            }

            string CorpSQL = @" 
                            --条件下的各个题的票数
	                        select
		                        distinct  Corp,QuestionId,Content,QuestionType, 
                                count(*) over (partition by Corp,QuestionId)  As total
		                        into #SubCount
	                        from FL_Culture..SummarySurvey_detail As A
	                        where A.SurveyId='{0}' ##Query##
	                        and QuestionType not like '填写项%' 

	                        ---各个题项选择人数
	                        select
		                        distinct Corp, A.QuestionId,A.Content,QuestionItemId, A.AnSwer,
		                        count(*) over (partition by Corp,QuestionId,QuestionItemId)  As total 
		                        into #ThirdCount
	                        from FL_Culture..SummarySurvey_detail As A
	                        where A.SurveyId='{0}' ##Query##
		                          and QuestionType not like '填写项%'

	                        select 
		                        newid() As Id,A.*,
	                            isnull(B.total,0) Total, isnull(C.total,0) As QstTotal,isnull(D.total,0) As ItemTotal,
		                        cast(1.0*isnull(D.total,0)/isnull(B.total,0)*100 as Decimal(5,2)) As TotalRate,
		                        cast(1.0*isnull(D.total,0)/isnull(C.total,0)*100 as Decimal(5,2)) As CurrRate
                            from (
		                        select * from 
		                        ( select distinct Corp from FL_Culture..SummarySurvey_detail As A 
		                           where  A.SurveyId='{0}' ##Query##
		                        )As A, #Guid
	                        )As A 
	                        left join  #TotalCount As B
		                        on B.QuestionId=A.QuestionId
	                        left join  #SubCount As C
		                        on A.QuestionId=C.QuestionId and C.Corp=A.Corp
	                        left join  #ThirdCount As D
		                        on D.Corp=A.Corp and D.QuestionId=A.QuestionId and A.QuestionItemId=D.QuestionItemId";

            CorpSQL = BeforeSQL + CorpSQL;
            CorpSQL = string.Format(CorpSQL, SurveyId);
            CorpSQL = CorpSQL.Replace("##Query##", internalSQL("A.WorkNo"));

            string SexSQL = @"  
                                --条件下的各个题的票数
                                select
                                    distinct 
                                    Sex As Corp,QuestionId,Content,QuestionType, count(*) over (partition by Sex,QuestionId)  As total
                                    into #SubCount
                                from FL_Culture..SummarySurvey_detail As A
                                where A.SurveyId='{0}' ##Query##
                                and QuestionType not like '填写项%' 
                                ---各个题项选择人数

                                select
                                    distinct Sex As Corp, A.QuestionId,A.Content, QuestionItemId, A.AnSwer,
                                    count(*) over (partition by Sex,QuestionId,QuestionItemId)  As total 
                                    into #ThirdCount
                                from FL_Culture..SummarySurvey_detail As A
                                where A.SurveyId='{0}' ##Query##
                                      and QuestionType not like '填写项%'

                                select 
                                    newid() As Id,A.*,
                                    isnull(B.total,0) Total, isnull(C.total,0) As QstTotal,isnull(D.total,0) As ItemTotal,
                                    cast(1.0*isnull(D.total,0)/isnull(B.total,0)*100 as Decimal(5,2)) As TotalRate,
                                    cast(1.0*isnull(D.total,0)/isnull(C.total,0)*100 as Decimal(5,2)) As CurrRate
                                from (
                                    select * from 
                                    ( select distinct Sex As Corp from FL_Culture..SummarySurvey_detail As A 
                                       where  A.SurveyId='{0}' ##Query##
                                    )As A, #Guid
                                )As A 
                                left join  #TotalCount As B
                                    on B.QuestionId=A.QuestionId
                                left join  #SubCount As C
                                    on A.QuestionId=C.QuestionId and C.Corp=A.Corp
                                left join  #ThirdCount As D
                                    on D.Corp=A.Corp and D.QuestionId=A.QuestionId and A.QuestionItemId=D.QuestionItemId";

            SexSQL = BeforeSQL + SexSQL;
            SexSQL = string.Format(SexSQL, SurveyId);
            SexSQL = SexSQL.Replace("##Query##", internalSQL("A.WorkNo"));

            string WorkAgeSQL = @"--条件下的各个题的票数
                                select
                                   distinct isnull(cast(WorkAge as nvarchar(10)),'未知') As Corp,QuestionId,Content,QuestionType, 
	                               count(*) over (partition by WorkAge,QuestionId)  As total
                                   into #SubCount
                                from FL_Culture..SummarySurvey_detail As A
                                where A.SurveyId='{0}' ##Query##
                                and QuestionType not like '填写项%' ;
                                ---各个题项选择人数
                                select
                                    distinct isnull(cast(WorkAge as nvarchar(10)),'未知') As Corp, A.QuestionId,A.Content, 
                                    QuestionItemId, A.AnSwer, count(*) over (partition by WorkAge,QuestionId,QuestionItemId) As total 
                                    into #ThirdCount
                                from FL_Culture..SummarySurvey_detail As A
                                where A.SurveyId='{0}' ##Query##
                                      and QuestionType not like '填写项%';

                                select 
                                    newid() As Id,A.*,
                                    isnull(B.total,0) Total, isnull(C.total,0) As QstTotal,isnull(D.total,0) As ItemTotal,
                                    cast(1.0*isnull(D.total,0)/isnull(B.total,0)*100 as Decimal(5,2)) As TotalRate,
                                    cast(1.0*isnull(D.total,0)/isnull(C.total,0)*100 as Decimal(5,2)) As CurrRate
                                from (
                                    select * from 
                                    ( select distinct  isnull(cast(WorkAge as nvarchar(10)),'未知') As Corp from FL_Culture..SummarySurvey_detail As A 
                                       where  A.SurveyId='{0}' ##Query##
                                    )As A, #Guid
                                )As A 
                                left join  #TotalCount As B
                                    on B.QuestionId=A.QuestionId
                                left join  #SubCount As C
                                    on A.QuestionId=C.QuestionId and C.Corp=A.Corp
                                left join  #ThirdCount As D
                                    on D.Corp=A.Corp and D.QuestionId=A.QuestionId and A.QuestionItemId=D.QuestionItemId";

            WorkAgeSQL = BeforeSQL + WorkAgeSQL;
            WorkAgeSQL = string.Format(WorkAgeSQL, SurveyId);
            WorkAgeSQL = WorkAgeSQL.Replace("##Query##", internalSQL("A.WorkNo"));

            string AgeSegSQL = @"IF (OBJECT_ID('tempdb..#TotalCount') IS NOT NULL)
                                    DROP TABLE tempdb..#TotalCount;
                                IF (OBJECT_ID('tempdb..#SubCount') IS NOT NULL)
                                    DROP TABLE tempdb..#SubCount;
                                IF (OBJECT_ID('tempdb..#ThirdCount') IS NOT NULL)
                                    DROP TABLE tempdb..#ThirdCount;
                                IF (OBJECT_ID('tempdb..#Guid') IS NOT NULL)
                                    DROP TABLE tempdb..#Guid;
                                IF (OBJECT_ID('tempdb..#SummarySurvey_detail') IS NOT NULL)
                                    DROP TABLE tempdb..#SummarySurvey_detail;
                                select		
                                    A.Id As QuestionId,Content,QuestionType,
                                    B.Id As QuestionItemId,B.Answer
                                    into #Guid
                                 from  FL_Culture..QuestionItem As A 
                                    left join  FL_Culture..QuestionAnswerItem As B
                                        on A.SubItemId=B.QuestionItemId and A.SurveyId=B.SurveyId
                                where  A.SurveyId='{0}' 
                                       and QuestionType not like '填写项%' 
                                order  by A.SortIndex, B.SortIndex ;

                                -----处理后的数据
                                select 
	                                cast(newid() as varchar(36)) As Id, Ca.Corp,
	                                A.SurveyId,A.WorkNo,A.UserId,A.UserName,A.Sex,A.Corp As Corp_1,
	                                A.Dept,A.Indutydate,A.WorkAge,A.Crux,A.BornDate,A.Age,
	                                A.JobName,A.JobDegree,A.JobSeq,A.Skill,A.Content,A.QuestionType,
	                                A.Answer,A.Explanation,A.QuestionId,A.QuestionItemId
	                                into #SummarySurvey_detail
                                from  FL_Culture..SummarySurvey_detail As A
                                Cross Apply(
                                        ##Age##
                                )As Ca
                                where A.SurveyId='{0}'
                                      ##Append##
                                ----该题选择人数
                                select
                                    distinct 
                                    QuestionId ,QuestionType,Content, 
                                    (select count(*) As total
			                            from (
				                            select
					                             Min(cast(Id as varchar(36))) As T
				                             from  FL_Culture..SummarySurvey_detail As A
				                               where A.SurveyId='{0}' ##Query##
				                            group by workno
			                            ) As A
		                            )As total 
                                    into #TotalCount
                                from #SummarySurvey_detail   As A
                                  Cross Apply( select 1 As Tol from   FL_Culture..f_splitstr(A.QuestionItemId,',') ) As CA
                                where  QuestionType not like '填写项%'								
                                 
                                --条件下的各个题的总票数
                                select
                                   distinct Corp,QuestionId,Content,QuestionType, 
                                   count(*) over (partition by Corp,QuestionId)  As total
                                   into #SubCount
                                from #SummarySurvey_detail  As A
                                where  QuestionType not like '填写项%' 

                                ---各个题项选择人数
                                select
                                    distinct Corp, A.QuestionId,A.Content,QuestionItemId, A.AnSwer,
                                    count(*) over (partition by Corp,QuestionId,QuestionItemId)  As total 
                                    into #ThirdCount
                                from #SummarySurvey_detail  As A
                                where QuestionType not like '填写项%';
                                ---margin
                                select 
                                    newid() As Id,A.*,
                                    isnull(B.total,0) Total, isnull(C.total,0) As QstTotal,isnull(D.total,0) As ItemTotal,
                                    cast(1.0*isnull(D.total,0)/isnull(B.total,0)*100 as Decimal(5,2)) As TotalRate,
                                    cast(1.0*isnull(D.total,0)/isnull(C.total,0)*100 as Decimal(5,2)) As CurrRate
                                from 
                                (
                                    select * from 
                                    (  
	                                   select distinct Corp from #SummarySurvey_detail As A 
                                    )As A, #Guid
                                )As A 
                                left join  #TotalCount As B
                                    on B.QuestionId=A.QuestionId
                                left join  #SubCount As C
                                    on A.QuestionId=C.QuestionId and C.Corp=A.Corp
                                left join  #ThirdCount As D
                                    on D.Corp=A.Corp and D.QuestionId=A.QuestionId and A.QuestionItemId=D.QuestionItemId";
            AgeSegSQL = string.Format(AgeSegSQL, SurveyId);
            AgeSegSQL = AgeSegSQL.Replace("##Query##", internalSQL("A.WorkNo"));

            if (!string.IsNullOrEmpty(pType) && pType == "qst")  //以题模式进行统计
            {
                string QuestionId = RequestData.Get("QuestionId") + "";
                string QuestionItemId = RequestData.Get("QuestionItemId") + "";
                string tmpSQL = @" and A.WorkNo in 
		                            (
			                            select Distinct WorkNo from FL_Culture..SummarySurvey_detail As A
			                            where  A.SurveyId='{0}'
			                            and QuestionId='{1}' 
			                            and QuestionItemId='{2}'
		                            ) ";
                tmpSQL = string.Format(tmpSQL, SurveyId, QuestionId, QuestionItemId);
                AgeSegSQL = AgeSegSQL.Replace("##Append##", tmpSQL);
            }
            else if (!string.IsNullOrEmpty(pType) && pType == "usr")
            {
                AgeSegSQL = AgeSegSQL.Replace("##Append##", "");
            }
            else
            {
                AgeSegSQL = AgeSegSQL.Replace("##Append##", "");
            }
            //----------------

            IList<EasyDictionary> DList = null;
            switch ((RequestData.Get("GroupType") + "").Trim())
            {
                case "WorkAge":
                    DList = DataHelper.QueryDictList(WorkAgeSQL);
                    {
                        string coprChsSQ = @"select 
	                                            distinct isnull(cast(WorkAge as nvarchar(10)),'未知') As Corp ,
                                                count(*) over (partition by WorkAge)  As ItemTotal           
                                            from  
                                            (
                                                select 
                                                    WorkNo,Min(Id) As Id
                                                from FL_Culture..SummarySurvey_detail As A
                                                where A.SurveyId='{0}' ##Query##
                                                group by WorkNo
                                            )AS T 
                                            left join  FL_Culture..SummarySurvey_detail As A
                                                on A.Id=T.Id
                                            where A.SurveyId='{0}'";

                        coprChsSQ = coprChsSQ.Replace("##Query##", internalSQL("A.WorkNo"));
                        coprChsSQ = string.Format(coprChsSQ, SurveyId);
                        this.PageState.Add("CorpUsr", DataHelper.QueryDict(coprChsSQ));
                    }
                    break;
                case "Sex":
                    DList = DataHelper.QueryDictList(SexSQL);
                    {
                        string coprChsSQ = @"select distinct Sex As Corp ,count(*) over (partition by Sex)  As ItemTotal           
                                from  
                                (
                                    select 
                                        WorkNo,Min(Id) As Id
                                    from FL_Culture..SummarySurvey_detail As A
                                    where A.SurveyId='{0}' ##Query##
                                    group by WorkNo
                                )AS T 
                                left join  FL_Culture..SummarySurvey_detail As A
                                    on A.Id=T.Id
                                where A.SurveyId='{0}'";
                        coprChsSQ = coprChsSQ.Replace("##Query##", internalSQL("A.WorkNo"));
                        coprChsSQ = string.Format(coprChsSQ, SurveyId);
                        this.PageState.Add("CorpUsr", DataHelper.QueryDict(coprChsSQ));
                    }
                    break;
                case "AgeSeg":
                    string tempAgeStr = GetAgeSeg(" A.Age");
                    AgeSegSQL = AgeSegSQL.Replace("##Age##", tempAgeStr);
                    DList = DataHelper.QueryDictList(AgeSegSQL);
                    {
                        string tmpSQL = @" IF (OBJECT_ID('tempdb..#SummarySurvey_detail') IS NOT NULL)
                                            DROP TABLE tempdb..#SummarySurvey_detail;
                                        -----处理后的数据
                                        select 
	                                        cast(newid() as varchar(36)) As Id, CA.Corp,
	                                        A.SurveyId,A.WorkNo,A.UserId,A.UserName,A.Sex,A.Corp As Corp_1,
	                                        A.Dept,A.Indutydate,A.WorkAge,A.Crux,A.BornDate,A.Age,
	                                        A.JobName,A.JobDegree,A.JobSeq,A.Skill,A.Content,A.QuestionType,
	                                        A.Answer,A.Explanation,A.QuestionId,A.QuestionItemId
	                                        into #SummarySurvey_detail
                                        from  FL_Culture..SummarySurvey_detail As A
                                        Cross Apply(
                                            ##Age##
                                        )As CA
                                        where A.SurveyId='{0}' ##Query## ;
                                        -----
                                        With Guid 
                                        As (
		                                        select Name,Value,SortIndex from FL_PortalHR..SysEnumeration where 
	                                        ParentID in(select EnumerationID from  FL_PortalHR..SysEnumeration where Code='AgeSeg' ) 
                                        ),
                                        Detail As 
                                        (
	                                        select  
		                                        distinct Corp ,count(*) over(partition by Corp) As ItemTotal , count(*)over() As Total
	                                        from 
	                                        (
		                                        select WorkNo,Min(cast(Id as varchar(36))) As Id
		                                         from #SummarySurvey_detail
		                                        group by WorkNo,Corp
	                                        )AS T 
	                                        left join #SummarySurvey_detail As A
		                                        on A.Id=T.Id
                                        )
                                        select 
	                                        A.Name As Corp,isnull(B.ItemTotal,0) As ItemTotal
                                         from Guid As A
	                                        left join Detail As B  on A.Name=B.Corp";

                        tmpSQL = tmpSQL.Replace("##Query##", internalSQL("A.WorkNo"));
                        tmpSQL = string.Format(tmpSQL, SurveyId);
                        tmpSQL = tmpSQL.Replace("##Age##", tempAgeStr);
                        tmpSQL = tmpSQL.Replace("FL_PortalHR", Global.AimPortalDB);
                        this.PageState.Add("CorpUsr", DataHelper.QueryDict(tmpSQL));
                    }
                    break;
                case "Corp":
                    DList = DataHelper.QueryDictList(CorpSQL);
                    {
                        string coprChsSQ = @"select distinct Corp ,count(*) over (partition by Corp)  As ItemTotal           
                                from  
                                (
                                    select 
                                        WorkNo,Min(Id) As Id
                                    from FL_Culture..SummarySurvey_detail As A
                                    where SurveyId='{0}' ##Query##
                                    group by WorkNo
                                )AS T 
                                left join  FL_Culture..SummarySurvey_detail As A
                                    on A.Id=T.Id
                                where A.SurveyId='{0}'";

                        coprChsSQ = coprChsSQ.Replace("##Query##", internalSQL("A.WorkNo"));
                        coprChsSQ = string.Format(coprChsSQ, SurveyId);
                        this.PageState.Add("CorpUsr", DataHelper.QueryDict(coprChsSQ));
                    }
                    break;
                default:
                    DList = DataHelper.QueryDictList(CorpSQL);
                    {
                        string coprChsSQ = @"select distinct Corp ,count(*) over (partition by Corp)  As ItemTotal           
                                from  
                                (
                                    select 
                                        WorkNo,Min(Id) As Id 
                                    from FL_Culture..SummarySurvey_detail As A
                                    where SurveyId='{0}' ##Query##
                                    group by WorkNo
                                )AS T 
                                left join  FL_Culture..SummarySurvey_detail As A
                                    on A.Id=T.Id
                                where A.SurveyId='{0}'";

                        coprChsSQ = string.Format(coprChsSQ, SurveyId);
                        coprChsSQ = coprChsSQ.Replace("##Query##", internalSQL("A.WorkNo"));
                        this.PageState.Add("CorpUsr", DataHelper.QueryDict(coprChsSQ));
                    }
                    break;
            }

            this.PageState.Add("QstDetail", DList);

        }

        private string internalSQL(string fieldName)
        {
            string ty = RequestData.Get("pType") + "";

            if (!string.IsNullOrEmpty(ty) && ty == "qst")  //以题模式进行统计
            {
                string QuestionId = RequestData.Get("QuestionId") + "";
                string QuestionItemId = RequestData.Get("QuestionItemId") + "";
                string SurveyId = RequestData.Get("SurveyId") + "";

                string tmpSQL = @"  and ##WorkNo## in 
		                            (
			                            select Distinct WorkNo from FL_Culture..SummarySurvey_detail As A
			                            where  A.SurveyId='{0}'
			                            and QuestionId='{1}' 
			                            and QuestionItemId='{2}'
		                            ) ";
                tmpSQL = string.Format(tmpSQL, SurveyId, QuestionId, QuestionItemId);
                tmpSQL = tmpSQL.Replace("##WorkNo##", fieldName);
                return tmpSQL;
            }
            else
            {
                return "";
            }
        }

        private string internalSQL(string fieldName, bool isCondition)
        {
            string ty = RequestData.Get("pType") + "";

            if (!string.IsNullOrEmpty(ty) && ty == "qst")  //以题模式进行统计
            {
                string QuestionId = RequestData.Get("QstQuestionId") + "";
                string QuestionItemId = RequestData.Get("QstQuestionItemId") + "";
                string SurveyId = RequestData.Get("SurveyId") + "";

                string tmpSQL = @"  and ##WorkNo## in 
		                            (
			                            select Distinct WorkNo from FL_Culture..SummarySurvey_detail As A
			                            where  A.SurveyId='{0}'
			                            and QuestionId='{1}' 
			                            and QuestionItemId='{2}'
		                            ) ";
                tmpSQL = string.Format(tmpSQL, SurveyId, QuestionId, QuestionItemId);
                tmpSQL = tmpSQL.Replace("##WorkNo##", fieldName);
                return tmpSQL;
            }
            else
            {
                return "";
            }
        }


        /// <summary>
        /// 问题项统计
        /// </summary>
        private void GetQstInfo()
        {
            string SurveyId = RequestData.Get("SurveyId") + "";
            string QuesiontId = RequestData.Get("QuestionId") + "";

            string sql = @"With Guid As
	                        (
		                        select
                                    A.Id As QuestionId,Content,QuestionType,
                                    B.Id As QuestionItemId,B.Answer,A.SortIndex As AIndex,B.SortIndex as BIndex
                                 from  FL_Culture..QuestionItem As A 
                                    left join  FL_Culture..QuestionAnswerItem As B
                                        on A.SubItemId=B.QuestionItemId and A.SurveyId=B.SurveyId
                                where  A.SurveyId='{0}' 
                                       and QuestionType not like '填写项%' 
			                           and A.Id='{2}'
	                        ),
	                        Info As
                            (
		                        select
			                        distinct ##FristCln##, A.QuestionId,A.Content, Items as QuestionItemId, A.AnSwer,
			                        count(*) over (partition by ##GroupBy##,QuestionId,Items)  As total ,Ct.SubmitTol
		                        from FL_Culture..SummarySurvey_detail As A
		                          cross apply
			                        (
			                           select F1 AS Items from  FL_Culture.dbo.f_splitstr( A.QuestionItemId,',')
			                        ) As CA
		                           Cross apply
			                        (
				                        select count(distinct WorkNo) As SubmitTol
				                        from FL_Culture..SummarySurvey_detail  As A
				                        Cross Apply( select 1 As Tol from  FL_Culture..f_splitstr(A.QuestionItemId,',') ) As CA
				                        where A.SurveyId='{0}' ##Query##
					                          and QuestionType not like '填写项%' 
			                        )Ct
		                        where A.SurveyId='{0}'  ##Query##
			                         and {1}
			                         and QuestionId='{2}' 
			                         and QuestionType not like '填写项%'      
                            )
	                        select B.Corp,A.QuestionId,A.Content,A.QuestionItemId,
							       A.Answer, isnull(B.total,0) as Total,isnull(SubmitTol,0) as SubmitTol
                            from Guid As A 
		                        left join Info As B
			                        on A.QuestionId=B.QuestionId and A.QuestionItemId=B.QuestionItemId
	                        order by  Aindex,BIndex";
            sql = sql.Replace("##Query##", internalSQL("A.WorkNo", true));

            //根据问题反推统计项 无分组统计
            string sql_no = @"With Guid As
	                        (
		                        select
                                    A.Id As QuestionId,Content,QuestionType,
                                    B.Id As QuestionItemId,B.Answer,A.SortIndex As AIndex,B.SortIndex as BIndex
                                 from  FL_Culture..QuestionItem As A 
                                    left join  FL_Culture..QuestionAnswerItem As B
                                        on A.SubItemId=B.QuestionItemId and A.SurveyId=B.SurveyId
                                where  A.SurveyId='{0}' 
                                       and QuestionType not like '填写项%' 
			                           and A.Id='{2}'
	                        ),
	                        Info As
                            (
		                        select
			                        distinct  A.QuestionId,A.Content, Items as QuestionItemId, A.AnSwer,
			                        count(*) over (partition by QuestionId,Items)  As total ,Ct.SubmitTol
		                        from FL_Culture..SummarySurvey_detail As A
		                          cross apply
			                        (
			                           select F1 AS Items from  FL_Culture.dbo.f_splitstr( A.QuestionItemId,',')
			                        ) As CA
		                           Cross apply
			                        (
				                        select count(distinct WorkNo) As SubmitTol
				                        from FL_Culture..SummarySurvey_detail  As A
				                        Cross Apply( select 1 As Tol from  FL_Culture..f_splitstr(A.QuestionItemId,',') ) As CA
				                        where A.SurveyId='{0}' ##Query##
					                          and QuestionType not like '填写项%' 
			                        )Ct
		                        where A.SurveyId='{0}'  ##Query##
			                         and {1}
			                         and QuestionId='{2}' 
			                         and QuestionType not like '填写项%'      
                            )
	                        select A.QuestionId,A.Content,A.QuestionItemId,
							       A.Answer, isnull(B.total,0) as Total,isnull(SubmitTol,0) as SubmitTol
                            from Guid As A 
		                        left join Info As B
			                        on A.QuestionId=B.QuestionId and A.QuestionItemId=B.QuestionItemId
	                        order by  Aindex,BIndex";
            sql_no = sql_no.Replace("##Query##", internalSQL("A.WorkNo", true));

            string AgeSQL = @"IF (OBJECT_ID('tempdb..#SummarySurvey_detail') IS NOT NULL)
                                DROP TABLE tempdb..#SummarySurvey_detail;
                            select 
                                cast(newid() as varchar(36)) As Id, CA.Corp,
                                A.SurveyId,A.WorkNo,A.UserId,A.UserName,A.Sex,A.Corp As Corp_1,
                                A.Dept,A.Indutydate,A.WorkAge,A.Crux,A.BornDate,A.Age,
                                A.JobName,A.JobDegree,A.JobSeq,A.Skill,A.Content,A.QuestionType,
                                A.Answer,A.Explanation,A.QuestionId,A.QuestionItemId
                                into #SummarySurvey_detail
                            from  FL_Culture..SummarySurvey_detail As A
                            Cross Apply(
                                   ##Age##
                            )As CA
                            where A.SurveyId='{0}' ##Query## ;

                            With Guid 
                            As 
                            (
	                            select		
		                            A.Id As QuestionId,Content,QuestionType,
		                            B.Id As QuestionItemId,B.Answer,
		                            A.SortIndex As AIndex,B.SortIndex as BIndex
	                             from  FL_Culture..QuestionItem As A 
		                            left join  FL_Culture..QuestionAnswerItem As B
			                            on A.SubItemId=B.QuestionItemId and A.SurveyId=B.SurveyId
	                             where  A.SurveyId='{0}'
		                               and QuestionType not like '填写项%' 
		                               and A.Id='{2}'
                            ),
                            Info
                            As(
	                            select
		                            distinct Corp, A.QuestionId,A.Content, Items as QuestionItemId, A.AnSwer,
		                            count(*) over (partition by Corp,QuestionId,Items)  As total ,Ct.SubmitTol
	                            from #SummarySurvey_detail As A
	                              cross apply
		                            (
		                               select F1 AS Items from  FL_Culture.dbo.f_splitstr( A.QuestionItemId,',')
		                            ) As CA
	                               Cross apply
		                            (
			                            select count(distinct WorkNo) As SubmitTol
			                            from #SummarySurvey_detail  As A
			                            Cross Apply( select 1 As Tol from  FL_Culture..f_splitstr(A.QuestionItemId,',') ) As CA
			                            where  QuestionType not like '填写项%' 
		                            )Ct
	                            where  Corp='{1}'  and QuestionId='{2}' 
		                             and QuestionType not like '填写项%'  
                            )
                             
                            select B.Corp,A.QuestionId,A.Content,A.QuestionItemId,
                               A.Answer, isnull(B.total,0) as Total,isnull(SubmitTol,0) as SubmitTol
                            from Guid As A 
                            left join Info As B
                                on A.QuestionId=B.QuestionId and A.QuestionItemId=B.QuestionItemId
                            order by  Aindex,BIndex  ";
            AgeSQL = AgeSQL.Replace("##Query##", internalSQL("A.WorkNo", true));
            string QtyOpt = RequestData.Get("QtyOpt") + "";

            IList<EasyDictionary> DList = null;
            switch ((RequestData.Get("GroupType") + "").Trim())
            {
                case "Sex":
                    sql = sql.Replace("##FristCln##", "Sex As Corp").Replace("##GroupBy##", "Sex");
                    sql = string.Format(sql, SurveyId, " Sex='" + QtyOpt + "' ", QuesiontId);
                    DList = DataHelper.QueryDictList(sql);
                    break;
                case "WorkAge":
                    sql = sql.Replace("##FristCln##", "isnull(cast(WorkAge as nvarchar(10)),'未知') As Corp").Replace("##GroupBy##", "WorkAge");
                    if (QtyOpt.Contains("未知"))
                    {
                        sql = string.Format(sql, SurveyId, " WorkAge is null ", QuesiontId);
                        DList = DataHelper.QueryDictList(sql);
                    }
                    else
                    {
                        sql = string.Format(sql, SurveyId, " WorkAge=" + QtyOpt, QuesiontId);
                        DList = DataHelper.QueryDictList(sql);
                    }
                    break;
                case "AgeSeg":
                    AgeSQL = string.Format(AgeSQL, SurveyId, QtyOpt, QuesiontId);
                    AgeSQL = AgeSQL.Replace("##Age##", GetAgeSeg(" A.Age "));
                    DList = DataHelper.QueryDictList(AgeSQL);
                    break;
                case "Corp":
                    sql = sql.Replace("##FristCln##", "Corp").Replace("##GroupBy##", "Corp");
                    sql = string.Format(sql, SurveyId, " Corp='" + QtyOpt + "' ", QuesiontId);
                    DList = DataHelper.QueryDictList(sql);
                    break;
                case "no": //根据题反推
                    {
                        string QstQuestionId = RequestData.Get("QstQuestionId") + "";
                        string QstQuestionItemId = RequestData.Get("QstQuestionItemId") + "";

                        sql_no = string.Format(sql_no, SurveyId, " 1=1 ", QuesiontId);
                        DList = DataHelper.QueryDictList(sql_no);
                    }
                    break;
                default:
                    sql = sql.Replace("##FristCln##", "Corp").Replace("##GroupBy##", "Corp");
                    sql = string.Format(sql, SurveyId, " Corp='" + QtyOpt + "' ", QuesiontId);
                    DList = DataHelper.QueryDictList(sql);
                    break;
            }

            this.PageState.Add("QstInfo", DList);
        }

        /// <summary>
        /// 根据题反推选项
        /// </summary>
        private void RebackQstInfo()
        {
            string QuestionId = RequestData.Get("QuestionId") + "";
            string QuestionItemId = RequestData.Get("QuestionItemId") + "";

            string sql = @"------------
                        IF (OBJECT_ID('tempdb..#Guid') IS NOT NULL)
                            DROP TABLE tempdb..#Guid;
                        IF (OBJECT_ID('tempdb..#Accord') IS NOT NULL)
                            DROP TABLE tempdb..#Accord;
                        --guid
                        select		
	                        A.Id As QuestionId,Content,QuestionType,
	                        B.Id As QuestionItemId,B.Answer,
	                        A.SortIndex As AIndex,B.SortIndex as BIndex
	                        into #Guid
                         from  FL_Culture..QuestionItem As A 
	                        left join  FL_Culture..QuestionAnswerItem As B
		                        on A.SubItemId=B.QuestionItemId and A.SurveyId=B.SurveyId
                         where  A.SurveyId='{0}'
	                           and QuestionType not like '填写项%' ;
                        --record
                        select * into #Accord
	                        from   FL_Culture..SummarySurvey_detail As A 
                        where   A.SurveyId='{0}' 
		                        and  WorkNo in 
		                        (
			                        select Distinct WorkNo from FL_Culture..SummarySurvey_detail As A
			                        where  A.SurveyId='{0}'
			                        and QuestionId='{1}' 
			                        and  QuestionItemId='{2}'
		                        );
                        ------
                        With QstTotalRote 
                        As 
                        (
	                        select 
		                        distinct  QuestionId ,QuestionType,Content, count(*) over (partition by QuestionId)  As total 
	                        from #Accord  As A
	                          Cross Apply(
				                         select 1 As Tol from 
					                         FL_Culture..f_splitstr(A.QuestionItemId,',')
	                          ) As CA
	                        where A.SurveyId='{0}'
		                        and QuestionType not like '填写项%'		
                        ),
                        ItemChoice As 
                        (
                            select
                                distinct Corp, A.QuestionId,A.Content, Items as QuestionItemId, A.AnSwer,
                                count(*) over (partition by Items)  As total 
                            from  #Accord As A
                            cross apply
                                ( select F1 AS Items from  FL_Culture.dbo.f_splitstr( A.QuestionItemId,',') ) As CA
                            where A.SurveyId='{0}'
                                  and QuestionType not like '填写项%'
                        )
                        select
	                        distinct A.*,
	                        B.total As ZTotal, isnull(C.total,0) As STotal
                            from  #Guid As A
	                        left join  QstTotalRote As B	
		                        on A.QuestionId=B.QuestionId
                            left join ItemChoice As C
		                        on C.QuestionId=A.QuestionId and C.QuestionItemId=A.QuestionItemId
                            order by AIndex,BIndex; ";

            sql = string.Format(sql, SurveyId, QuestionId, QuestionItemId);
            this.PageState.Add("DList", DataHelper.QueryDictList(sql));
        }

        /// <summary>
        /// 获取提交的总人数
        /// </summary>
        private void GetTotalSubmit()
        {
            string sql = @" select count(distinct WorkNo) As SubmitTol
                            from FL_Culture..SummarySurvey_detail  As A
                            where A.SurveyId='{0}' ";
            sql = string.Format(sql, SurveyId);
            this.PageState.Add("SubmitTol", DataHelper.QueryValue<int>(sql));
        }

        /// <summary>
        /// 组合年龄段SQL
        /// </summary>
        private string GetAgeSeg(string InputFieldName)
        {
            string SQL = @"select 
                                Name,Value,SortIndex 
                          from FL_PortalHR..SysEnumeration 
                          where ParentID 
                          in(
                                select EnumerationID from  FL_PortalHR..SysEnumeration where Code='AgeSeg' 
                           ) ";
            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
            DataTable Dt = DataHelper.QueryDataTable(SQL);

            StringBuilder strb = new StringBuilder();
            for (int i = 0; i < Dt.Rows.Count; i++)
            {
                string OraStr = Dt.Rows[i]["Name"] + "";
                string[] Arr = (Dt.Rows[i]["Name"] + "").Split('-');

                if (string.IsNullOrEmpty(OraStr)) continue;
                if (i > 0) strb.Append(" union all ");

                if (Arr.Length > 1)
                {
                    strb.Append(" select '" + OraStr + "' As Corp where " + InputFieldName + " between " + Arr[0] + " and " + Arr[1] + " \r\n");
                }
                else
                {
                    strb.Append(" select '" + OraStr + "' As Corp  where " + InputFieldName + " " + Arr[0] + " \r\n");
                }
            }
            return strb.ToString();
        }

    }
}

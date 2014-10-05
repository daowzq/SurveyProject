using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using NHibernate.Criterion;
using Aim.Data;
using Aim.Examining.Web;
using System.Configuration;
using Aim.WorkFlow;
using System.Data;

namespace Aim.Examining.Web.ReportSheet
{
    public partial class OutDutyReport : ExamListPage
    {
        string sql = "";
        DateTime first = new DateTime(DateTime.Now.Year, 1, 1);
        DateTime last = new DateTime(DateTime.Now.Year + 1, 1, 1).AddDays(-1);
        protected void Page_Load(object sender, EventArgs e)
        {
            first = RequestData.Get<DateTime>("start", first);
            last = RequestData.Get<DateTime>("end", last);

            switch (RequestActionString)
            {
                default:
                    DoSelectDefault(first, last);
                    break;
            }
        }

        private void DoSelectDefault(DateTime first, DateTime last)
        {
            string sql = @"select '{2}' as Year,
isnull(sum(case when datepart(mm,outdutydate)='1' then 1 else 0 end),0) as January,
isnull(sum(case when datepart(mm,outdutydate)='2' then 1 else 0 end),0) as February,
isnull(sum(case when datepart(mm,outdutydate)='3' then 1 else 0 end),0) as March,
isnull(sum(case when datepart(mm,outdutydate)='4' then 1 else 0 end),0) as April,
isnull(sum(case when datepart(mm,outdutydate)='5' then 1 else 0 end),0) as May, 
isnull(sum(case when datepart(mm,outdutydate)='6' then 1 else 0 end),0) as June, 
isnull(sum(case when datepart(mm,outdutydate)='7' then 1 else 0 end),0) as July, 
isnull(sum(case when datepart(mm,outdutydate)='8' then 1 else 0 end),0) as August , 
isnull(sum(case when datepart(mm,outdutydate)='9' then 1 else 0 end),0) as September , 
isnull(sum(case when datepart(mm,outdutydate)='10' then 1 else 0 end),0) as October, 
isnull(sum(case when datepart(mm,outdutydate)='11' then 1 else 0 end),0) as November, 
isnull(sum(case when datepart(mm,outdutydate)='12' then 1 else 0 end),0) as December,
count(1) as YearTotal 
from (SELECT psncode, MIN(indutydate) AS indutydate, MAX(outdutydate) AS outdutydate
FROM HR_OA_MiddleDB..fld_ryxx AS r
WHERE (NOT EXISTS (SELECT id
                   FROM HR_OA_MiddleDB..fld_ryxx AS t
                   WHERE (r.psncode = psncode) AND (ISNULL(outdutydate, '') = ''))
) AND (ISNULL(psncode, '') <> '')
GROUP BY psncode)a where outdutydate>convert(datetime,'{0}') and outdutydate<convert(datetime,'{1}')";

            sql = sql.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            sql = string.Format(sql, first, last, first.Year);
            PageState.Add("YearView", DataHelper.QueryDictList(sql));

            string StructSql = @"with Temp
as
(select 
isnull(sum(case when isnull(datediff(mm,indutydate,outdutydate),0)<3 then 1 else 0 end),0) as Less3M,
isnull(sum(case when datediff(mm,indutydate,outdutydate)>=3 and datediff(mm,indutydate,outdutydate)<12 then 1 else 0 end),0) as F3Mto1Y,
isnull(sum(case when datediff(mm,indutydate,outdutydate)>=12 and datediff(mm,indutydate,outdutydate)<24 then 1 else 0 end),0) as F1Yto2Y,
isnull(sum(case when datediff(mm,indutydate,outdutydate)>=24 and datediff(mm,indutydate,outdutydate)<36 then 1 else 0 end),0) as F2Yto3Y,
isnull(sum(case when datediff(mm,indutydate,outdutydate)>=36 and datediff(mm,indutydate,outdutydate)<60 then 1 else 0 end),0) as F3Yto5Y,
isnull(sum(case when datediff(mm,indutydate,outdutydate)>=60 and datediff(mm,indutydate,outdutydate)<84 then 1 else 0 end),0) as F5Yto7Y,
isnull(sum(case when datediff(mm,indutydate,outdutydate)>=84 then 1 else 0 end),0) as Greater7Y,
count(1) as Total
from
(SELECT psncode, MIN(indutydate) AS indutydate, MAX(outdutydate) AS outdutydate
FROM HR_OA_MiddleDB..fld_ryxx AS r
WHERE (NOT EXISTS (SELECT id
                   FROM HR_OA_MiddleDB..fld_ryxx AS t
                   WHERE (r.psncode = psncode) AND (ISNULL(outdutydate, '') = ''))
) AND (ISNULL(psncode, '') <> '')
GROUP BY psncode)a where outdutydate>convert(datetime,'{0}') and outdutydate<convert(datetime,'{1}'))

select * from (
select '人数' as Tit,Less3M,F3Mto1Y,F1Yto2Y,F2Yto3Y,F3Yto5Y,F5Yto7Y,Greater7Y,Total  from Temp
union
select '结构比例' as Tit,
convert(decimal(18,2),Less3M/convert(float,Total)*100) as Less3M,
convert(decimal(18,2),F3Mto1Y/convert(float,Total)*100) as F3Mto1Y,
convert(decimal(18,2),F1Yto2Y/convert(float,Total)*100 )as F1Yto2Y,
convert(decimal(18,2),F2Yto3Y/convert(float,Total)*100 )as F2Yto3Y,
convert(decimal(18,2),F3Yto5Y/convert(float,Total)*100) as F3Yto5Y,
convert(decimal(18,2),F5Yto7Y/convert(float,Total)*100 )as F5Yto7Y,
convert(decimal(18,2),Greater7Y/convert(float,Total)*100) as Greater7Y,
'100' as Total from Temp where Total!=0
union
select '结构比例' as Tit,0 as Less3M, 0 as F3Mto1Y,0 as F1Yto2Y,0 as F2Yto3Y,0 as F3Yto5Y,0 as F5Yto7Y,0 as Greater7Y,0 as Total from Temp where Total=0)a order by Tit desc
";
            StructSql = StructSql.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            StructSql = string.Format(StructSql, first, last);
            PageState.Add("StructView", DataHelper.QueryDictList(StructSql));


        }


        private IList<EasyDictionary> GetPageData(String sql, SearchCriterion search)
        {
            SearchCriterion.RecordCount = DataHelper.QueryValue<int>("select count(*) from (" + sql + ") t");
            string order = search.Orders.Count > 0 ? search.Orders[0].PropertyName : "CreateTime";
            string asc = search.Orders.Count <= 0 || !search.Orders[0].Ascending ? " desc" : " asc";
            string pageSql = @"
		    WITH OrderedOrders AS
		    (SELECT *,
		    ROW_NUMBER() OVER (order by {0} {1})as RowNumber
		    FROM ({2}) temp ) 
		    SELECT * 
		    FROM OrderedOrders 
		    WHERE RowNumber between {3} and {4}";
            pageSql = string.Format(pageSql, order, asc, sql, (search.CurrentPageIndex - 1) * search.PageSize + 1, search.CurrentPageIndex * search.PageSize);
            IList<EasyDictionary> dicts = DataHelper.QueryDictList(pageSql);
            return dicts;
        }
    }
}

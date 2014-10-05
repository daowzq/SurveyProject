using System;
using System.Collections.Generic;
using System.Collections;
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
using NHibernate.Criterion;
using System.Data;
using Aspose.Cells;
namespace Aim.Examining.Web.SurveyManage
{
    public partial class WGMTest : BaseListPage
    {

        public WGMTest()
        {
            this.IsCheckLogon = false;
        }
        protected void Page_Load(object sender, EventArgs e)
        {

            //            DataTable Dt = DataHelper.QueryDataTable(sql);
            //string sql = @" select min(Corp) As Corp 
            //	                                from FL_Culture..SummarySurvey_detail 
            //                                 where surveyid='7296036a-3fdf-456e-a08b-6e26a699e4b4'
            //                                 group by UserId";

            string CorpStr = @"江苏富智国际贸易有限公司,
                                昆山综合保税区物流中心有限公司,
                                江苏飞力达国际物流股份有限公司苏州分公司,
                                江苏飞力达国际物流股份有限公司,
                                苏州飞力达现代物流有限公司,
                                江苏飞力达国际物流股份有限公司吴江分公司,
                                江苏飞力达国际物流股份有限公司无锡分公司,
                                宁波飞力达仓储服务有限公司,
                                昆山飞力仓储服务有限公司,
                                淮安飞力供应链管理有限公司,
                                上海飞力达仓储有限公司,
                                飞力达物流(深圳)有限公司,
                                江苏飞力达国际物流股份有限公司常州分公司,
                                昆山飞力宇宏航空货运有限公司,
                                江苏飞力达国际物流股份有限公司上海分公司,
                                重庆飞力达供应链管理有限公司,
                                江苏飞力达国际物流股份有限公司太仓分公司";
            string[] CorpArr = CorpStr.Split(',');
            string DeptStr = @"财务管理中心,信息管理中心,综合管理中心,物流研发中心,物流事业部,
                               法务稽核部,营销服务中心,人力资源中心,海运事业部,空运事业部,商业发展部";
            string[] DeptArr = DeptStr.Split(',');


        }

        protected DataTable ExcelToDataTable(string ExcelPath)
        {
            Cells cells;
            Workbook workbook = new Workbook();
            workbook.Open(ExcelPath);
            cells = workbook.Worksheets[0].Cells;

            DataTable dtnew = new DataTable("dtnew");//创建数据表
            //auto fit columns
            for (int i = 0; i < cells.MaxDataColumn; i++)
            {
                dtnew.Columns.Add(new DataColumn(cells[i].Name));
            }

            DataRow dr;
            for (int k = 1; k < cells.MaxDataRow + 1; k++)
            {
                dr = dtnew.NewRow();
                for (int j = 0; j < cells.MaxDataColumn + 1; j++)
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

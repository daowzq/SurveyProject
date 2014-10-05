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
using System.Data;
using System.Data.OleDb;
using System.IO;
namespace Aim.Examining.Web.EmpWelfare
{
    public partial class ExcelInput : ExamBasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            WelfareConfig ent = null;
            switch (RequestActionString)
            {
                case "Save":
                    DoSave();
                    break;
                case "Update":
                    DoUpdate();
                    break;
                default:
                    //if (RequestActionString == "GetAusrId")
                    //{
                    //    string CoupleAcceptUsrId = RequestData.Get("CoupleAcceptUsrId") + "";
                    //    ComUtility Ut = new ComUtility();
                    //    this.PageState.Add("GetAusrId", Ut.GetWorkNo(CoupleAcceptUsrId));
                    //}
                    DoSelect();
                    break;
            }
        }


        private void DoUpdate()
        {
            WelfareConfig ent = this.GetMergedData<WelfareConfig>();
            ent.DoUpdate();
        }

        private void DoSave()
        {
            WelfareConfig ent = this.GetPostedData<WelfareConfig>();
            ent.DoCreate();
            this.PageState.Add("Id", ent.Id);
            //string CouponCost = this.RequestData.Get("CouponCost") + "";
            //string MarryCheckCost = this.RequestData.Get("MarryCheckCost") + "";
            //string NoMarryCheckCost = this.RequestData.Get("NoMarryCheckCost") + "";
            //WelfareConfig Ent = new WelfareConfig();
            //Ent.CouponCost = decimal.Parse(CouponCost);
            //Ent.MarryCheckCost = decimal.Parse(MarryCheckCost);
            //Ent.NoMarryCheckCost = decimal.Parse();
        }

        //
        private void DoSelect()
        {
            string SQL = @"select  top 1 * from  FL_Culture..WelfareConfig";

            var Ent = DataHelper.QueryDataTable(SQL);
            if (Ent != null)
            {
                this.SetFormData(new
                {
                    Id = Ent.Rows[0]["Id"],
                    CouponCost = Ent.Rows[0]["CouponCost"],
                    MarryCheckCost = Ent.Rows[0]["MarryCheckCost"],
                    NoMarryCheckCost = Ent.Rows[0]["NoMarryCheckCost"],

                    CoupleAcceptUsrId = Ent.Rows[0]["CoupleAcceptUsrId"],
                    CoupleAcceptUsrName = Ent.Rows[0]["CoupleAcceptUsrName"],
                    ChildAcceptUsrId = Ent.Rows[0]["ChildAcceptUsrId"],
                    ChildAcceptName = Ent.Rows[0]["ChildAcceptName"],

                    TravelAcceptUsrId = Ent.Rows[0]["TravelAcceptUsrId"],
                    TravelAcceptUsrName = Ent.Rows[0]["TravelAcceptUsrName"],
                    HealthyAcceptUsrId = Ent.Rows[0]["HealthyAcceptUsrId"],
                    HealthyAcceptUsrName = Ent.Rows[0]["HealthyAcceptUsrName"],
                    WomanAcceptUsrId = Ent.Rows[0]["WomanAcceptUsrId"],
                    WomanAcceptUsrName = Ent.Rows[0]["WomanAcceptUsrName"]
                });
            }
        }

        private void DoImpUser()
        {
            string FileName = RequestData.Get("FileId") + "";
            string SurveyId = RequestData.Get("SurveyId") + "";
            string InputType = RequestData.Get("InputType") + "";     //导入的类型   

            FileName = MapPath("/Document/") + FileName;
            ComUtility Ut = new ComUtility();
            DataTable dt = Ut.ExcelToDataTable(FileName);
        }


    }
}

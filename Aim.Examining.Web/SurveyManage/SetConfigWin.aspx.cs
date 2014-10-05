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

namespace Aim.Examining.Web.SurveyManage
{
    public partial class SetConfigWin : BaseListPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (RequestActionString)
            {
                default:
                    DoSelect();
                    break;
            }
        }

        private void DoSelect()
        {
            personTypeEnum();
            string SurveyId = RequestData.Get("SurveyId") + "";
            if (!string.IsNullOrEmpty(SurveyId))
            {
                var Ent = SurveyQuestion.Find(SurveyId);
                string rObj = (Ent.ReaderObj + "").Trim(',').Replace("sender", "问卷发起者").Replace("joiner", "问卷参与者");
                string wWay = (Ent.NoticeWay + "").Trim(',').Replace("Message", "短信").Replace("Email", "邮件");
                string rWay = (Ent.RemindWay + "").Trim(',').Replace("Message", "短信").Replace("Email", "邮件");
                //是否流程审批
                string ISCheck = string.Empty;
                if (!string.IsNullOrEmpty(Ent.SurveyTypeId))
                {
                    try
                    {
                        var SType = Model.SurveyType.Find(Ent.SurveyTypeId);
                        if ((SType.MustCheckFlow + "").Contains("1")) ISCheck = "是 ";
                        else
                            ISCheck = "否 ";
                        if (!string.IsNullOrEmpty(SType.ApproveRoleName))
                            ISCheck += " 审批最高层级为:" + SType.ApproveRoleName;
                    }
                    catch
                    {
                        ISCheck = "";
                    }
                }

                object Obj = new
                {
                    ISCheck = ISCheck,
                    ReaderObj = rObj,
                    Score = Ent.Score,
                    NoticeWay = wWay,
                    RemindWay = rWay,
                    SetTimeout = Ent.SetTimeout,
                    RecyleDay = Ent.RecyleDay,
                    TimePoint = Ent.TimePoint
                };
                this.SetFormData(Obj);
                this.PageState.Add("SurveyedObj", DataHelper.QueryDictList("select * from FL_Culture..SurveyedObj where surveyid='" + SurveyId + "'"));
            }
        }

        //人员类别
        private void personTypeEnum()
        {
            //string sql = @"select pk_fld_rylb Value,psnclassname Name
            //  from HR_OA_MiddleDB..fld_rylb where patIndex('%'+psnclassname+'%','正式工临时工实习生其他人员' )>0 ";
            string sql = @"select pk_fld_rylb Value,psnclassname Name
                            from HR_OA_MiddleDB..fld_rylb where patIndex('%'+psnclassname+'%','正式工临时工实习生其他人员' )>0 ";
            sql = sql.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            this.PageState.Add("personTypeEnum", DataHelper.QueryDictList(sql));
        }
    }
}

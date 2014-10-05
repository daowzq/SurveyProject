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

namespace Aim.Examining.Web.SurveyManage
{
    public partial class Wizard_Three : BaseListPage
    {
        string op = String.Empty;           // 用户编辑操作
        string SurveyId = String.Empty;     // 对象id
        string type = String.Empty;         // 对象类型
        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op");
            SurveyId = RequestData.Get<string>("SurveyId");
            type = RequestData.Get<string>("type");

            string AllowUser = RequestData.Get("AllowUser") + "";       // 允许人员
            string NoAllowUser = RequestData.Get("NoAllowUser") + "";   // 排除人员

            SurveyReaderObj ent = null;

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<SurveyReaderObj>();
                    if (!string.IsNullOrEmpty(AllowUser)) ent.AllowUser = AllowUser;
                    if (!string.IsNullOrEmpty(NoAllowUser)) ent.NoAllowUser = NoAllowUser;
                    ent.DoUpdate();
                    break;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<SurveyReaderObj>();
                    if (!string.IsNullOrEmpty(AllowUser)) ent.AllowUser = AllowUser;
                    if (!string.IsNullOrEmpty(NoAllowUser)) ent.NoAllowUser = NoAllowUser;
                    ent.DoCreate();
                    this.PageState.Add("Id", ent.Id);//回写ID
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<SurveyReaderObj>();
                    ent.DoDelete();
                    break;
            }

            if (op != "c" && op != "cs")
            {
                if (!String.IsNullOrEmpty(SurveyId))
                {
                    ent = SurveyReaderObj.FindFirstByProperties(SurveyedObj.Prop_SurveyId, SurveyId);
                    if (ent != null)
                    {
                        this.PageState.Add("DataList", ent.AllowUser);
                        this.PageState.Add("DataList1", ent.NoAllowUser);
                    }
                }

                this.SetFormData(ent);
            }
        }
    }
}

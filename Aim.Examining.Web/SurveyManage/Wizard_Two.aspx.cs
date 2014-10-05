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
using System.Data;
using System.Text;
namespace Aim.Examining.Web.SurveyManage
{
    public partial class Wizard_Two : BaseListPage
    {

        string op = String.Empty;           // 用户编辑操作
        string SurveyId = String.Empty;     // 对象id
        string type = String.Empty;         // 对象类型

        protected void Page_Load(object sender, EventArgs e)
        {
            string RemoveUserNames = string.Empty;//排除人员
            string AddUserNames = string.Empty;   //添加人员
            string AgeRange = string.Empty;       //工作年限

            op = RequestData.Get<string>("op");
            SurveyId = RequestData.Get<string>("SurveyId");
            type = RequestData.Get<string>("type");
            RemoveUserNames = RequestData.Get("RemoveUserNames") + "";
            AddUserNames = RequestData.Get("AddUserNames") + "";
            AgeRange = RequestData.Get("AgeRange") + "";

            SurveyedObj ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<SurveyedObj>();
                    if (!string.IsNullOrEmpty(RemoveUserNames)) ent.RemoveUserNames = RemoveUserNames;
                    if (!string.IsNullOrEmpty(AddUserNames)) ent.AddUserNames = AddUserNames;
                    if (!string.IsNullOrEmpty(AgeRange)) ent.AgeRange = AgeRange;

                    ent.DoUpdate();
                    break;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<SurveyedObj>();
                    if (!string.IsNullOrEmpty(RemoveUserNames)) ent.RemoveUserNames = RemoveUserNames;
                    if (!string.IsNullOrEmpty(AddUserNames)) ent.AddUserNames = AddUserNames;
                    if (!string.IsNullOrEmpty(AgeRange)) ent.AgeRange = AgeRange;

                    ent.DoCreate();
                    this.PageState.Add("Id", ent.Id);  // 回填Id
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<SurveyedObj>();
                    ent.DoDelete();
                    break;
            }

            if (op != "c" && op != "cs")
            {
                if (!String.IsNullOrEmpty(SurveyId))
                {
                    ent = SurveyedObj.FindFirstByProperties(SurveyedObj.Prop_SurveyId, SurveyId);
                    if (ent != null)
                    {
                        this.PageState.Add("DataList", ent.AddUserNames);
                        this.PageState.Add("DataList1", ent.RemoveUserNames);
                    }
                }
                this.SetFormData(ent);
            }
        }

        /// <summary>
        ///默认选中的公司Id
        /// </summary>
        public string nodeId
        {
            get
            {
                string sql = @"select B.GroupID, B.Name from sysuser As A 
	                            left join Sysgroup As B
                              on A.Pk_corp=B.GroupID
	                            where A.UserID='{0}' ";
                sql = string.Format(sql, UserInfo.UserID);
                DataTable dt = DataHelper.QueryDataTable(sql);
                StringBuilder strb = new StringBuilder();
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    if (i > 0) strb.Append(",");
                    if (dt.Rows[i]["Name"].ToString().Contains("江苏飞力达国际物流股份有限公司")) 
                    {
                        strb.Remove(0, strb.Length);
                        break;
                    }
                    strb.Append(dt.Rows[i]["GroupID"].ToString());
                }

                return strb.ToString();
            }
        }

        /// <summary>
        /// 根据选项生成人员
        /// </summary>
        private void AnalyzingUser()
        {
            if (!string.IsNullOrEmpty(SurveyId))
            {
                StatisticsUser St = new StatisticsUser();
                bool bl = St.CreateSurveyedUser(SurveyId);
            }

        }
    }
}

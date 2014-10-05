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
    public partial class SurveyedHistory : BaseListPage
    {
        public SurveyedHistory()
        {
            IsCheckLogon = false;
        }

        protected void Page_Load(object sender, EventArgs e)
        {

            if (!string.IsNullOrEmpty(RequestData.Get("GetInfo") + "") && RequestData.Get("GetInfo") + "" == "1")
            {
                string SurveyId = this.RequestData.Get<string>("SurveyId");
                //var ResultEntList = SurveyedResult.FindAllByProperties(SurveyedResult.Prop_SurveyId, SurveyId, SurveyedResult.Prop_UserId, this.RequestData.Get<string>("UserId") + "");
                DataTable dt = DataHelper.QueryDataTable(" select * from FL_Culture..SurveyedResult where SurveyId='" + SurveyId + "' and UserId='" + this.RequestData.Get<string>("UserId") + "' ");
                this.Response.Write(JsonHelper.GetJsonStringFromDataTable(dt));
                this.Response.End();
            }
            else
            {
                GetCommitSurvey();
            }
        }
        private void GetCommitSurvey()
        {
            string SurveyId = this.RequestData.Get<string>("SurveyId");
            if (!string.IsNullOrEmpty(SurveyId))
            {
                if (!string.IsNullOrEmpty(this.RequestData.Get<string>("UserId")))
                {

                    SurveyCommitHistory Ent = SurveyCommitHistory.FindFirstByProperties(SurveyCommitHistory.Prop_SurveyId, SurveyId, SurveyCommitHistory.Prop_SurveyedUserId, this.RequestData.Get<string>("UserId"));
                    if (Ent != null)
                    {
                        string str = string.IsNullOrEmpty(Ent.CommitSurvey) ? "" : Ent.CommitSurvey;
                        try
                        {
                            int start = str.IndexOf("<SCRIPT type=text/javascript src=\"js/renderSurvey.js\"></SCRIPT>");
                            int end = str.IndexOf("</HEAD>");
                            str = str.Remove(start, end - start);
                            str = str.Replace("commit()", "");
                            str = str.Replace("cancel()", "");
                            Response.Write(str);
                        }
                        catch (Exception e)
                        {
                            Response.Write(str);
                        }
                    }
                }
                else
                {
                    SurveyCommitHistory Ent = SurveyCommitHistory.FindFirstByProperties(SurveyCommitHistory.Prop_SurveyId, SurveyId, SurveyCommitHistory.Prop_SurveyedUserId, UserInfo.UserID);
                    if (Ent != null)
                    {
                        string str = string.IsNullOrEmpty(Ent.CommitSurvey) ? "" : Ent.CommitSurvey;

                        int start = str.IndexOf("<SCRIPT type=text/javascript src=\"js/renderSurvey.js\"></SCRIPT>");
                        int end = str.IndexOf("</HEAD>");
                        str = str.Remove(start, end - start);
                        Response.Write(str);
                        // Response.Write(string.IsNullOrEmpty(Ent.CommitSurvey) ? "" : Ent.CommitSurvey);
                    }
                }

            }
            //Response.End();
        }
    }
}

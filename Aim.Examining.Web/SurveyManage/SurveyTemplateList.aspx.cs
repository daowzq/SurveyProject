using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Web.Script.Serialization;

using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using System.Text;
using System.Data;
using Aim.Examining.Web.Common;


namespace Aim.Examining.Web.SurveyManage
{
    public partial class SurveyTemplateList : BaseListPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (RequestActionString)
            {
                case "getGuid":
                    GetGuid();
                    break;
                case "batchdelete":
                    DoBatchDelete();
                    break;
                case "Start":
                    DoStart();
                    break;
                case "Stop":
                    DoStop();
                    break;
                case "Grant":
                    GrantTemplate();
                    break;
                default:
                    DoSelect();
                    break;
            }
        }


        private void GetGuid()
        {
            SurveyQuestion ent = new SurveyQuestion();
            ent.IsFixed = "1";

            UserContextInfo UC = new UserContextInfo();
            ent.CompanyId = UC.GetUserCurrentCorpId(UserInfo.UserID);//判断公司登陆

            string sql = @"select top 1 Name from SysGroup where GroupId='{0}' ";
            sql = string.Format(sql, ent.CompanyId);

            object obj = DataHelper.QueryValue(sql);
            if (obj != null) ent.CompanyName = obj.ToString();

            ent.State = "2";   //默认停用
            ent.DoCreate();
            this.PageState.Add("Guid", ent.Id);
        }

        /// <summary>
        /// 问卷模板授权
        /// </summary>
        private void GrantTemplate()
        {
            string Id = RequestData.Get("Id") + "";
            if (!string.IsNullOrEmpty(Id))
            {
                string GrantCorpId = RequestData.Get("GrantCorpId") + "";
                string GrantCorpName = RequestData.Get("GrantCorpName") + "";
                SurveyQuestion Ent = SurveyQuestion.Find(Id);
                Ent.GrantCorpId = GrantCorpId;
                Ent.GrantCorpName = GrantCorpName;
                Ent.DoUpdate();
                this.PageState.Add("State", "1");
            }
            else
            {
                this.PageState.Add("State", "0");
            }

        }
        //启用状态
        private void DoStart()
        {
            string id = RequestData.Get("id") + "";
            if (!string.IsNullOrEmpty(id))
            {
                var Ent = SurveyQuestion.Find(id);
                Ent.State = "1";  //start
                Ent.DoUpdate();
            }
        }

        //启用状态
        private void DoStop()
        {
            string id = RequestData.Get("id") + "";
            if (!string.IsNullOrEmpty(id))
            {
                var Ent = SurveyQuestion.Find(id);
                Ent.State = "2";  //start
                Ent.DoUpdate();
            }
        }

        private void DoSelect()
        {

            CommPowerSplit ps = new CommPowerSplit();

            if (ps.IsSurveyRole(UserInfo.UserID, UserInfo.LoginName))
            {
                this.PageState.Add("IsCanGrant", "1");
                SearchCriterion.SetSearch("IsFixed", "1");  //
                SurveyQuestion[] Ents = SurveyQuestion.FindAll(SearchCriterion);
                this.PageState.Add("DataList", Ents);

            }
            else
            {
                string SQL = @"select  * from  SysRole  As A
	                         inner join  SysUserRole As B
                           on  A.RoleID=B.RoleID  
                            where A.Code='PubSurvey' and B.UserId='{0}'";
                SQL = string.Format(SQL, UserInfo.UserID);
                object obj = DataHelper.QueryValue(SQL);
                if (obj == null)
                {
                    if (Session["CompanyId"] != null)
                    {
                        string CorpId = Session["CompanyId"].ToString();
                        CorpId = !string.IsNullOrEmpty(CorpId) ? CorpId : "1007";
                        SearchCriterion.SetSearch("CompanyId", CorpId);
                    }
                }
                SearchCriterion.SetSearch("IsFixed", "1");  //
                SurveyQuestion[] Ents = SurveyQuestion.FindAll(SearchCriterion);
                this.PageState.Add("DataList", Ents);
            }

        }


        [ActiveRecordTransaction]
        private void DoBatchDelete()
        {
            IList<object> idList = RequestData.GetList<object>("IdList");

            if (idList != null && idList.Count > 0)
            {
                SurveyQuestion.DoBatchDelete(idList.ToArray());

                foreach (var v in idList.ToArray())
                {
                    string sql = @" delete from FL_Culture..QuestionAnswerItem where surveyid='{0}';
                                    delete from FL_Culture..QuestionItem where surveyid='{0}' ";
                    sql = string.Format(sql, v.ToString());
                    DataHelper.ExecSql(sql);
                }
            }
        }

    }
}

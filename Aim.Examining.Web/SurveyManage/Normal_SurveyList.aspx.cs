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
    public partial class Normal_SurveyList : BaseListPage
    {
        public string IP = string.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            IP = Request.ServerVariables.Get("Server_Name").ToString();
            string Id = RequestData.Get("Id") + "";
            switch (RequestActionString)
            {
                case "getGuid":
                    GetGuid();
                    break;
                case "batchdelete":
                    DoBatchDelete();
                    break;
                case "Start":   //启用
                    if (!string.IsNullOrEmpty(Id))
                    {
                        var SQEnt = SurveyQuestion.Find(Id);
                        if (SQEnt != null)
                        {
                            SQEnt.State = "1";
                            SQEnt.DoUpdate();
                        }
                    }
                    break;
                case "stop":  //停用
                    if (!string.IsNullOrEmpty(Id))
                    {
                        var SQEnt = SurveyQuestion.Find(Id);
                        if (SQEnt != null)
                        {
                            SQEnt.State = "2";
                            SQEnt.DoUpdate();
                        }
                    }
                    break;
                case "SetOARef":
                    SetOARef();
                    break;
                default:
                    DoSelect();
                    break;
            }
        }


        /// <summary>
        /// 与OA单据关联
        /// </summary>
        private void SetOARef()
        {
            string SurveyId = RequestData.Get("SurveyId") + "";
            string Value = RequestData.Get("Value") + "";

            // SearchCriterion.AddSearch("CompanyId", CompanyId);  //公司后续使用
            SurveyQuestion[] Ents = SurveyQuestion.FindAllByProperties("IsFixed", "2");
            string state = string.Empty;
            foreach (var v in Ents)
            {
                if (v.Id == SurveyId)
                {
                    v.OARef = Value;
                    state = "1";
                }
                else
                {
                    v.OARef = "";
                }
                v.DoUpdate();
            }
            this.PageState.Add("State", state);
        }



        private void GetGuid()
        {
            SurveyQuestion ent = new SurveyQuestion();
            ent.IsFixed = "2";  //固定问卷标志

            UserContextInfo UC = new UserContextInfo();
            ent.CompanyId = UC.GetUserCurrentCorpId(UserInfo.UserID);

            string sql = @"select top 1 Name from SysGroup where GroupId='{0}' ";
            sql = string.Format(sql, ent.CompanyId);
            object obj = DataHelper.QueryValue(sql);
            if (obj != null) ent.CompanyName = obj.ToString();

            ent.DoCreate();
            this.PageState.Add("Guid", ent.Id);
        }

        private void DoSelect()
        {
            CommPowerSplit ps = new CommPowerSplit();
            if (ps.IsSurveyRole(UserInfo.UserID, UserInfo.LoginName))
            {
                SearchCriterion.SetSearch("IsFixed", "2");  //固定问卷
                SurveyQuestion[] Ents = SurveyQuestion.FindAll(SearchCriterion);
                this.PageState.Add("DataList", Ents);
            }
            else
            {
                SearchCriterion.SetSearch("IsFixed", "2");  //固定问卷
                string CompanyId = string.Empty;            //公司ID

                //first depend login corpid  
                var Ent = SysUser.Find(UserInfo.UserID);
                UserContextInfo UC = new UserContextInfo();
                CompanyId = UC.GetUserCurrentCorpId(UserInfo.UserID);

                SearchCriterion.AddSearch("CompanyId", CompanyId);
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

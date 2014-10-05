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
using System.Data.OleDb;
using System.Data;
using System.IO;
using System.Text;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class Tab_ReadUser : BaseListPage
    {

        public Tab_ReadUser()
        {
            SearchCriterion.PageSize = 40;
        }
        string SurveyId = string.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            SurveyId = RequestData.Get("SurveyId") + "";
            switch (RequestActionString)
            {
                case "Save":
                    DoSave();
                    break;
                case "batchdelete":
                    DoBatchDelete();
                    break;
                default:
                    DoSelect();
                    break;
            }
        }

        private void DoSelect()
        {
            if (!string.IsNullOrEmpty(SurveyId))
            {
                SearchCriterion.SetSearch("SurveyId", SurveyId);
                SearchCriterion.SetOrder("CreateWay");
                SurveyCanReaderUsr[] SrEnt = SurveyCanReaderUsr.FindAll(SearchCriterion);
                this.PageState.Add("DataList2", SrEnt);
            }
        }

        [ActiveRecordTransaction]
        private void DoBatchDelete()
        {
            IList<object> idList = RequestData.GetList<object>("IdList");

            if (idList != null && idList.Count > 0)
            {
                SurveyCanReaderUsr.DoBatchDelete(idList.ToArray());
            }
        }
        //保存
        private void DoSave()
        {
            if (!String.IsNullOrEmpty(SurveyId))
            {
                IList<SurveyCanReaderUsr> Ent = RequestData.GetList<object>("Record").Select(ten => { return JsonHelper.GetObject<SurveyCanReaderUsr>(ten.ToString()); }).ToArray();

                string SQL = "delete from FL_Culture..SurveyCanReaderUsr where '{0}' like '%'+ UserId+'%' Or '{1}' like '%'+ WorkNo+'%' ";
                StringBuilder UserId = new StringBuilder();
                StringBuilder WorkNo = new StringBuilder();
                for (int i = 0; i < Ent.Count; i++)
                {
                    UserId.Append(Ent[i].UserId);
                    WorkNo.Append(Ent[i].WorkNo);
                }
                SQL = string.Format(SQL, UserId, WorkNo);
                DataHelper.ExecSql(SQL);
                foreach (var ent in Ent)
                {
                    ent.SurveyId = SurveyId;
                    ent.DoCreate();
                }
            }
        }

    }
}

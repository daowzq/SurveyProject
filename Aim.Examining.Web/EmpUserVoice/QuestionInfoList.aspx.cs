using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Castle.ActiveRecord;
using NHibernate;
using NHibernate.Criterion;
using Aim.Data;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;
using Aim.Examining.Model;

namespace Aim.Examining.Web
{
    public partial class QuestionInfoList : ExamListPage
    {

        private IList<EmpVoiceAskQuestion> ents = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            EmpVoiceAskQuestion ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<EmpVoiceAskQuestion>();
                    ent.DoDelete();
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        DoBatchDelete();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }

        }



        #region 私有方法

        /// <summary>
        /// 查询
        /// </summary>
        private void DoSelect()
        {
            SearchCriterion.SetSearch("CreateId", UserInfo.UserID);
            SearchCriterion.SetOrder("CreateTime", false);
            ents = EmpVoiceAskQuestion.FindAll(SearchCriterion);
            this.PageState.Add("DataList", ents);
            this.PageState.Add("QuestionEnum", SysEnumeration.GetEnumDict("QuestionType"));

        }

        /// <summary>
        /// 批量删除
        /// </summary>
        [ActiveRecordTransaction]
        private void DoBatchDelete()
        {
            IList<object> idList = RequestData.GetList<object>("IdList");

            if (idList != null && idList.Count > 0)
            {
                EmpVoiceAskQuestion.DoBatchDelete(idList.ToArray());
            }
           

        }

        #endregion
    }
}


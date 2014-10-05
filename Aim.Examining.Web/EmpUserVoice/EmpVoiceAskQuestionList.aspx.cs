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
    public partial class EmpVoiceAskQuestionList : ExamListPage
    {
        #region 变量

        private IList<EmpVoiceAskQuestion> ents = null;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            EmpVoiceAskQuestion ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<EmpVoiceAskQuestion>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        DoBatchDelete();
                    }
                    else if (RequestActionString == "ischeck")
                    {
                        Ischeck();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }

        }

        #endregion

        #region 私有方法

        /// <summary>
        /// 查询
        /// </summary>
        private void DoSelect()
        {
            ents = EmpVoiceAskQuestion.FindAll(SearchCriterion);
            this.PageState.Add("EmpVoiceAskQuestionList", ents);
        }

        //审核
        private void Ischeck()
        {
            string id = RequestData.Get<string>("thisid");
            string typ = RequestData.Get<string>("typ");
            string sql = "update FL_Culture..EmpVoiceAskQuestion set IsCheck='" + typ + "' where Id='" + id + "'";
            DataHelper.ExecSql(sql);
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


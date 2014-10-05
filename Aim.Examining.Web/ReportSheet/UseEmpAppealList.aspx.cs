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
using System.Text;

namespace Aim.Examining.Web.ReportSheet
{
    public partial class UseEmpAppealList : ExamListPage
    {

        private IList<UsrAppealList> ents = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            UsrAppealList ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<UsrAppealList>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
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


        /// <summary>
        /// 查询
        /// </summary>
        private void DoSelect()
        {
            EasyDictionary dic = SysEnumeration.GetEnumDict("EmpAppeal");
            dic.Add("%%", "请选择...");
            PageState.Add("AppealTypeName", dic);


            //问卷角色或管理员
            CommPowerSplit Role = new CommPowerSplit();
            if (Role.IsAppealRole(UserInfo.UserID, UserInfo.LoginName))
            {
                ents = UsrAppealList.FindAll(SearchCriterion);
                this.PageState.Add("UsrAppealListList", ents);
            }
            else
            {
                StringBuilder strb = new StringBuilder();
                if (Session["CompanyId"] != null)           //判断公司登陆
                {
                    SearchCriterion.SetSearch(UsrAppealList.Prop_CompanyId, Session["CompanyId"]);
                    ents = UsrAppealList.FindAll(SearchCriterion);
                    this.PageState.Add("UsrAppealListList", ents);
                }
                else
                {
                    var UsrEnt = SysUser.Find(UserInfo.UserID);
                    SearchCriterion.SetSearch(UsrAppealList.Prop_CompanyId, UsrEnt.Pk_corp);
                    ents = UsrAppealList.FindAll(SearchCriterion);
                    this.PageState.Add("UsrAppealListList", ents);
                }
            }
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
                UsrAppealList.DoBatchDelete(idList.ToArray());
            }
        }

    }
}

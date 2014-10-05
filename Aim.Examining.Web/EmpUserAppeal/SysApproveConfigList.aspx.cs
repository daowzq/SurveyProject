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
using System.Net;

namespace Aim.Examining.Web
{
    public partial class SysApproveConfigList : ExamListPage
    {
        #region 变量

        private IList<SysApproveConfig> ents = null;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {

            SysApproveConfig ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<SysApproveConfig>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        DoBatchDelete();
                    }
                    else if (RequestActionString == "batchsave")
                    {

                        btnSave();

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
            ents = SysApproveConfig.FindAll(SearchCriterion);
            this.PageState.Add("SysApproveConfigList", ents);
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
                SysApproveConfig.DoBatchDelete(idList.ToArray());
            }
        }

        #endregion

        private void btnSave()
        {
            IList<string> entStrList = RequestData.GetList<string>("data");

            if (entStrList != null && entStrList.Count > 0)
            {
                IList<SysApproveConfig> ents = entStrList.Select(tent => JsonHelper.GetObject<SysApproveConfig>(tent) as SysApproveConfig).ToList();

                foreach (SysApproveConfig ent in ents)
                {
                    if (ent != null)
                    {
                        SysApproveConfig tent = ent;

                        if (String.IsNullOrEmpty(tent.Id))
                        {
                            tent.CreateId = UserInfo.UserID;
                            tent.CreateName = UserInfo.Name;

                        }
                        else
                        {
                            tent = DataHelper.MergeData(SysApproveConfig.Find(tent.Id), tent);
                        }

                        tent.DoSave();
                    }
                }
            }
        }
    }

}










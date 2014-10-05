using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using NHibernate;
using NHibernate.Criterion;
using Aim.Data;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;


namespace Aim.Portal.Web
{
    public partial class SysMessageList : BaseListPage
    {
        #region 属性

        #endregion

        #region 变量

        private SysMessage[] ents = null;

        protected string TypeId = string.Empty;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            TypeId = RequestData.Get<string>("TypeId");

            if (!String.IsNullOrEmpty(TypeId))
            {
                ICriterion crit = null;
                if (TypeId == "Send")
                {
                    SearchCriterion.AddSearch("SenderId", this.UserInfo.UserID, SearchModeEnum.Like);
                    crit = Expression.Or(Expression.Eq("IsSenderDelete", false), Expression.IsNull("IsSenderDelete"));
                }
                else
                {
                    SearchCriterion.AddSearch("ReceiverId", this.UserInfo.UserID, SearchModeEnum.Like);
                    crit = Expression.Or(Expression.Eq("IsReceiverDelete", false), Expression.IsNull("IsReceiverDelete"));
                }

                SearchCriterion.SetOrder("SendTime", false);
                ents = SysMessageRule.FindAll(SearchCriterion, crit);

                this.PageState.Add("SysMessageList", ents);
            }

            SysMessage ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<SysMessage>();
                    ent.DoCreate();
                    this.SetMessage("新建成功！");
                    break;
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<SysMessage>();
                    ent.DoUpdate();
                    this.SetMessage("保存成功！");
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<SysMessage>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                case RequestActionEnum.Custom:
                    IList<object> ids = RequestData.GetList<object>("Ids");

                    if (ids != null && ids.Count > 0)
                    {
                        if (RequestActionString == "batchdelete")
                        {
                            SysMessage[] tents = SysMessage.FindAll(Expression.In("Id", ids.ToList()));

                            foreach (SysMessage tent in tents)
                            {
                                if (TypeId == "Send")
                                {
                                    tent.IsSenderDelete = true;
                                }
                                else
                                {
                                    tent.IsReceiverDelete = true;
                                }

                                tent.DoDelete();
                            }
                        }
                    }
                    break;
            }
        }

        #endregion

        #region 私有方法

        #endregion
    }
}


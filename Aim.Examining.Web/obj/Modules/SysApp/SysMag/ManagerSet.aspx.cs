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

namespace Aim.Examining.Web.Modules.SysApp.SysMag
{
    public partial class ManagerSet : BaseListPage
    {

        public ManagerSet()
        {
            SearchCriterion.DefaultPageSize = 80;  //默认数据
        }
        private IList<Model.ManagementGroup> ents = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            Model.ManagementGroup ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<Model.ManagementGroup>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        DoDelete();
                    }
                    else if (RequestActionString == "batchsave")
                    {
                        DoBatchSave();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }
        }



        /// <summary>
        /// 批量保存
        /// </summary>
        [ActiveRecordTransaction]
        private void DoBatchSave()
        {
            IList<string> entStrList = RequestData.GetList<string>("data");
            if (entStrList != null && entStrList.Count > 0)
            {
                IList<Model.ManagementGroup> ents = entStrList.Select(tent => JsonHelper.GetObject<Model.ManagementGroup>(tent) as Model.ManagementGroup).ToList();

                foreach (Model.ManagementGroup ent in ents)
                {
                    if (ent != null)
                    {
                        Model.ManagementGroup tent = ent;
                        if (String.IsNullOrEmpty(ent.Id))
                        {
                            ent.CreateId = UserInfo.UserID;
                            ent.CreateName = UserInfo.Name;
                            ent.CreateTime = DateTime.Now;
                        }
                        else
                        {
                            tent = DataHelper.MergeData(Model.ManagementGroup.Find(tent.Id), tent);
                        }
                        tent.DoSave();
                    }
                }
            }
        }

        /// <summary>
        /// 查询
        /// </summary>
        private void DoSelect()
        {
            SearchCriterion.SetOrder("SortIndex", true);
            ents = Model.ManagementGroup.FindAll(SearchCriterion);
            this.PageState.Add("DataList", ents);
        }

        //删除
        public void DoDelete()
        {
            IList<object> idList = RequestData.GetList<object>("IdList");

            if (idList != null && idList.Count > 0)
            {
                ManagementGroup.DoBatchDelete(idList.ToArray());
            }
        }

    }
}

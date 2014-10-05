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
namespace Aim.Examining.Web.CommonPages
{
    public partial class ManagerDetail : BaseListPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (RequestActionString)
            {
                case "BachDelete":
                    DoBatchDelete();
                    break;
                case "BatchSave":
                    DoBatchSave();
                    break;
                case "DoSave":
                    DoSave();
                    break;
                default:
                    DoSelect();
                    break;
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
                Model.ManagementInfo.DoBatchDelete(idList.ToArray());
            }
        }


        /// <summary>
        /// 保存
        /// </summary>
        private void DoSave()
        {
            string PId = RequestData.Get("PId") + "";
            IList<string> DataList = RequestData.GetList<string>("dt");
            if (DataList.Count > 0)
            {
                IList<ManagementInfo> qiEnts = DataList.Select(tent => JsonHelper.GetObject<ManagementInfo>(tent) as ManagementInfo).ToArray();
                qiEnts[0].PId = PId;
                if (!string.IsNullOrEmpty(qiEnts[0].Id))
                {
                    qiEnts[0].CreateId = UserInfo.UserID;
                    qiEnts[0].CreateTime = DateTime.Now;
                    qiEnts[0].CreateName = UserInfo.LoginName;
                }
                qiEnts[0].DoSave();
                this.PageState.Add("Id", qiEnts[0].Id);
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
                IList<ManagementInfo> ents = entStrList.Select(tent => JsonHelper.GetObject<ManagementInfo>(tent) as ManagementInfo).ToList();

                foreach (ManagementInfo ent in ents)
                {
                  
                    //if (ent != null)
                    //{
                    //    Model.ManagementInfo tent = ent;
                    //    if (String.IsNullOrEmpty(ent.Id))
                    //    {
                    //        ent.CreateId = UserInfo.UserID;
                    //        ent.CreateName = UserInfo.Name;
                    //        ent.CreateTime = DateTime.Now;
                    //    }
                    //    else
                    //    {
                    //        tent = DataHelper.MergeData(Model.ManagementInfo.Find(tent.Id), tent);
                    //    }
                    //tent.DoSave();
                    //}
                    ent.DoSave();
                }
            }
        }
        /// <summary>
        /// default
        /// </summary>
        private void DoSelect()
        {
            string PId = RequestData.Get("PId") + "";
            if (!string.IsNullOrEmpty(PId))
            {
                //ManagementInfo.Prop_PId, PId);
                SearchCriterion.AddSearch("PId", PId);
                SearchCriterion.SetOrder(ManagementInfo.Prop_CreateTime, false);
                var Ents = ManagementInfo.FindAll(SearchCriterion);
                this.PageState.Add("DataList", Ents);
            }
        }

    }
}

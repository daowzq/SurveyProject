using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;

namespace Aim.Examining.Web
{
    public partial class ManagementGroupEdit : ExamBasePage
    {

        string op = String.Empty; // 用户编辑操作
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 对象类型
        ManagementGroup ent = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op");
            id = RequestData.Get<string>("id");
            type = RequestData.Get<string>("type");

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    DoUpdate();
                    break;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    DoCreate();
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<ManagementGroup>();
                    ent.DoDelete();
                    return;
                default:
                    DoSelect();
                    break;
            }

        }


        private void DoUpdate()
        {
            string OrgEns = RequestData.Get("OrgEnts") + "";
            ent = this.GetMergedData<ManagementGroup>();
            if (!string.IsNullOrEmpty(OrgEns)) ent.GroupsSet = OrgEns;
            ent.DoUpdate();
        }

        private void DoCreate()
        {
            string OrgEns = RequestData.Get("OrgEnts") + "";
            ent = this.GetPostedData<ManagementGroup>();
            if (!string.IsNullOrEmpty(OrgEns)) ent.GroupsSet = OrgEns;
            ent.DoCreate();

        }

        private void DoSelect()
        {
            if (op != "c" && op != "cs")
            {
                if (!String.IsNullOrEmpty(id))
                {
                    ent = ManagementGroup.Find(id);
                    this.PageState.Add("DataList", ent.GroupsSet);  // 组织结构
                }

                this.SetFormData(ent);
            }
        }


    }
}


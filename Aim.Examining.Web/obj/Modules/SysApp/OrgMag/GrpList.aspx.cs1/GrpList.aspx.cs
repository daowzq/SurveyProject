using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Web.Script.Serialization;

using Aim.Data;
using Aim.Common;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;


namespace Aim.Portal.Web.Modules.SysApp.OrgMag
{
    public partial class GrpList : BasePage
    {


        private SysGroup[] ents = null;



        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsAsyncRequest)
            {
                ents = SysGroupRule.FindAll(SearchCriterion);

                this.PageState.Add("GrpList", ents);
            }

            SysGroup ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Query:
                case RequestActionEnum.Default:
                    ent = this.GetTargetData<SysGroup>();
                    this.SetFormData(ent);
                    break;
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<SysGroup>();
                    ent.ParentID = String.IsNullOrEmpty(ent.ParentID) ? null : ent.ParentID;
                    ent.DoUpdate();
                    this.SetMessage("更新成功！");
                    break;
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<SysGroup>();
                    if (String.IsNullOrEmpty(ent.ParentID))
                    {
                        ent.CreateAsTop();
                    }
                    else
                    {
                        ent.CreateAsSub(ent.ParentID);
                    }
                    this.SetMessage("添加模块成功！");
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<SysGroup>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                case RequestActionEnum.Custom:
                    if (RequestActionString == "refreshsys")
                    {
                        PortalService.RefreshSysModules();
                        SetMessage("操作成功！");
                    }
                    break;
            }

            SysGroupType[] grpTypes = SysGroupTypeRule.FindAll();
            this.PageState.Add("GrpTypeList", grpTypes);
        }


    }
}

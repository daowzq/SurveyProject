using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;


namespace Aim.Portal.Web.Modules.SysApp.MdlMag
{
    public partial class AuthList : BaseListPage
    {
        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            switch (this.RequestAction)
            {
                case RequestActionEnum.Custom:
                    if (RequestActionString == "querychildren")
                    {
                        string id = (RequestData.ContainsKey("ID") ? RequestData["ID"].ToString() : String.Empty);
                        string ttype = RequestData["Type"].ToString().ToLower();

                        if (RequestData.ContainsKey("Type"))
                        {
                            SysAuth[] ents = null;
                            if (ttype == "atype")  // 1为入口权限
                            {
                                ents = SysAuth.FindAll("FROM SysAuth as ent WHERE ent.Type = ? AND  ent.ParentID is null", id);
                            }
                            else
                            {
                                ents = SysAuth.FindAll("FROM SysAuth as ent WHERE ent.ParentID = ?", id);
                            }

                            this.PageState.Add("DtList", ents.OrderBy(v => v.SortIndex).ThenBy(v => v.CreateDate));
                        }
                    }
                    else if (RequestActionString == "refreshsys")
                    {
                        PortalService.RefreshSysModules();

                        SetMessage("操作成功！");
                    }
                    break;
            }

            if (!IsAsyncRequest)
            {
                SysAuthType[] authTypeList = SysAuthTypeRule.FindAll();

                this.PageState.Add("DtList", authTypeList);
            }
        }

        #endregion

        #region 私有方法

        #endregion
    }
}

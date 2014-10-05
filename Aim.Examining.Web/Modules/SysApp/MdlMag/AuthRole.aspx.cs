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
using Aim.Portal.Web.UI;
using Aim.Portal.Model;


namespace Aim.Portal.Web.Modules.SysApp.MdlMag
{
    public partial class AuthRole : BaseListPage
    {
        private SysRole[] ents = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (this.IsAsyncRequest)
            {
                switch (this.RequestAction)
                {
                    case RequestActionEnum.Custom:
                        if (RequestActionString == "querychildren")
                        {
                            string id = (RequestData.ContainsKey("ID") ? RequestData["ID"].ToString() : String.Empty);
                            string type = RequestData["Type"].ToString().ToLower();

                            if (RequestData.ContainsKey("Type"))
                            {
                                if (type == "rtype")
                                {
                                    id = (RequestData.ContainsKey("RoleTypeID") ? RequestData["RoleTypeID"].ToString() : String.Empty);
                                    ents = SysRole.FindAll("FROM SysRole as ent WHERE ent.Type = ?", id);

                                    this.PageState.Add("DtList", ents);
                                }
                            }
                        }
                        break;
                }
            }
            else
            {
                SysRoleType[] typeList = SysRoleTypeRule.FindAll();
                this.PageState.Add("DtList", typeList);
            }
        }
    }
}

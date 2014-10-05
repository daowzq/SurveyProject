using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Aim.Common;
using Aim.Portal;
using Aim.Portal.Web;
using Aim.Portal.Model;
using Aim.Portal.Web.UI;

namespace Aim.Examining.Web
{
    public partial class SubPortal3 : ExamBasePage
    {
        string mcode = String.Empty;

        SysModule ent = null;
        IEnumerable<SysModule> ents = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            mcode = RequestData.Get<string>("mcode", String.Empty);

            if (!String.IsNullOrEmpty(mcode))
            {
                ent = UserContext.AccessibleModules.First(tent => tent.Code == mcode);

                if (ent != null)
                {
                    ents = UserContext.AccessibleModules.Where(tent => !String.IsNullOrEmpty(tent.Path) && tent.Path.IndexOf(ent.ModuleID) >= 0)
                        .OrderBy(tent => tent.SortIndex);

                    PageState.Add("Module", ent);
                    PageState.Add("SubModules", ents);
                }
            }
        }
    }
}

using System;
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
    public partial class OrgStructureEdit : BasePage
    {
        #region 变量

        string op = String.Empty; // 用户编辑操作
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 对象类型

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op");
            id = RequestData.Get<string>("id");
            type = RequestData.Get<string>("type");

            SysGroup ent = null;

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<SysGroup>();
                    ent.DoUpdate();
                    this.SetMessage("修改成功！");
                    break;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<SysGroup>();
                    //ent.CreaterID = UserInfo.UserID;
                    //ent.CreaterName = UserInfo.Name;
                    if (ent.SortIndex == null)
                    {
                        ent.SortIndex = 9999;
                    }

                    ent.CreateDate = DateTime.Now;

                    if (String.IsNullOrEmpty(id))
                    { 
                        ent.CreateAsRoot();
                    }
                    else
                    {
                        ent.CreateAsSibling(SysGroup.Find(id));
                    }

                    this.SetMessage("新建成功！");
                    break;
                     default:
                    if (RequestActionString == "createsub")
                    {
                        ent = this.GetPostedData<SysGroup>();
                        //ent.CreaterID = UserInfo.UserID;
                        //ent.CreaterName = UserInfo.Name;
                        ent.LastModifiedDate = DateTime.Now;
                        if (!SysGroup.Exists("Name=? and code=? and Type=2 and ParentID = ?", ent.Name,ent.Code, id)) 
                        ent.CreateAsChild(SysGroup.Find(id)); 
                        this.SetMessage("新建成功！"); 
                    }
                    break;
            }

            if (op != "c" && op != "cs")
            {
                if (!String.IsNullOrEmpty(id))
                {
                    ent = SysGroup.Find(id);
                }
                
                this.SetFormData(ent);
            }
            else
            {
                PageState.Add("CreaterName", UserInfo.Name);
                PageState.Add("CreatedDate", DateTime.Now);
            }
        }

        #endregion
    }
}


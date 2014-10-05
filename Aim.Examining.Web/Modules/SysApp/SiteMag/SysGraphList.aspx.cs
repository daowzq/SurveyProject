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
using Aim.Portal.FileSystem;

namespace Aim.Portal.Web.Modules.SysApp.SiteMag
{
    public partial class SysGraphList : BaseListPage
    {
        #region 属性

        #endregion

        #region 变量

        private SysGraph[] ents = null;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            ents = SysGraphRule.FindAll(SearchCriterion);

            this.PageState.Add("SysGraphList", ents);
            
            SysGraph ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<SysGraph>();
                    ent.DoDelete();
                    
                    FileService.DeleteFileByFullID(ent.FileID);

                    this.SetMessage("删除成功！");
                    break;
                case RequestActionEnum.Custom:
                    IList<object> idList = RequestData.GetList<object>("IdList");

                    if (idList != null && idList.Count > 0)
                    {
                        if (RequestActionString == "batchdelete")
                        {
                            SysGraph[] tents = SysGraph.FindAllByPrimaryKeys(idList.ToArray());

                            for (int i = 0; i < tents.Length; i++)
                            {
                                tents[i].DoDelete();

                                FileService.DeleteFileByFullID(tents[i].FileID);
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


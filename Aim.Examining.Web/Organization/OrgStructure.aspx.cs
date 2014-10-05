using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Web.Script.Serialization;

using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;

namespace Aim.Examining.Web
{
    public partial class OrgStructure : BaseListPage
    {
        #region 属性

        private SysGroup[] ents = null;

        #endregion

        #region 变量
        string id = String.Empty;   // 对象id
        IList<string> ids = null;   // 节点列表
        IList<string> pids = null;   // 父节点列表
        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            id = RequestData.Get<string>("id", String.Empty);
            ids = RequestData.GetList<string>("ids");
            pids = RequestData.GetList<string>("pids");
            
            switch (this.RequestAction)
            {
                case RequestActionEnum.Custom:
                    if (RequestActionString == "querychildren")
                    {
                        if (String.IsNullOrEmpty(id))
                        {
                            ents = SysGroup.FindAll("FROM SysGroup as ent WHERE ParentId is null and (Type = 2 or Type = 3) and isnull(Status,'')<>0 Order By SortIndex asc");
                        }
                        else
                        {
                            ents = SysGroup.FindAll("FROM SysGroup as ent WHERE ParentId = '" + id + "' and (Type = 2 or Type = 3) and isnull(Status,'')<>0 Order By SortIndex asc");
                        }

                        this.PageState.Add("DtList", ents);
                        return;
                    }
                    else if (RequestActionString == "batchdelete")
                    {
                        IList<object> idList = RequestData.GetList<object>("IdList");
                        if (idList != null && idList.Count > 0)
                        {
                            SysGroup.DoBatchDelete(idList.ToArray());
                        }
                        return;
                    }
                    else if (RequestActionString == "c")
                    {
                        DoCreateSubByRole();
                        return;
                    }
                    break;
                default:
                    SysGroup[] grpList = SysGroup.FindAll("From SysGroup as ent where ParentId is null and (Type = 2 or Type = 21) and isnull(Status,'')<>0 Order By SortIndex, CreateDate Desc");

                    this.PageState.Add("DtList", grpList);
                    break;
            }
        }

        #endregion

        #region 私有方法

        [ActiveRecordTransaction]
        private void DoCreateSubByRole()
        {
            IList<string> idList = RequestData.GetList<string>("IdList");
            SysGroup tent = SysGroup.Find(id);

            if (idList != null && idList.Count > 0)
            {
                SysRole[] duties = SysRole.FindAllByPrimaryKeys(idList.ToArray());

                foreach (SysRole tduty in duties)
                {
                    if (!SysGroup.Exists("Name=? and Type=21 and ParentID = ?", tduty.Name, tent.ID))
                    {
                        SysGroup tgrp = new SysGroup()
                        {
                            Name = tduty.Name,
                            Code=tduty.Code,
                            Type = 3,   //角色
                            Status = 1,
                            SortIndex = 9999,
                            CreateDate = DateTime.Now
                        };

                        tgrp.CreateAsChild(tent);
                    }
                }
            }

        }

        #endregion
    }
}

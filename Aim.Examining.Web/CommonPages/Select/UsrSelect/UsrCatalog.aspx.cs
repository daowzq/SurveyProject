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
using Aim.Examining.Web;


namespace Aim.Portal.Web.CommonPages
{
    public partial class UsrCatalog : BaseListPage
    {
        private SysGroup[] ents = null;
        string id = String.Empty;   // 对象id
        IList<string> ids = null;   // 节点列表
        IList<string> pids = null;   // 父节点列表 

        public UsrCatalog()
        {
            IsCheckAuth = false;
            IsCheckLogon = false;
        }
        protected void Page_Load(object sender, EventArgs e)
        {

            id = RequestData.Get<string>("id", String.Empty);
            ids = RequestData.GetList<string>("ids");
            pids = RequestData.GetList<string>("pids");

            string SQL = string.Empty;    //

            switch (this.RequestAction)
            {
                case RequestActionEnum.Custom:
                    if (RequestActionString == "querychildren")
                    {
                        if (String.IsNullOrEmpty(id))
                        {
                            // ents = SysGroup.FindAll("FROM SysGroup as ent WHERE ParentId is null and (Type = 2 or Type = 3) Order By SortIndex asc");                      
                            SQL = "select * from FL_PortalHR..SysGroup WHERE ParentId is null and (Type = 2 or Type = 3) Order By SortIndex asc ";
                        }
                        else
                        {
                            //ents = SysGroup.FindAll("FROM SysGroup as ent WHERE ParentId = '" + id + "' and (Type = 2 or Type = 3) Order By SortIndex asc");
                            SQL = "select * from FL_PortalHR..SysGroup  WHERE ParentId = '" + id + "' and (Type = 2 or Type = 3) Order By SortIndex asc";
                        }
                        SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

                        //this.PageState.Add("DtList", ents);
                        this.PageState.Add("DtList", DataHelper.QueryDictList(SQL));
                    }
                    break;
                default:
                    //SysGroup[] grpList = SysGroup.FindAll("From SysGroup as ent where ParentId is null and (Type = 2 or Type = 21) Order By SortIndex Desc");

                    //this.PageState.Add("DtList", grpList);
                    SQL = @"select * from FL_PortalHR..SysGroup where  ParentId is null and (Type = 2 or Type = 21) union all
                                    select * from FL_PortalHR..SysGroup where
                                     ParentID in (select GroupID from FL_PortalHR..SysGroup where  ParentId is null and (Type = 2 or Type = 21) )
                                    order by SortIndex,Code";
                    // SysGroup[] grpList = SysGroup.FindAll("From SysGroup as ent where ParentId is null and (Type = 2 or Type = 21) Order By SortIndex Desc");
                    SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
                    this.PageState.Add("DtList", DataHelper.QueryDictList(SQL));
                    break;
            }

        }

    }
}

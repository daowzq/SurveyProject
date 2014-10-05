using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Aim.Data;
using Aim.Common;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;


namespace Aim.Portal.Web.Modules.SysApp.OrgMag
{
    public partial class RolTree : BasePage
    {
        string op = String.Empty;
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 查询类型

        protected void Page_Load(object sender, EventArgs e)
        {
            id = (RequestData.ContainsKey("id") ? RequestData["id"].ToString() : String.Empty);
            type = (RequestData.ContainsKey("type") ? RequestData["type"].ToString() : String.Empty).ToLower();

            if (this.IsAsyncRequest)
            {
                switch (this.RequestAction)
                {
                    case RequestActionEnum.Custom:
                        if (RequestActionString == "querychildren" || RequestActionString == "querydescendant")
                        {
                            SysRole[] ents = null;

                            if (RequestActionString == "querychildren" || RequestActionString == "querydescendant")
                            {
                                string atype = String.Empty;

                                if (type == "rtype")
                                {
                                    ents = SysRole.FindAll("FROM SysRole as ent WHERE ent.Type = ?", id);
                                }
                            }

                            string jsonString = JsonHelper.GetJsonString(this.ToExtTreeCollection(ents, null));
                            Response.Write(jsonString);

                            Response.End();
                        }
                        else if (RequestActionString == "savechanges")
                        {
                            ICollection authAdded = RequestData["added"] as ICollection;
                            ICollection authRemoved = RequestData["removed"] as ICollection;

                            if (type == "user" && !String.IsNullOrEmpty(id))
                            {
                                SysRoleRule.GrantRoleToUser(authAdded, id);
                                SysRoleRule.RevokeRoleFromUser(authRemoved, id);
                            }
                            else if (type == "group" && !String.IsNullOrEmpty(id))
                            {
                                SysRoleRule.GrantRoleToGroup(authAdded, id);
                                SysRoleRule.RevokeRoleFromGroup(authRemoved, id);
                            }
                        }
                        break;
                }
            }
            else
            {
                SysRoleType[] typeList = SysRoleTypeRule.FindAll();
                this.PageState.Add("EntData", typeList);
            }

            // 获取权限列表
            if (RequestAction != RequestActionEnum.Custom)
            {
                this.PageState.Add("EntityID", id);

                IEnumerable<string> roleIDs = null;
                using (new Castle.ActiveRecord.SessionScope())
                {
                    if (type == "user" && !String.IsNullOrEmpty(id))
                    {
                        SysUser user = SysUser.Find(id);
                        roleIDs = (user.Role).Select((ent) => { return ent.RoleID; });
                    }
                    else if (type == "group" && !String.IsNullOrEmpty(id))
                    {
                        SysGroup group = SysGroup.Find(id);
                        roleIDs = (group.Role).Select((ent) => { return ent.RoleID; });
                    }

                    this.PageState.Add("EntList", new List<string>(roleIDs));
                }
            }
        }

        /// <summary>
        /// 生成ExtTree
        /// </summary>
        /// <param name="ents"></param>
        /// <param name="parentID"></param>
        /// <returns></returns>
        private WebHelper.ExtTreeNodeCollection ToExtTreeCollection(IEnumerable<SysRole> ents, WebHelper.ExtTreeNode pnode)
        {
            string parentID = (pnode == null) ? null : (pnode["id"] == null ? null : pnode["id"].ToString());

            IEnumerable<SysRole> rtnents = ents;

            WebHelper.ExtTreeNodeCollection nodes = new WebHelper.ExtTreeNodeCollection();

            if (ents != null)
            {
                if (rtnents.Count() > 0)
                {
                    foreach (SysRole tent in rtnents)
                    {
                        WebHelper.ExtTreeNode node = new WebHelper.ExtTreeNode();
                        node["id"] = tent.RoleID;
                        node["text"] = tent.Name;
                        node["RoleID"] = tent.RoleID;
                        node["Type"] = tent.Type;
                        node["Name"] = tent.Name;
                        node["Code"] = tent.Code;
                        node["SortIndex"] = tent.SortIndex;
                        node["LastModifiedDate"] = tent.LastModifiedDate;
                        node["CreateDate"] = tent.CreateDate;
                        node["Description"] = tent.Description;
                        node["leaf"] = true;

                        nodes.Add(node);
                    }
                }
            }

            return nodes;
        }
    }
}

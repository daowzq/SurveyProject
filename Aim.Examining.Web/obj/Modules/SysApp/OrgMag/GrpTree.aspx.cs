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
    public partial class GrpTree : BasePage
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
                            SysGroup[] ents = null;

                            if (RequestActionString == "querychildren")
                            {
                                string atype = String.Empty;

                                if (type == "gtype")
                                {
                                    ents = SysGroup.FindAll("FROM SysGroup as ent WHERE ent.Type = ? AND ent.ParentID IS NULL", id);
                                }
                                else
                                {
                                    ents = SysGroup.FindAll("FROM SysGroup as ent WHERE ent.ParentID = ?", id);
                                }
                            }
                            else if (RequestActionString == "querydescendant")
                            {
                                string atype = String.Empty;

                                if (type == "gtype")
                                {
                                    ents = SysGroup.FindAll("FROM SysGroup as ent WHERE ent.Type = ?", id);
                                }
                                else
                                {
                                    ents = SysGroup.FindAll("FROM SysGroup as ent WHERE ent.Path LIKE %?%", id);
                                }
                            }

                            string jsonString = JsonHelper.GetJsonString(this.ToExtTreeCollection(ents, null));
                            Response.Write(jsonString);

                            Response.End();
                        }
                        else if (RequestActionString == "savechanges")
                        {
                            ICollection added = RequestData["added"] as ICollection;
                            ICollection removed = RequestData["removed"] as ICollection;

                            if (type == "user" && !String.IsNullOrEmpty(id))
                            {
                                SysGroupRule.GrantGroupToUser(added, id);
                                SysGroupRule.RevokeGroupFromUser(removed, id);
                            }
                            /*else if (type == "role" && !String.IsNullOrEmpty(id))
                            {
                                SysGroupRule.GrantGroupToRole(added, id);
                                SysGroupRule.RevokeGroupFromRole(removed, id);
                            }*/
                        }
                        break;
                }
            }
            else
            {
                SysGroupType[] typeList = SysGroupTypeRule.FindAll();
                this.PageState.Add("EntData", typeList);
            }

            // 获取权限列表
            if (RequestAction != RequestActionEnum.Custom)
            {
                this.PageState.Add("EntityID", id);

                IEnumerable<string> grpIDs = null;
                using (new Castle.ActiveRecord.SessionScope())
                {
                    if (type == "user" && !String.IsNullOrEmpty(id))
                    {
                        SysUser user = SysUser.Find(id);
                        grpIDs = (user.Group).Select((ent) => { return ent.GroupID; });
                    }
                    else if (type == "role" && !String.IsNullOrEmpty(id))
                    {
                        SysRole role = SysRole.Find(id);
                        grpIDs = (role.Group).Select((ent) => { return ent.GroupID; });
                    }

                    this.PageState.Add("EntList", new List<string>(grpIDs));
                }
            }
        }

        /// <summary>
        /// 生成ExtTree
        /// </summary>
        /// <param name="ents"></param>
        /// <param name="parentID"></param>
        /// <returns></returns>
        private WebHelper.ExtTreeNodeCollection ToExtTreeCollection(IEnumerable<SysGroup> ents, WebHelper.ExtTreeNode pnode)
        {
            string parentID = (pnode == null) ? null : (pnode["id"] == null ? null : pnode["id"].ToString());

            IEnumerable<SysGroup> rtnents = null;

            WebHelper.ExtTreeNodeCollection nodes = new WebHelper.ExtTreeNodeCollection();

            if (ents != null)
            {
                if (String.IsNullOrEmpty(parentID))
                {
                    rtnents = ents.Where(ent => (ent.ParentID == null || ent.ParentID == String.Empty));
                }
                else
                {
                    rtnents = ents.Where(ent => ent.ParentID == parentID);
                }

                if (rtnents.Count() > 0)
                {
                    if (pnode != null)
                    {
                        pnode["leaf"] = false;
                    }

                    foreach (SysGroup tent in rtnents)
                    {
                        WebHelper.ExtTreeNode node = new WebHelper.ExtTreeNode();
                        node["id"] = tent.GroupID;
                        node["text"] = tent.Name;
                        node["GroupID"] = tent.GroupID;
                        node["ParentID"] = tent.ParentID;
                        node["Type"] = tent.Type;
                        node["Name"] = tent.Name;
                        node["Code"] = tent.Code;
                        node["Path"] = tent.Path;
                        node["PathLevel"] = tent.PathLevel;
                        node["Status"] = tent.Status;
                        node["SortIndex"] = tent.SortIndex;
                        node["LastModifiedDate"] = tent.LastModifiedDate;
                        node["CreateDate"] = tent.CreateDate;
                        node["Description"] = tent.Description;

                        node["children"] = ToExtTreeCollection(ents, node);

                        nodes.Add(node);
                    }
                }
                else
                {
                    if (pnode != null)
                    {
                        pnode["leaf"] = true;

                        if (pnode["children"] == null)
                        {
                            pnode.Remove("children");
                        }
                    }
                }
            }

            return nodes;
        }
    }
}

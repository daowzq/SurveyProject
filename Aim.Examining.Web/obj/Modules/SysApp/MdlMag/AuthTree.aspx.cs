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


namespace Aim.Portal.Web.Modules.SysApp.MdlMag
{
    public partial class AuthTree : BasePage
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
                            SysAuth[] ents = null;

                            if (RequestActionString == "querychildren")
                            {
                                string atype = String.Empty;

                                if (type == "atype")
                                {
                                    ents = SysAuth.FindAll("FROM SysAuth as ent WHERE ent.Type = ? AND ent.ParentID IS NULL", id);
                                }
                                else
                                {
                                    ents = SysAuth.FindAll("FROM SysAuth as ent WHERE ent.ParentID = ?", id);
                                }
                            }
                            else if (RequestActionString == "querydescendant")
                            {
                                string atype = String.Empty;

                                if (type == "atype")
                                {
                                    ents = SysAuth.FindAll("FROM SysAuth as ent WHERE ent.Type = ?", id);
                                }
                                else
                                {
                                    ents = SysAuth.FindAll("FROM SysAuth as ent WHERE ent.Path LIKE %?%", id);
                                }
                            }

                            string jsonString = JsonHelper.GetJsonString(this.ToExtTreeCollection(ents.OrderBy(v => v.SortIndex).ThenBy(v => v.CreateDate), null));

                            Response.Write(jsonString);

                            Response.End();
                        }
                        else if (RequestActionString == "savechanges")
                        {
                            ICollection authAdded = RequestData["added"] as ICollection;
                            ICollection authRemoved = RequestData["removed"] as ICollection;

                            if (type == "user" && !String.IsNullOrEmpty(id))
                            {
                                SysAuthRule.GrantAuthToUser(authAdded, id);
                                SysAuthRule.RevokeAuthFromUser(authRemoved, id);
                            }
                            else if (type == "group" && !String.IsNullOrEmpty(id))
                            {
                                SysAuthRule.GrantAuthToGroup(authAdded, id);
                                SysAuthRule.RevokeAuthFromGroup(authRemoved, id);
                            }
                            else if (type == "role" && !String.IsNullOrEmpty(id))
                            {
                                SysAuthRule.GrantAuthToRole(authAdded, id);
                                SysAuthRule.RevokeAuthFromRole(authRemoved, id);
                            }
                        }
                        break;
                }
            }
            else
            {
                SysAuthType[] authTypeList = SysAuthTypeRule.FindAll();

                this.PageState.Add("DtList", authTypeList);
            }

            // 获取权限列表
            if (RequestAction != RequestActionEnum.Custom)
            {
                this.PageState.Add("EntityID", id);

                IEnumerable<string> authIDs = null;
                using (new Castle.ActiveRecord.SessionScope())
                {
                    if (type == "user" && !String.IsNullOrEmpty(id))
                    {
                        SysUser user = SysUser.Find(id);
                        authIDs = (user.Auth).Select((ent) => { return ent.AuthID; });
                    }
                    else if (type == "group" && !String.IsNullOrEmpty(id))
                    {
                        SysGroup group = SysGroup.Find(id);
                        authIDs = (group.Auth).Select((ent) => { return ent.AuthID; });
                    }
                    else if (type == "role" && !String.IsNullOrEmpty(id))
                    {
                        SysRole role = SysRole.Find(id);
                        authIDs = (role.Auth).Select((ent) => { return ent.AuthID; });
                    }

                    this.PageState.Add("AtList", new List<string>(authIDs));
                }
            }
        }

        /// <summary>
        /// 生成ExtTree
        /// </summary>
        /// <param name="ents"></param>
        /// <param name="parentID"></param>
        /// <returns></returns>
        private WebHelper.ExtTreeNodeCollection ToExtTreeCollection(IEnumerable<SysAuth> ents, WebHelper.ExtTreeNode pnode)
        {
            string parentID = (pnode == null) ? null : (pnode["id"] == null ? null : pnode["id"].ToString());

            IEnumerable<SysAuth> rtnents = null;

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

                    foreach (SysAuth tent in rtnents)
                    {
                        WebHelper.ExtTreeNode node = new WebHelper.ExtTreeNode();
                        node["id"] = tent.AuthID;
                        node["text"] = tent.Name;
                        node["AuthID"] = tent.AuthID;
                        node["ParentID"] = tent.ParentID;
                        node["ModuleID"] = tent.ModuleID;
                        node["Type"] = tent.Type;
                        node["Name"] = tent.Name;
                        node["Code"] = tent.Code;
                        node["Data"] = tent.Data;
                        node["Path"] = tent.Path;
                        node["PathLevel"] = tent.PathLevel;
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

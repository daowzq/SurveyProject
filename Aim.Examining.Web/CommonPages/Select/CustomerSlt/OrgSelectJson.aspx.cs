using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Text;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using NHibernate.Criterion;
using System.Data;

namespace Aim.Examining.Web.CommonPages.Select.CustomerSlt
{
    public partial class OrgSelectJson : BaseListPage
    {
        string nodeId = string.Empty;
        string JsonStr = string.Empty;
        string ckId = string.Empty;  //选中的节点ID
        protected void Page_Load(object sender, EventArgs e)
        {
            nodeId = RequestData.Get("nodeId") + "";
            ckId = RequestData.Get("ckId") + "";

            if (!string.IsNullOrEmpty(nodeId))
            {
                string SQL = @"select GroupID,Name,ParentID from FL_Portal..SysGroup 
                                           where Type=2 and ParentID in {0} ";
                // where Type=2 and ParentID = '{0}'";
                // SQL = string.Format(SQL, nodeId);
                SQL = string.Format(SQL, GetGroupID());
                DataTable dt = DataHelper.QueryDataTable(SQL);
                List<ExtTree> listTree = GetTree(dt);
                string json = JsonHelper.GetJsonString(listTree);
                json = json.Replace("check", "checked");
                JsonStr = json;
            }
            Response.Write(JsonStr);
            Response.End();
        }

        /// <summary>
        /// 根据SurveyType 配置获取GroupID
        /// </summary>
        /// <returns></returns>
        private string GetGroupID()
        {
            string SQL = @" select CA.* from FL_Culture..SurveyType  A 
                            cross apply(select * from FL_Culture..GetTblByJson(A.AccessPower,'Id')) As CA
	                        where A.Id in (
		                         select TypeId from  FL_Culture.dbo.View_SuryTypeUsr 
			                        where UserID='{0}'
	                        )
	                        union 
	                        select * from FL_Culture..f_splitstr((
		                        select CA.Filed+',' from FL_Culture..SurveyType  A 
		                        cross apply(select * from FL_Culture..GetTblByJson(A.AccessPower,'OrgIds')) As CA
		                        where A.Id in (
			                         select TypeId from  FL_Culture.dbo.View_SuryTypeUsr 
				                        where UserID='{0}'
		                        )  
		                        for xml path('')
	                         ),',') where F1 <>'' ";

            SQL = string.Format(SQL, UserInfo.UserID);
            DataTable dt = DataHelper.QueryDataTable(SQL);
            StringBuilder strb = new StringBuilder();
            strb.Append("(");
            for (var v = 0; v < dt.Rows.Count; v++)
            {
                if (v > 0) strb.Append(",");
                strb.Append("'" + dt.Rows[v][0] + "'");
            }
            strb.Append(")");
            return strb.ToString();
        }

        private List<ExtTree> GetTree(DataTable dt)
        {
            List<ExtTree> list = new List<ExtTree>();

            //递归调用
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                ExtTree tree = new ExtTree();
                tree.id = dt.Rows[i]["GroupID"] + "";
                tree.text = dt.Rows[i]["Name"] + "";
                //节点是否选中
                if (ckId.Contains(tree.id))
                {
                    tree.check = true;
                    tree.expanded = true;
                }
                else
                {
                    tree.check = false;
                    tree.expanded = false;
                }

                DataTable TempDt = GetChildNode(dt.Rows[i]["GroupID"].ToString());
                if (TempDt.Rows.Count > 0)
                {
                    tree.leaf = false;
                    tree.cls = "folder";
                    tree.children = GetTree(TempDt);
                    list.Add(tree);
                }
                else
                {
                    tree.leaf = true;
                    tree.cls = "folder";
                    tree.children = null;
                    list.Add(tree);
                }
            }
            return list;
        }

        private DataTable GetChildNode(string ParentID)
        {
            string SQL = @"select GroupID,Name,ParentID from FL_Portal..SysGroup where Type=2 and ParentID='{0}'";
            SQL = string.Format(SQL, ParentID);
            return DataHelper.QueryDataTable(SQL);
        }

        public string GetTreeFormat(DataTable dt)
        {
            string pattern = @"{{ 'id': '{0}',text: '{1}', checked: {2}, leaf: {3} }}";
            StringBuilder strb = new StringBuilder();
            strb.Append("[");
            if (dt.Rows.Count == 0)
            {
                strb.AppendFormat(pattern, "", "", "false", "true");
            }
            else
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    if (i > 0) strb.Append(",");
                    strb.AppendFormat(pattern, dt.Rows[i]["GroupID"].ToString(), dt.Rows[i]["Name"].ToString(), "false", "true");
                }
            }
            strb.Append("]");
            return strb.ToString();

        }

    }


}

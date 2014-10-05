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
    public partial class OrgPostionSlt : BaseListPage
    {
        string nodeId = string.Empty;
        string JsonStr = string.Empty;
        string ckId = string.Empty;  //选中的节点ID
        protected void Page_Load(object sender, EventArgs e)
        {

            string OrgID = GetOrgPostionStr();  //继承过来组织结构

            nodeId = RequestData.Get("nodeId") + "";
            ckId = RequestData.Get("ckId") + "";
            if (!string.IsNullOrEmpty(nodeId))
            {
                string SQL = @"select GroupID,Name,ParentID from FL_Portal..SysGroup 
                                           where Type=2 and ParentID in {0} ";
                SQL = string.Format(SQL, OrgID);
                DataTable dt = DataHelper.QueryDataTable(SQL);
                List<ExtTree> listTree = GetTree(dt);
                string json = JsonHelper.GetJsonString(listTree);
                json = json.Replace("check", "checked");// 转换成TreeNode格式
                JsonStr = json;
                Response.Write(JsonStr);
                Response.End();
            }
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

        /// <summary>
        /// 查询子节点
        /// </summary>
        /// <param name="ParentID"></param>
        /// <returns></returns>
        private DataTable GetChildNode(string ParentID)
        {
            string SQL = @"select GroupID,Name,ParentID from FL_Portal..SysGroup where GroupID IN
                            (select max(GroupID) from FL_Portal..SysGroup where Type=3 and ParentID like '{0}%' group by [Name])";
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

        /// <summary>
        /// 组织结构ID字符串
        /// </summary>
        /// <returns></returns>
        private string GetOrgPostionStr()
        {
            //根据用户获取组织结构
            string SQL = @"  ---默认本部门
                    select B.* from (
	                    select * from FL_Culture..SurveyType Where Id in 
	                    (select TypeId from FL_Culture..View_SuryTypeUsr where UserId='{0}') 
                    ) As A
                    cross apply 
                    ( select * from FL_Culture..GetTblByJson(A.AccessPower,'Id' ))
                    As B 
                    union 
                    --发布范围
                    select B.* from (
	                    select B.* from (
		                    select * from FL_Culture..SurveyType Where Id in 
		                    (select TypeId from FL_Culture..View_SuryTypeUsr where UserId='{0}') 
	                    ) As A
	                    cross apply 
	                    ( select * from FL_Culture..GetTblByJson(A.AccessPower,'OrgIds' )) As B 
                    )As A
                    Cross Apply(
                      select * from FL_Culture..f_splitstr(A.Filed,',')
                    ) As B ";
            SQL = string.Format(SQL, UserInfo.UserID);
            StringBuilder strb = new StringBuilder();
            DataTable dt = DataHelper.QueryDataTable(SQL);
            if (dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    if (i > 0) strb.Append(",");
                    strb.Append("'" + dt.Rows[i][0] + "'");
                }
            }
            return "(" + strb.ToString() + ")";
        }

    }
}

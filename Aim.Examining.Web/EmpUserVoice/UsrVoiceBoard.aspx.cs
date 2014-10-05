using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;
using Aim.Data;
using System.Data;

namespace Aim.Examining.Web.EmpUserVoice
{
    public partial class UsrVoiceBoard : ExamListPage
    {
        string nodeId = string.Empty;
        string JsonStr = string.Empty;
        string ckId = string.Empty;  //选中的节点ID
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(this.RequestData.Get("nodeId") + ""))
            {
                Response.Write(GetGroupID());
                Response.End();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        private string GetGroupID()
        {
            string SQL = @" with GetTree
                            as
                            (
	                            select EnumerationID,Code,Name,Value,ParentID,Path,IsLeaf
	                               from FL_PortalHR..SysEnumeration where Code='QuestionType'
	                            union all
	                            select A.EnumerationID,A.Code,A.Name,A.Value,A.ParentID,A.Path,A.IsLeaf
	                               from FL_PortalHR..SysEnumeration  As A 
	                            join GetTree as B 
	                            on  A.ParentId=B.EnumerationID
                            )
                            select * from getTree";

            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
            DataTable dt = DataHelper.QueryDataTable(SQL);
            if (dt.Rows.Count > 0)
            {
                dt.Rows.Remove(dt.Rows[0]); //去除第一行
                //dt.Rows[0]["Name"] = "所有分类";  
            }
            return GetTreeFormat(dt);

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
                    if (i == 0)
                    {
                        string isLeaf = string.Empty;
                        isLeaf = dt.Rows[i]["IsLeaf"].ToString() == "0" ? "false" : "true";
                        strb.AppendFormat(pattern, dt.Rows[i]["EnumerationID"].ToString(), "所有分类", "null", isLeaf);
                    }
                    else
                    {
                        strb.Append(",");
                        string isLeaf = string.Empty;
                        isLeaf = dt.Rows[i]["IsLeaf"].ToString() == "0" ? "false" : "true";
                        strb.AppendFormat(pattern, dt.Rows[i]["EnumerationID"].ToString(), dt.Rows[i]["Name"].ToString(), "null", isLeaf);
                    }

                }
            }
            strb.Append("]");
            return strb.ToString();
        }
    }
    //定义树的结构
    internal class ExtTree
    {
        public string cls { get; set; }
        public string id { get; set; }
        public bool leaf { get; set; }
        public string text { get; set; }
        public bool expanded { get; set; }
        public bool check { get; set; }
        public List<ExtTree> children { get; set; }
    }
}

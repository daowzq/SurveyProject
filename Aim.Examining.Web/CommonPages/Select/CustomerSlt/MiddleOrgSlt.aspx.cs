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
    public partial class MiddleOrgSlt : BaseListPage
    {

        public MiddleOrgSlt()
        {
            this.IsCheckAuth = false;
            this.IsCheckLogon = false;
        }

        string nodeId = string.Empty;
        string ckId = string.Empty;  //选中的节点ID
        string allowNodeId = string.Empty;
        static DataTable GDt = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            ckId = RequestData.Get("ckId") + "";
            nodeId = RequestData.Get("nodeId") + "";
            allowNodeId = RequestData.Get("allowNodeId") + "";

            string SQLINStr = string.Empty; // eg: '123123','bbbb'
            if (allowNodeId.Contains(","))
            {
                string[] tmpArr = allowNodeId.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                for (int i = 0; i < tmpArr.Length; i++)
                {
                    if (i > 0) SQLINStr += ",";
                    SQLINStr += "'" + tmpArr[i] + "'";
                }
            }


            string jsonStr = string.Empty;
            //string SQL = "select * from FL_Culture..V_MiddleDbOrg";
            string SQL = "select GroupID As ID ,GroupID,Name,Code,ParentID from SysGroup  where Type=2 and ParentID is not null";

            if (!string.IsNullOrEmpty(nodeId))
            {
                var Ent = SysInfoConfig.FindFirstByProperties("Code", "MiddleDbOrg");
                DoUpdateNode(Ent, SQL);

                if (!string.IsNullOrEmpty(allowNodeId))
                {
                    GDt = DataHelper.QueryDataTable(SQL);
                    DataRow[] rows = null;
                    if (!string.IsNullOrEmpty(SQLINStr))
                    {
                        rows = GDt.Select(" GroupID in (" + SQLINStr + ") ");  //better指定公司
                    }
                    else
                    {
                        rows = GDt.Select(" GroupID in ('" + allowNodeId + "') ");  //better指定公司
                    }

                    List<TreeNode> listTree = GetTree(rows);
                    jsonStr = JsonHelper.GetJsonString(listTree);
                }
                else
                {
                    jsonStr = Ent.Content;
                }

                Response.Write(jsonStr);
                Response.End();
            }
        }

        /// <summary>
        /// 更新节点json
        /// </summary>
        private void DoUpdateNode(SysInfoConfig Ent, string SQL)
        {
            if (Ent.UpdateTime.GetValueOrDefault().Year < DateTime.Now.Year
                || Ent.UpdateTime.GetValueOrDefault().DayOfYear < DateTime.Now.DayOfYear)    //以天为周期更新
            {
                GDt = DataHelper.QueryDataTable(SQL);
                DataRow[] rows = SelectDt(GDt, adapterNodeId(nodeId));

                List<TreeNode> listTree = GetTree(rows);
                string jsonStr = JsonHelper.GetJsonString(listTree);

                Ent.UpdateTime = DateTime.Now;
                Ent.Content = jsonStr;
                Ent.DoUpdate();
            }
        }


        /// <summary>
        /// 选择DataRow
        /// </summary>
        private DataRow[] SelectDt(DataTable dt, string selectStr)
        {
            if (dt.Rows.Count <= 0) return null;
            // string Query = "'" + selectStr + "'" + " like '%'+ParentID+'%' ";
            string Query = " ParentID in " + selectStr;
            DataRow[] Drs = dt.Select(Query);
            return Drs;
        }

        //处理nodeId
        private string adapterNodeId(string Ids)
        {
            StringBuilder strb = new StringBuilder();
            strb.Append("(");
            for (int i = 0; i < Ids.Split(',').Length; i++)
            {
                if (i > 0) strb.Append(",");
                strb.Append("'" + Ids.Split(',')[i] + "'");
            }
            strb.Append(")");
            return strb.ToString();
        }

        #region 获取节点
        private List<TreeNode> GetTree(DataRow[] rows)
        {
            List<TreeNode> list = new List<TreeNode>();

            //递归调用
            for (int i = 0; i < rows.Length; i++)
            {
                TreeNode tree = new TreeNode();
                tree.id = rows[i]["GroupID"] + "";
                tree.text = rows[i]["Name"] + "";

                DataRow[] TempDt = SelectDt(GDt, adapterNodeId(rows[i]["GroupID"].ToString()));
                if (TempDt.Length > 0)
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
        #endregion



        public string IsSurveyAdmin
        {
            get
            {
                CommPowerSplit ps = new CommPowerSplit();
                bool bol = ps.IsSurveyRole(UserInfo.UserID, UserInfo.LoginName);
                if (bol) return "1";
                else return "0";
            }
        }


    }

}

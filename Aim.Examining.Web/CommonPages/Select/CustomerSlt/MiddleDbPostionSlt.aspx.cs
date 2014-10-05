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
    public partial class MiddleDbPostionSlt : BaseListPage
    {
        string nodeId = string.Empty;
        string deptId = string.Empty;


        public MiddleDbPostionSlt()
        {
            this.IsCheckAuth = false;
            this.IsCheckLogon = false;
        }
        static DataTable PositionDt = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            deptId = RequestData.Get("param") + "";
            nodeId = RequestData.Get("nodeId") + "";
            string jsonStr = string.Empty;

            //  string SQL = @"select  pk_fld_gw As id,pk_fld_gw As GroupID, jobname As Name,jobcode As Code,'1001' ParentID,
            //                  FL_Culture.dbo.f_getDeptPathByGwId(pk_deptdoc) As Path 
            //                  from  HR_OA_MiddleDB..fld_gw";
            string SQL = @"select  GroupID As ID,GroupID,Name,Code,ParentID  from 
                            (
	                             select B.* from  FL_Culture..f_splitstr('{0}',',') As A
	                                left join  FL_PortalHR..SysGroup  As B 
		                            on B.Path like '''%'+A.F1+'%''' where type=3 and Status=1 
	                             union All
	                             select * from FL_PortalHR..SysGroup where type=3 and Status=1 and Path=''
                            ) As T";

            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

            SQL = string.Format(SQL, deptId);

            // SQL = @"select * from FL_PortalHR..SysGroup where type=3 and Status=1";

            if (!string.IsNullOrEmpty(nodeId))
            {
                //var Ent = SysInfoConfig.FindFirstByProperties("Code", "Postion");
                //以天为周期更新
                //if (Ent.UpdateTime.GetValueOrDefault().Day < DateTime.Now.Day)
                //{
                //if (PositionDt == null)
                //{
                PositionDt = DataHelper.QueryDataTable(SQL);
                DataRow[] rows = SelectDt(PositionDt, "");

                List<TreeNode> listTree = GetTree(rows);
                jsonStr = JsonHelper.GetJsonString(listTree);
                //}
                //else
                //{
                //DataRow[] rows = SelectDt(PositionDt, adapterNodeId(nodeId));
                //List<TreeNode> listTree = GetTree(rows);
                //jsonStr = JsonHelper.GetJsonString(listTree);
                // }

                //Ent.UpdateTime = DateTime.Now;
                //Ent.Content = jsonStr;
                //Ent.DoUpdate();
                //}
                //else
                //{
                //    jsonStr = Ent.Content;
                //}
                Response.Write(jsonStr);
                Response.End();
            }

        }

        //选择DataRow
        private DataRow[] SelectDt(DataTable dt, string selectStr)
        {
            if (dt.Rows.Count <= 0) return null;
            // string Query = "'" + selectStr + "'" + " like '%'+ParentID+'%' ";
            string Query = string.IsNullOrEmpty(selectStr) ? "" : " ParentID in " + selectStr;
            DataRow[] Drs = dt.Select();
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

                DataRow[] TempDt = SelectDt(PositionDt, adapterNodeId(rows[i]["GroupID"].ToString()));
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
    }
}

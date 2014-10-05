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
using System.Text;
using System.Data;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class SurveyTypeEdit : BaseListPage
    {

        string op = String.Empty; // 用户编辑操作
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 对象类型

        Model.SurveyType ent = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op");
            id = RequestData.Get<string>("id");
            type = RequestData.Get<string>("type");

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    DoUpdate();
                    break;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    DoCreate();
                    break;
                case RequestActionEnum.Delete:
                    ent = GetTargetData<Model.SurveyType>();
                    ent.DoDelete();
                    return;
                default:
                    DoSelect();
                    break;
            }


        }

        private void DoUpdate()
        {
            string AccessPower = RequestData.Get("AccessPower") + "";
            string MustCheckFlow = RequestData.Get("MustCheckFlow") + "";

            ent = this.GetMergedData<Model.SurveyType>();
            ent.AccessPower = AccessPower;
            ent.MustCheckFlow = MustCheckFlow;
            ent.DoUpdate();
        }

        private void DoCreate()
        {
            string AccessPower = RequestData.Get("AccessPower") + "";
            string MustCheckFlow = RequestData.Get("MustCheckFlow") + "";
            ent = GetPostedData<Model.SurveyType>();
            ent.AccessPower = AccessPower;
            ent.EnabledState = "1";   //启用标志
            ent.MustCheckFlow = MustCheckFlow;
            ent.DoCreate();
        }
        private void DoSelect()
        {
            ////获取系统枚举流程
            //string WFSQL = "select Code,TemplateName from  FL_Culture_AimPortal..WorkflowTemplate";
            //this.PageState.Add("WFEnum", DataHelper.QueryDict(WFSQL));
            //this.PageState.Add("PostionType", SysEnumeration.GetEnumDict("PostionType"));

            string SQL = @" select top 20 MName,MName As Name from  FL_Culture..ManagementGroup order by SortIndex Desc ";
            this.PageState.Add("PostionType", DataHelper.QueryDict(SQL));

            string AccessPower = "", SurveyedPower = "";
            if (!String.IsNullOrEmpty(id))
            {
                ent = Model.SurveyType.Find(id);
                SurveyedPower = ent.SurveyedPower;
                AccessPower = ent.AccessPower;
                this.PageState.Add("AccessList", ent.AccessPower);
            }
            else
            {
                //创建情况
                ent = new Model.SurveyType();
                ent.TypeCode = "HR_ST" + DateTime.Now.ToString("yyyyMMddhhmm");

            }
            this.SetFormData(ent);

        }

        /// <summary>
        ///默认选中的公司Id
        /// </summary>
        public string nodeId
        {
            get
            {
                //问卷角色或管理员
                CommPowerSplit Role = new CommPowerSplit();
                bool bl = Role.IsSurveyRole(UserInfo.UserID, UserInfo.LoginName);
                if (bl)
                {
                    string SQL = "select top 1 GroupID from FL_PortalHR..sysgroup where type='2' and Name='飞力集团' ";
                    SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
                    object obj = DataHelper.QueryValue(SQL);
                    return obj.ToString();
                }
                else
                {
                    CommPowerSplit ps = new CommPowerSplit();
                    string corps = ps.GetRoleCorps(UserInfo.UserID); //角色所在公司id

                    StringBuilder strb = new StringBuilder();
                    if (Session["CompanyId"] != null)           //判断公司登陆
                    {
                        strb.Append(Session["CompanyId"].ToString());

                    }
                    else
                    {
                        string sql = @"select B.GroupID, B.Name from sysuser As A 
	                               left join Sysgroup As B
                                        on A.Pk_corp=B.GroupID
	                               where A.UserID='{0}' ";
                        sql = string.Format(sql, UserInfo.UserID);
                        DataTable dt = DataHelper.QueryDataTable(sql);

                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            if (i > 0) strb.Append(",");
                            strb.Append(dt.Rows[i]["GroupID"].ToString());
                        }
                    }

                    if (strb.Length > 0)
                        strb.Append("," + corps);
                    else
                        strb.Append(corps);

                    return strb.ToString();

                }
            }
        }
    }
}

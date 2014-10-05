using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

using NHibernate;
using NHibernate.Criterion;
using Castle.ActiveRecord;
using Aim.Data;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;
using Aim.Component;
using Aim.Component.ThirdpartySupport.MsOffice;


namespace Aim.Portal.Web.Modules.SysApp.OrgMag
{
    public partial class UsrList : BaseListPage
    {
        #region 属性

        #endregion

        #region 变量

        string op = String.Empty;
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 查询类型

        private SysUser[] users = null;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            if (this.Request.Files.Count > 0)
            {
                string guid = Guid.NewGuid().ToString();
                string filePath = "//WorkTime//InputExcelFiles//" + Guid.NewGuid().ToString() + System.IO.Path.GetExtension(Request.Files[0].FileName);
                this.Request.Files[0].SaveAs(Server.MapPath(filePath));
                ExcelProcessor ep = ExcelService.GetProcessor(Server.MapPath(filePath));
                DataSet ds = ep.GetDataSet();
                InputDatas(ds.Tables[0]);
                Response.Write("{success:true}");
                Response.End();
            }

            id = RequestData.Get<string>("id", String.Empty);
            type = RequestData.Get<string>("type", String.Empty);
            SearchCriterion.AutoOrder = false;
            SearchCriterion.SetOrder(SysUser.Prop_WorkNo);
            users = SysUserRule.FindAll(SearchCriterion);

            this.PageState.Add("UsrList", users);

            SysUser usr = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Create:
                    usr = this.GetPostedData<SysUser>();
                    usr.DoCreate();
                    this.SetMessage("新建成功！");
                    break;
                case RequestActionEnum.Update:
                    usr = this.GetMergedData<SysUser>();
                    usr.DoUpdate();
                    this.SetMessage("保存成功！");
                    break;
                case RequestActionEnum.Delete:
                    usr = this.GetTargetData<SysUser>();
                    usr.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
            }
        }

        #endregion

        #region 私有方法

        private void InputDatas(DataTable dt)
        {
            foreach (DataRow row in dt.Rows)
            {
                if (row[2] != null && row[2].ToString().Trim() != "")
                {
                    string workNo = "";
                    try
                    {
                        if (SysUser.FindAllByProperties("WorkNo", row[1].ToString()).Length == 0)
                        {
                            SysUser sysUser = new SysUser();
                            sysUser.WorkNo = row[1].ToString();
                            sysUser.Name = row[2].ToString();
                            sysUser.LoginName = row[3].ToString();
                            sysUser.Email = row[5].ToString();
                            sysUser.Remark = row[6].ToString();
                            sysUser.Status = 1;
                            sysUser.Save();
                            if (SysGroup.FindAllByProperties("Name", row[4].ToString()).Length > 0)
                            {
                                using (new SessionScope())
                                {
                                    SysGroup grp = SysGroup.FindAllByProperties("Name", row[4].ToString())[0];

                                    IList<string> userIDs = new List<string>();
                                    userIDs.Add(sysUser.UserID);
                                    grp.AddUsers(userIDs);
                                }
                            }
                        }

                    }
                    catch (Exception e)
                    {
                        continue;
                    }
                }
            }
        }
        #endregion
    }
}

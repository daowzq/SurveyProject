using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;
using Aim.Data;

namespace Aim.Examining.Web.Common
{
    public partial class UserContextInfo : BaseListPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        /// <summary>
        /// 获取公司当前公司ID
        /// </summary>
        /// <param name="UID"></param>
        /// <returns></returns>
        public string GetUserCurrentCorpId(string UID)
        {
            string CorpIds = string.Empty;
            // 判断公司登陆
            if (Session["CompanyId"] != null)
            {
                CorpIds = Session["CompanyId"] + "";
            }
            else
            {
                SysUser UsrEnt = SysUser.Find(UID);
                CorpIds = UsrEnt.Pk_corp;
            }
            return CorpIds;
        }
    }
}
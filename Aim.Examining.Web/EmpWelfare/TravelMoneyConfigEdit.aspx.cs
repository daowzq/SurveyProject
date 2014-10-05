using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using Aim.Examining.Web.EmpWelfare;

namespace Aim.Examining.Web
{
    public partial class TravelMoneyConfigEdit : ExamBasePage
    {

        string op = String.Empty; // 用户编辑操作
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 对象类型

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op");
            id = RequestData.Get<string>("id");
            type = RequestData.Get<string>("type");

            TravelMoneyConfig ent = null;

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<TravelMoneyConfig>();
                    ent.DoUpdate();
                    break;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    ent = this.GetPostedData<TravelMoneyConfig>();
                    ent.DoCreate();
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<TravelMoneyConfig>();
                    ent.DoDelete();
                    return;
                default:
                    if (RequestActionString == "SelectVal")
                    {
                        GetDetailInfo();
                    }
                    break;
            }

            if (op != "c" && op != "cs")
            {
                if (!String.IsNullOrEmpty(id))
                {
                    ent = TravelMoneyConfig.Find(id);
                }

                this.SetFormData(ent);
            }
        }

        /// <summary>
        /// 获取人员信息
        /// </summary>
        private void GetDetailInfo()
        {
            string UserId = RequestData.Get("UserId") + "";
            if (!string.IsNullOrEmpty(UserId))
            {
                SysUser UsrEnt = SysUser.Find(UserId);
                SysGroup CrpEnt = SysGroup.Find(UsrEnt.Pk_corp);
                string val = UsrEnt.WorkNo + "|" + CrpEnt.GroupID + "|" + CrpEnt.Name + "|" + UsrEnt.Indutydate;

                string Money = string.Empty;
                ComUtility Utility = new ComUtility();
                Money = Utility.GetTravelMoney(UsrEnt.WorkNo);

                val = val + "|" + Money + "|" + Utility.GetTravelBaseMoney(UsrEnt.WorkNo);
                this.PageState.Add("RtnVal", val);
            }
        }
    }
}


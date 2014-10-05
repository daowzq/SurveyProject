using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Castle.ActiveRecord;
using NHibernate;
using NHibernate.Criterion;
using Aim.Data;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;
using Aim.Examining.Model;
using System.Data;

namespace Aim.Examining.Web.EmpWelfare
{
    public partial class Welfareconfig : ExamListPage
    {
        private IList<WelfareConfig> ents = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            WelfareConfig ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<WelfareConfig>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        DoBatchDelete();
                    }
                    else if (RequestActionString == "batchsave")
                    {
                        btnSave();
                    }
                    else if (RequestActionString == "SaveItem")
                    {
                        SaveItem();
                    }
                    else if (RequestActionString == "GetID")
                    {
                        //string strGUID = System.Guid.NewGuid().ToString();
                        //string sql = " select * from FL_Culture..WelfareConfig where Id='" + strGUID + "'";
                        //DataTable dt = DataHelper.QueryDataTable(sql);
                        //while (dt.Rows.Count != 0)
                        //{
                        //    strGUID = System.Guid.NewGuid().ToString();
                        //    sql = " select * from FL_Culture..WelfareConfig where Id='" + strGUID + "'";
                        //    dt = DataHelper.QueryDataTable(sql);
                        //}
                        WelfareConfig Ent = new WelfareConfig();
                        Ent.Create();
                        this.PageState.Add("thisid", Ent.Id);
                    }
                    else if (RequestActionString == "ISEnable")
                    {
                        string ISEnable = RequestData.Get<string>("Enable");
                        string ID = RequestData.Get<string>("ID");
                        string sql = " update  FL_Culture..WelfareConfig set ISEnable='" + ISEnable + "' where Id in(" + ID + ")";
                        DataHelper.ExecSql(sql);
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }
        }

        /// <summary>
        /// 查询
        /// </summary>
        private void DoSelect()
        {
            string sql = @"select B.GroupID As CorpId ,B.Name As CorpName from sysuser As A 
	                       left join SysGroup As B
                             on A.Pk_corp=B.GroupID
	                       where A.UserID='{0}' ";
            sql = string.Format(sql, UserInfo.UserID);
            DataTable Dt = DataHelper.QueryDataTable(sql);

            CommPowerSplit ps = new CommPowerSplit();
            if (ps.IsHR(UserInfo.UserID, UserInfo.LoginName) || ps.IsSetMgrRole(UserInfo.UserID, UserInfo.LoginName)) //设置管理角色 or HR
            {
                ents = WelfareConfig.FindAll(SearchCriterion);
            }
            else
            {
                string CorpIds = string.Empty;
                SysUser Ent = SysUser.Find(UserInfo.UserID);

                // 判断公司登陆
                if (Session["CompanyId"] != null)
                {
                    CorpIds = Session["CompanyId"] + "";
                }
                else
                {
                    CorpIds = Ent.Pk_corp;
                }
                ents = WelfareConfig.FindAll(SearchCriterion, Expression.Sql("CorpId='" + CorpIds + "' or CreateId='" + UserInfo.UserID + "' "));
            }

            this.PageState.Add("DataList", ents);
        }

        /// <summary>
        /// 批量删除
        /// </summary>
        [ActiveRecordTransaction]
        private void DoBatchDelete()
        {
            IList<object> idList = RequestData.GetList<object>("IdList");

            if (idList != null && idList.Count > 0)
            {
                WelfareConfig.DoBatchDelete(idList.ToArray());
            }
        }

        //保存
        private void SaveItem()
        {
            //frist delete
            //string sql = "delete  from  FL_Culture..WelfareConfig where CorpId is null or  CorpId='' or TravelAddress is null ";
            //DataHelper.ExecSql(sql);

            IList<string> DataList = RequestData.GetList<string>("strRec");
            if (DataList.Count > 0)
            {
                IList<WelfareConfig> qiEnts = DataList.Select(tent => JsonHelper.GetObject<WelfareConfig>(HttpUtility.UrlDecode(tent)) as WelfareConfig).ToArray();
                foreach (WelfareConfig itms in qiEnts)
                {
                    itms.DoSave();
                }
            }
        }

        private void btnSave()
        {
            IList<string> entStrList = RequestData.GetList<string>("data");

            if (entStrList != null && entStrList.Count > 0)
            {
                IList<WelfareConfig> ents = entStrList.Select(tent => JsonHelper.GetObject<WelfareConfig>(tent) as WelfareConfig).ToList();

                foreach (WelfareConfig ent in ents)
                {
                    if (ent != null)
                    {
                        WelfareConfig tent = ent;

                        if (String.IsNullOrEmpty(tent.Id))
                        {
                            tent.CreateId = UserInfo.UserID;
                            tent.CreateName = UserInfo.Name;
                        }
                        else
                        {
                            tent = DataHelper.MergeData(WelfareConfig.Find(tent.Id), tent);
                        }

                        tent.DoSave();
                    }
                }
            }
        }
    }
}

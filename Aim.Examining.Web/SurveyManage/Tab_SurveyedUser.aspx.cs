using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using NHibernate.Criterion;
using System.Data.OleDb;
using System.Data;
using System.IO;
using System.Text;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class Tab_SurveyedUser : BaseListPage
    {

        public Tab_SurveyedUser()
        {
            SearchCriterion.PageSize = 40;
        }

        string SurveyId = string.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            SurveyId = RequestData.Get("SurveyId") + "";
            switch (RequestActionString)
            {
                case "Save":
                    DoSave();
                    break;
                case "batchdelete":
                    DoBatchDelete();
                    break;
                case "EffectiveCount":
                    GetEffectiveCount();
                    break;

                default:
                    DoSelect();
                    break;
            }
        }

        /// <summary>
        /// 获取有效问卷数量
        /// </summary>
        private void GetEffectiveCount()
        {
            string value = "";
            if (!string.IsNullOrEmpty(SurveyId))
            {
                //var UsrEnt = SurveyFinallyUsr.FindAllByProperty(SurveyFinallyUsr.Prop_SurveyId, SurveyId);
                //value += UsrEnt.Length + "|"; ;
                //var Ent = SurveyQuestion.Find(SurveyId);
                //value = Ent.EffectiveCount.ToString();
                string SQL = @"select  cast(T as varchar(10))+'|'+cast( isnull(EffectiveCount,'') as varchar(10)) As total from  
                                FL_Culture..SurveyQuestion,
                                (select count(1) AS T from FL_Culture..SurveyFinallyUsr where SurveyId='{0}'  )AS T
                                where Id='{0}' ";
                SQL = string.Format(SQL, SurveyId);
                object obj = DataHelper.QueryValue(SQL);
                if (obj != null)
                {
                    value = obj.ToString();
                }
                else
                {
                    value = "|";
                }
            }
            this.PageState.Add("value", value);
        }

        [ActiveRecordTransaction]
        private void DoBatchDelete()
        {
            IList<object> idList = RequestData.GetList<object>("IdList");

            if (idList != null && idList.Count > 0)
            {
                SurveyFinallyUsr.DoBatchDelete(idList.ToArray());
            }
        }

        //保存
        private void DoSave()
        {
            if (!String.IsNullOrEmpty(SurveyId))
            {
                IList<SurveyFinallyUsr> Ent = RequestData.GetList<object>("Record").Select(ten => { return JsonHelper.GetObject<SurveyFinallyUsr>(ten.ToString()); }).ToArray();

                //先删除
                string SQL = "delete from FL_Culture..SurveyFinallyUsr where SurveyId='{2}' and ( '{0}' like '%'+ UserId+'%' Or '{1}' like '%'+ WorkNo+'%' ) ";
                StringBuilder UserId = new StringBuilder();
                StringBuilder WorkNo = new StringBuilder();
                for (int i = 0; i < Ent.Count; i++)
                {
                    UserId.Append(Ent[i].UserId);
                    WorkNo.Append(Ent[i].WorkNo);
                }
                SQL = string.Format(SQL, UserId, WorkNo, SurveyId);
                DataHelper.ExecSql(SQL);
                //保存
                foreach (var ent in Ent)
                {
                    ent.SurveyId = SurveyId;
                    ent.DoCreate();
                }
            }
        }


        private void DoSelect()
        {
            if (!string.IsNullOrEmpty(SurveyId))
            {
                string where = "";
                foreach (CommonSearchCriterionItem item in SearchCriterion.Searches.Searches)
                {
                    if (!String.IsNullOrEmpty(item.Value.ToString()))
                    {
                        switch (item.PropertyName)
                        {
                            case "StartTime":
                                where += " and CreateTime>='" + item.Value + "' ";
                                break;
                            case "EndTime":
                                where += " and CreateTime<='" + (item.Value.ToString()).Replace(" 0:00:00", " 23:59:59") + "' ";
                                break;
                            default:
                                where += " and " + item.PropertyName + " like '%" + item.Value + "%' ";
                                break;
                        }
                    }
                }
                //SearchCriterion.SetSearch("SurveyId", SurveyId);
                //SearchCriterion.SetOrder("CreateWay");
                //SurveyFinallyUsr[] SuEnt = SurveyFinallyUsr.FindAll(SearchCriterion);
                // this.PageState.Add("DataList1", SuEnt);
                string SQL = @"select distinct A.*,B.Phone,B.Email,
                                 case when C.State='1' then '是'
                                      when C.State='0' then '否'
                                      else '否'
                                 end As EmailIsFilled,
                                 case when C.PhoneState='1' then '是'
                                      when C.PhoneState='0' then '否'
                                      else '否'
                                 end As MsgIsFilled,
								case when  D.Id is null then 'N' when D.Id is not null  then 'Y' end As Commited 
                                from  FL_Culture..SurveyFinallyUsr As A 
                                left join FL_PortalHR..SysUser As B
	                                on A.UserID=B.UserID
                                left join FL_Recruitment..Remind As C
	                                on A.UserID =C.UserId and C.EXT1='S|'+A.Surveyid 
							    left join  FL_Culture..SurveyCommitHistory As D	
								    on A.UserId=D.SurveyedUserId and  D.SurveyId=A.SurveyId
                                where A.SurveyId='{0}' ";
                SQL += where;
                SQL = string.Format(SQL, SurveyId);
                SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);
                SQL = SQL.Replace("FL_Recruitment", Global.FL_Recruitment);
                SearchCriterion.SetOrder("CreateWay");
                this.PageState.Add("DataList1", GetPageData(SQL, SearchCriterion));
            }
        }

        private IList<EasyDictionary> GetPageData(String sql, SearchCriterion search)
        {
            SearchCriterion.RecordCount = DataHelper.QueryValue<int>("select count(*) from (" + sql + ") t");
            string order = search.Orders.Count > 0 ? search.Orders[0].PropertyName : "CreateTime";
            string asc = search.Orders.Count <= 0 || !search.Orders[0].Ascending ? " desc" : " asc";
            string pageSql = @"
		    WITH OrderedOrders AS
		    (SELECT *,
		    ROW_NUMBER() OVER (order by {0} {1})as RowNumber
		    FROM ({2}) temp ) 
		    SELECT * 
		    FROM OrderedOrders 
		    WHERE RowNumber between {3} and {4}";
            pageSql = string.Format(pageSql, order, asc, sql, (search.CurrentPageIndex - 1) * search.PageSize + 1, search.CurrentPageIndex * search.PageSize);
            IList<EasyDictionary> dicts = DataHelper.QueryDictList(pageSql);
            return dicts;
        }

    }
}

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
using System.Data;
using Aim.Examining.Web.Common;
namespace Aim.Examining.Web.ReportSheet
{
    public partial class LeaveReasonDetail : BaseListPage
    {
        public List<QItem> QItm = new List<QItem>();
        public int MonthTotal = 0;   //该月份总和
        public int YearTotal = 0;    //该年份总和

        protected void Page_Load(object sender, EventArgs e)
        {

            string qryYear = RequestData.Get("year") + "";
            string qryMonth = RequestData.Get("month") + "";
            string SurveyId = RequestData.Get("SurveyId") + "";

            if (string.IsNullOrEmpty(qryYear) || string.IsNullOrEmpty(qryMonth))
            {
                qryYear = DateTime.Now.Year.ToString();
                qryMonth = DateTime.Now.Month.ToString();
            }
            if (string.IsNullOrEmpty(SurveyId)) SurveyId = GetString();

            DoSelect(qryYear, qryMonth, SurveyId);
        }

        public void DoSelect(string year, string month, string SurveyId)
        {
            //问题项
            string sql = @" select Distinct * from FL_Culture..QuestionItem where SurveyId='{0}'
	                        and '单选项,多选项' like '%'+QuestionType+'%' and  Content like '%主要原因%' ";
            sql = string.Format(sql, SurveyId);
            DataTable TypeDt = DataHelper.QueryDataTable(sql);

            //选择项
            sql = @"select A.Id,A.SurveyTitle,A.Content, A.SubItemId,A.SortIndex,
	                        B.Id As ItemId,B.AnSwer,B.SortIndex
                        from (
	                        select * from FL_Culture..QuestionItem where SurveyId='{0}'
	                        and '单选项,多选项' like '%'+QuestionType+'%'
                        ) As A 
                        left join   FL_Culture..QuestionAnswerItem As B
                         on A.SubItemId=B.QuestionItemId and A.SurveyId=B.SurveyId
                        where Content like '%主要原因%'
                        order by A.SortIndex,B.SortIndex";
            sql = string.Format(sql, SurveyId);
            DataTable QDt = DataHelper.QueryDataTable(sql);

            //每月
            sql = @"select QuestionId, QuestionItemId,count(QuestionItemId) As ChoiceTotal 
                    from FL_Culture..SurveyedResult As A
                        left join FL_PortalHR..SysUser As B
				        on A.UserId=B.UserID
                    where 
                        surveyId='{0}'  
                        and QuestionItemContent='1'  
	                    and year(CreateTime)={1} and month(CreateTime)={2} 
                        and Len(QuestionItemId)>0  and 1=1
                    group by QuestionId,QuestionItemId order by QuestionId";
            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);
            sql = string.Format(sql, SurveyId, year, month);

            //权限过滤
            CommPowerSplit PS = new CommPowerSplit();
            if (PS.IsHR(UserInfo.UserID, UserInfo.LoginName) || PS.IsAdmin(UserInfo.LoginName) || PS.IsInAdminsRole(UserInfo.UserID))
            {

            }
            else
            {
                UserContextInfo UC = new UserContextInfo();
                sql = sql.Replace("and 1=1", " and  B.Pk_corp='" + UC.GetUserCurrentCorpId(UserInfo.UserID) + "' ");
            }
            DataTable ItemTal = DataHelper.QueryDataTable(sql);

            //每月和
            int monthTotal = 0;
            if (ItemTal.Rows.Count > 0)
            {
                for (int i = 0; i < ItemTal.Rows.Count; i++)
                {
                    int temp = 0;
                    if (int.TryParse(ItemTal.Rows[i]["ChoiceTotal"].ToString(), out temp))
                    {
                        monthTotal += temp;
                    }
                }
            }
            MonthTotal = monthTotal;

            //全年每项
            sql = @"select QuestionId, count(QuestionId) As ChoiceTotal 
                    from FL_Culture..SurveyedResult As A
                         left join FL_PortalHR..SysUser As B
				            on A.UserId=B.UserID
	                where  
                        surveyId='{0}' 
                        and QuestionItemContent='1' and 1=1 
                        and  year(CreateTime)={1}  and Len(QuestionItemId)>0
                    group by QuestionId  order by QuestionId";

            sql = string.Format(sql, SurveyId, year);
            sql = sql.Replace("FL_PortalHR", Global.AimPortalDB);

            //权限过滤
            if (PS.IsHR(UserInfo.UserID, UserInfo.LoginName) || PS.IsAdmin(UserInfo.LoginName) || PS.IsInAdminsRole(UserInfo.UserID))
            {

            }
            else
            {
                UserContextInfo UC = new UserContextInfo();
                sql = sql.Replace("and 1=1", " and  B.Pk_corp='" + UC.GetUserCurrentCorpId(UserInfo.UserID) + "' ");
            }

            DataTable YearDt = DataHelper.QueryDataTable(sql);
            //全年和
            int yearTotal = 0;
            if (YearDt.Rows.Count > 0)
            {
                for (int i = 0; i < YearDt.Rows.Count; i++)
                {
                    int temp = 0;
                    if (int.TryParse(YearDt.Rows[i]["ChoiceTotal"].ToString(), out temp))
                    {
                        yearTotal += temp;
                    }
                }
            }
            YearTotal = yearTotal;

            for (int i = 0; i < TypeDt.Rows.Count; i++)
            {
                //问题项
                QItem tempItem = new QItem();
                tempItem.type = TypeDt.Rows[i]["Content"].ToString();

                //子项
                DataRow[] rows = QDt.Select(" Id='" + TypeDt.Rows[i]["Id"] + "' ");
                tempItem.items = new List<string>();
                tempItem.itemsChoices = new List<string>();
                for (int j = 0; j < rows.Length; j++)
                {
                    tempItem.items.Add(rows[j]["AnSwer"].ToString());
                    DataRow tempRow = ItemTal.Select(" QuestionItemId='" + rows[j]["ItemId"] + "' ").FirstOrDefault();
                    if (tempRow == null)
                        tempItem.itemsChoices.Add("0");
                    else
                        tempItem.itemsChoices.Add(tempRow["ChoiceTotal"].ToString());
                }

                //每年该项
                if (YearDt.Rows.Count > 0)
                {
                    DataRow yearRow = YearDt.Select(" QuestionId ='" + TypeDt.Rows[i]["Id"] + "'").FirstOrDefault();
                    if (yearRow == null)
                        tempItem.yearTotal = 0;
                    else
                        tempItem.yearTotal = int.Parse(string.IsNullOrEmpty(yearRow["ChoiceTotal"].ToString()) ? "0 " : yearRow["ChoiceTotal"].ToString());
                }
                QItm.Add(tempItem);
            }


        }

        /// <summary>
        /// 获取离职问卷Id
        /// </summary>
        private string GetString()
        {
            string sql = "select top 1 * from FL_Culture..SurveyQuestion where IsFixed='2' and State='1' and SurveyTypeId<>''";
            DataTable Dt = DataHelper.QueryDataTable(sql);
            if (Dt.Rows.Count > 0)
            {
                return Dt.Rows[0]["Id"].ToString();
            }
            else
            {
                return "";
            }
        }


    }

    /// <summary>
    /// 问题项模板
    /// </summary>
    public class QItem
    {
        public string type { get; set; }
        public int monthUsrCount { get; set; }
        public decimal monthRate { get; set; }

        public int yearUsrCount { get; set; }
        public decimal yearUsrRate { get; set; }

        public List<string> items { get; set; }
        public List<string> itemsChoices { get; set; }

        public int yearTotal { get; set; }
    }
}

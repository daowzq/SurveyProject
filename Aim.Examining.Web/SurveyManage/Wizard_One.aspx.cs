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

namespace Aim.Examining.Web.SurveyManage
{
    public partial class Wizard_One : BaseListPage
    {

        string op = string.Empty;
        string id = string.Empty;
        SurveyQuestion ent = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            id = RequestData.Get("id") + "";
            op = RequestData.Get("op") + "";
            string SurveyTypeId = RequestData.Get("SurveyTypeId") + "";
            string SurveyTypeName = RequestData.Get("SurveyTypeName") + "";

            switch (RequestAction)
            {
                case RequestActionEnum.Update:

                    ent = this.GetMergedData<SurveyQuestion>();
                    if (string.IsNullOrEmpty(ent.State)) ent.State = "0";  //"0" 表示创建
                    ent.SurveyTypeId = SurveyTypeId;
                    ent.SurveyTypeName = SurveyTypeName;
                    ent.DoUpdate();
                    this.SetFormData(ent);
                    break;
                default:
                    if (RequestActionString == "GetTypeInfo")
                    {
                        GetAddFiles();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }
        }


        private void DoSelect()
        {
            //问卷类型
            string SQL = @" select '' As Id, '请选择...' As TypeName
                            union all 
                            select Id,TypeName from FL_Culture..SurveyType
	                        where ( EnabledState='1' or (EnabledState='1' and (AccessPower is null or len(AccessPower)=0))) 
                            and Id in (select distinct TypeId from FL_Culture..View_SuryTypeUsr where UserID='{0}') ";
            SQL = string.Format(SQL, UserInfo.UserID);
            this.PageState.Add("TypeEnum", DataHelper.QueryDict(SQL));

            //问卷模板
            SQL = @" select Id,SurveyTitile As Name from FL_Culture..SurveyQuestion where IsFixed='1' and state='1' ";

            SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

            PageState.Add("tplEnum", DataHelper.QueryDict(SQL));

            if (!string.IsNullOrEmpty(id) && op != "c")
            {
                ent = SurveyQuestion.Find(id);

                if (string.IsNullOrEmpty(ent.TypeCode))
                {
                    ent.TypeCode = GetCode(); //设置问卷编号
                }
                if (string.IsNullOrEmpty(ent.CompanyId))
                {
                    //公司与部门
                    SQL = @"select A.UserID,A.WorkNo,A.Name,B.GroupID as CropId,B.Name as CropName,
                                    C.GroupID as DeptId,C.Name as DeptName
                             from FL_PortalHR..SysUser As A
	                            left join FL_PortalHR..SysGroup As B
                              on  A.Pk_corp=B.GroupID
	                            left join  FL_PortalHR..SysGroup As C
                              on A.Pk_deptdoc=C.GroupID
                            where UserID='{0}' ";

                    SQL = SQL.Replace("FL_PortalHR", Global.AimPortalDB);

                    SQL = string.Format(SQL, UserInfo.UserID);
                    DataTable dt = DataHelper.QueryDataTable(SQL);
                    ent.CompanyId = dt.Rows[0]["CropId"].ToString();
                    ent.CompanyName = dt.Rows[0]["CropName"].ToString();

                    ent.DeptId = dt.Rows[0]["DeptId"].ToString();
                    ent.DeptName = dt.Rows[0]["DeptName"].ToString();
                }
                this.SetFormData(ent);
            }

        }

        //调查问卷编号
        private string GetCode()
        {
            //WGM  2013/7/16
            //string SQL = "select FL_Culture.dbo.fn_ChineseToSpell('" + UserInfo.Name + "') ";
            //string Spell = DataHelper.QueryValue(SQL).ToString();
            //return "HR_WJ" + Spell.ToUpper() + DateTime.Now.Year + DateTime.Now.Month + DateTime.Now.Day + DateTime.Now.Minute;

            return "HR_W" + DateTime.Now.Year + DateTime.Now.Month + DateTime.Now.Day + DateTime.Now.Minute;
        }

        /// <summary>
        /// 获取附件等相关信息
        /// </summary>
        private void GetAddFiles()
        {
            string typeId = RequestData.Get("typeId") + "";
            string SQL = @"select AddFilesId,AddFilesName,WorkFlowId,WorkFlowName from  FL_Culture..SurveyType where Id='{0}'";
            SQL = string.Format(SQL, typeId);
            this.PageState.Add("TypeInfo", DataHelper.QueryDictList(SQL));
        }

    }
}

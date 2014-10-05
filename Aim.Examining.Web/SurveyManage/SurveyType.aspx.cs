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

namespace Aim.Examining.Web.SurveyManage
{
    public partial class SurveyType : BaseListPage
    {

        private IList<Model.SurveyType> ents = null;
        string id = string.Empty;  //数据ID
        protected void Page_Load(object sender, EventArgs e)
        {
            id = RequestData.Get("id") + "";
            Model.SurveyType ent = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<Model.SurveyType>();
                    ent.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                default:
                    if (RequestActionString == "batchdelete")
                    {
                        DoBatchDelete();
                    }
                    else if (RequestActionString == "StartType")
                    {
                        DoStartType();
                    }
                    else if (RequestActionString == "StopType")
                    {
                        DoStopType();
                    }
                    else if (RequestActionString == "IsRef")
                    {
                        CheckRef();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }
        }

        //启用类型状态
        private void DoStartType()
        {
            if (!string.IsNullOrEmpty(id))
            {
                Model.SurveyType ent = Model.SurveyType.Find(id);
                ent.EnabledState = "1";
                ent.DoUpdate();
                this.PageState.Add("State", "Secuss");
            }
        }
        private void DoStopType()
        {
            if (!string.IsNullOrEmpty(id))
            {
                Model.SurveyType ent = Model.SurveyType.Find(id);
                ent.EnabledState = "0";
                ent.DoUpdate();
                this.PageState.Add("State", "Secuss");
            }
        }

        #region 私有方法

        /// <summary>
        /// 查询
        /// </summary>
        private void DoSelect()
        {
            SearchCriterion.SetOrder("SortIndex");
            ents = Model.SurveyType.FindAll(SearchCriterion);
            this.PageState.Add("DataList", ents);
        }


        /// <summary>
        /// 检查是否引用
        /// </summary>
        private void CheckRef()
        {
            string TypeName = RequestData.Get("TypeName") + "";
            string SQL = @"select  *  from  FL_Culture..SurveyQuestion where IsFixed <>'1' and SurveyTypeName='{0}' ";
            SQL = string.Format(SQL, TypeName);
            Object Obj = DataHelper.QueryValue(SQL);
            if (Obj != null)
            {
                this.PageState.Add("State", "1");
            }
            else
            {
                this.PageState.Add("State", "0");
            }
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
                Model.SurveyType.DoBatchDelete(idList.ToArray());
            }
        }

        #endregion
    }
}

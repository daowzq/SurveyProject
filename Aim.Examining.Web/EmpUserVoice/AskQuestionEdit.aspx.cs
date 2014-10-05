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
using System.Data;

namespace Aim.Examining.Web
{
    public partial class AskQuestionEdit : ExamBasePage
    {
        #region 变量

        string op = String.Empty; // 用户编辑操作
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 对象类型

        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op");
            id = RequestData.Get<string>("id");
            type = RequestData.Get<string>("type");

            EmpVoiceAskQuestion ent = null;

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<EmpVoiceAskQuestion>();
                    ent.DoUpdate();
                    this.PageState.Add("Ent", ent);
                    break;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    string Anonymity = this.RequestData.Get("Anonymity") + "";
                    ent = this.GetPostedData<EmpVoiceAskQuestion>();
                    ent.Anonymity = Anonymity; //1 表示匿名
                    ent.DoCreate();

                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<EmpVoiceAskQuestion>();
                    ent.DoDelete();

                    return;
                default:
                    Doselect();
                    break;

            }


        }

        private void Doselect()
        {
            EmpVoiceAskQuestion ent = null;
            if (op != "c" && op != "cs")
            {
                if (!String.IsNullOrEmpty(id))
                {
                    ent = EmpVoiceAskQuestion.Find(id);
                }
                this.SetFormData(ent);
            }
            else
            {
                var Ent = SysUser.FindFirstByProperties("UserID", UserInfo.UserID);
                //公司与部门
                string SQL = @"select B.GroupID As CompanyId,B.Name As CompanyName,C.GroupID AS DeptId,C.Name As DeptName
                        from  sysuser As A
	                        left join sysgroup As B
	                        on A.pk_corp=B.groupID
                        left join sysgroup As C
	                        on C.GroupID=A.pk_deptdoc
                        where A.UserID='{0}'";
                SQL = string.Format(SQL, UserInfo.UserID);
                DataTable Dt1 = DataHelper.QueryDataTable(SQL);

                string CompanyName = string.Empty, CompanyId = string.Empty;
                string DeptName = string.Empty, DeptId = string.Empty;

                if (Dt1.Rows.Count > 0)
                {
                    CompanyName = Dt1.Rows[0]["CompanyName"].ToString();
                    CompanyId = Dt1.Rows[0]["CompanyId"].ToString();
                    DeptId = Dt1.Rows[0]["DeptId"].ToString();
                    DeptName = Dt1.Rows[0]["DeptName"].ToString();
                }

                if (Ent != null)
                {
                    var Obj = new
                    {
                        UserId = Ent.UserID,
                        UserName = Ent.Name,
                        Sex = Ent.Sex,
                        Age = Ent.Wage,
                        WorkNo = Ent.WorkNo,
                        IndutyData = Ent.Indutydate,

                        CorpName = CompanyName,
                        CorpId = CompanyId,
                        DeptId = DeptId,
                        DeptName = DeptName,


                    };
                    this.SetFormData(Obj);
                }
            }

            this.PageState.Add("QuestionEnum", SysEnumeration.GetEnumDict("QuestionType"));
        }
    }
}


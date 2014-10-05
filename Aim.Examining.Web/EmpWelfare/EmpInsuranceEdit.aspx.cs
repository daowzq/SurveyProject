using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Web;
using System.Data;
using Aim.Examining.Model;
using Aim.Examining.Web.EmpWelfare;
using Aim.Portal.Model;
using Newtonsoft.Json.Linq;

namespace Aim.Examining.Web
{
    public partial class EmpInsuranceEdit : ExamBasePage
    {

        string op = String.Empty; // 用户编辑操作
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 对象类型 
        EmpInsurance ent = null;
        string JsonString = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op");
            id = RequestData.Get<string>("id");
            type = RequestData.Get<string>("type");
            JsonString = RequestData.Get<string>("JsonString");
            if (!string.IsNullOrEmpty(id))
            {
                ent = EmpInsurance.Find(id);
            }
            switch (RequestActionString)
            {
                case "update":
                    if (!string.IsNullOrEmpty(JsonString))
                    {
                        ent = JsonHelper.GetObject<EmpInsurance>(JsonString);
                    }
                    if (string.IsNullOrEmpty(ent.Id))
                    {
                        ent.CreateId = UserInfo.UserID;
                        ent.CreateName = UserInfo.Name;
                        ent.CreateTime = DateTime.Now;
                        ent.DoCreate();
                    }
                    else
                    {
                        ent.DoUpdate();
                    }
                    ent.State = "待提交";
                    PageState.Add("Id", ent.Id);
                    break;
                case "submit":
                    if (!string.IsNullOrEmpty(JsonString))
                    {
                        ent = JsonHelper.GetObject<EmpInsurance>(JsonString);
                    }
                    ent.ApplyTime = DateTime.Now;//申请时间在提交审批的时候赋值
                    if (string.IsNullOrEmpty(ent.Id))
                    {
                        ent.CreateId = UserInfo.UserID;
                        ent.CreateName = UserInfo.Name;
                        ent.CreateTime = DateTime.Now;
                        ent.DoCreate();
                    } 
                    IList<SysApproveConfig> sacEnts = SysApproveConfig.FindAll();
                    if (sacEnts.Count > 0)
                    {
                        ent.ApproveUserId = sacEnts[0].ChildWelfareId;
                        ent.ApproveName = sacEnts[0].ChildWelfareName;
                    }
                    ent.State = "已提交";
                    ent.DoUpdate();
                    PageState.Add("Id", ent.Id);
                    break;
                case "GetWorkNo":
                    string UserID = RequestData.Get("UserID") + "";
                    ComUtility Ut = new ComUtility();
                    PageState.Add("WorkNo", Ut.GetWorkNo(UserID));
                    break;
                default:
                    DoSelect();
                    break;
            }
        }
        private void DoSelect()
        {
            if (ent != null)
            {
                SetFormData(ent);
                IList<EasyDictionary> dics = new List<EasyDictionary>();
                if (!string.IsNullOrEmpty(ent.FamilyNames))
                {
                    string[] fns = ent.FamilyNames.Split(new string[] { ";" }, StringSplitOptions.RemoveEmptyEntries);
                    string[] fgs = ent.FamilyGenders.Split(new string[] { ";" }, StringSplitOptions.RemoveEmptyEntries);
                    string[] fis = ent.FamilyIdentities.Split(new string[] { ";" }, StringSplitOptions.RemoveEmptyEntries);
                    for (int i = 0; i < fns.Length; i++)
                    {
                        EasyDictionary dic = new EasyDictionary();
                        dic.Add("FamilyName", fns[i]);
                        dic.Add("FamilyGender", fgs[i]);
                        dic.Add("FamilyIdentity", fis[i]);
                        dics.Add(dic);
                    }
                    PageState.Add("DataList", dics);
                }
            }
            //            if (op == "c" || op == "create")  //创建生成编号
            //            {
            //                var Ent = SysUser.FindFirstByProperties("UserID", UserInfo.UserID);

            //                //用来获取配置的审批人
            //                string SQL = "select top 1 * from  FL_Culture..SysApproveConfig where CompanyId='{0}' and len(ChildWelfareId)>0 ";
            //                SQL = string.Format(SQL, Ent.Pk_corp);
            //                DataTable Dt = DataHelper.QueryDataTable(SQL);

            //                //公司与部门
            //                SQL = @"select B.GroupID As CompanyId,B.Name As CompanyName,C.GroupID AS DeptId,C.Name As DeptName
            //                        from  sysuser As A
            //	                        left join sysgroup As B
            //	                        on A.pk_corp=B.groupID
            //                        left join sysgroup As C
            //	                        on C.GroupID=A.pk_deptdoc
            //                        where A.UserID='{0}'";
            //                SQL = string.Format(SQL, UserInfo.UserID);
            //                DataTable Dt1 = DataHelper.QueryDataTable(SQL);

            //                string CompanyName = string.Empty, CompanyId = string.Empty;
            //                string DeptName = string.Empty, DeptId = string.Empty;

            //                if (Dt1.Rows.Count > 0)
            //                {
            //                    CompanyName = Dt1.Rows[0]["CompanyName"].ToString();
            //                    CompanyId = Dt1.Rows[0]["CompanyId"].ToString();
            //                    DeptId = Dt1.Rows[0]["DeptId"].ToString();
            //                    DeptName = Dt1.Rows[0]["DeptName"].ToString();
            //                }

            //                if (Ent != null)
            //                {
            //                    var Obj = new
            //                    {
            //                        UserId = Ent.UserID,
            //                        UserName = Ent.Name,
            //                        Sex = Ent.Sex,
            //                        Age = Ent.Wage,
            //                        WorkNo = Ent.WorkNo,
            //                        IndutyData = Ent.Indutydate,

            //                        CompanyName = CompanyName,
            //                        CompanyId = CompanyId,
            //                        DeptId = DeptId,
            //                        DeptName = DeptName,

            //                        ApproveName = Dt == null ? "" : Dt.Rows.Count > 0 ? Dt.Rows[0]["ChildWelfareName"].ToString() : "",
            //                        ApproveUserId = Dt == null ? "" : Dt.Rows.Count > 0 ? Dt.Rows[0]["ChildWelfareId"].ToString() : ""
            //                    };
            //                    this.SetFormData(Obj);
            //                }
            //            }
        }
    }
}


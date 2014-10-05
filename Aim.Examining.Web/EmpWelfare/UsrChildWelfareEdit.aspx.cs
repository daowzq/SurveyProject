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
using Aim.WorkFlow;
using System.Data;

namespace Aim.Examining.Web
{
    public partial class UsrChildWelfareEdit : ExamBasePage
    {
        #region 变量

        string op = String.Empty; // 用户编辑操作
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 对象类型
        string UserId = string.Empty;  //
        string UserName = string.Empty;  //
        SysUser UserEnt = null;
        string CorpId = string.Empty;
        #endregion


        UsrChildWelfare ent = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            op = RequestData.Get<string>("op");
            id = RequestData.Get<string>("id");
            type = RequestData.Get<string>("type");

            string uid = RequestData.Get("userid") + "";
            if (!string.IsNullOrEmpty(uid))
            {
                UserId = uid;
                UserEnt = SysUser.TryFind(uid);
                UserName = UserEnt.Name;
            }
            else
            {
                UserEnt = SysUser.TryFind(UserInfo.UserID);
            }


            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    ent = this.GetMergedData<UsrChildWelfare>();
                    ent.WorkFlowState = "1";
                    SaveEveryForm(RequestData.GetList<string>("data"), ent);
                    ent.DoUpdate();
                    break;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    DoSave();
                    break;
                case RequestActionEnum.Delete:
                    ent = this.GetTargetData<UsrChildWelfare>();
                    ent.DoDelete();
                    return;
                default:
                    if (RequestActionString == "GetWorkNo")
                    {
                        string UserID = RequestData.Get("UserID") + "";
                        ComUtility Ut = new ComUtility();
                        this.PageState.Add("WorkNo", Ut.GetWorkNo(UserID));
                    }
                    else if (RequestActionString == "Del")
                    {
                        Del();
                    }
                    else if (RequestActionString == "doAppSubmit")
                    {
                        doAppSubmit();
                    }
                    else if (RequestActionString == "getUserInfo")
                    {
                        GetUserInfo();
                    }
                    else if (RequestActionString == "CheckApply")
                    {
                        CheckApply();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }

        }

        private void CheckApply()
        {
            string IDCartNo = RequestData.Get("IDCartNo") + "";
            string Year = RequestData.Get("year") + "";

            string sql = @"select count(1) from  FL_Culture..UsrWelfareChildInfo 
                           where IDCartNo='{0}' and  year(CreateTime)={1} ";
            sql = string.Format(sql, IDCartNo, Year);
            int a = DataHelper.QueryValue<int>(sql);
            if (a > 0) this.PageState.Add("state", "1");
        }

        //审批处理
        private void doAppSubmit()
        {
            string State = RequestData.Get("State") + "";
            string Advise = RequestData.Get("Advise") + "";
            string preAdvice = RequestData.Get("preAdvice") + ""; //以前的意见
            SysUser UserEnt = SysUser.Find(UserInfo.UserID);

            UsrChildWelfare Ent = UsrChildWelfare.TryFind(id);
            if (Ent != null)
            {
                string tempStr = string.Empty;
                if (!string.IsNullOrEmpty(Advise))
                {
                    //tempStr = Advise + "\r\n----------工号: " + UserEnt.WorkNo + " 审批人: " + UserEnt.LoginName + "\r\n";
                }

                Ent.WorkFlowState = State;
                Ent.Result = Advise;
                Ent.DoUpdate();
            }
        }

        ///// <summary>
        ///// 保存
        ///// </summary>
        //private void DoSave()
        //{
        //    IList<string> IListStr = RequestData.GetList<string>("data");
        //    ent = this.GetPostedData<UsrChildWelfare>();
        //    ent.WorkFlowState = "1"; //提交申诉

        //    ent.ApplyTime = DateTime.Now;
        //    SaveEveryForm(IListStr, ent);
        //    ent.DoCreate();
        //}

        /// <summary>
        /// 保存
        /// </summary>
        private void DoSave()
        {

            IList<string> IListStr = RequestData.GetList<string>("data");
            ent = this.GetPostedData<UsrChildWelfare>();
            ent.WorkFlowState = "1"; //提交申诉
            if (IListStr.Count > 0)
            {
                IList<UsrWelfareChildInfo> triEntChild = IListStr.Distinct().Select(tent => JsonHelper.GetObject<UsrWelfareChildInfo>(tent) as UsrWelfareChildInfo).Where(ten => ten.BeRelation == "子女").ToList();
                IList<UsrWelfareChildInfo> triEntDouble = IListStr.Distinct().Select(tent => JsonHelper.GetObject<UsrWelfareChildInfo>(tent) as UsrWelfareChildInfo).Where(ten => ten.BeRelation == "配偶").ToList();

                if (triEntChild.Count > 0)
                {
                    ent.ApplyTime = DateTime.Now;
                    ent.WelfareType = "child";
                    ent.DoCreate();
                    SaveEveryForm(triEntChild, ent);
                }
                if (triEntDouble.Count > 0)
                {
                    ent.ApplyTime = DateTime.Now;
                    ent.WelfareType = "double";
                    ent.DoCreate();
                    SaveEveryForm(triEntDouble, ent);
                }
            }
            else
            {
                ent.ApplyTime = DateTime.Now;
                ent.DoCreate();
                SaveEveryForm(IListStr, ent);
            }
        }

        private void GetUserInfo()
        {
            string UserId = RequestData.Get("UserId") + "";
            this.PageState.Add("UserInfo", SysUser.TryFind(UserId));
        }

        /// <summary>
        /// 保存子项
        /// </summary>
        /// <param name="entStrList"></param>
        /// <param name="ent"></param>
        private void SaveEveryForm(IList<string> entStrList, UsrChildWelfare ent)
        {
            if (entStrList != null && entStrList.Count > 0)
            {
                UsrWelfareChildInfo.DoBatchDelete(entStrList.ToArray());
                IList<UsrWelfareChildInfo> triEnts = entStrList.Select(tent => JsonHelper.GetObject<UsrWelfareChildInfo>(tent) as UsrWelfareChildInfo).ToList();

                foreach (UsrWelfareChildInfo triEnt in triEnts)
                {
                    if (string.IsNullOrEmpty(triEnt.Id))
                    {
                        triEnt.ChildWelfareId = ent.Id;
                        triEnt.DoCreate();
                    }
                    else
                    {
                        triEnt.DoUpdate();
                    }
                }
            }
            else
            {
                string sql = "delete FL_Culture..UsrWelfareChildInfo where ChildWelfareId='" + ent.Id + "'";
                DataHelper.ExecSql(sql);
            }
        }

        /// <summary>
        /// 保存子项
        /// </summary>
        /// <param name="entStrList"></param>
        /// <param name="ent"></param>
        private void SaveEveryForm(IList<UsrWelfareChildInfo> entStrList, UsrChildWelfare ent)
        {
            if (entStrList != null && entStrList.Count > 0)
            {
                foreach (UsrWelfareChildInfo triEnt in entStrList)
                {
                    if (string.IsNullOrEmpty(triEnt.Id))
                    {
                        triEnt.ChildWelfareId = ent.Id;
                        triEnt.DoCreate();
                    }
                    else
                    {
                        triEnt.DoUpdate();
                    }
                }
            }
            else
            {
                string sql = "delete FL_Culture..UsrWelfareChildInfo where ChildWelfareId='" + ent.Id + "'";
                DataHelper.ExecSql(sql);
            }
        }

        private void DoSelect()
        {
            if (op != "c" && op != "cs")
            {
                if (!String.IsNullOrEmpty(id))
                {
                    ent = UsrChildWelfare.Find(id);
                }
                this.SetFormData(ent);
                string sql = "select * from FL_Culture..UsrWelfareChildInfo where ChildWelfareId='{0}' order by CreateTime";
                sql = string.Format(sql, id);
                this.PageState.Add("datalist", DataHelper.QueryDictList(sql));
            }

            if (op == "c" || op == "create")  //创建生成编号
            {
                string CompanyId = string.Empty;
                string CompanyName = string.Empty;
                string DeptId = string.Empty, DeptName = string.Empty;

                // 判断公司登陆
                if (Session["CompanyId"] != null)
                {
                    CompanyId = Session["CompanyId"] + "";
                }
                else
                {
                    CompanyId = UserEnt.Pk_corp;
                }

                var GroupEnt = SysGroup.TryFind(CompanyId);
                if (GroupEnt != null)
                {
                    CompanyName = GroupEnt.Name;
                }
                //部门判断
                if (UserEnt.Pk_corp == CompanyId)
                {
                    var DeptEnt = SysGroup.TryFind(UserEnt.Pk_deptdoc);
                    DeptName = DeptEnt.Name;
                    DeptId = UserEnt.Pk_deptdoc;
                }


                if (UserEnt != null)
                {
                    var Obj = new
                    {
                        UserId = UserEnt.UserID,
                        UserName = UserEnt.Name,
                        Sex = UserEnt.Sex,
                        Age = UserEnt.Wage,
                        WorkNo = UserEnt.WorkNo,
                        IndutyData = UserEnt.Indutydate,

                        CompanyName = CompanyName,
                        CompanyId = CompanyId,
                        DeptId = DeptId,
                        DeptName = DeptName
                    };
                    this.SetFormData(Obj);
                }
            }
        }

        /// <summary>
        /// 删除子女信息
        /// </summary>
        private void Del()
        {
            string sql = "delete  FL_Culture..UsrWelfareChildInfo where Id in(" + RequestData.Get<string>("idList") + ")";
            DataHelper.ExecSql(sql);
        }


    }
}


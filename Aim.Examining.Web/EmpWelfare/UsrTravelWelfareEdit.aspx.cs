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
using System.Text;

namespace Aim.Examining.Web
{
    public partial class UsrTravelWelfareEdit : ExamBasePage
    {
        #region 变量

        string op = String.Empty; // 用户编辑操作
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 对象类型
        string UserId = string.Empty;  //
        string UserName = string.Empty;  //
        SysUser UserEnt = null;

        #endregion

        public string AddressEnum = string.Empty;
        public string TimesEnum = string.Empty;

        public UsrTravelWelfareEdit()
        {
            this.IsCheckAuth = false;
            this.IsCheckLogon = false;
        }
        UsrTravelWelfare ent = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            string uid = RequestData.Get("userid") + "";
            if (!string.IsNullOrEmpty(uid))
            {
                UserId = uid;
                UserEnt = SysUser.TryFind(uid);
                UserName = UserEnt.Name;
            }
            else
            {
                UserId = UserInfo.UserID;
                UserEnt = SysUser.TryFind(UserInfo.UserID);
                UserName = UserInfo.LoginName;
            }

            op = RequestData.Get<string>("op");
            id = RequestData.Get<string>("id");
            type = RequestData.Get<string>("type");

            GetMyTravelMoney(); //获取旅游金额

            switch (this.RequestAction)
            {
                case RequestActionEnum.Update:
                    DoUpdate();
                    break;
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    DoCreate();
                    break;
                default:
                    if (RequestActionString == "DeleteSub")
                    {
                        DelFamilyMember();
                    }
                    else if (RequestActionString == "GetTimeSeg") //获取时间段
                    {
                        string CorpId = string.Empty, DeptId = string.Empty;
                        string Addr = RequestData.Get("Addr") + "";

                        if (Session["CompanyId"] != null)
                            CorpId = Session["CompanyId"] + "";
                        else CorpId = UserEnt.Pk_corp;
                        DeptId = UserEnt.Pk_deptdoc;
                        this.PageState.Add("Result", GetTimeSegEnum(CorpId, DeptId, Addr));
                    }
                    else if (RequestActionString == "GetUsrCount") //获取人员名额
                    {
                        string configId = RequestData.Get("ConfigSetId") + "";
                        this.PageState.Add("Result", GetRemainCout(configId));
                    }
                    else if (RequestActionString == "GetDetailInfo")
                    {
                        string CorpId = string.Empty, DeptId = string.Empty;
                        string Addr = RequestData.Get("Addr") + "";
                        string TimeSeg = RequestData.Get("TimeSeg") + "";

                        if (Session["CompanyId"] != null)
                            CorpId = Session["CompanyId"] + "";
                        else CorpId = UserEnt.Pk_corp;
                        DeptId = UserEnt.Pk_deptdoc;
                        this.PageState.Add("Result", GetUserCount(CorpId, DeptId, Addr, TimeSeg));
                    }
                    else if (RequestActionString == "GetTravelConfig")
                    {
                        string ConfigId = RequestData.Get("ConifgId") + "";
                        WelfareConfig Ent = Model.WelfareConfig.TryFind(ConfigId);
                        this.PageState.Add("Info", Ent == null ? (object)"" : Ent);
                    }
                    else if (RequestActionString == "doAppSubmit")
                    {
                        doAppSubmit();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }
        }


        /// <summary>
        /// 获取旅游金
        /// </summary>
        private void GetMyTravelMoney()
        {
            string SQL = @"select top 1
                                BaseMoney,[Money]
                            from FL_Culture..TravelMoneyConfig where WorkNo='{0}' order by CreateTime desc ";
            SQL = string.Format(SQL, SysUser.Find(UserInfo.UserID).WorkNo);
            DataTable Dt = DataHelper.QueryDataTable(SQL);
            string TravleMoney = "|";
            if (Dt.Rows.Count > 0)
            {
                TravleMoney = Dt.Rows[0][0] + "|" + Dt.Rows[0][1];
            }
            this.PageState.Add("TravelMoney", TravleMoney);
        }

        //审批处理
        private void doAppSubmit()
        {
            string State = RequestData.Get("State") + "";
            string Advise = RequestData.Get("Advise") + "";
            UsrTravelWelfare Ent = UsrTravelWelfare.TryFind(id);
            if (Ent != null)
            {
                Ent.WorkFlowState = State;
                Ent.Result = Advise;
                Ent.DoUpdate();
            }
        }

        private void DoUpdate()
        {
            ent = this.GetMergedData<UsrTravelWelfare>();
            ent.NoticeId = RequestData.Get<string>("noticeid");
            ent.TravelAddr = RequestData.Get("TravelAddr") + "";
            ent.TravelTime = RequestData.Get("TravelTime") + "";
            ent.Ext1 = RequestData.Get("Ext1") + "";
            SaveEveryForm(RequestData.GetList<string>("data"), ent);
            ent.DoUpdate();
        }
        private void DoCreate()
        {
            ent = this.GetPostedData<UsrTravelWelfare>();
            ent.ApplyTime = DateTime.Now;
            ent.NoticeId = RequestData.Get<string>("noticeid");
            ent.TravelAddr = RequestData.Get("TravelAddr") + "";
            ent.TravelTime = RequestData.Get("TravelTime") + "";
            ent.Ext1 = RequestData.Get("Ext1") + "";
            ent.CreateId = UserInfo.UserID;
            ent.CreateName = UserInfo.LoginName;
            ent.CreateTime = DateTime.Now;
            ent.WorkFlowState = "1";    //标识 0未提交状态 1已申报

            ent.DoCreate();
            SaveEveryForm(RequestData.GetList<string>("data"), ent);
        }


        private void DoSelect()
        {
            string CorpId = string.Empty;
            string DeptId = string.Empty;
            string ApproveName = string.Empty;
            string ApproveUserId = string.Empty;

            if (Session["CompanyId"] != null)
            {
                CorpId = Session["CompanyId"] + "";
            }
            else
            {
                CorpId = UserEnt.Pk_corp;
            }

            DeptId = UserEnt.Pk_deptdoc;

            GetAddrEnum(CorpId, DeptId);   //获取地址枚举

            if (op == "c" || op == "create")
            {

                //corp
                SysGroup Gp = SysGroup.TryFind(CorpId);
                string CompanyName = Gp == null ? "" : Gp.Name;

                string DeptName = string.Empty;
                if (UserEnt.Pk_corp != CorpId)
                {
                    DeptName = "";
                }
                else if (UserEnt.Pk_corp == CorpId)
                {
                    SysGroup GpEnt = SysGroup.FindFirstByProperties(SysGroup.Prop_GroupID, UserEnt.Pk_deptdoc);
                    DeptName = "/" + GpEnt.Name;
                }


                //查找到部门配置
                string SQL = @"with GetTree
                                as
                                (
	                                select * from HR_OA_MiddleDB..fld_bmml where pk_deptdoc='{0}'
	                                union all
	                                select A.*
	                                from HR_OA_MiddleDB..fld_bmml As A 
	                                join GetTree as B 
	                                on  A.pk_deptdoc=B.pk_fathedept
                                )
	                           select deptname+',' as [text()] from getTree FOR XML PATH('') ";
                SQL = SQL.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
                SQL = string.Format(SQL, UserEnt.Pk_deptdoc);
                string DeptPathStr = DataHelper.QueryValue(SQL).ToString();
                DeptPathStr = string.IsNullOrEmpty(DeptPathStr) ? "" : DeptPathStr;

                SQL = @"select top 1 *,
                    case when patindex('%'+DeptName+'%','{1}')=0  then 100
                         else  patindex('%'+DeptName+'%','{1}') 
                    end  As SortIndex 
                from FL_Culture..SysApproveConfig As A
                where A.CompanyId='{0}' and TravelWelfareId is not null  order by SortIndex";
                SQL = string.Format(SQL, CorpId, DeptPathStr);
                DataTable Dt = DataHelper.QueryDataTable(SQL);

                if (Dt.Rows.Count > 0)
                {
                    ApproveName = Dt.Rows[0]["TravelWelfareName"] + "";
                    ApproveUserId = Dt.Rows[0]["TravelWelfareId"] + "";
                }

                var Obj = new
               {
                   UserId = UserEnt.UserID,
                   UserName = UserEnt.Name,
                   Sex = UserEnt.Sex,
                   //Age = Ent.Age,
                   WorkNo = UserEnt.WorkNo,
                   //IndutyData = Ent.IndutyData,
                   CompanyName = CompanyName + DeptName,
                   CompanyId = CorpId,
                   DeptId = DeptId,
                   DeptName = DeptName,
                   ApproveName = "",
                   ApproveUserId = "",
               };
                this.SetFormData(Obj);
            }

            if (op != "c" && op != "cs")
            {
                if (!String.IsNullOrEmpty(id))
                {
                    ent = UsrTravelWelfare.Find(id);
                    string SQL = @"select * from Task where PatIndex('%{0}%',EFormName)>0  and Status='4' order by FinishTime asc";
                    SQL = string.Format(SQL, id);
                    IList<EasyDictionary> taskDics = DataHelper.QueryDictList(SQL);
                    PageState.Add("Opinion", taskDics);
                    string taskId = RequestData.Get<string>("TaskId");//取审批暂存时所填写的意见
                    if (!string.IsNullOrEmpty(taskId))
                    {
                        Task tEnt = Task.Find(taskId);
                        if (tEnt.Status != 4 && !string.IsNullOrEmpty(tEnt.Description))
                        {
                            PageState.Add("UnSubmitOpinion", tEnt.Description);
                        }
                    }
                }
                this.SetFormData(ent);
                string sql = "select * from FL_Culture..UsrTravelInfo  where WelfareTravelId='{0}' order by CreateTime";
                sql = string.Format(sql, id);
                this.PageState.Add("datalist", DataHelper.QueryDictList(sql));
            }
        }

        #region 旅游填报筛选判断
        /// <summary>
        /// get TravelConfigset set
        /// </summary>
        /// <param name="CorpId"></param>
        /// <param name="DeptId"></param>
        /// <returns></returns>
        private string GetConfigSet(string CorpId, string DeptId)
        {
            string sql = @"SELECT  *  FROM FL_Culture..WelfareConfig where ISEnable='Y' and CorpId='{0}'  ";
            sql = string.Format(sql, CorpId);
            DataTable DtConfig = DataHelper.QueryDataTable(sql);

            DataRow[] rows = DtConfig.Select(" DetpId is not null or DetpId<>'' ");
            DataRow[] rowsCp = DtConfig.Select(" DetpId is null or DetpId='' ");// have corp

            //get current user workage 
            sql = @"select datediff(year,Indutydate,getdate()) As Year  from sysuser where UserId='{0}'";
            int WorkAge = DataHelper.QueryValue<int>(string.Format(sql, UserInfo.UserID));
            List<string> Ids = new List<string>();

            //frist:  have corp and DeptId is not null 
            for (int i = 0; i < rowsCp.Length; i++)
            {
                if (!string.IsNullOrEmpty(rowsCp[i]["WorkAge"] + "")) //工龄筛选
                {
                    if (WorkAge < int.Parse(rowsCp[i]["WorkAge"] + ""))
                    {
                        continue;
                    }
                    else
                    {
                        Ids.Add(rowsCp[i]["Id"] + "");
                    }
                }
                else
                {
                    Ids.Add(rowsCp[i]["Id"] + "");
                }
            }

            //second: have deptID
            for (int i = 0; i < rows.Length; i++)
            {
                string tepsql = @"select GroupID+',' as [text()]
                                        from  sysgroup where type='2' and (Path like '%{0}%' or  GroupID='{0}' ) 
                                 FOR XML PATH('') ";
                tepsql = string.Format(tepsql, rows[i]["DetpId"] + "");
                string val = DataHelper.QueryValue(tepsql) + "";
                if (val.Contains(DeptId))
                {
                    if (!string.IsNullOrEmpty(rowsCp[i]["WorkAge"] + ""))  //工龄筛选
                    {
                        if (WorkAge < int.Parse(rowsCp[i]["WorkAge"] + ""))
                        {
                            continue;
                        }
                        else
                        {
                            Ids.Add(rowsCp[i]["Id"] + "");
                        }
                    }
                    else
                    {
                        Ids.Add(rowsCp[i]["Id"] + "");
                    }
                }
            }

            StringBuilder IdsBild = new StringBuilder();
            for (int i = 0; i < Ids.Count; i++)
            {
                if (i > 0) IdsBild.Append(",");
                IdsBild.Append("'" + Ids[i] + "'");
            }
            return IdsBild.ToString();
        }


        /// <summary>
        /// get address enum
        /// </summary>
        /// <param name="CorpId"></param>
        /// <param name="DeptId"></param>
        private void GetAddrEnum(string CorpId, string DeptId)
        {
            string sql = @"select '' As K,'请选择...'
                           union All
                           select TravelAddress As K,TravelAddress As V from FL_Culture..WelfareConfig where  1=1 {0}
                           group by TravelAddress";
            string qry = GetConfigSet(CorpId, DeptId);
            if (string.IsNullOrEmpty(qry))
                sql = string.Format(sql, " and 1<>1");
            else
                sql = string.Format(sql, " and  Id in (" + qry + ") ");
            sql = string.Format(sql, qry);
            this.PageState.Add("TravelAddrEnum", DataHelper.QueryDict(sql));
        }

        //get travle time segment enum str
        private string GetTimeSegEnum(string CorpId, string DeptId, string Addr)
        {
            string sql = @" select '' As K, '请选择' As V
                            union All
                            select convert(varchar(10) ,TravelStartTime,111)+'--'+convert(varchar(10),TravelEndTime,111)  As K,
                            convert(varchar(10) ,TravelStartTime,111)+'--'+convert(varchar(10),TravelEndTime,111) As V
                            from FL_Culture..WelfareConfig where Id in ({0}) and TravelAddress='{1}' ";

            sql = string.Format(sql, GetConfigSet(CorpId, DeptId), String.IsNullOrEmpty(Addr) ? "" : Addr);
            return JsonHelper.GetJsonStringFromDataTable(DataHelper.QueryDataTable(sql));
        }

        /// <summary>
        /// get user count 
        /// </summary>
        private string GetUserCount(string CorpId, string DeptId, string Addr, string TimeSeg)
        {
            // if (!string.IsNullOrEmpty(TimeSeg)) TimeSeg = TimeSeg.Replace("/", "-");
            string[] timArr = TimeSeg.Split(new string[] { "--" }, StringSplitOptions.RemoveEmptyEntries);

            string sql = @"select top 1 Id,TravelName,WorkAge,TravelCount,NeedMoney 
                           from FL_Culture..WelfareConfig where Id in ({0}) and TravelAddress='{1}' 
                           and ( convert(varchar(10) ,TravelStartTime,111)='{2}' and   convert(varchar(10) ,TravelEndTime,111)='{3}')";
            if (timArr.Length == 2)
            {
                sql = string.Format(sql, GetConfigSet(CorpId, DeptId), Addr, timArr[0], timArr[1]);
            }
            else
            {
                sql = string.Format(sql, GetConfigSet(CorpId, DeptId), Addr, "", "");
            }
            DataTable dt = DataHelper.QueryDataTable(sql);

            if (dt.Rows.Count > 0)
            {
                string Id = dt.Rows[0]["Id"] + "";
                string TravelName = dt.Rows[0]["TravelName"] + "";
                string TravelCount = string.IsNullOrEmpty(dt.Rows[0]["TravelName"] + "") ? "暂未限制" : (dt.Rows[0]["TravelCount"] + "");
                string RemainCout = GetRemainCout(Id); //剩余人员
                string NeedMoney = dt.Rows[0]["NeedMoney"] + "";  //需要金额

                string JsonRlt = "{{'TravelCount':'{0}','TravelName':'{1}','ConfigId':'{2}','LeaveUsrCount':'{3}','NeedMoney':'{4}' }}";
                return JsonRlt = string.Format(JsonRlt, TravelCount, TravelName, Id, RemainCout, NeedMoney);
            }
            else
            {
                return "{}";
            }

        }

        /// <summary>
        ///  获取剩余的名额 "" 无限制, 负 超过限额
        /// </summary>
        /// <param name="ConfigId"></param>
        /// <returns></returns>
        private string GetRemainCout(string ConfigId)
        {
            string LevelUsre = string.Empty;
            var Ent = WelfareConfig.TryFind(ConfigId);
            if (Ent != null)
            {
                if (Ent.TravelCount.GetValueOrDefault() > 0)
                {
                    string sql = @" select Sum(T) As Cout from 
                            (
	                            select count(*) As T from  FL_Culture..UsrTravelWelfare As A where ConfigSetId='{0}' 
	                            union All
	                            select Count(*) As T from  FL_Culture..UsrTravelWelfare As A
	                            inner join  FL_Culture..UsrTravelInfo As B 
	                            on A.Id=B.WelfareTravelId 
	                            where ConfigSetId='{0}'
                            )As T ";
                    sql = string.Format(sql, ConfigId);
                    int FillUsr = DataHelper.QueryValue<int>(sql);

                    LevelUsre = (Ent.TravelCount.GetValueOrDefault() - FillUsr).ToString();
                }
            }
            return LevelUsre;
        }

        #endregion


        #region 处理家属信息
        /// <summary>
        /// 家属信息
        /// </summary>
        private void SaveEveryForm(IList<string> entStrList, UsrTravelWelfare Ent)
        {
            if (entStrList != null && entStrList.Count > 0)
            {
                UsrTravelInfo.DoBatchDelete(entStrList.ToArray());
                IList<UsrTravelInfo> triEnts = entStrList.Select(tent => JsonHelper.GetObject<UsrTravelInfo>(tent) as UsrTravelInfo).ToList();

                foreach (UsrTravelInfo triEnt in triEnts)
                {
                    if (string.IsNullOrEmpty(triEnt.Id))
                    {
                        triEnt.WelfareTravelId = Ent.Id;
                        triEnt.DoCreate();
                    }
                    else
                    {
                        triEnt.DoUpdate();
                    }
                }
                if (Ent.NeedMoney > 0)
                {
                    try
                    {
                        Ent.XLMoney = Ent.NeedMoney * (triEnts.Count + 1); //包括家属在内的旅游费用
                        Ent.DoUpdate();
                    }
                    catch { }
                }
            }
            else
            {
                string sql = "delete FL_Culture..UsrTravelInfo where WelfareTravelId='" + Ent.Id + "'";
                DataHelper.ExecSql(sql);
            }
        }

        /// <summary>
        /// 删除家属信息
        /// </summary>
        private void DelFamilyMember()
        {
            string sql = "delete  FL_Culture..UsrTravelInfo where ID in(" + RequestData.Get<string>("idList") + ")";
            DataHelper.ExecSql(sql);
        }
        #endregion

        #region 流程相关
        //创建流程
        private void StartFlow()
        {
            if (op == "c" || op == "create")
            {
                ent = this.GetPostedData<UsrTravelWelfare>();
                ent.ApplyTime = DateTime.Now;
                ent.DoCreate();
                id = ent.Id;
            }
            else
            {
                ent = UsrTravelWelfare.Find(id);
            }

            //受理人
            string UserId = ent.ApproveUserId;
            string UserName = ent.ApproveName;

            string FlowKey = "EmpUsrWelfare";   //工作流key

            if (!string.IsNullOrEmpty(FlowKey))
            {
                string formUrl = "/EmpWelfare/UsrTravelWelfareEdit.aspx?op=r&id=" + id;
                Guid guid = Aim.WorkFlow.WorkFlow.StartWorkFlow(id, formUrl, "员工旅游申请", FlowKey, UserInfo.UserID, UserInfo.Name);
                ent.WorkFlowState = "Start";
                ent.WorkFLowCode = guid.ToString(); //InstanceId
                ent.DoUpdate();
                this.PageState.Add("NextInfo", guid.ToString() + "$" + UserId + "|" + UserName);
            }

        }
        private void AutoExecuteFlow()
        {
            string NextInfo = this.RequestData.Get("NextInfo") + "";
            string IntanceId = NextInfo.Split('$')[0];
            string[] UserArr = NextInfo.Split('$')[1].Split('|');

            IList<Task> tasks = Task.FindAllByProperty(Task.Prop_WorkflowInstanceID, IntanceId);
            Aim.WorkFlow.WorkFlow.AutoExecute(tasks[0], UserArr);  //制定节点
        }

        //获取下一节点人
        private void GetNextUsers()
        {
            //  taskName id   nextUserName
            string id = this.RequestData.Get("id") + "";
            string taskName = this.RequestData.Get("taskName") + "";
            string nextName = this.RequestData.Get("nextName") + "";
            if (!string.IsNullOrEmpty(id))
            {
                var Ent = UsrTravelWelfare.Find(id);
                if (nextName == "审批人")
                {
                    this.PageState.Add("NextUsers", new { nextUserId = Ent.ApproveUserId, nextUserName = Ent.ApproveName });
                }
            }

        }

        /// <summary>
        /// 审批完成
        /// </summary>
        private void SubmitFinish()
        {
            if (!string.IsNullOrEmpty(id))
            {
                UsrTravelWelfare Ent = UsrTravelWelfare.Find(id);
                Ent.WorkFlowState = "End";
                Ent.Result = RequestData.Get<string>("ApproveResult"); //处理结果
                Ent.DoUpdate();
            }
        }
        #endregion
    }
}


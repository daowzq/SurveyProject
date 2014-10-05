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
using Aim;
using Aim.WorkFlow;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class WorkFlowTab : BaseListPage
    {
        string SurveyId = string.Empty;
        protected void Page_Load(object sender, EventArgs e)
        {
            SurveyId = RequestData.Get("SurveyId") + "";
            switch (RequestActionString)
            {
                case "GetNextUsers":
                    GetNextUsers();
                    break;
                case "submitfinish":
                    SubmitFinish();
                    break;
                default:
                    DoSelect();
                    break;
            }
        }

        private void GetNextUsers()
        {
            SurveyQuestion SEnt = SurveyQuestion.Find(SurveyId);
            string CurrentNode = RequestData.Get<string>("taskName");
            string nextName = RequestData.Get<string>("nextName");
            string nextUserId = "";
            string nextUserName = "";

            if (CurrentNode == "申请人")
            {
                string[] User = UserChoice()[0].Split('|');
                if (User.Length > 0)
                {
                    nextUserId = User[0];
                    nextUserName = User[1];
                }
            }
            else if (CurrentNode == "第一步" && nextName == "不同意")
            {
                if (SEnt != null)
                {
                    nextUserId = SEnt.CreateId;
                    nextUserName = SEnt.CreateName;
                }
            }

            else if (CurrentNode == "第一步" && nextName != "不同意")
            {
                string[] User = UserChoice()[1].Split('|');
                if (User.Length > 0)
                {
                    nextUserId = User[0];
                    nextUserName = User[1];
                }
            }

            else if (CurrentNode == "第二步" && nextName != "退回上一步")
            {
                string[] User = UserChoice()[2].Split('|');
                if (User.Length > 0)
                {
                    nextUserId = User[0];
                    nextUserName = User[1];
                }
            }
            else if (CurrentNode == "第三步" && nextName != "退回上一步")
            {
                string[] User = UserChoice()[3].Split('|');
                if (User.Length > 0)
                {
                    nextUserId = User[0];
                    nextUserName = User[1];
                }
            }
            else if (CurrentNode == "第四步" && nextName != "退回上一步")
            {
                string[] User = UserChoice()[4].Split('|');
                if (User.Length > 0)
                {
                    nextUserId = User[0];
                    nextUserName = User[1];
                }
            }
            else if (CurrentNode == "第五步" && nextName != "退回上一步")
            {
                string[] User = UserChoice()[5].Split('|');
                if (User.Length > 0)
                {
                    nextUserId = User[0];
                    nextUserName = User[1];
                }
            }
            PageState.Add("NextUsers", new { nextUserId = nextUserId, nextUserName = nextUserName });
        }
        private string[] UserChoice()
        {
            //审批人
            //            string SQL = @"select UserId1+'|'+UserName1+','+UserId2 +'|'+UserName2+','+UserId3+'|'+UserName3+','+UserId4+'|'+UserName4+','+UserId5+'|'+UserName5
            //                           from FL_Culture..SurveyWFUserSet where SurveyId='{0}'";
            //            SQL = string.Format(SQL, SurveyId);


            //Change by WGM 7/23  UserId1 
            SysWFUserSet Ent = SysWFUserSet.FindFirstByProperties("SurveyId", SurveyId);
            var UserIds = Ent.UserId1.Split(',');
            var UserNames = Ent.UserName1.Split(',');

            //string UsrTemp = DataHelper.QueryValue(SQL).ToString();
            string UsrTemp = string.Empty;
            for (int i = 0; i < UserIds.Length; i++)
            {
                if (i > 0) UsrTemp += ",";
                UsrTemp += UserIds[i] + "|" + UserNames[i];
            }
            string[] User = UsrTemp.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries).Where(ten => ten.Replace("|", "").Length > 0).ToArray();
            return User;
        }

        /// <summary>
        /// 审批完成
        /// </summary>
        private void SubmitFinish()
        {
            string id = RequestData.Get("SurveyId") + "";
            if (!string.IsNullOrEmpty(id))
            {
                SurveyQuestion Ent = SurveyQuestion.Find(id);
                if (Ent.IsFixed == "2") Ent.State = "1";  //WGM 9/15
                Ent.WorkFlowState = "End";
                Ent.WorlFlowResult = RequestData.Get<string>("ApproveResult");
                Ent.DoUpdate();
            }
        }

        private void DoSelect()
        {
            string sql = @"select * from Task where PatIndex('%{0}%',EFormName)>0  and Status='4' order by FinishTime asc";
            sql = string.Format(sql, SurveyId);
            IList<EasyDictionary> taskDics = DataHelper.QueryDictList(sql);
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
    }
}

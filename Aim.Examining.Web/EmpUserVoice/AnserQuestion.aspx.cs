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
namespace Aim.Examining.Web.EmpUserVoice
{
    public partial class AnserQuestion : ExamListPage
    {
        string id = String.Empty;           // 对象id
        string op = String.Empty;           // 用户编辑操作
        string QuestionId = string.Empty;   //

        EmpVoiceAnswerInfo ent = null;
        protected void Page_Load(object sender, EventArgs e)
        {
            id = RequestData.Get<string>("id");
            op = RequestData.Get<string>("op");
            QuestionId = RequestData.Get("QuestionId") + "";

            switch (this.RequestAction)
            {
                case RequestActionEnum.Insert:
                case RequestActionEnum.Create:
                    DoCreate();
                    break;
                default:
                    if (!string.IsNullOrEmpty(QuestionId))
                    {
                        QuestionInfo();
                    }
                    else
                    {
                        DoSelect();
                    }
                    break;
            }


        }

        private void DoCreate()
        {
            string Anonymity = RequestData.Get("Anonymity") + "";
            string Answer = RequestData.Get("Answer") + "";
            string QuestionId = RequestData.Get("QuestionId") + "";

            var QEnt = EmpVoiceAskQuestion.Find(QuestionId);
            if (QEnt != null)
            {
                QEnt.AnswerCount = QEnt.AnswerCount.GetValueOrDefault() + 1;
                QEnt.DoUpdate();
            }

            ent = this.GetPostedData<EmpVoiceAnswerInfo>();
            ent.Anonymity = Anonymity;

            ent.DoCreate();
        }

        private void QuestionInfo()
        {
            string SQL = @"select A.Id As QuestionId,B.Id,A.Contents,A.Anonymity,A.Category,A.AwardScore,A.ViewCount,A.AnswerCount,A.CreateTime, B.Answer
                           from FL_Culture..EmpVoiceAskQuestion As A
	                            left join  FL_Culture..EmpVoiceAnswerInfo  As B
                             on A.Id=B.QuestionId
                           where A.Id='{0}' and B.CreateId ='{1}' ";

            SQL = string.Format(SQL, QuestionId, UserInfo.UserID);
            EasyDictionary Edic = DataHelper.QueryDictList(SQL).FirstOrDefault();
            if (Edic == null)
            {
                SQL = @"select Id As QuestionId,Contents,Anonymity,Category,AwardScore,ViewCount,AnswerCount,CreateTime
                        from FL_Culture..EmpVoiceAskQuestion  where Id ='{0}' ";
                Edic = DataHelper.QueryDictList(SQL).FirstOrDefault();
            }
            this.SetFormData(Edic);
        }

        private void DoSelect()
        {
            if (op != "c" && op != "cs")
            {
                if (!String.IsNullOrEmpty(id))
                {
                    ent = EmpVoiceAnswerInfo.Find(id);
                }
                this.SetFormData(ent);
            }
        }
    }
}

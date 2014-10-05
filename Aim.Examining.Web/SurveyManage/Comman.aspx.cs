using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Collections;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using NHibernate.Criterion;
using System.Data;
using System.Data.OleDb;
using System.IO;

namespace Aim.Examining.Web.SurveyManage
{
    public partial class Comman : BaseListPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (this.RequestActionString)
            {
                case "GetId":
                    CopyItems();
                    break;
                case "DeleteItem":
                    DeleteItem();
                    break;
                case "GetOrgs":
                    GetOrgs();
                    break;
                case "ImpUser":
                    DoImpUser();
                    break;
                case "SaveItem":
                    SaveItem();
                    break;
                case "AddQuestionItem":
                    AddQuestionItem();
                    break;
                case "DoImpScore":  //导入问卷分值
                    DoImpScore();
                    break;
                case "SaveTpl":   //转存为问卷模板
                    TurnTempLate();
                    break;
                case "CkHaveTpl":  // 检查模板
                    CkHaveTpl();
                    break;
                case "CreateUser": //生成问卷人员
                    CreateUsr();
                    break;
                case "SaveSurveyedObj":
                    SaveSurveyedObj();
                    break;
                case "CancelTpl": //撤销模板
                    CancelTpl();
                    break;
                case "GetAllPath":
                    GetAllPath();
                    break;
                case "RefData":         //刷新数据源
                    RefData();
                    break;
            }
        }

        /// <summary>
        /// 刷新数据源数据
        /// </summary>
        private void RefData()
        {
            string SurveyId = RequestData.Get("SurveyId") + "";

            string sql = @" 		
                            declare @SurveyId varchar(36)
                            set @SurveyId='{0}'

	                         delete from FL_Culture..SummarySurvey_detail where SurveyId=@SurveyId;
                        		
		                        IF (OBJECT_ID('tempdb..#ST') IS NOT NULL)
		                         DROP TABLE tempdb..#ST;
		                        IF (OBJECT_ID('tempdb..#STInfo') IS NOT NULL)
		                         DROP TABLE tempdb..#STInfo;
		                        IF (OBJECT_ID('tempdb..#Usrs') IS NOT NULL)
		                         DROP TABLE tempdb..#Usrs;

		                        Select 
				                        A.UserId,D.WorkNo, UserName,B.Content,B.QuestionType,
				                        A.QuestionId,C.Id As QuestionItemId,
				                        --选项内容
				                        Case 
					                        when  QuestionType like '填写项%'  then A.QuestionContent 
			                                when  QuestionType like '排序_'    then A.QuestionContent
                                            else  C.SortIndex+' '+C.Answer
				                        end AS Answer ,
				                        Case
					                        when C.IsExplanation='是' then A.QuestionItemContent else ''
				                        End 'Explanation',B.SortIndex P,C.SortIndex S
				                        into #STInfo
			                        from FL_Culture..SurveyedResult As A 
			                         left join FL_Culture..QuestionItem As B 
				                         on B.Id=A.QuestionId and A.SurveyId=B.SurveyId
			                         left join FL_Culture..QuestionAnswerItem As C 
				                         on A.SurveyId=C.SurveyId and  A.QuestionItemId  like '%'+C.Id+'%'
			                         left join  FL_PortalHR..sysuser As D 
				                         on A.UserID=D.UserID
		                           where A.SurveyId=@SurveyId;
                         
		                        With  SingleUserInfo AS  --去除一个人在多个公司的情况
			                        (
										--	select * from HR_OA_MiddleDB..fld_ryxx where 
										--	Id in 
										--	(
										--	    select  min(id) As Id
										--	     from  HR_OA_MiddleDB..fld_ryxx As B
										--	    where  1=1 
										--	    ---outdutydate is null 
										--	       and psncode is not null 
										--	    -- and pk_gw is not null 
										--	       and def3 is null --def3 兼职
										--	    group by  psncode 
										--	)
										select B.* 
										from FL_PortalHR..sysuser As A
										join  HR_OA_MiddleDB..fld_ryxx As B
											on A.WorkNo=B.psncode and A.pk_corp=B.pk_corp and A.pk_deptdoc=B.pk_deptdoc
										where len(A.outdutydate)=0
			                        ),
			                         UsrInfo As
			                        ( 
				                        select 
					                         A.SurveyId ,B.psncode 'WorkNo', B.psnname 'UserName',B.pk_sex 'Sex',
					                         F.unitname 'Corp',G.deptname 'Dept',
					                         B.indutydate 'Indutydate', datediff(year,indutydate,getdate()) 'WorkAge',
					                         B.def4 'BornDate',datediff(year,B.def4,getdate()) 'Age',
					                         E.jobname 'JobName',D.daname 'JobDegree', E.def2 'JobSeq',H.daname 'Skill',
					                         E.def1  'Crux'  --是否关键岗位
				                        from  FL_Culture..SurveyCommitHistory As A
				                         left join SingleUserInfo AS B
					                        ---  HR_OA_MiddleDB..fld_ryxx As B
					                        on A.WorkNo=B.psncode --and A.SurveyedUserName=B.psnname
				                         left join HR_OA_MiddleDB..fld_rylb As C   --人员类别
					                        on B.pk_psncl=C.pk_fld_rylb
				                         left join  HR_OA_MiddleDB..fld_gwdj As D --岗位等级
					                        on B.pk_gwdj=D.pk_dazj
				                        left join HR_OA_MiddleDB..fld_gw As E   --岗位
					                        on B.pk_gw=E.pk_jobcode 
				                        left join HR_OA_MiddleDB..fld_gsml AS F --公司
					                        on B.pk_corp=F.pk_corp 
				                        left join HR_OA_MiddleDB..fld_bmml AS G --部门
					                        on B.pk_deptdoc=G.pk_deptdoc
				                        left join HR_OA_MiddleDB..fld_jndj AS H --技能等级
					                        on B.pk_jndj=H.pk_dazj 
				                        where A.SurveyId=@SurveyId
			                        )
		                           Select * into #Usrs from UsrInfo ;

		                           With ComPiseInfo 
		                           As 
			                        (
			                           select 
					                        A.*,B.UserId,B.Content,B.QuestionType,B.QuestionId,B.QuestionItemId,Answer ,Explanation, P,S
			                          from #Usrs As A 
				                         left join #STInfo As B
					                        on A.WorkNo=B.WorkNo 
					                        --and A.UserName=B.UserName
			                        )
		                           select newid() Id,
				                          SurveyId,WorkNo,UserId,UserName,Sex,Corp,Dept,Indutydate,WorkAge,Crux,
				                          BornDate,Age,JobName,JobDegree,JobSeq,Skill,Content, QuestionType,QuestionId,QuestionItemId,Answer,Explanation
				                         into #ST
			                        from  ComPiseInfo
			                        where  WorkNo is not null 
			                        order by UserID,P,S;

		                        Insert into FL_Culture..SummarySurvey_detail
		                        (
			                        Id, SurveyId,WorkNo,UserId,UserName,Sex,Corp,Dept,Indutydate,WorkAge,Crux,
			                        BornDate,Age,JobName,JobDegree,JobSeq,Skill,Content,QuestionType,QuestionId,QuestionItemId,Answer,Explanation,CreateTime
		                        )
		                        select A.*, getdate() as Dt from  #ST As A";

            sql = sql.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
            sql = string.Format(sql, SurveyId);

            DataHelper.ExecSql(sql);
            this.PageState.Add("State", "1");
        }

        /// <summary>
        /// 获取组织机构路径
        /// </summary>
        private void GetAllPath()
        {
            string GroupId = RequestData.Get("GroupID") + "";
            string reResult = "";
            //string sql = @"select *  from SysGroup where GroupId='{0}' ";
            //sql = string.Format(sql, GroupId);
            //DataTable Dt = DataHelper.QueryDataTable(sql);
            if (!string.IsNullOrEmpty(GroupId))
            {
                string Result = WFHelper.getCzlxDG1(GroupId, ref reResult);
                this.PageState.Add("State", Result);
            }
            else
            {
                this.PageState.Add("State", "");
            }
        }

        /// <summary>
        /// 撤销模板
        /// </summary>
        private void CancelTpl()
        {
            string SurveyId = RequestData.Get("SurveyId") + "";
            var Ent = SurveyQuestion.Find(SurveyId);
            Ent.TemplateId = "";   //TemplateId
            Ent.DoUpdate();

            var ItemEnts = QuestionItem.FindAllByProperties(QuestionItem.Prop_SurveyId, SurveyId, QuestionItem.Prop_Ext2, "imp");
            if (ItemEnts.Length > 0)
            {
                //撤销模板 'imp' 导入标志
                string SQL = @"delete from FL_Culture..QuestionItem where  SurveyId='{0}' and Ext2='imp' ;
                           delete from FL_Culture..QuestionAnswerItem where SurveyId='{0}' and Ext1='imp' ";
                SQL = string.Format(SQL, SurveyId);
                DataHelper.ExecSql(SQL);

                IList<QuestionItem> items = QuestionItem.FindAll(Expression.Sql(" SurveyId='" + SurveyId + "' order by SortIndex  "));
                this.PageState.Add("QItem", items);
            }
        }

        /// <summary>
        /// SaveSurveyedObj
        /// </summary>
        private void SaveSurveyedObj()
        {
            string SurveyId = RequestData.Get("SurveyId") + "";
            //first delete
            string sql = " delete from  FL_Culture..SurveyedObj where SurveyId='{0}' ;";
            sql += " delete from  FL_Culture..SurveyReaderObj where SurveyId='{0}' ;";
            sql = string.Format(sql, SurveyId);
            DataHelper.ExecSql(sql);

            string OrgIds = RequestData.Get("OrgIds") + "";
            string OrgNames = RequestData.Get("OrgNames") + "";
            string PostionIds = RequestData.Get("PostionIds") + "";
            string PostionNames = RequestData.Get("PostionNames") + "";
            string BornAddr = RequestData.Get("BornAddr") + "";
            string StartWorkTime = RequestData.Get("StartWorkTime") + "";
            string UntileWorkTime = RequestData.Get("UntileWorkTime") + "";
            string Sex = RequestData.Get("Sex") + "";
            string StartAge = RequestData.Get("StartAge") + "";
            string EndAge = RequestData.Get("EndAge") + "";
            string WorkAge = RequestData.Get("WorkAge") + "";
            string Major = RequestData.Get("Major") + "";
            string PersonType = RequestData.Get("PersonType") + "";
            string PositionDegree1 = RequestData.Get("PositionDegree1") + "";
            string PositionDegree0 = RequestData.Get("PositionDegree0") + "";
            string CruxPositon = RequestData.Get("CruxPositon") + "";  //关键岗位
            string PositionSeq = RequestData.Get("PositionSeq") + "";  //岗位序列

            SurveyedObj Ent = new SurveyedObj();
            Ent.SurveyId = SurveyId;            //*
            Ent.OrgIds = OrgIds;
            Ent.OrgNames = OrgNames;
            Ent.PostionIds = PostionIds;
            Ent.PostionNames = PostionNames;
            Ent.Sex = Sex;
            Ent.WorkAge = WorkAge;
            if (!string.IsNullOrEmpty(StartWorkTime))
                Ent.StartWorkTime = DateTime.Parse(StartWorkTime);
            if (!string.IsNullOrEmpty(UntileWorkTime))
                Ent.UntileWorkTime = DateTime.Parse(UntileWorkTime);
            if (!string.IsNullOrEmpty(CruxPositon)) Ent.CruxPositon = CruxPositon;
            if (!string.IsNullOrEmpty(PositionSeq)) Ent.PositionSeq = PositionSeq; //岗位序列

            Ent.Major = Major;  //学历
            Ent.PersonType = PersonType;
            Ent.BornAddr = BornAddr;

            //年龄范围
            if (!string.IsNullOrEmpty(StartAge))
            {
                Ent.StartAge = DateTime.Parse(StartAge);
            }
            if (!string.IsNullOrEmpty(EndAge))
            {
                Ent.EndAge = DateTime.Parse(EndAge);
            }

            //StartAge EndAge(年龄范围) BornAddr 籍贯
            Ent.PositionDegree0 = PositionDegree0;
            Ent.PositionDegree1 = PositionDegree1;
            Ent.DoCreate();

            SurveyQuestion SEnt = SurveyQuestion.Find(SurveyId);
            string ReadObj = SEnt.ReaderObj;
            if (ReadObj.Contains("joiner")) ReadObj = "joiner";
            else ReadObj = "sender";

            SurveyReaderObj ReadEnt = new SurveyReaderObj();
            ReadEnt.SurveyId = SurveyId;
            ReadEnt.ReaderWay = ReadObj;
            ReadEnt.DoCreate();

            this.PageState.Add("State", "1");
        }

        /// <summary>
        /// 检查是否存在该模板
        /// </summary>
        private void CkHaveTpl()
        {
            string Id = RequestData.Get("SurveyId") + "";
            var SqEnt = SurveyQuestion.FindAllByProperties(SurveyQuestion.Prop_IsFixed, "1", SurveyQuestion.Prop_TurnSurveyId, Id);
            if (SqEnt.Length > 0)
            {
                this.PageState.Add("HaveTpl", "1"); // 1 Exist
            }
            else
            {
                this.PageState.Add("HaveTpl", "0");
            }

        }

        /// <summary>
        /// 转存为模板
        /// </summary>
        private void TurnTempLate()
        {
            string Id = RequestData.Get<string>("SurveyId");
            if (!string.IsNullOrEmpty(Id))
            {
                //先删除
                var tplEnt = SurveyQuestion.FindFirstByProperties(SurveyQuestion.Prop_TurnSurveyId, Id, SurveyQuestion.Prop_IsFixed, "1");
                if (tplEnt != null)
                {
                    string SQL = "delete from FL_Culture..QuestionItem where SurveyId='{0}' ";
                    SQL += " delete from FL_Culture..QuestionAnswerItem where SurveyId='{0}' ";
                    SQL = string.Format(SQL, tplEnt.Id);
                    DataHelper.ExecSql(SQL);
                    tplEnt.DoDelete();
                }

                SurveyQuestion Ent = SurveyQuestion.Find(Id);
                if (Ent != null)
                {
                    SurveyQuestion TplEnt = new SurveyQuestion();
                    TplEnt.IsFixed = "1";   //1 模板标志位
                    TplEnt.State = "1";     //表示启用
                    TplEnt.SurveyTitile = Ent.SurveyTitile;
                    TplEnt.Description = Ent.Description;
                    TplEnt.TurnSurveyId = Id;
                    TplEnt.CompanyId = Ent.CompanyId; //公司ID
                    TplEnt.CompanyName = Ent.CompanyName;
                    TplEnt.DoCreate();

                    var tplItems = QuestionItem.FindAllByProperties(QuestionItem.Prop_SurveyId, Id);
                    var tplSubItems = QuestionAnswerItem.FindAllByProperties(QuestionAnswerItem.Prop_SurveyId, Id);
                    foreach (var Item in tplItems)
                    {
                        QuestionItem tmpItem = new QuestionItem();
                        tmpItem = Item;
                        tmpItem.SurveyId = TplEnt.Id;
                        tmpItem.DoCreate();
                    }
                    foreach (var SubItem in tplSubItems)
                    {
                        QuestionAnswerItem tempSubEnt = new QuestionAnswerItem();
                        tempSubEnt = SubItem;
                        tempSubEnt.SurveyId = TplEnt.Id;
                        tempSubEnt.DoCreate();
                    }

                }
            }
        }

        //子项的添加
        private void AddQuestionItem()
        {
            QuestionItem qItem = new QuestionItem();
            qItem.SubItemId = Guid.NewGuid().ToString();

            qItem.IsMustAnswer = "是";
            qItem.QuestionType = "单选项";
            qItem.IsShowScore = "否";
            qItem.IsComment = "否";
            var SortIndex = this.RequestData.Get("SortIndex") + "";
            var SurveyId = RequestData.Get("SurveyId") + "";
            if (String.IsNullOrEmpty(SortIndex)) SortIndex = "0";
            qItem.SortIndex = int.Parse(SortIndex);

            qItem.SurveyId = SurveyId;
            qItem.DoCreate();
            this.PageState.Add("SubItemId", qItem.Id + "|" + qItem.SubItemId);
        }

        private void SaveItem()
        {
            IList<string> DataList = RequestData.GetList<string>("strRec");
            if (DataList.Count > 0)
            {
                IList<QuestionItem> qiEnts = DataList.Select(tent => JsonHelper.GetObject<QuestionItem>(tent) as QuestionItem).ToArray();
                foreach (QuestionItem itms in qiEnts)
                {
                    itms.Content = HttpUtility.UrlDecode(itms.Content);
                    itms.DoSave();
                }
            }
        }


        /// <summary>
        /// 复制题目选择项
        /// </summary>
        private void CopyItems()
        {
            string LastItem = RequestData.Get("LastItem") + "";
            if (!string.IsNullOrEmpty(LastItem))
            {
                string gid = Guid.NewGuid().ToString();

                var LastEnt = QuestionItem.FindFirstByProperties(QuestionItem.Prop_SubItemId, LastItem);
                var Ents = QuestionAnswerItem.FindAllByProperty("QuestionItemId", LastItem);
                foreach (var v in Ents)
                {
                    QuestionAnswerItem item = new QuestionAnswerItem();
                    item.Answer = v.Answer;
                    item.IsExplanation = v.IsExplanation;
                    item.IsShowScore = v.IsShowScore;
                    item.QuestionItemId = gid;    //* 
                    item.SurveyId = v.SurveyId;
                    item.SortIndex = v.SortIndex;
                    item.Score = v.Score;
                    item.DoCreate();
                }

                QuestionItem QiEnt = new QuestionItem();
                QiEnt = LastEnt;
                QiEnt.SubItemId = gid;   //*
                QiEnt.Content = string.Empty;
                QiEnt.SortIndex = LastEnt.SortIndex + 1;

                //QiEnt.IsComment = LastEnt.IsComment;
                //QiEnt.IsMustAnswer = LastEnt.IsMustAnswer;
                //QiEnt.IsShowScore = LastEnt.IsShowScore;
                //QiEnt.QuestionType = LastEnt.QuestionType;
                //QiEnt.SurveyId = LastEnt.SurveyId;
                //QiEnt.SubItems = LastEnt.SubItems;
                //QiEnt.Ext1 = LastEnt.Ext1;
                QiEnt.DoCreate();


                this.PageState.Add("SubItemId", gid + "|" + QiEnt.Id);
            }
            else
            {
                this.PageState.Add("SubItemId", "");
            }
        }

        /// <summary>
        /// 删除问题选项
        /// </summary>
        private void DeleteItem()
        {
            string QuestionItemId = RequestData.Get("QuestionItemId") + "";
            string SurveyId = RequestData.Get("SurveyId") + "";

            if (!string.IsNullOrEmpty(QuestionItemId))
            {
                if (QuestionItemId.Contains(",") || QuestionItemId.Split(',').Length > 0)
                {
                    string sql = @" delete from  FL_Culture..QuestionAnswerItem where  SurveyId='{0}' and  QuestionItemId in ({1}) ;";
                    sql += @" delete from  FL_Culture..QuestionItem where SurveyId='{0}' and  SubItemId in ({1}) ";

                    sql = string.Format(sql, SurveyId, QuestionItemId);
                    DataHelper.ExecSql(sql);
                }
                else
                {
                    string sql = @" delete from  FL_Culture..QuestionAnswerItem where  SurveyId='{0}' and  QuestionItemId='{1}' ;";
                    sql += @" delete from  FL_Culture..QuestionItem where SurveyId='{0}' and  SubItemId='{1}'";

                    sql = string.Format(sql, SurveyId, QuestionItemId);
                    DataHelper.ExecSql(sql);
                }
            }

        }

        /// <summary>
        /// 获取人员的组织信息 生成问卷对象 [0] WorkNo [1] org [3]mail [4] Phone
        /// </summary>
        private void GetOrgs()
        {
            string UserId = RequestData.Get("UserId") + "";
            if (!string.IsNullOrEmpty(UserId))
            {
                string sql = @"select A.WorkNo+'|'+ B.Name +'/'+C.Name +'|'+A.Email+'|'+A.Phone As OrgName 
                             from sysuser As A
	                            left join sysgroup As B
                              on A.pk_corp=B.GroupID
                            left join sysgroup As C
	                            on A.Pk_deptdoc=C.GroupID 
                            where A.UserID='{0}'";
                sql = string.Format(sql, UserId);
                this.PageState.Add("OrgName", DataHelper.QueryValue(sql));
            }
        }

        #region  根据配置生成人员
        /// <summary>
        /// 根据配置生成人员
        /// </summary>
        private void CreateUsr()
        {
            string SurveyId = RequestData.Get("SurveyId") + "";
            if (!string.IsNullOrEmpty(SurveyId))
            {
                //先清除
                string SQL = @" delete from  FL_Culture..SurveyFinallyUsr where SurveyId='{0}' and CreateWay='1' ;
                                delete from  FL_Culture..SurveyCanReaderUsr where SurveyId='{0}' and CreateWay='1' ";
                SQL = string.Format(SQL, SurveyId);
                DataHelper.ExecSql(SQL);

                StatisticsUser Usr = new StatisticsUser();   //人员统计
                Usr.CreateReadUser(SurveyId);
                Usr.CreateSurveyedUser(SurveyId);

                RemoveEnableUsr(SurveyId); //公司
                GetMiddleDBUser(SurveyId);

                SQL = @" select Id from  FL_Culture..SurveyFinallyUsr where SurveyId='{0}'";
                SQL = string.Format(SQL, SurveyId);
                DataTable obj = DataHelper.QueryDataTable(SQL);
                if (obj.Rows.Count > 0)
                {
                    this.PageState.Add("CreateState", "1");
                }
                else
                {
                    this.PageState.Add("CreateState", "0");
                }


            }
        }

        /// <summary>
        ///  移除关系错误的人员
        /// </summary>
        private void RemoveEnableUsr(string surveyId)
        {
            if (!string.IsNullOrEmpty(surveyId))
            {
                //调查对象
                var Ent = SurveyedObj.FindFirstByProperties(SurveyedObj.Prop_SurveyId, surveyId);
                if (Ent == null) return;
                var Arr = Ent.OrgIds.ToString().Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                if (Arr.Length <= 0) return;

                string OrgIds = "(";
                for (int i = 0; i < Arr.Length; i++)
                {
                    if (i > 0) OrgIds += ",";
                    OrgIds += "'" + Arr[i] + "'";
                }
                OrgIds += ")";

                string sql = @" With GetTree As
                                (
	                                select * from  sysgroup  where type=2 and GroupID  in {0}  
	                                union All
	                                select A.* from  sysgroup AS A
	                                  join GetTree AS B 
	                                on B.ParentID=A.GroupID
                                )
                               select GroupID from  GetTree where Name like  '%公司%'";
                sql = string.Format(sql, OrgIds);

                DataTable tmpDt = DataHelper.QueryDataTable(sql);
                if (tmpDt.Rows.Count <= 0) return;

                string CorpIds = " (";
                for (int i = 0; i < tmpDt.Rows.Count; i++)
                {
                    if (i > 0) CorpIds += ",";
                    CorpIds += "'" + tmpDt.Rows[i][0] + "'";
                }
                CorpIds += " ) ";
                //CreateWay='1' 系统生成 0 导入方式
                sql = @"delete from FL_Culture..SurveyFinallyUsr where SurveyId='{1}' and CreateWay='1' and  WorkNo not in 
                        (
	                        select psncode from  HR_OA_MiddleDB..fld_ryxx where pk_corp in {0}
                        )";
                sql = string.Format(sql, CorpIds, surveyId);
                sql = sql.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
                DataHelper.ExecSql(sql);


                //查看对象
                SurveyReaderObj Ent1 = SurveyReaderObj.FindFirstByProperties(SurveyReaderObj.Prop_SurveyId, surveyId);
                //if (Ent1 == null) return;
                if (Ent1 == null || string.IsNullOrEmpty(Ent1.OrgIds)) return;   //Change By WGM 9-30

                var Arr1 = Ent1.OrgIds.ToString().Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                if (Arr1.Length <= 0) return;

                OrgIds = "(";
                for (int i = 0; i < Arr1.Length; i++)
                {
                    if (i > 0) OrgIds += ",";
                    OrgIds += "'" + Arr1[i] + "'";
                }
                OrgIds += ")";

                sql = @" With GetTree As
                                (
	                                select * from  sysgroup  where type=2 and GroupID  in {0}  
	                                union All
	                                select A.* from  sysgroup AS A
	                                  join GetTree AS B 
	                                on B.ParentID=A.GroupID
                                )
                               select GroupID from  GetTree where Name like  '%公司%'";
                sql = string.Format(sql, OrgIds);

                DataTable tmpDt1 = DataHelper.QueryDataTable(sql);
                CorpIds = " (";
                for (int i = 0; i < tmpDt1.Rows.Count; i++)
                {
                    if (i > 0) CorpIds += ",";
                    CorpIds += "'" + tmpDt1.Rows[i][0] + "'";
                }
                CorpIds += " ) ";

                sql = @"delete from FL_Culture..SurveyCanReaderUsr where SurveyId='{1}' and  WorkNo not in 
                        (
	                        select psncode from  HR_OA_MiddleDB..fld_ryxx where pk_corp in {0}
                        )";
                sql = string.Format(sql, CorpIds, surveyId);
                sql = sql.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);
                DataHelper.ExecSql(sql);

            }


        }

        /// <summary>
        /// 与中间库取取交集
        /// </summary>
        public void GetMiddleDBUser(string surveyId)
        {
            //学历,职位等级,人员类别
            var Ent = SurveyedObj.FindFirstByProperties(SurveyedObj.Prop_SurveyId, surveyId);
            string BornAddr = Ent.BornAddr;
            string Major = Ent.Major;  //暂无
            string PositionDegree0 = Ent.PositionDegree0;
            string PositionDegree1 = Ent.PositionDegree1;
            string PersonType = Ent.PersonType;
            string CruxPositon = Ent.CruxPositon;
            string PositionSeq = Ent.PositionSeq;  //岗位序列

            DateTime? StartAge = Ent.StartAge;     //年龄范围
            DateTime? EndAge = Ent.EndAge;
            //*********这句判断很关键
            if (string.IsNullOrEmpty(BornAddr + Major + PositionDegree0 + PositionDegree1 + PersonType + PositionSeq + CruxPositon + StartAge + EndAge)) return;

            //frist delete 
            string SQL = @"IF (OBJECT_ID('tempdb..#MidDb') IS NOT NULL)
                                DROP TABLE tempdb..#MidDb;";
            DataHelper.ExecSql(SQL);

            SQL = @"select A.psncode,psnname into #MidDb from HR_OA_MiddleDB..fld_ryxx As A
                   left join  HR_OA_MiddleDB..fld_rylb As B 
                     on A.pk_psncl=B.pk_fld_rylb
                   left join  HR_OA_MiddleDB..fld_gwdj As C
                      on A.pk_gwdj=C.pk_dazj
				   left join HR_OA_MiddleDB..fld_gw As D
					on A.pk_gw=D.pk_jobcode 
                   where ( A.outdutydate is null or  A.outdutydate='') ";

            SQL = SQL.Replace("HR_OA_MiddleDB", Global.HR_OA_MiddleDB);

            string where = string.Empty;
            if (!string.IsNullOrEmpty(PositionDegree0))
            {
                where += " and  cast(dacode as int) >= " + PositionDegree0 + " ";
            }
            if (!string.IsNullOrEmpty(PositionDegree1))
            {
                where += " and  cast(dacode as int) <= " + PositionDegree1 + " ";
            }
            if (!string.IsNullOrEmpty(PersonType))
            {
                where += " and pk_fld_rylb='" + PersonType + "' ";
            }
            if (!string.IsNullOrEmpty(BornAddr))  //籍贯
            {
                string temp = string.Empty;
                string[] arr = BornAddr.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                for (int i = 0; i < arr.Length; i++)
                {
                    if (i > 0) temp += " or ";
                    temp += " ( A.def5 like '%" + arr[i] + "%' or '" + arr[i] + "' like '%'+A.def5+'%' ) ";  //def5 籍贯字段
                }
                where += " and (" + temp + ") ";
            }
            if (!string.IsNullOrEmpty(Major))  //学历
            {
                where += " and  pk_xl like  '%" + Major + "%' ";
            }
            if (!string.IsNullOrEmpty(CruxPositon)) //关键岗位
            {
                where += "  and  D.def1 = '" + CruxPositon + "' ";
            }
            if (!string.IsNullOrEmpty(PositionSeq))//岗位序列
            {
                string temp = string.Empty;
                string[] arr = PositionSeq.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                for (int i = 0; i < arr.Length; i++)
                {
                    if (i > 0) temp += " or ";
                    temp += " ( D.def2 like '%" + arr[i] + "%' or '" + arr[i] + "' like '%'+D.def2+'%' ) ";  //
                }
                where += " and (" + temp + ") ";
            }
            //年龄范围
            if (StartAge.HasValue)//start
            {
                string tmp = "  and cast(A.def4 as datetime ) >= cast('{0}' as datetime) ";
                tmp = string.Format(tmp, StartAge.GetValueOrDefault().ToString("yyyy-MM-dd"));
                where += tmp;
            }
            if (EndAge.HasValue) //end
            {
                string tmp = "  and cast(A.def4 as datetime ) <= cast('{0}' as datetime) ";
                tmp = string.Format(tmp, EndAge.GetValueOrDefault().ToString("yyyy-MM-dd"));
                where += tmp;
            }

            SQL += where;


            //取交集1 生成方式
            string delSQL = @" delete from FL_Culture..SurveyFinallyUsr where SurveyId='{0}' and CreateWay='1' and UserId not in
                                (
	                                select distinct  A.UserId  from FL_Culture..SurveyFinallyUsr As A
	                                inner join   #MidDb As B
	                                 on B.psncode=A.WorkNo where SurveyId='{0}'
                                )";
            delSQL = string.Format(delSQL, surveyId);
            SQL += "; " + delSQL;

            DataHelper.ExecSql(SQL);
        }

        #endregion

        #region 导入积分
        /// <summary>
        /// 导入积分
        /// </summary>
        private void DoImpScore()
        {
            string FileName = RequestData.Get("FileId") + "";
            if (!string.IsNullOrEmpty(FileName))
            {
                FileName = MapPath("/Document/") + FileName;
                DataTable UsrScoreDt = ImpUser(FileName);

                for (int i = 0; i < UsrScoreDt.Rows.Count; i++)
                {
                    var Ent = SysUser.FindFirstByProperties(SysUser.Prop_WorkNo, UsrScoreDt.Rows[i]["工号"].ToString());
                    if (Ent == null) continue;
                    SurveyScore Ss = new SurveyScore();
                    Ss.UserID = Ent.UserID;
                    Ss.WorkNo = Ent.WorkNo;
                    Ss.UserName = Ent.Name;

                    int score = 0;
                    if (int.TryParse(UsrScoreDt.Rows[i]["积分"].ToString(), out score))
                    {
                        score = int.Parse(UsrScoreDt.Rows[i]["积分"].ToString());
                    }
                    Ss.Score = score;
                    Ss.Detail = "导入";
                    Ss.DoCreate();
                }
                this.PageState.Add("State", "1");
            }
        }
        #endregion


        #region 导入用户
        private void DoImpUser()
        {
            string FileName = RequestData.Get("FileId") + "";
            string SurveyId = RequestData.Get("SurveyId") + "";
            string Sign = RequestData.Get("Sign") + "";         //区分导入对象 Surveyed Reader 

            FileName = MapPath("../Document/") + FileName;
            DataTable dt = ImpUser(FileName);

            if (Sign.Contains("Reader"))
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    SurveyCanReaderUsr Usr = new SurveyCanReaderUsr();
                    Usr.SurveyId = SurveyId;
                    Usr.WorkNo = dt.Rows[i]["工号"].ToString();
                    Usr.UserName = dt.Rows[i]["姓名"].ToString();
                    Usr.DeptName = GetOrgs(dt.Rows[i]["工号"].ToString());
                    try
                    {
                        var User = SysUser.FindFirstByProperties(SysUser.Prop_WorkNo, dt.Rows[i]["工号"].ToString(), SysUser.Prop_Status, 1);
                        Usr.UserId = User.UserID;
                    }
                    catch { }


                    Usr.CreateWay = "0";   //表示导入
                    Usr.DoCreate();
                }
                DataHelper.ExecSql("Delete from FL_Culture..SurveyCanReaderUsr where UserId='' or WorkNo='' ");
            }
            else if (Sign.Contains("Surveyed"))
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    SurveyFinallyUsr Usr = new SurveyFinallyUsr();
                    Usr.SurveyId = SurveyId;
                    Usr.WorkNo = dt.Rows[i]["工号"].ToString();
                    Usr.UserName = dt.Rows[i]["姓名"].ToString();
                    Usr.DeptName = GetOrgs(dt.Rows[i]["工号"].ToString());

                    try
                    {
                        //这里还需处理 工号错误
                        var User = SysUser.FindFirstByProperties(SysUser.Prop_WorkNo, dt.Rows[i]["工号"].ToString(), SysUser.Prop_Status, 1);
                        Usr.UserId = User.UserID;
                    }
                    catch { }

                    Usr.CreateWay = "0";     //表示导入
                    Usr.DoCreate();
                }
                DataHelper.ExecSql("Delete from FL_Culture..SurveyFinallyUsr where UserId='' or WorkNo=''  ");
            }

            this.PageState.Add("State", "1");
        }

        /// <summary>
        /// 导入用户
        /// </summary>
        public DataTable ImpUser(string FileName)
        {
            string Extend = string.Empty;   //文件扩展名
            string strConn = string.Empty;

            if (FileName.Contains(","))
            {
                FileName = FileName.Substring(0, FileName.Length - 1);
                Extend = FileName.Split(new string[] { "." }, StringSplitOptions.RemoveEmptyEntries)[1];
            }
            else
            {
                Extend = FileName.Split(new string[] { "." }, StringSplitOptions.RemoveEmptyEntries)[1];
            }

            strConn = GetConStr(FileName);

            OleDbConnection XLSconn = new OleDbConnection(strConn);
            OleDbDataAdapter da = new OleDbDataAdapter(" select * from [Sheet1$] ", XLSconn);
            DataTable dt = new DataTable();
            da.Fill(dt);


            if (dt.Rows.Count > 0)
            {
                try
                {
                    if (File.Exists(FileName))
                        File.Delete(FileName);
                }
                catch
                {
                }
            }

            return dt;
        }


        private string GetConStr(string Path)
        {
            string strConn = string.Empty;
            if (Path.Contains("xlsx")) //2007的链接参数
            {
                strConn = "Provider=Microsoft.ACE.OLEDB.12.0;" + "Data Source=" + Path + ";" + "Extended Properties=Excel 12.0 Xml;Persist Security Info=False";
            }
            else  //2003的链接参数
            {
                strConn = "Provider=Microsoft.Jet.OLEDB.4.0;" + "Data Source=" + Path + ";" + "Extended Properties=Excel 8.0;Persist Security Info=False";
            }
            return strConn;
        }



        /// <summary>
        /// 获取人员的组织信息  
        /// </summary>
        private string GetOrgs(string WorkNo)
        {
            if (!string.IsNullOrEmpty(WorkNo))
            {
                string sql = @"select  B.Name +'/'+C.Name As OrgName from sysuser As A
	                            left join sysgroup As B
                              on A.pk_corp=B.GroupID
                            left join sysgroup As C
	                            on A.Pk_deptdoc=C.GroupID 
                            where A.WorkNo='{0}'";
                sql = string.Format(sql, WorkNo);
                object obj = DataHelper.QueryValue(sql);
                return obj == null ? "" : obj.ToString();
            }
            else
            {
                return "";
            }
        }

        #endregion
    }
}

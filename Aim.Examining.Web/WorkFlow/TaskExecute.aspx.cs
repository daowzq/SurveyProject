using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Aim.Data;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;
using Aim.WorkFlow;
using System.Text;
using System.Xml.Serialization;
using System.IO;
using System.Xml;
using Aim.WorkFlow.WinService;

namespace Aim.Portal.Web.WorkFlow
{
    public partial class TaskExecute : BasePage
    {
        public string NextStep = "";
        public string FlowInstanceId = "";
        public string FormUrl = "";
        public string FlowDefineId = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (this.RequestActionString.ToLower())
            {
                case "submittask":
                    Aim.WorkFlow.WinService.Task task = Aim.WorkFlow.WorkFlow.ServiceClient.GetTaskByTaskId(this.RequestData["TaskId"].ToString());
                    if (task.Status == 0)
                        Aim.WorkFlow.WorkFlow.SubmitTask("", task.WorkflowInstanceID, task.BookmarkName, GetApprovalResult(task));
                    PageState.Add("message", "提交成功!");
                    break;
                case "submitaddtask":
                    Aim.WorkFlow.Task taskOld = Aim.WorkFlow.Task.Find(this.RequestData["TaskId"].ToString());
                    string userIds = this.RequestData.Get<string>("UserIds");
                    string userNames = this.RequestData.Get<string>("UserNames");
                    string[] userIdss = userIds.Split(',');
                    string[] userNamess = userNames.Split(',');
                    for (int i = 0; i < userIdss.Length; i++)
                    {
                        if (userIdss[i].Trim() == "") continue;
                        Aim.WorkFlow.Task taskNew = new Aim.WorkFlow.Task();
                        DataHelper.MergeData<Aim.WorkFlow.Task>(taskNew, taskOld);
                        taskNew.Owner = userNamess[i];
                        taskNew.OwnerId = userIdss[i];
                        taskNew.Ext1 = "Branch";
                        taskNew.Ext2 = taskOld.ID;
                        taskNew.CreatedTime = DateTime.Now;
                        taskNew.UpdatedTime = DateTime.Now;
                        taskNew.ApprovalNodeName = taskNew.ApprovalNodeName + "[分发]";
                        taskNew.Create();
                    }
                    PageState.Add("message", "分发成功!");
                    break;
                case "savetask":
                    Aim.WorkFlow.Task tas = Aim.WorkFlow.Task.Find(this.RequestData["TaskId"].ToString());
                    tas.Description = this.RequestData["Opinion"].ToString();
                    tas.SaveAndFlush();
                    break;
                case "getusers":
                    GetNextUsers(this.RequestData["TemplateId"].ToString(), this.RequestData["FlowInstanceId"].ToString(), this.RequestData["Name"].ToString(), this.RequestData["CurrentName"].ToString());
                    break;
                case "getbackusers":
                    Aim.WorkFlow.Task[] tks = Aim.WorkFlow.Task.FindAllByProperties(Aim.WorkFlow.Task.Prop_WorkflowInstanceID, this.RequestData["FlowInstanceId"].ToString(), Aim.WorkFlow.Task.Prop_ApprovalNodeName, this.RequestData["TaskName"].ToString());
                    if (tks != null && tks.Length == 1)//打回情况一个人的时候有效,多人的话,还是从之前配置里取
                    {
                        this.PageState.Add("NextUserIds", tks[0].OwnerId);
                        this.PageState.Add("NextUserNames", tks[0].Owner);
                    }
                    break;
                case "checkstate":
                    //检查如果有后续任务未提交,则设置状态为已提交.
                    Aim.WorkFlow.Task taskpre = Aim.WorkFlow.Task.Find(this.RequestData["TaskId"].ToString());
                    if (taskpre.Status == 0 && DataHelper.QueryDataTable("select * from Task where WorkFlowInstanceId='" + taskpre.WorkflowInstanceID + "' and ApprovalNodeName<>'" + taskpre.ApprovalNodeName + "' and CreatedTime>'" + taskpre.CreatedTime + "' and Status=0").Rows.Count > 0)
                    {
                        taskpre.Status = 4;
                        taskpre.Save();
                    }
                    break;
                default:
                    if (this.RequestData["TaskId"] != null && !string.IsNullOrEmpty(this.RequestData["TaskId"].ToString()))
                    {
                        Aim.WorkFlow.Task fTask = Aim.WorkFlow.Task.Find(this.RequestData["TaskId"].ToString());
                        if (!fTask.UpdatedTime.HasValue)
                        {
                            fTask.UpdatedTime = DateTime.Now;
                            fTask.Save();
                        }
                        if (fTask.Ext1 == "Branch")
                        {
                            Response.Redirect("FreeTask.aspx?Type=Branch&TaskId=" + this.RequestData["TaskId"].ToString());
                        }
                        if (fTask.Flag == "Add")
                            fTask.ApprovalNodeName = fTask.Ext1;
                        //捕获节点扩展信息配置，如已阅，加签，并行等信息
                        this.PageState.Add("ExtData", GetNodeExtData(fTask));
                        Aim.WorkFlow.WorkflowInstance instance = WorkflowInstance.Find(fTask.WorkflowInstanceID);
                        this.PageState.Add("InstanceId", fTask.WorkflowInstanceID);
                        this.PageState.Add("TemplateId", instance.WorkflowTemplateID);
                        FlowInstanceId = instance.ID;
                        FormUrl = instance.RelateUrl;
                        FlowDefineId = instance.WorkflowTemplateID;
                        Title = fTask.WorkFlowName + "->" + fTask.ApprovalNodeName;
                        XmlSerializer xs = new XmlSerializer(typeof(TaskContext));
                        if (!string.IsNullOrEmpty(fTask.Context))
                        {
                            /*Aim.WorkFlow.WorkflowTemplate temp = Aim.WorkFlow.WorkflowTemplate.Find(instance.WorkflowTemplateID);
                            XmlDocument doc = new XmlDocument();
                            doc.LoadXml(temp.XAML);
                            XmlElement root = doc.DocumentElement;
                            string nameSpace = root.NamespaceURI;
                            XmlNamespaceManager nsmgr = new XmlNamespaceManager(doc.NameTable);
                            nsmgr.AddNamespace("ns", nameSpace);
                            nsmgr.AddNamespace("x", "http://schemas.microsoft.com/winfx/2006/xaml");
                            nsmgr.AddNamespace("bwa", "clr-namespace:BPM.WF.Activities;assembly=BPM.WF");
                            XmlNode currentNode = root.SelectSingleNode("//*[contains(@ApprovalNodeConfig,'" + fTask.ApprovalNodeName + "')]", nsmgr);*/
                            StringReader sr = new StringReader(fTask.Context);
                            TaskContext content = xs.Deserialize(sr) as TaskContext;
                            if (content.SwitchRules.Length > 0)
                            {
                                TaskContextSwitchRuleNextAction[] arrs = content.SwitchRules[0].NextActions;
                                string comboxdataText = "['{0}','{1}'],";
                                if (arrs.Length > 0)
                                {
                                    int first = 0;
                                    foreach (TaskContextSwitchRuleNextAction ar in arrs)
                                    {
                                        //GetNextRoute(currentNode, nsmgr, ar.Name)
                                        NextStep += string.Format(comboxdataText, ar.Name, ar.Name);
                                        if (first == 0)
                                            GetNextUsers(instance.WorkflowTemplateID, fTask.WorkflowInstanceID, ar.Name, fTask.ApprovalNodeName);
                                        first++;
                                    }
                                }
                                else
                                    NextStep += string.Format("['','{0}'],", "结束");
                            }
                            else
                                NextStep += string.Format("['','{0}'],", "结束");
                        }
                        else
                            NextStep += string.Format("['','{0}'],", "结束");
                        NextStep = NextStep.TrimEnd(',');
                        Aim.WorkFlow.Task[] tasks = Aim.WorkFlow.Task.FindAllByProperty("CreatedTime", "WorkflowInstanceID", fTask.WorkflowInstanceID).OrderBy(ens => !ens.FinishTime.HasValue ? DateTime.Now : ens.FinishTime).OrderBy(ens => ens.CreatedTime).ToArray();
                        this.PageState.Add("Tasks", JsonHelper.GetJsonString(tasks));
                        this.PageState.Add("Task", fTask);
                    }
                    break;
            }
        }

        public string GetNodeExtData(Aim.WorkFlow.Task task)
        {
            string contents = "";
            Aim.WorkFlow.WorkflowInstance temp = Aim.WorkFlow.WorkflowInstance.Find(task.WorkflowInstanceID);
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(temp.XAML);
            XmlElement root = doc.DocumentElement;
            string nameSpace = root.NamespaceURI;
            XmlNamespaceManager nsmgr = new XmlNamespaceManager(doc.NameTable);
            nsmgr.AddNamespace("ns", nameSpace);
            nsmgr.AddNamespace("x", "http://schemas.microsoft.com/winfx/2006/xaml");
            nsmgr.AddNamespace("bwa", "clr-namespace:BPM.WF.Activities;assembly=BPM.WF");

            string current = "ApprovalNode Name=\"" + task.ApprovalNodeName + "\"";
            XmlNode currentNode = root.SelectSingleNode("//*[contains(@ApprovalNodeConfig,'" + current + "')]", nsmgr);
            if (currentNode != null)//直接路由
            {
                string config = System.Web.HttpUtility.HtmlDecode(currentNode.Attributes["ApprovalNodeConfig"].InnerXml);
                XmlDocument docC = new XmlDocument();
                docC.LoadXml(config);
                if (docC.DocumentElement.Attributes["ExtData"] != null)
                    return docC.DocumentElement.Attributes["ExtData"].InnerText.ToString();
            }
            return contents;
        }
        public string GetNextRoute(XmlNode node, XmlNamespaceManager nsmgr, string routeString)
        {
            XmlNode nodeOr = node.NextSibling.SelectSingleNode("ns:FlowSwitch/ns:FlowStep[@x:Key='" + routeString + "']", nsmgr);
            if (nodeOr != null)
            {
                node = nodeOr.SelectSingleNode("bwa:Approval_Node", nsmgr);
                string config = System.Web.HttpUtility.HtmlDecode(node.Attributes["ApprovalNodeConfig"].InnerXml);
                XmlDocument docC = new XmlDocument();
                docC.LoadXml(config);
                return docC.DocumentElement.Attributes["Name"].InnerText.ToString();
            }
            else
                return routeString;

        }

        public void GetNextUsers(string templateId, string instanctId, string nextName, string currentName)
        {
            Aim.WorkFlow.WorkflowInstance temp = Aim.WorkFlow.WorkflowInstance.Find(instanctId);
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(temp.XAML);
            XmlElement root = doc.DocumentElement;
            string nameSpace = root.NamespaceURI;
            XmlNamespaceManager nsmgr = new XmlNamespaceManager(doc.NameTable);
            nsmgr.AddNamespace("ns", nameSpace);
            nsmgr.AddNamespace("x", "http://schemas.microsoft.com/winfx/2006/xaml");
            nsmgr.AddNamespace("bwa", "clr-namespace:BPM.WF.Activities;assembly=BPM.WF");

            string current = "ApprovalNode Name=\"" + currentName + "\"";
            XmlNode currentNode = root.SelectSingleNode("//*[contains(@ApprovalNodeConfig,'" + current + "')]", nsmgr);
            //XmlNode node = root.SelectSingleNode("//*[@x:Key='" + nextName + "']", nsmgr);
            XmlNode node = currentNode.NextSibling.SelectSingleNode("ns:FlowSwitch/ns:FlowStep[@x:Key='" + nextName + "']", nsmgr);
            string nextUserIds = "";
            string nextUserNames = "";
            string nextUserAccountType = "";
            string nextNodeName = "";
            string content = "ApprovalNode Name=\"" + nextName + "\"";
            if (node != null)//switch路由
            {
                node = node.SelectSingleNode("bwa:Approval_Node", nsmgr);
                if (node != null)
                {
                    string config = System.Web.HttpUtility.HtmlDecode(node.Attributes["ApprovalNodeConfig"].InnerXml);
                    SetNextUsers(config, ref nextUserIds, ref nextUserNames, ref nextUserAccountType, ref nextNodeName);
                }
            }
            else if (root.SelectSingleNode("//*[contains(@ApprovalNodeConfig,'" + content + "')]", nsmgr) != null)//直接路由
            {
                string config = System.Web.HttpUtility.HtmlDecode(root.SelectSingleNode("//*[contains(@ApprovalNodeConfig,'" + content + "')]", nsmgr).Attributes["ApprovalNodeConfig"].InnerXml);
                SetNextUsers(config, ref nextUserIds, ref nextUserNames, ref nextUserAccountType, ref nextNodeName);
            }
            //如果是打回的情况
            XmlNode nextNode = root.SelectSingleNode("//*[contains(@ApprovalNodeConfig,'" + nextName + "')]", nsmgr);
            if (currentNode.ParentNode.SelectSingleNode("ns:FlowStep.Next/ns:FlowSwitch/x:Reference/x:Key", nsmgr) != null)//switch情况的打回
            {
                if (currentNode.ParentNode.SelectSingleNode("ns:FlowStep.Next/ns:FlowSwitch/x:Reference[x:Key/text()='" + nextName + "']", nsmgr) != null)
                {
                    string reference = currentNode.ParentNode.SelectSingleNode("ns:FlowStep.Next/ns:FlowSwitch/x:Reference[x:Key/text()='" + nextName + "']", nsmgr).ChildNodes[0].InnerText;
                    nextNode = root.SelectSingleNode("//*[@x:Name='" + reference + "']", nsmgr);
                    string config = System.Web.HttpUtility.HtmlDecode(nextNode.SelectSingleNode("bwa:Approval_Node", nsmgr).Attributes["ApprovalNodeConfig"].InnerXml);
                    XmlDocument docC = new XmlDocument();
                    docC.LoadXml(config);
                    nextNodeName = docC.DocumentElement.Attributes["Name"].InnerText.ToString();
                    SetNextUsers(instanctId, nextNodeName, ref nextUserIds, ref nextUserNames, ref nextUserAccountType);
                    if (nextUserIds == null || nextUserIds == "")
                    {
                        content = "ApprovalNode Name=\"" + nextNodeName + "\"";
                        config = System.Web.HttpUtility.HtmlDecode(root.SelectSingleNode("//*[contains(@ApprovalNodeConfig,'" + content + "')]", nsmgr).Attributes["ApprovalNodeConfig"].InnerXml);
                        SetNextUsers(config, ref nextUserIds, ref nextUserNames, ref nextUserAccountType, ref nextNodeName);
                    }
                }
            }
            else if (currentNode.SelectSingleNode("parent::*/ns:FlowStep.Next/x:Reference", nsmgr) != null)//正常路由打回
            {
                string refer = currentNode.SelectSingleNode("parent::*/ns:FlowStep.Next/x:Reference", nsmgr).InnerText;
                if (refer == nextNode.ParentNode.Attributes["x:Name"].Value)
                {
                    SetNextUsers(instanctId, nextName, ref nextUserIds, ref nextUserNames, ref nextUserAccountType);
                }
                nextNodeName = nextName;
            }
            this.PageState.Add("NextUserIds", nextUserIds.TrimEnd(','));
            this.PageState.Add("NextUserNames", nextUserNames.TrimEnd(','));
            this.PageState.Add("NextUserType", nextUserAccountType);
            this.PageState.Add("NextNodeName", nextNodeName);
        }
        public void SetNextUsers(string instanceId, string NodeName, ref string userIds, ref string userNames, ref string accountType)
        {
            Aim.WorkFlow.Task[] tks = Aim.WorkFlow.Task.FindAllByProperties(Aim.WorkFlow.Task.Prop_WorkflowInstanceID, instanceId, Aim.WorkFlow.Task.Prop_ApprovalNodeName, NodeName);
            foreach (Aim.WorkFlow.Task tk in tks)
            {
                if (userIds.IndexOf(tk.OwnerId) >= 0) continue;
                userIds += tk.OwnerId + ",";
                userNames += tk.Owner + ",";
                accountType = "ADAccount";
            }
        }
        public void SetNextUsers(string config, ref string userIds, ref string userNames, ref string accountType, ref string nextNodeName)
        {
            XmlDocument docC = new XmlDocument();
            docC.LoadXml(config);
            nextNodeName = docC.DocumentElement.Attributes["Name"].InnerText.ToString();
            if (docC.DocumentElement.SelectSingleNode("ApprovalUnits") != null && docC.DocumentElement.SelectSingleNode("ApprovalUnits").ChildNodes.Count > 0)
            {
                XmlNodeList list = docC.DocumentElement.SelectSingleNode("ApprovalUnits").ChildNodes;
                foreach (XmlNode chd in list)
                {
                    userIds += chd.ChildNodes[0].Attributes["Value"].InnerText + ",";
                    userNames += chd.ChildNodes[0].Attributes["Name"].InnerText + ",";
                    accountType = chd.ChildNodes[0].Attributes["Type"].InnerText;
                }
            }
        }

        public Aim.WorkFlow.WinService.ApprovalResult GetApprovalResult(Aim.WorkFlow.WinService.Task task)
        {
            Aim.WorkFlow.WinService.ApprovalResult result = new Aim.WorkFlow.WinService.ApprovalResult()
            {
                Task = task,
                TaskId = this.RequestData["TaskId"].ToString(),
                ApprovalDateTime = DateTime.Now,
                Opinion = Aim.WorkFlow.WinService.ApprovalOpinion.同意,
                ExtendedProperties = new List<KeyValuePair_V2>().ToArray(),
                ApprovalNodeSkipInfoList = new List<ApprovalNodeSkipInfo>().ToArray(),

                Comment = this.RequestData["Route"] == null ? "" : this.RequestData["Route"].ToString(),
            };
            /// 设定跳过后续哪些节点. 
            /*List<ApprovalNodeSkipInfo> approvalNodeSkipInfos = new List<ApprovalNodeSkipInfo>();

            if (checkBox1.IsChecked.HasValue && checkBox1.IsChecked.Value)
                approvalNodeSkipInfos.Add(new ApprovalNodeSkipInfo() { ApprovalNodeContextName = "经理审批", CanBeSkipped = true });

            if (checkBox2.IsChecked.HasValue && checkBox2.IsChecked.Value)
                approvalNodeSkipInfos.Add(new ApprovalNodeSkipInfo() { ApprovalNodeContextName = "主管审批", CanBeSkipped = true });

            result.ApprovalNodeSkipInfoList = approvalNodeSkipInfos.ToArray();
            */
            /// 设定选中的流转节点
            if (this.RequestData["Route"] != null && this.RequestData["Route"].ToString() != "")
            {
                result.SwitchRules = new Aim.WorkFlow.WinService.KeyValuePair_V2[] 
                    { 
                        new Aim.WorkFlow.WinService.KeyValuePair_V2() 
                        { 
                            Key = task.ApprovalNodeName, 
                            Value = this.RequestData["Route"].ToString() 
                        } 
                    };
                /// 设定指定流转节点的审批人员的信息. 
                List<ApprovalNodeContext> approvalNodeContexts = new List<ApprovalNodeContext>();
                ApprovalNodeContext specifiedApprovalNodeContext = new ApprovalNodeContext();
                specifiedApprovalNodeContext.Name = this.RequestData["NextNodeName"] == null ? "" : this.RequestData["NextNodeName"].ToString();
                if (!string.IsNullOrEmpty(this.RequestData.Get<string>("Jumps")))
                {
                    List<ApprovalNodeSkipInfo> approvalNodeSkipInfos = new List<ApprovalNodeSkipInfo>();
                    string[] jumps = this.RequestData.Get<string>("Jumps").Split(';');
                    foreach (string jump in jumps)
                    {
                        if (jump.Trim() != "")
                        {
                            approvalNodeSkipInfos.Add(new ApprovalNodeSkipInfo() { ApprovalNodeContextName = jump, CanBeSkipped = true });
                            specifiedApprovalNodeContext.Name = jump;
                            result.SwitchRules.ToList().Add(new Aim.WorkFlow.WinService.KeyValuePair_V2()
                            {
                                Key = jump,
                                Value = "下一步"
                            }
                            );
                        }
                    }
                    if (approvalNodeSkipInfos.Count > 0)
                    {
                        result.ApprovalNodeSkipInfoList = approvalNodeSkipInfos.ToArray();
                    }
                }

                //if (this.RequestData["UserType"] != null)
                //{
                if (this.RequestData["UserType"] != null && this.RequestData["UserType"].ToString() != "ADAccount" && this.RequestData["UserIds"].ToString() != "")//如果是组或者角色
                {
                    string[] grpIds = this.RequestData["UserIds"].ToString().Split(',');
                    List<ApprovalUnitContext> approvalUnitContexts = new List<ApprovalUnitContext>();
                    foreach (string groupId in grpIds)
                    {
                        string cou = @"select count(*) from (select distinct ParentDeptName from View_SysUserGroup where 
ChildDeptName=(Select Name from SysRole where RoleID='{0}')) a";
                        string sql = "";
                        int count = DataHelper.QueryValue<int>(string.Format(cou, groupId));
                        IList<EasyDictionary> lists = null;
                        //判断角色的唯一性,多部门角色需要对应到部门
                        if (count > 1)
                        {
                            sql = @"select distinct UserID,UserName Name from View_SysUserGroup where ChildDeptName in (Select Name from SysRole where RoleID='{0}') 
and (select top 1 Path+'.'+DeptId from View_SysUserGroup where UserID='{1}') like '%'+Path+'%'";
                            if (this.RequestData.Get("StartUserId") != null && this.RequestData.Get<string>("StartUserId") != "")
                                sql = string.Format(sql, groupId, this.RequestData.Get("StartUserId"));
                            else
                                sql = string.Format(sql, groupId, this.UserInfo.UserID);
                            lists = DataHelper.QueryDictList(sql);
                        }
                        else if (count == 1)
                        {
                            sql = "select UserId,UserName Name from View_SysUserGroup where ChildDeptName=(Select Name from SysRole where RoleID='{0}')";
                            sql = string.Format(sql, groupId);
                            lists = DataHelper.QueryDictList(sql);
                        }
                        if (lists.Count == 0)
                        {
                            throw new Exception("缺少角色" + this.RequestData["UserNames"] + "的人员!");
                        }
                        foreach (EasyDictionary ed in lists)
                        {
                            approvalUnitContexts.Add(new ApprovalUnitContext() { Approver = new Approver() { Value = ed["UserID"].ToString(), Name = ed["Name"].ToString() } });
                        }
                    }
                    specifiedApprovalNodeContext.ApprovalUnitContexts = approvalUnitContexts.ToArray();
                    approvalNodeContexts.Add(specifiedApprovalNodeContext);
                    result.SpecifiedApprovalNodeContexts = approvalNodeContexts.ToArray();
                }
                //}
                else if (this.RequestData["UserIds"] != null && this.RequestData["UserIds"].ToString().Trim() != "")
                {
                    string userIds = this.RequestData["UserIds"].ToString().TrimEnd(',');
                    string userNames = this.RequestData["UserNames"].ToString().TrimEnd(',');
                    LoadFromConfigString(specifiedApprovalNodeContext, userIds, userNames);
                    approvalNodeContexts.Add(specifiedApprovalNodeContext);
                    result.SpecifiedApprovalNodeContexts = approvalNodeContexts.ToArray();
                }
                /*List<ApprovalNodeContext> approvalNodeContexts = new List<ApprovalNodeContext>();

                ApprovalNodeContext specifiedApprovalNodeContext = new ApprovalNodeContext();
                specifiedApprovalNodeContext.Name = this.RequestData["RouteName"].ToString();

                string userIds = this.RequestData["UserIds"].ToString().TrimEnd(',');
                string userNames = this.RequestData["UserNames"].ToString().TrimEnd(',');
                LoadFromConfigString(specifiedApprovalNodeContext, userIds,userNames);
                approvalNodeContexts.Add(specifiedApprovalNodeContext);
                result.SpecifiedApprovalNodeContexts = approvalNodeContexts.ToArray();*/
            }

            return result;
        }

        private ApprovalNodeContext LoadFromConfigString(ApprovalNodeContext approvalNodeContext, string userIds, string userNames)
        {
            //TODO: 需要扩展, 将config扩展为更复杂的格式.

            string[] accounts = userIds.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            string[] accountNames = userNames.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            List<ApprovalUnitContext> approvalUnitContexts = new List<ApprovalUnitContext>();


            for (int i = 0; i < accounts.Length; i++)
                approvalUnitContexts.Add(new ApprovalUnitContext() { Approver = new Approver() { Value = accounts[i], Name = accountNames[i] } });

            approvalNodeContext.ApprovalUnitContexts = approvalUnitContexts.ToArray();


            return approvalNodeContext;
        }
    }


    //------------------------------------------------------------------------------
    // <auto-generated>
    //     This code was generated by a tool.
    //     Runtime Version:4.0.30319.1
    //
    //     Changes to this file may cause incorrect behavior and will be lost if
    //     the code is regenerated.
    // </auto-generated>
    //------------------------------------------------------------------------------


    // 
    // This source code was auto-generated by xsd, Version=4.0.30319.1.
    // 


    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "4.0.30319.1")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    [System.Xml.Serialization.XmlRootAttribute(Namespace = "", IsNullable = false)]
    public partial class TaskContext
    {

        private TaskContextSwitchRule[] switchRulesField;

        /// <remarks/>
        [System.Xml.Serialization.XmlArrayAttribute(Form = System.Xml.Schema.XmlSchemaForm.Unqualified)]
        [System.Xml.Serialization.XmlArrayItemAttribute("SwitchRule", Form = System.Xml.Schema.XmlSchemaForm.Unqualified, IsNullable = false)]
        public TaskContextSwitchRule[] SwitchRules
        {
            get
            {
                return this.switchRulesField;
            }
            set
            {
                this.switchRulesField = value;
            }
        }
    }

    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "4.0.30319.1")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class TaskContextSwitchRule
    {

        private TaskContextSwitchRuleNextAction[] nextActionsField;

        private string nodeNameField;

        /// <remarks/>
        [System.Xml.Serialization.XmlArrayAttribute(Form = System.Xml.Schema.XmlSchemaForm.Unqualified)]
        [System.Xml.Serialization.XmlArrayItemAttribute("NextAction", Form = System.Xml.Schema.XmlSchemaForm.Unqualified, IsNullable = false)]
        public TaskContextSwitchRuleNextAction[] NextActions
        {
            get
            {
                return this.nextActionsField;
            }
            set
            {
                this.nextActionsField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string NodeName
        {
            get
            {
                return this.nodeNameField;
            }
            set
            {
                this.nodeNameField = value;
            }
        }
    }

    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "4.0.30319.1")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class TaskContextSwitchRuleNextAction
    {

        private string nameField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string Name
        {
            get
            {
                return this.nameField;
            }
            set
            {
                this.nameField = value;
            }
        }
    }
}

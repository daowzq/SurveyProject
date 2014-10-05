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
using System.Data;

using Aim.WorkFlow.WinService;
using NHibernate.Criterion;
namespace Aim.Examining.Web.WorkFlow
{
    public partial class TaskExecuteView : BasePage
    {
        public string NextStep = "";
        public string FlowInstanceId = "";
        public string FormUrl = "";
        public string FlowDefineId = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (this.RequestActionString.ToLower())
            {
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
                default:
                    Aim.WorkFlow.Task fTask = null;
                    if (this.RequestData["FormId"] != null)
                    {
                        Aim.WorkFlow.WorkflowInstance wf = WorkflowInstance.FindAllByProperties(WorkflowInstance.Prop_RelateId, this.RequestData["FormId"].ToString())[0];
                        fTask = Aim.WorkFlow.Task.FindAllByProperties(Aim.WorkFlow.Task.Prop_WorkflowInstanceID, wf.ID).Where(Ent => Ent.Ext1 != "Branch").ToArray()[0];
                    }
                    else
                    {
                        fTask = Aim.WorkFlow.Task.Find(this.RequestData["TaskId"].ToString());
                    }
                    /*if (fTask.Ext1 == "Branch")
                    {
                        Response.Redirect("FreeTask.aspx?op=r&Type=Branch&TaskId=" + this.RequestData["TaskId"].ToString());
                    }*/
                    /*if (!fTask.UpdatedTime.HasValue)
                    {
                        try
                        {
                            DataTable dt = DataHelper.QueryDataTable("select FactDeptName,FactDeptId from View_SysUserGroupFact where UserId='" + this.UserInfo.UserID + "' and FactDeptName is not null ");
                            if (dt.Rows.Count > 0)
                            {
                                fTask.DeptId = dt.Rows[0]["FactDeptId"].ToString();
                                fTask.DeptName = dt.Rows[0]["FactDeptName"].ToString();
                            }
                        }
                        catch { }
                        fTask.UpdatedTime = DateTime.Now;
                        fTask.Save();
                    }*/
                    Aim.WorkFlow.WorkflowInstance instance = WorkflowInstance.Find(fTask.WorkflowInstanceID);
                    this.PageState.Add("InstanceId", fTask.WorkflowInstanceID);
                    this.PageState.Add("TemplateId", instance.WorkflowTemplateID);
                    FlowInstanceId = instance.ID;
                    FormUrl = instance.RelateUrl;
                    FlowDefineId = instance.WorkflowTemplateID;
                    Title = fTask.WorkFlowName;//+ "->" + fTask.ApprovalNodeName;
                    XmlSerializer xs = new XmlSerializer(typeof(TaskContext));
                    if (!string.IsNullOrEmpty(fTask.Context))
                    {
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
                    Aim.WorkFlow.Task[] tasks = Aim.WorkFlow.Task.FindAll(Expression.Eq("WorkflowInstanceID", fTask.WorkflowInstanceID)).OrderBy(ens => !ens.FinishTime.HasValue ? DateTime.Now : ens.FinishTime).OrderBy(ens => ens.CreatedTime).ToArray();
                    this.PageState.Add("Tasks", JsonHelper.GetJsonString(tasks));
                    this.PageState.Add("Task", fTask);
                    break;
            }

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
            Aim.WorkFlow.WorkflowTemplate tp = Aim.WorkFlow.WorkflowTemplate.Find(temp.WorkflowTemplateID);
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(tp.XAML);
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


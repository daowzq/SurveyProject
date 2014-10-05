using System;
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
using Aim.WorkFlow;
using System.Xml;
using System.Data;
namespace Aim.Examining.Web.WorkFlow
{
    public partial class FlowTrack : BasePage
    {
        public FlowTrack()
        {
            IsCheckLogon = false;
        }
        private Task[] tasks = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsAsyncRequest)
            {
                if (this.Request.QueryString["flowId"] != null)
                {
                    WorkflowInstance wi = WorkflowInstance.Find(this.Request.QueryString["flowId"]);
                    WorkflowTemplate tp = WorkflowTemplate.Find(wi.WorkflowTemplateID);

                    IList<EasyDictionary> dicts = DataHelper.DataTableToDictList(GetNodes(tp.XAML));
                    this.PageState.Add("FlowEnum", dicts);
                    tasks = Task.FindAllByProperties(Task.Prop_WorkflowInstanceID, wi.ID).OrderBy(ens => !ens.FinishTime.HasValue ? DateTime.Now : ens.FinishTime).OrderBy(ens => ens.CreatedTime).ToArray();
                    this.PageState.Add("SysWorkFlowTaskList", tasks);
                }
            }
            if (this.RequestActionString != null && this.RequestActionString == "sendMessage")
            {
                string flowId = this.RequestData.Get<string>("flowId");
                string taskName = this.RequestData.Get<string>("TaskName");
                if (Task.FindAllByProperties(Task.Prop_WorkflowInstanceID, flowId, Task.Prop_ApprovalNodeName, taskName).Length > 0)
                {
                    Task task = Task.FindAllByProperties(Task.Prop_WorkflowInstanceID, flowId, Task.Prop_ApprovalNodeName, taskName)[0];
                    string userId = task.OwnerId;
                    string userName = task.Owner;
                    SysUser user = SysUser.TryFind(userId);
                    if (userId == this.UserInfo.UserID)
                    {
                        PageState.Add("Message", "您是要催办的审批人,无需给自己发送短信催办!");
                    }
                    else if (user != null && (!string.IsNullOrEmpty(user.Phone) || !string.IsNullOrEmpty(user.Email)))
                    {
                        string mailTemplate = SysParameter.FindAllByProperties("Code", "TaskAlertMail")[0].Description;//{[AuditCount]} {[TaskName]}
                        string phoneTemplate = SysParameter.FindAllByProperties("Code", "TaskAlertPhone")[0].Description;//{[AuditCount]} {[LinkUrl]} {[SysEntry]}

                        string tName = task.Title;
                        string linkUrl = task.EFormName;
                        string sysEntry = SysParameter.FindAllByProperties("Code", "SysEntry")[0].Description;
                        string auditCount = DataHelper.QueryValue<int>("select count(*) from Task where status='0' and ownerId='" + userId + "'").ToString();

                        string mailContent = mailTemplate.Replace("{[TaskName]}", tName).Replace("{[AuditCount]}", auditCount);
                        string phoneContent = phoneTemplate.Replace("{[AuditCount]}", auditCount).Replace("{[LinkUrl]}", linkUrl).Replace("{[SysEntry]}", sysEntry);
                        /*if (!string.IsNullOrEmpty(user.Phone))
                            MessageTool.SendMessage(user.Phone, phoneContent);
                        if (!string.IsNullOrEmpty(user.Email))
                            MessageTool.SendMessageMail(user.Email, mailContent);*/
                    }
                    else
                    {
                        PageState.Add("Message", "系统尚未配置相关审批人电话号码及邮箱信息,无法发送短信和邮件!");
                    }
                }
            }
        }
        private DataTable GetNodes(string xml)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("EnumerationID", typeof(string));
            dt.Columns.Add("TaskName", typeof(string));
            dt.Columns.Add("Value", typeof(string));
            dt.Columns.Add("UserName", typeof(string));
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(xml);
            XmlElement root = doc.DocumentElement;
            string nameSpace = root.NamespaceURI;
            XmlNamespaceManager nsmgr = new XmlNamespaceManager(doc.NameTable);
            nsmgr.AddNamespace("ns", nameSpace);
            nsmgr.AddNamespace("x", "http://schemas.microsoft.com/winfx/2006/xaml");
            nsmgr.AddNamespace("bwa", "clr-namespace:BPM.WF.Activities;assembly=BPM.WF");
            XmlNode startNode = root.SelectSingleNode("//ns:Flowchart.StartNode", nsmgr);
            RecalculateRoute(startNode.ChildNodes[0].ChildNodes[1], ref dt, nsmgr);
            return dt;
        }
        private void RecalculateRoute(XmlNode node, ref DataTable dt, XmlNamespaceManager nsmgr)
        {
            string startxml = node.OuterXml;
            string startName = startxml.Substring(startxml.IndexOf("ApprovalNode Name=&quot;") + 24, startxml.IndexOf("&quot; Mode=&quot;") - (startxml.IndexOf("ApprovalNode Name=&quot;") + 24));
            string userName = "";
            try
            {
                userName = startxml.Substring(startxml.IndexOf("&quot; Name=&quot;") + 18, startxml.IndexOf("&quot; Type=&quot;") - (startxml.IndexOf("&quot; Name=&quot;") + 18));
            }
            catch { }
            DataRow row = dt.NewRow();
            row["EnumerationID"] = Guid.NewGuid().ToString();
            row["TaskName"] = startName;
            row["Value"] = startName;
            row["UserName"] = userName;
            dt.Rows.Add(row);
            if (node.NextSibling != null)
                if (node.NextSibling.ChildNodes[0].LocalName == "FlowStep")
                {
                    //节点
                    node = node.NextSibling.ChildNodes[0].ChildNodes[1];
                    RecalculateRoute(node, ref dt, nsmgr);
                }
                else if (node.NextSibling.ChildNodes[0].LocalName == "FlowSwitch")
                {
                    XmlNode switchNode = node.NextSibling.ChildNodes[0];
                    XmlNodeList nodes = switchNode.SelectNodes("ns:FlowStep", nsmgr);
                    node = nodes[0].ChildNodes[1];
                    RecalculateRoute(node, ref dt, nsmgr);
                }
        }
    }
}

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
    public partial class FlowTrack2 : BasePage
    {
        public FlowTrack2()
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
                    tasks = Task.FindAll(Expression.Eq(Task.Prop_WorkflowInstanceID, wi.ID), Expression.Not(Expression.Eq("Status", 2))).OrderBy(ens => !ens.FinishTime.HasValue ? DateTime.Now : ens.FinishTime).OrderBy(ens => ens.CreatedTime).ToArray();
                    this.PageState.Add("SysWorkFlowTaskList", tasks);
                }

                //TemplateCode
            }

            if (!string.IsNullOrEmpty(Request["TemplateCode"] + ""))
            {
                string TemplateCode = Request["TemplateCode"] + "";
                WorkflowTemplate tp = WorkflowTemplate.FindFirstByProperties("Code", TemplateCode);

                IList<EasyDictionary> dicts = DataHelper.DataTableToDictList(GetNodes(tp.XAML));
                this.PageState.Add("FlowEnum", dicts);
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
                        string method = this.RequestData.Get<string>("Method").ToLower();
                        string mailTemplate = SysParameter.FindAllByProperties("Code", "TaskAlertMail")[0].Description;//{[AuditCount]} {[TaskName]}
                        string phoneTemplate = SysParameter.FindAllByProperties("Code", "TaskAlertPhone")[0].Description;//{[AuditCount]} {[LinkUrl]} {[SysEntry]}

                        string tName = task.Title;
                        string linkUrl = task.EFormName;
                        string sysEntry = SysParameter.FindAllByProperties("Code", "SysEntry2")[0].Description;
                        string auditCount = DataHelper.QueryValue<int>("select count(*) from Task where status='0' and ownerId='" + userId + "'").ToString();

                        string mailContent = mailTemplate.Replace("{[TaskName]}", tName).Replace("{[AuditCount]}", auditCount).Replace("{[SysEntry]}", sysEntry + task.ID);
                        string phoneContent = phoneTemplate.Replace("{[AuditCount]}", auditCount).Replace("{[TaskName]}", tName).Replace("{[LinkUrl]}", linkUrl).Replace("{[SysEntry]}", sysEntry);
                        //if (!string.IsNullOrEmpty(user.Phone) && method == "phone")
                        //    MessageTool.SendMessage(user.Phone, phoneContent);
                        //if (!string.IsNullOrEmpty(user.Email) && method == "mail")
                        //    MessageTool.SendMessageMail(mailContent, user.Email);
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
            dt.Columns.Add("Parent", typeof(string));
            dt.Columns.Add("Child", typeof(string));
            dt.Columns.Add("ExecuteState", typeof(string));
            dt.Columns.Add("ExecuteRoute", typeof(string));
            dt.Columns.Add("ExecuteMessages", typeof(string));
            dt.Columns.Add("ViewDate", typeof(string));
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(xml);
            XmlElement root = doc.DocumentElement;
            string nameSpace = root.NamespaceURI;
            XmlNamespaceManager nsmgr = new XmlNamespaceManager(doc.NameTable);
            nsmgr.AddNamespace("ns", nameSpace);
            nsmgr.AddNamespace("x", "http://schemas.microsoft.com/winfx/2006/xaml");
            nsmgr.AddNamespace("bwa", "clr-namespace:BPM.WF.Activities;assembly=BPM.WF");
            XmlNode startNode = root.SelectSingleNode("//ns:Flowchart.StartNode", nsmgr);
            RecalculateRoute(startNode.ChildNodes[0].ChildNodes[1], ref dt, nsmgr, "");
            return dt;
        }
        private void RecalculateRoute(XmlNode node, ref DataTable dt, XmlNamespaceManager nsmgr, string parent)
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
            string executeState = "0";
            string executeRoute = "0";
            string messages = "";
            string viewDate = "";
            DataTable dtState = DataHelper.QueryDataTable("select status,result,finishtime,updatedtime,owner from Task where ApprovalNodeName='" + startName + "' and workflowinstanceId='" + this.Request.QueryString["flowId"] + "' order by finishtime desc ");
            if (dtState != null && dtState.Rows.Count > 0)
            {
                if (dtState.Select(" status ='0'").Length > 0)
                {
                    executeState = "1";
                }
                else
                    executeState = "2";
                executeRoute = dtState.Rows[0]["result"].ToString().Replace("同意 ", "");
                foreach (DataRow rw in dtState.Rows)
                {
                    if (rw["status"].ToString() == "2") continue;
                    string time = rw["finishtime"] == null || rw["finishtime"].Equals(System.DBNull.Value) ? "<font color='red'>未提交</font>" : "提交时间：" + rw["finishtime"] + "<br>";
                    string finishT = rw["finishtime"] == null || rw["finishtime"].Equals(System.DBNull.Value) ? "[未处理]" : rw["finishtime"].ToString();
                    string viewT = rw["updatedtime"] == null || rw["updatedtime"].Equals(System.DBNull.Value) ? "[未签收]" : rw["updatedtime"].ToString();
                    if (finishT != "[未处理]" && viewT == "[未签收]")
                    {
                        viewT = finishT;
                    }
                    string state = "未签收";
                    if (viewT != "[未签收]")
                        state = "已签收审批中";
                    if (finishT != "[未处理]")
                        state = "已处理";
                    messages += rw["owner"].ToString() + " " + state + "</br>";
                    if (viewDate == "")
                    {
                        viewDate = rw["updatedtime"] == null || rw["updatedtime"].Equals(System.DBNull.Value) ? "" : rw["updatedtime"].ToString();
                    }
                }
            }
            row["ExecuteState"] = executeState;
            row["ExecuteRoute"] = executeRoute;
            row["ExecuteMessages"] = messages;
            row["Parent"] = parent;
            row["ViewDate"] = viewDate;
            dt.Rows.Add(row);
            if (node.NextSibling != null)
                if (node.NextSibling.ChildNodes[0].LocalName == "FlowStep")
                {
                    //节点
                    node = node.NextSibling.ChildNodes[0].ChildNodes[1];
                    row["Child"] = node.OuterXml.Substring(node.OuterXml.IndexOf("ApprovalNode Name=&quot;") + 24, node.OuterXml.IndexOf("&quot; Mode=&quot;") - (node.OuterXml.IndexOf("ApprovalNode Name=&quot;") + 24));
                    RecalculateRoute(node, ref dt, nsmgr, startName);
                }
                else if (node.NextSibling.ChildNodes[0].LocalName == "FlowSwitch")
                {
                    if (startName == "信息管理主管审批")
                    {
                        string s = "";
                    }
                    XmlDocument dom = new XmlDocument();
                    dom.LoadXml(node.Attributes["ApprovalNodeConfig"].Value);
                    XmlElement element = dom.DocumentElement;
                    XmlElement elSR = element.SelectSingleNode("//SwitchRules") as XmlElement;
                    XmlNodeList nodelist = elSR.SelectNodes("//NextAction");
                    foreach (XmlNode nd in nodelist)
                    {
                        string nodeName = nd.Attributes["Name"].Value;
                        if (nodeName == "退回上一步") continue;
                        XmlNode nodeChild = null;
                        if (node.NextSibling.SelectSingleNode("ns:FlowSwitch/ns:FlowStep[@x:Key='" + nodeName + "']", nsmgr) != null)
                        {
                            nodeChild = node.NextSibling.SelectSingleNode("ns:FlowSwitch/ns:FlowStep[@x:Key='" + nodeName + "']", nsmgr).ChildNodes[1];
                        }
                        else if (node.NextSibling.SelectSingleNode("ns:FlowSwitch/x:Reference[x:Key/text()='" + nodeName + "']", nsmgr) != null)
                        {
                            string refname = node.NextSibling.SelectSingleNode("ns:FlowSwitch/x:Reference[x:Key/text()='" + nodeName + "']", nsmgr).ChildNodes[0].Value;
                            if (node.NextSibling.SelectSingleNode("ns:FlowSwitch//ns:FlowStep[@x:Name='" + refname + "']", nsmgr) != null)
                            {
                                nodeChild = node.NextSibling.SelectSingleNode("ns:FlowSwitch//ns:FlowStep[@x:Name='" + refname + "']", nsmgr).ChildNodes[1];
                            }
                            else if (node.NextSibling.SelectSingleNode("//ns:FlowStep[@x:Name='" + refname + "']", nsmgr) != null)//结束的特殊处理
                            {
                                var nodeEnd = node.NextSibling.SelectSingleNode("//ns:FlowStep[@x:Name='" + refname + "']", nsmgr).ChildNodes[1];
                                string nName = nodeEnd.OuterXml.Substring(nodeEnd.OuterXml.IndexOf("ApprovalNode Name=&quot;") + 24, nodeEnd.OuterXml.IndexOf("&quot; Mode=&quot;") - (nodeEnd.OuterXml.IndexOf("ApprovalNode Name=&quot;") + 24));
                                if (nName == "结束")
                                {
                                    if (row["Child"] == null || row["Child"].ToString() == "")
                                    {
                                        row["Child"] = "结束,," + nodeName;
                                    }
                                    else
                                    {
                                        row["Child"] = row["Child"].ToString() + ";;结束,," + nodeName;
                                    }
                                }
                                else if (nodeName == "同意" && dt.Select("TaskName='" + nName + "'").Length > 0)//分支汇聚处理
                                {
                                    if (row["Child"] == null || row["Child"].ToString() == "")
                                    {
                                        row["Child"] = nName + ",," + nodeName;
                                    }
                                    else
                                    {
                                        row["Child"] = row["Child"].ToString() + ";;" + nName + ",," + nodeName;
                                    }
                                }
                            }
                        }
                        if (nodeChild != null)
                        {
                            if (row["Child"] == null || row["Child"].ToString() == "")
                            {
                                try
                                {
                                    row["Child"] = nodeChild.OuterXml.Substring(nodeChild.OuterXml.IndexOf("ApprovalNode Name=&quot;") + 24, nodeChild.OuterXml.IndexOf("&quot; Mode=&quot;") - (nodeChild.OuterXml.IndexOf("ApprovalNode Name=&quot;") + 24)) + ",," + nodeName;
                                }
                                catch { continue; }
                            }
                            else
                            {
                                row["Child"] = row["Child"].ToString() + ";;" + nodeChild.OuterXml.Substring(nodeChild.OuterXml.IndexOf("ApprovalNode Name=&quot;") + 24, nodeChild.OuterXml.IndexOf("&quot; Mode=&quot;") - (nodeChild.OuterXml.IndexOf("ApprovalNode Name=&quot;") + 24)) + ",," + nodeName;
                            }
                            RecalculateRoute(nodeChild, ref dt, nsmgr, startName);
                        }
                        /*string content = "ApprovalNode Name=\"" + nodeName + "\"";
                        XmlNode nodeC = node.SelectSingleNode("//*[contains(@ApprovalNodeConfig,'" + content + "')]", nsmgr);
                        if (nodeC != null)
                            if (nodeC.NextSibling.ChildNodes[0].LocalName == "FlowSwitch")
                            {

                            }
                            else
                            {
                                if (row["Child"] == null || row["Child"].ToString() == "")
                                {
                                    try
                                    {
                                        row["Child"] = nodeC.OuterXml.Substring(nodeC.OuterXml.IndexOf("ApprovalNode Name=&quot;") + 24, nodeC.OuterXml.IndexOf("&quot; Mode=&quot;") - (nodeC.OuterXml.IndexOf("ApprovalNode Name=&quot;") + 24));
                                    }
                                    catch { continue; }
                                }
                                else
                                {
                                    row["Child"] = row["Child"].ToString() + ";;" + nodeC.OuterXml.Substring(nodeC.OuterXml.IndexOf("ApprovalNode Name=&quot;") + 24, nodeC.OuterXml.IndexOf("&quot; Mode=&quot;") - (nodeC.OuterXml.IndexOf("ApprovalNode Name=&quot;") + 24));
                                }
                                RecalculateRoute(nodeC, ref dt, nsmgr, startName);
                            }*/
                    }
                    /*XmlNode switchNode = node.NextSibling.ChildNodes[0];
                    XmlNodeList nodes = switchNode.SelectNodes("ns:FlowStep", nsmgr);
                    node = nodes[0].ChildNodes[1];
                    RecalculateRoute(node, ref dt, nsmgr);*/
                }
        }
    }
}

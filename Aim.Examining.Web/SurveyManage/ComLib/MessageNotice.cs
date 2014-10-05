using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


namespace Aim.Examining.Web.SurveyManage
{
    public class MessageNotice
    {
        public static void SendEmail(string SenderAddress, string toAssress, string title, string body, string mailAccount, string mailServer, string serverPwd)
        {
            //string MailSenderAddress = mailSenderAddress;  发信人邮箱地址
            //string MailtoAssress = mailtoAssress; 收件人邮箱地址
            //string Title = title;
            //string Body = body;
            //string MailAccount = mailAccount;  发件人的要显示在邮件的名称
            //string MailPass = mailPass;        pwd
            //string MailServer = mailServer;    smpt.163.com

            WebMailUtinity.SendWebMail(SenderAddress, toAssress, title, body, mailAccount, serverPwd, mailServer);
        }

        public static void NoticeMessage(string PhoneNo, string MessageText)
        {
            if (String.IsNullOrEmpty(MessageText))
                MessageText = @"您好！此短信来自江苏飞力达[企业文化系统]的友情提醒 。";
           // FLWebServices.MessageService.SendMessage(PhoneNo, MessageText);
        }
    }
}

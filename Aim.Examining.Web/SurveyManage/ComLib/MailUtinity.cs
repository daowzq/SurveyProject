using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Net.Mail;

namespace Aim.Examining.Web
{
    public class WebMailUtinity
    {


        public static void SendWebMailOld(string mailSenderAddress, string mailto, string title, string body, string mailAccount, string mailPass, string mailServer)
        {
            //实例化MailMessage对象 
            System.Web.Mail.MailMessage mail = new System.Web.Mail.MailMessage();
            //定义邮件的发送地址 , 可以随便填一个不存在的地址
            mail.From = mailSenderAddress;
            //定义邮件的接收地址 
            //设置以分号分隔的收件人电子邮件地址列表 
            mail.To = mailto;
            //定义邮件的暗送地址 
            //设置以分号分隔的电子邮件地址列表 
            //mail.Bcc="ddd@sina.com"; 
            //定义邮件的抄送地址 
            //设置以分号分隔的电子邮件地址列表 
            //mail.Cc="ddd@x.cn;ddd@eyou.com 
            //定义邮件的主题 
            mail.Subject = title;
            //设置电子邮件正文的内容类型 
            //在这里我们以HTML的格式发送 
            mail.BodyFormat = System.Web.Mail.MailFormat.Html;
            //设置电子邮件的正文 
            mail.Body = body;
            mail.BodyEncoding = System.Text.Encoding.UTF8;
            //SMTP服务器 ，因为用的是本机架设的，所以写127.0.0.1 , 如果连接的是其他服务器的话，像163邮箱，要写smpt.163.com
            System.Web.Mail.SmtpMail.SmtpServer = mailServer;
            //说是许多SMTP服务器都需要身份验证 ，防止垃圾邮件，好像叫做扩展smpt协议什么的。
            //但这里连接的是自己的smpt服务器，简单的smpt，所以也没有什么验证了。
            //至于从本机的SMPT服务器再把邮件发送到163或者其他邮箱 的时候要不要验证就不知道了， 实测时邮件时可以发到
            //@163.com , @eyou.com,@x.cn的，也不用什么验证。
            //验证 
            mail.Fields.Add("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate", "1");
            //登陆名 
            mail.Fields.Add("http://schemas.microsoft.com/cdo/configuration/sendusername", mailAccount);
            //登陆密码 
            mail.Fields.Add("http://schemas.microsoft.com/cdo/configuration/sendpassword", mailPass);
            //发送 
            System.Web.Mail.SmtpMail.Send(mail);
        }
        // MailUtinity.SendWebMail("568909447@qq.com", txtMail.Text, "邮件测试", string.Format(mailMessage, "加班", "test", "当天未上班"), "这个是标题", " ", "smtp.qq.com");
        public static void SendWebMail(string mailSenderAddress, string mailtoAssress, string title, string body, string mailAccount, string mailPass, string mailServer)
        {
            //创建smtpclient对象   
            System.Net.Mail.SmtpClient client = new SmtpClient();
            client.Host = mailServer;//163的smtp服务器是 smtp.163.com   
            string from = mailSenderAddress;
            string pwd = mailPass;

            client.UseDefaultCredentials = false;
            client.Credentials = new System.Net.NetworkCredential(from, pwd);

            client.DeliveryMethod = SmtpDeliveryMethod.Network;
            System.Text.Encoding encoding = System.Text.Encoding.UTF8;
            string senderDisplayName = mailAccount;//这个配置的是发件人的要显示在邮件的名称   
            //string recipientsDisplayName = "昊云";//这个配置的是收件人的要显示在邮件的名称

            MailAddress mailfrom = new MailAddress(mailSenderAddress, senderDisplayName, encoding);//发件人邮箱地址，名称，编码UTF8
            MailAddress mailto = new MailAddress(mailtoAssress);//收件人邮箱地址，名称，编码UTF8   
            //创建mailMessage对象   
            System.Net.Mail.MailMessage message = new MailMessage(mailfrom, mailto);
            message.Subject = title;
            //正文默认格式为html   
            message.Body = body;
            message.IsBodyHtml = true;
            message.BodyEncoding = encoding;
            message.SubjectEncoding = encoding;

            client.Send(message);
        }


        /// <summary>
        /// 发送邮件
        /// </summary>
        /// <param name="email_from_name">发件邮箱名称</param>
        /// <param name="email_uid">发件邮箱地址</param>
        /// <param name="email_pwd">发件邮箱密码</param>
        /// <param name="email_to">接收邮箱地址</param>
        /// <param name="email_cc">抄送邮箱地址</param>
        /// <param name="Bcc">密送邮箱地址</param>
        /// <param name="email_body">邮件正文</param>
        /// <param name="email_title">邮件标题</param>
        /// <param name="Pri">紧急邮件</param>
        /// <param name="host">邮件服务器</param>
        /// <param name="ecoding">邮件编码格式 GB2312,UTF-8 等</param>
        /// <param name="thisid">当前要发送的数据id</param>
        /// <param name="file">附件</param>
        public static void SendEmail(string email_from_name, string email_uid, string email_pwd, string email_to, string email_cc, string email_bcc, string email_body, string email_title, bool Pri, string host, string ecoding, string file)
        {
            string[] emailto = email_to.Split(';');
            MailAddress from = new MailAddress(email_uid, email_from_name);
            MailAddress to = new MailAddress(emailto[0]);      //接收邮箱账号

            MailMessage message = new MailMessage(from, to);
            message.IsBodyHtml = true;
            message.SubjectEncoding = Encoding.GetEncoding(ecoding);
            message.Subject = email_title;            //设置邮件的标题

            foreach (var item in emailto)
            {
                if (item != emailto[0])
                    message.To.Add(item);
            }

            //抄送地址
            if (!string.IsNullOrEmpty(email_cc + ""))
            {

                foreach (var cc in email_cc.Split(';'))
                {
                    message.CC.Add(cc);     //抄送
                }

            }

            //密送
            if (!string.IsNullOrEmpty(email_bcc + ""))
            {
                foreach (var bcc in email_bcc.Split(';'))
                {
                    message.Bcc.Add(bcc);       //密送
                }

            }


            if (!string.IsNullOrEmpty(file + ""))
            {
                string[] fileArr = file.Split(',');
                foreach (var item in fileArr)
                {
                    if (!string.IsNullOrEmpty(item + ""))
                    {
                        string files = "D://RW//Files//AppFiles//Portal//Default//" + item;
                        message.Attachments.Add(new Attachment(files));
                    }
                }
            }



            if (Pri)
                message.Priority = MailPriority.High;
            else
                message.Priority = MailPriority.Normal;

            message.Body = email_body;


            SmtpClient client = new SmtpClient();
            client.DeliveryMethod = SmtpDeliveryMethod.Network;
            client.Port = 25;
            if (host != "" || host.Length != 0)
            {
                client.Host = host;
            }
            else
            {
                client.Host = "smtp.163.com";
            }
            client.Credentials = new System.Net.NetworkCredential(email_uid, email_pwd);
            try
            {
                client.Send(message);
            }
            catch
            {

            }
            finally
            {
                message.Dispose();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public static bool SendMessageMail(string content, string Email)
        {
            // SendWebMailOld();
            return true;
        }

    }
}

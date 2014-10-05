using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;
using System.IO;
using Castle.ActiveRecord;
using Castle.ActiveRecord.Framework.Config;
using System.Configuration;
using Aim.Aop;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using System.Timers;

namespace Aim.Examining.Web
{
    public class Global : System.Web.HttpApplication
    {
        public static string AimPortalDB = string.Empty;
        public static string HR_OA_MiddleDB = string.Empty;
        public static string FL_Recruitment = string.Empty;
        protected void Application_Start(object sender, EventArgs e)
        {
            InitApplication();
        }

        #region 初始化应用

        private void InitApplication()
        {
            // 初始化PortalService
            PortalService.Initialize(new string[] { "Aim.Examining.Model", "Aim.WorkFlow" }, typeof(Aim.Examining.Model.ExamModelBase<>));

            //日志
            log4net.Config.XmlConfigurator.Configure();

            //日志、异常
            LogAttribute.del += WriteLog;
            ExceptionAttribute.del += WriteLog;

            //检验序列号是否有效
            //CheckSystemValid();
        }

        /// <summary>
        /// 写日志
        /// </summary>
        /// <param name="message"></param>
        protected void WriteLog(string message)
        {
            //System.Web.HttpContext.Current.Response.Write(message);
        }

        public void CheckSystemValid()
        {
            SystemInfo info = new SystemInfo();

            if (!info.CheckIsValidSN())
            {
                Response.Write("验证已失效,请联系融为已获得序列号!");
                Response.End();
            }
        }

        #endregion

        protected void Session_Start(object sender, EventArgs e)
        {
            AimPortalDB = ConfigurationManager.AppSettings["AimPortalDB"].ToString();//FL_PortalHR
            HR_OA_MiddleDB = ConfigurationManager.AppSettings["HR_OA_MiddleDB"].ToString();
            FL_Recruitment = ConfigurationManager.AppSettings["FL_Recruitment"].ToString();
        }

        protected void Application_BeginRequest(object sender, EventArgs e)
        {
        }

        protected void Application_AuthenticateRequest(object sender, EventArgs e)
        {

        }

        protected void Application_Error(object sender, EventArgs e)
        {

        }

        protected void Session_End(object sender, EventArgs e)
        {

        }

        protected void Application_End(object sender, EventArgs e)
        {

        }
    }
}
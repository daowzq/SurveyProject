using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Aim.Common;
using Aim.Common.Authentication;
using Aim.Data;
using Aim.Portal.Model;
using Aim.Portal.Web.UI;

namespace Aim.Examining.Web
{
    public class ExamBasePage : BasePage
    {
        #region 私有变量

        public static object uclslocker = new object(); // 添加一个对象作为UserContext的锁

        // EPC应用编码
        public const string EXAMINING_APP_CODE = "EXAMINING";

        public const string ExaminingIDKey = "ExaminingID";
        public const string ExaminingContextKey = "ExaminingContext";

        public ExaminingContext examContext;

        #endregion

        #region 构造函数

        public ExamBasePage()
        {
        }

        #endregion 构造函数

        #region 属性

        /// <summary>
        /// 项目上下文
        /// </summary>
        protected ExaminingContext ExamContext
        {
            get
            {
                return examContext;
            }
        }

        #endregion

        #region ASP.NET 事件

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            if (UserContext != null && !UserContext.ExtData.ContainsKey(ExaminingContextKey))
            {
                if (UserInfo.ExtData.ContainsKey(ExaminingIDKey))
                {
                    string examID = UserInfo.ExtData[ExaminingIDKey];
                    examContext = new ExaminingContext(examID);
                }
                else
                {
                    examContext = new ExaminingContext();
                }

                try
                {
                    lock (uclslocker)
                    {
                        UserContext.ExtData.Add(ExaminingContextKey, examContext);
                    }
                }
                catch(Exception) { }
            }
        }

        protected override void Page_PreRender(object sender, EventArgs e)
        {
            if (ExamContext != null)
            {
            }

            base.Page_PreRender(sender, e);
        }

        #endregion ASP.NET 事件

        #region 方法

        /// <summary>
        /// 重新加载当前项目上下文
        /// </summary>
        protected void ReloadExamining()
        {
            if (examContext != null)
            {

            }
        }

        #endregion

        #region 静态方法

        /// <summary>
        /// 重新加载考核上下文
        /// </summary>
        /// <param name="examID"></param>
        public static void ReloadExamining(string examID)
        {
            // 切换考核上下文
        }

        #endregion
    }

    /// <summary>
    /// 项目上下文
    /// </summary>
    public class ExaminingContext
    {
        #region 成员

        private Hashtable _tag;

        #endregion

        #region 属性

        /// <summary>
        /// 扩展数据
        /// </summary>
        public Hashtable ExtData
        {
            get
            {
                if (_tag == null)
                {
                    _tag = new Hashtable();
                }

                return _tag;
            }
        }

        #endregion

        #region 构造函数

        public ExaminingContext()
        {
        }

        public ExaminingContext(string prjid)
        {

        }

        #endregion
    }
}
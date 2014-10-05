using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Text;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Xml.Linq;

using Aim.Data;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;

using Aim.Common.Service;
using NHibernate;
using Castle.ActiveRecord;
using NHibernate.Criterion;

namespace Aim.Portal.Web.CommonPages
{
    public partial class HomeData : BasePage
    {
        public HomeData()
        {
            this.IsCheckLogon = false;
        }
        public string content = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            string userId = UserInfo != null ? UserInfo.UserID : "";
            string reqAction = this.Request["Param"];
            switch (reqAction)
            {
                //获取各个块内容
                case "GetContent":
                    string blockId = this.Request["BlockId"];
                    Aim.Portal.Model.WebPart part = Aim.Portal.Model.WebPart.Find(blockId);
                    WebPartExt bl = new WebPartExt(part, blockId);
                    part.RepeatItemCount = int.Parse(this.Request["Count"]);
                    content = GetBlockContent(reqAction, part,bl);
                    break;
                case "GetAllBlock":
                    content = WebPartRule.GetAllBlockNames(userId, this.Request["BlockType"], this.Request["TemplateId"], this.Request["IsManage"], ActiveRecordMediator.GetSessionFactoryHolder().CreateSession(typeof(ActiveRecordBase)).Connection.Database);
                    break;
                case "GetOneNew":
                    content = WebPartRule.GetOneBlockHtmls(this.Request["BlockId"],userId);
                    WebPartRule.UpdateAfterAddNewOneBlock(userId, this.Request["BlockId"], this.Request["BlockType"], this.Request["TemplateId"], this.Request["IsManage"]);
                    break;
                case "DeleteBlock":
                    WebPartRule.DeleteBlockFromTemplate(userId, this.Request["BlockId"], this.Request["BlockType"], this.Request["TemplateId"], this.Request["IsManage"]);
                    break;
                case "SaveOrder"://保存页面布局
                    string orders = this.Request["Orders"];
                    WebPartRule.SaveGetBlocks(userId, orders, this.Request["BlockType"], this.Request["TemplateId"], this.Request["IsManage"]);
                    break;
                case "BlockParam":
                    content = WebPartRule.GetUserBlock(userId, this.Request["BlockId"], this.Request["BlockType"], this.Request["TemplateId"], this.Request["IsManage"]);
                    break;
                case "BlockUpdate":
                    string blocktitle = this.Request["blocktitle"];
                    string blockrow = this.Request["blockrow"];
                    string subjectlength = this.Request["subjectlength"];
                    string blocktpl = this.Request["blocktpl"];
                    string blockcolorvalue = Server.HtmlDecode(this.Request["colorvalue"]);
                    string blockid = this.Request["blockid"];
                    WebPartRule.UpdateUserBlock(userId, blockid, blocktitle, blockrow, subjectlength, blocktpl, blockcolorvalue, this.Request["BlockType"], this.Request["TemplateId"], this.Request["IsManage"]);
                    break;
                case "GetOneOld":
                    content = WebPartRule.GetOneBlockHtmls(userId, this.Request["BlockId"], this.Request["BlockType"]);
                    break;
                case "ChangeColumns":
                    string columns = this.Request["Columns"];
                    string layout1 = this.Request["layout1"];
                    string layout2 = this.Request["layout2"];
                    string layout3 = this.Request["layout3"];
                    string layout4 = this.Request["layout4"];
                    string templateString = this.Request["TemplateString"];
                    WebPartRule.ChangeColumns(userId, columns, templateString, this.Request["BlockType"], this.Request["TemplateId"], this.Request["IsManage"], layout1, layout2, layout3, layout4);
                    break;
                case "ChangeWidth":
                    string columns1 = this.Request["Columns"];
                    string layout11 = this.Request["layout1"];
                    string layout21 = this.Request["layout2"];
                    string layout31 = this.Request["layout3"];
                    string layout41 = this.Request["layout4"];
                    WebPartRule.ChangeColumnsWidth(userId, columns1, this.Request["BlockType"], this.Request["TemplateId"], this.Request["IsManage"], layout11, layout21, layout31, layout41);
                    break;
                case "Reset":
                    content = Reset();
                    break;
                default:
                    content = "";
                    break;
                #region 主页功能部分

                /*
                case "SetGlobalColor":
                    Block.SetGlobalColor(this.UserState.UserId, this.Request["Color"], Server.HtmlDecode(this.Request["ColorValue"]), this.Request["BlockType"], this.RequestDs["TemplateId", ""], this.RequestDs["IsManage", ""]);
                    this.SysColor = this.Request["Color"];
                    break;
                case "GetIcons":
                    content = Block.GetIcons();
                    break;
                case "SetIcon":
                    Block.SetIcon(this.UserState.UserId, this.Request["BlockId"], this.Request["BlockType"], this.Request["BlockImg"], this.RequestDs["TemplateId", ""], this.RequestDs["IsManage", ""]);
                    break;
                case "MyRss":
                    content = MyRss();
                    break;
                    */
                #endregion

                case "Menu":
                    string appId = this.Request["AppId"];
                    InitSubMenu(appId);
                    break;
            }

            Response.Write(content);
            Response.End();

        }

        #region 获得应用菜单
        public string Template = "<li><a href='{0}' target=workFrame>{1}</a></li>";
        public void InitSubMenu(string appId)
        {
            content += "<ul>";
            SysModule[] modules = SysModuleRule.FindAll();
            foreach (SysModule module in modules)
            {
                if (string.IsNullOrEmpty(module.ParentID) && module.ApplicationID == appId)
                {
                    if (CheckExsitChild(modules, module.ModuleID))
                    {
                        content += string.Format("<li><a href='{0}' target=workFrame>{1}</a>", module.Url == null ? "" : module.Url.ToString(), module.Name);
                        InitSubs(modules, module);
                        content += "</li>";
                    }
                    else
                    {
                        content += string.Format(Template, module.Url == null ? "" : module.Url.ToString(), module.Name);
                    }
                }
            }
            content += "</ul>";
        }
        public bool CheckExsitChild(SysModule[] modules, string id)
        {
            foreach (SysModule module in modules)
            {
                if (module.ParentID == id) return true;
            }
            return false;
        }
        public void InitSubs(SysModule[] modules, SysModule module)
        {
            content += "<ul>";
            foreach (SysModule moduleC in modules)
            {
                if (moduleC.ParentID == module.ModuleID)
                {
                    if (CheckExsitChild(modules, moduleC.ModuleID))
                    {
                        content += string.Format("<li><a href='{0}' target=workFrame>{1}</a>", moduleC.Url == null ? "" : moduleC.Url.ToString(), moduleC.Name);
                        InitSubs(modules, moduleC);
                        content += "</li>";
                    }
                    else
                    {
                        content += string.Format(Template, moduleC.Url == null ? "" : moduleC.Url.ToString(), moduleC.Name);
                    }
                }
            }
            content += "</ul>";
        }
        #endregion

        private string GetBlockContent(string action,Aim.Portal.Model.WebPart part, WebPartExt bl)
        {
            try
            {
                bl.UserId = UserInfo==null?"":UserInfo.UserID;
                //特殊Block直接输出html
                //比如获取我的头像
                switch (bl.WebPart.BlockKey)
                {
                    case "MyHead":
                        return GetPhotoContent();
                    case "Weather":
                        return GetWeatherContent();
                    case "RssNews":
                        return GetSummaryContent();
                    //case "PictureNews":
                    //	return GetPictureContent(bl);
                    case "Vote":
                        return GetVoteContent();
                    case "ProjectProgressHome":
                        return GetPics();
                    default:
                        {
                            if (bl.WebPart.BlockKey.Length == 36)
                            {
                                //News[] news = News
                                //Goodway.Data.DataList dll = Information.GetQueryCatalogList(OAdbAccess, dbAccess, this.UserState.UserId, true);
                                //DataItem di = dll.GetItem("*[@CatalogId='" + bl.BlockKey + "']");
                                //return GetUserInformNew(di, true, bl);
                            }
                            break;
                        }
                }
                //list型block需要传入数据源datalist的在代理里添加即可
                if (part.RepeatDataDataSql.Trim() == "")
                {
                    bl.GetSourceEvent += new Aim.Portal.Model.WebPartExt.GetSourceListEventHandler(bl_GetSourceEvent);
                }
                if (part.RepeatItemTemplate.ToLower().IndexOf("</iframe>") >= 0)
                {
                    return part.RepeatItemTemplate;
                }
                return bl.GetContentHtml() + bl.GetFootHtml();
            }
            catch (Exception dpe)
            {
                return dpe.Message;
            }

        }
        //这里添加每块需要的数据源DataList,根据datalist自动生成html
        private void bl_GetSourceEvent(ref DataCollection dl, string blockKey)
        {
            /*switch (blockKey)
            {
                case "AuditTask":
                    {
                        dl = this.GetAuditTaskDataList(false);
                        break;
                    }
                case "DesignTask":
                    {
                        dl = this.GetWaitDesignDataList();
                        break;
                    }
                case "DesignAuditTask":
                    {
                        dl = this.GetAuditTaskDataList(true);
                        break;
                    }
                //				case "Message":
                //					dl = DbTool.DataTableToDataList(dbAccess.QueryDataTable("select *  FROM vwMsgForReceiver WHERE (IsFirstView = 'T') AND (UserId = '"+this.UserState.UserId+"') and Type='normal'"));
                //					break;
            }*/
        }

        private string GetPics()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("<div style='width:100%;overflow:hidden;margin-right:5px;padding-right:5px' id=marquee onmouseover=clearInterval(repeat)  onmouseout=repeat=setInterval(scrollMarquee,1)>");
            sb.Append("<table style='margin-right:5px;padding-right:5px;' border='0' cellspacing='0' cellpadding='0'><tr>");
            News[] news = News.FindAllByProperties("TypeId", "8ff907a3-cac1-4174-b9e7-4dad223c6178", "State", "1");
            for (int i = 0; i < news.Length; i++)
            {
                News ne = news[i];
                string[] pics = ne.Pictures.Split(',');
                foreach (string pic in pics)
                {
                    if(pic.Trim()!="")
                        sb.AppendFormat("<td><a href='javascript:void(0)' onclick=OpenPicWin('{1}') ><img border=0 height=110 width=110 src='/CommonPages/File/DownLoad.aspx?Id={1}'  alt='{2}' ></a></td>", ne.Id, pic.Split('_')[0], ne.Title);
                }
            }
            sb.Append("</tr></table></Div>");
            return sb.ToString();
        }

        private string GetVoteContent()
        {
            StringBuilder sb = new StringBuilder();
            /*string szNowTime = DateTime.Now.ToShortDateString();

            string szSQL = "SELECT * FROM Vote WHERE VoteStartTime <= '" + szNowTime + "' AND VoteEndTime >= '" + szNowTime + "'";
            DataTable dt = OAdbAccess.QueryDataTable(szSQL);
            string userId = this.UserState.UserId;
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                bool allowQuery = false;
                string allowQueryId = dt.Rows[i]["AllowQueryId"].ToString();
                if (allowQueryId != null && allowQueryId != "")
                {
                    //string [] ids = allowQueryId.Split(',');
                    //如果登陆人员id在人员id中，则允许查询
                    if (allowQueryId.IndexOf(userId) != -1)
                        allowQuery = true;
                }
                else//如果为空，则表示默认状况下允许所有人查询
                    allowQuery = true;

                if (allowQuery)
                {
                    bool allowStatistic = false;
                    string allowStatisticId = dt.Rows[i]["AllowStatisticId"].ToString();
                    DataRow dr = dt.Rows[i];
                    sb.AppendFormat("<div class=\"linkdiv\"><IMG SRC=\"Blockimages/Icons/sms.gif\" WIDTH=\"15\" HEIGHT=\"10\" BORDER=\"0\" ALT=\"\"><a href=\"#\" onclick=\"OpenVoteQuestionnaire('/officeauto/Vote/VoteQuestionnaire.aspx?Id={0}&FuncType=view');\" title='{1}'>{1}</a>", dr["Id"], dr["Title"]);

                    if (allowStatisticId != null && allowStatisticId != "")
                    {
                        //string[] ids = allowStatisticId.Split('_');
                        if (allowStatisticId.IndexOf(userId) != -1)
                            allowStatistic = true;
                    }
                    else
                        allowStatistic = true;

                    if (allowStatistic)
                        sb.AppendFormat("&nbsp;<IMG src=\"images/VoteStatistic.gif\" width=\"31\" height=\"12\" style=\"cursor:hand\" title='查看投票结果' onclick=\"OpenVoteStatistic('/officeauto/Vote/VoteStatistic.aspx?Id={0}&FuncType=view')\">", dr["Id"]);

                    sb.Append("</div>");
                }
            }
            dt.Dispose();*/
            return sb.ToString();
        }

        //获得天气预报
        private string GetWeatherContent()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("<iframe src='http://weather.265.com/weather.htm' width='160' height='54' frameborder='no' border='0' marginwidth='0'; marginheight='0' scrolling='no'></iframe>");
            return sb.ToString();
        }
        //获得图片新闻
        private string GetPictureContent(Aim.Portal.Model.WebPart bl)
        {
            StringBuilder sb = new StringBuilder();
            //			sb.Append("<object classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000'  codebase='http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0' width='100%' height='220px'>");
            //			sb.Append("<param name='allowScriptAccess' value='sameDomain'><param name='movie' value='BlockImages/bcastr31.swf'><param name='quality' value='high'><param name='bgcolor' value='#ffffff'>");
            //			sb.Append("<param name='wmode' value='transparent'>");
            //			sb.Append("<param name='FlashVars' value='bcastr_file=BlockImages/1.jpg|BlockImages/2.jpg|BlockImages/3.jpg|BlockImages/4.jpg|BlockImages/5.jpg&bcastr_link=图1|图2|图3|图4|图5&bcastr_title=1.htm|1.htm|1.htm|1.htm|1.htm'>");
            //			sb.Append("</object>");

            /*
            string imgUrl1="http://www.soojs.com/folder/经典广告/焦点/01.jpg";
            string imgtext1="图片新闻01";
            string imgLink1="http://www.goodwaysoft.com";
            string imgUrl2="http://www.soojs.com/folder/经典广告/焦点/02.jpg";
            string imgtext2="图片新闻02";
            string imgLink2="http://www.goodwaysoft.com";
            string imgUrl3="http://www.soojs.com/folder/经典广告/焦点/03.jpg";
            string imgtext3="图片新闻03";
            string imgLink3="http://www.goodwaysoft.com";
            string imgUrl4="http://www.soojs.com/folder/经典广告/焦点/04.jpg";
            string imgtext4="图片新闻04";
            string imgLink4="http://www.goodwaysoft.com";
            string imgUrl5="http://www.goodwaysoft.com/folder/经典广告/焦点/05.jpg";
            string imgtext5="图片新闻05";
            string imgLink5="http://www.goodwaysoft.com";

            string pics=imgUrl1+"|"+imgUrl2+"|"+imgUrl3+"|"+imgUrl4+"|"+imgUrl5;
            string links=imgLink1+"|"+imgLink2+"|"+imgLink3+"|"+imgLink4+"|"+imgLink5;
            string texts=imgtext1+"|"+imgtext2+"|"+imgtext3+"|"+imgtext4+"|"+imgtext5;
            */

            int focus_width = 240;
            int focus_height = 200;
            int text_height = 18;
            int swf_height = focus_height + text_height;

            string pics = "";
            string links = "";
            string texts = "";

            /*DbRecord dr = new DbRecord(OAdbAccess, "PublicInformCatalog", bl.BlockKey);
            Goodway.Data.DataList dll = Information.GetQueryCatalogList(OAdbAccess, dbAccess, this.UserState.UserId, true);
            DataItem di = dll.GetItem("*[@CatalogId='" + bl.BlockKey + "']");
            if (di != null)
            {
                string catalogId = di.GetAttr("CatalogId");
                DataForm df = Information.GetInformQueryForm(catalogId);
                df.SetValue("BelongDeptId", dr["BelongDeptId"]);
                df.SetValue("State", "1");
                df.SetValue("ExpireTimeMin", DateTime.Now.ToString());
                df.RemoveAttr("PageIndex");
                //得到所有为上条件的所有信息
                Goodway.Data.DataList dlQuery = Information.GetQueryResultList(OAdbAccess, "PublicInformation(ExpireTime,Pictures,HomePagePopup,PopupIds,Attachments,Class,Title,PostDeptName,PostTime,Id)", df, new DataEnum(), this.UserState.UserId);
                for (int i = 0; i < dlQuery.GetItemCount(); i++)
                {
                    DataItem item = dlQuery.GetItem(i);
                    pics += string.Format("http://{0}:{1}/officeauto/PubInfo/files/image/{2}", HttpContext.Current.Request.Url.Host, HttpContext.Current.Request.Url.Port, item.GetAttr("Pictures")) + "|";
                    links += string.Format("http://{0}:{1}/officeauto/PubInfo/InformView.aspx?Id={2}", HttpContext.Current.Request.Url.Host, HttpContext.Current.Request.Url.Port, item.GetAttr("Id")) + "|";
                    texts += item.GetAttr("Title") + "|";
                    if (i == 4)
                        break;
                }
                pics = pics.TrimEnd('|');
                links = links.TrimEnd('|');
                texts = texts.TrimEnd('|');

                sb.Append("<object classid='clsid:d27cdb6e-ae6d-11cf-96b8-444553540000' codebase='http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0' width='" + focus_width.ToString() + "' height='" + swf_height.ToString() + "'>");
                sb.Append("<param name='allowScriptAccess' value='sameDomain'><param name='movie' value='/Portal/BlockImages/focus1.swf'><param name='quality' value='high'><param name='bgcolor' value='#F0F0F0'>");
                sb.Append("<param name='menu' value='false'><param name=wmode value='opaque'>");
                sb.Append("<param name='FlashVars' value='pics=" + pics + "&links=" + links + "&texts=" + texts + "&borderwidth=" + focus_width.ToString() + "&borderheight=" + focus_height.ToString() + "&textheight=" + text_height.ToString() + "'>");
                sb.Append("</object>");
            }*/
            return sb.ToString();
        }

        //获得头像html
        private string GetPhotoContent()
        {
            string photo = "";
            /*try
            {
                photo = dbAccess.QueryValue("select Photo from OgUser where Id = '" + this.UserState.UserId + "'").ToString();
            }
            catch
            {
                photo = "";
            }*/
            StringBuilder sb = new StringBuilder();
            sb.Append(@"<table width='100%' border='0' cellspacing='0' cellpadding='0' style='height:100%;cursor:hand'>
				<tr>
					<td width='100%' align='center' valign='top' style=' background-repeat:repeat-y;'>
					<table width='164' border='1' cellspacing='0' cellpadding='0'>
					<tr>");

            sb.Append("<td height='174' valign='bottom' align=center>");
            sb.Append(@"<table width='100%' border='0' cellpadding='0' cellspacing='0'  style='-moz-opacity:0.7; filter:alpha(opacity=70);' onMouseOver='this.style.MozOpacity=1;
							this.filters.alpha.opacity=100' onclick='ChangePhoto()' onMouseOut='this.style.MozOpacity=0.7;
							this.filters.alpha.opacity=70'>");
            if (photo == "")
                sb.Append("<tr><td height='174' valign='bottom' background='images/photo.gif'></td></tr>");
            else
                sb.Append(@"<tr>
							<td height='174'width='164'><image width='164' height='174'  id='UserPhoto' src='/sysmodule/FileSystem/Download.aspx?IsExec=true&Key=Goodway_BE-DownLoad&Id=" + photo.Split('_')[0] + @"'></td>
						</tr>");
            sb.Append(@"
						</table></td>
					</tr>
					</table>
					</td></tr>
					</table>");

            return sb.ToString();
        }

        private string GetUserInformNew(DataElement di, bool IsOnlyNotRead, Aim.Portal.Model.WebPart bl)
        {
            if (di != null)
            {
                /*string catalogId = di.GetAttr("CatalogId");
                if (IsOnlyNotRead == false)
                {
                    return GetUserInform(di, bl);
                }

                DataForm df = Information.GetInformQueryForm(catalogId);

                //df.SetValue("BelongDeptId","PRO0001I");
                df.SetValue("State", "1");
                df.SetValue("ExpireTimeMin", DateTime.Now.ToString());

                df.RemoveAttr("PageIndex");

                Goodway.Data.DataList dlQuery = Information.GetQueryResultList(OAdbAccess, "PublicInformation(ExpireTime,Pictures,HomePagePopup,PopupIds,Attachments,Class,Title,PostDeptName,PostTime,Id)", df, new DataEnum(), this.UserState.UserId);
                return GetInformHtml(dlQuery, bl, di);*/
            return "";
            }
            else
            {
                return "没有权限";
            }
        }
        private string GetUserInform(DataElement di, Aim.Portal.Model.WebPart bl)
        {
            /*string catalogId = di.GetAttr("CatalogId");
            DataForm df = Information.GetInformQueryForm(catalogId);

            //df.SetValue("BelongDeptId","PRO0001I");
            df.SetValue("State", "1");
            df.SetValue("ExpireTimeMin", DateTime.Now.ToString());

            df.RemoveAttr("PageIndex");

            //得到所有为上条件的所有信息
            Goodway.Data.DataList dlQuery = Information.GetQueryResultList(OAdbAccess, "PublicInformation(ExpireTime,Pictures,HomePagePopup,PopupIds,Attachments,Class,Title,PostDeptName,PostTime,Id)", df, new DataEnum(), this.UserState.UserId);
            return GetInformHtml(dlQuery, bl, di);*/
            return "";
        }

        private string GetInformHtml(DataCollection dl, Aim.Portal.Model.WebPart bl, DataElement di)
        {
            StringBuilder sb = new StringBuilder();
            /*DateTime nowDate = DateTime.Now;
            for (int i = 0; i < dl.GetItemCount(); i++)
            {
                if (i == int.Parse(bl.RepeatItemCount))
                    break;
                DataItem diP = dl.GetItem(i);
                if (di.GetAttr("Fate") != "" && ((TimeSpan)nowDate.Subtract((DateTime.Parse(diP.GetAttr("PostTime"))))).Days <= Convert.ToInt32(di.GetAttr("Fate")))
                {
                    sb.AppendFormat("<TABLE width='100%' border='0' style='TABLE-LAYOUT: fixed;BORDER-COLLAPSE: collapse'><TR><TD WIDTH='*'><div class=\"linkdiv\" Title=\"{1}\"><IMG SRC=\"image/new.gif\" WIDTH=\"15\" HEIGHT=\"10\" BORDER=\"0\" ALT=\"\"><a onclick=\"OpenNews('/officeauto/PubInfo/InformView.aspx?FuncType=View&Id={0}');\" href='javascript:void(0);'>{1}</a></div></TD><TD WIDTH='80px' align='center'><div class=\"linkdiv\">{2}</div></TD></TR></TABLE>", diP.GetAttr("Id"), diP.GetAttr("Title"), DateTime.Parse(diP.GetAttr("PostTime")).ToString("yyyy-MM-dd"));
                }
                else
                {
                    sb.AppendFormat("<TABLE width='100%' border='0' style='TABLE-LAYOUT: fixed;BORDER-COLLAPSE: collapse'><TR><TD WIDTH='*'><div class=\"linkdiv\" Title=\"{1}\"><IMG SRC=\"Blockimages/Icons/sms.gif\" WIDTH=\"15\" HEIGHT=\"10\" BORDER=\"0\" ALT=\"\"><a onclick=\"OpenNews('/officeauto/PubInfo/InformView.aspx?FuncType=View&Id={0}');\" href='javascript:void(0);'>{1}</a></div></TD><TD WIDTH='80px' align='center'><div class=\"linkdiv\">{2}</div></TD></TR></TABLE>", diP.GetAttr("Id"), diP.GetAttr("Title"), DateTime.Parse(diP.GetAttr("PostTime")).ToString("yyyy-MM-dd"));
                }
            }
            sb.Append("<TABLE width='100%' border='0' style='TABLE-LAYOUT: fixed;BORDER-COLLAPSE: collapse'><TR><TD><div align=\"right\" style=\"padding:2px；font-size:12px;\"><a href=\"javascript:OpenCatalogNews('/officeauto/pubinfo/CatalogQuery.aspx?CatalogName=" + di.GetAttr("CatalogName") + "&CatalogId=" + di.GetAttr("CatalogId") + "')\">更多</a></div></TD></TR></TABLE>");*/
            return sb.ToString();
        }


        //生成新闻汇总的HTML
        private string GetSummaryContent()
        {

            StringBuilder sb = new StringBuilder();
            /*sb.Append(@"<table id='SummaryContent' cellSpacing='0' width='99%' align='center' cellPadding='0' height='115px' border='0'>
						<tr>
							<td width='1'></td>
							<td align='center' width='99%'>");
            sb.Append(@"<marquee id='marscroll' style='height:115px' scrollAmount='1' scrollDelay='20' direction='up' onmouseover='this.stop();'
										onmouseout='this.start();'>");
            try
            {
                string CTitle = "";
                string newsTitle = "";
                string webLink = "";
                ItemCollection newsItem;
                DataTable dtNews = OAdbAccess.QueryDataTable("select Name,WebLink from UserNews where CreatorId='" + this.UserState.UserId + "' and State='1'");
                if (dtNews.Rows.Count > 0)
                {

                    for (int i = 0; i < dtNews.Rows.Count; i++)
                    {
                        CTitle = dtNews.Rows[i]["Name"].ToString();
                        sb.AppendFormat(CTitle + "<br>");
                        webLink = dtNews.Rows[i]["WebLink"].ToString();
                        newsItem = GetBewsList(webLink);
                        if (newsItem != null && newsItem.Count > 0)
                            foreach (Item item in newsItem)
                            {
                                newsTitle = item.title;
                                if (newsTitle.Length > 15)
                                {
                                    newsTitle = newsTitle.Substring(0, 15) + "...";
                                    sb.AppendFormat("&nbsp;&nbsp;<img src='images/dot1.gif' width='6' height='9'>&nbsp;<a href='" + item.link + "' target='_blank' title='" + item.title + "' class=\"STYLE1\"  >" + newsTitle + "</a><br>");
                                    sb.AppendFormat("<img src='image/BottomDot.JPG' width='95%' height='5'><br>");
                                }
                            }
                    }
                }
                else
                {
                    sb.AppendFormat("您尚未设置首页新闻！<br>");
                }
            }
            catch
            {
                sb.AppendFormat("新闻获取有误请耐心等待，新闻会自动刷新！<br>");
            }
            sb.Append(@"</marquee></td>
			<td width='1'></td>
						</tr>
					<tr>
						<td width='1'></td>
						<td align=right><a href='/portal/Rss/Index.aspx' target='_blank' class='font_12_black'>订阅</a></td>
						<td width='1'></td>
					</tr>
					</table>");*/
            return sb.ToString();

        }
        /*private ItemCollection GetBewsList(string url)
        {
            try
            {
                Feed feed = new Feed(url, DateTime.Now);
                feed.Read();
                Channel channel = new Channel();
                channel = feed.Channel;
                //Html +=string.Format(HeadTemplate,channel.title,channel.Image.Link,channel.Image.ImageUrl,channel.Image.Link);
                ItemCollection ic = channel.Items;
                return ic;
            }
            catch (Exception ex)
            {
                //Html = "<font color=red>该新闻地址无效,无法获取rss订阅内容!</font>";
                return null;
            }
        }
        public Goodway.Data.DataList GetWaitDesignDataList()
        {
            try
            {
                string whereStr = "  Type IN ('DesignTask','CollaborationTask') and DutyIds LIKE '%" + this.UserState.UserId + "%' AND State <> 'Complete'  ";
                Goodway.Data.DataList rtndl = null;
                DataTable dtbl = projectdbAccess.QueryDataTable("select Id,PrjId,FullId,PrjName,Name,DesignerCompleteRate,CONVERT(VARCHAR(10), PlanStartDate, 120) AS PlanStartDate, CONVERT(VARCHAR(10), PlanEndDate, 120) AS PlanEndDate,CreateDate from V_DesignProject where " + whereStr + " order by Id Desc", 0, 20);
                rtndl = DbTool.DataTableToDataList(dtbl);//PortalCachManager.GetWaitDesignList(this.userId);
                rtndl.SetAttr("Type", "Design");
                rtndl.SetName("TaskList");
                return rtndl;
            }
            catch (Exception ex)
            {
                return null;
            }
        }
        public Goodway.Data.DataList GetAuditTaskDataList(bool isProject)
        {
            try
            {
                string whereStr = "";
                if (isProject)
                    whereStr += "(OwnerUserId='" + this.UserState.UserId + "') AND (State='New') and (System='Project' or System='ProjectAuditFlow')";
                else
                    whereStr += "(OwnerUserId='" + this.UserState.UserId + "') AND (State='New') and System<>'Project' and System<>'ProjectAuditFlow'";
                Goodway.Data.DataList rtndl = null;
                DataTable dtbl = dbAccess.QueryDataTable("select Id,FlowId,TaskName,FlowName,RelateName,RelateType,ExecUrl,CreateTime,System,Type from WfWorkList  where " + whereStr + "  order by Id desc", 0, 20);
                rtndl = DbTool.DataTableToDataList(dtbl);//PortalCachManager.GetWaitDesignList(this.userId);
                rtndl.SetAttr("Type", "Design");
                rtndl.SetName("TaskList");
                return rtndl;
            }
            catch
            {
                return null;
            }
        }

        private string MyRss()
        {
            string szResult = "/portal/BlockImages/Icons/icon_favourites.gif";
            string blockId = HttpContext.Current.Request["BlockId"];
            string blockType = HttpContext.Current.Request["BlockType"];
            Block b = new Block(this.dbAccess, blockId);
            Match m = Regex.Match(b.FootHtml, "(?<=CatalogId=)\\w+[^('|&)]");
            string szSQL = "SELECT Id FROM MyRss WHERE UserId = '" + this.UserState.UserId + "' AND PICId = '" + m.Value + "'";
            if (this.OAdbAccess.CheckIsExist(szSQL))
            {
                szSQL = "DELETE MyRss WHERE UserId = '" + this.UserState.UserId + "' AND PICId = '" + m.Value + "'";
                szResult = "T";
            }
            else
            {
                szSQL = "INSERT INTO MyRss (UserId,UserName,PICId) VALUES ('" + this.UserState.UserId + "','" + this.UserState.UserName + "','" + m.Value + "')";
                szResult = "F";
            }
            this.OAdbAccess.ExecSql(szSQL);
            return szResult;
        }*/

        private string Reset()
        {
            string szColor = "";
            /*string szSQL = "SELECT Id FROM DoorTemplate WHERE UserId = '" + this.UserState.UserId + "' AND IsDefault = 'T' AND BlockType = '" + HttpContext.Current.Request["BlockType"] + "' AND BaseTemplateId = '" + HttpContext.Current.Request["TemplateId"] + "'";
            if (dbAccess.CheckIsExist(szSQL))
            {
                DbRecord drBase = new DbRecord(dbAccess, "DoorBaseTemplate", HttpContext.Current.Request["TemplateId"]);
                DbRecord dr = new DbRecord(dbAccess, "DoorTemplate", "UserId", this.UserState.UserId, "IsDefault", "T", "BlockType", HttpContext.Current.Request["BlockType"], "BaseTemplateId", HttpContext.Current.Request["TemplateId"]);
                string szId = dr["Id"];
                DataForm df = drBase.ToDataForm();
                df.SetValue("Id", szId);
                dr.SetData(df);
                dr["Type"] = "User";
                dr["UserId"] = this.UserState.UserId;
                dr["UserName"] = this.UserState.UserName;
                dr.Update();
                szColor = dr["GlobalColor"];
            }*/
            return szColor;
        }
    }
}
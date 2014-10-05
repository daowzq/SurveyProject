using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using Aim.Portal.Model;

namespace IntegratedManage.Web.CommonPages.File
{
    public partial class DownLoadSign : System.Web.UI.Page
    {
        string userId = "";
        string userName = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            userId = Request.QueryString["UserId"];
            InitImage();
        } 
        private void InitImage()
        {
            Bitmap bmp = null;
            string strExtName = "";
            if (false)//GetURL().Length > 0&&file!=null)
            {
                bmp = new Bitmap(GetURL(), true);
            }
            else
            {
                //string s = AppDomain.CurrentDomain.BaseDirectory.Replace("/","\\") +"image\\noneImage.gif";
                //bmp = new Bitmap(s,true);
                //根据用户名生成签名
                GetFileIdByUserId(userId);
                bmp = CreateImage();
                strExtName = "gif";

            }
            HttpContext current = HttpContext.Current;
            current.Response.ContentType = "image/gif";
            switch (strExtName)
            {
                case "jpg":
                case "gif":
                    bmp.Save(current.Response.OutputStream, System.Drawing.Imaging.ImageFormat.Gif);
                    break;
                case "png":
                    bmp.Save(current.Response.OutputStream, System.Drawing.Imaging.ImageFormat.Png);
                    break;
                case "bmp":
                    bmp.Save(current.Response.OutputStream, System.Drawing.Imaging.ImageFormat.Bmp);
                    break;
                default:
                    bmp.Save(current.Response.OutputStream, System.Drawing.Imaging.ImageFormat.Gif);
                    break;
            }

            current.Response.Flush();
            bmp.Dispose();

        }
        private string GetURL()
        {
            string fileId = GetFileIdByUserId(userId);
            string filePath = HttpContext.Current.Server.MapPath(@"/share/image/noneImage.gif");
            if (fileId != "")
            {
                //filePath = file.FullName.ToLower();
            }

            return filePath;
        }

        private string GetFileIdByUserId(string userId)
        {
            if (!string.IsNullOrEmpty(userId))
            {
                userName = SysUser.Find(userId).Name;
            }
            string fileId = "";
            return fileId;
        }
        //没有上传签名,根据用户名生成签名(为了测试需要)jnp add
        public Bitmap CreateImage()
        {
            Bitmap bitmap;
            try
            {
                Graphics g;
                bitmap = new Bitmap(80, 35, PixelFormat.Format64bppArgb);
                g = Graphics.FromImage(bitmap);
                g.Clear(Color.Silver);
                float fontSize = 25;
                Font f = new Font("华文行楷", fontSize, FontStyle.Regular);
                SizeF size = g.MeasureString(userName, f);

                // 调整文字大小直到能适应背景尺寸
                while (size.Width > bitmap.Width)
                {
                    fontSize--;
                    f = new Font("华文行楷", fontSize, FontStyle.Regular);
                    size = g.MeasureString(userName, f);
                }

                Brush b = new SolidBrush(Color.Black);
                StringFormat StrFormat = new StringFormat();
                StrFormat.Alignment = StringAlignment.Near;
                g.DrawString(userName, f, b, new PointF(0, 0), StrFormat);

            }
            catch
            {
                string s = AppDomain.CurrentDomain.BaseDirectory.Replace("/", "\\") + "image\\noneImage.gif";
                bitmap = new Bitmap(s, true);
            }
            return bitmap;
        } 
    }
}

using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aim.Data;
using Aim.Portal;
using Aim.Portal.Model;
using Aim.Portal.Web;
using Aim.Portal.Web.UI;
using Aim.Examining.Model;
using Aim.WorkFlow;
using System.Data;
using System.Text;

namespace Aim.Examining.Web.EmpWelfare
{
    public partial class test : ExamBasePage
    {
        public test()
        {
            this.IsCheckLogon = false;
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            split(623);
            Response.Write(lt.Count);
        }


        public List<int> lt = new List<int>();

        // 拆分的方法
        private void split(int val)
        {
            //623=500+100+20+3
            //val = 623;
            //if (val == 500 || val == 300 || val == 200 || val == 100 || val == 50 || val == 20 || val == 10 || val == 5 || val == 3 || val == 1)
            //{
            //    lt.Add(val);
            //    return val;
            //}

            if (val > 500)
            {
                // 623/500=1+123
                int k = (int)val / 500;
                for (int i = 0; i < k; i++)
                {
                    lt.Add(500);
                }
                split(val % 500);
            }
            else if (val < 500 && val > 300)
            {
                int k = (int)val / 300;
                for (int i = 0; i < k; i++)
                {
                    lt.Add(300);
                }
                split(val % 300);
            }
            else if (val < 300 && val > 200)
            {
                int k = (int)val / 200;
                for (int i = 0; i < k; i++)
                {
                    lt.Add(200);
                }
                split(val % 200);
            }
            else if (val < 200 && val > 100)
            {
                // 123/100=1+23 
                int k = (int)val / 100;
                for (int i = 0; i < k; i++)
                {
                    lt.Add(100);
                }
                split(val % 100);
            }
            else if (val < 100 && val > 50)
            {
                int k = (int)val / 50;
                for (int i = 0; i < k; i++)
                {
                    lt.Add(50);
                }
                split(val % 50);
            }
            else if (20 < val && val < 50)
            {
                // 23/20=1+3
                int k = (int)val / 20;
                for (int i = 0; i < k; i++)
                {
                    lt.Add(20);
                }
                split(val % 20);
            }
            else if (val > 10 && val < 20)
            {
                int k = (int)val / 10;
                for (int i = 0; i < k; i++)
                {
                    lt.Add(10);
                }
                split(val % 10);
            }
            else if (val > 5 && val < 10)
            {
                int k = (int)val / 5;
                for (int i = 0; i < k; i++)
                {
                    lt.Add(5);
                }
                split(val % 5);
            }
            else if (val > 3 && val < 5)
            {
                int k = (int)val / 3;
                for (int i = 0; i < k; i++)
                {
                    lt.Add(3);
                }
                split(val % 3);
            }
            else if (1 < val && val < 3)
            {
                int k = (int)val / 1;
                for (int i = 0; i < k; i++)
                {
                    lt.Add(1);
                }
                split(val % 1);
            }
            else
            {
                lt.Add(val);
                return;
            }
        }
    }
}

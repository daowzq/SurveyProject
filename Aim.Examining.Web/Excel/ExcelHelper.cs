using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Aim.Examining.Web
{
    public static class ExcelHelper
    {

        public static void deletefile(System.IO.DirectoryInfo path)
        {
            foreach (System.IO.DirectoryInfo d in path.GetDirectories())
            {
                deletefile(d);
            }
            foreach (System.IO.FileInfo f in path.GetFiles())
            {
                f.Delete();
            }
        }
    }
}
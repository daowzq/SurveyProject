using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Aim.Examining.Web.CommonPages.Select
{
    //定义树的结构1
    internal class TreeNode
    {
        public string cls { get; set; }
        public string id { get; set; }
        public bool leaf { get; set; }
        public string text { get; set; }
        public bool expanded { get; set; }
        //public bool check { get; set; }
        public List<TreeNode> children { get; set; }
    }

    //定义树的结构2
    internal class ExtTree
    {
        public string cls { get; set; }
        public string id { get; set; }
        public bool leaf { get; set; }
        public string text { get; set; }
        public bool expanded { get; set; }
        public bool check { get; set; }
        public List<ExtTree> children { get; set; }
    }

}

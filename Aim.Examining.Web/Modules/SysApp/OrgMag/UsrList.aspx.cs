using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

using NHibernate;
using NHibernate.Criterion;
using Castle.ActiveRecord;
using Aim.Data;
using Aim.Portal.Web.UI;
using Aim.Portal.Model;
using Aim.Component;
using Aim.Component.ThirdpartySupport.MsOffice;
using Aim.Utilities;


namespace Aim.Portal.Web.Modules.SysApp.OrgMag
{
    public partial class UsrList : BaseListPage
    {
        #region 属性

        #endregion

        #region 变量

        string op = String.Empty;
        string id = String.Empty;   // 对象id
        string type = String.Empty; // 查询类型
        string workNumbers = "";

        private SysUser[] users = null;

        #endregion

        #region 构造函数

        #endregion

        #region ASP.NET 事件

        protected void Page_Load(object sender, EventArgs e)
        {
            if (this.Request.Files.Count > 0)
            {
                string guid = Guid.NewGuid().ToString();
                string filePath = "//WorkTime//InputExcelFiles//" + Guid.NewGuid().ToString() + System.IO.Path.GetExtension(Request.Files[0].FileName);
                this.Request.Files[0].SaveAs(Server.MapPath(filePath));
                ExcelProcessor ep = ExcelService.GetProcessor(Server.MapPath(filePath));
                DataSet ds = ep.GetDataSet();
                string exMessage = "";
                workNumbers = "";
                try
                {
                    InputDatasV2(ds.Tables[0]);
                }
                catch (Exception ex)
                {
                    exMessage = ex.Message;
                }
                if (workNumbers != "")
                {
                    Response.Write("{success:false,message:'" + workNumbers + "'}");
                    Response.End();
                }
                else
                {
                    Response.Write("{success:true}");
                    Response.End();
                }
            }

            id = RequestData.Get<string>("id", String.Empty);
            type = RequestData.Get<string>("type", String.Empty);
            
            SysUser usr = null;
            switch (this.RequestAction)
            {
                case RequestActionEnum.Create:
                    usr = this.GetPostedData<SysUser>();
                    usr.DoCreate();
                    this.SetMessage("新建成功！");
                    break;
                case RequestActionEnum.Update:
                    usr = this.GetMergedData<SysUser>();
                    usr.DoUpdate();
                    this.SetMessage("保存成功！");
                    break;
                case RequestActionEnum.Delete:
                    usr = this.GetTargetData<SysUser>();
                    usr.DoDelete();
                    this.SetMessage("删除成功！");
                    break;
                default:
                    if (RequestActionString == "clearpass")
                    {
                        usr = SysUser.Find(this.RequestData.Get<string>("UserId"));
                        usr.Password = "";
                        usr.Save();
                    }
                    else
                    {
                        SearchCriterion.AutoOrder = false;
                        SearchCriterion.SetOrder(SysUser.Prop_WorkNo);
                        string dName = SearchCriterion.GetSearchValue<string>("Name");
                        if (dName != null && dName.Trim() != "")
                        {
                            string where = "select * from SysUser where " + GetPinyinWhereString("Name", dName);
                            this.PageState.Add("UsrList", DataHelper.QueryDictList(where));
                        }
                        else
                        {
                            users = SysUserRule.FindAll(SearchCriterion);

                            this.PageState.Add("UsrList", users);
                        }
                    }
                    break;
            }
        }

        #endregion

        #region 私有方法


        public string GetPinyinWhereString(string fieldName, string pinyinIndex)
        {
            string[,] hz = Aim.Utilities.Tool.GetHanziScope(pinyinIndex);
            string whereString = "(";
            for (int i = 0; i < hz.GetLength(0); i++)
            {
                whereString += "(SUBSTRING(" + fieldName + ", " + (i + 1) + ", 1) >= '" + hz[i, 0] + "' AND SUBSTRING(" + fieldName + ", " + (i + 1) + ", 1) <= '" + hz[i, 1] + "') AND ";
            }
            if (whereString.Substring(whereString.Length - 4, 4) == "AND ")
                return whereString.Substring(0, whereString.Length - 4) + ")";
            else
                return "(1=1)";
        }

        private void InputDatas(DataTable dt)
        {
            foreach (DataRow row in dt.Rows)
            {
                if (row[2] != null && row[2].ToString().Trim() != "")
                {
                    try
                    {
                        if (SysUser.FindAllByProperties("WorkNo", row[1].ToString()).Length == 0)
                        {
                            SysUser sysUser = new SysUser();
                            sysUser.WorkNo = row[1].ToString();
                            sysUser.Name = row[2].ToString();
                            sysUser.LoginName = row[3].ToString();
                            sysUser.Email = row[5].ToString();
                            sysUser.Remark = row[6].ToString();
                            sysUser.Status = 1;
                            sysUser.Save();
                            if (SysGroup.FindAllByProperties("Name", row[4].ToString()).Length > 0)
                            {
                                using (new SessionScope())
                                {
                                    SysGroup grp = SysGroup.FindAllByProperties("Name", row[4].ToString())[0];

                                    IList<string> userIDs = new List<string>();
                                    userIDs.Add(sysUser.UserID);
                                    grp.AddUsers(userIDs);
                                }
                            }
                        }

                    }
                    catch (Exception)
                    {
                        continue;
                    }
                }
            }
        }

        private void InputDatasV2(DataTable dt)
        {
            //DataHelper.ExecSql("delete from SysUser where LoginName<>'admin'");
            foreach (DataRow row in dt.Rows)
            {
                if (row[2] != null && row[2].ToString().Trim() != "")
                {
                    string workNo = row[1].ToString().Trim(); ;
                    try
                    {
                        if (!SysGroup.Exists(Expression.Eq(SysGroup.Prop_Name, row[4].ToString()))) continue;
                        using (new SessionScope())
                        {
                            if (row[4].ToString().Trim() == "昆山飞力仓储服务有限公司")
                            {
                                string dept = row[4].ToString();
                            }
                            SysGroup group = SysGroup.FindAllByProperties("Name", row[4].ToString())[0];
                            SysGroup Fact = null;
                            if (row[6].ToString().Trim() != "")
                            {
                                if (group.ChildGroups.Count(tt => tt.Name == row[6].ToString()) == 0)
                                {
                                    SysGroup group1 = new SysGroup();
                                    group1.Name = row[6].ToString();
                                    group1.Code = row[7].ToString();
                                    group1.SortIndex = int.Parse(row[7].ToString());
                                    group1.Type = 2;
                                    group1.Status = 1;
                                    group1.CreateAsChild(group);
                                    Fact = group1;
                                    if (row[6].ToString().Trim() != row[8].ToString().Trim())
                                    {
                                        SysGroup group2 = new SysGroup();
                                        group2.Name = row[8].ToString();
                                        group2.Code = row[9].ToString();
                                        group2.SortIndex = int.Parse(row[9].ToString());
                                        group2.Type = 2;
                                        group2.Status = 1;
                                        group2.Save();
                                        group2.CreateAsChild(group1);
                                        Fact = group2;
                                    }
                                }
                                else
                                {
                                    Fact = group.ChildGroups.FirstOrDefault(ent => ent.Name == row[6].ToString());
                                    if (row[6].ToString().Trim() != row[8].ToString().Trim())
                                    {
                                        if (Fact.ChildGroups.Count(tt => tt.Name == row[8].ToString()) == 0)
                                        {
                                            SysGroup group2 = new SysGroup();
                                            group2.Name = row[8].ToString();
                                            group2.Code = row[9].ToString();
                                            group2.SortIndex = int.Parse(row[9].ToString());
                                            group2.Type = 2;
                                            group2.Status = 1;
                                            group2.Save();
                                            group2.CreateAsChild(Fact);
                                            Fact = group2;
                                        }
                                        else
                                        {
                                            Fact = Fact.ChildGroups.FirstOrDefault(ent => ent.Name == row[8].ToString());
                                        }
                                    }
                                }
                            }
                            else
                            {
                                Fact = group;
                            }
                            SysUser sysUser = new SysUser();
                            sysUser.WorkNo = row[1].ToString().Trim();
                            sysUser.Name = row[2].ToString().Trim();
                            if (row[3].ToString().Trim() == "")
                            {
                                sysUser.LoginName = GetPingyin(row[2].ToString().Trim());
                            }
                            else
                            {
                                sysUser.LoginName = row[3].ToString();
                            }
                            sysUser.Status = 1;
                            sysUser.CreateDate = DateTime.Now;
                            sysUser.Save();
                            IList<string> userIDs = new List<string>();
                            userIDs.Add(sysUser.UserID);
                            Fact.AddUsers(userIDs);
                        }
                    }
                    catch (Exception)
                    {
                        workNumbers += workNo + ";";
                        continue;
                        //throw e;
                    }
                    /*if (SysUser.FindAllByProperties("WorkNo", row[1].ToString().Trim()).Length == 0)
                    {
                        SysUser sysUser = new SysUser();
                        sysUser.WorkNo = row[1].ToString().Trim();
                        sysUser.Name = row[2].ToString().Trim();
                        if (row[3].ToString().Trim() == "")
                        {
                            sysUser.LoginName = GetPingyin(row[2].ToString().Trim());
                        }
                        else
                        {
                            sysUser.LoginName = row[3].ToString();
                        }
                        sysUser.Email = row[5].ToString();
                        sysUser.Remark = row[6].ToString();
                        sysUser.Status = 1;
                        sysUser.CreateDate = DateTime.Now;
                        sysUser.Save();
                        if (SysGroup.FindAllByProperties("Name", row[4].ToString().Trim()).Length > 0)
                        {
                            using (new SessionScope())
                            {
                                SysGroup grp = SysGroup.FindAllByProperties("Name", row[4].ToString().Trim())[0];

                                IList<string> userIDs = new List<string>();
                                userIDs.Add(sysUser.UserID);
                                grp.AddUsers(userIDs);
                            }
                        }
                        else
                        {
 
                        }
                    }
                    else
                    {
                        if (SysGroup.FindAllByProperties("Name", row[4].ToString().Trim()).Length > 0)
                        {
                            SysUser sysUser = SysUser.FindAllByProperties("WorkNo", row[1].ToString().Trim())[0];
                            using (new SessionScope())
                            {
                                if (sysUser.RetrieveAllGroup().Where(en => en.Type == 2 && en.Name != row[4].ToString()).Count() == 0)
                                {
                                    if (sysUser.RetrieveAllGroup().Where(en => en.Type == 2).Count() > 0)
                                    {
                                        foreach (SysGroup gp in sysUser.RetrieveAllGroup().Where(en => en.Type == 2))
                                            gp.User.Remove(sysUser);
                                    }
                                    SysGroup grp = SysGroup.FindAllByProperties("Name", row[4].ToString().Trim())[0];
                                    IList<string> userIDs = new List<string>();
                                    userIDs.Add(sysUser.UserID);
                                    grp.AddUsers(userIDs);
                                }
                            }
                        }
                    }*/
                }
            }
        }

        public string GetPingyin(string name)
        {
            return Tool.ConvertToFullHanzi(name);
        }
        #endregion
    }
}

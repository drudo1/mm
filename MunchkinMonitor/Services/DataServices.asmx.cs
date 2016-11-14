using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using MunchkinMonitor.Classes;
using System.Web.Script.Services;

namespace MunchkinMonitor.Services
{
    /// <summary>
    /// Summary description for DataServices
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    public class DataServices : System.Web.Services.WebService
    {

        [WebMethod]
        public string GetCurrentAppState()
        {
            AppState state = AppState.CurrentState();
            return state.gameState.ToString();
        }

        [WebMethod]
        public void RotateState()
        {
            AppState state = AppState.CurrentState();
            int cur = (int)state.gameState;
            cur++;
            cur = cur % Convert.ToInt32(Enum.GetValues(typeof(AppStates)).Cast<AppStates>().Max());
            state.SetState((AppStates)cur);
        }
    }
}

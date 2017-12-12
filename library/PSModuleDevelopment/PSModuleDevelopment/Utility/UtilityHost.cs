using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Host;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Utility
{
    /// <summary>
    /// Host class, containing statics in support of the utility namespace
    /// </summary>
    public static class UtilityHost
    {
        /// <summary>
        /// Gives access to the host UI, in order to access window information
        /// </summary>
        public static PSHostRawUserInterface RawUI;
    }
}

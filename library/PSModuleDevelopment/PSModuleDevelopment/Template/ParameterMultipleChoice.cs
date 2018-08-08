using System;
using System.Collections.Generic;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// Parameter representing a multiple-choice option
    /// </summary>
    [Serializable]
    public class ParameterMultipleChoice : ParameterBase
    {
        /// <summary>
        /// The options available to the user
        /// </summary>
        public List<string> Options = new List<string>();

        /// <summary>
        /// Descriptions for the choices offered to the user
        /// </summary>
        public Dictionary<string, string> Descriptions = new Dictionary<string, string>(StringComparer.InvariantCultureIgnoreCase);
    }
}

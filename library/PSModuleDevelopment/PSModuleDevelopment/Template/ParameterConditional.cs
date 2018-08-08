using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// A set of values that depend on a given condition.
    /// </summary>
    [Serializable]
    public class ParameterConditional : ParameterBase
    {
        /// <summary>
        /// If no condition matches, this value is picked.
        /// </summary>
        public string DefaultValue;

        /// <summary>
        /// The first condition to match will be applied
        /// </summary>
        public List<ConditionalValue> Values = new List<ConditionalValue>();
    }
}

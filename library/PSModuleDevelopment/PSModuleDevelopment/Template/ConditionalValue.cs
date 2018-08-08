using PSModuleDevelopment.Condition;
using System;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// A value tied to a set of conditions, ALL of which must be true in order for the valuer ot apply
    /// </summary>
    [Serializable]
    public class ConditionalValue
    {
        /// <summary>
        /// The value to apply if conditions are met
        /// </summary>
        public string Value;

        /// <summary>
        /// 
        /// </summary>
        public Condition.Condition Condition;
    }
}

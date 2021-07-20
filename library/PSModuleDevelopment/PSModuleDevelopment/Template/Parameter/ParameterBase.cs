using System;

namespace PSModuleDevelopment.Template.Parameter
{
    /// <summary>
    /// Base class for all kinds of parameters gen 2+
    /// </summary>
    [Serializable]
    public abstract class ParameterBase
    {
        /// <summary>
        /// Name of the parameter
        /// </summary>
        public string Name;

        /// <summary>
        /// Description of the parameter
        /// </summary>
        public string Description;

        /// <summary>
        /// Get the value associated with this parameter
        /// </summary>
        /// <returns>The value to insert into the artifact generated from the template</returns>
        public abstract string GetValue();
    }
}

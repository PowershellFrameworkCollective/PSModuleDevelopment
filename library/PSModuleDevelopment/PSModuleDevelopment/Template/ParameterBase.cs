using System;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// Base class for all parameters
    /// </summary>
    [Serializable]
    public abstract class ParameterBase
    {
        /// <summary>
        /// Name of the parameter
        /// </summary>
        public string Name;

        /// <summary>
        /// A description for the parameter.
        /// In case of parameter types interacting with the user, this may also be used to explain the parameter to the user.
        /// </summary>
        public string Description;

        /// <summary>
        /// The value that was assigned to the parameter. Filled by logic executed or values chosen.
        /// </summary>
        public string Value;

        /// <summary>
        /// The type of parameter this is
        /// </summary>
        public ParameterType Type;

        /// <summary>
        /// A unique ID for a given parameter. Names should be unique, but this allows for future need.
        /// </summary>
        public Guid Id;
    }
}

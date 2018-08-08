using System;
using System.Management.Automation;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// A script used to calculate content to be inserted
    /// </summary>
    [Serializable]
    public class ParameterScript : ParameterBase
    {
        /// <summary>
        /// The scriptblock to invoke
        /// </summary>
        public ScriptBlock ScriptBlock;

        /// <summary>
        /// Direct string representation of the scriptblock.
        /// </summary>
        public string StringScript
        {
            get { return ScriptBlock.ToString(); }
            set { }
        }

        /// <summary>
        /// Creates an empty parameter script. Usually used in serialization.
        /// </summary>
        public ParameterScript()
        {

        }

        /// <summary>
        /// Creates a prefilled paramter script. Usually used when creating templates
        /// </summary>
        /// <param name="Name">The name of the parameter. This is used to insert it into individual files or file names.</param>
        /// <param name="ScriptBlock">The scriptblock to execute</param>
        public ParameterScript(string Name, ScriptBlock ScriptBlock)
        {
            this.Name = Name;
            this.ScriptBlock = ScriptBlock;
        }
    }
}

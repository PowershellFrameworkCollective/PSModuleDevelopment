using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// A script used to calculate content to be inserted
    /// </summary>
    [Serializable]
    public class ParameterScript
    {
        /// <summary>
        /// Name of the scriptblock (auto-assigned or specified)
        /// </summary>
        public string Name;

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
        /// <param name="ScriptBlock"></param>
        public ParameterScript(string Name, ScriptBlock ScriptBlock)
        {
            this.Name = Name;
            this.ScriptBlock = ScriptBlock;
        }

        /// <summary>
        /// Creates a prefilled parameter script. Usually used in fixing serialization the hard way.
        /// </summary>
        /// <param name="Item">The deserialized ParameterScript item</param>
        public ParameterScript(PSObject Item)
        {
            Name = (string)Item.Properties["Name"].Value;
            ScriptBlock = ScriptBlock.Create((string)Item.Properties["ScriptBlock"].Value);
        }
    }
}

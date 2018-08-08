using System;
using System.Management.Automation;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// A script executed in the context of a template file it is attached to.
    /// </summary>
    [Serializable]
    public class ParameterFileScript : ParameterBase
    {
        /// <summary>
        /// The scriptblock to execute
        /// </summary>
        public ScriptBlock ScriptBlock;

        /// <summary>
        /// The scope during which the sciprtblock will be executed
        /// </summary>
        public FileScriptScope Scope = FileScriptScope.End;
    }
}

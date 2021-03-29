using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Template.Parameter
{
    /// <summary>
    /// When will a specific scriptblock parameter be executed?
    /// </summary>
    public enum ScriptExecutionTime
    {
        /// <summary>
        /// Executed when starting the overall template invocation
        /// </summary>
        StartUp = 1,

        /// <summary>
        /// Executed before an individual item using it is created.
        /// Values will be inserted into the file-content before writing to disk if applicable.
        /// </summary>
        PreItemCreation = 2,

        /// <summary>
        /// Executed after the individual item using it has been created.
        /// Output will be discarded, but scriptblock will receive path of file / folder.
        /// </summary>
        PostItemCreation = 3,

        /// <summary>
        /// Executed after the entire project has been written.
        /// Enables post-processing.
        /// </summary>
        Conclusion = 4
    }
}

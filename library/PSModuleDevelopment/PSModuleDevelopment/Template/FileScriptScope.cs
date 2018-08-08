using System;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// WHen a file script parameter will be executed
    /// </summary>
    [Flags]
    public enum FileScriptScope
    {
        /// <summary>
        /// Execute after name has been determined but before any other processing has been performed.
        /// </summary>
        Begin,

        /// <summary>
        /// Execute during file creation. Executed after file content has been determined but before it is written.
        /// Able to affect file content to be written.
        /// </summary>
        Process,

        /// <summary>
        /// Execute after the file content has been written.
        /// </summary>
        End
    }
}

using System;
using System.Collections.Generic;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// Base class for all files &amp; folders that can be part of a template
    /// </summary>
    [Serializable]
    public abstract class TemplateItemBase
    {
        /// <summary>
        /// Name of the item
        /// </summary>
        public string Name;

        /// <summary>
        /// The full path from the project root
        /// </summary>
        public string RelativePath;

        /// <summary>
        /// The string sequence used to identify variables in this file
        /// </summary>
        public string Identifier;

        /// <summary>
        /// List of flat string insertion parameters for the filesystem object's name
        /// </summary>
        public List<string> FileSystemParameterFlat = new List<string>();

        /// <summary>
        /// List of script value insertion parameters for the filesystem object's name
        /// </summary>
        public List<string> FileSystemParameterScript = new List<string>();
    }
}

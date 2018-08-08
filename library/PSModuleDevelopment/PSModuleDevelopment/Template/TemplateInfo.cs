using System;
using System.Collections.Generic;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// Class containing meta information about a template
    /// </summary>
    [Serializable]
    public class TemplateInfo
    {
        /// <summary>
        /// The name of the template
        /// </summary>
        public string Name;

        /// <summary>
        /// What kind of template is this?
        /// </summary>
        public TemplateType Type;

        /// <summary>
        /// What version is the template
        /// </summary>
        public Version Version;

        /// <summary>
        /// Text describing the template
        /// </summary>
        public string Description;

        /// <summary>
        /// Author of the template
        /// </summary>
        public string Author;

        /// <summary>
        /// When was the template originally created?
        /// </summary>
        public DateTime CreatedOn;

        /// <summary>
        /// List of tags that have been assigned to the template
        /// </summary>
        public List<string> Tags = new List<string>();

        /// <summary>
        /// List of parameters the template accepts
        /// </summary>
        public List<string> Parameters = new List<string>();

        /// <summary>
        /// The store the template is stored in.
        /// </summary>
        public string Store;

        /// <summary>
        /// The path to the template file
        /// </summary>
        public string Path;

        /// <summary>
        /// Version of the template schema used to create the template.
        /// Used to track legacy templates and prevent breaking their invocation.
        /// </summary>
        public Version SchemaVersion;

        /// <summary>
        /// The version-qualified name of the template
        /// </summary>
        /// <returns>The version-qualified name of the template</returns>
        public override string ToString()
        {
            return String.Format("{0} {1}", Name, Version);
        }
    }
}

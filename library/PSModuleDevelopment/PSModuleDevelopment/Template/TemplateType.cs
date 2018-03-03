using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// Is the template a single file or a project?
    /// </summary>
    public enum TemplateType
    {
        /// <summary>
        /// The template consists of a single file
        /// </summary>
        File,

        /// <summary>
        /// The template consists of multiple files
        /// </summary>
        Project
    }
}

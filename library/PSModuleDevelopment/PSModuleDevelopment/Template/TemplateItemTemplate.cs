using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// Class implementing a template referencing another template
    /// </summary>
    public class TemplateItemTemplate : TemplateItemBase
    {
        /// <summary>
        /// Name of the template to initialize
        /// </summary>
        public string TemplateName;

        /// <summary>
        /// The minimum version required for the template to invoke.
        /// </summary>
        public Version MinimumVersion;

        /// <summary>
        /// Exactly this version and only this version may be used
        /// </summary>
        public Version RequiredVersion;

        /// <summary>
        /// Which parameters should be inherited from the parent template
        /// </summary>
        public List<string> ParametersToInherit;

        /// <summary>
        /// How many times should the template be invoked
        /// </summary>
        public int Count = 1;

        /// <summary>
        /// Whether the template should be looped over repeatedly, offering the user to create any number of instances of the template.
        /// </summary>
        public bool Loop = false;
    }
}

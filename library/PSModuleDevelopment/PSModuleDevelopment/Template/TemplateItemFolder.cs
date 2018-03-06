using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// Describes a folder that is part of a template
    /// </summary>
    [Serializable]
    public class TemplateItemFolder : TemplateItemBase
    {
        /// <summary>
        /// Items under the current item.
        /// </summary>
        public List<TemplateItemBase> Children = new List<TemplateItemBase>();
    }
}

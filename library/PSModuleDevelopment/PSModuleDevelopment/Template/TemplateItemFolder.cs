using System;
using System.Collections.Generic;

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

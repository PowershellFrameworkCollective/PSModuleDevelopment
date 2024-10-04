using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;
using PSModuleDevelopment.Utility;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// Static helpers for the template system
    /// </summary>
    internal static class TemplateHost
    {
        internal static TemplateItemBase GetTemplateItem(object Item)
        {
            if (Item.GetType() == typeof(TemplateItemFile))
                return (TemplateItemFile)Item;

            TemplateItemFolder result = new TemplateItemFolder(); ;
            PSObject PSItem = PSObject.AsPSObject(Item);

            foreach (object child in PSItem.GetValue<ArrayList>("Children"))
                result.Children.Add(GetTemplateItem(child));

            result.Name = PSItem.GetValue<string>("Name");
            result.RelativePath = PSItem.GetValue<string>("RelativePath");
            result.Identifier = PSItem.GetValue<string>("Identifier");
            foreach (string entry in PSItem.GetValue<ArrayList>("FileSystemParameterFlat"))
                result.FileSystemParameterFlat.Add(entry);
            foreach (string entry in PSItem.GetValue<ArrayList>("FileSystemParameterScript"))
                result.FileSystemParameterScript.Add(entry);

            return result;
        }
    }
}

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
    public static class TemplateHost
    {
        /// <summary>
        /// Convert a deserialized template item into a fully valid object of its type.
        /// </summary>
        /// <param name="Item">The PSObject to transform back into what it was meant to be</param>
        /// <returns>The resultant TemplateItemBase</returns>
        public static TemplateItemBase GetTemplateItem(object Item)
        {
            if (Item.GetType() == typeof(TemplateItemFile))
                return (TemplateItemFile)Item;

            PSObject PSItem = PSObject.AsPSObject(Item);
            if (PSItem.TypeNames.Contains("Deserialized.PSModuleDevelopment.Template.TemplateItemFile"))
                return new TemplateItemFile(PSItem);

            TemplateItemFolder result = new TemplateItemFolder();

            foreach (object child in PSItem.GetValues("Children"))
                result.Children.Add(GetTemplateItem(child));

            result.Name = PSItem.GetValue<string>("Name");
            result.RelativePath = PSItem.GetValue<string>("RelativePath");
            result.Identifier = PSItem.GetValue<string>("Identifier");
            foreach (string entry in PSItem.GetValues("FileSystemParameterFlat"))
                result.FileSystemParameterFlat.Add(entry);
            foreach (string entry in PSItem.GetValues("FileSystemParameterScript"))
                result.FileSystemParameterScript.Add(entry);

            return result;
        }
    }
}

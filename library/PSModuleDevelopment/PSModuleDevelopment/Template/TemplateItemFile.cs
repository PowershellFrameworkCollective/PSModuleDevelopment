using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;
using PSModuleDevelopment.Utility;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// Describes a file that is part of a template
    /// </summary>
    [Serializable]
    public class TemplateItemFile : TemplateItemBase
    {
        /// <summary>
        /// The value of the file. May contain plaintext UTF8 in cases of script files or similar text files. Base64 Encoded string in case of binary files.
        /// </summary>
        public string Value;

        /// <summary>
        /// Whether the file is interpreted as plain text. If not, it will be assumed to be a Base64 encoded binary file.
        /// </summary>
        public bool PlainText = true;

        /// <summary>
        /// List of flat string insertion parameters for the plaintext file
        /// </summary>
        public List<string> ContentParameterFlat = new List<string>();

        /// <summary>
        /// List of script value insertion parameters for the plaintext file
        /// </summary>
        public List<string> ContentParameterScript = new List<string>();

        /// <summary>
        /// Creates an empty TemplateItemFile
        /// </summary>
        public TemplateItemFile()
        {

        }

        /// <summary>
        /// Creates a filled-out TemplateItemFile.
        /// Usually called when deserializing a template.
        /// </summary>
        /// <param name="PSItem">The deserialized instance of this template item file.</param>
        public TemplateItemFile(PSObject PSItem)
        {
            Name = PSItem.GetValue<string>("Name");
            RelativePath = PSItem.GetValue<string>("RelativePath");
            Identifier = PSItem.GetValue<string>("Identifier");
            foreach (string entry in PSItem.GetValues("FileSystemParameterFlat"))
                FileSystemParameterFlat.Add(entry);
            foreach (string entry in PSItem.GetValues("FileSystemParameterScript"))
                FileSystemParameterScript.Add(entry);

            foreach (string entry in PSItem.GetValues("ContentParameterFlat"))
                ContentParameterFlat.Add(entry);
            foreach (string entry in PSItem.GetValues("ContentParameterScript"))
                ContentParameterScript.Add(entry);

            Value = PSItem.GetValue<string>("Value");
            PlainText = PSItem.GetValue<bool>("PlainText");
        }
    }
}

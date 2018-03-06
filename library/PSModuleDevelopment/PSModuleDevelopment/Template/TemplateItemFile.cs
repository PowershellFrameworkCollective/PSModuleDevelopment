using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
    }
}

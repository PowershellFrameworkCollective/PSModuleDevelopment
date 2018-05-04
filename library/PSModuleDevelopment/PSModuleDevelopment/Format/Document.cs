using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Format
{
    /// <summary>
    /// A format document. Should be written to a *.Format.ps1xml format.
    /// </summary>
    [Serializable]
    public class Document
    {
        /// <summary>
        /// Name of the document. Purely cosmetic in nature.
        /// </summary>
        public string Name;

        /// <summary>
        /// List of views stored in this document.
        /// </summary>
        public List<ViewDefinitionBase> Views = new List<ViewDefinitionBase>();

        /// <summary>
        /// The XML definition of this format document
        /// </summary>
        public string Text
        {
            get
            {
                List<string> tempString = new List<string>();
                if (!String.IsNullOrEmpty(Name))
                    tempString.Add(String.Format("<!-- {0} -->", Name));
                tempString.Add("<?xml version=\"1.0\" encoding=\"utf-16\"?>");
                tempString.Add("<Configuration>");
                tempString.Add("    <ViewDefinitions>");

                bool firstDone = false;
                foreach (ViewDefinitionBase view in Views)
                {
                    if (firstDone)
                        tempString.Add("        ");
                    tempString.Add(view.TextDefinition);
                    firstDone = true;
                }

                tempString.Add("    </ViewDefinitions>");
                tempString.Add("</Configuration>");
                return String.Join("\n", tempString);
            }
            set { }
        }

        /// <summary>
        /// Returns the string representation of the format XML
        /// </summary>
        /// <returns>The string representation of the format XML</returns>
        public override string ToString()
        {
            return Text;
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Format
{
    /// <summary>
    /// Base class for format definitions
    /// </summary>
    public abstract class ViewDefinitionBase : IComparable
    {
        /// <summary>
        /// The name of the definition
        /// </summary>
        public string Name;

        /// <summary>
        /// The typenames selected by
        /// </summary>
        public List<string> ViewSelectedByType = new List<string>();

        /// <summary>
        /// The selectionset to select by
        /// </summary>
        public List<string> ViewSelectedBySet = new List<string>();

        /// <summary>
        /// The string representation. Must be overridden by all implementing classes.
        /// </summary>
        public abstract string TextDefinition { get; set; }

        /// <summary>
        /// The string representation. Must be overridden by all implementing classes.
        /// </summary>
        /// <returns>The format string to produce for the format file.</returns>
        public abstract override string ToString();

        public int CompareTo(object Item)
        {
            ViewDefinitionBase tempItem = Item as ViewDefinitionBase;
            if (tempItem == null)
                throw new InvalidOperationException("Comparison is supported only between views!");

            return Name.CompareTo(tempItem.Name);
        }
    }
}

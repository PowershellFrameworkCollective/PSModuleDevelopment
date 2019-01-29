using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Utility
{
    /// <summary>
    /// The result object returned by Search-PSMDPropertyValue
    /// </summary>
    [Serializable]
    public class PropertySearchResult
    {
        /// <summary>
        /// Path notation on nested properties
        /// </summary>
        public string Path
        {
            get
            {
                return String.Join(".", PathElements);
            }
            set { }
        }

        /// <summary>
        /// The name of the property found
        /// </summary>
        public string Name;

        /// <summary>
        /// The full name of the property
        /// </summary>
        public string FullName
        {
            get
            {
                if (PathElements.Length > 0)
                    return String.Format("{0}.{1}", Path, Name);
                return Name;
            }
            set { }
        }

        /// <summary>
        /// Individual property names on a found nested property.
        /// </summary>
        public string[] PathElements = new string[0];

        /// <summary>
        /// The actual value found
        /// </summary>
        public object Value;

        /// <summary>
        /// The type of the value found
        /// </summary>
        public Type Type
        {
            get
            {
                if (Value != null)
                    return Value.GetType();
                return null;
            }
            set { }
        }

        /// <summary>
        /// How deeply nested was the property found.
        /// </summary>
        public int Depth
        {
            get { return PathElements.Length; }
            set { }
        }

        /// <summary>
        /// The original input object
        /// </summary>
        public object InputObject;

        /// <summary>
        /// Creates an empty object. Only used for serialization support.
        /// </summary>
        public PropertySearchResult()
        {

        }

        /// <summary>
        /// Creates a full report object from using Search-PSMDPropertyValue
        /// </summary>
        /// <param name="Name">The name of the property</param>
        /// <param name="PathElements">The path elements if it is a nested property</param>
        /// <param name="Value">The actual value found</param>
        /// <param name="InputObject">The original input object offered to the command.</param>
        public PropertySearchResult(string Name, string[] PathElements, object Value, object InputObject)
        {
            this.Name = Name;
            if (PathElements != null)
                this.PathElements = PathElements;
            this.Value = Value;
            this.InputObject = InputObject;
        }
    }
}

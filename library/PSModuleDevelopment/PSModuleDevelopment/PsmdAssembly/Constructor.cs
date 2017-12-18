using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.PsmdAssembly
{
    /// <summary>
    /// Class containing information about a class's constructor
    /// </summary>
    public class Constructor
    {
        /// <summary>
        /// The type the constructor is part of
        /// </summary>
        public Type Type
        {
            get { return ConstructorItem.DeclaringType; }
        }

        /// <summary>
        /// The constructor definition
        /// </summary>
        public string Definition
        {
            get
            {
                StringBuilder temp = new StringBuilder();

                temp = temp.AppendFormat("{0}(", Type.Name);
                bool first = true;

                foreach (ParameterInfo info in Parameters)
                {
                    if (!first)
                        temp = temp.Append(", ");

                    temp = temp.AppendFormat("{0} {1}", info.ParameterType.Name, info.Name);
                    if (info.HasDefaultValue)
                        temp = temp.AppendFormat("[ = {0}]", info.DefaultValue);

                    if (first)
                        first = false;
                }
                temp = temp.Append(")");

                return temp.ToString();
            }
        }

        /// <summary>
        /// Whether the constructor is public
        /// </summary>
        public bool Public
        {
            get { return ConstructorItem.IsPublic; }
        }

        /// <summary>
        /// The actual parameters of the constructor
        /// </summary>
        public ParameterInfo[] Parameters
        {
            get
            {
                return ConstructorItem.GetParameters();
            }
        }

        /// <summary>
        /// The actual constructor object
        /// </summary>
        public ConstructorInfo ConstructorItem { get; set; }

        /// <summary>
        /// Creates a new constructor object, designed for display in PowerShell
        /// </summary>
        /// <param name="Info">The constructor info object describing the constructor</param>
        public Constructor(ConstructorInfo Info)
        {
            ConstructorItem = Info;
        }
    }
}

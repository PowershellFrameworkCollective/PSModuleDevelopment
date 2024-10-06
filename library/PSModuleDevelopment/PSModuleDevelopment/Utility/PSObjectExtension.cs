using PSModuleDevelopment.Template;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Utility
{
    /// <summary>
    /// Extends the PSObject with C# convenience
    /// </summary>
    public static class PSObjectExtension
    {
        /// <summary>
        /// Get the value!
        /// </summary>
        /// <typeparam name="T">The type of the value</typeparam>
        /// <param name="PSObject">The object to extend</param>
        /// <param name="Name">The name of the property that has the value</param>
        /// <returns>The value</returns>
        public static T GetValue<T>(this PSObject PSObject, string Name)
        {
            PSObject value = PSObject.AsPSObject(PSObject.Properties[Name].Value);
            return (T)value.BaseObject;
        }

        /// <summary>
        /// Get the Values!
        /// Always as an arraylist, empty if null
        /// </summary>
        /// <param name="PSObject">The object to extend</param>
        /// <param name="Name">>The name of the property that has the values</param>
        /// <returns>The values</returns>
        public static ArrayList GetValues(this PSObject PSObject, string Name)
        {
            if (null == PSObject || null == PSObject.Properties || null == PSObject.Properties[Name] || null == PSObject.Properties[Name]?.Value)
                return new ArrayList();
            PSObject value = PSObject.AsPSObject(PSObject.Properties[Name].Value);
            if (null == value.BaseObject)
                return new ArrayList();
            return (ArrayList)value.BaseObject;
        }

        /// <summary>
        /// Get a hashtable value!
        /// </summary>
        /// <typeparam name="T">The type of the values in hashtable</typeparam>
        /// <param name="PSObject">The object to extend</param>
        /// <param name="Name">The name of the property that has the hashtable</param>
        /// <returns>The hashtable!</returns>
        public static Dictionary<string, ParameterScript> GetParameterScriptDictionary(this PSObject PSObject, string Name)
        {
            Hashtable temp = PSObject.GetValue<Hashtable>(Name);
            Dictionary<string, ParameterScript> result = new Dictionary<string, ParameterScript>();
            foreach (DictionaryEntry pair in temp)
                result[(string)pair.Key] = new ParameterScript((PSObject)pair.Value);

            return result;
        }
    }
}

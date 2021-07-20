using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace PSModuleDevelopment.Template.Parameter
{
    /// <summary>
    /// A template parameter where the user is prompted for input.
    /// </summary>
    [Serializable]
    public class ParameterPrompt : ParameterBase
    {
        /// <summary>
        /// The value provided by the user
        /// </summary>
        public string Value;

        /// <summary>
        /// List of legal values to provide
        /// </summary>
        public List<string> ValidateSet = new List<string>();

        /// <summary>
        /// A validation pattern that needs to be met.
        /// </summary>
        public string ValidatePattern;

        /// <summary>
        /// An error description that will be shown if the user provides invalid input to a parameter with pattern validation.
        /// </summary>
        public string PatternError;

        /// <summary>
        /// Test whether the input meets the validation rules
        /// </summary>
        /// <param name="Value">The value to test</param>
        /// <returns>Whether the value is valid.</returns>
        public bool TestValue(string Value)
        {
            if (ValidateSet.Count > 0 && !ValidateSet.Contains(Value, StringComparer.InvariantCultureIgnoreCase))
                return false;
            if (!String.IsNullOrEmpty(ValidatePattern) && !Regex.IsMatch(Value, ValidatePattern))
                return false;

            return true;
        }

        /// <summary>
        /// Return the value specified by the user.
        /// </summary>
        /// <returns>The value specified by the user</returns>
        public override string GetValue()
        {
            return Value;
        }
    }
}

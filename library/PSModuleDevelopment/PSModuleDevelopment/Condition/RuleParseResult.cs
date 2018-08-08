using System;
using System.Text;

namespace PSModuleDevelopment.Condition
{
    /// <summary>
    /// Conveys the result of a rule parsing
    /// </summary>
    public class RuleParseResult
    {
        /// <summary>
        /// Name of the rule
        /// </summary>
        public string Name;

        /// <summary>
        /// COndition text
        /// </summary>
        public string Condition;

        /// <summary>
        /// Constructs a parse result from an input string to parse.
        /// </summary>
        /// <param name="Filter">The string to dissect into a rule</param>
        public RuleParseResult(string Filter)
        {
            if (Filter.Length == 0)
                throw new ArgumentNullException("Can't process an empty string");
            char[] characters = Filter.ToCharArray();
            if (characters[0] != '(')
                throw new ArgumentException("A rule section must start with a '(' character!");

            #region Parsing the name
            StringBuilder stringBuilder = new StringBuilder();
            int position = 1;
            bool killIt = false;
            while (!killIt)
            {
                if (characters.Length <= position)
                    break;
                switch (characters[position])
                {
                    case ' ':
                        killIt = true;
                        break;
                    case '\t':
                        killIt = true;
                        break;
                    case '(':
                        killIt = true;
                        break;
                    case ')':
                        killIt = true;
                        break;
                    default:
                        stringBuilder.Append(characters[position]);
                        break;
                }

                position++;
            }

            Name = stringBuilder.ToString();
            if (String.IsNullOrEmpty(Name))
                throw new ArgumentException(String.Format("Could not resolve a legal name from this condition string: {0}", Filter));
            #endregion Parsing the name

            #region Parsing the filter condition
            stringBuilder = new StringBuilder();
            int braceLevel = 1;
            while (position < Filter.Length)
            {
                stringBuilder.Append(characters[position]);

                if (characters[position] == '(')
                    braceLevel++;
                if (characters[position] == ')')
                    braceLevel--;

                position++;

                if (braceLevel < 0)
                    throw new ArgumentException(String.Format("Failed to parse content of {0} rule!", Name));
                if ((braceLevel == 0) && (position < Filter.Length))
                    throw new ArgumentException(String.Format("Failed to parse content of {0} rule!", Name));
            }

            if (braceLevel > 0)
                throw new ArgumentException(String.Format("Failed to parse content of {0} rule!", Name));

            Condition = stringBuilder.ToString().Trim();
            #endregion Parsing the filter condition
        }
    }
}

using System;
using System.Collections.Generic;
using System.Management.Automation.Host;
using System.Text;

namespace PSModuleDevelopment.Utility
{
    /// <summary>
    /// Host class, containing statics in support of the utility namespace
    /// </summary>
    public static class UtilityHost
    {
        /// <summary>
        /// Gives access to the host UI, in order to access window information
        /// </summary>
        public static PSHostRawUserInterface RawUI;

        /// <summary>
        /// Implement's VB's Like operator logic.
        /// </summary>
        public static bool IsLike(string String, string Pattern, bool CaseSensitive = false)
        {
            if (!CaseSensitive)
            {
                String = String.ToLower();
                Pattern = Pattern.ToLower();
            }

            // Characters matched so far
            int matched = 0;

            // Loop through pattern string
            for (int i = 0; i < Pattern.Length;)
            {
                // Check for end of string
                if (matched > String.Length)
                    return false;

                // Get next pattern character
                char c = Pattern[i++];
                if (c == '[') // Character list
                {
                    // Test for exclude character
                    bool exclude = (i < Pattern.Length && Pattern[i] == '!');
                    if (exclude)
                        i++;
                    // Build character list
                    int j = Pattern.IndexOf(']', i);
                    if (j < 0)
                        j = String.Length;
                    HashSet<char> charList = CharListToSet(Pattern.Substring(i, j - i));
                    i = j + 1;

                    if (charList.Contains(String[matched]) == exclude)
                        return false;
                    matched++;
                }
                else if (c == '?') // Any single character
                {
                    matched++;
                }
                else if (c == '#') // Any single digit
                {
                    if (!Char.IsDigit(String[matched]))
                        return false;
                    matched++;
                }
                else if (c == '*') // Zero or more characters
                {
                    if (i < Pattern.Length)
                    {
                        // Matches all characters until
                        // next character in pattern
                        char next = Pattern[i];
                        int j = String.IndexOf(next, matched);
                        if (j < 0)
                            return false;
                        matched = j;
                    }
                    else
                    {
                        // Matches all remaining characters
                        matched = String.Length;
                        break;
                    }
                }
                else // Exact character
                {
                    if (matched >= String.Length || c != String[matched])
                        return false;
                    matched++;
                }
            }
            // Return true if all characters matched
            return (matched == String.Length);
        }

        /// <summary>
        /// Converts a string of characters to a HashSet of characters. If the string
        /// contains character ranges, such as A-Z, all characters in the range are
        /// also added to the returned set of characters.
        /// </summary>
        /// <param name="charList">Character list string</param>
        private static HashSet<char> CharListToSet(string charList)
        {
            HashSet<char> set = new HashSet<char>();

            for (int i = 0; i < charList.Length; i++)
            {
                if ((i + 1) < charList.Length && charList[i + 1] == '-')
                {
                    // Character range
                    char startChar = charList[i++];
                    i++; // Hyphen
                    char endChar = (char)0;
                    if (i < charList.Length)
                        endChar = charList[i++];
                    for (int j = startChar; j <= endChar; j++)
                        set.Add((char)j);
                }
                else set.Add(charList[i]);
            }
            return set;
        }

        /// <summary>
        /// Replace a value in a string with another.
        /// Extends the default c# String.Replace with the capability to be case-insensitive.
        /// </summary>
        /// <param name="String">The string to modify</param>
        /// <param name="OldString">The value to look for and replace with someting else</param>
        /// <param name="NewString">The value to insert where you found the previous value. Leave empty to just delete the original value.</param>
        /// <param name="CaseSensitive">Whether to be case sensitive in your replacement. Defaults to false, this being PowerShell</param>
        /// <returns>The original string, with all instances of the looked for value replaced with the new value.</returns>
        public static string Replace(string String, string OldString, string NewString, bool CaseSensitive = false)
        {
            // Validate User Inputs (emulating the original C# behavior
            if (String == null)
                throw new ArgumentNullException(nameof(String));
            if (String.Length == 0)
                return String;
            if (OldString == null)
                throw new ArgumentNullException(nameof(OldString));
            if (OldString.Length == 0)
                throw new ArgumentException("String cannot be of zero length.");

            StringComparison comparisonType = StringComparison.OrdinalIgnoreCase;
            if (CaseSensitive)
                comparisonType = StringComparison.Ordinal;


            StringBuilder resultStringBuilder = new StringBuilder();

            bool isReplacementNullOrEmpty = string.IsNullOrEmpty(NewString);

            int foundAt;
            int startSearchFromIndex = 0;
            while ((foundAt = String.IndexOf(OldString, startSearchFromIndex, comparisonType)) != -1)
            {
                int charsUntilReplacement = foundAt - startSearchFromIndex;
                bool isNothingToAppend = charsUntilReplacement == 0;
                if (!isNothingToAppend)
                    resultStringBuilder.Append(String, startSearchFromIndex, charsUntilReplacement);
                
                // Process the replacement.
                if (!isReplacementNullOrEmpty)
                    resultStringBuilder.Append(NewString);
                
                // Reset Search Index
                startSearchFromIndex = foundAt + OldString.Length;
                if (startSearchFromIndex == String.Length)
                    return resultStringBuilder.ToString();
            }

            resultStringBuilder.Append(String, startSearchFromIndex, (String.Length - startSearchFromIndex));
            return resultStringBuilder.ToString();
        }
    }
}

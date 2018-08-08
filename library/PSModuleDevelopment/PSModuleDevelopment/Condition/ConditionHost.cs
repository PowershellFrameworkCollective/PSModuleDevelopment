using System;
using System.Collections.Generic;
using System.Text;

namespace PSModuleDevelopment.Condition
{
    /// <summary>
    /// Class hosting static tools used when working with the condition system.
    /// </summary>
    public static class ConditionHost
    {
        /// <summary>
        /// Table of registered contexts
        /// </summary>
        public static Dictionary<string, ConditionContext> Contexts = new Dictionary<string, ConditionContext>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// Table of registered Rules
        /// </summary>
        public static Dictionary<Guid, RuleBase> Rules = new Dictionary<Guid, RuleBase>();

        /// <summary>
        /// Returns a specific rule based on its Guid
        /// </summary>
        /// <param name="Id">The unique ID of the rule to return</param>
        /// <returns>The rule matching the Guid</returns>
        public static RuleBase GetRule(Guid Id)
        {
            if (!Rules.ContainsKey(Id))
                throw new KeyNotFoundException(String.Format("A rule with Id '{0}' has not been registered yet!", Id));
            return Rules[Id].Clone();
        }

        /// <summary>
        /// Returns all rules with a matching name
        /// </summary>
        /// <param name="Name">The name to look by. Does NOT support wildcards</param>
        /// <returns>All rules that use a given name</returns>
        public static List<RuleBase> GetRules(string Name)
        {
            List<RuleBase> rules = new List<RuleBase>();
            List<Guid> ruleIDs = new List<Guid>();

            foreach (RuleBase rule in Rules.Values)
                foreach (string name in rule.Names)
                    if (String.Equals(name, Name, StringComparison.InvariantCultureIgnoreCase) && !ruleIDs.Contains(rule.Id))
                    {
                        rules.Add(rule.Clone());
                        ruleIDs.Add(rule.Id);
                    }

            return rules;
        }

        /// <summary>
        /// Parses the rule from a filter string.
        /// This parser assumes the name to be delimited from anything coming after it by either a whitespace or an open parens.
        /// The condition will be trimmed, so working with leading or trailing whitespace is impossible, but additional ones will not hurt.
        /// </summary>
        /// <param name="Filter">The filter to consider</param>
        /// <returns>The parsed name and condition</returns>
        public static RuleParseResult ParseRule(string Filter)
        {
            return new RuleParseResult(Filter);
        }

        /// <summary>
        /// Splits a string containing one or multiple filter rules.
        /// Used by rules that handle multiple conditions, such as AND or OR rules.
        /// </summary>
        /// <param name="Filter">The string to separate out.</param>
        /// <returns>A list of strings that each represent a rule.</returns>
        public static List<string> SplitRulesString(string Filter)
        {
            List<string> result = new List<string>();

            int braceLevel = 0;
            int position = 0;
            string tempFilter = Filter.Trim();
            char[] content = tempFilter.ToCharArray();
            bool inCondition = false;
            StringBuilder builder = new StringBuilder();

            while (position < content.Length)
            {
                char curItem = content[position];
                switch (curItem)
                {
                    case '(':
                        braceLevel++;
                        builder.Append(curItem);
                        inCondition = true;
                        break;
                    case ')':
                        braceLevel--;
                        builder.Append(curItem);
                        if (braceLevel == 0)
                        {
                            inCondition = false;
                            result.Add(builder.ToString());
                            builder = new StringBuilder();
                        }
                        if (braceLevel < 0)
                            throw new ArgumentException(String.Format("Failed to parse '{0}' at position {1}", tempFilter, position));
                        break;
                    case ' ':
                        if (inCondition)
                            builder.Append(curItem);
                        break;
                    default:
                        if (!inCondition)
                            throw new ArgumentException(String.Format("Failed to parse '{0}' at position {1}", tempFilter, position));
                        builder.Append(curItem);
                        break;
                }

                position++;
            }

            return result;
        }
    }
}

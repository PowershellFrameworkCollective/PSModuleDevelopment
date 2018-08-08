using System;
using System.Collections.Generic;

namespace PSModuleDevelopment.Condition
{
    /// <summary>
    /// A condition is a context specific wrapper for a condition syntax, serving as the framework for dynamic filter/condition syntax that must be implemented in context-specific conditions.
    /// </summary>
    [Serializable]
    public sealed class Condition
    {
        /// <summary>
        /// Name of the context to apply.
        /// A context is a set of conditions grouped to be legal in combination.
        /// An application must first initialize a context before it can apply / use conditions within that same context.
        /// </summary>
        public string Context
        {
            get { return _Context.Name; }
            set { _Context = ConditionHost.Contexts[value]; }
        }

        /// <summary>
        /// The actual context object defining the condition's rule
        /// </summary>
        private ConditionContext _Context;

        /// <summary>
        /// The rule by which to comply.
        /// Generally, the first rule is an AND or OR condition, but this is by no means mandatory.
        /// </summary>
        public RuleBase Rule
        {
            get { return _Rule; }
            set
            {
                if (!IsValidRule(value))
                    throw new ArgumentException("Rule is not a type of rule valid for this condition!");
                _Rule = value;
                _Rule.Condition = this;
            }
        }
        private RuleBase _Rule;

        /// <summary>
        /// Validates a given item against the rules contained within.
        /// </summary>
        /// <param name="Item">The item to validate</param>
        /// <returns>Whether the item can be validated against this rule.</returns>
        public bool Validate(object Item)
        {
            if (Rule == null)
                return false;
            Log.Clear();
            return Rule.Validate(Item);
        }

        /// <summary>
        /// Whether a given rule is valid for this condition
        /// </summary>
        /// <param name="Rule">The rule to validate</param>
        /// <returns>Whether it is valid for this condition</returns>
        public bool IsValidRule(RuleBase Rule)
        {
            // Universal rules - that is core logic rules, such as NOT, OR or AND - are valid for all conditions
            if (Rule.IsUniversal)
                return true;

            if (_Context.Rules.Contains(Rule.Id))
                return true;
            return false;
        }

        /// <summary>
        /// The log containing the logging entries of the rules of this condition.
        /// </summary>
        public List<RuleLogEntry> Log = new List<RuleLogEntry>();

        /// <summary>
        /// Writes a log entry to the log.
        /// </summary>
        /// <param name="RuleName">The name of the rule evaluated</param>
        /// <param name="RuleId">The ID of the rule evaluated</param>
        /// <param name="Success">Whether the result was positive</param>
        /// <param name="Message">Any message to pass along</param>
        /// <param name="Error">Any errors that occured</param>
        public void WriteLog(string RuleName, Guid RuleId, bool Success, string Message, Exception Error)
        {
            Log.Add(new RuleLogEntry(RuleName, RuleId, Success, Message, Error));
        }

        /// <summary>
        /// Generates a fresh instance of the defined condition.
        /// Discards logs, but copies all other relevnt content.
        /// </summary>
        /// <returns>A fresh Condition instance, ready to rock.</returns>
        public Condition Clone()
        {
            Condition condition = new Condition();
            condition._Context = _Context;
            condition._Rule = _Rule.Clone();
            return condition;
        }

        /// <summary>
        /// Returns the only rule object with the specified name that is legal for this condition.
        /// Ambiguous names will cause an exception to be thrown.
        /// </summary>
        /// <param name="Name">The name of the rule to generate.</param>
        /// <returns>A Rule object that owns that name.</returns>
        public RuleBase GetRule(string Name)
        {
            RuleBase rule = _Context.GetRule(Name);
            rule.Name = Name;
            rule.Condition = this;
            return rule;
        }

        /// <summary>
        /// Returns the only legal rule based on the parsed name of the condition string.
        /// Preinitializes that rule object with its parsed filter string and assigns it to this condition object.
        /// </summary>
        /// <param name="ParseResult">The result of parsing a filter string into rule and rule-filter</param>
        /// <returns>A finished rule object ready to use</returns>
        public RuleBase GetRule(RuleParseResult ParseResult)
        {
            RuleBase rule = GetRule(ParseResult.Name);
            rule.Parse(ParseResult.Condition);
            return rule;
        }

        /// <summary>
        /// Load a condition string and generate rules from it.
        /// </summary>
        /// <param name="Condition">The condition string to break down into the set of rules to validate.</param>
        public void Load(string Condition)
        {
            RuleParseResult parsed = new RuleParseResult(Condition);
            RuleBase ruleItem = GetRule(parsed.Name);
            ruleItem.Parse(parsed.Condition);
            Rule = ruleItem;
        }
    }
}

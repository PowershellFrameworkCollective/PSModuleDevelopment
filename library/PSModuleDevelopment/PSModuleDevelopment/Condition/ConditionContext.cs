using System;
using System.Collections.Generic;

namespace PSModuleDevelopment.Condition
{
    /// <summary>
    /// A condition context defines, what conditions may be part of a given condition type (="Context")
    /// </summary>
    [Serializable]
    public sealed class ConditionContext
    {
        /// <summary>
        /// Name of the context as seen by the world
        /// </summary>
        public string Name;

        /// <summary>
        /// List of all rules that are part of this context.
        /// </summary>
        public List<Guid> Rules = new List<Guid>();
        
        /// <summary>
        /// Resolves the name of a rule to the actual rule object legal for this context.
        /// Multiple rules may share a name at any given time, but in order for a name to be usable within a context, it must be unqiue within the rules supported by that context.
        /// </summary>
        /// <param name="Name">The name to search by</param>
        /// <returns>The rule that applies to this context.</returns>
        public RuleBase GetRule(string Name)
        {
            List<RuleBase> rules = ConditionHost.GetRules(Name);
            List<RuleBase> rulesLegal = new List<RuleBase>();
            foreach (RuleBase rule in rules)
                if (Rules.Contains(rule.Id))
                    rulesLegal.Add(rule);

            if (rulesLegal.Count > 1)
                throw new ArgumentException(String.Format("Ambiguous rule resolution! Found {0} rules using the name {1} in the context {2}", rulesLegal.Count, Name, this.Name));

            if (rulesLegal.Count < 1)
                throw new ArgumentException(String.Format("Found no rules using the name {0} in the context {1}", Name, this.Name));
            return rules[0];
        }

        /// <summary>
        /// Return all rules that are part of this context
        /// </summary>
        /// <returns>List of all rules that are part of this context.</returns>
        public List<RuleBase> GetRules()
        {
            List<RuleBase> rules = new List<RuleBase>();
            foreach (Guid id in Rules)
                rules.Add(ConditionHost.GetRule(id));
            return rules;
        }
    }
}

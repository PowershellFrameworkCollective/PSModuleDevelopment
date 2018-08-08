using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Condition
{
    /// <summary>
    /// The rule implementing a logical AND condition
    /// </summary>
    public class RuleAnd : RuleBase
    {
        /// <summary>
        /// The ID of the rule
        /// </summary>
        public override Guid Id
        {
            get { return new Guid("6d4a7080-a69e-4ea1-a9ed-bfa5da729bba"); }
        }

        /// <summary>
        /// The names you can call the rule by
        /// </summary>
        public override string[] Names
        {
            get
            {
                return new string[] { "&", "and" };
            }
        }

        /// <summary>
        /// The condition governing this rule
        /// </summary>
        public new Condition Condition
        {
            get
            {
                return _Condition;
            }
            set
            {
                _Condition = value;
                foreach (RuleBase rule in Rules)
                    rule.Condition = value;
            }
        }
        private Condition _Condition;

        /// <summary>
        /// Contains all rules that are chained in an AND chain
        /// </summary>
        public List<RuleBase> Rules = new List<RuleBase>();

        /// <summary>
        /// Create a true copy of the current item
        /// </summary>
        /// <returns>The cloned rule</returns>
        public override RuleBase Clone()
        {
            RuleAnd rule = new RuleAnd();
            rule.Name = Name;
            foreach (RuleBase ruleItem in Rules)
                rule.Rules.Add(ruleItem.Clone());

            return rule;
        }

        /// <summary>
        /// The string representation of this rule
        /// </summary>
        /// <returns>The string representation of this rule</returns>
        public override string ToString()
        {
            return String.Format("({0}{1})", Name, String.Join("", Rules));
        }

        /// <summary>
        /// Parses a filterstring into a list of rules, all of which must be true for this rule to be true.
        /// </summary>
        /// <param name="String">The string to interpret</param>
        public override void Parse(string String)
        {
            foreach (string ruleString in ConditionHost.SplitRulesString(String))
                Rules.Add(Condition.GetRule(new RuleParseResult(ruleString)));
        }

        /// <summary>
        /// Validates an input object by applying all rules contained in this rule, ALL of which must be true
        /// </summary>
        /// <param name="Item">An arbitrary object to evaluate</param>
        /// <returns>Whetehr all conditions returned true or not.</returns>
        public override bool Validate(object Item)
        {
            foreach (RuleBase rule in Rules)
            {
                if (!rule.Validate(Item))
                {
                    Condition.WriteLog(Name, Id, false, "", null);
                    return false;
                }
            }
            Condition.WriteLog(Name, Id, true, "", null);
            return true;
        }
    }
}

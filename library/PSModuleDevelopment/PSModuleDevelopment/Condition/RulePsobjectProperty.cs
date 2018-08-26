using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Condition
{
    /// <summary>
    /// Rule that compares a property with a value
    /// </summary>
    public class RulePsobjectProperty : RuleBase
    {
        /// <inheritdoc />
        public override Guid Id
        {
            get { return new Guid("9f454bda-b3e7-480d-8653-64ec714c1dd6"); }
        }

        /// <inheritdoc />
        public override string[] Names
        {
            get { return new string[] { "property", "psproperty", "prop" }; }
        }

        /// <summary>
        /// The property on the object to compare
        /// </summary>
        public string PropertyName;

        /// <summary>
        /// The compare operator to use
        /// </summary>
        public PSCompareOperator Operator = PSCompareOperator.None;

        /// <summary>
        /// The value to compare the property of the input with
        /// </summary>
        public string Value
        {
            get { return _Value; }
            set
            {
                try
                {
                    Number = Double.Parse(value);
                    IsNumber = true;
                }
                catch { }
                if (value.ToLower() == "true")
                {
                    BoolValue = true;
                    IsBool = true;
                }
                if (value.ToLower() == "false")
                {
                    BoolValue = false;
                    IsBool = true;
                }
                _Value = value;
            }
        }
        private string _Value;

        /// <summary>
        /// The numeric value of the property
        /// </summary>
        public double Number;

        /// <summary>
        /// Whether the value to compare with actually is numeric
        /// </summary>
        public bool IsNumber;

        /// <summary>
        /// The boolean value of the object to compare with
        /// </summary>
        public bool BoolValue;

        /// <summary>
        /// Whether the value to compare with actually is a boolean
        /// </summary>
        public bool IsBool;

        /// <inheritdoc />
        public override RuleBase Clone()
        {
            RulePsobjectProperty rule = new RulePsobjectProperty();
            rule.Condition = Condition;
            rule.Name = Name;
            rule.PropertyName = PropertyName;
            rule.Operator = Operator;
            rule.Value = Value;
            return rule;
        }

        /// <inheritdoc />
        public override string ToString()
        {
            return String.Format("({0} {1} {2} {3})", Name, PropertyName, GetOperator(Operator), Value);
        }

        /// <inheritdoc />
        public override void Parse(string String)
        {
            string[] values = String.Split(' ');
            if (values.Length != 3)
                throw new ArgumentException(String.Format("Invalid {0} filter! '{1}' must consist of three elements", Name, String));
            PropertyName = values[0];
            Operator = GetOperator(values[1]);
            Value = values[2];
        }

        /// <inheritdoc />
        public override bool Validate(object Item)
        {
            if (Item == null)
            {
                Condition.WriteLog(Name, Id, false, "Input object is null", null);
                return false;
            }

            PSObject item = Item as PSObject;
            bool testResult = false;

            foreach (PSPropertyInfo property in item.Properties)
            {
                if (property.Name.ToLower() != PropertyName.ToLower())
                    continue;

                if (Operator == PSCompareOperator.Null)
                {
                    testResult = property.Value == null;
                    Condition.WriteLog(Name, Id, testResult, "", null);
                    return testResult;
                }
                

            }

            Condition.WriteLog(Name, Id, false, "Property not found", null);
            return false;
        }

        /// <summary>
        /// Resolves an operator to its string form
        /// </summary>
        /// <param name="Operator">The operator to resolve</param>
        /// <returns>Its string representation</returns>
        private string GetOperator(PSCompareOperator Operator)
        {
            switch (Operator)
            {
                case PSCompareOperator.Equals:
                    return "-eq";
                case PSCompareOperator.GreaterThan:
                    return "-gt";
                case PSCompareOperator.LessThan:
                    return "-lt";
                case PSCompareOperator.Like:
                    return "-like";
                case PSCompareOperator.Match:
                    return "-match";
                case PSCompareOperator.Null:
                    return "-null";
                default:
                    throw new ArgumentException("Unknown Operator!");
            }
        }

        /// <summary>
        /// Resolves an operator to its PSComperOperator form
        /// </summary>
        /// <param name="Operator">The string form of the operator</param>
        /// <returns>The resolved enum form of the operator</returns>
        private PSCompareOperator GetOperator(string Operator)
        {
            switch (Operator.ToLower())
            {
                case "-eq":
                    return PSCompareOperator.Equals;
                case "-gt":
                    return PSCompareOperator.GreaterThan;
                case "-lt":
                    return PSCompareOperator.LessThan;
                case "-like":
                    return PSCompareOperator.Like;
                case "-match":
                    return PSCompareOperator.Match;
                case "-null":
                    return PSCompareOperator.Null;
                default:
                    throw new ArgumentException("Unknown Operator!");
            }
        }
    }
}

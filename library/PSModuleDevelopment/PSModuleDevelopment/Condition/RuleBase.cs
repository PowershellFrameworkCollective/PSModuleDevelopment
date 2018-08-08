using System;

namespace PSModuleDevelopment.Condition
{
    /// <summary>
    /// The base class rules are built upon.
    /// </summary>
    public abstract class RuleBase
    {
        /// <summary>
        /// The condition the rule is a part of
        /// </summary>
        public Condition Condition { get; set; }

        /// <summary>
        /// The unique id each rule must have.
        /// </summary>
        public abstract Guid Id { get; }

        /// <summary>
        /// The name of the rule
        /// </summary>
        public abstract string[] Names { get; }

        /// <summary>
        /// The name the rule was actually selected by.
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Whether a rule is universal. Common language rules are universal
        /// </summary>
        internal bool IsUniversal
        {
            get { return false; }
        }

        /// <summary>
        /// Parse an input-string to produce the actual condition rule(s) represented by it.
        /// </summary>
        /// <param name="String">The string to parse into rules</param>
        public abstract void Parse(string String);

        /// <summary>
        /// Creates a copy of itself
        /// </summary>
        /// <returns>A copy of itself</returns>
        public abstract RuleBase Clone();

        /// <summary>
        /// Validates the input item against the rule contained
        /// </summary>
        /// <param name="Item">The object to validate</param>
        /// <param name="Condition">The condition the rule is part of</param>
        /// <returns>Whether the item meets the implemented rule's requirements</returns>
        public abstract bool Validate(object Item);

        /// <summary>
        /// Method that overrides the default string output.
        /// </summary>
        /// <returns>The filter string which - when passed to parse - will generate this object</returns>
        public abstract override string ToString();
    }
}

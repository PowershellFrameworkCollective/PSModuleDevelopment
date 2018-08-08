using System;

namespace PSModuleDevelopment.Condition
{
    /// <summary>
    /// Contains information on a rules evaluation.
    /// This is used to offer diagnostics to the system using this condition component.
    /// It is not meant as a means for conditions to return their validation output (which is done using the Validate method).
    /// </summary>
    public class RuleLogEntry
    {
        /// <summary>
        /// THe name of the rule that was evaluated
        /// </summary>
        public string RuleName;

        /// <summary>
        /// The guid of the rule that was evaluated
        /// </summary>
        public Guid RuleId;

        /// <summary>
        /// Whether evaluation was a success
        /// </summary>
        public bool Success;

        /// <summary>
        /// Any message to pass along to the system
        /// </summary>
        public string Message;

        /// <summary>
        /// If an actual exception occured, pass that along also
        /// </summary>
        public Exception Error;

        /// <summary>
        /// Creates a new log entry, containing the result of a rule's evaluation.
        /// </summary>
        /// <param name="RuleName">The name of the rule that was evaluated</param>
        /// <param name="RuleId">The ID of the rule that was evaluated.</param>
        /// <param name="Success">Whether the rule evaluated the target as valid</param>
        /// <param name="Message">Any message to pass to the system</param>
        /// <param name="Error">Any error that occured.</param>
        public RuleLogEntry(string RuleName, Guid RuleId, bool Success, string Message, Exception Error)
        {
            this.RuleName = RuleName;
            this.RuleId = RuleId;
            this.Success = Success;
            this.Message = Message;
            this.Error = Error;
        }
    }
}

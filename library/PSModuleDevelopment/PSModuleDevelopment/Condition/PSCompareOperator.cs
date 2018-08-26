namespace PSModuleDevelopment.Condition
{
    /// <summary>
    /// The powershell operator implemented in the 
    /// </summary>
    public enum PSCompareOperator
    {
        /// <summary>
        /// Don't do anything
        /// </summary>
        None,

        /// <summary>
        /// Equality
        /// </summary>
        Equals,

        /// <summary>
        /// Greater than
        /// </summary>
        GreaterThan,

        /// <summary>
        /// Less than
        /// </summary>
        LessThan,

        /// <summary>
        /// Similarity
        /// </summary>
        Like,

        /// <summary>
        /// Regex Match
        /// </summary>
        Match,

        /// <summary>
        /// Compare with null
        /// </summary>
        Null,
    }
}

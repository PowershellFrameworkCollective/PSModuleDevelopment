namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// The type of parameter a parameter is
    /// </summary>
    public enum ParameterType
    {
        /// <summary>
        /// A plain value parameter - the user may be prompted to fill this in
        /// </summary>
        Value,

        /// <summary>
        /// A script parameter - this logic will be executed to produce text to be inserted
        /// </summary>
        Script,

        /// <summary>
        /// A script that will be executed in the context of the file it was assigned to.
        /// It can be assigned to run before or after creating the file.
        /// </summary>
        FileScript,

        /// <summary>
        /// Prompting the user for multiple choice
        /// </summary>
        MultipleChoice,

        /// <summary>
        /// A value that depends on a given condition
        /// </summary>
        ConditionalValue,
    }
}

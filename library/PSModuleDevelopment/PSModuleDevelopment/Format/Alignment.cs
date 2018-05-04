namespace PSModuleDevelopment.Format
{
    /// <summary>
    /// The way text can be oriented
    /// </summary>
    public enum Alignment
    {
        /// <summary>
        /// No alignment implies the property being not set. Instead, it will use the datatype default orientation.
        /// </summary>
        None,

        /// <summary>
        /// Text is oriented to the left
        /// </summary>
        Left,

        /// <summary>
        /// Text is centered
        /// </summary>
        Center,

        /// <summary>
        /// Text is oriented to the right
        /// </summary>
        Right,

        /// <summary>
        /// There was no alignment specified. Used to not apply changes during transformation
        /// </summary>
        Undefined,
    }
}

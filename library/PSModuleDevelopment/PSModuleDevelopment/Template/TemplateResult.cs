namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// The result object of a template invokation item.
    /// A project template will generate one such object per file/folder
    /// </summary>
    public class TemplateResult
    {
        /// <summary>
        /// Name of the file or folder
        /// </summary>
        public string Name;
        /// <summary>
        /// Path the file or folder should be written to
        /// </summary>
        public string Path;
        /// <summary>
        /// The full, resolved path of the item
        /// </summary>
        public string FullPath;
        /// <summary>
        /// Any content to write (only viable for files)
        /// </summary>
        public object Content;
        /// <summary>
        /// Whether the item to create is a folder or a file
        /// </summary>
        public bool IsFolder;
        /// <summary>
        /// Whether the file is a text-file.
        /// If false, it will be written as a binary file instead.
        /// </summary>
        public bool IsText = true;
    }
}

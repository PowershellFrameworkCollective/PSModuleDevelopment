using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Utility
{
    /// <summary>
    /// The lines of code in a scanned script
    /// </summary>
    [Serializable]
    public class LinesOfCode
    {
        /// <summary>
        /// The number of lines found
        /// </summary>
        public int Count = -1;

        /// <summary>
        /// The path to the file that was scanned
        /// </summary>
        public string Path;

        /// <summary>
        /// Whether the file could be successfully scanned
        /// </summary>
        public bool Success = false;

        /// <summary>
        /// The individual lines that contained code
        /// </summary>
        public int[] Lines;

        /// <summary>
        /// The ast of the script that was scanned
        /// </summary>
        public object Ast;
    }
}

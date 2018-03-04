using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Template
{
    /// <summary>
    /// Class containing information relating to where templates are stored
    /// </summary>
    [Serializable]
    public class Store
    {
        /// <summary>
        /// The name of the store
        /// </summary>
        public string Name;

        /// <summary>
        /// The path the store is pointed to
        /// </summary>
        public string Path;

        /// <summary>
        /// A directory information wrapper to more easily manipulate it
        /// </summary>
        public DirectoryInfo Directory
        {
            get { return new DirectoryInfo(Path); }
            set { }
        }

        /// <summary>
        /// Whether the diretory already exists
        /// </summary>
        public bool Exists
        {
            get { return System.IO.Directory.Exists(Path); }
            set { }
        }

        /// <summary>
        /// Ensures the store actually exists
        /// </summary>
        /// <returns>True if it worked, false otherwise</returns>
        public bool Ensure()
        {
            if (Exists)
                return true;

            try { System.IO.Directory.CreateDirectory(Path); }
            catch { return false; }
            return true;
        }
    }
}

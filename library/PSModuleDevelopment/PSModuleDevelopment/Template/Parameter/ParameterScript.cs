using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;

using PSFramework.Utility;

namespace PSModuleDevelopment.Template.Parameter
{
    /// <summary>
    /// Parameter type executing 
    /// </summary>
    public class ParameterScript : ParameterBase
    {
        /// <summary>
        /// The scriptblock to execute.
        /// Wrapped as string for serialization purposes.
        /// </summary>
        public string ScriptBlock
        {
            get
            {
                if (_ScriptBlock == null)
                    return "";
                return _ScriptBlock.ToString();
            }
            set
            {
                _ScriptBlock = new PsfScriptBlock(System.Management.Automation.ScriptBlock.Create(value));
            }
        }
        private PsfScriptBlock _ScriptBlock;

        /// <summary>
        /// The value of the scriptblock.
        /// Populated by the GetValue() method usually called with the "StartUp" timing.
        /// </summary>
        public string Value;

        /// <summary>
        /// When exactly during the template process should this scriptblock be executed?
        /// </summary>
        public ScriptExecutionTime Timing = ScriptExecutionTime.StartUp;

        /// <summary>
        /// Setting this to true will cause the Invoke-PSMDTemplate command to omit inserting values for the 
        /// </summary>
        public bool SkipInsert;

        /// <summary>
        /// Returns the string value of the scriptblock by executing it!
        /// </summary>
        /// <returns>The string value of the scriptblock by executing it!</returns>
        public override string GetValue()
        {
            if (String.IsNullOrEmpty(Value))
                try { Value = (string)LanguagePrimitives.ConvertTo(_ScriptBlock.InvokeEx(true, true, false), typeof(string)); }
                catch (Exception e) { Value = $"<Error: Scriptblock {Name} failed: {e.Message}>"; }
            return Value;
        }

        /// <summary>
        /// Execute the scriptblock "Just-in-time" during either PreItemCreation or PostItemCreation Timing.
        /// </summary>
        /// <param name="Info">The file/directory info object of the file recently or about to be created</param>
        /// <returns>Returns a string value resulting from the scriptblock to insert</returns>
        public string GetInTimeValue(FileSystemInfo Info)
        {
            try { return (string)LanguagePrimitives.ConvertTo(_ScriptBlock.InvokeEx(Info, true, true, false), typeof(string)); }
            catch (Exception e) { return $"<Error: Scriptblock {Name} failed: {e.Message}>"; }
        }
    }
}

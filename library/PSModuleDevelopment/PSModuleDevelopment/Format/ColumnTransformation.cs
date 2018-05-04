using System;
using System.Collections;
using System.Management.Automation;

namespace PSModuleDevelopment.Format
{
    /// <summary>
    /// A set of transformation rules that determine, wheter a column needs to be updated
    /// </summary>
    public class ColumnTransformation
    {
        /// <summary>
        /// A filter rule, based on the name of the view
        /// </summary>
        public string FilterViewName = "*";

        /// <summary>
        /// A filter rule, based on the name of the column
        /// </summary>
        public string FilterColumnName;

        /// <summary>
        /// Whether the rule should be added as an additional property, if no matching ColumName was found.
        /// </summary>
        public bool Append;

        /// <summary>
        /// A scriptblock to determine column content at runtime
        /// </summary>
        public ScriptBlock ScriptBlock;

        /// <summary>
        /// The label to apply to the column
        /// </summary>
        public string Label;

        /// <summary>
        /// Total width of the column. Anything less than one will be ignored.
        /// </summary>
        public int Width;

        /// <summary>
        /// How to align the text.
        /// </summary>
        public Alignment Alignment = Alignment.Undefined;

        /// <summary>
        /// Empty constructor for manual assembly
        /// </summary>
        public ColumnTransformation()
        {

        }

        /// <summary>
        /// Hashtable constructor, in order to automatically convert&amp;understand input
        /// </summary>
        /// <param name="Table">The hashtable to parse</param>
        public ColumnTransformation(Hashtable Table)
        {
            // FilterViewName
            if (Table.ContainsKey("T"))
                FilterViewName = (string)Table["T"];
            if (Table.ContainsKey("Type"))
                FilterViewName = (string)Table["Type"];
            if (Table.ContainsKey("TypeName"))
                FilterViewName = (string)Table["TypeName"];
            if (Table.ContainsKey("FilterViewName"))
                FilterViewName = (string)Table["FilterViewName"];

            // FilterColumnName
            if (Table.ContainsKey("C"))
                FilterColumnName = (string)Table["C"];
            if (Table.ContainsKey("Column"))
                FilterColumnName = (string)Table["Column"];
            if (Table.ContainsKey("Name"))
                FilterColumnName = (string)Table["Name"];
            if (Table.ContainsKey("P"))
                FilterColumnName = (string)Table["P"];
            if (Table.ContainsKey("Property"))
                FilterColumnName = (string)Table["Property"];
            if (Table.ContainsKey("PropertyName"))
                FilterColumnName = (string)Table["PropertyName"];

            // Append
            if (Table.ContainsKey("A"))
                Append = (bool)Table["A"];
            if (Table.ContainsKey("Append"))
                Append = (bool)Table["Append"];

            // ScriptBlock
            if (Table.ContainsKey("S"))
                ScriptBlock = (ScriptBlock)Table["S"];
            if (Table.ContainsKey("Script"))
                ScriptBlock = (ScriptBlock)Table["Script"];
            if (Table.ContainsKey("ScriptBlock"))
                ScriptBlock = (ScriptBlock)Table["ScriptBlock"];

            // Label
            if (Table.ContainsKey("L"))
                Label = (string)Table["L"];
            if (Table.ContainsKey("Label"))
                Label = (string)Table["Label"];

            // Width
            if (Table.ContainsKey("W"))
                Width = (int)Table["W"];
            if (Table.ContainsKey("Width"))
                Width = (int)Table["Width"];

            // Alignment
            string align = "";
            if (Table.ContainsKey("Align"))
                align = (string)Table["Align"];
            if (Table.ContainsKey("Alignment"))
                align = (string)Table["Alignment"];
            if (!String.IsNullOrEmpty(align))
                Alignment = (Alignment)Enum.Parse(typeof(Alignment), align, false);
        }

        /// <summary>
        /// Applies changes to column
        /// </summary>
        /// <param name="Item">The column to affect</param>
        public void Apply(Column Item)
        {
            if (ScriptBlock != null)
                Item.ScriptBlock = ScriptBlock;
            if (!String.IsNullOrEmpty(Label))
                Item.Label = Label;
            if (Width > 0)
                Item.Width = Width;
            if (Alignment != Alignment.Undefined)
                Item.Alignment = Alignment;
        }
    }
}

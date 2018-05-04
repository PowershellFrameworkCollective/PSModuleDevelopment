using System;
using System.Collections.Generic;
using System.Management.Automation;

namespace PSModuleDevelopment.Format
{
    /// <summary>
    /// A column in a format table definition
    /// </summary>
    [Serializable]
    public class Column : IComparable
    {
        /// <summary>
        /// The name to select a property by. Ignored if a scriptblock is set.
        /// </summary>
        public string PropertyName;

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
        /// Name to show and sort with. Used for sorting and to explicitly assign positions.
        /// </summary>
        public string SortableName
        {
            get
            {
                if (!String.IsNullOrEmpty(Label))
                    return Label;
                return PropertyName;
            }
            set { }
        }

        /// <summary>
        /// How to align the text.
        /// </summary>
        public Alignment Alignment = Alignment.None;

        /// <summary>
        /// The text to use in the definition's header
        /// </summary>
        public string TextHeader
        {
            get
            {
                string baseIndent = "                    ";
                bool needExpand = false;
                if ((!String.IsNullOrEmpty(Label)) || (Width > 0) || (Alignment != Alignment.None))
                    needExpand = true;

                if (!needExpand)
                    return String.Format("{0}<TableColumnHeader/>", baseIndent);

                List<string> tempString = new List<string>();
                tempString.Add(String.Format("{0}<TableColumnHeader>", baseIndent));
                if (!String.IsNullOrEmpty(Label))
                    tempString.Add(String.Format("{0}    <Label>{1}</Label>", baseIndent, Label));
                if (Width > 0)
                    tempString.Add(String.Format("{0}    <Width>{1}</Width>", baseIndent, Width));
                if (Alignment != Alignment.None)
                    tempString.Add(String.Format("{0}    <Alignment>{1}</Alignment>", baseIndent, Alignment));
                tempString.Add(String.Format("{0}</TableColumnHeader>", baseIndent));

                return String.Join("\n", tempString);
            }
            set { }
        }

        /// <summary>
        /// The text to use in the definition's body
        /// </summary>
        public string TextBody
        {
            get
            {
                string baseIndent = "                            ";

                List<string> tempString = new List<string>();

                tempString.Add(String.Format("{0}<TableColumnItem>", baseIndent));

                if (ScriptBlock == null)
                    tempString.Add(String.Format("{0}    <PropertyName>{1}</PropertyName>", baseIndent, PropertyName));
                else
                {
                    tempString.Add(String.Format("{0}    <ScriptBlock>", baseIndent));
                    tempString.Add(ScriptBlock.ToString());
                    tempString.Add(String.Format("{0}    </ScriptBlock>", baseIndent));
                }
                tempString.Add(String.Format("{0}</TableColumnItem>", baseIndent));

                return String.Join("\n", tempString);
            }
            set { }
        }

        /// <summary>
        /// Compares one column with another
        /// </summary>
        /// <param name="Item">The item to compare the current one with</param>
        /// <returns>-1, 0 or 1</returns>
        public int CompareTo(object Item)
        {
            Column tempItem = Item as Column;
            if (tempItem == null)
                throw new InvalidOperationException("Columns can only be compared with each other!");

            return SortableName.CompareTo(tempItem.SortableName);
        }
    }
}

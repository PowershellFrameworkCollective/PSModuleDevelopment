using PSModuleDevelopment.Utility;
using System;
using System.Collections.Generic;

namespace PSModuleDevelopment.Format
{
    /// <summary>
    /// A Format Table definition
    /// </summary>
    [Serializable]
    public class TableDefinition : ViewDefinitionBase
    {
        /// <summary>
        /// Whether to automatically size the column width
        /// </summary>
        public bool Autosize = true;

        /// <summary>
        /// List of columns to 
        /// </summary>
        public List<Column> Columns = new List<Column>();

        /// <summary>
        /// The string representation of a format table fragment.
        /// </summary>
        public override string TextDefinition
        {
            get
            {
                string baseIndent = "        ";

                List<string> tempString = new List<string>();
                tempString.Add(String.Format("{0}<!-- {1} -->", baseIndent, Name));
                tempString.Add(String.Format("{0}<View>", baseIndent));
                tempString.Add(String.Format("{0}    <Name>{1}</Name>", baseIndent, Name));
                tempString.Add(String.Format("{0}    <ViewSelectedBy>", baseIndent));
                foreach (string name in ViewSelectedByType)
                    tempString.Add(String.Format("{0}        <TypeName>{1}</TypeName>", baseIndent, name));
                foreach (string name in ViewSelectedBySet)
                    tempString.Add(String.Format("{0}        <SelectionSetName>{1}</SelectionSetName>", baseIndent, name));
                tempString.Add(String.Format("{0}    </ViewSelectedBy>", baseIndent));
                tempString.Add(String.Format("{0}    <TableControl>", baseIndent));
                if (Autosize)
                    tempString.Add(String.Format("{0}        <AutoSize/>", baseIndent));
                tempString.Add(String.Format("{0}        <TableHeaders>", baseIndent));
                foreach (Column item in Columns)
                    tempString.Add(item.TextHeader);
                tempString.Add(String.Format("{0}        </TableHeaders>", baseIndent));
                tempString.Add(String.Format("{0}        <TableRowEntries>", baseIndent));
                tempString.Add(String.Format("{0}            <TableRowEntry>", baseIndent));
                tempString.Add(String.Format("{0}                <TableColumnItems>", baseIndent));
                foreach (Column item in Columns)
                    tempString.Add(item.TextBody);
                tempString.Add(String.Format("{0}                </TableColumnItems>", baseIndent));
                tempString.Add(String.Format("{0}            </TableRowEntry>", baseIndent));
                tempString.Add(String.Format("{0}        </TableRowEntries>", baseIndent));
                tempString.Add(String.Format("{0}    </TableControl>", baseIndent));
                tempString.Add(String.Format("{0}</View>", baseIndent));
                return String.Join("\n", tempString);
            }
            set { }
        }

        #region Methods
        /// <summary>
        /// Sets the columns to this specified order, using the SortableName property to assign.
        /// Not listed properties will be moved to the end of the list.
        /// </summary>
        /// <param name="Names">The names to sort by</param>
        public void SetColumnOrder(string[] Names)
        {
            List<Column> tempList = new List<Column>();

            foreach (string name in Names)
                foreach (Column item in Columns)
                    if ((name.ToLower() == item.SortableName.ToLower()) && (!tempList.Contains(item)))
                        tempList.Add(item);
            foreach (Column item in Columns)
                if (!tempList.Contains(item))
                    tempList.Add(item);

            Columns = tempList;
        }

        /// <summary>
        /// Applies a transformation rule to the columns stored in this view
        /// </summary>
        /// <param name="Transform">The transformation rule to apply</param>
        public void TransformColumn(ColumnTransformation Transform)
        {
            if (!UtilityHost.IsLike(Name, Transform.FilterViewName))
                return;

            bool applied = false;

            foreach (Column column in Columns)
            {
                if ((!String.IsNullOrEmpty(Transform.FilterColumnName)) && (UtilityHost.IsLike(column.SortableName, Transform.FilterColumnName)))
                {
                    Transform.Apply(column);
                    applied = true;
                }
            }

            if (!applied && Transform.Append && (Transform.ScriptBlock != null))
            {
                Column tempColumn = new Column();
                Transform.Apply(tempColumn);
                Columns.Add(tempColumn);
            }
        }

        /// <summary>
        /// The default string representation of a tableview format definition
        /// </summary>
        /// <returns>The default string representation of a tableview format definition</returns>
        public override string ToString()
        {
            return TextDefinition;
        }
        #endregion Methods
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSModuleDevelopment.Utility
{
    /// <summary>
    /// Object containing information 
    /// </summary>
    public class TextHeader
    {
        /// <summary>
        /// The text of the header
        /// </summary>
        public string Text { get; set; }

        /// <summary>
        /// The number of lines the header text has
        /// </summary>
        public int LinesOfText
        {
            get
            {
                return Text.Split('\n').Length;
            }
        }

        /// <summary>
        /// The maximum width any line of text has.
        /// </summary>
        public int WidthOfText
        {
            get
            {
                int result = 0;
                foreach (string line in Text.Split('\n'))
                    if (line.Length > result)
                        result = line.Length;
                return result;
            }
        }

        /// <summary>
        /// The symbol of the left top corner
        /// </summary>
        public string CornerLT = "#";
        /// <summary>
        /// The symbol of the right top corner
        /// </summary>
        public string CornerRT = "#";
        /// <summary>
        /// The symbol of the left bottom corner
        /// </summary>
        public string CornerLB = "#";
        /// <summary>
        /// The symbol of the right bottom corner
        /// </summary>
        public string CornerRB = "#";
        /// <summary>
        /// The symbol of the right border
        /// </summary>
        public string BorderRight = "#";
        /// <summary>
        /// The symbol of the left border
        /// </summary>
        public string BorderLeft = "#";
        /// <summary>
        /// The symbol of the top border
        /// </summary>
        public string BorderTop = "-";
        /// <summary>
        /// The symbol of the bottom border
        /// </summary>
        public string BorderBottom = "-";

        /// <summary>
        /// Whether the header should be as wide as the window running the code
        /// </summary>
        public bool MaxWidth = true;

        /// <summary>
        /// How wide should the header be, if it isn't set to max. Anything shorter than the text width will be ignored
        /// </summary>
        public int Width = -1;

        /// <summary>
        /// How the text should be aligned within the header
        /// </summary>
        public TextAlignment TextAlignment = TextAlignment.Center;

        /// <summary>
        /// Whether the text should be padded on the side it is aligned to
        /// </summary>
        public int Padding;

        public TextHeader(string Text)
        {
            this.Text = Text;
        }

        public override string ToString()
        {
            StringBuilder result = new StringBuilder();

            // Process Width
            int effectivePadding = 0;
            if (TextAlignment != TextAlignment.Center)
                effectivePadding = Padding;

            int width = Width;
            if (MaxWidth)
                width = UtilityHost.RawUI.WindowSize.Width;
            if ((WidthOfText + effectivePadding + 2 + BorderLeft.Length + BorderRight.Length) > width)
                width = WidthOfText + effectivePadding + 2 + BorderLeft.Length + BorderRight.Length;
            int effectiveContentWidth = width - 2 - BorderLeft.Length - BorderRight.Length;

            // Process Top Line
            result = result.Append(CornerLT);
            for (int n = 0; n < (effectiveContentWidth + 2); n++)
                result = result.Append(BorderTop);
            result = result.Append(CornerRT + "\n");

            // Process Content
            foreach (string line in Text.Split('\n'))
            {
                result = result.Append(BorderLeft + " ");
                int spaceLeft = 0;
                int spaceRight = 0;
                if (TextAlignment == TextAlignment.Left)
                {
                    spaceLeft += Padding;
                    spaceRight = effectiveContentWidth - line.Length - spaceLeft;
                }
                else if (TextAlignment == TextAlignment.Right)
                {
                    spaceRight += Padding;
                    spaceLeft = effectiveContentWidth - line.Length - spaceRight;
                }
                else
                {
                    spaceLeft = (effectiveContentWidth - line.Length) / 2;
                    spaceRight = effectiveContentWidth - line.Length - spaceLeft;
                }

                result = result.Append(' ', spaceLeft);
                result = result.Append(line);
                result = result.Append(' ', spaceRight);
                result = result.Append(" " + BorderRight + "\n");
            }

            // Process Bottom Line
            result = result.Append(CornerLB);
            for (int n = 0; n < (effectiveContentWidth + 2); n++)
                result = result.Append(BorderBottom);
            result = result.Append(CornerRB);

            return result.ToString();
        }
    }
}

function New-PSMDHeader
{
<#
	.SYNOPSIS
		Generates a header wrapping around text.
	
	.DESCRIPTION
		Generates a header wrapping around text.
		The output is an object that contains the configuration options to generate a header.
		Use its ToString() method (or cast it to string) to generate the header.
	
	.PARAMETER Text
		The text to wrap into a header.
		Can handle multiline text.
		When passing a list of strings, each string will be wrapped into its own header.
	
	.PARAMETER BorderBottom
		The border used for the bottom of the frame. Use a single letter, such as "-"
	
	.PARAMETER BorderLeft
		The border used for the left side of the frame.
	
	.PARAMETER BorderRight
		The border used for the right side of the frame.
	
	.PARAMETER BorderTop
		The border used for the top of the frame. Use a single letter, such as "-"
	
	.PARAMETER CornerLB
		The symbol used for the left-bottom corner of the frame
	
	.PARAMETER CornerLT
		The symbol used for the left-top corner of the frame
	
	.PARAMETER CornerRB
		The symbol used for the right-bottom corner of the frame
	
	.PARAMETER CornerRT
		The symbol used for the right-top corner of the frame
	
	.PARAMETER MaxWidth
		Whether to align the frame's total width to the window width.
	
	.PARAMETER Padding
		Whether the text should be padded.
		Only applies to left/right aligned text.
	
	.PARAMETER TextAlignment
		Default: Center
		Whether the text should be aligned left, center or right.
	
	.PARAMETER Width
		Total width of the header.
		Defaults to entire screen.
	
	.EXAMPLE
		PS C:\> New-PSMDHeader -Text 'Example'
	
		Will create a header labeled 'Example' that spans the entire screen.
	
	.EXAMPLE
		PS C:\> New-PSMDHeader -Text 'Example' -Width 80
	
		Will create a header labeled 'Example' with a total width of 80:
		 #----------------------------------------------------------------------------#
		 #                                  Example                                   #
		 #----------------------------------------------------------------------------#
	
	.EXAMPLE
		PS C:\> New-PSMDHeader -Text 'Example' -Width 80 -BorderLeft " |" -BorderRight "| " -CornerLB " \" -CornerLT " /" -CornerRB "/" -CornerRT "\"
	
		Will create a header labeled "Example with a total width of 80 and some custom border lines:
		 /----------------------------------------------------------------------------\
		 |                                  Example                                   |
		 \----------------------------------------------------------------------------/
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[string[]]
		$Text,
		
		[string]
		$BorderBottom = "-",
		
		[string]
		$BorderLeft = " #",
		
		[string]
		$BorderRight = "# ",
		
		[string]
		$BorderTop = "-",
		
		[string]
		$CornerLB = " #",
		
		[string]
		$CornerLT = " #",
		
		[string]
		$CornerRB = "# ",
		
		[string]
		$CornerRT = "# ",
		
		[switch]
		$MaxWidth,
		
		[int]
		$Padding = 0,
		
		[PSModuleDevelopment.Utility.TextAlignment]
		$TextAlignment = "Center",
		
		[int]
		$Width = $Host.UI.RawUI.WindowSize.Width
	)
	
	process
	{
		foreach ($line in $Text)
		{
			$header = New-Object PSModuleDevelopment.Utility.TextHeader($line)
			
			$header.BorderBottom = $BorderBottom
			$header.BorderLeft = $BorderLeft
			$header.BorderRight = $BorderRight
			$header.BorderTop = $BorderTop
			$header.CornerLB = $CornerLB
			$header.CornerLT = $CornerLT
			$header.CornerRB = $CornerRB
			$header.CornerRT = $CornerRT
			$header.Padding = $Padding
			$header.TextAlignment = $TextAlignment
			
			if ((Test-PSFParameterBinding -ParameterName Width) -and (Test-PSFParameterBinding -ParameterName MaxWidth -Not))
			{
				$header.MaxWidth = $false
				$header.Width = $Width
			}
			else
			{
				$header.MaxWidth = $MaxWidth
				$header.Width = $Width
			}
			
			$header
		}
	}
}
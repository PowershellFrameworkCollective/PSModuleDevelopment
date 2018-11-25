function Show-PSMDSyntax {
    <#
    .SYNOPSIS
        Validate or show parameter set details with colored output

    .DESCRIPTION
        Analyze a function and it's parameters

        The cmdlet / function is capable of validating a string input with function name and parameters

    .PARAMETER CommandText
        The string that you want to analyze

        If there is parameter value present, you have to use the opposite quote strategy to encapsulate the string correctly

        E.g. for double quotes
        -CommandText 'New-Item -Path "c:\temp\newfile.txt"'
        
        E.g. for single quotes
        -CommandText "New-Item -Path 'c:\temp\newfile.txt'"

    .PARAMETER Mode
        The operation mode of the cmdlet / function

        Valid options are:
        - Validate
        - ShowParameters

    .PARAMETER Legend
        Include a legend explaining the color mapping

    .EXAMPLE
        PS C:\> Show-PSMDSyntax -CommandText "New-Item -Path 'c:\temp\newfile.txt'"

        This will validate all the parameters that have been passed to the Import-D365Bacpac cmdlet.
        All supplied parameters that matches a parameter will be marked with an asterisk.
        
    .EXAMPLE
        PS C:\> Show-PSMDSyntax -CommandText "New-Item" -Mode "ShowParameters"

        This will display all the parameter sets and their individual parameters.

    .NOTES
        Author: Mötz Jensen (@Splaxi)
        Twitter: https://twitter.com/splaxi
        Original github project: https://github.com/d365collaborative/d365fo.tools

#>
    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $CommandText,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateSet('Validate', 'ShowParameters')]
        [string] $Mode = 'Validate',

        [switch] $Legend
    )

    $commonParameters = 'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable', 'Confirm', 'WhatIf'

    $colorParmsNotFound = Get-PSFConfigValue -FullName "PSModuleDevelopment.ShowSyntax.ParmsNotFound"
    $colorCommandName = Get-PSFConfigValue -FullName "PSModuleDevelopment.ShowSyntax.CommandName"
    $colorMandatoryParam = Get-PSFConfigValue -FullName "PSModuleDevelopment.ShowSyntax.MandatoryParam"
    $colorNonMandatoryParam = Get-PSFConfigValue -FullName "PSModuleDevelopment.ShowSyntax.NonMandatoryParam"
    $colorFoundAsterisk = Get-PSFConfigValue -FullName "PSModuleDevelopment.ShowSyntax.FoundAsterisk"
    $colorNotFoundAsterisk = Get-PSFConfigValue -FullName "PSModuleDevelopment.ShowSyntax.NotFoundAsterisk"
    $colParmValue = Get-PSFConfigValue -FullName "PSModuleDevelopment.ShowSyntax.ParmValue"

    #Match to find the command name: Non-Whitespace until the first whitespace
    $commandMatch = ($CommandText | Select-String '\S+\s*').Matches

    if ($null -eq $commandMatch) {
        Write-PSFMessage -Level Host -Message "The function was unable to extract a valid command name from the supplied command text. Please try again."
        Stop-PSFFunction -Message "Stopping because of missing command name."
        return
    }

    $commandName = $commandMatch.Value.Trim()
 
    $res = Get-Command $commandName -ErrorAction Ignore
 
    if ($null -eq $res) {
        Write-PSFMessage -Level Host -Message "The function was unable to get the help of the command. Make sure that the command name is valid and try again."
        Stop-PSFFunction -Message "Stopping because command name didn't return any help."
        return
    }
 
    $sbHelp = New-Object System.Text.StringBuilder
    $sbParmsNotFound = New-Object System.Text.StringBuilder
 
    switch ($Mode) {
        "Validate" {
            #Match to find the parameters: Whitespace Dash Non-Whitespace
            $inputParameterMatch = ($CommandText | Select-String '\s{1}[-]\S+' -AllMatches).Matches
                     
            if (-not ($null -eq $inputParameterMatch)) {
                $inputParameterNames = $inputParameterMatch.Value.Trim("-", " ")
                Write-PSFMessage -Level Verbose -Message "All input parameters - $($inputParameterNames -join ",")" -Target ($inputParameterNames -join ",")
            }
            else {
                Write-PSFMessage -Level Host -Message "The function was unable to extract any parameters from the supplied command text. Please try again."
                Stop-PSFFunction -Message "Stopping because of missing input parameters."
                return
            }
 
            $availableParameterNames = (Get-Command $commandName).Parameters.keys | Where-Object {$commonParameters -NotContains $_}
            Write-PSFMessage -Level Verbose -Message "Available parameters - $($availableParameterNames -join ",")" -Target ($availableParameterNames -join ",")

            $inputParameterNotFound = $inputParameterNames | Where-Object {$availableParameterNames -NotContains $_}
 
            if ($inputParameterNotFound.Length -gt 0) {
                $null = $sbParmsNotFound.AppendLine("Parameters that <c='em'>don't exists</c>")
                $inputParameterNotFound | ForEach-Object {
                    $null = $sbParmsNotFound.AppendLine("<c='$colorParmsNotFound'>$($_)</c>")
                }
            }
            
            foreach ($parmSet in (Get-Command $commandName).ParameterSets) {
                $sb = New-Object System.Text.StringBuilder
                $null = $sb.AppendLine("ParameterSet Name: <c='em'>$($parmSet.Name)</c> - Validated List")
                $null = $sb.Append("<c='$colorCommandName'>$commandName </c>")
 
                $parmSetParameters = $parmSet.Parameters | Where-Object name -NotIn $commonParameters
         
                foreach ($parameter in $parmSetParameters) {
                    $parmFoundInCommandText = $parameter.Name -In $inputParameterNames
                             
                    $color = "$colorNonMandatoryParam"
         
                    if ($parameter.IsMandatory -eq $true) { $color = "$colorMandatoryParam" }
         
                    $null = $sb.Append("<c='$color'>-$($parameter.Name)</c>")
         
                    if ($parmFoundInCommandText) {
                        $null = $sb.Append("<c='$colorFoundAsterisk'>* </c>")
                    }
                    elseif ($parameter.IsMandatory -eq $true) {
                        $null = $sb.Append("<c='$colorNotFoundAsterisk'>* </c>")
                    }
                    else {
                        $null = $sb.Append(" ")
                    }
         
                    if (-not ($parameter.ParameterType -eq [System.Management.Automation.SwitchParameter])) {
                        $null = $sb.Append("<c='$colParmValue'>PARAMVALUE </c>")
                    }
                }
         
                $null = $sb.AppendLine("")
                Write-PSFHostColor -String "$($sb.ToString())"
            }
 
            $null = $sbHelp.AppendLine("")
            $null = $sbHelp.AppendLine("<c='$colorParmsNotFound'>$colorParmsNotFound</c> = Parameter not found")
            $null = $sbHelp.AppendLine("<c='$colorCommandName'>$colorCommandName</c> = Command Name")
            $null = $sbHelp.AppendLine("<c='$colorMandatoryParam'>$colorMandatoryParam</c> = Mandatory Parameter")
            $null = $sbHelp.AppendLine("<c='$colorNonMandatoryParam'>$colorNonMandatoryParam</c> = Optional Parameter")
            $null = $sbHelp.AppendLine("<c='$colParmValue'>$colParmValue</c> = Parameter value")
            $null = $sbHelp.AppendLine("<c='$colorFoundAsterisk'>*</c> = Parameter was filled")
            $null = $sbHelp.AppendLine("<c='$colorNotFoundAsterisk'>*</c> = Mandatory missing")
        }
 
        "ShowParameters" {
            foreach ($parmSet in (Get-Command $commandName).ParameterSets) {
                # (Get-Command $commandName).ParameterSets | ForEach-Object {
                $sb = New-Object System.Text.StringBuilder
                $null = $sb.AppendLine("ParameterSet Name: <c='em'>$($parmSet.Name)</c> - Parameter List")
                $null = $sb.Append("<c='$colorCommandName'>$commandName </c>")
 
                $parmSetParameters = $parmSet.Parameters | Where-Object name -NotIn $commonParameters
         
                foreach ($parameter in $parmSetParameters) {
                    # $parmSetParameters | ForEach-Object {
                    $color = "$colorNonMandatoryParam"
         
                    if ($parameter.IsMandatory -eq $true) { $color = "$colorMandatoryParam" }
         
                    $null = $sb.Append("<c='$color'>-$($parameter.Name) </c>")
         
                    if (-not ($parameter.ParameterType -eq [System.Management.Automation.SwitchParameter])) {
                        $null = $sb.Append("<c='$colParmValue'>PARAMVALUE </c>")
                    }
                }
         
                $null = $sb.AppendLine("")
                Write-PSFHostColor -String "$($sb.ToString())"
            }
 
            $null = $sbHelp.AppendLine("")
            $null = $sbHelp.AppendLine("<c='$colorCommandName'>$colorCommandName</c> = Command Name")
            $null = $sbHelp.AppendLine("<c='$colorMandatoryParam'>$colorMandatoryParam</c> = Mandatory Parameter")
            $null = $sbHelp.AppendLine("<c='$colorNonMandatoryParam'>$colorNonMandatoryParam</c> = Optional Parameter")
            $null = $sbHelp.AppendLine("<c='$colParmValue'>$colParmValue</c> = Parameter value")
        }
        Default {}
    }
 
    if ($sbParmsNotFound.ToString().Trim().Length -gt 0) {
        Write-PSFHostColor -String "$($sbParmsNotFound.ToString())"
    }
 
    if ($Legend) {
        Write-PSFHostColor -String "$($sbHelp.ToString())"
    }
}
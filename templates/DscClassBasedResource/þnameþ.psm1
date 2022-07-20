enum Ensure
{
    Present
    Absent
}
      
# Support for DSC v3, or Azure Guest Configuration
class Reason
{
    [DscProperty()]
    [string] $Code
        
    [DscProperty()]
    [string] $Phrase
}

function Get-Resource
{
    [OutputType([hashtable])]
    [CmdletBinding()]
    param
    (
    )

    $reasonList = @()

    if ($Ensure -eq 'Present' -and -not $successfulTests)
    {
        $reasonList += @{
            Code   = 'þnameþ:þnameþ:SomethingAwfulHappened'
            Phrase = "Extend the reasonList with all errors"
        }
    }
   
    return @{
        Reasons         = $reasonList
    }
}

function Set-Resource
{
    [CmdletBinding()]
    param
    (
    )

}

function Test-Resource
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (

    )
    
    return $true
}
      
[DscResource()]
class þnameþ
{
    [DscProperty(Key)] [string] $YourKeyProperty
    [DscProperty(Mandatory)] [string] $YourRequiredProperty
    [DscProperty()] [string[]] $YourStandardProperty
    [DscProperty()] [Ensure] $Ensure # Usually a good idea to include
    [DscProperty(NotConfigurable)] [Reason[]] $Reasons # Reserved for Azure Guest Configuration
   
    þnameþ ()
    {
        $this.Ensure = 'Present' # Set up defaults
    }

    [þnameþ] Get()
    {
        $parameter = $this.GetConfigurableDscProperties()
        return (Get-Resource @parameter)        
    }

    [void] Set()
    {
        $parameter = $this.GetConfigurableDscProperties()
        Set-Resource @parameter        
    }

    [bool] Test()
    {
        $parameter = $this.GetConfigurableDscProperties()
        return (Test-Resource @parameter)
    }

    [Hashtable] GetConfigurableDscProperties()
    {
        # This method returns a hashtable of properties with two special workarounds
        # The hashtable will not include any properties marked as "NotConfigurable"
        # Any properties with a ValidateSet of "True","False" will beconverted to Boolean type
        # The intent is to simplify splatting to functions
        # Source: https://gist.github.com/mgreenegit/e3a9b4e136fc2d510cf87e20390daa44
        $DscProperties = @{}
        foreach ($property in [þnameþ].GetProperties().Name)
        {
            # Checks if "NotConfigurable" attribute is set
            $notConfigurable = [þnameþ].GetProperty($property).GetCustomAttributes($false).Where({ $_ -is [System.Management.Automation.DscPropertyAttribute] }).NotConfigurable
            if (!$notConfigurable)
            {
                $value = $this.$property
                # Gets the list of valid values from the ValidateSet attribute
                $validateSet = [þnameþ].GetProperty($property).GetCustomAttributes($false).Where({ $_ -is [System.Management.Automation.ValidateSetAttribute] }).ValidValues
                if ($validateSet)
                {
                    # Workaround for boolean types
                    if ($null -eq (Compare-Object @('True', 'False') $validateSet))
                    {
                        $value = [System.Convert]::ToBoolean($this.$property)
                    }
                }
                # Add property to new
                $DscProperties.add($property, $value)
            } 
        }
        return $DscProperties
    }
}

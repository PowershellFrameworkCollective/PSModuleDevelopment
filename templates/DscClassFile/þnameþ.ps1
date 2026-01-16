[DscResource()]
class þnameþ {
	#region DSC Properties
	<#
	The properties you can define in configuration settings.
	The [DscProperty(...)] attribute has a few possible values:
	- <empty>: Nothing specified makes this an optional property you can leave empty when defining the configuration setting.
	- Mandatory: A Property that MUST be set when defining the configuration setting.
	- Key: The property is considered as the identifier for the resource modified. It is mandatory AND there cannot be multiple configuration entries with the same value for this property!
	- NotConfigurable: ReadOnly property. Mostly used for integration into Azure Guest Configurations

	Example Properties:

    [DscProperty(Key)]
    [string]$Path

    [DscProperty(Mandatory)]
    [string]$Text

    [DscProperty(Mandatory)]
    [Ensure]$Ensure
	#>

	[DscProperty(NotConfigurable)]
	[Reason[]] $Reasons # Reserved for Azure Guest Configuration
	#endregion DSC Properties

    [void]Set() {
        # Apply Desired State
    }

    [þnameþ]Get() {
		# Return current actual state
    }

    [bool]Test() {
        # Check whether current state = desired state
    }

	[Hashtable] GetConfigurableDscProperties()
    {
        # This method returns a hashtable of properties with two special workarounds
        # The hashtable will not include any properties marked as "NotConfigurable"
        # Any properties with a ValidateSet of "True","False" will beconverted to Boolean type
        # The intent is to simplify splatting to functions
        # Source: https://gist.github.com/mgreenegit/e3a9b4e136fc2d510cf87e20390daa44
        $dscProperties = @{}
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
                $dscProperties.add($property, $value)
            }
        }
        return $dscProperties
    }
}
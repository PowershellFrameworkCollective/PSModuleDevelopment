# Purpose

The PSModuleDevelopment module is designed to provide tools that help with - big surprise incoming - module development.
This attempts to help with:
 - Speeding up iterative procedures, especially reinitiating tests runs
 - Debugging Execution
 - Development Research & Analytics
 - Miscellaneous other things

# Alias Warning

This module actually ships with convenience aliases.

Generally, modules should leave aliases like that to the user's preference.
However, in this instance, the main purpose is to optimize the performance of the developer, which requires the use of aliases.

Due to this, the decision was made to ship the module with aliases.

# Configuration Notice

This module uses the PSFramework for configuration management (and many other things).
Run `Get-PSFConfig -Module PSModuleDevelopment` in order to retrieve the full list of configurations set.

# Profile notice

Some features of this module assume, that it is in the profile and automtically imported on console start.
It is still possible to profit from the module without this, but it is highly recommended to add the module import to the PowerShell profile
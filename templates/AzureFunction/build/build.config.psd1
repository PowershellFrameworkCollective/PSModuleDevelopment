@{
	TimerTrigger = @{
		# Default Schedule for timed executions
		Schedule = '0 5 * * * *'

		# Different Schedules for specific timed endpoints
		ScheduleOverrides = @{
			# 'Update-Whatever' = '0 5 12 * * *'
		}
	}

	HttpTrigger = @{
		<#
		AuthLevels:
		https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-http-webhook-trigger?tabs=python-v2%2Cisolated-process%2Cnodejs-v4%2Cfunctionsv2&pivots=programming-language-csharp#http-auth

		anonymous: No Token needed (combine with Identity Provider for Entra ID auth without also needing a token)
		function: (default) Require a function-endpoint-specific token with the request
		admin: Require a Function-App-global admin token (master key) for the request
		#>
		AuthLevel = 'function'
		AuthLevelOverrides = @{
			# 'Set-Foo' = 'anonymous'
		}
	}
}
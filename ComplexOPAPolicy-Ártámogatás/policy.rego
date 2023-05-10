package gasSupport

import future.keywords.contains
import future.keywords.if
import future.keywords.in

default policyParameters := {
	"thresholds": {
		"rollingConsumption": {
			"mid": 10,
			"high": 25,
		},
		"currentSaving": {
			"low": 10,
			"mid": 15,
			"high": 20,
		},
	},
	"supports": {
		#rows: rollingConsumption
		#cols: currentSaving
		"low": {"low": ["percent", 10], "mid": ["percent", 10], "high": ["percent", 10]},
		"mid": {"low": ["percent", 10], "mid": ["percent", 10], "high": ["percent", 10]},
		"high": {"low": ["percent", 10], "mid": ["percent", 10], "high": ["percent", 10]},
	},
	"socialSupports": {"ChangedWorkcapacity": {
		"credentialType": "ChangedWorkcapacityCredential",
		"support": ["nominal", 1000],
	}},
}


pastConsumptionCred := cred if {
	cred := input.credentialData.credentials[_]
	cred.type[_] == "ProofOfActualGasConsumptionCredential"
}
consumptionClass := "high" if {
	policyParameters.thresholds.rollingConsumption.high < currentConsumption
}

else := "mid" if {
	policyParameters.thresholds.rollingConsumption.mid < currentConsumption
}

else := "low"
currentConsumption := input.parameter.consumption

currentSavingsClass := "high" if {
	policyParameters.thresholds.currentSaving.high < pastConsumptionCred.consumption - currentConsumption
}

else := "mid" if {
	policyParameters.thresholds.currentSaving.mid < pastConsumptionCred.consumption - currentConsumption
}

else := "low" if {
	policyParameters.thresholds.currentSaving.low < pastConsumptionCred.consumption - currentConsumption
}

applySupport(support, base) := base * multiplier if {
	[type, percent] := support
	type == "percent"
	multiplier := 1 - (0.01 * percent)
}

applySupport(support, base) := base - value if {
	[type, value] := support
	type == "nominal"
}



currentPrice := input.parameter.price

paymentBase := res if {
	currentPrice.unit == "HUF"
	res := currentConsumption * currentPrice.amount
}

paymentAfterSavings := applySupport(policyParameters.supports[consumptionClass][currentSavingsClass], paymentBase)

socialSuports contains [cred, support] if {
	cred := input.credentialData.credentials[_]
	cred.type[_] == policyParameters.socialSupports[_].credentialType
	support := policyParameters.socialSupports[_]
}

default allow := false

#allow {
#	input.UserInput.expectedAmount == supportAmount
#}

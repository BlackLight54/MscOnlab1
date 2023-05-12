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

rollingConsumption := value if {
	pastConsumptionCreds := [pastConsumptionCred |
		some cred in input.credentialData.credentials
		cred.type[_] == "ProofOfActualGasConsumptionCredential"
		[currentYear, currentMonth, _] := time.date(time.now_ns())
		months := numbers.range(1, 12)
		month := months[x]
		((((currentYear * 12) + currentMonth) - 1) - 12) + month == (to_number(cred.year) * 12) + to_number(cred.month)
		pastConsumptionCred := cred
	]
	count(pastConsumptionCreds) == 12
	pastConsumptionValues := [value | value := pastConsumptionCreds[_].consumption]
	count(pastConsumptionValues) == 12
	value := sum(pastConsumptionValues) / count(pastConsumptionCreds)
}
currentConsumption := input.parameter.consumption

#assign consumption class based on rolling consumption
consumptionClass := "high" if {
	policyParameters.thresholds.rollingConsumption.high < rollingConsumption
}

else := "mid" if {
	policyParameters.thresholds.rollingConsumption.mid < rollingConsumption
}

else := "low"


#assign savings class based on current consumption
currentSavingsClass := "high" if {
	policyParameters.thresholds.currentSaving.high < rollingConsumption - currentConsumption
}

else := "mid" if {
	policyParameters.thresholds.currentSaving.mid < rollingConsumption - currentConsumption
}

else := "low" if {
	policyParameters.thresholds.currentSaving.low < rollingConsumption - currentConsumption
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


paymentBase := res if {
	currentPrice.unit == "HUF"
	res := currentConsumption * input.parameter.price.amount
}

paymentAfterSavings := applySupport(policyParameters.supports[consumptionClass][currentSavingsClass], paymentBase)

socialSupports contains [cred, support] if {
	cred := input.credentialData.credentials[_]
	cred.type[_] == policyParameters.socialSupports[x].credentialType
	support := policyParameters.socialSupports[x].support
}

applySupports(supports, inValue) := result if {
	result :=applySupports(supports)
	 applySupport(supports[0],inValue)
}

paymentAfterSupports := value if {
    some [cred, support] in socialSupports
    previousValue := paymentAfterSavings
	value := applySupport(support, previousValue)
}

default allow := false

#allow {
#	input.UserInput.expectedAmount == supportAmount
#}

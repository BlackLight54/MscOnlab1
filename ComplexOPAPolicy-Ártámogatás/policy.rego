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

consumptionClass := "high" if {
	policyParameters.thresholds.rollingConsumption.high < rollingConsumption
}

else := "mid" if {
	policyParameters.thresholds.rollingConsumption.mid < rollingConsumption
}

else := "low"

currentConsumption := input.parameter.consumption

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

currentPrice := input.parameter.price

paymentBase := res if {
	currentPrice.unit == "HUF"
	res := currentConsumption * currentPrice.amount
}

paymentAfterSavings := applySupport(policyParameters.supports[consumptionClass][currentSavingsClass], paymentBase)

socialSupports contains [cred, support] if {
	cred := input.credentialData.credentials[_]
	cred.type[_] == policyParameters.socialSupports[x].credentialType
	support := policyParameters.socialSupports[x].support
}

# applySupports(supports, inValue) := result if {
# 	otherValuesSum := applySupports(supports, inValue)
# 	 value := applySupport(supports[0],inValue)
#      result := otherValuesSum + value 
# }

paymentAfterSupports := value if {
    some [cred, support] in socialSupports
    previousValue := paymentAfterSavings
	value := applySupport(support, previousValue)
}

supportAmount := paymentBase - paymentAfterSupports

default allow := false

allow {
	supportAmount := paymentBase - paymentAfterSupports
	supportAmount == input.parameter.expectedSupportAmmount
}
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
	"supports": {"rollingConsumption": {
		"low": {"currentSaving": {
			"low": {
				"type": "percentage",
				"value": 10,
			},
			"mid": {
				"type": "percentage",
				"value": 10,
			},
			"high": {
				"type": "percentage",
				"value": 10,
			},
		}},
		"mid": {"currentSaving": {
			"low": {
				"type": "percentage",
				"value": 10,
			},
			"mid": {
				"type": "percentage",
				"value": 10,
			},
			"high": {
				"type": "percentage",
				"value": 10,
			},
		}},
		"high": {"currentSaving": {
			"low": {
				"type": "percentage",
				"value": 10,
			},
			"mid": {
				"type": "percentage",
				"value": 10,
			},
			"high": {
				"type": "percentage",
				"value": 10,
			},
		}},
	}},
	"socialSupports": {"ChangedWorkcapacity": {
		"credentialType": "ChangedWorkcapacityCredential",
		"type": "nominal",
		"value": 1000,
	}},
}

supportCreds contains cred if {
	cred := input.credentialData.credentials[_]
	cred.type[_] ==  policyParameters.socialSupports[_].credentialType
}

pastConsumptionCred := cred if {
	cred := input.credentialData.credentials[_]
	cred.type[_] == "ProofOfActualGasConsumptionCredential"
}

currentConsumption := input.parameter.consumption
currentPrice := input.parameter.price

default allow := false

#allow {
#	input.UserInput.expectedAmount == supportAmount
#}

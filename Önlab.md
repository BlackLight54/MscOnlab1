# Quick Start
CLI Tool
REST API
JVM Dep. 
# ![[Demo]]
# Összehasonlítás
## Indy/Aries-el 
- DID:
	- átfedés: did:key ; did:web
	- [DIF Universal Resolver](https://dev.uniresolver.io) aries oldalon támogatott, unofficial plugin keretében, walt.id-ben nem
- VC representation: Megszokottan JSON-LD, vagyis szemantikus információ csatolt az adatokhoz
	- ZKP?: Aries-ben ugye van, walt.id-bem még nem találtam, de ami a tavalyi rotokollhoz kellene, azt mindenkép ki kellene húzni egy Zokrates layerbe, ahogy tavaly beszéltük, ha támogatja az openID kommunikációs protokoll
- Communication protocol: DIF DIDCom nem támogatott, helyette openID; meg kell nézni az openID mit tud, mennyire biztonságos, mi küldhető rajta JSON-LD-n túl

- EBSI: ebsi DID method mellett támogatott mind a openID Connect protocol és az EBSI specifikus validációs policyk; ezek közül az Aries csak az EBSI DID resolution-t támogatja, a [DIF Universal Resolver](https://dev.uniresolver.io) -el 

- A két fő flow, az *onboarding* és az *authentication* automatizálva van, nem kell kézzel megírni
- Futtatható mind JVM-ben, mind CLI-n, mind REST-API ként; Aries-hez képest kisebb komplexitásúak ezek az interfészek
- Újdonság: Open Policy Agent integráció: formális nyelven megfogalmazható policy-k a W3C VC-k validálására

- [ ] TODO: Walt-os okat megkérdezni ZKP-ról
- [ ] TODO: OpenID-t megnézni
- [x] TODO: [European Digital Identity Architecture and Reference Framework](https://digital-strategy.ec.europa.eu/en/library/european-digital-identity-architecture-and-reference-framework-outline) 
no answer
- [ ] TODO: ToIP? Melyik kommunikaciós protokoll lesz a nyerő? mik vannak? [Talán ez az?](https://trustoverip.org/blog/2023/01/05/the-toip-trust-spanning-protocol/)

- [x] TODO: Rego-t megnézni

# 5. hét
Nem találtam a walt.id API-jában biztonságos kommunikációra lehetőséget adó endpointot. Ez egy további különbség a DIDCom-hoz képest, mert itt, ahogy én látom, OAuth-osan, TLS-el mennek át az üzenetek

## REGO (pr.: *ray-go*)
### Jellemzők
- Deklaratív nyelv (Prolog-hoz hasonlít számomra)
- Magas szintű
- Open Policy Agent-hez használható; OPA: Ágens aki enforce-olja a policy-ket
- [Datalog](https://en.wikipedia.org/wiki/Datalog) inspirálta, azt kiterjeszti hogy JSON és egyéb strukturált adatmodellekhez is lehessen használni
- Célja, hogy a policy-kat könnyen írható és olvasható módon, deklaratívan tudjuk leírni
### Felépítés
- Alapegysége a szabály
  `pi := 3.1415`
- Ez mutathat összetett értékre
  `rect := { "width" : 2 , "height" = 3 } `
- Olyan mint a prolog


## OpenID / OpenID Connect
### Jellemzők 
- API specifikáció
- OAuth 2.0 -hoz tartozik, a felett utazik, azt egészíti ki
- Issuance and presentitation of Verifiable Credentials
- Az OpenID core a dokumentáció szerint könnyedén bővíthető

- [x] [KILT](https://github.com/KILTprotocol/kilt-parachain#24-hierarchy-of-trust-module) Hierarchy of trust: Lecsekkolni, milyen policy-ket támogat a KILT, abból inspirálódni
- [ ] TODO: REGO demo
# 6. hét
## Open Policy Agent
Auditor API-n keresztül policy enforcement
unifes policy enforcement across the stack
goal: separate policy-decision making from business logic
flexible validation of w3c credentials
policy from file-system, DB or trusted registry(DLT)

vreification requrest = policy, to-be-verified data, action
to-be-verified data: relevant data points of credential, in JSON-LD
![[opa-service.svg]]
- Can function as a Kubernetes Admission Controller
	For example, by deploying OPA as an admission controller you can:
	-   Require specific labels on all resources.
	-   Require container images come from the corporate image registry.
	-   Require all Pods specify resource requests and limits.
	-   Prevent conflicting Ingress objects from being created.
### Docker HTTP API tutorial
policy fájlok (opa build)=> bundle
bundle => bundle server

seq:
nginx (policy req)-> opa (feth policies)-> bundle server (policy data)-> opa (policy decision) -> nginx

allows for arbitrarily complex policies, based on arbitrary structured data(JSON)
for examle: easy imlpementation of jWT tokens 
### Walt.id Dynamic Policies
The SSIKit allows for specifying custom policies written in one of the supported policy engine lingos. A dynamic policy can be executed on the fly, if all required parameters are given, or saved with a name, by which it can be referenced in the verify command or REST API lateron. In this example I'm going to use a very simple policy written in the Rego language, for the **Open Policy Agent** engine.

## Dynamic policy argument
The dynamic policy requires an argument of the DynamicPolicyArg type, which is defined like follows:
```
data class DynamicPolicyArg (
val name: String = "DynamicPolicy",
val description: String? = null,
val input: Map<String, Any?>,
val policy: String,
val dataPath: String = "\$",
val policyQuery: String = "data.system.main",
val policyEngine: PolicyEngineType = PolicyEngineType.OPA,
val applyToVC: Boolean = true,
val applyToVP: Boolean = false
)
```

**Properties:**
-   `name`: policy name, defaults to "DynamicPolicy"
-   `description`: Optional description of the policy
-   `input`: A generic map (JSON object), holding the input data required by the policy (or an empty map if no input is required)
-   `policy`: the policy definition (e.g. rego file), which can be a file path, URL, ==JSON Path (if policy is defined in a credential property)== or the code/script directly.
-   `dataPath`: The path to the credential data, which should be verified, by default it's the whole credential object `$`. To use e.g. only the credential subject as verification data, specify the JSON path like this: `$.credentialSubject`.
-   `policyQuery`: The query string in the policy engine lingo, defaults to "data.system.main"
-   `policyEngine`: The engine to use for execution of the policy. By default `OPA` (Open Policy Agent) is used.
-   `applyToVC`: Apply this policy to verifiable credentials (Default: true)
-   `applyToVP`: Apply this policy to verifiable presentations (Default: false)
## Issuance OIDC4CI
## Presentation OIDC4VP

TODO: példa walt-ban VC ellenőrzésre egy VC-ben leírt policy-t, amit OPA rego segítségével értékelünk ki, use-case gázártámogatás: dinamikusan változik a támogatás, a VC egy állítás azzal kapcsolatban, hogy jogosult vagyok valamennyi gázártámogatásra, a VS akkor érvényes, ha kiszámíthatóan
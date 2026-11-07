# Local validation — November 6, 2026

**Terms used here:** A private endpoint gives a supported service an address on a private network; access permissions still apply. DNS turns a service name into the network address used to reach it.

| Check | Observed result |
| --- | --- |
| Python standard-library unit tests | 14 passed |
| Offline demonstration | Six explicit declaration/consistency rows |
| Terraform format/init/validate | Passed, signed AzureRM 4.81.0 |
| Terraform mocked cases | Three passed; no Azure API calls or apply |
| Workflow syntax | Actionlint passed; manual workflow not dispatched |
| Trivy source secret scan | No findings; not infrastructure/dependency clearance |
| Local browser | Four network cards, six check cards and four shared-service cards |
| Navigation/mobile | All three tabs and 390px layout passed |
| Browser isolation | Zero page errors and external requests |

The public wrapper initially had a multi-argument variable formatted as an invalid single-line HCL block. It was corrected before provider initialization; validation and all three cases using simulated responses then passed. No live plan/apply or resource read occurred.

Tests reject overlapping/escaped ranges, duplicate/unknown peerings and a one-sided connection assumption. A fictional additional hub-peered spoke does not produce a direct spoke relationship in this deliberately narrow model. Prefixes and production transit flags are compared with the selected copied source.

These are source-declaration checks, not effective-route/NSG evaluation, packet delivery, real DNS resolution, private endpoint approval or identity/data-access tests. The six demonstration rows summarize model declarations and are not six independent live network tests. Other routes and networks can exist outside this curated selection.

Screenshots were captured from the new offline viewer. They do not show Azure Portal or a live inventory. No Azure resources, service starts, SQL access, endpoints, paid tiers or settings changed, and no hosted Actions minutes were consumed.

[Machine-readable result](validation-results.json) records this scope. See [source mapping](SOURCE-MAP.md) for original file hashes and explicit public adaptations.

## Troubleshooting documentation review — November 7, 2026

Added a README incident summary and a linked historical lessons guide, checking the account against the maintained source records. Documentation checks covered local links, complete incident fields, identifying-information patterns, whitespace and preservation of the existing four-step walkthrough. Shared incidents link to the relevant project details; unresolved causes remain explicit.

This was an editorial update. Application code, tests, Terraform, images, workflow definitions and cloud settings were not changed. Existing functional test counts and screenshots above retain their original scope and dates; no application suite, live scan, paid image request, recovery rehearsal or GitHub Actions run was executed for this documentation pass.

## Tools and utilities documentation review — November 7, 2026

Added a prominent README table naming the relevant tools/services and their jobs. The wording distinguishes actual platform components, operating utilities, selected source adapters, optional preparation and local teaching examples. Relevant step headings name their tools while the four-step order and explanatory sentences remain unchanged.

This editorial pass did not change application code, dependencies, infrastructure, workflows or cloud settings. Existing tests and screenshots retain their original evidence scope; no application suite, live scanner, browser sign-in, paid request or GitHub Actions run was executed for this wording update.

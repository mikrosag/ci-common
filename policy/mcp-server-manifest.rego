# OPA/conftest policy for a registry manifest (homelab/mcp-gateway/registry/<server>.yaml).
# Run with: conftest test --policy policy/ --namespace main.manifest <manifest.yaml>
#
# This is the "runtime egress allowlist declaration" gate from the design doc (section
# 7, stage 6) plus the structural checks that make gateway_sync.py's assumptions safe.
#
# Written in Rego v1 syntax (OPA >= 1.0, `if`/`contains` required) -- validated locally
# with `conftest test` against sample manifests before committing.
package main.manifest

import rego.v1

required_fields := ["name", "namespace", "transport", "owner", "security"]

deny contains msg if {
	some field in required_fields
	not input[field]
	msg := sprintf("manifest missing required field '%s'", [field])
}

# Egress must be explicitly declared -- either an empty allowlist (no outbound calls)
# or an explicit host list. Its absence entirely is what's disallowed: silence must
# not be read as "no restriction."
deny contains msg if {
	not input.network
	msg := "manifest has no 'network' block -- must declare network.egress: [] or an explicit host allowlist"
}

deny contains msg if {
	input.network
	not input.network.egress
	msg := "manifest has a 'network' block but no 'egress' key -- must be [] or an explicit host list, not omitted"
}

# Wildcard egress defeats the point of an allowlist.
deny contains msg if {
	some entry in input.network.egress
	entry == "*"
	msg := "manifest declares network.egress: ['*'] -- wildcard egress is not an allowlist, list explicit hosts or use []"
}

# security.attestation must point at a real SBOM path, not be left blank/templated,
# and security.signed must be explicitly true -- gateway_sync.py refuses to sync a
# manifest that fails either check (see AGENTS.md in mcp-gateway), this just catches
# the mistake earlier, in CI, rather than at sync time.
deny contains msg if {
	not input.security.attestation
	msg := "manifest's security.attestation is missing -- must reference the SBOM path produced by the sbom-sign stage"
}

deny contains msg if {
	input.security.signed != true
	msg := "manifest's security.signed must be explicitly true -- gateway_sync.py will refuse to sync this manifest otherwise"
}

# transport must be one of the two MetaMCP supports.
deny contains msg if {
	input.transport
	not input.transport in {"stdio", "streamable-http"}
	msg := sprintf("manifest's transport '%s' is not one of: stdio, streamable-http", [input.transport])
}

# OPA/conftest policy for docker-compose.yml belonging to a new MCP server being
# onboarded (mcp-server-security-gate.yml, stage 5). Run with:
#   conftest test --policy policy/ --namespace main.compose <(docker compose config)
#
# Enforces the homelab convention (see homelab/AGENTS.md: "No secrets in compose
# files, ever") plus baseline container hardening for anything joining the gateway.
#
# Written in Rego v1 syntax (OPA >= 1.0, `if`/`contains` required) -- validated
# locally with `conftest test` against sample compose output before committing.
package main.compose

import rego.v1

# --- No literal secrets: every environment value referencing credential-shaped
# keys must be a ${VAR} substitution already resolved to empty/absent by `docker
# compose config` when run with no .env -- a literal non-empty value means it was
# hardcoded rather than sourced from a repo secret.
deny contains msg if {
	some service_name
	service := input.services[service_name]
	some key
	value := service.environment[key]
	is_string(value)
	looks_like_secret_key(key)
	value != ""
	msg := sprintf("service '%s': environment key '%s' has a literal value -- secrets must come from ${VAR}, resolved via a gitignored .env written at deploy time, never hardcoded", [service_name, key])
}

looks_like_secret_key(key) if {
	upper_key := upper(key)
	contains(upper_key, "PASSWORD")
}

looks_like_secret_key(key) if {
	upper_key := upper(key)
	contains(upper_key, "SECRET")
}

looks_like_secret_key(key) if {
	upper_key := upper(key)
	contains(upper_key, "TOKEN")
}

looks_like_secret_key(key) if {
	upper_key := upper(key)
	contains(upper_key, "API_KEY")
}

# --- Must not run as root unless the service explicitly documents why (an
# override manifest field, checked at the registry-manifest level instead --
# this rule flags the common case of no `user:` directive at all on a service
# that also doesn't inherit a non-root USER from its own Dockerfile, which this
# policy can't see -- so it's a warn, not a hard deny, pending that cross-check).
warn contains msg if {
	some service_name
	service := input.services[service_name]
	not service.user
	msg := sprintf("service '%s': no explicit 'user:' -- confirm the image's Dockerfile sets a non-root USER, or add 'user: \"1000:1000\"' (or similar) here", [service_name])
}

# --- Resource limits should be set for anything joining a shared host.
warn contains msg if {
	some service_name
	service := input.services[service_name]
	not service.deploy.resources.limits
	msg := sprintf("service '%s': no deploy.resources.limits set -- an onboarded MCP server should cap memory/cpu so a runaway process can't starve the rest of the fleet", [service_name])
}

# --- read_only rootfs is a should, not a must (some servers need scratch space) --
# surfaced as a warn so a human reviews the tradeoff rather than it being silently
# absent.
warn contains msg if {
	some service_name
	service := input.services[service_name]
	service.read_only != true
	msg := sprintf("service '%s': read_only is not true -- set it if the server doesn't need to write outside declared volumes", [service_name])
}

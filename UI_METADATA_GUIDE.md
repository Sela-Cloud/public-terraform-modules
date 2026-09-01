# Sela Craft - UI Metadata & Terraform Code Generation Guide

This guide provides a comprehensive specification for generating `ui-metadata.json` alongside compatible Terraform HCL code (`variables.tf`, `main.tf`, `outputs.tf`) for any cloud infrastructure resource. 

This document is specifically structured so that **AI Coding Assistants** or developers can consume it to reliably construct modules compatible with the Sela Craft platform.

---

## 1. System Architecture Overview

Sela Craft provides a dynamic UI for deploying cloud infrastructure modules. The system works as follows:

```
[ Frontend Dynamic UI ]
         │ (Reads ui-metadata.json)
         ▼
[ User Fills Form ] ────► [ API Payload: values dict ]
                                 │
                                 ▼
                    [ Backend (terraform_runner.py) ]
                                 │ (Converts values to HCL)
                                 ▼
                    [ terraform.tfvars ] ──► [ Terraform Plan / Apply ]
```

### Key Architectural Concepts
1. **Globals vs. Resource Map**: 
   - **Globals**: Top-level variables passed directly into `terraform.tfvars` (e.g. `project_id = "my-project"`).
   - **Resource Map**: The primary resource configuration is formatted as a map of objects in `terraform.tfvars`:
     ```hcl
     gcs_bucket = {
       "my-bucket-name" = {
         location      = "US"
         storage_class = "STANDARD"
         versioning    = true
       }
     }
     ```
2. **Key Field**: The field designated in `ui-metadata.json` as `resource.key_field` (e.g. `app_name`, `instance_name`). Its value becomes the map key in `terraform.tfvars`.
3. **Category Scope**: 
   - `"global"`: Global resource (e.g. IAM, Global GCS bucket).
   - `"regional"`: Resource attached to a specific GCP region/zone (e.g. Compute Instance, Subnet).

---

## 2. Terraform (TF) Code Requirements & Best Practices

When crafting or generating Terraform code for Sela Craft modules, follow these conventions:

### A. Variable Structuring (`variables.tf`)

1. **Top-Level Global Variables**:
   Always declare top-level global variables outside the resource map.
   ```hcl
   variable "project_id" {
     description = "The GCP project ID in which to deploy resources."
     type        = string
   }
   ```

2. **Primary Resource Variable (`map(object)` pattern)**:
   The primary variable **must** be a map of objects indexed by unique resource keys. Use `optional(...)` with default values matching the `ui-metadata.json` defaults.
   ```hcl
   variable "gcs_bucket" {
     description = "Map of bucket configurations to create."
     type = map(object({
       app_name           = string
       location           = optional(string, "US")
       storage_class      = optional(string, "STANDARD")
       versioning         = optional(bool, false)
       bucket_policy_only = optional(bool, true)
       labels             = optional(map(string), {})
     }))
     default = {}
   }
   ```

3. **Extra Top-Level Variables (Optional)**:
   If your module needs secondary complex variables (e.g., IAM bindings), use `extras` in `ui-metadata.json` and declare them similarly:
   ```hcl
   variable "bucket_iam_bindings" {
     type    = map(any)
     default = {}
   }
   ```

### B. Module Implementation (`main.tf`)

1. Use `for_each = var.<resource_variable>` to iterate over the resource instances.
   ```hcl
   resource "google_storage_bucket" "buckets" {
     for_each = var.gcs_bucket

     project       = var.project_id
     name          = each.key # Or each.value.app_name
     location      = each.value.location
     storage_class = each.value.storage_class

     versioning {
       enabled = each.value.versioning
     }

     uniform_bucket_level_access = each.value.bucket_policy_only
     labels                      = each.value.labels
   }
   ```

---

## 3. `ui-metadata.json` Complete Specification

The `ui-metadata.json` file resides in the root directory of the module and instructs Sela Craft how to build form controls, group fields into collapsible sections, run client-side validations, and query GCP data sources.

### JSON Schema Structure Overview
```json
{
  "$schema": "../ui-metadata.schema.json",
  "module": "<module-id>",
  "version": "1.0.0",
  "display": { ... },
  "globals": [ ... ],
  "resource": { ... },
  "extras": [ ... ],
  "import": { ... }
}
```

---

### Top-Level Metadata Properties

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `$schema` | `string` | No | Path to schema definition (e.g., `"../ui-metadata.schema.json"`). |
| `module` | `string` | **Yes** | Unique module identifier, matching folder name (e.g., `"cloud-storage"`, `"compute-engine"`). |
| `version` | `string` | **Yes** | Semver string (e.g., `"1.0.0"`). |
| `import` | `object` | No | Enables importing pre-existing resources into this module. Omit it and the module is create-only. See [`import` Block](#import-block). |
| `display` | `object` | **Yes** | UI catalog display attributes (label, icon, category, description). |
| `globals` | `array` | No | Top-level variables (e.g. `project_id`). |
| `resource` | `object` | **Yes** | Main resource variable definition and section layout. |
| `extras` | `array` | No | Additional secondary top-level variables. |
| `provides` | `array` | No | What a resource of this module can be *used as* by another module's field. See [`provides` Block](#provides-block). |
| `satellites` | `array` | No | Secondary resources the module creates that have no independent lifecycle. See [`satellites` Block](#satellites-block). |
| `deprecated` | `boolean` | No | Hides the module from the new-request picker while keeping existing resources editable. See [`deprecated`](#deprecated). |

---

### `display` Block

```json
"display": {
  "label": "Cloud Storage",
  "icon": "cloud-storage",
  "description": "Google Cloud Storage buckets with lifecycle, IAM, CORS, and website hosting",
  "category": "global"
}
```
- `label` (`string`, required): Display title in UI catalog.
- `icon` (`string`, required): Frontend icon identifier (e.g., `"cloud-storage"`, `"compute-engine"`, `"cloud-sql"`).
- `description` (`string`, required): Short description shown on resource catalog cards.
- `category` (`string`, required): Categorization scope: `"global"` or `"regional"`.

---

### `globals` Block

Array of field objects that represent top-level Terraform variables not nested inside the main resource map (e.g., `project_id`).

```json
"globals": [
  {
    "id": "project_id",
    "label": "Project ID",
    "description": "GCP Project ID in which the resource will be provisioned.",
    "type": "text",
    "required": true,
    "placeholder": "my-gcp-project"
  }
]
```

---

### `resource` Block

Describes the main repeatable resource variable.

```json
"resource": {
  "variable": "gcs_bucket",
  "key_field": "app_name",
  "key_label": "Bucket name",
  "key_description": "A globally unique name for the Cloud Storage bucket. Serves as map key.",
  "sections": [ ... ]
}
```

- `variable` (`string`, required): Matches the Terraform variable name in `variables.tf`.
- `key_field` (`string`, required): Specifies which field inside the section fields is the unique resource identifier (map key).
- `key_label` (`string`, required): Human readable label for the key field.
- `key_description` (`string`, optional): Help text for the key field.
- `sections` (`array`, required): Array of `Section` objects.

---

### `provides` Block

**Optional.** Declares that a resource built from this module can be the *value* of some other
module's field.

A field says what it needs with `data_source.resource`: `subnet.network` needs `compute.networks`.
`provides` is the other half of that sentence — `vpc-network` states that it produces one:

```json
"provides": [
  { "data_source": "compute.networks", "value_field": "name" }
]
```

- `data_source` (`string`, required): the `data_source.resource` identifier this module satisfies.
  Must be one the API actually implements, or nothing will ever match it.
- `value_field` (`string`, required): which of *this* module's own values a consumer should use.
  Almost always the `key_field`, and validated to be a real field id or the key field.

**Why it exists.** A field backed by `data_source` is offered as the live list of what already
exists in the cloud, and for the AI builder that list becomes a hard constraint — a VPC created in
the same request was not in it, so referencing one was impossible rather than merely unlikely. With
`provides`, the platform can match a resource being created now against a field that needs its kind,
add it to the allowed values, and order the request so the producer is applied first. The deploy
applies each module into its own directory and state in request order, so that ordering is what makes
the reference resolve at apply time rather than fail.

Declare it on the module that **creates** the thing, not the one that consumes it. Deprecated modules
are ignored even when they declare it: nothing new should be steered towards them.

Only declare a `value_field` a consumer can actually use as a literal. A module that creates a
service account cannot usefully provide `iam.serviceAccounts`, because the email a consumer needs is
derived at apply time and is not one of the form's values.

---

### `import` Block

**Optional.** Declares how an existing cloud resource is adopted into this module. A module
without it can only create; a module with it also appears in the catalog's *import* mode. See
[IMPORT_PLAN.md](IMPORT_PLAN.md) for the mechanism.

This block exists because two facts cannot be inferred from outside the module:

1. **The resource address inside the wrapped module.** `main.tf` calls a remote module
   (`source = "git::…"`), so the real Terraform address of one instance is
   `module.<variable>["<key>"].<something inside that remote module>`. Only the module author
   knows the inner part.
2. **The attribute → field mapping.** A ui-metadata field feeds a module input which feeds a
   resource attribute, and the names differ along the way (`app_name` → `name` → `name`).

```json
"import": {
  "module": "gcs_bucket",
  "target": "google_storage_bucket.bucket",
  "id_template": "{project_id}/{app_name}",
  "identity_fields": ["project_id", "app_name"],
  "field_map": {
    "name": "app_name",
    "location": "location",
    "storage_class": "storage_class",
    "uniform_bucket_level_access": "bucket_policy_only"
  },
  "ignore": ["force_destroy"],
  "requires_review": false
}
```

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `module` | `string` | **Yes** | Label of the `module` block in `main.tf` that this import targets. **Always set it explicitly; there is no default.** It coincides with `resource.variable` often enough to look defaultable, but differs in 6 of 25 catalog modules — `cloud-run` declares `module "cloud_run_v2"` for variable `cloud_run`, `gke-autopilot-cluster` declares `module "gke_autopilot"` for variable `gke_autopilot_cluster`, and `gke-node-pool` declares `module "gke_standard_node_pool"` for variable `gke_node_pool`. A silent default would resolve to an address that does not exist. Read it out of `main.tf`. |
| `target` | `string` | **Yes** | Resource address **inside** the wrapped remote module, e.g. `google_storage_bucket.bucket`. Sela Craft prefixes it with `module.<import.module>["<key>"]`. Do **not** include that prefix. |
| `id_template` | `string` | **Yes** | The provider's import ID format, with `{field_id}` placeholders resolved from `identity_fields`. Take it from the provider's import documentation for `target`'s type. |
| `identity_fields` | `string[]` | **Yes** | The fields needed to build `id_template` uniquely. Every other value is discovered from the live resource. List `project_id` here if the ID needs it — but note it is **resolved from the environment, not asked of the user** (see below). |
| `field_map` | `object` | No | Resource **attribute path** → ui-metadata **field id**, for every field whose names or shapes differ. Identically-named scalars need no entry. Keys may be dotted paths — see *Attribute paths* below. |
| `ignore` | `string[]` | No | Attributes with no live counterpart, so they can never cause a false mismatch. `force_destroy` is the classic case: it governs Terraform's behaviour, not the resource. |
| `requires_review` | `boolean` | No | Forces human review of this module's imports regardless of the generic flow. Set it for anything sensitive. Defaults to `false`. |

**Rules**

- Import covers **one instance of one `module` block** — the one named by `import.module`.
  Standalone resources in the same `main.tf` (for instance
  `google_storage_managed_folder_iam_member`) are **not** imported.
- **Modules with several `module` blocks are not importable under this schema.** `cloud-sql`
  (`cloud_sql_instance` / `cloud_sql_database` / `cloud_sql_user`), `gke-cluster`
  (`gke_autopilot` / `gke_standard_cluster` / `gke_standard_node_pool`) and `iam` each declare
  three, and in `gke-cluster` *which* one applies depends on a field value, so a single static
  `target` cannot express it. Omit the `import` block for these.
- `target` names a resource inside the remote module **at the `?ref=` pinned in `main.tf`** (the
  catalog is uniformly on `v0.5.4`). A ref bump can rename inner resources, so re-verify `target`
  when it moves.
- Some remote modules build a **set** of resources from one input — `cloud-run` also creates a
  service account, `compute-engine` also creates disks and addresses. A single `target` cannot
  adopt those, and the gate will correctly fail with pending additions. Omit the `import` block
  until multi-target import exists.
- `identity_fields` must be a subset of `globals` and section field ids, and must include
  `resource.key_field` — the key decides the tfvars map entry.
- **Never assume the block label equals `resource.variable`.** Copy it from the `module "..."` line
  in that module's own `main.tf`. Six of 25 modules differ, including two of the newest ones.
- **`project_id` is injected from the environment, never entered by the user.** Sela Craft takes
  it from the environment record, so a user cannot import from a project they have no environment
  for. Keep it in `identity_fields` when `id_template` needs it; it simply will not be rendered as
  a form control.
- Mark identity fields `locked_after_create` where the provider does not allow changing them
  after the fact. Editing an imported resource's identity would target a different resource.
- A **partial match is refused.** After writing the discovered values, Sela Craft runs
  `terraform plan` and requires *N to import, 0 to add, 0 to change, 0 to destroy*. If the live
  resource uses anything the module does not model, the import fails with the offending
  attributes named, and nothing is written. Fixing that means extending the module, not relaxing
  the check — the alternative is an apply that silently reverts a real resource.
- Therefore `field_map` and `ignore` must be **complete**. An unmapped attribute that the module
  does model shows up as a spurious diff and blocks every import for that module.

**Attribute paths in `field_map`**

Keys are paths, not plain names, because a provider and a module often disagree about *shape* as
well as naming:

```json
"field_map": {
  "name": "app_name",
  "uniform_bucket_level_access": "bucket_policy_only",
  "versioning.enabled": "versioning",
  "custom_placement_config.data_locations": "data_locations",
  "lifecycle_rule": "lifecycle_rules"
}
```

`versioning` is a nested block `{enabled = bool}` in the provider but a bare `bool` in the module, so
the path names the inner field. A path into an **absent** block resolves to `null` rather than being
skipped — with no `versioning` block on the resource, `versioning.enabled` is `null`, and dropping
the key would leave a required module attribute unset.

Two things you do **not** have to declare, because Terraform's own provider schema states them and
import reads it directly:

- **Single nested blocks are collapsed automatically.** A block declared `max_items: 1` is returned
  by the provider as a 0-or-1-element list; import collapses it before mapping. Genuine lists
  (`cors`, `lifecycle_rule`) are left alone.
- **Computed-only attributes are dropped automatically** — `self_link`, `time_created`, `url` and
  friends can never appear in configuration, so they are never mapped and never reported as
  unmodelled.

**Fields the resource cannot supply**

Some fields have no counterpart on the live resource at all: `force_destroy` governs Terraform's
behaviour, and fields like `iam_members` or `tag_bindings` drive satellite resources. Import fills
these from each field's declared `default`, the same value the create flow would use. So **give every
such field a `default`** — otherwise import produces an entry missing a required attribute.

**Modules that own several resources: `targets`**

Some remote modules build a **set**. A VPN is a gateway, three forwarding rules, an address and a
tunnel; adopting only one of them would leave the rest to be created alongside the real ones on the
next apply. Such a module declares `targets` instead of `target`/`id_template`:

```json
"import": {
  "module": "vpn",
  "identity_fields": ["project_id", "region", "name"],
  "targets": [
    { "id": "tunnel",  "target": "google_compute_vpn_tunnel.this",
      "id_template": "projects/{project_id}/regions/{region}/vpnTunnels/{name}" },
    { "id": "gateway", "target": "google_compute_vpn_gateway.this",
      "id_template": "projects/{project_id}/regions/{region}/targetVpnGateways/{name}-gateway" },
    { "id": "address", "target": "google_compute_address.this", "required": false,
      "id_template": "projects/{project_id}/regions/{region}/addresses/{name}-ip" }
  ],
  "requires_review": true
}
```

| Key | Meaning |
| :--- | :--- |
| `id` | Stable name for this target within the module. Used in logs and error messages. |
| `target` | Resource address inside the remote module, as for the single-target form. |
| `id_template` | This resource type's own documented import ID. |
| `index` | Index suffix when the resource is `count`/`for_each` indexed inside the module, e.g. `[0]`. |
| `required` | Default true. When false, a target that does not exist is **skipped** rather than failing. |
| `field_map`, `ignore` | Per target, so a shared attribute name like `name` or `region` cannot collide across resource types. |

Rules for `targets`:

- **The first entry is the primary**, and its attributes supply the tfvars key. Choose the resource
  whose name *is* the key: every other resource in `vpn` derives its name by suffixing, so only the
  tunnel can supply `name`. If the primary cannot be read the import is refused outright — a
  satellite's derived name must never become the entry key.
- **Derived names go in the template as literal text.** The remote module names the gateway
  `${var.name}-gateway`, so the template ends `/{name}-gateway`.
- **`required: false` beats a conditional.** Whether an optional resource exists is a question the
  cloud can answer, and a 404 on an optional target means exactly "not there". Encoding the module's
  own conditional logic here instead would mean reimplementing it in JSON — and those conditions
  usually live in the remote module's `locals`, computed from several inputs.
- A **403 is never treated as absence.** Skipping on a permission error would adopt a partial set and
  report success.
- At least one target must be required, or an import could succeed having adopted nothing.

**How to derive `target` and `id_template`**

1. Find the resource in the remote module's source (`source = "git::…//modules/<name>"`) whose
   type matches what the module provisions.
2. `target` is that resource's `<type>.<local name>`, exactly as declared there.
3. `id_template` comes from that resource type's *Import* section in the provider docs.
   `google_storage_bucket` imports by `{{project}}/{{name}}`, hence
   `"{project_id}/{app_name}"` using **this module's** field ids.

---

### `satellites` Block

**Optional.** Lists the resources this module creates *besides* the primary one, which have no
independent lifecycle and therefore correctly stay inside the module rather than becoming their
own catalog module (`MODULE_CONTRACT.md` R4).

```json
"satellites": [
  {
    "address": "google_storage_bucket_iam_member.members",
    "driven_by": "iam_members",
    "note": "IAM bindings are not adopted on import; existing bindings stay unmanaged."
  },
  { "address": "google_compute_global_network_endpoint_group.neg", "driven_by": "enable_neg" }
]
```

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `address` | `string` | **Yes** | Terraform address of the satellite **inside the wrapped remote module**, same convention as `import.target` (no `module.…` prefix). |
| `driven_by` | `string` | No | The ui-metadata field id whose value creates these resources. Omit when the module always creates the satellite (for example `cloud-run`'s service account). |
| `note` | `string` | No | Plain-language consequence, shown to the user verbatim. Write the user-visible fact, not the implementation. |

This block exists because of one specific silent failure: an empty `for_each` produces **no diff**,
so importing a bucket with `iam_members = []` passes the plan gate cleanly while the live bucket's
real IAM bindings go uncaptured and unmentioned. Declaring satellites lets the UI say so out loud.

Declaring a satellite does not make Terraform adopt it — `import` still covers exactly the one
resource named by `import.target`. It only makes the omission visible.

---

### `deprecated`

**Optional, defaults to `false`.** Restructuring a module in a way that changes Terraform
addresses would destroy and recreate live infrastructure, so the catalog never does it in place: a
restructured module ships under a **new module id** and the old one is marked deprecated
(`MODULE_CONTRACT.md` R9).

```json
"deprecated": true
```

- Hidden from the new-request picker, so nothing new can be created with it.
- Still fully rendered, editable and deletable for resources that already exist.
- No `terraform state mv`, no cutover, no migration window.

`cloud-sql` is the worked example: it stays exactly as it is forever for the environments already
using it, while `cloud-sql-instance` / `cloud-sql-database` / `cloud-sql-user` are new ids.

---

### `Section` Block

Organizes form controls into collapsible visual cards.

```json
{
  "id": "basic",
  "label": "Basic Configuration",
  "description": "Core bucket settings.",
  "collapsed": false,
  "fields": [ ... ]
}
```

---

### Field Definition Objects

Supported `type` values:
- `"text"`: Standard text input.
- `"number"`: Numeric input.
- `"boolean"`: Toggle switch or checkbox.
- `"select"`: Dropdown selection (uses `options` array or dynamic `data_source`).
- `"list"`: Array of strings or primitive items.
- `"map"`: Key-value map editor (e.g. labels/tags).
- `"object"`: Nested single object structure (requires `fields` array).
- `"repeatable"`: Array of objects (requires `fields` array for each entry).

#### Field Attributes

| Property | Type | Description |
| :--- | :--- | :--- |
| `id` | `string` | Variable field key matching Terraform object attribute. |
| `label` | `string` | Display label in form. |
| `description` | `string` | Tooltip or help description text under the input. |
| `type` | `string` | One of `"text"`, `"select"`, `"boolean"`, `"number"`, `"map"`, `"list"`, `"object"`, `"repeatable"`. |
| `required` | `boolean` | Whether input is mandatory (default: `false`). |
| `default` | `any` | Default initial value. |
| `placeholder` | `string` | Input placeholder text. |
| `nullable` | `boolean` | Allows setting value to `null` (renders 'None' option). |
| `locked_after_create` | `boolean` | Disables the field while editing a resource already managed by Terraform; use it for create-time-only values. |
| `ui_only` | `boolean` | Marks a control that does not map to any Terraform attribute or global. See [`ui_only` Controls](#4-ui_only-controls). |
| `multiline` | `boolean` | Renders a `text` control as a multi-line editor. See [Multi-line text](#4-multi-line-text). |
| `options` | `array` | Options array for `select` type: `[{"value": "...", "label": "...", "description": "..."}]`. |
| `validation` | `object` | Client validation rules (`min`, `max`, `pattern`, `pattern_error`). |
| `depends_on` | `object` | Conditional visibility condition based on another field. |
| `data_source` | `object` | Dynamic API data fetching rules for dropdowns. |
| `fields` | `array` | Sub-fields for `"object"` or `"repeatable"` types. |

---

### Advanced Field Features

#### 1. Client-Side Validation (`validation`)
```json
"validation": {
  "min": 3,
  "max": 63,
  "pattern": "^[a-z0-9][a-z0-9._-]{1,61}[a-z0-9]$",
  "pattern_error": "Bucket names must be 3-63 characters starting/ending with alphanumeric."
}
```

#### 2. Conditional Visibility (`depends_on`)
Show a field only when another field equals/matches a specific condition.
Operators: `"eq"`, `"neq"`, `"in"`, `"not_in"`.

```json
"depends_on": {
  "field": "enable_custom_domain",
  "value": true,
  "operator": "eq"
}
```

#### 3. Dynamic GCP Data Sources (`data_source`)
Populates select dropdowns dynamically by querying GCP backend endpoints (e.g., VPC networks, subnets, service accounts, zones).

```json
"data_source": {
  "resource": "compute.subnetworks",
  "params": {
    "project": { "from_field": "project_id" },
    "region": { "from_field": "region" },
    "vpc": { "from_field": "network" }
  },
  "display": {
    "value_key": "name",
    "label_key": "name",
    "description_key": "ipCidrRange"
  },
  "allow_custom": true,
  "cache_ttl": 300
}
```

##### Supported GCP Data Source Resources & Parameters

Generated from `RESOURCE_HANDLERS` in `apps/api/services/gcp_client.py`. Every identifier below is
implemented; anything **not** listed here will raise `Unknown resource type` at request time, so do
not invent one. `project` and `project_id` are interchangeable everywhere, as are
`region`/`location`. All handlers return a `description` key in addition to those listed.

| Resource Identifier | Aliases | Returns | Parameters | Response Keys |
| :--- | :--- | :--- | :--- | :--- |
| `compute.networks` | `compute.vpc`, `vpc.networks` | VPC networks | `project_id` | `name`, `selfLink`, `autoCreateSubnetworks` |
| `compute.subnetworks` | `compute.subnets`, `subnet.subnetworks` | Subnets, optionally filtered by VPC | `project_id`, `region`, `vpc`/`network` | `name`, `ipCidrRange`, `region`, `network`, `selfLink` |
| `compute.zones` | — | Zones, optionally filtered by region | `project_id`, `region` | `name`, `region`, `status` |
| `compute.regions` | — | Regions with status `UP` | `project_id` | `name`, `status` |
| `compute.disks` | `compute.additionalDisks`, `compute.additional_disks` | Persistent disks | `project_id`, `zone`, `region` | `name`, `sizeGb`, `type`, `zone`, `region`, `selfLink` |
| `compute.machineTypes` | `compute.machine_types` | Machine types in a zone | `project_id`, `zone` | `name`, `guestCpus`, `memoryMb` |
| `compute.routers` | — | Cloud Routers in a region | `project_id`, `region` | `name`, `network` |
| `compute.healthChecks` | — | Health checks, for DNS routing policies | `project_id` | `name`, `selfLink` |
| `iam.serviceAccounts` | `iam.service_accounts`, `iam.sa` | Service accounts | `project_id` | `email`, `displayName`, `uniqueId` |
| `iam.roles` | `iam.custom_roles`, `iam.customRoles` | Predefined and/or custom roles | `project_id`, `scope` (`predefined`\|`custom`\|`all`, default `all`) | `name`, `title`, `type` |
| `cloudsql.instances` | `cloudsql.sqlInstances` | Cloud SQL instances; read replicas excluded | `project_id`, `region` | `name`, `databaseVersion`, `region`, `state` |
| `cloudsql.databaseVersions` | — | Supported engine versions (static catalog) | `project_id` | `name` |
| `cloudsql.tiers` | — | Machine tiers, filtered by region | `project_id`, `region` | `name` |
| `cloudsql.flags` | — | Flags for one engine version | `project_id`, `database_version` | `name` |
| `container.clusters` | `gke.clusters` | GKE clusters, regional and zonal; Autopilot flagged | `project_id`, `region` | `name`, `location`, `status`, `autopilot` |
| `artifactregistry.locations` | — | Artifact Registry locations | `project_id` | `name` |
| `artifactregistry.repositories` | — | Repositories in one location | `project_id`, `location` | `name`, `repositoryId` |
| `secretmanager.secrets` | — | Secret names; never reads payloads | `project_id` | `name` |
| `secretmanager.secretVersions` | — | Version metadata; never reads secret data | `project_id`, `secret` | `name` |
| `dns.managedZones` | `dns.managed_zones` | Cloud DNS managed zones | `project_id` | `name`, `dnsName`, `visibility` |
| `dns.peeringNetworks` | — | Target VPCs for a peering zone | `project_id` | `project_id` |
| `kms.cryptoKeys` | — | CryptoKeys; never reads key material | `project_id`, `location` | `name` |
| `servicenetworking.psa` | `servicenetworking.connections`, `compute.psa` | PSA connections and reserved ranges | `project_id`, `vpc`/`network`, `region` | `name`, `peering`, `address`, `prefixLength` |

Note the two parent pickers, `cloudsql.instances` and `container.clusters`: they exist so a
standalone child resource (a database, a user, a node pool) can select its parent rather than have
an operator retype a name that must match exactly. Both set `allow_custom: true` in practice, so a
parent being created in the same change can still be named by hand.

#### 4. Multi-line text

`type: "text"` is a single-line input by default. Set `multiline: true` for values that are
genuinely documents rather than identifiers — a startup script, cloud-init, an embedded config file:

```json
{
  "id": "startup_script",
  "label": "Startup script",
  "type": "text",
  "multiline": true,
  "default": ""
}
```

This changes the **input control only**. The value is an ordinary string throughout: the tfvars
writer emits it as a quoted string with escaped newlines (`"#!/bin/bash\nset -eux\n"`), which is
byte-for-byte the same value Terraform would read from a `<<-EOT` heredoc. A multi-line script is
therefore already correct today without this flag; the flag exists so the operator gets a text area
instead of typing a script into a one-line box.

Only meaningful on `text`. It has no effect on `select`, `number`, `map`, `list`, `object` or
`repeatable`.

#### 5. `ui_only` Controls

Every form control must map to **an attribute of the resource object, or a global** — that is R6 in
`MODULE_CONTRACT.md`, and CI fails the build otherwise. `ui_only: true` is the declared exception,
for controls that exist purely to parameterise the form itself:

```json
{
  "id": "remote_password_secret",
  "label": "Upstream password secret",
  "type": "select",
  "ui_only": true,
  "data_source": { "…": "…" }
}
```

- Use it when the control's only job is to feed another field's `data_source` `params`, or otherwise
  drive the UI. `artifact-registry.remote_password_secret` is the canonical case.
- Its value is **not written to tfvars**, so nothing downstream can read it.
- Do **not** use it to silence the check for a control that *should* reach Terraform — a control
  whose attribute is missing from `variables.tf` is a dropped field, and marking it `ui_only` hides
  a real bug (this is exactly the `compute-engine` class of failure).
- Nested sub-fields (under a `repeatable`/`object` field's `fields`) describe the shape of that
  field's value, not separate attributes, so they never need `ui_only`.

---

## 4. Instructions for AI Code Generators

When tasked with generating a module for Sela Craft, follow these steps sequentially:

1. **Analyze Resource Requirements**: Identify the GCP resource type, its required parameters, optional parameters, and logical sub-configurations (e.g. networking, storage, security).
2. **Define Category Scope**: 
   - If the resource requires a region/zone parameter (e.g., VM, Subnet, GKE), set `display.category` to `"regional"`.
   - If global (e.g. GCS, IAM, Global VPC), set `display.category` to `"global"`.
3. **Construct `variables.tf`**:
   - Create `variable "project_id"` as a global variable.
   - Create a single primary variable `variable "<resource_name>"` of type `map(object({...}))` with proper `optional(...)` defaults.
4. **Construct `ui-metadata.json`**:
   - Set `module` identifier and `display` details.
   - Map `globals` (containing `project_id`).
   - Define `resource` pointing `variable` to your Terraform map variable and `key_field` to the unique identifier field.
   - Group fields logically into clean, user-friendly `sections` (e.g., `Basic`, `Networking`, `Storage & Security`).
   - Use proper input types (`select`, `boolean`, `number`, `text`, `map`, `repeatable`).
5. **Construct `main.tf`**:
   - Use `for_each = var.<resource_name>` to instantiate resources cleanly.
   - Handle optional blocks using `dynamic` blocks or conditional expressions where appropriate.

---

## 5. Complete Example: Compute Engine VM Module

### A. `ui-metadata.json`
```json
{
  "$schema": "../ui-metadata.schema.json",
  "module": "compute-engine",
  "version": "1.0.0",
  "display": {
    "label": "Compute Engine",
    "icon": "compute-engine",
    "description": "Google Cloud Compute Engine Virtual Machine instances",
    "category": "regional"
  },
  "globals": [
    {
      "id": "project_id",
      "label": "Project ID",
      "description": "GCP Project ID",
      "type": "text",
      "required": true,
      "placeholder": "my-gcp-project"
    }
  ],
  "resource": {
    "variable": "compute_instance",
    "key_field": "instance_name",
    "key_label": "Instance Name",
    "key_description": "Name of the VM instance. Serves as map key.",
    "sections": [
      {
        "id": "basic",
        "label": "Basic Configuration",
        "fields": [
          {
            "id": "instance_name",
            "label": "Instance Name",
            "type": "text",
            "required": true,
            "validation": {
              "pattern": "^[a-z]([-a-z0-9]*[a-z0-9])?$",
              "pattern_error": "Must start with a lowercase letter, contain lowercase letters, numbers, hyphens."
            }
          },
          {
            "id": "zone",
            "label": "Zone",
            "type": "select",
            "required": true,
            "data_source": {
              "resource": "compute.zones",
              "params": {
                "project": { "from_field": "project_id" }
              },
              "display": {
                "value_key": "name",
                "label_key": "name"
              }
            }
          },
          {
            "id": "machine_type",
            "label": "Machine Type",
            "type": "select",
            "required": true,
            "default": "e2-medium",
            "options": [
              { "value": "e2-micro", "label": "e2-micro (2 vCPU, 1 GB RAM)" },
              { "value": "e2-small", "label": "e2-small (2 vCPU, 2 GB RAM)" },
              { "value": "e2-medium", "label": "e2-medium (2 vCPU, 4 GB RAM)" },
              { "value": "n2-standard-2", "label": "n2-standard-2 (2 vCPU, 8 GB RAM)" }
            ]
          }
        ]
      },
      {
        "id": "boot_disk",
        "label": "Boot Disk",
        "fields": [
          {
            "id": "image",
            "label": "Disk Image",
            "type": "text",
            "required": true,
            "default": "debian-cloud/debian-11"
          },
          {
            "id": "disk_size_gb",
            "label": "Disk Size (GB)",
            "type": "number",
            "required": true,
            "default": 20,
            "validation": { "min": 10, "max": 65536 }
          }
        ]
      }
    ]
  }
}
```

### B. `variables.tf`
```hcl
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "compute_instance" {
  description = "Map of Compute Engine instance configurations."
  type = map(object({
    instance_name = string
    zone          = string
    machine_type  = optional(string, "e2-medium")
    image         = optional(string, "debian-cloud/debian-11")
    disk_size_gb  = optional(number, 20)
  }))
  default = {}
}
```

### C. `main.tf`
```hcl
resource "google_compute_instance" "vm" {
  for_each = var.compute_instance

  project      = var.project_id
  name         = each.value.instance_name
  zone         = each.value.zone
  machine_type = each.value.machine_type

  boot_disk {
    initialize_params {
      image = each.value.image
      size  = each.value.disk_size_gb
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}
```

---

## 6. Summary Checklist for AI / Code Generator Validation

Most of this list is enforced automatically by `frontend/validate_metadata.py` in the
`public-terraform-modules` repo, which runs on every PR and push to `main` (and again before a
release publishes). Run it locally with `python3 frontend/validate_metadata.py`.

Before finalizing a module generation task, verify:
- [ ] `ui-metadata.json` is syntactically valid JSON.
- [ ] `module` string matches directory name.
- [ ] `resource.variable` in `ui-metadata.json` matches the `map(object)` variable name in `variables.tf`.
- [ ] `resource.key_field` exists as a field in `ui-metadata.json` sections. Whether it *also* exists inside the `variables.tf` object type is the module author's choice — see [Two valid `key_field` patterns](#two-valid-key_field-patterns).
- [ ] `globals` array contains all top-level single variables (e.g. `project_id`).
- [ ] Every field `id` inside sections matches an attribute inside `variables.tf`, or a `globals` id, or is marked `ui_only: true`.
- [ ] `main.tf` uses `for_each = var.<resource.variable>` and accesses properties via `each.value.<field_id>`.
- [ ] Every `each.value.<x>` in `main.tf` is a real attribute of the object type (a typo here silently drops a field).
- [ ] The remote `?ref=` pin matches the rest of the catalog.
- [ ] Secondary resources the module creates are declared in `satellites`.

### Two valid `key_field` patterns

`resource.key_field` names the field whose value becomes the **tfvars map key**. Whether that field
is *also* declared as an attribute of the object type is a free choice, and the catalog uses both
patterns today. Do not "fix" one into the other — changing it rewrites tfvars.

**Pattern A — key *and* attribute.** The field appears in the object type and `main.tf` reads it via
`each.value.<key_field>`. The majority pattern: `cloud-storage` (`app_name`), `firewall`,
`cloud-dns-zone`, `cloud-nat`, `cloud-router`, `vpc-network`, `subnet`, `cloud-run`,
`private-service-access`, `compute-engine`, `artifact-registry`.

```hcl
variable "gcs_bucket" {
  type = map(object({
    app_name = string   # declared: readable as each.value.app_name
    location = string
  }))
}
```
```hcl
name = each.value.app_name
```

**Pattern B — key only.** The field is *not* in the object type; the map key carries the value and
`main.tf` reads `each.key` (or nothing at all). Used by `iam` (`config_name`).

```hcl
variable "iam_configs" {
  type = map(object({    # no config_name attribute here
    service_account_name = string
  }))
}
```
```hcl
name = each.key
```

Both work because the tfvars writer emits the key field unconditionally and Terraform drops values
the object type does not declare (`MODULE_CONTRACT.md` R5). Pick one per module and be consistent:

- Pattern A when the module passes the value into the remote module as an attribute, or when the map
  key is a *separate* identifier from the resource name — `cloud-dns-record` keys on `record_key`
  while naming the record from `each.value.name`.
- Pattern B when the key *is* the identifier and nothing inside the module needs to read it back.

CI never fails on a `key_field` that is absent from the object type.

If the module supports import (`import` block present):
- [ ] `import.module` matches the actual `module "…"` label in `main.tf` — verified, not assumed equal to `resource.variable`.
- [ ] `main.tf` declares exactly **one** `module` block (multi-block modules are not importable).
- [ ] `import.target` is the address **inside** the wrapped remote module, with no `module.…` prefix.
- [ ] `import.target` was read from the remote module at the `?ref=` pinned in this `main.tf`.
- [ ] `import.id_template` matches the provider's documented import ID for that resource type.
- [ ] `import.identity_fields` includes `resource.key_field` and is sufficient to fill `id_template`.
- [ ] Every field whose resource attribute name differs from its ui-metadata `id` appears in `field_map`.
- [ ] Terraform-only attributes (e.g. `force_destroy`) are listed in `ignore`.
- [ ] Every field with no live counterpart has a `default`, so import can fill it.
- [ ] `field_map` keys use dotted paths wherever the provider nests a value the module flattens.
- [ ] `requires_review` is `true` for anything sensitive (IAM, credentials, shared networking).
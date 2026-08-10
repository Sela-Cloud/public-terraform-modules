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
| `target` | `string` | **Yes** | Resource address **inside** the wrapped remote module, e.g. `google_storage_bucket.bucket`. Sela Craft prefixes it with `module.<resource.variable>["<key>"]`. Do **not** include that prefix. |
| `id_template` | `string` | **Yes** | The provider's import ID format, with `{field_id}` placeholders resolved from `identity_fields`. Take it from the provider's import documentation for `target`'s type. |
| `identity_fields` | `string[]` | **Yes** | The fields needed to build `id_template` uniquely. Every other value is discovered from the live resource. List `project_id` here if the ID needs it — but note it is **resolved from the environment, not asked of the user** (see below). |
| `field_map` | `object` | No | Resource **attribute** → ui-metadata **field id**, for every field whose names differ. Identically-named fields need no entry. |
| `ignore` | `string[]` | No | Attributes with no live counterpart, so they can never cause a false mismatch. `force_destroy` is the classic case: it governs Terraform's behaviour, not the resource. |
| `requires_review` | `boolean` | No | Forces human review of this module's imports regardless of the generic flow. Set it for anything sensitive. Defaults to `false`. |

**Rules**

- Import covers **only the main `module` block** driven by `resource.variable`. Standalone
  resources in the same `main.tf` (for instance `google_storage_managed_folder_iam_member`) are
  **not** imported. One import adopts one module instance.
- `identity_fields` must be a subset of `globals` and section field ids, and must include
  `resource.key_field` — the key decides the tfvars map entry.
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

**How to derive `target` and `id_template`**

1. Find the resource in the remote module's source (`source = "git::…//modules/<name>"`) whose
   type matches what the module provisions.
2. `target` is that resource's `<type>.<local name>`, exactly as declared there.
3. `id_template` comes from that resource type's *Import* section in the provider docs.
   `google_storage_bucket` imports by `{{project}}/{{name}}`, hence
   `"{project_id}/{app_name}"` using **this module's** field ids.

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

| Resource Identifier | Description | Parameters | Response Keys |
| :--- | :--- | :--- | :--- |
| `compute.networks` (or `compute.vpc`) | VPC Networks in project | `project` / `project_id` | `name`, `description`, `selfLink` |
| `compute.subnetworks` (or `compute.subnets`) | Subnets in project/region/vpc | `project`, `vpc` / `network`, `region` / `location` | `name`, `ipCidrRange`, `region`, `network` |
| `compute.zones` | Available zones in region | `project`, `region` / `location` | `name`, `region`, `status` |
| `iam.serviceAccounts` (or `iam.sa`) | Service Accounts in project | `project` / `project_id` | `email`, `displayName`, `uniqueId` |
| `iam.roles` (or `iam.customRoles`) | IAM Roles (Predefined & Custom) | `project` / `project_id`, `scope` (`predefined`, `custom`, `all`) | `name`, `title`, `description`, `type` |
| `compute.disks` | Persistent Disks | `project`, `region` / `location`, `zone` | `name`, `sizeGb`, `type`, `zone`, `region` |
| `servicenetworking.psa` | Private Services Access (PSA) | `project`, `vpc` / `network`, `region` / `location` | `name`, `peering`, `address`, `prefixLength` |


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

Before finalizing a module generation task, verify:
- [ ] `ui-metadata.json` is syntactically valid JSON.
- [ ] `module` string matches directory name.
- [ ] `resource.variable` in `ui-metadata.json` matches the `map(object)` variable name in `variables.tf`.
- [ ] `resource.key_field` exists as a field in `ui-metadata.json` sections and inside the `variables.tf` object type declaration.
- [ ] `globals` array contains all top-level single variables (e.g. `project_id`).
- [ ] All field `id`s inside sections match corresponding key attributes inside `variables.tf`.
- [ ] `main.tf` uses `for_each = var.<resource.variable>` and accesses properties via `each.value.<field_id>`.

If the module supports import (`import` block present):
- [ ] `import.target` is the address **inside** the wrapped remote module, with no `module.…` prefix.
- [ ] `import.id_template` matches the provider's documented import ID for that resource type.
- [ ] `import.identity_fields` includes `resource.key_field` and is sufficient to fill `id_template`.
- [ ] Every field whose resource attribute name differs from its ui-metadata `id` appears in `field_map`.
- [ ] Terraform-only attributes (e.g. `force_destroy`) are listed in `ignore`.
- [ ] `requires_review` is `true` for anything sensitive (IAM, credentials, shared networking).

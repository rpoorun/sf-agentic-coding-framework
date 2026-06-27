---
name: sf-platform-permissions
description: "Generates correct, deployable Salesforce permission set metadata (PermissionSet XML) with object, field, user, and app permissions. Use this skill when creating or editing permission set metadata, object permissions, field-level security (FLS), tab visibility, or deploying permission sets."
metadata:
  version: "1.0"
  cloud: "Platform"
  synthesized: true
  sources:
    - forcedotcom/sf-skills :: platform-permission-set-generate
    - Clientell-Ai/salesforce-skills :: sf-permissions
---

# sf-platform-permissions: Permission Sets & FLS

| Field | Value |
| --- | --- |
| Skill ID | `sf-platform-permissions` |
| Cloud | Platform |
| Version | 1.0 |
| Synthesized | Yes — deduplicated and merged from the source(s) below |
| Sources | forcedotcom/sf-skills :: platform-permission-set-generate; Clientell-Ai/salesforce-skills :: sf-permissions |

## When to Use This Skill

Use when generating or editing permission set metadata, or when granting object, field, user, and app permissions.

## Step 1: Define Core Properties

Start by defining the required permission set properties:

```xml
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>YourPermissionSetName</fullName>
    <label>Display Name for Administrators</label>
    <description>Clear description of purpose and intended audience</description>
</PermissionSet>
```

**Naming conventions:**
- Use descriptive API names (e.g., `Sales_Manager_Access`)

## Step 2: Configure Object Permissions

Add CRUD permissions for standard and custom objects:

```xml
<objectPermissions>
    <allowCreate>true</allowCreate>
    <allowRead>true</allowRead>
    <allowEdit>true</allowEdit>
    <allowDelete>false</allowDelete>
    <modifyAllRecords>false</modifyAllRecords>
    <viewAllRecords>false</viewAllRecords>
    <viewAllFields>false</viewAllFields>
    <object>Account</object>
</objectPermissions>
```

## Step 3: Set Field-Level Security

Define field permissions for sensitive or custom fields:

```xml
<fieldPermissions>
    <editable>true</editable>
    <readable>true</readable>
    <field>Account.SSN__c</field>
</fieldPermissions>
```

**Important:**
- Required fields must NEVER appear in list of field permissions. Granting field-level security on required fields is not allowed by the platform and will cause deployment failure. 
- Before adding any field, confirm from the object metadata that the field exists and is not required
- A field is required when its metadata contains `<required>true</required>`:
- Formula fields cannot be editable
- Master-detail fields are required fields on the child (detail) object

```xml
<fields>
    <fullName>FieldName__c</fullName>
    <required>true</required>
</fields>
```
- Use format `ObjectName.FieldName` for field references
- Set both readable and editable to true when the user needs edit access; editable implies readable
- If all fields should be visible, can alternatively enable the "viewAllFields" object permission

## Step 4: Grant User Permissions

Add system-level permissions for features and capabilities:

```xml
<userPermissions>
    <enabled>true</enabled>
    <name>ApiEnabled</name>
</userPermissions>
<userPermissions>
    <enabled>true</enabled>
    <name>RunReports</name>
</userPermissions>
```

**Common permissions:**
- `ApiEnabled`: API access
- `ViewSetup`: View Setup menu
- `ManageUsers`: User management
- `RunReports`: Report execution

**Security review required for:**
- `ViewAllData`: Read all records
- `ModifyAllData`: Edit all records
- `ManageUsers`: User administration

## Step 5: Configure App and Tab Visibility

Make applications and tabs visible to users:

```xml
<applicationVisibilities>
    <application>Sales_Console</application>
    <visible>true</visible>
</applicationVisibilities>
<tabSettings>
    <tab>CustomTab__c</tab>
    <visibility>Visible</visibility>
</tabSettings>
```

**Application visibility options:**
- <visible> can be true or false

**Tab visibility options:**
- `Visible`: The tab is available on the All Tabs page and appears in the visible tabs for its associated app. Can be customized.
- `Available`: The tab is available on the All Tabs page. Individual users can customize their display to make the tab visible in any app
- `None`: Not visible

**CRITICAL - Tab Naming:**
- Custom object tabs: MUST include the __c suffix (e.g., MyCustomObject__c)
- Standard object tabs: Use the object name with "standard-" prefix (e.g., standard-Account, standard-Contact)
- The tab name matches the object's API name exactly

## Step 6: Add Apex and Visualforce Access (Optional)

Grant access to custom code:

```xml
<classAccesses>
    <apexClass>CustomController</apexClass>
    <enabled>true</enabled>
</classAccesses>
<pageAccesses>
    <apexPage>CustomPage</apexPage>
    <enabled>true</enabled>
</pageAccesses>
```

## Step 7: Set License and Record Type Settings (Optional)

Specify license requirements and record type visibility:

```xml
<license>Salesforce</license>
<hasActivationRequired>false</hasActivationRequired>
<recordTypeVisibilities>
    <recordType>Account.Business</recordType>
    <visible>true</visible>
    <default>true</default>
</recordTypeVisibilities>
```
## Step 8: Set Agent Access (Optional)
                                              
Enable access to Agentforce Employee Agents for users assigned to this permission set:

<agentAccesses>
    <agentName>Sales_Assistant_Agent</agentName>
    <enabled>true</enabled>
</agentAccesses>

Field requirements:
- agentName (Required): The developer name of the employee agent
- enabled (Required): Set to true to grant access, false to deny

Important:
- Agent names must match existing Agentforce Employee Agent developer names

## Validation Checklist

Before deploying, verify:
- [ ] fullName, label, description set
- [ ] Permissions follow least privilege
- [ ] No required fields in `<fieldPermissions>`
- [ ] No duplicate permissions
- [ ] No lengthy comments

## What Causes Deployment Failure

- **Field permissions on required fields:** Any required field in `<fieldPermissions>` fails deployment. Required fields cannot have FLS; omit them entirely. Always confirm from object/field metadata that a field exists and is not required—never assume.
- **Incorrect API names:** Using the wrong name or missing suffixes (e.g. missing `__c` for custom objects, fields, tabs) cause failure.

## Deployment

Deploy using Salesforce CLI

---

## Merged Source Material

The sections below are retained from the secondary source(s) for completeness. Treat the primary guidance above as authoritative; use this section only for details not already covered above, and reconcile any conflicts in favor of the primary source.

### Supplemental Guidance from `sf-permissions` (Clientell-Ai/salesforce-skills :: sf-permissions)

# Salesforce Permission Management & Access Auditing

You are a Salesforce permissions specialist. Manage permission sets, audit access, diagnose permission errors, and enforce least-privilege security.

## 1. Permission Model Overview

| Layer | Controls | Scope |
|-------|----------|-------|
| **Profiles** | Login hours, IP ranges, page layouts, record types, default app | One per user (required) |
| **Permission Sets** | Object CRUD, FLS, Apex class, VF page, tab, custom permissions | Many per user (additive) |
| **Permission Set Groups** | Bundle of Permission Sets + optional muting | Many per user (additive) |

**Best practice: Minimal Profile + Permission Sets.** Assign a stripped-down profile (e.g., "Minimum Access - Salesforce") and grant everything else through Permission Sets and Permission Set Groups.

Why Permission Sets over Profiles:
- A user can have only ONE profile but MANY permission sets
- Permission sets are additive and composable
- Profiles cause merge conflicts in source control
- Permission Set Groups enable role-based bundling with muting for exceptions
- Salesforce is actively moving away from profile-based permissions

## 2. Permission Set XML (SFDX Source Format)

```xml
<!-- force-app/main/default/permissionsets/Order_Manager.permissionset-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Order Manager</label>
    <description>Full CRUD on Order__c, read on Account</description>
    <hasActivationRequired>false</hasActivationRequired>
    <license>Salesforce</license>
    <objectPermissions>
        <object>Order__c</object>
        <allowCreate>true</allowCreate>
        <allowDelete>false</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>false</modifyAllRecords>
        <viewAllRecords>true</viewAllRecords>
    </objectPermissions>
    <fieldPermissions>
        <field>Order__c.Amount__c</field>
        <editable>true</editable>
        <readable>true</readable>
    </fieldPermissions>
    <tabSettings>
        <tab>Order__c</tab>
        <visibility>Visible</visibility>
    </tabSettings>
    <classAccesses>
        <apexClass>OrderService</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <pageAccesses>
        <apexPage>OrderEntryPage</apexPage>
        <enabled>true</enabled>
    </pageAccesses>
    <customPermissions>
        <name>Bypass_Validation</name>
        <enabled>true</enabled>
    </customPermissions>
    <userPermissions>
        <name>RunReports</name>
        <enabled>true</enabled>
    </userPermissions>
</PermissionSet>
```

- `hasActivationRequired`: When `true`, must be activated in a session before taking effect
- `license`: Restricts assignment to users with that license type
- Object permissions hierarchy: Read required for Edit; Edit required for Delete; `viewAllRecords`/`modifyAllRecords` override sharing

## 3. Permission Set Group XML

```xml
<!-- force-app/main/default/permissionsetgroups/Sales_Team.permissionsetgroup-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSetGroup xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Sales Team</label>
    <description>All permissions needed by sales reps</description>
    <status>Updated</status>
    <permissionSets>
        <permissionSet>Account_Reader</permissionSet>
        <permissionSet>Opportunity_Manager</permissionSet>
        <permissionSet>Report_Viewer</permissionSet>
    </permissionSets>
    <mutingPermissionSet>Sales_Team_Muting</mutingPermissionSet>
</PermissionSetGroup>
```

### Muting Permission Set

A muting permission set **removes** specific permissions from the group. It only works inside a Permission Set Group.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Sales Team Muting</label>
    <description>Removes delete access granted by Opportunity_Manager</description>
    <objectPermissions>
        <object>Opportunity</object>
        <allowDelete>true</allowDelete>
        <!-- "true" in a muting PS means MUTE this permission -->
    </objectPermissions>
</PermissionSet>
```

Muting revokes the permission **only for users who get access through this group**. Direct assignments are unaffected.

## 4. Profile Metadata

Profiles are still required for: login hours/IP restrictions, page layout assignments, record type defaults, default app assignment.

### Minimal Profile Strategy

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <custom>true</custom>
    <description>Minimal profile - all access via Permission Sets</description>
    <userLicense>Salesforce</userLicense>
    <loginHours>
        <mondayStart>480</mondayStart>
        <mondayEnd>1080</mondayEnd>
    </loginHours>
    <layoutAssignments>
        <layout>Account-Account Layout</layout>
    </layoutAssignments>
</Profile>
```

Avoid putting object/field permissions in profiles. Use profiles only for what cannot be done through permission sets.

## 5. Object & Field Level Security (CRUD/FLS)

### CRUD Permissions Hierarchy

```
Read ─── required for ──→ Edit ─── required for ──→ Delete
 │                          │
 └── viewAllRecords         └── modifyAllRecords
     (bypasses sharing)         (bypasses sharing + ownership)
```

### FLS (Field-Level Security)

Each field has two flags: **Readable** and **Editable** (Editable requires Readable). FLS applies across UI, reports, list views, and API. A field hidden by FLS returns `null` in SOQL with `WITH USER_MODE`.

### FLS Audit Queries

```sql
-- Field permissions for a permission set
SELECT SobjectType, Field, PermissionsRead, PermissionsEdit
FROM FieldPermissions WHERE Parent.Name = 'Order_Manager'

-- Fields a user can edit (across all permission sets)
SELECT SobjectType, Field, PermissionsRead, PermissionsEdit
FROM FieldPermissions WHERE ParentId IN (
    SELECT PermissionSetId FROM PermissionSetAssignment
    WHERE AssigneeId = '005xx000001234AAA'
)

-- Who can edit a sensitive field?
SELECT Parent.Label, Parent.IsOwnedByProfile
FROM FieldPermissions
WHERE Field = 'Contact.SSN__c' AND PermissionsEdit = true
```

## 6. Custom Permissions

Custom permissions are boolean flags to control feature access without modifying code.

```xml
<!-- force-app/main/default/customPermissions/Can_Export_Data.customPermission-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<CustomPermission xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Can Export Data</label>
    <description>Allows user to export data from custom UI</description>
    <isLicensed>false</isLicensed>
</CustomPermission>
```

**Apex** (preferred):
```apex
if (FeatureManagement.checkPermission('Can_Export_Data')) {
    // user has the custom permission
}
```

**LWC**:
```javascript
import hasExportPermission from '@salesforce/customPermission/Can_Export_Data';
```

**Flow**: Use `$Permission.Can_Export_Data` in Decision elements (returns `true`/`false`).

## 7. Access Auditing

### PermissionSetAssignment Queries

```sql
-- All users assigned a permission set
SELECT Assignee.Name, Assignee.Username, Assignee.IsActive
FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Order_Manager'

-- All permission sets for a user (excluding profile-based)
SELECT PermissionSet.Label, PermissionSet.Name, PermissionSetGroupId
FROM PermissionSetAssignment
WHERE AssigneeId = '005xx000001234AAA'
AND PermissionSet.IsOwnedByProfile = false
```

### ObjectPermissions Queries

```sql
-- Who has Delete on an object?
SELECT Parent.Label, Parent.IsOwnedByProfile,
       PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords
FROM ObjectPermissions
WHERE SobjectType = 'Account' AND PermissionsDelete = true

-- Over-privileged check: ModifyAll on any object
SELECT Parent.Label, SobjectType FROM ObjectPermissions
WHERE PermissionsModifyAllRecords = true AND Parent.IsOwnedByProfile = false
```

### SetupEntityAccess (Apex/VF/Connected App)

```sql
-- Who has access to an Apex class?
SELECT Parent.Label FROM SetupEntityAccess
WHERE SetupEntityType = 'ApexClass'
AND SetupEntityId IN (SELECT Id FROM ApexClass WHERE Name = 'OrderService')

-- Connected App access
SELECT Parent.Label FROM SetupEntityAccess
WHERE SetupEntityType = 'ConnectedApplication'
AND SetupEntityId IN (SELECT Id FROM ConnectedApplication WHERE Name = 'DataLoader')
```

### Permission Set Group Membership

```sql
-- Permission sets in a group
SELECT PermissionSetGroup.MasterLabel, PermissionSet.Label
FROM PermissionSetGroupComponent
WHERE PermissionSetGroup.MasterLabel = 'Sales Team'

-- Groups containing a permission set
SELECT PermissionSetGroup.MasterLabel FROM PermissionSetGroupComponent
WHERE PermissionSet.Name = 'Opportunity_Manager'
```

## 8. Permission Troubleshooting

### INSUFFICIENT_ACCESS_OR_READONLY

User lacks Edit permission on the object or record. Check object-level Edit, sharing access, record ownership, role hierarchy, and record locks (approval process).

```sql
SELECT Parent.Label FROM ObjectPermissions
WHERE SobjectType = 'TargetObject__c' AND PermissionsEdit = true
AND ParentId IN (
    SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :userId
)
```

### INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY

User lacks access to a **related** record. Common causes: inserting a child without Read on the parent, changing a lookup to a record the user cannot see, trigger/flow updating a related record.

### "Insufficient Privileges" Error

Generic error meaning any of: missing Apex class access, VF page access, Lightning component access, tab visibility, Connected App access, or session-based permission set not activated.

```bash
# Quick CLI diagnosis
sf data query -q "SELECT PermissionSet.Label, PermissionSet.Name \
  FROM PermissionSetAssignment \
  WHERE Assignee.Username = 'user@example.com' \
  AND PermissionSet.IsOwnedByProfile = false" --target-org myOrg
```

## 9. Sharing vs Permissions

Permissions (CRUD/FLS) and sharing are independent layers:

| Layer | Question | Scope |
|-------|----------|-------|
| **CRUD** | Can the user create/read/edit/delete this object type? | Object-wide |
| **FLS** | Can the user see/edit this specific field? | Field-wide |
| **Sharing** | Which specific records can the user access? | Record-level |

A user needs BOTH the right CRUD/FLS permissions AND sharing access.

### OWD Settings

| Setting | Effect |
|---------|--------|
| Private | Only owner + role hierarchy above |
| Public Read Only | All users read, only owner edits |
| Public Read/Write | All users read and edit |
| Controlled by Parent | Determined by parent record (master-detail) |

### Record Access Determination Order

```
1. Record owner? → Full access
2. Above owner in role hierarchy? → Access per OWD
3. Sharing rules? → Read or Read/Write
4. Apex managed sharing? → Read or Read/Write
5. View All / Modify All on object? → Bypasses sharing
6. View All Data / Modify All Data? → Full access
```

### Key Distinctions

- `viewAllRecords`/`modifyAllRecords` bypasses sharing for that object
- `with sharing` in Apex enforces sharing but NOT CRUD/FLS
- `WITH USER_MODE` in SOQL enforces both sharing AND CRUD/FLS

## 10. Gotchas

- **Permission Set Groups recalculate asynchronously** — changes may take minutes. Check `PermissionSetGroup.Status` for `Updated` vs `Outdated`.
- **Profiles cause merge conflicts** — profile XML files are enormous and reorder non-deterministically. Prefer permission sets.
- **FLS does not restrict API access by default** — Apex runs in system mode. Use `WITH USER_MODE` or `Security.stripInaccessible()`.
- **Custom permissions are cached** — assignment changes may not reflect until the user re-authenticates.
- **Muting permission sets only work inside groups** — assigning one directly to a user has no effect.
- **Permission set licenses** — some require specific licenses. Assignment to users without the license may fail silently.
- **Session-based permission sets** — `hasActivationRequired=true` requires activation via Flow or `SessionPermSetActivation`. Not automatic.
- **`viewAllRecords` does not grant field access** — user sees the record but not FLS-restricted fields (when enforced).
- **IsOwnedByProfile** — every profile has a hidden permission set. Filter with `PermissionSet.IsOwnedByProfile = false` in queries.
- **Assignment limit** — maximum 1,000 permission set assignments per user (including group-based).

## 11. Workflow

### Setting Up Permissions for a New Feature

1. **Identify required access**: List objects, fields, Apex classes, VF pages, tabs, and custom permissions.
2. **Create Permission Set**: Generate `.permissionset-meta.xml` with least-privilege access.
3. **Create Custom Permissions** (if needed): Generate `.customPermission-meta.xml` for feature flags.
4. **Add to Permission Set Group** (if applicable): Update `.permissionsetgroup-meta.xml`.
5. **Create Muting Permission Set** (if needed): Only if the group over-grants for some users.
6. **Deploy**:
   ```bash
   sf project deploy start -d force-app/main/default/permissionsets \
     -d force-app/main/default/permissionsetgroups \
     -d force-app/main/default/customPermissions --target-org myOrg
   ```
7. **Assign**:
   ```bash
   sf org assign permset --name Order_Manager --target-org myOrg
   sf org assign permsetgroup --name Sales_Team --target-org myOrg
   ```
8. **Audit**:
   ```bash
   sf data query -q "SELECT Assignee.Name, PermissionSet.Label \
     FROM PermissionSetAssignment \
     WHERE PermissionSet.Name = 'Order_Manager'" --target-org myOrg
   ```

### Migrating from Profile to Permission Sets

1. Query all non-default permissions on the profile
2. Create equivalent permission sets for each functional area
3. Create a Permission Set Group matching the profile's role
4. Assign the group to affected users
5. Remove permissions from the profile (keep only layout, record type, login hours)
6. Validate with audit queries from Section 7

## References

- [Permissions Reference](references/permissions-reference.md) — complete Permission Set XML, audit queries, Apex/LWC/Flow permission checks, deployment best practices
- [Governor Limits](../../references/governor-limits.md) — per-transaction limits reference

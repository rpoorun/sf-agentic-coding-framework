# Jira Cloud Platform REST API v3 — Full Method Reference

| Field | Value |
| --- | --- |
| Skill | `jira-management` |
| Source | Official Atlassian OpenAPI 3.0.1 spec (`swagger-v3.v3.json`) for The Jira Cloud platform REST API |
| Spec snapshot | `1001.0.0-SNAPSHOT-3483ab4f777f667dfc438a82ade5da45e16de73e` |
| Generated | 2026-07-17 (`scripts/generate-api-reference.py`) |
| Base URL | `https://your-domain.atlassian.net` |
| Operations | **616** total — 275 GET, 134 POST, 118 PUT, 89 DELETE |
| Experimental | 114 operations flagged `x-experimental` |

This catalog lists **every operation** exposed by the Jira Cloud platform REST API v3, grouped by resource. It documents the full capability of the `jira-management` skill at the **user tier**. Which of these methods an agent may actually invoke in a given repo is governed by the **project-tier scope** (`jira.allowed_methods` / `jira.allowed_operations`) — see [SKILL.md](../SKILL.md#capability--scoping-model). Regenerate this file from a fresh spec download per [schema-structure.md](schema-structure.md#keeping-this-skill-current).

Legend: 🧪 = experimental (may change without notice, excluded from Atlassian's deprecation policy) · ⚠️ = deprecated. Operations under `/rest/atlassian-connect/` and `/rest/forge/` are for Connect/Forge apps and are not callable with basic auth; the internal endpoint is listed for completeness only and must not be used.

## Resource Group Index

| Resource group | GET | POST | PUT | DELETE | Total |
| --- | ---: | ---: | ---: | ---: | ---: |
| [Announcement banner](#announcement-banner) | 1 | 0 | 1 | 0 | 2 |
| [App data policies](#app-data-policies) | 2 | 0 | 0 | 0 | 2 |
| [App migration](#app-migration) | 0 | 1 | 2 | 0 | 3 |
| [App properties](#app-properties) | 4 | 0 | 2 | 2 | 8 |
| [Application roles](#application-roles) | 2 | 0 | 0 | 0 | 2 |
| [Audit records](#audit-records) | 1 | 0 | 0 | 0 | 1 |
| [Avatars](#avatars) | 5 | 1 | 0 | 1 | 7 |
| [Classification levels](#classification-levels) | 1 | 0 | 0 | 0 | 1 |
| [Dashboards](#dashboards) | 7 | 3 | 4 | 3 | 17 |
| [Dynamic modules](#dynamic-modules) | 1 | 1 | 0 | 1 | 3 |
| [Field schemes](#field-schemes) | 6 | 2 | 4 | 3 | 15 |
| [Filter sharing](#filter-sharing) | 3 | 1 | 1 | 1 | 6 |
| [Filters](#filters) | 5 | 1 | 4 | 3 | 13 |
| [Group and user picker](#group-and-user-picker) | 1 | 0 | 0 | 0 | 1 |
| [Groups](#groups) | 4 | 2 | 0 | 2 | 8 |
| [Internal (untagged)](#internal-untagged) | 0 | 1 | 0 | 0 | 1 |
| [Issue attachments](#issue-attachments) | 6 | 1 | 0 | 1 | 8 |
| [Issue bulk operations](#issue-bulk-operations) | 3 | 6 | 0 | 0 | 9 |
| [Issue comment properties](#issue-comment-properties) | 2 | 0 | 1 | 1 | 4 |
| [Issue comments](#issue-comments) | 2 | 2 | 1 | 1 | 6 |
| [Issue custom field associations](#issue-custom-field-associations) | 0 | 0 | 1 | 1 | 2 |
| [Issue custom field configuration (apps)](#issue-custom-field-configuration-apps) | 1 | 1 | 1 | 0 | 3 |
| [Issue custom field contexts](#issue-custom-field-contexts) | 5 | 4 | 4 | 1 | 14 |
| [Issue custom field options](#issue-custom-field-options) | 2 | 1 | 2 | 2 | 7 |
| [Issue custom field options (apps)](#issue-custom-field-options-apps) | 4 | 1 | 1 | 2 | 8 |
| [Issue custom field values (apps)](#issue-custom-field-values-apps) | 0 | 1 | 1 | 0 | 2 |
| [Issue field configurations](#issue-field-configurations) | 5 | 3 | 5 | 2 | 15 |
| [Issue fields](#issue-fields) | 6 | 3 | 1 | 1 | 11 |
| [Issue link types](#issue-link-types) | 2 | 1 | 1 | 1 | 5 |
| [Issue links](#issue-links) | 1 | 1 | 0 | 1 | 3 |
| [Issue navigator settings](#issue-navigator-settings) | 1 | 0 | 1 | 0 | 2 |
| [Issue notification schemes](#issue-notification-schemes) | 3 | 1 | 2 | 2 | 8 |
| [Issue panels](#issue-panels) | 0 | 1 | 0 | 0 | 1 |
| [Issue priorities](#issue-priorities) | 3 | 1 | 3 | 1 | 8 |
| [Issue properties](#issue-properties) | 2 | 2 | 2 | 2 | 8 |
| [Issue redaction](#issue-redaction) | 1 | 1 | 0 | 0 | 2 |
| [Issue remote links](#issue-remote-links) | 2 | 1 | 1 | 2 | 6 |
| [Issue resolutions](#issue-resolutions) | 3 | 1 | 3 | 1 | 8 |
| [Issue search](#issue-search) | 3 | 4 | 0 | 0 | 7 |
| [Issue security level](#issue-security-level) | 2 | 0 | 0 | 0 | 2 |
| [Issue security schemes](#issue-security-schemes) | 6 | 1 | 6 | 3 | 16 |
| [Issue type properties](#issue-type-properties) | 2 | 0 | 1 | 1 | 4 |
| [Issue type schemes](#issue-type-schemes) | 3 | 1 | 4 | 2 | 10 |
| [Issue type screen schemes](#issue-type-screen-schemes) | 4 | 2 | 4 | 1 | 11 |
| [Issue types](#issue-types) | 4 | 2 | 1 | 1 | 8 |
| [Issue votes](#issue-votes) | 1 | 1 | 0 | 1 | 3 |
| [Issue watchers](#issue-watchers) | 1 | 2 | 0 | 1 | 4 |
| [Issue worklog properties](#issue-worklog-properties) | 2 | 0 | 1 | 1 | 4 |
| [Issue worklogs](#issue-worklogs) | 4 | 3 | 1 | 2 | 10 |
| [Issues](#issues) | 9 | 8 | 5 | 1 | 23 |
| [Jira expressions](#jira-expressions) | 0 | 3 | 0 | 0 | 3 |
| [Jira settings](#jira-settings) | 3 | 0 | 1 | 0 | 4 |
| [JQL](#jql) | 2 | 4 | 0 | 0 | 6 |
| [JQL functions (apps)](#jql-functions-apps) | 1 | 2 | 0 | 0 | 3 |
| [Labels](#labels) | 1 | 0 | 0 | 0 | 1 |
| [License metrics](#license-metrics) | 3 | 0 | 0 | 0 | 3 |
| [Migration of Connect modules to Forge](#migration-of-connect-modules-to-forge) | 1 | 1 | 0 | 0 | 2 |
| [Myself](#myself) | 3 | 0 | 2 | 1 | 6 |
| [Permission schemes](#permission-schemes) | 4 | 2 | 1 | 2 | 9 |
| [Permissions](#permissions) | 2 | 2 | 0 | 0 | 4 |
| [Plans](#plans) | 2 | 2 | 3 | 0 | 7 |
| [Priority schemes](#priority-schemes) | 4 | 2 | 1 | 1 | 8 |
| [Project avatars](#project-avatars) | 1 | 1 | 1 | 1 | 4 |
| [Project categories](#project-categories) | 2 | 1 | 1 | 1 | 5 |
| [Project classification levels](#project-classification-levels) | 2 | 0 | 1 | 1 | 4 |
| [Project components](#project-components) | 5 | 1 | 1 | 1 | 8 |
| [Project email](#project-email) | 1 | 0 | 1 | 0 | 2 |
| [Project features](#project-features) | 1 | 0 | 1 | 0 | 2 |
| [Project key and name validation](#project-key-and-name-validation) | 3 | 0 | 0 | 0 | 3 |
| [Project permission schemes](#project-permission-schemes) | 3 | 0 | 1 | 0 | 4 |
| [Project properties](#project-properties) | 2 | 0 | 1 | 1 | 4 |
| [Project role actors](#project-role-actors) | 1 | 2 | 1 | 2 | 6 |
| [Project roles](#project-roles) | 5 | 2 | 1 | 1 | 9 |
| [Project templates](#project-templates) | 1 | 2 | 1 | 1 | 5 |
| [Project types](#project-types) | 4 | 0 | 0 | 0 | 4 |
| [Project versions](#project-versions) | 6 | 4 | 3 | 2 | 15 |
| [Projects](#projects) | 7 | 4 | 1 | 1 | 13 |
| [Screen schemes](#screen-schemes) | 1 | 1 | 1 | 1 | 4 |
| [Screen tab fields](#screen-tab-fields) | 1 | 2 | 0 | 1 | 4 |
| [Screen tabs](#screen-tabs) | 2 | 2 | 1 | 1 | 6 |
| [Screens](#screens) | 3 | 2 | 1 | 1 | 7 |
| [Server info](#server-info) | 1 | 0 | 0 | 0 | 1 |
| [Service Registry](#service-registry) | 1 | 0 | 0 | 0 | 1 |
| [Status](#status) | 6 | 1 | 1 | 1 | 9 |
| [Tasks](#tasks) | 1 | 1 | 0 | 0 | 2 |
| [Teams in plan](#teams-in-plan) | 3 | 2 | 2 | 2 | 9 |
| [Time tracking](#time-tracking) | 3 | 0 | 2 | 0 | 5 |
| [UI modifications (apps)](#ui-modifications-apps) | 1 | 1 | 1 | 1 | 4 |
| [User properties](#user-properties) | 2 | 0 | 1 | 1 | 4 |
| [User search](#user-search) | 8 | 0 | 0 | 0 | 8 |
| [Users](#users) | 9 | 1 | 1 | 2 | 13 |
| [Webhooks](#webhooks) | 2 | 1 | 1 | 1 | 5 |
| [Workflow scheme drafts](#workflow-scheme-drafts) | 4 | 2 | 4 | 4 | 14 |
| [Workflow scheme project associations](#workflow-scheme-project-associations) | 1 | 0 | 1 | 0 | 2 |
| [Workflow schemes](#workflow-schemes) | 6 | 5 | 4 | 4 | 19 |
| [Workflow status categories](#workflow-status-categories) | 2 | 0 | 0 | 0 | 2 |
| [Workflow statuses](#workflow-statuses) | 2 | 0 | 0 | 0 | 2 |
| [Workflow transition rules](#workflow-transition-rules) | 1 | 0 | 2 | 0 | 3 |
| [Workflows](#workflows) | 7 | 8 | 0 | 1 | 16 |
| **Total** | **275** | **134** | **118** | **89** | **616** |

## Method Catalog

### Announcement banner

This resource represents an announcement banner. Use it to retrieve and update banner configuration.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/announcementBanner` | `getBanner` | Get announcement banner configuration |
| PUT | `/rest/api/3/announcementBanner` | `setBanner` | Update announcement banner configuration |

### App data policies

This resource represents app access rule data policies.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/data-policy` | `getPolicy` | Get data policy for the workspace |
| GET | `/rest/api/3/data-policy/project` | `getPolicies` | Get data policy for projects |

### App migration

This resource supports [app migrations](https://developer.atlassian.com/platform/app-migration/). Use it to:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| PUT | `/rest/atlassian-connect/1/migration/field` | `AppIssueFieldValueUpdateResource.updateIssueFields_put` | Bulk update custom field value |
| PUT | `/rest/atlassian-connect/1/migration/properties/{entityType}` | `MigrationResource.updateEntityPropertiesValue_put` | Bulk update entity properties |
| POST | `/rest/atlassian-connect/1/migration/workflow/rule/search` | `MigrationResource.workflowRuleSearch_post` | Get workflow transition rule configurations |

### App properties

This resource represents app properties. Use it to store arbitrary data for your

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/atlassian-connect/1/addons/{addonKey}/properties` | `AddonPropertiesResource.getAddonProperties_get` | Get app properties |
| GET | `/rest/atlassian-connect/1/addons/{addonKey}/properties/{propertyKey}` | `AddonPropertiesResource.getAddonProperty_get` | Get app property |
| PUT | `/rest/atlassian-connect/1/addons/{addonKey}/properties/{propertyKey}` | `AddonPropertiesResource.putAddonProperty_put` | Set app property |
| DELETE | `/rest/atlassian-connect/1/addons/{addonKey}/properties/{propertyKey}` | `AddonPropertiesResource.deleteAddonProperty_delete` | Delete app property |
| GET | `/rest/forge/1/app/properties` | `getForgeAppPropertyKeys` | Get app property keys (Forge) |
| GET | `/rest/forge/1/app/properties/{propertyKey}` | `getForgeAppProperty` | Get app property (Forge) |
| PUT | `/rest/forge/1/app/properties/{propertyKey}` | `putForgeAppProperty` | Set app property (Forge) |
| DELETE | `/rest/forge/1/app/properties/{propertyKey}` | `deleteForgeAppProperty` | Delete app property (Forge) |

### Application roles

This resource represents application roles. Use it to get details of an application role or all application roles.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/applicationrole` | `getAllApplicationRoles` | Get all application roles |
| GET | `/rest/api/3/applicationrole/{key}` | `getApplicationRole` | Get application role |

### Audit records

This resource represents audits that record activities undertaken in Jira. Use it to get a list of audit records.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/auditing/record` | `getAuditRecords` | Get audit records |

### Avatars

This resource represents system and custom avatars. Use it to obtain the details of system or custom avatars, add and remove avatars from a project, issue type or priority and obtain avatar images.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/avatar/{type}/system` | `getAllSystemAvatars` | Get system avatars by type |
| GET | `/rest/api/3/universal_avatar/type/{type}/owner/{entityId}` | `getAvatars` | Get avatars |
| POST | `/rest/api/3/universal_avatar/type/{type}/owner/{entityId}` | `storeAvatar` | Load avatar |
| DELETE | `/rest/api/3/universal_avatar/type/{type}/owner/{owningObjectId}/avatar/{id}` | `deleteAvatar` | Delete avatar |
| GET | `/rest/api/3/universal_avatar/view/type/{type}` | `getAvatarImageByType` | Get avatar image by type |
| GET | `/rest/api/3/universal_avatar/view/type/{type}/avatar/{id}` | `getAvatarImageByID` | Get avatar image by ID |
| GET | `/rest/api/3/universal_avatar/view/type/{type}/owner/{entityId}` | `getAvatarImageByOwner` | Get avatar image by owner |

### Classification levels

This resource represents classification levels.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/classification-levels` | `getAllUserDataClassificationLevels` | Get all classification levels 🧪 |

### Dashboards

This resource represents dashboards. Use it to obtain the details of dashboards as well as get, create, update, or remove item properties and gadgets from dashboards.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/dashboard` | `getAllDashboards` | Get all dashboards |
| POST | `/rest/api/3/dashboard` | `createDashboard` | Create dashboard 🧪 |
| PUT | `/rest/api/3/dashboard/bulk/edit` | `bulkEditDashboards` | Bulk edit dashboards 🧪 |
| GET | `/rest/api/3/dashboard/gadgets` | `getAllAvailableDashboardGadgets` | Get available gadgets 🧪 |
| GET | `/rest/api/3/dashboard/search` | `getDashboardsPaginated` | Search for dashboards |
| GET | `/rest/api/3/dashboard/{dashboardId}/gadget` | `getAllGadgets` | Get gadgets 🧪 |
| POST | `/rest/api/3/dashboard/{dashboardId}/gadget` | `addGadget` | Add gadget to dashboard 🧪 |
| PUT | `/rest/api/3/dashboard/{dashboardId}/gadget/{gadgetId}` | `updateGadget` | Update gadget on dashboard 🧪 |
| DELETE | `/rest/api/3/dashboard/{dashboardId}/gadget/{gadgetId}` | `removeGadget` | Remove gadget from dashboard 🧪 |
| GET | `/rest/api/3/dashboard/{dashboardId}/items/{itemId}/properties` | `getDashboardItemPropertyKeys` | Get dashboard item property keys |
| GET | `/rest/api/3/dashboard/{dashboardId}/items/{itemId}/properties/{propertyKey}` | `getDashboardItemProperty` | Get dashboard item property |
| PUT | `/rest/api/3/dashboard/{dashboardId}/items/{itemId}/properties/{propertyKey}` | `setDashboardItemProperty` | Set dashboard item property |
| DELETE | `/rest/api/3/dashboard/{dashboardId}/items/{itemId}/properties/{propertyKey}` | `deleteDashboardItemProperty` | Delete dashboard item property |
| GET | `/rest/api/3/dashboard/{id}` | `getDashboard` | Get dashboard |
| PUT | `/rest/api/3/dashboard/{id}` | `updateDashboard` | Update dashboard 🧪 |
| DELETE | `/rest/api/3/dashboard/{id}` | `deleteDashboard` | Delete dashboard 🧪 |
| POST | `/rest/api/3/dashboard/{id}/copy` | `copyDashboard` | Copy dashboard 🧪 |

### Dynamic modules

This resource represents [modules registered dynamically](https://developer.atlassian.com/cloud/jira/platform/dynamic-modules/)

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/atlassian-connect/1/app/module/dynamic` | `DynamicModulesResource.getModules_get` | Get modules |
| POST | `/rest/atlassian-connect/1/app/module/dynamic` | `DynamicModulesResource.registerModules_post` | Register modules |
| DELETE | `/rest/atlassian-connect/1/app/module/dynamic` | `DynamicModulesResource.removeModules_delete` | Remove modules |

### Field schemes

This resource represents field schemes which are replacing field configuration schemes to control field associations. They are currently in beta and only available to customers who have opted-in to the beta program. For more information see [RFC-103: Jira Field Configuration Overhaul: Admin Experience and API Changes](https://community.developer.atlassian.com/t/rfc-103-jira-field-configuration-overhaul-admin-experience-and-api-changes/94205)

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/config/fieldschemes` | `getFieldAssociationSchemes` | Get field schemes 🧪 |
| POST | `/rest/api/3/config/fieldschemes` | `createFieldAssociationScheme` | Create field scheme 🧪 |
| PUT | `/rest/api/3/config/fieldschemes/fields` | `updateFieldsAssociatedWithSchemes` | Update fields associated with field schemes 🧪 |
| DELETE | `/rest/api/3/config/fieldschemes/fields` | `removeFieldsAssociatedWithSchemes` | Remove fields associated with field schemes 🧪 |
| PUT | `/rest/api/3/config/fieldschemes/fields/parameters` | `updateFieldAssociationSchemeItemParameters` | Update field parameters 🧪 |
| DELETE | `/rest/api/3/config/fieldschemes/fields/parameters` | `removeFieldAssociationSchemeItemParameters` | Remove field parameters 🧪 |
| GET | `/rest/api/3/config/fieldschemes/projects` | `getProjectsWithFieldSchemes` | Get projects with field schemes 🧪 |
| PUT | `/rest/api/3/config/fieldschemes/projects` | `associateProjectsToFieldAssociationSchemes` | Associate projects to field schemes 🧪 |
| GET | `/rest/api/3/config/fieldschemes/{id}` | `getFieldAssociationSchemeById` | Get field scheme 🧪 |
| PUT | `/rest/api/3/config/fieldschemes/{id}` | `updateFieldAssociationScheme` | Update field scheme 🧪 |
| DELETE | `/rest/api/3/config/fieldschemes/{id}` | `deleteFieldAssociationScheme` | Delete a field scheme 🧪 |
| POST | `/rest/api/3/config/fieldschemes/{id}/clone` | `cloneFieldAssociationScheme` | Clone field scheme 🧪 |
| GET | `/rest/api/3/config/fieldschemes/{id}/fields` | `searchFieldAssociationSchemeFields` | Search field scheme fields 🧪 |
| GET | `/rest/api/3/config/fieldschemes/{id}/fields/{fieldId}/parameters` | `getFieldAssociationSchemeItemParameters` | Get field parameters 🧪 |
| GET | `/rest/api/3/config/fieldschemes/{id}/projects` | `searchFieldAssociationSchemeProjects` | Search field scheme projects 🧪 |

### Filter sharing

This resource represents options for sharing [filters](#api-group-Filters). Use it to get share scopes as well as add and remove share scopes from filters.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/filter/defaultShareScope` | `getDefaultShareScope` | Get default share scope |
| PUT | `/rest/api/3/filter/defaultShareScope` | `setDefaultShareScope` | Set default share scope |
| GET | `/rest/api/3/filter/{id}/permission` | `getSharePermissions` | Get share permissions |
| POST | `/rest/api/3/filter/{id}/permission` | `addSharePermission` | Add share permission |
| GET | `/rest/api/3/filter/{id}/permission/{permissionId}` | `getSharePermission` | Get share permission |
| DELETE | `/rest/api/3/filter/{id}/permission/{permissionId}` | `deleteSharePermission` | Delete share permission |

### Filters

This resource represents [filters](https://confluence.atlassian.com/x/eQiiLQ). Use it to get, create, update, or delete filters. Also use it to configure the columns for a filter and set favorite filters.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/filter` | `createFilter` | Create filter |
| GET | `/rest/api/3/filter/favourite` | `getFavouriteFilters` | Get favorite filters |
| GET | `/rest/api/3/filter/my` | `getMyFilters` | Get my filters |
| GET | `/rest/api/3/filter/search` | `getFiltersPaginated` | Search for filters |
| GET | `/rest/api/3/filter/{id}` | `getFilter` | Get filter |
| PUT | `/rest/api/3/filter/{id}` | `updateFilter` | Update filter |
| DELETE | `/rest/api/3/filter/{id}` | `deleteFilter` | Delete filter |
| GET | `/rest/api/3/filter/{id}/columns` | `getColumns` | Get columns |
| PUT | `/rest/api/3/filter/{id}/columns` | `setColumns` | Set columns |
| DELETE | `/rest/api/3/filter/{id}/columns` | `resetColumns` | Reset columns |
| PUT | `/rest/api/3/filter/{id}/favourite` | `setFavouriteForFilter` | Add filter as favorite |
| DELETE | `/rest/api/3/filter/{id}/favourite` | `deleteFavouriteForFilter` | Remove filter as favorite |
| PUT | `/rest/api/3/filter/{id}/owner` | `changeFilterOwner` | Change filter owner 🧪 |

### Group and user picker

This resource represents a list of users and a list of groups. Use it to obtain the details to populate user and group picker suggestions list.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/groupuserpicker` | `findUsersAndGroups` | Find users and groups |

### Groups

This resource represents groups of users. Use it to get, create, find, and delete groups as well as add and remove users from groups. (\[WARNING\] The standard Atlassian group names are default names only and can be edited or deleted. For example, an admin or Atlassian support could delete the default group jira-software-users or rename it to jsw-users at any point. See https://support.atlassian.com/user-management/docs/create-and-update-groups/ for details.)

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/group` | `getGroup` | Get group ⚠️ |
| POST | `/rest/api/3/group` | `createGroup` | Create group |
| DELETE | `/rest/api/3/group` | `removeGroup` | Remove group |
| GET | `/rest/api/3/group/bulk` | `bulkGetGroups` | Bulk get groups 🧪 |
| GET | `/rest/api/3/group/member` | `getUsersFromGroup` | Get users from group |
| POST | `/rest/api/3/group/user` | `addUserToGroup` | Add user to group |
| DELETE | `/rest/api/3/group/user` | `removeUserFromGroup` | Remove user from group |
| GET | `/rest/api/3/groups/picker` | `findGroups` | Find groups |

### Internal (untagged)

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/internal/api/latest/worklog/bulk` | `getWorklogsByIssueIdAndWorklogId` | Get worklogs by issue id and worklog id |

### Issue attachments

This resource represents issue attachments and the attachment settings for Jira. Use it to get the metadata for an attachment, delete an attachment, and view the metadata for the contents of an attachment. Also, use it to get the attachment settings for Jira.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/attachment/content/{id}` | `getAttachmentContent` | Get attachment content |
| GET | `/rest/api/3/attachment/meta` | `getAttachmentMeta` | Get Jira attachment settings |
| GET | `/rest/api/3/attachment/thumbnail/{id}` | `getAttachmentThumbnail` | Get attachment thumbnail |
| GET | `/rest/api/3/attachment/{id}` | `getAttachment` | Get attachment metadata |
| DELETE | `/rest/api/3/attachment/{id}` | `removeAttachment` | Delete attachment |
| GET | `/rest/api/3/attachment/{id}/expand/human` | `expandAttachmentForHumans` | Get all metadata for an expanded attachment 🧪 |
| GET | `/rest/api/3/attachment/{id}/expand/raw` | `expandAttachmentForMachines` | Get contents metadata for an expanded attachment 🧪 |
| POST | `/rest/api/3/issue/{issueIdOrKey}/attachments` | `addAttachment` | Add attachment |

### Issue bulk operations

This resource represents the issue bulk operations. Use it to move multiple issues from one project to another project or edit fields of multiple issues in one go.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/bulk/issues/delete` | `submitBulkDelete` | Bulk delete issues |
| GET | `/rest/api/3/bulk/issues/fields` | `getBulkEditableFields` | Get bulk editable fields |
| POST | `/rest/api/3/bulk/issues/fields` | `submitBulkEdit` | Bulk edit issues |
| POST | `/rest/api/3/bulk/issues/move` | `submitBulkMove` | Bulk move issues |
| GET | `/rest/api/3/bulk/issues/transition` | `getAvailableTransitions` | Get available transitions |
| POST | `/rest/api/3/bulk/issues/transition` | `submitBulkTransition` | Bulk transition issue statuses |
| POST | `/rest/api/3/bulk/issues/unwatch` | `submitBulkUnwatch` | Bulk unwatch issues |
| POST | `/rest/api/3/bulk/issues/watch` | `submitBulkWatch` | Bulk watch issues |
| GET | `/rest/api/3/bulk/queue/{taskId}` | `getBulkOperationProgress` | Get bulk issue operation progress |

### Issue comment properties

This resource represents [issue comment](#api-group-Issue-comments) properties, which provides for storing custom data against an issue comment. Use is to get, set, and delete issue comment properties as well as obtain the keys of all properties on a comment. Comment properties are a type of [entity property](https://developer.atlassian.com/cloud/jira/platform/jira-entity-properties/).

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/comment/{commentId}/properties` | `getCommentPropertyKeys` | Get comment property keys |
| GET | `/rest/api/3/comment/{commentId}/properties/{propertyKey}` | `getCommentProperty` | Get comment property |
| PUT | `/rest/api/3/comment/{commentId}/properties/{propertyKey}` | `setCommentProperty` | Set comment property |
| DELETE | `/rest/api/3/comment/{commentId}/properties/{propertyKey}` | `deleteCommentProperty` | Delete comment property |

### Issue comments

This resource represents issue comments. Use it to:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/comment/list` | `getCommentsByIds` | Get comments by IDs |
| GET | `/rest/api/3/issue/{issueIdOrKey}/comment` | `getComments` | Get comments |
| POST | `/rest/api/3/issue/{issueIdOrKey}/comment` | `addComment` | Add comment |
| GET | `/rest/api/3/issue/{issueIdOrKey}/comment/{id}` | `getComment` | Get comment |
| PUT | `/rest/api/3/issue/{issueIdOrKey}/comment/{id}` | `updateComment` | Update comment |
| DELETE | `/rest/api/3/issue/{issueIdOrKey}/comment/{id}` | `deleteComment` | Delete comment |

### Issue custom field associations

This resource represents the fields associated to project and issue type contexts. Use it to:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| PUT | `/rest/api/3/field/association` | `createAssociations` | Create associations |
| DELETE | `/rest/api/3/field/association` | `removeAssociations` | Remove associations |

### Issue custom field configuration (apps)

This resource represents configurations stored against a custom field context by a [Forge app](https://developer.atlassian.com/platform/forge/). Configurations are information used by the Forge app at runtime to determine how to handle or process the data in a custom field in a given context. Use this resource to set and read configurations.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/app/field/context/configuration/list` | `getCustomFieldsConfigurations` | Bulk get custom field configurations 🧪 |
| GET | `/rest/api/3/app/field/{fieldIdOrKey}/context/configuration` | `getCustomFieldConfiguration` | Get custom field configurations |
| PUT | `/rest/api/3/app/field/{fieldIdOrKey}/context/configuration` | `updateCustomFieldConfiguration` | Update custom field configurations |

### Issue custom field contexts

This resource represents issue custom field contexts. Use it to:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/field/{fieldId}/context` | `getContextsForField` | Get custom field contexts |
| POST | `/rest/api/3/field/{fieldId}/context` | `createCustomFieldContext` | Create custom field context |
| GET | `/rest/api/3/field/{fieldId}/context/defaultValue` | `getDefaultValues` | Get custom field contexts default values ⚠️ |
| PUT | `/rest/api/3/field/{fieldId}/context/defaultValue` | `setDefaultValues` | Set custom field contexts default values ⚠️ |
| GET | `/rest/api/3/field/{fieldId}/context/defaultValues` | `getContextDefaultValues` | Get default values for a custom field grouped by context and issue type |
| GET | `/rest/api/3/field/{fieldId}/context/issuetypemapping` | `getIssueTypeMappingsForContexts` | Get issue types for custom field context |
| POST | `/rest/api/3/field/{fieldId}/context/mapping` | `getCustomFieldContextsForProjectsAndIssueTypes` | Get custom field contexts for projects and issue types |
| GET | `/rest/api/3/field/{fieldId}/context/projectmapping` | `getProjectContextMapping` | Get project mappings for custom field context |
| PUT | `/rest/api/3/field/{fieldId}/context/{contextId}` | `updateCustomFieldContext` | Update custom field context |
| DELETE | `/rest/api/3/field/{fieldId}/context/{contextId}` | `deleteCustomFieldContext` | Delete custom field context |
| PUT | `/rest/api/3/field/{fieldId}/context/{contextId}/issuetype` | `addIssueTypesToContext` | Add issue types to context |
| POST | `/rest/api/3/field/{fieldId}/context/{contextId}/issuetype/remove` | `removeIssueTypesFromContext` | Remove issue types from context |
| PUT | `/rest/api/3/field/{fieldId}/context/{contextId}/project` | `assignProjectsToCustomFieldContext` | Assign custom field context to projects |
| POST | `/rest/api/3/field/{fieldId}/context/{contextId}/project/remove` | `removeCustomFieldContextFromProjects` | Remove custom field context from projects |

### Issue custom field options

This resource represents custom issue field select list options created in Jira or using the REST API. This resource supports the following field types:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/customFieldOption/{id}` | `getCustomFieldOption` | Get custom field option |
| GET | `/rest/api/3/field/{fieldId}/context/{contextId}/option` | `getOptionsForContext` | Get custom field options (context) |
| POST | `/rest/api/3/field/{fieldId}/context/{contextId}/option` | `createCustomFieldOption` | Create custom field options (context) |
| PUT | `/rest/api/3/field/{fieldId}/context/{contextId}/option` | `updateCustomFieldOption` | Update custom field options (context) |
| PUT | `/rest/api/3/field/{fieldId}/context/{contextId}/option/move` | `reorderCustomFieldOptions` | Reorder custom field options (context) |
| DELETE | `/rest/api/3/field/{fieldId}/context/{contextId}/option/{optionId}` | `deleteCustomFieldOption` | Delete custom field options (context) |
| DELETE | `/rest/api/3/field/{fieldId}/context/{contextId}/option/{optionId}/issue` | `replaceCustomFieldOption` | Replace custom field options |

### Issue custom field options (apps)

This resource represents custom issue field select list options created by a Connect app. See [Issue custom field options](#api-group-Issue-custom-field-options) to manipulate options created in Jira or using the REST API.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/field/{fieldKey}/option` | `getAllIssueFieldOptions` | Get all issue field options |
| POST | `/rest/api/3/field/{fieldKey}/option` | `createIssueFieldOption` | Create issue field option |
| GET | `/rest/api/3/field/{fieldKey}/option/suggestions/edit` | `getSelectableIssueFieldOptions` | Get selectable issue field options |
| GET | `/rest/api/3/field/{fieldKey}/option/suggestions/search` | `getVisibleIssueFieldOptions` | Get visible issue field options |
| GET | `/rest/api/3/field/{fieldKey}/option/{optionId}` | `getIssueFieldOption` | Get issue field option |
| PUT | `/rest/api/3/field/{fieldKey}/option/{optionId}` | `updateIssueFieldOption` | Update issue field option |
| DELETE | `/rest/api/3/field/{fieldKey}/option/{optionId}` | `deleteIssueFieldOption` | Delete issue field option |
| DELETE | `/rest/api/3/field/{fieldKey}/option/{optionId}/issue` | `replaceIssueFieldOption` | Replace issue field option |

### Issue custom field values (apps)

This resource represents the values of custom fields added by [Forge apps](https://developer.atlassian.com/platform/forge/). Use it to update the value of a custom field on issues.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/app/field/value` | `updateMultipleCustomFieldValues` | Update custom fields |
| PUT | `/rest/api/3/app/field/{fieldIdOrKey}/value` | `updateCustomFieldValue` | Update custom field value |

### Issue field configurations

This resource represents issue field configurations. Use it to get, set, and delete field configurations and field configuration schemes.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/fieldconfiguration` | `getAllFieldConfigurations` | Get all field configurations ⚠️ |
| POST | `/rest/api/3/fieldconfiguration` | `createFieldConfiguration` | Create field configuration ⚠️ |
| PUT | `/rest/api/3/fieldconfiguration/{id}` | `updateFieldConfiguration` | Update field configuration ⚠️ |
| DELETE | `/rest/api/3/fieldconfiguration/{id}` | `deleteFieldConfiguration` | Delete field configuration ⚠️ |
| GET | `/rest/api/3/fieldconfiguration/{id}/fields` | `getFieldConfigurationItems` | Get field configuration items ⚠️ |
| PUT | `/rest/api/3/fieldconfiguration/{id}/fields` | `updateFieldConfigurationItems` | Update field configuration items ⚠️ |
| GET | `/rest/api/3/fieldconfigurationscheme` | `getAllFieldConfigurationSchemes` | Get all field configuration schemes ⚠️ |
| POST | `/rest/api/3/fieldconfigurationscheme` | `createFieldConfigurationScheme` | Create field configuration scheme ⚠️ |
| GET | `/rest/api/3/fieldconfigurationscheme/mapping` | `getFieldConfigurationSchemeMappings` | Get field configuration issue type items ⚠️ |
| GET | `/rest/api/3/fieldconfigurationscheme/project` | `getFieldConfigurationSchemeProjectMapping` | Get field configuration schemes for projects ⚠️ |
| PUT | `/rest/api/3/fieldconfigurationscheme/project` | `assignFieldConfigurationSchemeToProject` | Assign field configuration scheme to project ⚠️ |
| PUT | `/rest/api/3/fieldconfigurationscheme/{id}` | `updateFieldConfigurationScheme` | Update field configuration scheme ⚠️ |
| DELETE | `/rest/api/3/fieldconfigurationscheme/{id}` | `deleteFieldConfigurationScheme` | Delete field configuration scheme ⚠️ |
| PUT | `/rest/api/3/fieldconfigurationscheme/{id}/mapping` | `setFieldConfigurationSchemeMapping` | Assign issue types to field configurations ⚠️ |
| POST | `/rest/api/3/fieldconfigurationscheme/{id}/mapping/delete` | `removeIssueTypesFromGlobalFieldConfigurationScheme` | Remove issue types from field configuration scheme ⚠️ |

### Issue fields

This resource represents issue fields, both system and custom fields. Use it to get fields, field configurations, and create custom fields.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/field` | `getFields` | Get fields |
| POST | `/rest/api/3/field` | `createCustomField` | Create custom field |
| GET | `/rest/api/3/field/search` | `getFieldsPaginated` | Get fields paginated |
| GET | `/rest/api/3/field/search/trashed` | `getTrashedFieldsPaginated` | Get fields in trash paginated |
| PUT | `/rest/api/3/field/{fieldId}` | `updateCustomField` | Update custom field |
| GET | `/rest/api/3/field/{fieldId}/association/project` | `getFieldProjectAssociations` | Get field project associations 🧪 |
| GET | `/rest/api/3/field/{fieldId}/contexts` | `getContextsForFieldDeprecated` | Get contexts for a field ⚠️ |
| DELETE | `/rest/api/3/field/{id}` | `deleteCustomField` | Delete custom field |
| POST | `/rest/api/3/field/{id}/restore` | `restoreCustomField` | Restore custom field from trash |
| POST | `/rest/api/3/field/{id}/trash` | `trashCustomField` | Move custom field to trash |
| GET | `/rest/api/3/projects/fields` | `getProjectFields` | Get fields for projects 🧪 |

### Issue link types

This resource represents [issue link](#api-group-Issue-links) types. Use it to get, create, update, and delete link issue types as well as get lists of all link issue types.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/issueLinkType` | `getIssueLinkTypes` | Get issue link types |
| POST | `/rest/api/3/issueLinkType` | `createIssueLinkType` | Create issue link type |
| GET | `/rest/api/3/issueLinkType/{issueLinkTypeId}` | `getIssueLinkType` | Get issue link type |
| PUT | `/rest/api/3/issueLinkType/{issueLinkTypeId}` | `updateIssueLinkType` | Update issue link type |
| DELETE | `/rest/api/3/issueLinkType/{issueLinkTypeId}` | `deleteIssueLinkType` | Delete issue link type |

### Issue links

This resource represents links between issues. Use it to get, create, and delete links between issues.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/issueLink` | `linkIssues` | Create issue link |
| GET | `/rest/api/3/issueLink/{linkId}` | `getIssueLink` | Get issue link |
| DELETE | `/rest/api/3/issueLink/{linkId}` | `deleteIssueLink` | Delete issue link |

### Issue navigator settings

This resource represents issue navigator settings. Use it to get and set issue navigator default columns.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/settings/columns` | `getIssueNavigatorDefaultColumns` | Get issue navigator default columns |
| PUT | `/rest/api/3/settings/columns` | `setIssueNavigatorDefaultColumns` | Set issue navigator default columns |

### Issue notification schemes

This resource represents notification schemes, lists of events and the recipients who will receive notifications for those events. Use it to get details of a notification scheme and a list of notification schemes.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/notificationscheme` | `getNotificationSchemes` | Get notification schemes paginated |
| POST | `/rest/api/3/notificationscheme` | `createNotificationScheme` | Create notification scheme 🧪 |
| GET | `/rest/api/3/notificationscheme/project` | `getNotificationSchemeToProjectMappings` | Get projects using notification schemes paginated |
| GET | `/rest/api/3/notificationscheme/{id}` | `getNotificationScheme` | Get notification scheme |
| PUT | `/rest/api/3/notificationscheme/{id}` | `updateNotificationScheme` | Update notification scheme 🧪 |
| PUT | `/rest/api/3/notificationscheme/{id}/notification` | `addNotifications` | Add notifications to notification scheme |
| DELETE | `/rest/api/3/notificationscheme/{notificationSchemeId}` | `deleteNotificationScheme` | Delete notification scheme 🧪 |
| DELETE | `/rest/api/3/notificationscheme/{notificationSchemeId}/notification/{notificationId}` | `removeNotificationFromNotificationScheme` | Remove notification from notification scheme |

### Issue panels

This resource supports bulk pinning and unpinning of [issue panels](https://developer.atlassian.com/platform/forge/) that are added by a Forge app. Only Jira administrators can use it.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/forge/panel/action/bulk/async` | `bulkPinUnpinProjectsAsync` | Bulk pin or unpin issue panel to projects |

### Issue priorities

This resource represents issue priorities. Use it to get, create and update issue priorities and details for individual issue priorities.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/priority` | `getPriorities` | Get priorities ⚠️ |
| POST | `/rest/api/3/priority` | `createPriority` | Create priority |
| PUT | `/rest/api/3/priority/default` | `setDefaultPriority` | Set default priority |
| PUT | `/rest/api/3/priority/move` | `movePriorities` | Move priorities |
| GET | `/rest/api/3/priority/search` | `searchPriorities` | Search priorities |
| GET | `/rest/api/3/priority/{id}` | `getPriority` | Get priority |
| PUT | `/rest/api/3/priority/{id}` | `updatePriority` | Update priority |
| DELETE | `/rest/api/3/priority/{id}` | `deletePriority` | Delete priority |

### Issue properties

This resource represents [issue](#api-group-Issues) properties, which provides for storing custom data against an issue. Use it to get, set, and delete issue properties as well as obtain details of all properties on an issue. Operations to bulk update and delete issue properties are also provided. Issue properties are a type of [entity property](https://developer.atlassian.com/cloud/jira/platform/jira-entity-properties/).

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/issue/properties` | `bulkSetIssuesPropertiesList` | Bulk set issues properties by list |
| POST | `/rest/api/3/issue/properties/multi` | `bulkSetIssuePropertiesByIssue` | Bulk set issue properties by issue |
| PUT | `/rest/api/3/issue/properties/{propertyKey}` | `bulkSetIssueProperty` | Bulk set issue property |
| DELETE | `/rest/api/3/issue/properties/{propertyKey}` | `bulkDeleteIssueProperty` | Bulk delete issue property |
| GET | `/rest/api/3/issue/{issueIdOrKey}/properties` | `getIssuePropertyKeys` | Get issue property keys |
| GET | `/rest/api/3/issue/{issueIdOrKey}/properties/{propertyKey}` | `getIssueProperty` | Get issue property |
| PUT | `/rest/api/3/issue/{issueIdOrKey}/properties/{propertyKey}` | `setIssueProperty` | Set issue property |
| DELETE | `/rest/api/3/issue/{issueIdOrKey}/properties/{propertyKey}` | `deleteIssueProperty` | Delete issue property |

### Issue redaction

This resource represents Issue Redaction. Provides APIs to redact issue data.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/redact` | `redact` | Redact |
| GET | `/rest/api/3/redact/status/{jobId}` | `getRedactionStatus` | Get redaction status |

### Issue remote links

This resource represents remote issue links, a way of linking Jira to information in other systems. Use it to get, create, update, and delete remote issue links either by ID or global ID. The global ID provides a way of accessing remote issue links using information about the item's remote system host and remote system identifier.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/issue/{issueIdOrKey}/remotelink` | `getRemoteIssueLinks` | Get remote issue links |
| POST | `/rest/api/3/issue/{issueIdOrKey}/remotelink` | `createOrUpdateRemoteIssueLink` | Create or update remote issue link |
| DELETE | `/rest/api/3/issue/{issueIdOrKey}/remotelink` | `deleteRemoteIssueLinkByGlobalId` | Delete remote issue link by global ID |
| GET | `/rest/api/3/issue/{issueIdOrKey}/remotelink/{linkId}` | `getRemoteIssueLinkById` | Get remote issue link by ID |
| PUT | `/rest/api/3/issue/{issueIdOrKey}/remotelink/{linkId}` | `updateRemoteIssueLink` | Update remote issue link by ID |
| DELETE | `/rest/api/3/issue/{issueIdOrKey}/remotelink/{linkId}` | `deleteRemoteIssueLinkById` | Delete remote issue link by ID |

### Issue resolutions

This resource represents issue resolution values. Use it to obtain a list of all issue resolution values and the details of individual resolution values.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/resolution` | `getResolutions` | Get resolutions ⚠️ |
| POST | `/rest/api/3/resolution` | `createResolution` | Create resolution 🧪 |
| PUT | `/rest/api/3/resolution/default` | `setDefaultResolution` | Set default resolution 🧪 |
| PUT | `/rest/api/3/resolution/move` | `moveResolutions` | Move resolutions 🧪 |
| GET | `/rest/api/3/resolution/search` | `searchResolutions` | Search resolutions 🧪 |
| GET | `/rest/api/3/resolution/{id}` | `getResolution` | Get resolution |
| PUT | `/rest/api/3/resolution/{id}` | `updateResolution` | Update resolution 🧪 |
| DELETE | `/rest/api/3/resolution/{id}` | `deleteResolution` | Delete resolution 🧪 |

### Issue search

This resource represents various ways to search for issues. Use it to search for issues with a JQL query and find issues to populate an issue picker.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/issue/picker` | `getIssuePickerResource` | Get issue picker suggestions |
| POST | `/rest/api/3/jql/match` | `matchIssues` | Check issues against JQL |
| GET | `/rest/api/3/search` | `searchForIssuesUsingJql` | Currently being removed. Search for issues using JQL (GET) ⚠️ |
| POST | `/rest/api/3/search` | `searchForIssuesUsingJqlPost` | Currently being removed. Search for issues using JQL (POST) ⚠️ |
| POST | `/rest/api/3/search/approximate-count` | `countIssues` | Count issues using JQL |
| GET | `/rest/api/3/search/jql` | `searchAndReconsileIssuesUsingJql` | Search for issues using JQL enhanced search (GET) |
| POST | `/rest/api/3/search/jql` | `searchAndReconsileIssuesUsingJqlPost` | Search for issues using JQL enhanced search (POST) |

### Issue security level

This resource represents issue security levels. Use it to obtain the details of any issue security level. For more information about issue security levels, see [Configuring issue-level security](https://confluence.atlassian.com/x/J4lKLg).

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/issuesecurityschemes/{issueSecuritySchemeId}/members` | `getIssueSecurityLevelMembers` | Get issue security level members by issue security scheme |
| GET | `/rest/api/3/securitylevel/{id}` | `getIssueSecurityLevel` | Get issue security level |

### Issue security schemes

This resource represents issue security schemes. Use it to get an issue security scheme or a list of issue security schemes.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/issuesecurityschemes` | `getIssueSecuritySchemes` | Get issue security schemes |
| POST | `/rest/api/3/issuesecurityschemes` | `createIssueSecurityScheme` | Create issue security scheme 🧪 |
| GET | `/rest/api/3/issuesecurityschemes/level` | `getSecurityLevels` | Get issue security levels 🧪 |
| PUT | `/rest/api/3/issuesecurityschemes/level/default` | `setDefaultLevels` | Set default issue security levels 🧪 |
| GET | `/rest/api/3/issuesecurityschemes/level/member` | `getSecurityLevelMembers` | Get issue security level members 🧪 |
| GET | `/rest/api/3/issuesecurityschemes/project` | `searchProjectsUsingSecuritySchemes` | Get projects using issue security schemes 🧪 |
| PUT | `/rest/api/3/issuesecurityschemes/project` | `associateSchemesToProjects` | Associate security scheme to project 🧪 |
| GET | `/rest/api/3/issuesecurityschemes/search` | `searchSecuritySchemes` | Search issue security schemes 🧪 |
| GET | `/rest/api/3/issuesecurityschemes/{id}` | `getIssueSecurityScheme` | Get issue security scheme |
| PUT | `/rest/api/3/issuesecurityschemes/{id}` | `updateIssueSecurityScheme` | Update issue security scheme 🧪 |
| DELETE | `/rest/api/3/issuesecurityschemes/{schemeId}` | `deleteSecurityScheme` | Delete issue security scheme 🧪 |
| PUT | `/rest/api/3/issuesecurityschemes/{schemeId}/level` | `addSecurityLevel` | Add issue security levels 🧪 |
| PUT | `/rest/api/3/issuesecurityschemes/{schemeId}/level/{levelId}` | `updateSecurityLevel` | Update issue security level 🧪 |
| DELETE | `/rest/api/3/issuesecurityschemes/{schemeId}/level/{levelId}` | `removeLevel` | Remove issue security level 🧪 |
| PUT | `/rest/api/3/issuesecurityschemes/{schemeId}/level/{levelId}/member` | `addSecurityLevelMembers` | Add issue security level members 🧪 |
| DELETE | `/rest/api/3/issuesecurityschemes/{schemeId}/level/{levelId}/member/{memberId}` | `removeMemberFromSecurityLevel` | Remove member from issue security level 🧪 |

### Issue type properties

This resource represents [issue type](#api-group-Issue-types) properties, which provides for storing custom data against an issue type. Use it to get, create, and delete issue type properties as well as obtain the keys of all properties on a issues type. Issue type properties are a type of [entity property](https://developer.atlassian.com/cloud/jira/platform/jira-entity-properties/).

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/issuetype/{issueTypeId}/properties` | `getIssueTypePropertyKeys` | Get issue type property keys |
| GET | `/rest/api/3/issuetype/{issueTypeId}/properties/{propertyKey}` | `getIssueTypeProperty` | Get issue type property |
| PUT | `/rest/api/3/issuetype/{issueTypeId}/properties/{propertyKey}` | `setIssueTypeProperty` | Set issue type property |
| DELETE | `/rest/api/3/issuetype/{issueTypeId}/properties/{propertyKey}` | `deleteIssueTypeProperty` | Delete issue type property |

### Issue type schemes

This resource represents issue type schemes in classic projects. Use it to:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/issuetypescheme` | `getAllIssueTypeSchemes` | Get all issue type schemes |
| POST | `/rest/api/3/issuetypescheme` | `createIssueTypeScheme` | Create issue type scheme |
| GET | `/rest/api/3/issuetypescheme/mapping` | `getIssueTypeSchemesMapping` | Get issue type scheme items |
| GET | `/rest/api/3/issuetypescheme/project` | `getIssueTypeSchemeForProjects` | Get issue type schemes for projects |
| PUT | `/rest/api/3/issuetypescheme/project` | `assignIssueTypeSchemeToProject` | Assign issue type scheme to project |
| PUT | `/rest/api/3/issuetypescheme/{issueTypeSchemeId}` | `updateIssueTypeScheme` | Update issue type scheme |
| DELETE | `/rest/api/3/issuetypescheme/{issueTypeSchemeId}` | `deleteIssueTypeScheme` | Delete issue type scheme |
| PUT | `/rest/api/3/issuetypescheme/{issueTypeSchemeId}/issuetype` | `addIssueTypesToIssueTypeScheme` | Add issue types to issue type scheme |
| PUT | `/rest/api/3/issuetypescheme/{issueTypeSchemeId}/issuetype/move` | `reorderIssueTypesInIssueTypeScheme` | Change order of issue types |
| DELETE | `/rest/api/3/issuetypescheme/{issueTypeSchemeId}/issuetype/{issueTypeId}` | `removeIssueTypeFromIssueTypeScheme` | Remove issue type from issue type scheme |

### Issue type screen schemes

This resource represents issue type screen schemes. Use it to:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/issuetypescreenscheme` | `getIssueTypeScreenSchemes` | Get issue type screen schemes |
| POST | `/rest/api/3/issuetypescreenscheme` | `createIssueTypeScreenScheme` | Create issue type screen scheme |
| GET | `/rest/api/3/issuetypescreenscheme/mapping` | `getIssueTypeScreenSchemeMappings` | Get issue type screen scheme items |
| GET | `/rest/api/3/issuetypescreenscheme/project` | `getIssueTypeScreenSchemeProjectAssociations` | Get issue type screen schemes for projects |
| PUT | `/rest/api/3/issuetypescreenscheme/project` | `assignIssueTypeScreenSchemeToProject` | Assign issue type screen scheme to project |
| PUT | `/rest/api/3/issuetypescreenscheme/{issueTypeScreenSchemeId}` | `updateIssueTypeScreenScheme` | Update issue type screen scheme |
| DELETE | `/rest/api/3/issuetypescreenscheme/{issueTypeScreenSchemeId}` | `deleteIssueTypeScreenScheme` | Delete issue type screen scheme |
| PUT | `/rest/api/3/issuetypescreenscheme/{issueTypeScreenSchemeId}/mapping` | `appendMappingsForIssueTypeScreenScheme` | Append mappings to issue type screen scheme |
| PUT | `/rest/api/3/issuetypescreenscheme/{issueTypeScreenSchemeId}/mapping/default` | `updateDefaultScreenScheme` | Update issue type screen scheme default screen scheme |
| POST | `/rest/api/3/issuetypescreenscheme/{issueTypeScreenSchemeId}/mapping/remove` | `removeMappingsFromIssueTypeScreenScheme` | Remove mappings from issue type screen scheme |
| GET | `/rest/api/3/issuetypescreenscheme/{issueTypeScreenSchemeId}/project` | `getProjectsForIssueTypeScreenScheme` | Get issue type screen scheme projects |

### Issue types

This resource represents issues types. Use it to:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/issuetype` | `getIssueAllTypes` | Get all issue types for user |
| POST | `/rest/api/3/issuetype` | `createIssueType` | Create issue type |
| GET | `/rest/api/3/issuetype/project` | `getIssueTypesForProject` | Get issue types for project 🧪 |
| GET | `/rest/api/3/issuetype/{id}` | `getIssueType` | Get issue type |
| PUT | `/rest/api/3/issuetype/{id}` | `updateIssueType` | Update issue type |
| DELETE | `/rest/api/3/issuetype/{id}` | `deleteIssueType` | Delete issue type |
| GET | `/rest/api/3/issuetype/{id}/alternatives` | `getAlternativeIssueTypes` | Get alternative issue types |
| POST | `/rest/api/3/issuetype/{id}/avatar2` | `createIssueTypeAvatar` | Load issue type avatar |

### Issue votes

This resource represents votes cast by users on an issue. Use it to get details of votes on an issue as well as cast and withdrawal votes.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/issue/{issueIdOrKey}/votes` | `getVotes` | Get votes |
| POST | `/rest/api/3/issue/{issueIdOrKey}/votes` | `addVote` | Add vote |
| DELETE | `/rest/api/3/issue/{issueIdOrKey}/votes` | `removeVote` | Delete vote |

### Issue watchers

This resource represents users watching an issue. Use it to get details of users watching an issue as well as start and stop a user watching an issue.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/issue/watching` | `getIsWatchingIssueBulk` | Get is watching issue bulk |
| GET | `/rest/api/3/issue/{issueIdOrKey}/watchers` | `getIssueWatchers` | Get issue watchers |
| POST | `/rest/api/3/issue/{issueIdOrKey}/watchers` | `addWatcher` | Add watcher |
| DELETE | `/rest/api/3/issue/{issueIdOrKey}/watchers` | `removeWatcher` | Delete watcher |

### Issue worklog properties

This resource represents [issue worklog](#api-group-Issue-worklogs) properties, which provides for storing custom data against an issue worklog. Use it to get, create, and delete issue worklog properties as well as obtain the keys of all properties on a issue worklog. Issue worklog properties are a type of [entity property](https://developer.atlassian.com/cloud/jira/platform/jira-entity-properties/).

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/issue/{issueIdOrKey}/worklog/{worklogId}/properties` | `getWorklogPropertyKeys` | Get worklog property keys |
| GET | `/rest/api/3/issue/{issueIdOrKey}/worklog/{worklogId}/properties/{propertyKey}` | `getWorklogProperty` | Get worklog property |
| PUT | `/rest/api/3/issue/{issueIdOrKey}/worklog/{worklogId}/properties/{propertyKey}` | `setWorklogProperty` | Set worklog property |
| DELETE | `/rest/api/3/issue/{issueIdOrKey}/worklog/{worklogId}/properties/{propertyKey}` | `deleteWorklogProperty` | Delete worklog property |

### Issue worklogs

This resource represents issue worklogs. Use it to:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/issue/{issueIdOrKey}/worklog` | `getIssueWorklog` | Get issue worklogs |
| POST | `/rest/api/3/issue/{issueIdOrKey}/worklog` | `addWorklog` | Add worklog |
| DELETE | `/rest/api/3/issue/{issueIdOrKey}/worklog` | `bulkDeleteWorklogs` | Bulk delete worklogs 🧪 |
| POST | `/rest/api/3/issue/{issueIdOrKey}/worklog/move` | `bulkMoveWorklogs` | Bulk move worklogs 🧪 |
| GET | `/rest/api/3/issue/{issueIdOrKey}/worklog/{id}` | `getWorklog` | Get worklog |
| PUT | `/rest/api/3/issue/{issueIdOrKey}/worklog/{id}` | `updateWorklog` | Update worklog |
| DELETE | `/rest/api/3/issue/{issueIdOrKey}/worklog/{id}` | `deleteWorklog` | Delete worklog |
| GET | `/rest/api/3/worklog/deleted` | `getIdsOfWorklogsDeletedSince` | Get IDs of deleted worklogs |
| POST | `/rest/api/3/worklog/list` | `getWorklogsForIds` | Get worklogs |
| GET | `/rest/api/3/worklog/updated` | `getIdsOfWorklogsModifiedSince` | Get IDs of updated worklogs |

### Issues

This resource represents Jira issues. Use it to:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/changelog/bulkfetch` | `getBulkChangelogs` | Bulk fetch changelogs |
| GET | `/rest/api/3/events` | `getEvents` | Get events 🧪 |
| POST | `/rest/api/3/issue` | `createIssue` | Create issue |
| POST | `/rest/api/3/issue/archive` | `archiveIssuesAsync` | Archive issue(s) by JQL 🧪 |
| PUT | `/rest/api/3/issue/archive` | `archiveIssues` | Archive issue(s) by issue ID/key 🧪 |
| POST | `/rest/api/3/issue/bulk` | `createIssues` | Bulk create issue |
| POST | `/rest/api/3/issue/bulkfetch` | `bulkFetchIssues` | Bulk fetch issues |
| GET | `/rest/api/3/issue/createmeta` | `getCreateIssueMeta` | Get create issue metadata ⚠️ |
| GET | `/rest/api/3/issue/createmeta/{projectIdOrKey}/issuetypes` | `getCreateIssueMetaIssueTypes` | Get create metadata issue types for a project |
| GET | `/rest/api/3/issue/createmeta/{projectIdOrKey}/issuetypes/{issueTypeId}` | `getCreateIssueMetaIssueTypeId` | Get create field metadata for a project and issue type id |
| GET | `/rest/api/3/issue/limit/report` | `getIssueLimitReport` | Get issue limit report 🧪 |
| PUT | `/rest/api/3/issue/unarchive` | `unarchiveIssues` | Unarchive issue(s) by issue keys/ID 🧪 |
| GET | `/rest/api/3/issue/{issueIdOrKey}` | `getIssue` | Get issue |
| PUT | `/rest/api/3/issue/{issueIdOrKey}` | `editIssue` | Edit issue |
| DELETE | `/rest/api/3/issue/{issueIdOrKey}` | `deleteIssue` | Delete issue |
| PUT | `/rest/api/3/issue/{issueIdOrKey}/assignee` | `assignIssue` | Assign issue |
| GET | `/rest/api/3/issue/{issueIdOrKey}/changelog` | `getChangeLogs` | Get changelogs |
| POST | `/rest/api/3/issue/{issueIdOrKey}/changelog/list` | `getChangeLogsByIds` | Get changelogs by IDs |
| GET | `/rest/api/3/issue/{issueIdOrKey}/editmeta` | `getEditIssueMeta` | Get edit issue metadata |
| POST | `/rest/api/3/issue/{issueIdOrKey}/notify` | `notify` | Send notification for issue |
| GET | `/rest/api/3/issue/{issueIdOrKey}/transitions` | `getTransitions` | Get transitions |
| POST | `/rest/api/3/issue/{issueIdOrKey}/transitions` | `doTransition` | Transition issue |
| PUT | `/rest/api/3/issues/archive/export` | `exportArchivedIssues` | Export archived issue(s) 🧪 |

### Jira expressions

This resource is a collection of operations for [Jira expressions](https://developer.atlassian.com/cloud/jira/platform/jira-expressions/).

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/expression/analyse` | `analyseExpression` | Analyse Jira expression |
| POST | `/rest/api/3/expression/eval` | `evaluateJiraExpression` | Currently being removed. Evaluate Jira expression ⚠️ |
| POST | `/rest/api/3/expression/evaluate` | `evaluateJSISJiraExpression` | Evaluate Jira expression using enhanced search API |

### Jira settings

This resource represents various settings in Jira. Use it to get and update Jira settings and properties.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/application-properties` | `getApplicationProperty` | Get application property |
| GET | `/rest/api/3/application-properties/advanced-settings` | `getAdvancedSettings` | Get advanced settings |
| PUT | `/rest/api/3/application-properties/{id}` | `setApplicationProperty` | Set application property |
| GET | `/rest/api/3/configuration` | `getConfiguration` | Get global settings |

### JQL

This resource represents JQL search auto-complete details. Use it to obtain JQL search auto-complete data and suggestions for use in programmatic construction of queries or custom query builders. It also provides operations to:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/jql/autocompletedata` | `getAutoComplete` | Get field reference data (GET) |
| POST | `/rest/api/3/jql/autocompletedata` | `getAutoCompletePost` | Get field reference data (POST) |
| GET | `/rest/api/3/jql/autocompletedata/suggestions` | `getFieldAutoCompleteForQueryString` | Get field auto complete suggestions |
| POST | `/rest/api/3/jql/parse` | `parseJqlQueries` | Parse JQL query |
| POST | `/rest/api/3/jql/pdcleaner` | `migrateQueries` | Convert user identifiers to account IDs in JQL queries |
| POST | `/rest/api/3/jql/sanitize` | `sanitiseJqlQueries` | Sanitize JQL queries 🧪 |

### JQL functions (apps)

This resource represents JQL function's precomputations. Precomputation is a mapping between custom function call and JQL fragment returned by this function. Use it to get and update precomputations.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/jql/function/computation` | `getPrecomputations` | Get precomputations (apps) |
| POST | `/rest/api/3/jql/function/computation` | `updatePrecomputations` | Update precomputations (apps) |
| POST | `/rest/api/3/jql/function/computation/search` | `getPrecomputationsByID` | Get precomputations by ID (apps) |

### Labels

This resource represents available labels. Use it to get available labels for the global label field.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/label` | `getAllLabels` | Get all labels |

### License metrics

This resource represents license metrics. Use it to get available metrics for Jira licences.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/instance/license` | `getLicense` | Get license 🧪 |
| GET | `/rest/api/3/license/approximateLicenseCount` | `getApproximateLicenseCount` | Get approximate license count 🧪 |
| GET | `/rest/api/3/license/approximateLicenseCount/product/{applicationKey}` | `getApproximateApplicationLicenseCount` | Get approximate application license count 🧪 |

### Migration of Connect modules to Forge

This resource supports the migration of some Connect modules to their equivalent Forge modules.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/atlassian-connect/1/migration/{connectKey}/{jiraIssueFieldsKey}/task` | `ConnectToForgeMigrationFetchTaskResource.fetchMigrationTask_get` | Get Connect issue field migration task |
| POST | `/rest/atlassian-connect/1/migration/{connectKey}/{jiraIssueFieldsKey}/task` | `ConnectToForgeMigrationTaskSubmissionResource.submitTask_post` | Submit Connect issue field migration task |

### Myself

This resource represents information about the current user, such as basic details, group membership, application roles, preferences, and locale. Use it to get, create, update, and delete (restore default) values of the user's preferences and locale.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/mypreferences` | `getPreference` | Get preference |
| PUT | `/rest/api/3/mypreferences` | `setPreference` | Set preference |
| DELETE | `/rest/api/3/mypreferences` | `removePreference` | Delete preference |
| GET | `/rest/api/3/mypreferences/locale` | `getLocale` | Get locale |
| PUT | `/rest/api/3/mypreferences/locale` | `setLocale` | Set locale ⚠️ |
| GET | `/rest/api/3/myself` | `getCurrentUser` | Get current user |

### Permission schemes

This resource represents permission schemes. Use it to get, create, update, and delete permission schemes as well as get, create, update, and delete details of the permissions granted in those schemes.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/permissionscheme` | `getAllPermissionSchemes` | Get all permission schemes |
| POST | `/rest/api/3/permissionscheme` | `createPermissionScheme` | Create permission scheme |
| GET | `/rest/api/3/permissionscheme/{schemeId}` | `getPermissionScheme` | Get permission scheme |
| PUT | `/rest/api/3/permissionscheme/{schemeId}` | `updatePermissionScheme` | Update permission scheme |
| DELETE | `/rest/api/3/permissionscheme/{schemeId}` | `deletePermissionScheme` | Delete permission scheme |
| GET | `/rest/api/3/permissionscheme/{schemeId}/permission` | `getPermissionSchemeGrants` | Get permission scheme grants |
| POST | `/rest/api/3/permissionscheme/{schemeId}/permission` | `createPermissionGrant` | Create permission grant |
| GET | `/rest/api/3/permissionscheme/{schemeId}/permission/{permissionId}` | `getPermissionSchemeGrant` | Get permission scheme grant |
| DELETE | `/rest/api/3/permissionscheme/{schemeId}/permission/{permissionId}` | `deletePermissionSchemeEntity` | Delete permission scheme grant |

### Permissions

This resource represents permissions. Use it to obtain details of all permissions and determine whether the user has certain permissions.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/mypermissions` | `getMyPermissions` | Get my permissions |
| GET | `/rest/api/3/permissions` | `getAllPermissions` | Get all permissions |
| POST | `/rest/api/3/permissions/check` | `getBulkPermissions` | Get bulk permissions |
| POST | `/rest/api/3/permissions/project` | `getPermittedProjects` | Get permitted projects |

### Plans

This resource represents plans. Use it to get, create, duplicate, update, trash and archive plans.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/plans/plan` | `getPlans` | Get plans paginated 🧪 |
| POST | `/rest/api/3/plans/plan` | `createPlan` | Create plan 🧪 |
| GET | `/rest/api/3/plans/plan/{planId}` | `getPlan` | Get plan 🧪 |
| PUT | `/rest/api/3/plans/plan/{planId}` | `updatePlan` | Update plan 🧪 |
| PUT | `/rest/api/3/plans/plan/{planId}/archive` | `archivePlan` | Archive plan 🧪 |
| POST | `/rest/api/3/plans/plan/{planId}/duplicate` | `duplicatePlan` | Duplicate plan 🧪 |
| PUT | `/rest/api/3/plans/plan/{planId}/trash` | `trashPlan` | Trash plan 🧪 |

### Priority schemes

This resource represents issue priority schemes. Use it to get priority schemes and related information, and to create, update and delete priority schemes.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/priorityscheme` | `getPrioritySchemes` | Get priority schemes 🧪 |
| POST | `/rest/api/3/priorityscheme` | `createPriorityScheme` | Create priority scheme 🧪 |
| POST | `/rest/api/3/priorityscheme/mappings` | `suggestedPrioritiesForMappings` | Suggested priorities for mappings 🧪 |
| GET | `/rest/api/3/priorityscheme/priorities/available` | `getAvailablePrioritiesByPriorityScheme` | Get available priorities by priority scheme 🧪 |
| PUT | `/rest/api/3/priorityscheme/{schemeId}` | `updatePriorityScheme` | Update priority scheme 🧪 |
| DELETE | `/rest/api/3/priorityscheme/{schemeId}` | `deletePriorityScheme` | Delete priority scheme 🧪 |
| GET | `/rest/api/3/priorityscheme/{schemeId}/priorities` | `getPrioritiesByPriorityScheme` | Get priorities by priority scheme 🧪 |
| GET | `/rest/api/3/priorityscheme/{schemeId}/projects` | `getProjectsByPriorityScheme` | Get projects by priority scheme 🧪 |

### Project avatars

This resource represents avatars associated with a project. Use it to get, load, set, and remove project avatars.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| PUT | `/rest/api/3/project/{projectIdOrKey}/avatar` | `updateProjectAvatar` | Set project avatar |
| DELETE | `/rest/api/3/project/{projectIdOrKey}/avatar/{id}` | `deleteProjectAvatar` | Delete project avatar |
| POST | `/rest/api/3/project/{projectIdOrKey}/avatar2` | `createProjectAvatar` | Load project avatar |
| GET | `/rest/api/3/project/{projectIdOrKey}/avatars` | `getAllProjectAvatars` | Get all project avatars |

### Project categories

This resource represents project categories. Use it to create, update, and delete project categories as well as obtain a list of all project categories and details of individual categories. For more information on managing project categories, see [Adding, assigning, and deleting project categories](https://confluence.atlassian.com/x/-A5WMg).

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/projectCategory` | `getAllProjectCategories` | Get all project categories |
| POST | `/rest/api/3/projectCategory` | `createProjectCategory` | Create project category |
| GET | `/rest/api/3/projectCategory/{id}` | `getProjectCategoryById` | Get project category by ID |
| PUT | `/rest/api/3/projectCategory/{id}` | `updateProjectCategory` | Update project category |
| DELETE | `/rest/api/3/projectCategory/{id}` | `removeProjectCategory` | Delete project category |

### Project classification levels

This resource represents classification levels used in a project. Use it to view and manage classification levels in your projects.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/project/{projectIdOrKey}/classification-config` | `getProjectClassificationConfig` | Get the classification configuration for a project 🧪 |
| GET | `/rest/api/3/project/{projectIdOrKey}/classification-level/default` | `getDefaultProjectClassification` | Get the default data classification level of a project 🧪 |
| PUT | `/rest/api/3/project/{projectIdOrKey}/classification-level/default` | `updateDefaultProjectClassification` | Update the default data classification level of a project 🧪 |
| DELETE | `/rest/api/3/project/{projectIdOrKey}/classification-level/default` | `removeDefaultProjectClassification` | Remove the default data classification level from a project 🧪 |

### Project components

This resource represents project components. Use it to get, create, update, and delete project components. Also get components for project and get a count of issues by component.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/component` | `findComponentsForProjects` | Find components for projects |
| POST | `/rest/api/3/component` | `createComponent` | Create component |
| GET | `/rest/api/3/component/{id}` | `getComponent` | Get component |
| PUT | `/rest/api/3/component/{id}` | `updateComponent` | Update component |
| DELETE | `/rest/api/3/component/{id}` | `deleteComponent` | Delete component |
| GET | `/rest/api/3/component/{id}/relatedIssueCounts` | `getComponentRelatedIssues` | Get component issues count |
| GET | `/rest/api/3/project/{projectIdOrKey}/component` | `getProjectComponentsPaginated` | Get project components paginated |
| GET | `/rest/api/3/project/{projectIdOrKey}/components` | `getProjectComponents` | Get project components |

### Project email

This resource represents the email address used to send a project's notifications. Use it to get and set the [project's sender email address](https://confluence.atlassian.com/x/dolKLg).

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/project/{projectId}/email` | `getProjectEmail` | Get project's sender email |
| PUT | `/rest/api/3/project/{projectId}/email` | `updateProjectEmail` | Set project's sender email |

### Project features

This resource represents project features. Use it to get the list of features for a project and modify the state of a feature. The project feature endpoint is available only for Jira Software, both for team- and company-managed projects.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/project/{projectIdOrKey}/features` | `getFeaturesForProject` | Get project features |
| PUT | `/rest/api/3/project/{projectIdOrKey}/features/{featureKey}` | `toggleFeatureForProject` | Set project feature state |

### Project key and name validation

This resource provides validation for project keys and names.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/projectvalidate/key` | `validateProjectKey` | Validate project key |
| GET | `/rest/api/3/projectvalidate/validProjectKey` | `getValidProjectKey` | Get valid project key |
| GET | `/rest/api/3/projectvalidate/validProjectName` | `getValidProjectName` | Get valid project name |

### Project permission schemes

This resource represents permission schemes for a project. Use this resource to:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/project/{projectKeyOrId}/issuesecuritylevelscheme` | `getProjectIssueSecurityScheme` | Get project issue security scheme |
| GET | `/rest/api/3/project/{projectKeyOrId}/permissionscheme` | `getAssignedPermissionScheme` | Get assigned permission scheme |
| PUT | `/rest/api/3/project/{projectKeyOrId}/permissionscheme` | `assignPermissionScheme` | Assign permission scheme |
| GET | `/rest/api/3/project/{projectKeyOrId}/securitylevel` | `getSecurityLevelsForProject` | Get project issue security levels |

### Project properties

This resource represents [project](#api-group-Projects) properties, which provides for storing custom data against a project. Use it to get, create, and delete project properties as well as get a list of property keys for a project. Project properties are a type of [entity property](https://developer.atlassian.com/cloud/jira/platform/jira-entity-properties/).

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/project/{projectIdOrKey}/properties` | `getProjectPropertyKeys` | Get project property keys |
| GET | `/rest/api/3/project/{projectIdOrKey}/properties/{propertyKey}` | `getProjectProperty` | Get project property |
| PUT | `/rest/api/3/project/{projectIdOrKey}/properties/{propertyKey}` | `setProjectProperty` | Set project property |
| DELETE | `/rest/api/3/project/{projectIdOrKey}/properties/{propertyKey}` | `deleteProjectProperty` | Delete project property |

### Project role actors

This resource represents the users assigned to [project roles](#api-group-Issue-comments). Use it to get, add, and remove default users from project roles. Also use it to add and remove users from a project role associated with a project.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/project/{projectIdOrKey}/role/{id}` | `addActorUsers` | Add actors to project role |
| PUT | `/rest/api/3/project/{projectIdOrKey}/role/{id}` | `setActors` | Set actors for project role |
| DELETE | `/rest/api/3/project/{projectIdOrKey}/role/{id}` | `deleteActor` | Delete actors from project role |
| GET | `/rest/api/3/role/{id}/actors` | `getProjectRoleActorsForRole` | Get default actors for project role |
| POST | `/rest/api/3/role/{id}/actors` | `addProjectRoleActorsToRole` | Add default actors to project role |
| DELETE | `/rest/api/3/role/{id}/actors` | `deleteProjectRoleActorsFromRole` | Delete default actors from project role |

### Project roles

This resource represents the roles that users can play in projects. Use this resource to get, create, update, and delete project roles.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/project/{projectIdOrKey}/role` | `getProjectRoles` | Get project roles for project |
| GET | `/rest/api/3/project/{projectIdOrKey}/role/{id}` | `getProjectRole` | Get project role for project |
| GET | `/rest/api/3/project/{projectIdOrKey}/roledetails` | `getProjectRoleDetails` | Get project role details |
| GET | `/rest/api/3/role` | `getAllProjectRoles` | Get all project roles |
| POST | `/rest/api/3/role` | `createProjectRole` | Create project role |
| GET | `/rest/api/3/role/{id}` | `getProjectRoleById` | Get project role by ID |
| POST | `/rest/api/3/role/{id}` | `partialUpdateProjectRole` | Partial update project role |
| PUT | `/rest/api/3/role/{id}` | `fullyUpdateProjectRole` | Fully update project role |
| DELETE | `/rest/api/3/role/{id}` | `deleteProjectRole` | Delete project role |

### Project templates

This resource represents project templates. Use it to create a new project from a custom template.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/project-template` | `createProjectWithCustomTemplate` | Create custom project |
| PUT | `/rest/api/3/project-template/edit-template` | `editTemplate` | Edit a custom project template 🧪 |
| GET | `/rest/api/3/project-template/live-template` | `liveTemplate` | Gets a custom project template 🧪 |
| DELETE | `/rest/api/3/project-template/remove-template` | `removeTemplate` | Deletes a custom project template 🧪 |
| POST | `/rest/api/3/project-template/save-template` | `saveTemplate` | Save a custom project template 🧪 |

### Project types

This resource represents project types. Use it to obtain a list of all project types, a list of project types accessible to the calling user, and details of a project type.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/project/type` | `getAllProjectTypes` | Get all project types |
| GET | `/rest/api/3/project/type/accessible` | `getAllAccessibleProjectTypes` | Get licensed project types |
| GET | `/rest/api/3/project/type/{projectTypeKey}` | `getProjectTypeByKey` | Get project type by key |
| GET | `/rest/api/3/project/type/{projectTypeKey}/accessible` | `getAccessibleProjectTypeByKey` | Get accessible project type by key |

### Project versions

This resource represents project versions. Use it to get, get lists of, create, update, move, merge, and delete project versions. This resource also provides counts of issues by version.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/project/{projectIdOrKey}/version` | `getProjectVersionsPaginated` | Get project versions paginated |
| GET | `/rest/api/3/project/{projectIdOrKey}/versions` | `getProjectVersions` | Get project versions |
| POST | `/rest/api/3/version` | `createVersion` | Create version |
| GET | `/rest/api/3/version/{id}` | `getVersion` | Get version |
| PUT | `/rest/api/3/version/{id}` | `updateVersion` | Update version |
| DELETE | `/rest/api/3/version/{id}` | `deleteVersion` | Delete version ⚠️ |
| PUT | `/rest/api/3/version/{id}/mergeto/{moveIssuesTo}` | `mergeVersions` | Merge versions |
| POST | `/rest/api/3/version/{id}/move` | `moveVersion` | Move version |
| GET | `/rest/api/3/version/{id}/relatedIssueCounts` | `getVersionRelatedIssues` | Get version's related issues count |
| GET | `/rest/api/3/version/{id}/relatedwork` | `getRelatedWork` | Get related work |
| POST | `/rest/api/3/version/{id}/relatedwork` | `createRelatedWork` | Create related work |
| PUT | `/rest/api/3/version/{id}/relatedwork` | `updateRelatedWork` | Update related work |
| POST | `/rest/api/3/version/{id}/removeAndSwap` | `deleteAndReplaceVersion` | Delete and replace version |
| GET | `/rest/api/3/version/{id}/unresolvedIssueCount` | `getVersionUnresolvedIssues` | Get version's unresolved issues count |
| DELETE | `/rest/api/3/version/{versionId}/relatedwork/{relatedWorkId}` | `deleteRelatedWork` | Delete related work |

### Projects

This resource represents projects. Use it to get, create, update, and delete projects. Also get statuses available to a project, a project's notification schemes, and update a project's type.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/project` | `getAllProjects` | Get all projects ⚠️ |
| POST | `/rest/api/3/project` | `createProject` | Create project |
| GET | `/rest/api/3/project/recent` | `getRecent` | Get recent projects 🧪 |
| GET | `/rest/api/3/project/search` | `searchProjects` | Get projects paginated |
| GET | `/rest/api/3/project/{projectIdOrKey}` | `getProject` | Get project |
| PUT | `/rest/api/3/project/{projectIdOrKey}` | `updateProject` | Update project |
| DELETE | `/rest/api/3/project/{projectIdOrKey}` | `deleteProject` | Delete project |
| POST | `/rest/api/3/project/{projectIdOrKey}/archive` | `archiveProject` | Archive project |
| POST | `/rest/api/3/project/{projectIdOrKey}/delete` | `deleteProjectAsynchronously` | Delete project asynchronously 🧪 |
| POST | `/rest/api/3/project/{projectIdOrKey}/restore` | `restore` | Restore deleted or archived project 🧪 |
| GET | `/rest/api/3/project/{projectIdOrKey}/statuses` | `getAllStatuses` | Get all statuses for project |
| GET | `/rest/api/3/project/{projectId}/hierarchy` | `getHierarchy` | Get project issue type hierarchy |
| GET | `/rest/api/3/project/{projectKeyOrId}/notificationscheme` | `getNotificationSchemeForProject` | Get project notification scheme |

### Screen schemes

This resource represents screen schemes in classic projects. Use it to get, create, update, and delete screen schemes.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/screenscheme` | `getScreenSchemes` | Get screen schemes |
| POST | `/rest/api/3/screenscheme` | `createScreenScheme` | Create screen scheme |
| PUT | `/rest/api/3/screenscheme/{screenSchemeId}` | `updateScreenScheme` | Update screen scheme |
| DELETE | `/rest/api/3/screenscheme/{screenSchemeId}` | `deleteScreenScheme` | Delete screen scheme |

### Screen tab fields

This resource represents the screen tab fields used to record issue details. Use it to get, add, move, and remove fields from screen tabs.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/screens/{screenId}/tabs/{tabId}/fields` | `getAllScreenTabFields` | Get all screen tab fields |
| POST | `/rest/api/3/screens/{screenId}/tabs/{tabId}/fields` | `addScreenTabField` | Add screen tab field |
| DELETE | `/rest/api/3/screens/{screenId}/tabs/{tabId}/fields/{id}` | `removeScreenTabField` | Remove screen tab field |
| POST | `/rest/api/3/screens/{screenId}/tabs/{tabId}/fields/{id}/move` | `moveScreenTabField` | Move screen tab field |

### Screen tabs

This resource represents the screen tabs used to record issue details. Use it to get, create, update, move, and delete screen tabs.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/screens/tabs` | `getBulkScreenTabs` | Get bulk screen tabs 🧪 |
| GET | `/rest/api/3/screens/{screenId}/tabs` | `getAllScreenTabs` | Get all screen tabs |
| POST | `/rest/api/3/screens/{screenId}/tabs` | `addScreenTab` | Create screen tab |
| PUT | `/rest/api/3/screens/{screenId}/tabs/{tabId}` | `renameScreenTab` | Update screen tab |
| DELETE | `/rest/api/3/screens/{screenId}/tabs/{tabId}` | `deleteScreenTab` | Delete screen tab |
| POST | `/rest/api/3/screens/{screenId}/tabs/{tabId}/move/{pos}` | `moveScreenTab` | Move screen tab |

### Screens

This resource represents the screens used to record issue details. Use it to:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/field/{fieldId}/screens` | `getScreensForField` | Get screens for a field |
| GET | `/rest/api/3/screens` | `getScreens` | Get screens |
| POST | `/rest/api/3/screens` | `createScreen` | Create screen 🧪 |
| POST | `/rest/api/3/screens/addToDefault/{fieldId}` | `addFieldToDefaultScreen` | Add field to default screen |
| PUT | `/rest/api/3/screens/{screenId}` | `updateScreen` | Update screen 🧪 |
| DELETE | `/rest/api/3/screens/{screenId}` | `deleteScreen` | Delete screen 🧪 |
| GET | `/rest/api/3/screens/{screenId}/availableFields` | `getAvailableScreenFields` | Get available screen fields |

### Server info

This resource provides information about the Jira instance.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/serverInfo` | `getServerInfo` | Get Jira instance info |

### Service Registry

This resource represents a service registry. Use it to retrieve attributes related to a [service registry](https://support.atlassian.com/jira-service-management-cloud/docs/what-is-services/) in JSM.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/atlassian-connect/1/service-registry` | `ServiceRegistryResource.services_get` | Retrieve the attributes of service registries 🧪 |

### Status

This resource represents statuses. Use it to search, get, create, delete, and change statuses.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/statuses` | `getStatusesById` | Bulk get statuses |
| POST | `/rest/api/3/statuses` | `createStatuses` | Bulk create statuses |
| PUT | `/rest/api/3/statuses` | `updateStatuses` | Bulk update statuses |
| DELETE | `/rest/api/3/statuses` | `deleteStatusesById` | Bulk delete Statuses |
| GET | `/rest/api/3/statuses/byNames` | `getStatusesByName` | Bulk get statuses by name |
| GET | `/rest/api/3/statuses/search` | `search` | Search statuses paginated |
| GET | `/rest/api/3/statuses/{statusId}/project/{projectId}/issueTypeUsages` | `getProjectIssueTypeUsagesForStatus` | Get issue type usages by status and project |
| GET | `/rest/api/3/statuses/{statusId}/projectUsages` | `getProjectUsagesForStatus` | Get project usages by status |
| GET | `/rest/api/3/statuses/{statusId}/workflowUsages` | `getWorkflowUsagesForStatus` | Get workflow usages by status |

### Tasks

This resource represents a [long-running asynchronous tasks](#async-operations). Use it to obtain details about the progress of a long-running task or cancel a long-running task.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/task/{taskId}` | `getTask` | Get task |
| POST | `/rest/api/3/task/{taskId}/cancel` | `cancelTask` | Cancel task 🧪 |

### Teams in plan

This resource represents planning settings for plan-only and Atlassian teams in a plan. Use it to get, create, update and delete planning settings.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/plans/plan/{planId}/team` | `getTeams` | Get teams in plan paginated 🧪 |
| POST | `/rest/api/3/plans/plan/{planId}/team/atlassian` | `addAtlassianTeam` | Add Atlassian team to plan 🧪 |
| GET | `/rest/api/3/plans/plan/{planId}/team/atlassian/{atlassianTeamId}` | `getAtlassianTeam` | Get Atlassian team in plan 🧪 |
| PUT | `/rest/api/3/plans/plan/{planId}/team/atlassian/{atlassianTeamId}` | `updateAtlassianTeam` | Update Atlassian team in plan 🧪 |
| DELETE | `/rest/api/3/plans/plan/{planId}/team/atlassian/{atlassianTeamId}` | `removeAtlassianTeam` | Remove Atlassian team from plan 🧪 |
| POST | `/rest/api/3/plans/plan/{planId}/team/planonly` | `createPlanOnlyTeam` | Create plan-only team 🧪 |
| GET | `/rest/api/3/plans/plan/{planId}/team/planonly/{planOnlyTeamId}` | `getPlanOnlyTeam` | Get plan-only team 🧪 |
| PUT | `/rest/api/3/plans/plan/{planId}/team/planonly/{planOnlyTeamId}` | `updatePlanOnlyTeam` | Update plan-only team 🧪 |
| DELETE | `/rest/api/3/plans/plan/{planId}/team/planonly/{planOnlyTeamId}` | `deletePlanOnlyTeam` | Delete plan-only team 🧪 |

### Time tracking

This resource represents time tracking and time tracking providers. Use it to get and set the time tracking provider, get and set the time tracking options, and disable time tracking.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/configuration/timetracking` | `getSelectedTimeTrackingImplementation` | Get selected time tracking provider |
| PUT | `/rest/api/3/configuration/timetracking` | `selectTimeTrackingImplementation` | Select time tracking provider |
| GET | `/rest/api/3/configuration/timetracking/list` | `getAvailableTimeTrackingImplementations` | Get all time tracking providers |
| GET | `/rest/api/3/configuration/timetracking/options` | `getSharedTimeTrackingConfiguration` | Get time tracking settings |
| PUT | `/rest/api/3/configuration/timetracking/options` | `setSharedTimeTrackingConfiguration` | Set time tracking settings |

### UI modifications (apps)

UI modifications is a feature available for **Forge apps only**. It enables Forge apps to control how selected Jira and Jira Service Management fields behave on the following views:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/uiModifications` | `getUiModifications` | Get UI modifications |
| POST | `/rest/api/3/uiModifications` | `createUiModification` | Create UI modification |
| PUT | `/rest/api/3/uiModifications/{uiModificationId}` | `updateUiModification` | Update UI modification |
| DELETE | `/rest/api/3/uiModifications/{uiModificationId}` | `deleteUiModification` | Delete UI modification |

### User properties

This resource represents [user](#api-group-Users) properties and provides for storing custom data against a user. Use it to get, create, and delete user properties as well as get a list of property keys for a user. This resourse is designed for integrations and apps to store per-user data and settings. This enables data used to customized the user experience to be kept in the Jira Cloud instance's database. User properties are a type of [entity property](https://developer.atlassian.com/cloud/jira/platform/jira-entity-properties/).

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/user/properties` | `getUserPropertyKeys` | Get user property keys |
| GET | `/rest/api/3/user/properties/{propertyKey}` | `getUserProperty` | Get user property |
| PUT | `/rest/api/3/user/properties/{propertyKey}` | `setUserProperty` | Set user property |
| DELETE | `/rest/api/3/user/properties/{propertyKey}` | `deleteUserProperty` | Delete user property |

### User search

This resource represents various ways to search for and find users. Use it to obtain list of users including users assignable to projects and issues, users with permissions, user lists for pickup fields, and user lists generated using structured queries. Note that the operations in this resource only return users found within the first 1000 users.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/user/assignable/multiProjectSearch` | `findBulkAssignableUsers` | Find users assignable to projects |
| GET | `/rest/api/3/user/assignable/search` | `findAssignableUsers` | Find users assignable to issues |
| GET | `/rest/api/3/user/permission/search` | `findUsersWithAllPermissions` | Find users with permissions |
| GET | `/rest/api/3/user/picker` | `findUsersForPicker` | Find users for picker |
| GET | `/rest/api/3/user/search` | `findUsers` | Find users |
| GET | `/rest/api/3/user/search/query` | `findUsersByQuery` | Find users by query |
| GET | `/rest/api/3/user/search/query/key` | `findUserKeysByQuery` | Find user keys by query |
| GET | `/rest/api/3/user/viewissue/search` | `findUsersWithBrowsePermission` | Find users with browse permission |

### Users

This resource represent users. Use it to:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/user` | `getUser` | Get user |
| POST | `/rest/api/3/user` | `createUser` | Create user |
| DELETE | `/rest/api/3/user` | `removeUser` | Delete user |
| GET | `/rest/api/3/user/bulk` | `bulkGetUsers` | Bulk get users 🧪 |
| GET | `/rest/api/3/user/bulk/migration` | `bulkGetUsersMigration` | Get account IDs for users 🧪 |
| GET | `/rest/api/3/user/columns` | `getUserDefaultColumns` | Get user default columns |
| PUT | `/rest/api/3/user/columns` | `setUserColumns` | Set user default columns |
| DELETE | `/rest/api/3/user/columns` | `resetUserColumns` | Reset user default columns |
| GET | `/rest/api/3/user/email` | `getUserEmail` | Get user email |
| GET | `/rest/api/3/user/email/bulk` | `getUserEmailBulk` | Get user email bulk |
| GET | `/rest/api/3/user/groups` | `getUserGroups` | Get user groups |
| GET | `/rest/api/3/users` | `getAllUsersDefault` | Get all users default |
| GET | `/rest/api/3/users/search` | `getAllUsers` | Get all users |

### Webhooks

This resource represents webhooks. Webhooks are calls sent to a URL when an event occurs in Jira for issues specified by a JQL query. Only Connect and OAuth 2.0 apps can register and manage webhooks. For more information, see [Webhooks](https://developer.atlassian.com/cloud/jira/platform/webhooks/#registering-a-webhook-via-the-jira-rest-api-for-connect-apps).

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/webhook` | `getDynamicWebhooksForApp` | Get dynamic webhooks for app |
| POST | `/rest/api/3/webhook` | `registerDynamicWebhooks` | Register dynamic webhooks |
| DELETE | `/rest/api/3/webhook` | `deleteWebhookById` | Delete webhooks by ID |
| GET | `/rest/api/3/webhook/failed` | `getFailedWebhooks` | Get failed webhooks 🧪 |
| PUT | `/rest/api/3/webhook/refresh` | `refreshWebhooks` | Extend webhook life |

### Workflow scheme drafts

This resource represents draft workflow schemes. Use it to manage drafts of workflow schemes.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/workflowscheme/{id}/createdraft` | `createWorkflowSchemeDraftFromParent` | Create draft workflow scheme |
| GET | `/rest/api/3/workflowscheme/{id}/draft` | `getWorkflowSchemeDraft` | Get draft workflow scheme |
| PUT | `/rest/api/3/workflowscheme/{id}/draft` | `updateWorkflowSchemeDraft` | Update draft workflow scheme |
| DELETE | `/rest/api/3/workflowscheme/{id}/draft` | `deleteWorkflowSchemeDraft` | Delete draft workflow scheme |
| GET | `/rest/api/3/workflowscheme/{id}/draft/default` | `getDraftDefaultWorkflow` | Get draft default workflow |
| PUT | `/rest/api/3/workflowscheme/{id}/draft/default` | `updateDraftDefaultWorkflow` | Update draft default workflow |
| DELETE | `/rest/api/3/workflowscheme/{id}/draft/default` | `deleteDraftDefaultWorkflow` | Delete draft default workflow |
| GET | `/rest/api/3/workflowscheme/{id}/draft/issuetype/{issueType}` | `getWorkflowSchemeDraftIssueType` | Get workflow for issue type in draft workflow scheme |
| PUT | `/rest/api/3/workflowscheme/{id}/draft/issuetype/{issueType}` | `setWorkflowSchemeDraftIssueType` | Set workflow for issue type in draft workflow scheme |
| DELETE | `/rest/api/3/workflowscheme/{id}/draft/issuetype/{issueType}` | `deleteWorkflowSchemeDraftIssueType` | Delete workflow for issue type in draft workflow scheme |
| POST | `/rest/api/3/workflowscheme/{id}/draft/publish` | `publishDraftWorkflowScheme` | Publish draft workflow scheme |
| GET | `/rest/api/3/workflowscheme/{id}/draft/workflow` | `getDraftWorkflow` | Get issue types for workflows in draft workflow scheme |
| PUT | `/rest/api/3/workflowscheme/{id}/draft/workflow` | `updateDraftWorkflowMapping` | Set issue types for workflow in workflow scheme |
| DELETE | `/rest/api/3/workflowscheme/{id}/draft/workflow` | `deleteDraftWorkflowMapping` | Delete issue types for workflow in draft workflow scheme |

### Workflow scheme project associations

This resource represents the associations between workflow schemes and projects.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/workflowscheme/project` | `getWorkflowSchemeProjectAssociations` | Get workflow scheme project associations |
| PUT | `/rest/api/3/workflowscheme/project` | `assignSchemeToProject` | Assign workflow scheme to project |

### Workflow schemes

This resource represents workflow schemes. Use it to manage workflow schemes and the workflow scheme's workflows and issue types.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/workflowscheme` | `getAllWorkflowSchemes` | Get all workflow schemes |
| POST | `/rest/api/3/workflowscheme` | `createWorkflowScheme` | Create workflow scheme |
| POST | `/rest/api/3/workflowscheme/project/switch` | `switchWorkflowSchemeForProject` | Switch workflow scheme for project 🧪 |
| POST | `/rest/api/3/workflowscheme/read` | `readWorkflowSchemes` | Bulk get workflow schemes |
| POST | `/rest/api/3/workflowscheme/update` | `updateSchemes` | Update workflow scheme |
| POST | `/rest/api/3/workflowscheme/update/mappings` | `getRequiredWorkflowSchemeMappings` | Get required status mappings for workflow scheme update |
| GET | `/rest/api/3/workflowscheme/{id}` | `getWorkflowScheme` | Get workflow scheme |
| PUT | `/rest/api/3/workflowscheme/{id}` | `updateWorkflowScheme` | Classic update workflow scheme |
| DELETE | `/rest/api/3/workflowscheme/{id}` | `deleteWorkflowScheme` | Delete workflow scheme |
| GET | `/rest/api/3/workflowscheme/{id}/default` | `getDefaultWorkflow` | Get default workflow |
| PUT | `/rest/api/3/workflowscheme/{id}/default` | `updateDefaultWorkflow` | Update default workflow |
| DELETE | `/rest/api/3/workflowscheme/{id}/default` | `deleteDefaultWorkflow` | Delete default workflow |
| GET | `/rest/api/3/workflowscheme/{id}/issuetype/{issueType}` | `getWorkflowSchemeIssueType` | Get workflow for issue type in workflow scheme |
| PUT | `/rest/api/3/workflowscheme/{id}/issuetype/{issueType}` | `setWorkflowSchemeIssueType` | Set workflow for issue type in workflow scheme |
| DELETE | `/rest/api/3/workflowscheme/{id}/issuetype/{issueType}` | `deleteWorkflowSchemeIssueType` | Delete workflow for issue type in workflow scheme |
| GET | `/rest/api/3/workflowscheme/{id}/workflow` | `getWorkflow` | Get issue types for workflows in workflow scheme |
| PUT | `/rest/api/3/workflowscheme/{id}/workflow` | `updateWorkflowMapping` | Set issue types for workflow in workflow scheme |
| DELETE | `/rest/api/3/workflowscheme/{id}/workflow` | `deleteWorkflowMapping` | Delete issue types for workflow in workflow scheme |
| GET | `/rest/api/3/workflowscheme/{workflowSchemeId}/projectUsages` | `getProjectUsagesForWorkflowScheme` | Get projects which are using a given workflow scheme |

### Workflow status categories

This resource represents status categories. Use it to obtain a list of all status categories and the details of a category. Status categories provided a mechanism for categorizing [statuses](#api-group-Workflow-statuses).

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/statuscategory` | `getStatusCategories` | Get all status categories |
| GET | `/rest/api/3/statuscategory/{idOrKey}` | `getStatusCategory` | Get status category |

### Workflow statuses

This resource represents issue workflow statuses. Use it to obtain a list of all statuses associated with workflows and the details of a status.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/status` | `getStatuses` | Get all statuses |
| GET | `/rest/api/3/status/{idOrName}` | `getStatus` | Get status |

### Workflow transition rules

This resource represents workflow transition rules. Workflow transition rules define a Connect or a Forge app routine, such as a [workflow post functions](https://developer.atlassian.com/cloud/jira/platform/modules/workflow-post-function/) that is executed in association with the workflow. Use it to read and modify configuration of workflow transition rules.

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| GET | `/rest/api/3/workflow/rule/config` | `getWorkflowTransitionRuleConfigurations` | Get workflow transition rule configurations |
| PUT | `/rest/api/3/workflow/rule/config` | `updateWorkflowTransitionRuleConfigurations` | Update workflow transition rule configurations |
| PUT | `/rest/api/3/workflow/rule/config/delete` | `deleteWorkflowTransitionRuleConfigurations` | Delete workflow transition rule configurations |

### Workflows

This resource represents workflows. Use it to:

| Method | Path | Operation ID | Summary |
| --- | --- | --- | --- |
| POST | `/rest/api/3/workflow/history` | `readWorkflowFromHistory` | Read workflow version from history |
| POST | `/rest/api/3/workflow/history/list` | `listWorkflowHistory` | List workflow history entries |
| GET | `/rest/api/3/workflow/search` | `getWorkflowsPaginated` | Get workflows paginated ⚠️ |
| DELETE | `/rest/api/3/workflow/{entityId}` | `deleteInactiveWorkflow` | Delete inactive workflow |
| GET | `/rest/api/3/workflow/{workflowId}/project/{projectId}/issueTypeUsages` | `getWorkflowProjectIssueTypeUsages` | Get issue types in a project that are using a given workflow |
| GET | `/rest/api/3/workflow/{workflowId}/projectUsages` | `getProjectUsagesForWorkflow` | Get projects using a given workflow |
| GET | `/rest/api/3/workflow/{workflowId}/workflowSchemes` | `getWorkflowSchemeUsagesForWorkflow` | Get workflow schemes which are using a given workflow |
| POST | `/rest/api/3/workflows` | `readWorkflows` | Bulk get workflows |
| GET | `/rest/api/3/workflows/capabilities` | `workflowCapabilities` | Get available workflow capabilities |
| POST | `/rest/api/3/workflows/create` | `createWorkflows` | Bulk create workflows |
| POST | `/rest/api/3/workflows/create/validation` | `validateCreateWorkflows` | Validate create workflows |
| GET | `/rest/api/3/workflows/defaultEditor` | `getDefaultEditor` | Get the user's default workflow editor |
| POST | `/rest/api/3/workflows/preview` | `readWorkflowPreviews` | Preview workflow |
| GET | `/rest/api/3/workflows/search` | `searchWorkflows` | Search workflows |
| POST | `/rest/api/3/workflows/update` | `updateWorkflows` | Bulk update workflows |
| POST | `/rest/api/3/workflows/update/validation` | `validateUpdateWorkflows` | Validate update workflows |


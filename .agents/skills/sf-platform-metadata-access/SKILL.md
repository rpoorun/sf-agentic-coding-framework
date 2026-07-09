---
name: sf-platform-metadata-access
description: "Use when generating Salesforce metadata that must be usable by different personas or users, especially new custom objects, custom metadata types, tabs, or setup records that require profile or permission set access planning. This skill prompts the agent to ask who needs access, which profile or permission set grants it, and whether the generated metadata must ship together with access changes."
metadata:
  version: "1.0"
  cloud: "Platform"
  synthesized: true
---

# sf-platform-metadata-access: Metadata Accessibility Planning

## When to Use This Skill

Use when generating or reviewing metadata that creates something users must actually reach, such as:
- Custom objects
- Custom metadata types and their records
- Custom tabs or setup surfaces tied to new metadata
- Any metadata change that will be deployed for multiple personas or roles

Use this skill together with the relevant schema or permissions skill. It does not replace object, field, or permission metadata generation; it adds the access-planning question that prevents deployable-but-inaccessible metadata.

## Core Rule

Before generating metadata, ask:
1. Which personas or user groups need to see, create, edit, or assign this?
2. Which profile, permission set, or permission set group gives them that access today?
3. Does the new metadata need access changes in the same delivery, or is the access already in place?
4. If the answer is unclear, should the user confirm the intended personas before generation continues?

If the access path is unknown, do not silently assume it exists. Stop and ask the user.

## Accessibility Checklist

Before finalizing metadata, verify:
- The intended personas are named
- The access path is identified
- The access path matches the deployment scope
- A matching profile or permission set change is included when needed
- The metadata will not deploy in a technically valid but unusable state

## Decision Rule

If the generated metadata introduces a new object, custom metadata type, or record surface, the agent should question itself:
- "Who can use this?"
- "Where is that granted?"
- "Do I need to generate or deploy the access change with the metadata?"

When the answer is not obvious, prompt the user for confirmation before generating the final metadata.

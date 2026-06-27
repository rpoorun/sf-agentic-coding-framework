# Apex Trigger Framework

## Purpose And Use

This file mandates the trigger-handler base class this project uses for every Apex trigger, and explains how to use it. Read it before writing, refactoring, or reviewing any `.trigger` file or its handler class. Put trigger-dispatch, recursion-control, and bypass-API rules here; put general layering and bulkification rules in [SALESFORCE_APEX_STANDARDS.md](SALESFORCE_APEX_STANDARDS.md).

## Source

This framework vendors [kevinohara80/sfdc-trigger-framework](https://github.com/kevinohara80/sfdc-trigger-framework) (MIT License, Copyright (c) Kevin M. O'Hara) directly as `TriggerHandler.cls` — unlike the general web-dev sources in [LEAN_CODE_STANDARDS.md](LEAN_CODE_STANDARDS.md), this is a small, Salesforce-native, dependency-free base class with no Salesforce-specific adaptation needed, so it is vendored verbatim rather than refactored. See [AGENTIC_FRAMEWORK.md](../directives/AGENTIC_FRAMEWORK.md#installing-this-framework-into-a-new-repository) for how to re-pull updates from the source repository during a framework install or refresh.

The canonical copy of the base class lives at [`sf-platform-apex/assets/TriggerHandler.cls`](../skills/sf-platform-apex/assets/TriggerHandler.cls) (with matching `-meta.xml` and `TriggerHandlerTest.cls`). Deploy this class once per org/package; every trigger handler in the project extends it.

## Mandatory Pattern

Every trigger in this project must:

1. Contain no logic. The trigger body only constructs the handler and calls `run()`.
2. Delegate to a handler class named `{SObject}TriggerHandler` that `extends TriggerHandler`.
3. Override only the context methods it needs: `beforeInsert()`, `beforeUpdate()`, `beforeDelete()`, `afterInsert()`, `afterUpdate()`, `afterDelete()`, `afterUndelete()`.

```apex
trigger AccountTrigger on Account (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    new AccountTriggerHandler().run();
}
```

```apex
public with sharing class AccountTriggerHandler extends TriggerHandler {

    private Map<Id, Account> newMap;
    private Map<Id, Account> oldMap;

    public AccountTriggerHandler() {
        this.newMap = (Map<Id, Account>) Trigger.newMap;
        this.oldMap = (Map<Id, Account>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        // delegate to a Service/Domain class; do not inline business logic here
    }

    public override void afterUpdate() {
        // delegate to a Service/Domain class
    }
}
```

Cast `Trigger.new`/`Trigger.newMap`/`Trigger.old`/`Trigger.oldMap` to the concrete SObject type once, in the constructor — the base class exposes only the generic `Trigger` statics, matching standard Apex trigger context behavior.

This replaces the legacy "Custom Handler Pattern" (manual `if (Trigger.isBefore) { if (Trigger.isInsert) ... }` dispatch inside the trigger body) and the Trigger Actions Framework (TAF) option previously offered as alternatives in `sf-platform-apex/assets/trigger.cls`. Use TAF only when the project already has `Trigger_Action__mdt`-based actions deployed and in active use; do not introduce TAF net-new.

## Recursion Control (Max Loop Count)

Use `setMaxLoopCount` in the handler constructor when a context must run at most N times per transaction (typical case: prevent an `afterUpdate` that re-saves the same records from re-triggering itself):

```apex
public AccountTriggerHandler() {
    this.setMaxLoopCount(1);
}
```

Exceeding the max throws `TriggerHandler.TriggerHandlerException`. Use `clearMaxLoopCount()` if a handler must temporarily lift its own limit; do this only with a documented reason.

## Bypass API

Use the static bypass API to suppress a specific handler for a bounded section of code — never to silently swallow a handler for the rest of the transaction:

```apex
TriggerHandler.bypass('AccountTriggerHandler');
try {
    update accountsNeedingSystemUpdate;
} finally {
    TriggerHandler.clearBypass('AccountTriggerHandler');
}
```

- `TriggerHandler.bypass(handlerName)` / `TriggerHandler.clearBypass(handlerName)` — scope the bypass as tightly as possible; always pair with a `clearBypass` in a `finally` block so a thrown exception cannot leave the bypass active for the rest of the transaction.
- `TriggerHandler.isBypassed(handlerName)` — check before assuming a handler will or won't run.
- `TriggerHandler.clearAllBypasses()` — use only at a well-known transaction boundary (e.g. end of a batch `finish()`); never leave dangling bypasses across unrelated operations.
- `handlerName` is the simple class name (e.g. `'AccountTriggerHandler'`), matched against `getHandlerName()` internally — keep it in sync if a handler class is renamed.

## Testing

Test the trigger handler the same way as any other Apex class (see `sf-platform-test`): assert behavior per context by inserting/updating/deleting records and asserting the resulting state, not by calling private dispatch internals. The vendored `TriggerHandlerTest.cls` covers the base class itself (context detection, loop counting, bypass API) and does not need to be duplicated per-object; write `{SObject}TriggerHandlerTest` to cover the object-specific override logic only.

## Review Checklist

- Trigger file contains zero business logic.
- Handler class name is `{SObject}TriggerHandler` and extends `TriggerHandler`.
- Only the contexts actually needed are overridden.
- Business logic in each override is delegated to a Service/Domain/Selector class, not inlined.
- Any `setMaxLoopCount` or bypass usage has a one-line comment explaining why.
- Every `bypass(...)` has a matching `clearBypass(...)` in a `finally` block.

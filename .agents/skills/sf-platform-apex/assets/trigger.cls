/**
 * {SObject} Trigger
 */
trigger {SObject}Trigger on {SObject} (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    // ─── Mandatory pattern: extend TriggerHandler ────────────────────────
    // See assets/TriggerHandler.cls and APEX_TRIGGER_FRAMEWORK.md.
    new {SObject}TriggerHandler().run();

    // ─── Legacy option: Trigger Actions Framework (TAF) ──────────────────
    // Use only if Trigger_Action__mdt-based actions are already deployed
    // and in active use in this org. Do not introduce TAF net-new.
    //
    // new MetadataTriggerHandler().run();
}

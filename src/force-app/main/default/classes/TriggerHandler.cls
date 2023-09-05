public abstract class TriggerHandler {
    protected List<SObject> newRecords;
    protected Map<Id, SObject> oldRecordMap;

    protected TriggerHandler() {
        this.newRecords = (List<SObject>) Trigger.new;
        this.oldRecordMap = (Map<Id, SObject>) Trigger.oldMap;
    }

    public static TriggerHandler configureHandler(Type triggerHandler) {
        return (TriggerHandler) triggerHandler.newInstance();
    }

    protected abstract void beforeInsert();
    protected abstract void beforeUpdate();

    public void execute() {
        if (Trigger.isBefore && Trigger.isInsert) {
            beforeInsert();
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            beforeUpdate();
        }
    }
}
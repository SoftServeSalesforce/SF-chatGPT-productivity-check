
public with sharing class CaseSelector {
    @TestVisible
    private static CaseSelector instance;

    public static CaseSelector getInstance() {
        if (instance == null) {
            instance = new CaseSelector();
        }
        return instance;
    }

    public List<Case> getCasesWithOwnerStatusByIds(Set<Id> caseIds) {
        return [SELECT Id, Owner.IsActive FROM Case WHERE Id IN :caseIds WITH SECURITY_ENFORCED];
    }
}
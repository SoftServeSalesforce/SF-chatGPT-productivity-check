/**
 * @description OrderSelector: Selector to access "ContentDocumentLink" SObject records.
 */
public with sharing class ContentDocumentLinkSelector {

    @TestVisible
    private static ContentDocumentLinkSelector instance;

    public static ContentDocumentLinkSelector getInstance() {
        if (instance == null) {
            instance = new ContentDocumentLinkSelector();
        }
        return instance;
    }

    public List<ContentDocumentLink> getAttachedInvoicesOrderedByCDLMD(Set<Id> parentRecordsIds) {
        return [
            SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :parentRecordsIds
                AND ContentDocument.Title LIKE :Constants.SOQL_STARTS_WITH_INVOICE
            WITH SECURITY_ENFORCED
            ORDER BY ContentDocument.LastModifiedDate DESC
        ];
    }
}
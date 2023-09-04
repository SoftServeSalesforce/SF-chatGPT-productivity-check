/**
 * @description OrderSelector: Apex Class used to access "ContentDocumentLink" SObject records.
 * @note: Uses inherited sharing to enforce the sharing rules of the class that calls it.
 * //TODO: Cover with Apex Tests.
 */
public inherited sharing class ContentDocumentLinkSelector {

    @TestVisible
    private static ContentDocumentLinkSelector instance;

    /**
     * @description getInstance: Public access to the Class.
     * @return: Selector instance.
     */
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
            ORDER BY ContentDocument.LastModifiedDate DESC
        ];
    }
}
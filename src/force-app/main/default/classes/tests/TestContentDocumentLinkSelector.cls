@IsTest
public with sharing class TestContentDocumentLinkSelector {
    @IsTest
    private static void getAttachedInvoicesOrderedByCDLMDTest() {
        Set<Id> parentRecordsIds = new Set<Id> { fflib_IDGenerator.generate(Order.SobjectType) };
        List<ContentDocumentLink> expected = [
            SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :parentRecordsIds
                AND ContentDocument.Title LIKE :Constants.SOQL_STARTS_WITH_INVOICE
            WITH SECURITY_ENFORCED
            ORDER BY ContentDocument.LastModifiedDate DESC
        ];
        List<ContentDocumentLink> actual
            = ContentDocumentLinkSelector.getInstance().getAttachedInvoicesOrderedByCDLMD(parentRecordsIds);
        System.assertEquals(expected, actual);
    }
}
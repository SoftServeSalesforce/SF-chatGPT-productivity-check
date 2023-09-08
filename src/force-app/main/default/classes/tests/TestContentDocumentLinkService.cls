@IsTest
public with sharing class TestContentDocumentLinkService {
    @IsTest
    private static void getTheMostRecentInvoicesIdsByParentIdTest_multipleInvoiceReturned() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ContentDocumentLinkSelector selectorMock = (ContentDocumentLinkSelector)mocks.mock(ContentDocumentLinkSelector.class);
        ContentDocumentLinkSelector.instance = selectorMock;
        //Prepare data.
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Id cdIdOld = fflib_IDGenerator.generate(ContentDocument.SobjectType);
        Id cdIdNew = fflib_IDGenerator.generate(ContentDocument.SobjectType);
        Id cvIdOld = fflib_IDGenerator.generate(ContentVersion.SobjectType);
        Id cvIdNew = fflib_IDGenerator.generate(ContentVersion.SobjectType);
        Id cdlIdOld = fflib_IDGenerator.generate(ContentDocumentLink.SobjectType);
        Id cdlIdNew = fflib_IDGenerator.generate(ContentDocumentLink.SobjectType);
        Set<Id> parentRecordsIds = new Set<Id> { orderId };
        ContentDocumentLink cdlNew = (ContentDocumentLink)JSON.deserialize(
            Constants.CLD_WITH_LINKED_ENTITY_CD_AND_CV_TEMPLATE
                .replace('{0}', cdlIdNew)
                .replace('{1}', orderId)
                .replace('{2}', cdIdNew)
                .replace('{3}', cvIdNew),
            SObject.class
        );
        ContentDocumentLink cdlOld = (ContentDocumentLink)JSON.deserialize(
            Constants.CLD_WITH_LINKED_ENTITY_CD_AND_CV_TEMPLATE
                .replace('{0}', cdlIdOld)
                .replace('{1}', orderId)
                .replace('{2}', cdIdOld)
                .replace('{3}', cvIdOld),
            SObject.class
        );
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink> { cdlNew, cdlOld };
        //Stub data.
        mocks.startStubbing();
        mocks.when(selectorMock.getAttachedInvoicesOrderedByCDLMD(parentRecordsIds)).thenReturn(cdls);
        mocks.stopStubbing();
        //Execute scenario.
        Map<Id, Id> result = ContentDocumentLinkService.getInstance().getTheMostRecentInvoicesIdsByParentId(parentRecordsIds);
        //Verify outcomes.
        System.assertNotEquals(null, result);
        System.assert(!result.isEmpty());
        System.assert(result.containsKey(orderId));
        System.assertEquals(cvIdNew, result.get(orderId));
        ((ContentDocumentLinkSelector) mocks.verify(selectorMock, 1)).getAttachedInvoicesOrderedByCDLMD(parentRecordsIds);
    }

    @IsTest
    private static void getTheMostRecentInvoicesIdsByParentIdTest_oneInvoiceReturned() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ContentDocumentLinkSelector selectorMock = (ContentDocumentLinkSelector)mocks.mock(ContentDocumentLinkSelector.class);
        ContentDocumentLinkSelector.instance = selectorMock;
        //Prepare data.
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Id cdId = fflib_IDGenerator.generate(ContentDocument.SobjectType);
        Id cvId = fflib_IDGenerator.generate(ContentVersion.SobjectType);
        Id cdlId = fflib_IDGenerator.generate(ContentDocumentLink.SobjectType);
        Set<Id> parentRecordsIds = new Set<Id> { orderId };
        ContentDocumentLink cdl = (ContentDocumentLink)JSON.deserialize(
            Constants.CLD_WITH_LINKED_ENTITY_CD_AND_CV_TEMPLATE
                .replace('{0}', cdlId)
                .replace('{1}', orderId)
                .replace('{2}', cdId)
                .replace('{3}', cvId),
            SObject.class
        );
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink> { cdl };
        //Stub data.
        mocks.startStubbing();
        mocks.when(selectorMock.getAttachedInvoicesOrderedByCDLMD(parentRecordsIds)).thenReturn(cdls);
        mocks.stopStubbing();
        //Execute scenario.
        Map<Id, Id> result = ContentDocumentLinkService.getInstance().getTheMostRecentInvoicesIdsByParentId(parentRecordsIds);
        //Verify outcomes.
        System.assertNotEquals(null, result);
        System.assert(!result.isEmpty());
        System.assert(result.containsKey(orderId));
        System.assertEquals(cvId, result.get(orderId));
        ((ContentDocumentLinkSelector) mocks.verify(selectorMock, 1)).getAttachedInvoicesOrderedByCDLMD(parentRecordsIds);
    }

    @IsTest
    private static void getTheMostRecentInvoicesIdsByParentIdTest_noInvoicesReturned() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ContentDocumentLinkSelector selectorMock = (ContentDocumentLinkSelector)mocks.mock(ContentDocumentLinkSelector.class);
        ContentDocumentLinkSelector.instance = selectorMock;
        //Prepare data.
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Set<Id> parentRecordsIds = new Set<Id> { orderId };
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        //Stub data.
        mocks.startStubbing();
        mocks.when(selectorMock.getAttachedInvoicesOrderedByCDLMD(parentRecordsIds)).thenReturn(cdls);
        mocks.stopStubbing();
        //Execute scenario.
        Map<Id, Id> result = ContentDocumentLinkService.getInstance().getTheMostRecentInvoicesIdsByParentId(parentRecordsIds);
        //Verify outcomes.
        System.assertNotEquals(null, result);
        System.assert(result.isEmpty());
        ((ContentDocumentLinkSelector) mocks.verify(selectorMock, 1)).getAttachedInvoicesOrderedByCDLMD(parentRecordsIds);
    }

    @IsTest
    private static void getTheMostRecentInvoicesIdsByParentIdTest_parentRecordsIdsIsBlank() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ContentDocumentLinkSelector selectorMock = (ContentDocumentLinkSelector)mocks.mock(ContentDocumentLinkSelector.class);
        ContentDocumentLinkSelector.instance = selectorMock;
        //Prepare data.
        Set<Id> parentRecordsIds = new Set<Id>();
        //Execute scenario.
        Map<Id, Id> result = ContentDocumentLinkService.getInstance().getTheMostRecentInvoicesIdsByParentId(parentRecordsIds);
        //Verify outcomes.
        System.assertNotEquals(null, result);
        System.assert(result.isEmpty());
        ((ContentDocumentLinkSelector) mocks.verify(selectorMock, 0)).getAttachedInvoicesOrderedByCDLMD(parentRecordsIds);
    }

    @IsTest
    private static void getTheMostRecentInvoicesIdsByParentIdTest_parentRecordsIdsIsNull() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ContentDocumentLinkSelector selectorMock = (ContentDocumentLinkSelector)mocks.mock(ContentDocumentLinkSelector.class);
        ContentDocumentLinkSelector.instance = selectorMock;
        //Prepare data.
        Set<Id> parentRecordsIds;
        //Execute scenario.
        Map<Id, Id> result = ContentDocumentLinkService.getInstance().getTheMostRecentInvoicesIdsByParentId(parentRecordsIds);
        //Verify outcomes.
        System.assertNotEquals(null, result);
        System.assert(result.isEmpty());
        ((ContentDocumentLinkSelector) mocks.verify(selectorMock, 0)).getAttachedInvoicesOrderedByCDLMD(parentRecordsIds);
    }
}
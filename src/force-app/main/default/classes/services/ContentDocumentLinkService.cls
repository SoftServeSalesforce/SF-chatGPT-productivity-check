/**
 * @description ContentDocumentLinkService: ContentDocumentLink Service to capture Business logic.
 */
public with sharing class ContentDocumentLinkService {
    @TestVisible
    private static ContentDocumentLinkService instance;

    public static ContentDocumentLinkService getInstance() {
        if (instance == null) {
            instance = new ContentDocumentLinkService();
        }
        return instance;
    }

    public Map<Id, Id> getTheMostRecentInvoicesIdsByParentId(Set<Id> parentRecordsIds) {
        Map<Id, Id> result = new Map<Id, Id>();
        if (null != parentRecordsIds && !parentRecordsIds.isEmpty()) {
            List<ContentDocumentLink> cdls = ContentDocumentLinkSelector.getInstance().getAttachedInvoicesOrderedByCDLMD(parentRecordsIds);
            for (ContentDocumentLink cdl : cdls) {
                if (result.containsKey(cdl.LinkedEntityId)) {
                    //Recent ivoice already added.
                    continue;
                }
                result.put(cdl.LinkedEntityId, cdl.ContentDocument?.LatestPublishedVersionId);
            }
        }
        return result;
    }
}
/**
 * @description ContentDocumentLinkService: ContentDocumentLink Service to capture Business logic.
 * @note: Uses inherited sharing to enforce the sharing rules of the class that calls it.
 * //TODO: Cover with Apex Tests.
 */
public inherited sharing class ContentDocumentLinkService {
    @TestVisible
    private static ContentDocumentLinkService instance;

    /**
     * @description getInstance: Public access to the Class.
     * @return: Selector instance.
     */
    public static ContentDocumentLinkService getInstance() {
        if (instance == null) {
            instance = new ContentDocumentLinkService();
        }
        return instance;
    }

    public Map<Id, ContentDocumentLink> getTheMostRecentInvoicesByParentId(Set<Id> parentRecordsIds) {
        Map<Id, ContentDocumentLink> result = new Map<Id, ContentDocumentLink>();
        List<ContentDocumentLink> cdls = ContentDocumentLinkSelector.getInstance().getAttachedInvoicesOrderedByCDLMD(parentRecordsIds);
        for (ContentDocumentLink cdl : cdls) {
            if (result.containsKey(cdl.LinkedEntityId)) {
                //Recent ivoice already added.
                continue;
            }
            result.put(cdl.LinkedEntityId, cdl);
        }
        return result;
    }
}
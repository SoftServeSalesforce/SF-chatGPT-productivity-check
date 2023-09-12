Savepoint sp = Database.setSavepoint();
try {
    // Fetch the Orders created in the previous scripts
    List<Order> orders = [SELECT Id FROM Order WHERE Account.Name = 'SoftServe Inc.' OFFSET 200];

    // Create Content Files for the next 200 orders
    List<ContentVersion> allCVs = new List<ContentVersion>();
    for (Integer i = 200; i < 400; i++) {
        if (Math.mod(i, 4) == 1) {
            allCVs.add(new ContentVersion(Title = 'Invoice-' + i + '.pdf', PathOnClient = 'Invoice-' + i + '.pdf', VersionData = Blob.valueOf('Test Content')));
        } else if (Math.mod(i, 4) == 2) {
            allCVs.add(new ContentVersion(Title = 'test-' + i + '.pdf', PathOnClient = 'test-' + i + '.pdf', VersionData = Blob.valueOf('Test Content')));
        } else if (Math.mod(i, 4) == 3) {
            allCVs.add(new ContentVersion(Title = 'Invoice-' + i + '.pdf', PathOnClient = 'Invoice-' + i + '.pdf', VersionData = Blob.valueOf('Test Content')));
            allCVs.add(new ContentVersion(Title = 'test-' + i + '.pdf', PathOnClient = 'test-' + i + '.pdf', VersionData = Blob.valueOf('Test Content')));
        }
    }
    insert allCVs;

    // Create ContentDocumentLinks for the next 200 orders
    List<ContentDocumentLink> allCDLs = new List<ContentDocumentLink>();
    Map<String, Id> titleToContentDocumentId = new Map<String, Id>();
    for (ContentDocument cd : [SELECT Id, Title FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :allCVs)]) {
        titleToContentDocumentId.put(cd.Title, cd.Id);
    }

    for (Integer i = 200; i < 400; i++) {
        String invoiceTitle = 'Invoice-' + i + '.pdf';
        String testTitle = 'test-' + i + '.pdf';
        if (titleToContentDocumentId.containsKey(invoiceTitle)) {
            allCDLs.add(new ContentDocumentLink(ContentDocumentId = titleToContentDocumentId.get(invoiceTitle), LinkedEntityId = orders[i-200].Id, ShareType = 'V'));
        }
        if (titleToContentDocumentId.containsKey(testTitle)) {
            allCDLs.add(new ContentDocumentLink(ContentDocumentId = titleToContentDocumentId.get(testTitle), LinkedEntityId = orders[i-200].Id, ShareType = 'V'));
        }
    }
    insert allCDLs;
} catch (Exception e) {
    Database.rollback(sp);
    System.debug('EXCEPTION: ' + e.getMessage());
}

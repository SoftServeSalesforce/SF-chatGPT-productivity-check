        Blob body = Blob.valueOf('Test Content');
        private static ContentVersion createContentVersion(String fileName, String id) {
            return new ContentVersion(
                Title = fileName,
                PathOnClient = '/' + fileName,
                VersionData = body,
                IsMajorVersion = true,
                Description = id
            );
        }
        // 1. Create 5 products
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'HP ZBook', IsActive = true),
            new Product2(Name = 'Mac Book Pro', IsActive = true),
            new Product2(Name = 'Dell Inspiron', IsActive = true),
            new Product2(Name = 'SFDC Apex Development', IsActive = true),
            new Product2(Name = 'LWC Development', IsActive = true)
        };
        insert products;

        // 2. Create Pricebook entries for standard pricebook and each product
        Id standardPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        for(Product2 product : products) {
            pbeList.add(new PricebookEntry(
                Pricebook2Id = standardPricebookId, 
                Product2Id = product.Id, 
                UnitPrice = Math.round(Math.random() * 1000) + 1, // Arbitrary non-zero price
                IsActive = true
            ));
        }
        insert pbeList;

        // 3. Create Account record
        Account acc = new Account(Name = 'SoftServe Inc.');
        insert acc;

        // 4. Create activated Contract
        Contract con = new Contract(
            AccountId = acc.Id, 
            StartDate = Date.today(), 
            ContractTerm = 12, 
            Status = 'Draft'
        );
        insert con;
        con.Status = 'Activated';
        update con;

        // 5. Create 400 orders and their order items
        List<Order> ordersList = new List<Order>();
        List<OrderItem> orderItemsList = new List<OrderItem>();
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        List<String> statuses = new List<String>{'Draft', 'Activated', 'Shipped', 'Delivered'};
        
            for(Integer i=0; i<400; i++) {
                Order ord = new Order(
                    AccountId = acc.Id, 
                    ContractId = con.Id, 
                    Status = statuses[0], 
                    EffectiveDate = Date.today(),
                    Pricebook2Id = standardPricebookId
                );
                ordersList.add(ord);
            }

        insert ordersList;

        for(Order ord : ordersList) {
            for(PricebookEntry pbe : pbeList) {
                orderItemsList.add(new OrderItem(
                    OrderId = ord.Id, 
                    PricebookEntryId = pbe.Id, 
                    Quantity = 1, 
                    UnitPrice = pbe.UnitPrice
                ));
            }
        }
        insert orderItemsList;

        for(Integer i=0; i<100; i++) {
            if(i >= 25 && i <= 50) {
                    contentVersions.add(createContentVersion('Invoice-' + i + '.pdf', ordersList[i].Id));
                } else if(i > 50 && i <= 75) {
                    contentVersions.add(createContentVersion('test-' + i + '.pdf', ordersList[i].Id));
                } else if(i > 75) {
                    contentVersions.add(createContentVersion('Invoice-' + i + '.pdf', ordersList[i].Id));
                    contentVersions.add(createContentVersion('test-' + i + '.pdf', ordersList[i].Id));
                }
        }
        for(Integer i=100; i<200; i++) {
            ordersList[i].Status = statuses[1];
                if(i >= 125 && i <= 150) {
                    contentVersions.add(createContentVersion('Invoice-' + i + '.pdf', ordersList[i].Id));
                } else if(i > 150 && i <= 175) {
                    contentVersions.add(createContentVersion('test-' + i + '.pdf', ordersList[i].Id));
                } else if(i > 175) {
                    contentVersions.add(createContentVersion('Invoice-' + i + '.pdf', ordersList[i].Id));
                    contentVersions.add(createContentVersion('test-' + i + '.pdf', ordersList[i].Id));
                }
        }
        for(Integer i=200; i<300; i++) {
            ordersList[i].Status = statuses[2];
                if(i >= 225 && i <= 250) {
                    contentVersions.add(createContentVersion('Invoice-' + i + '.pdf', ordersList[i].Id));
                } else if(i > 250 && i <= 275) {
                    contentVersions.add(createContentVersion('test-' + i + '.pdf', ordersList[i].Id));
                } else if(i > 275) {
                    contentVersions.add(createContentVersion('Invoice-' + i + '.pdf', ordersList[i].Id));
                    contentVersions.add(createContentVersion('test-' + i + '.pdf', ordersList[i].Id));
                }
        }
        for(Integer i=300; i<400; i++) {
            ordersList[i].Status = statuses[3];
                // if(i >= 325 && i <= 350) {
                //     contentVersions.add(createContentVersion('Invoice-' + i + '.pdf', ordersList[i].Id));
                // } else if(i > 350 && i <= 375) {
                //     contentVersions.add(createContentVersion('test-' + i + '.pdf', ordersList[i].Id));
                // } else if(i > 375) {
                //     contentVersions.add(createContentVersion('Invoice-' + i + '.pdf', ordersList[i].Id));
                //     contentVersions.add(createContentVersion('test-' + i + '.pdf', ordersList[i].Id));
                // }
        }

        update ordersList;

        insert contentVersions;

        List<Id> contentVersionsIds = new List<Id>();
        for (ContentVersion cv : contentVersions) {
            contentVersionsIds.add(cv.Id);
        }
        contentVersions = [SELECT ContentDocumentId, Description FROM ContentVersion WHERE Id IN :contentVersionsIds];
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();

         for(ContentVersion cv : contentVersions) {
                cdlList.add(new ContentDocumentLink(
                    ContentDocumentId = cv.ContentDocumentId,
                    LinkedEntityId = cv.Description,
                    ShareType = 'V'
                ));
            }

        insert cdlList;
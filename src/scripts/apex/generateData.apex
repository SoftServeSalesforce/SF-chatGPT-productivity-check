final String DRAFT_STATUS = 'Draft';
         final String ACTIVATED_STATUS = 'Activated';
         final String SHIPPED_STATUS = 'Shipped';
         final String DELIVERED_STATUS = 'Delivered';
         Date today = System.today();
         final Decimal UNIT_PRICE = 2;

        Account acc = new Account(Name = 'SoftServe Inc.');
        insert acc;

        PaginationPageSize__c settings = new PaginationPageSize__c();        
        settings.Page_Size__c = 10; 
        insert settings;
        
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];

        List<Product2> products = new List<Product2>{
            new Product2(Name = 'HP ZBook', IsActive = true),
            new Product2(Name = 'Mac Book Pro', IsActive = true),
            new Product2(Name = 'Dell Inspiron', IsActive = true),
            new Product2(Name = 'SFDC Apex Development', IsActive = true),
            new Product2(Name = 'LWC Development', IsActive = true)
        };
        insert products;

        List<PricebookEntry> pbEntries = new List<PricebookEntry>();
        for(Product2 prod : products) {            
            pbEntries.add(new PricebookEntry(
                Product2Id = prod.Id,
                Pricebook2Id = standardPricebook.Id,
                UnitPrice = UNIT_PRICE,
                IsActive = true
            ));
        }
        insert pbEntries; 

        Contract cont = new Contract(
            AccountId = acc.Id,
            StartDate = today,
            ContractTerm = 12,
            Status = DRAFT_STATUS
        );
        insert cont;       

        cont.Status = ACTIVATED_STATUS;
        update cont;
        
        List<Order> orders = new List<Order>();
        for(Integer i = 0; i < 400; i++) {
            orders.add(new Order(
                AccountId = acc.Id,
                Status = DRAFT_STATUS,
                ContractId = cont.Id,
                EffectiveDate = today,
                Pricebook2Id = standardPricebook.Id));
        }

        insert orders;             

        List<OrderItem> orderItems = new List<OrderItem>();
        for(Order o : orders) {
            for(PricebookEntry pbe : pbEntries) {
                orderItems.add(new OrderItem(
                    OrderId = o.Id,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1,
                    UnitPrice = UNIT_PRICE
                ));
            }
        }
        insert orderItems;

        for(Integer i = 0; i < 300; i++) {            
            if (i < 100) orders[i].Status = ACTIVATED_STATUS;
            else if (i < 200) orders[i].Status = SHIPPED_STATUS;
            else orders[i].Status = DELIVERED_STATUS;
        }
        update orders;

        Blob dammyVersionData = Blob.valueOf('Test Data');
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for(Integer i = 0; i < 100; i++) { 
            String titleInvoice = 'Invoice-' + i + '.pdf'; 
            String titleTest = 'test-' + i + '.pdf'; 

                contentVersions.add(new ContentVersion(
                    Title = titleInvoice, 
                    VersionData = dammyVersionData,                   
                    PathOnClient = titleInvoice
                ));            
                contentVersions.add(new ContentVersion(
                    Title = titleTest,
                    VersionData = dammyVersionData,
                    PathOnClient = titleTest
                ));
           
        }
        insert contentVersions;  

        List<ContentVersion> contentVersionsList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersions];

        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();

        Integer contentVersionsListSize = contentVersionsList.size() - 1;
        Integer ordersSize = orders.size() - 1;

        for (Integer i = 0; i < 100; i++) {
                cdls.add(new ContentDocumentLink(
                    ContentDocumentId = contentVersionsList[i].ContentDocumentId,
                    LinkedEntityId = orders[i].Id
                )); 
                cdls.add(new ContentDocumentLink(
                    ContentDocumentId = contentVersionsList[contentVersionsListSize - i].ContentDocumentId,
                    LinkedEntityId = orders[ordersSize - i].Id
                ));               
        }        
       
        insert cdls;
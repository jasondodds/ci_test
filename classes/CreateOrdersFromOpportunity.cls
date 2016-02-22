public with sharing class CreateOrdersFromOpportunity {

        public Opportunity oppty;
        public Account acct {get;set;}
        public CHANNEL_ORDERS__Customer__c customer {get;set;}
        public CHANNEL_ORDERS__Service_Order__c service {get;set;}
        public List<OpportunityLineItem> opptyLineItem {get;set;}
        public csboss__BOSS_Order__c createOrder {get;set;}
        public Boolean hasMessage {get;set;}
        public String whichAddress {get;set;}
        public List<CHANNEL_ORDERS__Customer__c> customerExists {get;set;}
        public sfLma__License__c lic {get;set;}


        public CreateOrdersFromOpportunity(ApexPages.StandardController controller) 
        {
         oppty =  [SELECT Id,Name, OwnerId, csboss__Partner_Contract_Terms__c, AccountId, csboss__License__c,csboss__Service_Start_Date__c,
                   csboss__Date_Partner_Received_Customer_Order__c,csboss__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c,
                   csboss__Channel_Order_Type__c, Pricebook2Id, csboss__BOSS_Order_URL__c, csboss__Service_Order_URL__c,
                   CampaignId
                   FROM Opportunity 
                   WHERE Id = :controller.getId()];

         opptyLineItem = [SELECT Id, OpportunityId, Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.Id
                          FROM OpportunityLineItem
                          WHERE OpportunityId =:oppty.Id];                                 
         customer = new CHANNEL_ORDERS__Customer__c();
         service = new CHANNEL_ORDERS__Service_Order__c();
         createOrder = new csboss__BOSS_Order__c();

         lic = [SELECT Id, sfLma__Subscriber_Org_ID__c FROM sfLma__License__c WHERE Id = :oppty.csboss__License__c];

         customerExists = [SELECT Id,CHANNEL_ORDERS__Customer_Org_ID__c, csboss__Related_License__c 
                           FROM CHANNEL_ORDERS__Customer__c 
                           WHERE CHANNEL_ORDERS__Customer_Org_ID__c = :lic.sfLma__Subscriber_Org_ID__c];


         hasMessage = FALSE;
        }

        public PageReference OperationalCheck()
        {

          //Just say "No" to duplicate Service Orders.
          List<CHANNEL_ORDERS__Service_Order__c> ordersList = new List<CHANNEL_ORDERS__Service_Order__c> ([SELECT Id, CHANNEL_ORDERS__Customer__c 
                                                                                                          FROM CHANNEL_ORDERS__Service_Order__c
                                                                                                          WHERE CHANNEL_ORDERS__Related_Opportunity__c = :oppty.Id]);
 
          List<OpportunityLineItem> lineItemsWithBadContracts = new List<OpportunityLineItem>();

          Integer counter = 0;
          for(OpportunityLineItem oli : opptyLineItem)
          {
            if(counter < opptyLineItem.size())
              {
                if(Oppty.csboss__Partner_Contract_Terms__c != oli.Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.Id)
                {
                  lineItemsWithBadContracts.add(oli);
                  counter++;
                }
                else
                {
                  counter++;
                }
              }
          }

          if(ordersList.size() == 0 )
          {
            if(lineItemsWithBadContracts.size() == 0)
            {
              if(oppty.AccountId != NULL && oppty.csboss__License__c != NULL && oppty.csboss__Partner_Contract_Terms__c != NULL)
                  {
                    hasMessage = FALSE;
                    populateClassProperties(oppty);
                  }
              else
                  {
                    hasMessage = TRUE;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You need to have an Account, License, and Partner Contract Terms setup within this Opportunity before proceeding.'));
                  }
              }
              else
            {
              hasMessage = TRUE;
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Partner Contract Terms assigned to your Opportunity Line Item(s) must match the Partner Contract Terms assigned to your Opportunity.'));
            }
          }
          else
          {
          hasMessage = TRUE;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'A Service Order already exists for this Opportunity.'));
          }
           return null;
        }

        public Id populateClassProperties(Opportunity oppty)
        {
          whichAddress  = 'billing';

          acct = [SELECT Id,Name,BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,
                           ShippingStreet,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState
                  FROM Account WHERE Id = :oppty.AccountId];

          CHANNEL_ORDERS__Partner_Contract_Terms__c channel = [SELECT Id
                                                               FROM CHANNEL_ORDERS__Partner_Contract_Terms__c 
                                                               WHERE Id = :oppty.csboss__Partner_Contract_Terms__c];
          List<Contact> con = [SELECT Id, AccountId
                               FROM Contact 
                               WHERE AccountId = :acct.Id];
          Map<Id,Id> mapOfAccountAndContact = new Map<Id,Id>();
          if(con.size() > 0)
          {
            for(Contact ct : con)
            {
              mapOfAccountAndContact.put(ct.AccountId,ct.Id);
            }
          }
//Create BOSS Order
          createOrder.csboss__Opportunity__c = oppty.Id;
          createOrder.csboss__Campaign__c = oppty.CampaignId;
          createOrder.csboss__Account__c = oppty.AccountId; 
          if(mapOfAccountAndContact.containsKey(oppty.AccountId))
            {
              createOrder.csboss__Contact__c = mapOfAccountAndContact.get(oppty.AccountId);
            }
          if(oppty.csboss__License__c != NULL)
            {       
              createOrder.csboss__License__c = oppty.csboss__License__c;
            }
//Create Service Order
            service.CHANNEL_ORDERS__Related_Opportunity__c                         = oppty.Id; 
            service.CHANNEL_ORDERS__Service_Start_Date__c                          = oppty.csboss__Service_Start_Date__c;
            service.CHANNEL_ORDERS__Partner_Contract_Rules__c                      = String.valueOf(oppty.csboss__Partner_Contract_Terms__c).subString(0,15);
            service.CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c        = oppty.csboss__Date_Partner_Received_Customer_Order__c;        
            service.CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c      = oppty.csboss__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c;
            service.CHANNEL_ORDERS__Order_Type__c                                  = oppty.csboss__Channel_Order_Type__c;
            service.CHANNEL_ORDERS__I_certify__c                                   = 'Yes';
            service.csboss__License__c                                             = lic.Id;
//Create Customer
            if(customerExists.size() >0)                                         
            {
              for(CHANNEL_ORDERS__Customer__c check :  customerExists)
                {
                  customer.CHANNEL_ORDERS__Customer_Org_ID__c                     = lic.sfLma__Subscriber_Org_ID__c;
                  service.CHANNEL_ORDERS__Customer__c                             = check.Id;
                  service.CHANNEL_ORDERS__Customer_Org_ID__c                      = check.CHANNEL_ORDERS__Customer_Org_ID__c;
                }
            }
            else 
            { 
              customer = new CHANNEL_ORDERS__Customer__c(); 
              customer.csboss__Related_License__c                                 = lic.Id;
              customer.CHANNEL_ORDERS__Customer_Org_ID__c                         = lic.sfLma__Subscriber_Org_ID__c;
              customer.CHANNEL_ORDERS__Customer_Company_Name__c                   = acct.Name;
              populateAddress();      
            } 
        return null;
        }

        public void populateAddress()
        {
          if(whichAddress == 'billing')
          {
            customer.CHANNEL_ORDERS__Customer_Street__c                     = acct.billingStreet;
            customer.CHANNEL_ORDERS__Customer_City__c                       = acct.billingCity;
            customer.CHANNEL_ORDERS__Customer_State__c                      = acct.billingState;
            customer.CHANNEL_ORDERS__Customer_ZIP_Postal_Code__c            = acct.billingPostalCode;
            customer.CHANNEL_ORDERS__Customer_Country__c                    = acct.billingCountry;
          }
        else
          {
            customer.CHANNEL_ORDERS__Customer_Street__c                     = acct.shippingStreet;
            customer.CHANNEL_ORDERS__Customer_City__c                       = acct.shippingCity;
            customer.CHANNEL_ORDERS__Customer_State__c                      = acct.shippingState;
            customer.CHANNEL_ORDERS__Customer_ZIP_Postal_Code__c            = acct.shippingPostalCode;
            customer.CHANNEL_ORDERS__Customer_Country__c                    = acct.shippingCountry;
          }
        }

        public PageReference CreateOrdersAndRecord()
        {
          if(service.CHANNEL_ORDERS__Service_Start_Date__c >= System.Today())
          {
            hasMessage = FALSE;
            insert createOrder;
            if(customerExists.size() == 0)
            {
              insert customer;
            }
            service.CHANNEL_ORDERS__Customer__c = customer.Id;
            service.csboss__BOSS_Order__c   = createOrder.Id;
            service.CHANNEL_ORDERS__Customer_Org_ID__c      = customer.CHANNEL_ORDERS__Customer_Org_ID__c;
            insert service;
            createOrder.csboss__Service_Order_Status__c = service.CHANNEL_ORDERS__Service_Order_Status__c;
            String BOSSUrl = System.URL.getSalesforceBaseURL().toExternalForm() + '/'+ createOrder.Id;
            String ServiceURL = System.URL.getSalesforceBaseURL().toExternalForm() + '/'+ service.Id;
            String OpptyURL = System.URL.getSalesforceBaseURL().toExternalForm() + '/'+ oppty.Id;
            createOrder.csboss__Opportunity_URL__c = OpptyURL;
            createOrder.csboss__Service_Order_URL__c = ServiceURL;
            createOrder.csboss__Service_Order__c = service.Id;
            upsert createOrder;

        List<OpportunityLineItem> opptyProduct = new List<OpportunityLineItem>([SELECT Id,OpportunityId
                                                                                  FROM OpportunityLineItem
                                                                                 WHERE OpportunityId = :oppty.Id]);    
                if(opptyProduct.size() > 0)
                        {
                                CreateSerivceOrderLineItems();
                        }
                PageReference pr = new PageReference('/' + string.valueOf(createOrder.Id));     
                pr.setRedirect(TRUE);
                return pr;
            }
          else
          {
            hasMessage = TRUE;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Salesforce insists the Service Start Date cannot be a date in the past.'));
          }
          return null;
        }

        public PageReference swapAddress()
        {
          populateAddress();
          return null;
        }

        public void CreateSerivceOrderLineItems()
        {                                                                                                                                                                               
          List<OpportunityLineItem> opptyLineItem = [select Id, Description, OpportunityId, Product2Id, Quantity, UnitPrice, 
                                                    Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.Id, 
                                                    Product2.csboss__Related_Partner_Product_Catalog__r.Id, 
                                                    Product2.csboss__Related_Partner_Product_Catalog__r.Name, 
                                                    Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Billing_Frequency__c, 
                                                    Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Cancellation_Terms__c, 
                                                    Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Contract_Auto_Renew__c, 
                                                    Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Contract_Length__c, 
                                                    Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Renewal_Length__c  
                                                    from OpportunityLineItem
                                                    WHERE OpportunityId = :oppty.Id];

            List<CHANNEL_ORDERS__Service_Order_Detail__c> serviceDetail = new List<CHANNEL_ORDERS__Service_Order_Detail__c>();

            Integer counter = 0;
            for(OpportunityLineItem oppItem :opptyLineItem)
            {
              if(counter < opptyLineItem.size())
              {
                CHANNEL_ORDERS__Service_Order_Detail__c detailItem = new CHANNEL_ORDERS__Service_Order_Detail__c();

                detailItem.CHANNEL_ORDERS__pc_Partner_Contract_Term__c    = String.valueOf(oppty.csboss__Partner_Contract_Terms__c).subString(0,15);
                detailItem.CHANNEL_ORDERS__Product_Name__c                = oppItem.Product2.csboss__Related_Partner_Product_Catalog__r.Id;
                detailItem.CHANNEL_ORDERS__Partner_Order__c               = service.Id; 
                detailItem.CHANNEL_ORDERS__pc_Billing_Frequency__c        = oppItem.Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Billing_Frequency__c;
                detailItem.CHANNEL_ORDERS__pc_Cancellation_Terms__c       = oppItem.Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Cancellation_Terms__c;
                detailItem.CHANNEL_ORDERS__pc_Contract_Auto_Renew__c      = oppItem.Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Contract_Auto_Renew__c;
                detailItem.CHANNEL_ORDERS__pc_Contract_Length__c          = oppItem.Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Contract_Length__c;
                detailItem.CHANNEL_ORDERS__pc_Renewal_Terms__c            = oppItem.Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Renewal_Length__c;
                detailItem.CHANNEL_ORDERS__Customer_Price_Per_Month__c    = oppItem.UnitPrice;
                detailItem.CHANNEL_ORDERS__Product_Line_Description__c    = oppItem.Description;
                detailItem.CHANNEL_ORDERS__Quantity__c                    = oppItem.Quantity;
                detailItem.csboss__Related_Opportunity_Line_Item__c       = oppItem.Id;                                   
                serviceDetail.add(detailItem);
                counter ++;
                }
              }
              insert serviceDetail;
            /* 
              A separate BOSS Order Line Item is created by way of a Trigger on Service Order line item.
            */
          }


        public PageReference GoBack()
        {
          PageReference pr = new PageReference('/' + oppty.Id);
          pr.setRedirect(TRUE);
          return pr;
        }

}
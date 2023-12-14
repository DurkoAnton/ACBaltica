using { customer } from '../db/customer-data-model';
using {api as external} from './external/api';
using {opportunity as externalOppt} from './external/opportunity';
using {ticket as externalSR} from './external/ticket';
using {interaction as externalInteraction} from './external/interaction';

service CustomerService @(requires: 'authenticated-user'){
    @Capabilities : {
         InsertRestrictions.Insertable : true,
         UpdateRestrictions.Updatable  : true,
         DeleteRestrictions.Deletable  : false
    }

  entity Customer as projection on customer.Customer actions { 
    action UpdateInC4C();
    
    @cds.odata.bindingparameter.name : '_it'
    @Common.SideEffects : {    
        $Type:'Common.SideEffectsType', 
        TargetEntities : ['_it','_it/ToOpportunities', '_it/ToServiceRequests']        
    } 
    action updateAllFieldsFromRemote() returns Customer;
    };
  entity StatusCodes as projection on customer.StatusCodes;
  entity ServiceRequestStatusCode as projection on customer.ServiceRequestStatusCodes;
  entity CategoryCodes as projection on customer.CategoryCodes;
  entity Bank as projection on customer.Bank;
  
    entity Item as select from customer.Item 
  { *, toItemProduct.InternalID as ProductInternalID, toItemProduct.ProductCategory as ProductCategory, toItemProduct.ProductStatusDescription as ProductStatus };

 @Capabilities : {
         DeleteRestrictions.Deletable  : false
    }
  entity ItemProduct as projection on customer.ItemProduct;
   @Capabilities : {
         DeleteRestrictions.Deletable  : false
    }
  entity SalesPriceList as projection on customer.SalesPriceList;

  @cds.redirection.target
  entity Opportunity as projection on customer.Opportunity actions {
    action LoadProducts();

    @cds.odata.bindingparameter.name : '_it'
    @Common.SideEffects : {    
        $Type:'Common.SideEffectsType', 
        TargetEntities : ['_it','_it/Items', '_it/Attachment']        
    }   
    action updateFromRemote() returns Opportunity;
  };

  entity ServiceRequest as projection on customer.ServiceRequest actions {
    @cds.odata.bindingparameter.name : '_it'
    @Common.SideEffects : {    
        $Type:'Common.SideEffectsType', 
        TargetEntities : ['_it','_it/Attachment']        
    }   
    action updateFromRemote() /*returns ServiceRequest*/;
  }
  entity Attachement as projection on customer.Attachment;
  entity OpportunityStatusCode as projection on customer.OpportunityStatus;

  //Customer remote
  entity RemoteCustomer as projection on external.CorporateAccountCollection;
  entity RemoteContact as projection on external.ContactCollection;
  entity RemoteOwnerEmployee as projection on external.EmployeeBasicDataCollection;
  //Opportunity Remote
  entity RemoteOpportunity as projection on externalOppt.OpportunityCollection;
  //Service Requests Remote
  entity RemoteServiceRequest as projection on externalSR.ServiceRequestCollection;
  @Capabilities : {
         DeleteRestrictions.Deletable  : false,
         InsertRestrictions.Insertable  : false,
  }
  entity ServiceRequestInteraction as projection on customer.ServiceRequestInteraction;
  entity RemoteInteraction as projection on externalInteraction.ServiceRequestInteractionTicketCollection;
}
annotate CustomerService.Customer with @odata.draft.enabled;

// test
service ValueService {
      entity ValueHelpTable as projection on customer.ValueHelpTable;
}
annotate ValueService.ValueHelpTable with @odata.draft.enabled;

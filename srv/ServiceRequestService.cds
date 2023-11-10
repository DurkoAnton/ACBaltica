using { customer } from '../db/customer-data-model';

service ServiceRequestService {
     @Capabilities : {
      InsertRestrictions.Insertable : true,
      UpdateRestrictions.Updatable  : true,
      DeleteRestrictions.Deletable  : true
  }
  entity ServiceRequest as projection on customer.ServiceRequest actions {
    @cds.odata.bindingparameter.name : '_it'
    @Common.SideEffects : {    
        $Type:'Common.SideEffectsType', 
        TargetEntities : ['_it/Attachment']        
    }   
    action updateFromRemote() returns ServiceRequest;
  };
  entity Opportunity as projection on customer.Opportunity;
  entity Item as select from customer.Item 
  { *, toItemProduct.InternalID as ProductInternalID, toItemProduct.ProductCategory as ProductCategory, toItemProduct.ProductStatusDescription as ProductStatus };
  entity Attachement as projection on customer.Attachment;
  entity Customer as projection on customer.Customer;
  entity ServiceRequestStatusCode as projection on customer.ServiceRequestStatusCodes;
}
annotate ServiceRequestService.ServiceRequest with @odata.draft.enabled;
using { customer } from '../db/customer-data-model';
using {interaction as external} from './external/interaction';
using {ticket as externalSR} from './external/ticket';

service ServiceRequestService @(requires: 'authenticated-user'){
     @Capabilities : {
      InsertRestrictions.Insertable : true,
      UpdateRestrictions.Updatable  : true,
      DeleteRestrictions.Deletable  : true
  }
  entity ServiceRequest as projection on customer.ServiceRequest actions {
    @cds.odata.bindingparameter.name : '_it'
    @Common.SideEffects : {    
        $Type:'Common.SideEffectsType', 
        TargetEntities : ['_it','_it/Attachment']        
    }   
    action updateFromRemote() /*returns ServiceRequest*/;
  };
  entity Opportunity as projection on customer.Opportunity;
  entity Item as select from customer.Item 
  { *, toItemProduct.InternalID as ProductInternalID, toItemProduct.ProductCategory as ProductCategory, toItemProduct.ProductStatusDescription as ProductStatus,
  toItemProduct.Description as ProductDescription };
  
  //  @Capabilities : {
  //     InsertRestrictions.Insertable : {$edmJson: {$Eq: [{$Path: 'ServiceRequest/HasActiveEntity'},false]}},
  //     DeleteRestrictions.Deletable  : {$edmJson: {$Eq: [{$Path: 'ServiceRequest/HasActiveEntity'},false]}}
  // } 
  entity Attachement as projection on customer.Attachment;
  entity Customer as projection on customer.Customer;
  entity ServiceRequestStatusCode as projection on customer.ServiceRequestStatusCodes;

 @Capabilities : {
      InsertRestrictions.Insertable :false,
      DeleteRestrictions.Deletable  : false
  } 
  //Remote interaction
  entity ServiceRequestInteraction as projection on customer.ServiceRequestInteraction;
  entity RemoteInteraction as projection on external.ServiceRequestInteractionTicketCollection;
  entity RemoteServiceRequest as projection on externalSR.ServiceRequestCollection;

}
annotate ServiceRequestService.ServiceRequest with @odata.draft.enabled;
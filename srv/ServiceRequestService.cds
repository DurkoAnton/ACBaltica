using { customer } from '../db/customer-data-model';

service ServiceRequestService {
     @Capabilities : {
      InsertRestrictions.Insertable : true,
      UpdateRestrictions.Updatable  : true,
      DeleteRestrictions.Deletable  : true
  }
  entity ServiceRequest as projection on customer.ServiceRequest actions {
    action updateFromRemote() returns ServiceRequest;
  };
  entity Opportunity as projection on customer.Opportunity;
  entity Item as select from customer.Item 
  { *, toItemProduct.InternalID as ProductInternalID, toItemProduct.ProductCategory as ProductCategory, toItemProduct.ProductStatusDescription as ProductStatus };
  entity Attachement as projection on customer.Attachment;
  entity Customer as projection on customer.Customer;
}
annotate ServiceRequestService.ServiceRequest with @odata.draft.enabled;
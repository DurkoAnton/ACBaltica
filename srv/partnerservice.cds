using { partner } from '../db/data-model';
using { customer} from '../db/customer-data-model';

service PartnerService {
    @Capabilities : {
        InsertRestrictions.Insertable : true,
        UpdateRestrictions.Updatable  : true,
        DeleteRestrictions.Deletable  : true
    }
    entity PartnerProfile as projection on partner.partnerProfile
    actions{
      //@cds.odata.bindingparameter.name : '_it'
            // @Common.SideEffects : {
            //     TargetProperties : ['/ToCustomers']
            // } 
        action updateAllFieldsFromRemote() returns PartnerProfile;
    }
    entity Customer as projection on customer.Customer;
  entity Item as select from customer.Item 
  { *, toItemProduct.InternalID as ProductInternalID, toItemProduct.ProductCategory as ProductCategory, toItemProduct.ProductStatusDescription as ProductStatus };
  entity ItemProduct as projection on customer.ItemProduct;
  entity Bank as projection on customer.Bank;
  entity Opportunity as projection on customer.Opportunity actions {
    action LoadProducts();
    action updateFromRemote() returns Opportunity;
  };
  entity ServiceRequest as projection on customer.ServiceRequest actions {
    action updateFromRemote() returns ServiceRequest;
  };
  entity Attachement as projection on customer.Attachment;
  entity OpportunityStatusCode as projection on customer.OpportunityStatus;
  entity StatusCodes as projection on customer.StatusCodes;
  entity ServiceRequestStatusCode as projection on customer.ServiceRequestStatusCodes;
  entity CategoryCodes as projection on customer.CategoryCodes;
}

annotate PartnerService.PartnerProfile with @odata.draft.enabled;
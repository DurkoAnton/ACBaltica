using { customer } from '../db/customer-data-model';

service OpportunityService {
     @Capabilities : {
      InsertRestrictions.Insertable : true,
      UpdateRestrictions.Updatable  : true,
      DeleteRestrictions.Deletable  : true
  }
  entity Opportunity as projection on customer.Opportunity actions {
    action LoadProducts();
    action updateFromRemote() returns Opportunity;
  };
  entity Item as select from customer.Item 
  { *, toItemProduct.InternalID as ProductInternalID, toItemProduct.ProductCategory as ProductCategory, toItemProduct.ProductStatusDescription as ProductStatus };
  entity SalesPriceList as projection on customer.SalesPriceList;
  entity ItemProduct as projection on customer.ItemProduct;
  entity Attachement as projection on customer.Attachment;
  entity OpportunityStatusCode as projection on customer.OpportunityStatus;
  entity Customer as projection on customer.Customer;
}

annotate OpportunityService.Opportunity with @odata.draft.enabled;
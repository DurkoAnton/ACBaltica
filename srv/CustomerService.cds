using { customer } from '../db/customer-data-model';

service CustomerService {
    @Capabilities : {
         InsertRestrictions.Insertable : true,
         UpdateRestrictions.Updatable  : true,
         DeleteRestrictions.Deletable  : true
    }
  entity Customer as projection on customer.Customer actions { 
    action UpdateInC4C();
    action updateAllFieldsFromRemote() returns Customer;
    };
  entity StatusCodes as projection on customer.StatusCodes;
  entity ServiceRequestStatusCode as projection on customer.ServiceRequestStatusCodes;
  entity CategoryCodes as projection on customer.CategoryCodes;
  entity Bank as projection on customer.Bank;
  @cds.redirection.target
  entity Opportunity as projection on customer.Opportunity actions {
    action LoadProducts();
    action updateFromRemote() returns Opportunity;
  };
  entity Item as select from customer.Item 
  { *, toItemProduct.InternalID as ProductInternalID, toItemProduct.ProductCategory as ProductCategory, toItemProduct.ProductStatusDescription as ProductStatus };

  entity ItemProduct as projection on customer.ItemProduct;
  entity SalesPriceList as projection on customer.SalesPriceList;
  entity ServiceRequest as projection on customer.ServiceRequest actions {
    action updateFromRemote() returns ServiceRequest;
  }
  entity Attachement as projection on customer.Attachment;
  entity OpportunityStatusCode as projection on customer.OpportunityStatus;
}
annotate CustomerService.Customer with @odata.draft.enabled;
//annotate CustomerService.ProblemItems with @odata.draft.enabled;

// test
service ValueService {
      entity ValueHelpTable as projection on customer.ValueHelpTable;
}
annotate ValueService.ValueHelpTable with @odata.draft.enabled;

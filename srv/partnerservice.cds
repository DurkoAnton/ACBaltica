using { partner } from '../db/data-model';
using { customer} from '../db/customer-data-model';
using {api as external} from './external/api';

service PartnerService @(requires: 'authenticated-user'){
    @Capabilities : {
        InsertRestrictions.Insertable : true,
        UpdateRestrictions.Updatable  : true,
        DeleteRestrictions.Deletable  : false
    }
    entity PartnerProfile as projection on partner.partnerProfile
    actions{
        @cds.odata.bindingparameter.name : '_it'
        @Common.SideEffects : {    
            $Type:'Common.SideEffectsType', 
            TargetEntities : ['_it/ToCustomers']        
        }  
        action updateAllFieldsFromRemote() returns PartnerProfile;
    }
    //  @Capabilities : {
    //     InsertRestrictions.Insertable : true,
    //     UpdateRestrictions.Updatable  : true,
    //     DeleteRestrictions.Deletable  : true
    // }
    entity Customer as projection on customer.Customer;
  entity Item as select from customer.Item 
  { *, toItemProduct.InternalID as ProductInternalID, toItemProduct.ProductCategory as ProductCategory, toItemProduct.ProductStatusDescription as ProductStatus };
  entity ItemProduct as projection on customer.ItemProduct;
  entity Bank as projection on customer.Bank;
  entity Opportunity as projection on customer.Opportunity actions {
    action LoadProducts();

    @cds.odata.bindingparameter.name : '_it'
    @Common.SideEffects : {    
        $Type:'Common.SideEffectsType', 
        TargetEntities : ['_it/Items', '_it/Attachment']        
    }   
    action updateFromRemote() returns Opportunity;
  };
  entity ServiceRequest as projection on customer.ServiceRequest actions {
    @cds.odata.bindingparameter.name : '_it'
    @Common.SideEffects : {    
        $Type:'Common.SideEffectsType', 
        TargetEntities : ['_it/Attachment']        
    }   
    action updateFromRemote() returns ServiceRequest;
  };
  entity Attachement as projection on customer.Attachment;
  entity OpportunityStatusCode as projection on customer.OpportunityStatus;
  entity StatusCodes as projection on customer.StatusCodes;
  entity ServiceRequestStatusCode as projection on customer.ServiceRequestStatusCodes;
  entity CategoryCodes as projection on customer.CategoryCodes;

  //remote Objects
  entity RemoteCustomer as projection on external.CorporateAccountCollection;
  entity RemoteContact as projection on external.ContactCollection;
  //entity RemoteContactIsPersonFor as projection on external.ContactIsContactPersonForCollection;
  entity RemoteOwnerEmployee as projection on external.EmployeeBasicDataCollection;
}

annotate PartnerService.PartnerProfile with @odata.draft.enabled;
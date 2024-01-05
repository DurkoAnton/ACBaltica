using approval from '../db/approval-data-model';
using customer from '../db/customer-data-model';

service RequestApprovalService @(requires: 'authenticated-user') {
    @Capabilities : {
         DeleteRestrictions.Deletable  : true,
    }
    @odata.draft.enabled
    entity RequestApproval            as projection on approval.RequestApproval actions {
        @cds.odata.bindingparameter.name: '_it'
        @Common.SideEffects             : {
            $Type         : 'Common.SideEffectsType',
            TargetEntities: ['_it']
        }
        action sendRequestForApproval();
        @cds.odata.bindingparameter.name: '_it'
        @Common.SideEffects             : {
            $Type         : 'Common.SideEffectsType',
            TargetEntities: ['_it/Status']
        }
        action approve()                returns RequestApproval;
        @cds.odata.bindingparameter.name: '_it'
        @Common.SideEffects             : {
            $Type         : 'Common.SideEffectsType',
            TargetEntities: ['_it/Status']
        }
        action rejectApproval()         returns RequestApproval;
    };

    entity RequestApprovalStatusCodes as projection on approval.RequestApprovalStatusCodes;
    entity Customer                   as projection on customer.Customer;
}

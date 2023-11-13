using approval from '../db/approval-data-model';
using customer from '../db/customer-data-model';

service RequestApprovalService @(requires: 'authenticated-user'){
    @odata.draft.enabled
    entity RequestApproval as projection on approval.RequestApproval actions { action sendRequestForApproval()};
    entity Customer as projection on customer.Customer;
}
const cds = require('@sap/cds')

class RequestApprovalService extends cds.ApplicationService {
    init() {

        const { Customer, RequestApproval } = this.entities;

        this.on('sendRequestForApproval', async (req)=>{
            //form context body and trigger workflow for approval request
            const requestApprovalID = req.params[0].ID;
            const requestApproval = await SELECT.one.from(RequestApproval).where({ID : requestApprovalID});
            if (requestApproval){
                const customer = await SELECT.one.from(Customer).where({ID : requestApproval.CustomerID});
                if (customer){
                   const oldData = {
                        name : requestApproval.currentData_CustomerFormattedName,
                        responsibleManager : requestApproval.currentData_ResponsibleManager,
                        status: requestApproval.currentData_StatusDescription,
                        note: requestApproval.currentData_Note,
                        country: requestApproval.currentData_JuridicalCountry_name,
                        city: requestApproval.currentData_JuridicalCity,
                        street: requestApproval.currentData_JuridicalStreet,
                        house: requestApproval.currentData_JuridicalHomeID,
                        room: requestApproval.currentData_JuridicalRoomID,
                   }
                   const newData = {
                        name : requestApproval.newData_CustomerFormattedName,
                        responsibleManager : requestApproval.newData_ResponsibleManager,
                        status: requestApproval.newData_StatusCode_name,
                        note: requestApproval.newData_Note,
                        country: requestApproval.newData_JuridicalCountry_descr,
                        city: requestApproval.newData_JuridicalCity,
                        street: requestApproval.newData_JuridicalStreet,
                        house: requestApproval.newData_JuridicalHomeID,
                        room: requestApproval.newData_JuridicalRoomID,
                    }
                    let body = {
                        Name: requestApproval.newData_CustomerFormattedName,
                        LifeCycleStatusCode: requestApproval.newData_StatusCode_code,
                        OwnerID : requestApproval.newData_ResponsibleManagerID,
                        CountryCode : requestApproval.newData_JuridicalCountry_code,
                        City : requestApproval.newData_JuridicalCity,
                        Street : requestApproval.newData_JuridicalStreet,
                        HouseNumber :requestApproval.newData_JuridicalHomeID,
                        Room : requestApproval.newData_JuridicalRoomID
                    }
                    //delete null properties from body
                    for(let property in body){
                        if (!body[property]){
                            delete body[property];
                        }
                    }
                    const mail = req.req.headers['x-username'];
                    const context = {
                        objectID : customer.ObjectID,
                        internalID : customer.InternalID,
                        createdAt : new Date().toDateString(),
                        createdBy: mail,
                        old : oldData,
                        new: newData,
                        responsibleContact : mail,
                        responsibleManager : 'antondurko01gmail.com',
                        body: body
                    }
                    const workflow = await cds.connect.to('workflowService');
                    const response = await workflow.send('POST', '/v1/workflow-instances', {"definitionId" : "approvalflow", context: context})
                    req.info("Request for approval has been sent!")
                    //const debug=1;
                }
            }
        });

        return super.init();
    }
}

module.exports = {RequestApprovalService};
const cds = require('@sap/cds')
const { sendRequestToC4C } = require('./libs/ManageAPICalls');

class RequestApprovalService extends cds.ApplicationService {
    init() {

        const { Customer, RequestApproval } = this.entities;

        this.before('CREATE', RequestApproval, async req => {
            //link new request record to current Contact
            const email = req._.user.id;
            const partner = await SELECT.one.from("PARTNER_PARTNERPROFILE").where({ Email: email });
            if (partner) {
                req.data.MainContactID = partner.CODE;
            }
        });

        this.before('READ', RequestApproval, async req => {
            // filter only for current Contact
            const path = req._path;
            const editing = path.includes('IsActiveEntity=false'); // fetch from remote only for reading page not editing
            if (req._path == 'RequestApproval' && !editing && req._.event == 'READ') {
                const email = req._.user.id;
                const partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: email });
                if (partner) {
                    req.query.where({ 'MainContactID': partner.CODE });
                }
            }
        });

        this.on('sendRequestForApproval', async (req) => {
            //form context body and trigger workflow for approval request
            const requestApprovalID = req.params[0].ID;
            const requestApproval = await SELECT.one.from(RequestApproval).columns(
                root => {
                    root('*'),
                    root.currentStatusCode(currentStatus => { currentStatus.code, currentStatus.name }),
                    root.newStatusCode(newStatus => { newStatus.code, newStatus.name })
                }).where({ ID: requestApprovalID });
            if (requestApproval) {
                const customer = await SELECT.one.from(Customer).where({ ID: requestApproval.CustomerID });
                if (customer) {
                    let oldCountryDescription;
                    let newCountryDescription;
                    let oldPOBoxCountryDescription;
                    let newPOBoxCountryDescription;
                    // get country descriptions
                    if (requestApproval.currentCountry_code) {
                        const oldCountryInst = await SELECT.one.from('SAP_COMMON_COUNTRIES').where({ code: requestApproval.currentCountry_code });
                        if (oldCountryInst) {
                            oldCountryDescription = oldCountryInst.NAME;
                        }
                    }
                    if (requestApproval.newCountry_code) {
                        const newCountryInst = await SELECT.one.from('SAP_COMMON_COUNTRIES').where({ code: requestApproval.newCountry_code });
                        if (newCountryInst) {
                            newCountryDescription = newCountryInst.NAME;
                        }
                    }
                    if (requestApproval.currentPOBoxCountry_code) {
                        const oldPOBoxCountryInst = await SELECT.one.from('SAP_COMMON_COUNTRIES').where({ code: requestApproval.currentPOBoxCountry_code });
                        if (oldPOBoxCountryInst) {
                            oldPOBoxCountryDescription = oldPOBoxCountryInst.NAME;
                        }
                    }
                    if (requestApproval.newPOBoxCountry_code) {
                        const newPOBoxCountryInst = await SELECT.one.from('SAP_COMMON_COUNTRIES').where({ code: requestApproval.newPOBoxCountry_code });
                        if (newPOBoxCountryInst) {
                            newPOBoxCountryDescription = newPOBoxCountryInst.NAME;
                        }
                    }
                    let oldStatusDescription;
                    let newStatusDescription;
                    // get status descriptions
                    if (requestApproval.currentStatusCode) {
                        oldStatusDescription = requestApproval.currentStatusCode.name;
                    }
                    if (requestApproval.newStatusCode) {
                        newStatusDescription = requestApproval.newStatusCode.name;
                    }
                    const oldData = {
                        name: requestApproval.currentData_CustomerFormattedName,
                        responsibleManager: requestApproval.currentData_ResponsibleManager,
                        status: oldStatusDescription,
                        note: requestApproval.currentData_Note,
                        country: oldCountryDescription,
                        city: requestApproval.currentData_JuridicalCity,
                        street: requestApproval.currentData_JuridicalStreet,
                        house: requestApproval.currentData_JuridicalHomeID,
                        room: requestApproval.currentData_JuridicalRoomID,
                        // Postal address
                        POBox: requestApproval.currentData_POBox,
                        POBoxCountry: oldPOBoxCountryDescription,
                        POBoxState: requestApproval.currentData_POBoxState,
                        POBoxCity: requestApproval.currentData_POBoxCity,
                    }
                    const newData = {
                        name: requestApproval.newData_CustomerFormattedName,
                        responsibleManager: requestApproval.newData_ResponsibleManager,
                        status: newStatusDescription,
                        note: requestApproval.newData_Note,
                        country: newCountryDescription,
                        city: requestApproval.newData_JuridicalCity,
                        street: requestApproval.newData_JuridicalStreet,
                        house: requestApproval.newData_JuridicalHomeID,
                        room: requestApproval.newData_JuridicalRoomID,
                        // Postal address
                        POBox: requestApproval.newData_POBox,
                        POBoxCountry: newPOBoxCountryDescription,
                        POBoxState: requestApproval.newData_POBoxState,
                        POBoxCity: requestApproval.newData_POBoxCity,
                    }
                    let body = {
                        Name: requestApproval.newData_CustomerFormattedName,
                        LifeCycleStatusCode: requestApproval.currentStatusCode.code,
                        OwnerID: requestApproval.newData_ResponsibleManagerID,
                        CountryCode: requestApproval.newData_JuridicalCountry_code,
                        City: requestApproval.newData_JuridicalCity,
                        Street: requestApproval.newData_JuridicalStreet,
                        HouseNumber: requestApproval.newData_JuridicalHomeID,
                        Room: requestApproval.newData_JuridicalRoomID,
                        // Postal address
                        POBox: requestApproval.newData_POBox,
                        POBoxCountry: newPOBoxCountryDescription,
                        POBoxState: requestApproval.newData_POBoxState,
                        POBoxCity: requestApproval.newData_POBoxCity,
                    }
                    //delete null properties from body
                    for (let property in body) {
                        if (!body[property]) {
                            delete body[property];
                        }
                    }
                    const mail = req._.user.id;
                    const contact = await SELECT.one.from('Partner_PartnerProfile').where({Email : mail});
                    const today =  new Date();
                    const context = {
                        objectID: customer.ObjectID,
                        requestID : requestApprovalID,
                        internalID: customer.InternalID,
                        createdAt: today.toLocaleDateString() + ' ' + today.toLocaleTimeString(),
                        createdBy: mail,
                        old: oldData,
                        new: newData,
                        responsibleContact: contact.FIRSTNAME + ' ' + contact.LASTNAME,
                        responsibleManager: customer.ResponsibleManagerEmail,//test
                        body: body
                    }
                    const workflow = await cds.connect.to('workflowService');
                    await workflow.send('POST', '/v1/workflow-instances', { "definitionId": "approvalflow", context: context })
                    req.info("Request for approval has been sent!")

                    // set status to "Sent to Approval"
                    await UPDATE(RequestApproval).set({ Status_code: "2"})
                    return SELECT(RequestApproval).where({ ID: requestApprovalID });
                }
            }
        });


        this.on('approve', async (req) => {
            const requestApprovalID = req.params[0].ID;

            // set status to "Approved"
            await UPDATE(RequestApproval).set({ Status_code: "3" });

            // update Customer in c4c
            const approvalRecord = await SELECT.one.from(RequestApproval).where({ ID: requestApprovalID });

            if (approvalRecord){
                var body = {
                    Name: approvalRecord.newData_CustomerFormattedName,
                    LifeCycleStatusCode: approvalRecord.newStatusCode_code,
                    OwnerID: approvalRecord.newData_ResponsibleManagerID,
                    CountryCode: approvalRecord.newCountry_code,
                    City: approvalRecord.newData_JuridicalCity,
                    Street: approvalRecord.newData_JuridicalStreet,
                    HouseNumber: approvalRecord.newData_JuridicalHomeID,
                    Room: approvalRecord.newData_JuridicalRoomID,
                    // Postal Address
                    POBox: approvalRecord.newData_POBox,
                    POBoxDeviatingCountryCode: approvalRecord.newData_POBoxCountry_code,
                    //POBoxState: approvalRecord.newData_POBoxState,// code ?
                    POBoxDeviatingCity: approvalRecord.newData_POBoxCity,
                }
                //delete null properties from body
                for (let property in body) {
                    if (!body[property]) {
                        delete body[property];
                    }
                }
                let path = `/sap/c4c/odata/v1/c4codataapi/CorporateAccountCollection('${approvalRecord.CustomerObjectID}')`;
        
                let createInC4CParameters = {
                    method: 'PATCH',
                    url: path,
                    data: body,
                    headers: { 'content-type': 'application/json' }
                };
        
               await sendRequestToC4C(createInC4CParameters);

                //update Note through text collection
                path = `/sap/c4c/odata/v1/c4codataapi/CorporateAccountCollection('${approvalRecord.CustomerObjectID}')/CorporateAccountTextCollection`;
                const noteBody = {
                    Text : 'approvalRecord.newData_Note12'
                }
                createInC4CParameters = {
                    method: 'POST',
                    url: path,
                    data: noteBody,
                    headers: { 'content-type': 'application/json' }
                };
               await sendRequestToC4C(createInC4CParameters);

                // update locally in db
                await UPDATE(Customer, approvalRecord.CustomerID).with({
                    CustomerFormattedName : body.Name,
                    Status_code : body.LifeCycleStatusCode,
                    JuridicalCountry_code : body.CountryCode,
                    JuridicalAddress_City : body.City,
                    JuridicalAddress_Street : body.Street,
                    JuridicalAddress_HomeID : body.HouseNumber,
                    JuridicalAddress_RoomID : body.Room,
                    Note : noteBody.Text,
                    // Postal Address
                    POBox: body.POBox,
                    POBoxCountry_code: body.POBoxDeviatingCountryCode,
                    POBoxState: body.POBoxState,
                    POBoxCity: body.POBoxDeviatingCity,
                })
            }
            return SELECT(RequestApproval).where({ ID: requestApprovalID });
        });
        
        this.on('rejectApproval', async (req) => {
            const requestApprovalID = req.params[0].ID;

            // set status to "Rejected"
            await UPDATE(RequestApproval).set({ Status_code: "4" })
            return SELECT(RequestApproval).where({ ID: requestApprovalID });
        });

        return super.init();
    }
}

module.exports = { RequestApprovalService };
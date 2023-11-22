const cds = require('@sap/cds')

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
            if (req._path == 'RequestApproval' && req._.event == 'READ') {
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
                    }
                    let body = {
                        Name: requestApproval.newData_CustomerFormattedName,
                        LifeCycleStatusCode: requestApproval.currentStatusCode.code,
                        OwnerID: requestApproval.newData_ResponsibleManagerID,
                        CountryCode: requestApproval.newData_JuridicalCountry_code,
                        City: requestApproval.newData_JuridicalCity,
                        Street: requestApproval.newData_JuridicalStreet,
                        HouseNumber: requestApproval.newData_JuridicalHomeID,
                        Room: requestApproval.newData_JuridicalRoomID
                    }
                    //delete null properties from body
                    for (let property in body) {
                        if (!body[property]) {
                            delete body[property];
                        }
                    }
                    const mail = req._.user.id;
                    const context = {
                        objectID: customer.ObjectID,
                        requestID : requestApprovalID,
                        internalID: customer.InternalID,
                        createdAt: new Date().toDateString(),
                        createdBy: mail,
                        old: oldData,
                        new: newData,
                        responsibleContact: mail,
                        responsibleManager: customer.ResponsibleManagerEmail,//test
                        body: body
                    }
                    const workflow = await cds.connect.to('workflowService');
                    const response = await workflow.send('POST', '/v1/workflow-instances', { "definitionId": "approvalflow", context: context })
                    req.info("Request for approval has been sent!")

                    // set status to "Sent to Approval"
                    await UPDATE(RequestApproval).set({ Status_code: "2" })
                    return SELECT(RequestApproval).where({ ID: requestApprovalID });
                }
            }
        });


        this.on('approve', async (req) => {
            const requestApprovalID = req.params[0].ID;

            // set status to "Approved"
            await UPDATE(RequestApproval).set({ Status_code: "3" })
            return SELECT(RequestApproval).where({ ID: requestApprovalID });
        });
        
        this.on('reject', async (req) => {
            const requestApprovalID = req.params[0].ID;

            // set status to "Rejected"
            await UPDATE(RequestApproval).set({ Status_code: "4" })
            return SELECT(RequestApproval).where({ ID: requestApprovalID });
        });

        return super.init();
    }
}

module.exports = { RequestApprovalService };
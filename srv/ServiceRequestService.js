const cds = require('@sap/cds')
const { getObjectsWithDifferentPropertyValue, createAttachmentBody } = require('./libs/utils');
const { sendRequestToC4C } = require('./libs/ManageAPICalls');

class ServiceRequestService extends cds.ApplicationService {
    async init() {

        const { Customer, ServiceRequest, Attachement } = this.entities;

        async function _createServiceRequestInstances(c4cResponse) {

        }

        this.before('READ', 'ServiceRequest', async req => {
            if (req._path == 'ServiceRequest' && req._.event == 'READ') { // read only for general list
                if (req.headers['x-username']){
                    const partner = await SELECT.one.from('Partner_PartnerProfile').where({Email: req.headers['x-username']});
                    if (partner){
                        req.query.where({ 'MainContactID': partner.CODE });
                    }
                }
            }
        });

        this.before('NEW', 'ServiceRequest', async req => {
            if (req.headers['x-username']){
                const partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: req.headers["x-username"] });
                if(partner){
                    req.data.MainContactID = partner.CODE;
                }
            }
        });

        this.on('updateFromRemote', async (req) => {
            const pathStart = "ServiceRequest(ID=";
            let serviceRequestID = req._path.substring(pathStart.length, pathStart.length + 36);

            const obj = await SELECT.one.from(ServiceRequest, serviceRequestID);

            let path = `/sap/c4c/odata/v1/c4codataapi/ServiceRequestCollection('${obj.ObjectID}')?$expand=ServiceRequestAttachmentFolder`;
            try {
                let createRequestParameters = {
                    method: 'GET',
                    url: path,
                    headers: { 'content-type': 'application/json' }
                }
                const c4cResponse = await sendRequestToC4C(createRequestParameters);
                const serviceRequestResponse = c4cResponse.data.d.results;

                const LastChangeDateTime = serviceRequestResponse.LastChangeDateTime;
                const timestamp = serviceRequestResponse.LastChangeDateTime.substring(LastChangeDateTime.indexOf('(') + 1, LastChangeDateTime.indexOf(')'));
                const date = new Date(Number(timestamp));
                const year = date.getFullYear();
                const month = String(date.getMonth() + 1).padStart(2, '0'); // Month is 0-indexed, so add 1 and pad with '0' if necessary
                const day = String(date.getDate()).padStart(2, '0'); // Pad day with '0' if necessary
                const formattedDate = `${year}-${month}-${day}`;

                const serviceRequest = {
                    CustomerID: serviceRequestResponse.BuyerPartyID,
                    Status_code: serviceRequestResponse.ServiceRequestLifeCycleStatusCode,
                    LastChangingDate: formattedDate,
                    Processor: serviceRequestResponse.ProcessorPartyName,
                    RequestProcessingTime: serviceRequestResponse.RequestInProcessdatetimeContent,
                    OrderID: serviceRequestResponse.SalesOrderID,
                    ProblemDescription: serviceRequestResponse.Name,
                    MainContactID: serviceRequestResponse.BuyerMainContactPartyID,
                }

                await UPDATE(ServiceRequest).with(serviceRequest).where({ ObjectID: serviceRequestResponse.ObjectID });

                if (serviceRequestResponse.ServiceRequestAttachmentFolder.length) {
                    serviceRequestResponse.ServiceRequestAttachmentFolder.forEach(async attachmentResponse => {
                        if (attachmentResponse) {
                            const str = attachmentResponse.Binary;
                            const content = Buffer.from(str, 'base64').toString();
                            const buffer = Buffer.from(content, 'utf-8');
                            const attachment = {
                                content: buffer,
                                fileName: attachmentResponse.Name,
                                url: attachmentResponse.DocumentLink,
                                mediaType: attachmentResponse.MimeType
                            }
                            const attachmentInDB = await SELECT.one.from(Attachement).where({ ObjectID: attachmentResponse.ObjectID });
                            if (attachmentInDB)
                                await UPDATE(Attachement, attachmentInDB.ID).with(attachment);
                            else {
                                attachment.ObjectID = attachmentResponse.ObjectID;
                                attachment.ServiceRequest_ID = serviceRequestID;
                                await INSERT.into(Attachement).entries(attachment);
                            }
                        }
                    });
                }
                // if no ObjectID is in remote attachments, need to delete
                const attachmentsInDB = await SELECT(Attachement).where({ ServiceRequest_ID: serviceRequestID });

                if (attachmentsInDB.length) {
                    const attachmentsToBeDeleted = getObjectsWithDifferentPropertyValue(attachmentsInDB,
                        serviceRequestResponse.ServiceRequestAttachmentFolder, "ObjectID", "ObjectID");
                    const attachmentObjectIDsToBeDeleted = attachmentsToBeDeleted.map(item => item.ObjectID);
                    if (attachmentObjectIDsToBeDeleted.length)
                        await DELETE.from(Attachement).where({ ObjectID: attachmentObjectIDsToBeDeleted });
                }
                return SELECT(ServiceRequest, serviceRequestID);
            }
            catch (error) {
                req.reject({
                    message: error.message
                });
            }
        });

        this.after('SAVE', 'ServiceRequest', async (req) => {
            // create new Service Request in remote
            const ticket = req;
            if (ticket.UUID === null) { // if UUID is null, then it was not yet saved
                let customer;
                const customerID = ticket.Customer_ID;
                let internalBuyerID = null;
                if (customerID) {
                    customer = await SELECT.from(Customer).where({ ID: customerID });
                    if (customer[0]) {
                        internalBuyerID = customer[0].InternalID;
                    }
                }

                let body = {
                    Name: ticket.ProblemDescription,
                    ServiceRequestUserLifeCycleStatusCode: ticket.Status_code,
                    //oppt - document reference?
                    //category - codes are not matches
                    //processor - ovs of Employees from Remote
                }
                if (internalBuyerID)
                    body.BuyerPartyID = internalBuyerID;
                let products = [];
                if (ticket.ProblemItem != null) {
                    const itemInstance = await SELECT.one.from(Item).where({ ID: ticket.ProblemItem });
                    products.push({ ProductID: itemInstance.ProductInternalID });
                    body.ServiceRequestItem = { results: products };
                }

                if (ticket.Attachment && ticket.Attachment.length !== 0) {
                    const results = [];
                    createAttachmentBody(ticket, results);
                    body.ServiceRequestAttachmentFolder = { results };
                }

                let createRequestParameters = {
                    method: 'POST',
                    url: `/sap/c4c/odata/v1/c4codataapi/ServiceRequestCollection`,
                    data: body,
                    headers: { 'content-type': 'application/json' }
                }
                const c4cResponse = await sendRequestToC4C(createRequestParameters);
                // Update UUID
                if (c4cResponse.status == '201' && c4cResponse.data.d.results != undefined) {
                    const data = c4cResponse.data.d.results;
                    const objectID = data.ObjectID;
                    const UUID = data.UUID;
                    if (objectID && UUID) {
                        await UPDATE(ServiceRequest, ticket.ID).with({
                            UUID: UUID,
                            ObjectID: objectID,
                            InternalID: data.ID,
                            Processor: data.ProcessorPartyName
                        });
                    }
                    if (ticket.Attachment && ticket.Attachment.length !== 0) {
                        createRequestParameters = {
                            method: 'GET',
                            url: data.ServiceRequestAttachmentFolder.__deferred.uri,
                            headers: { 'content-type': 'application/json' }
                        }
                        // save ObjectID for the first time
                        const attachmentResponse = await sendRequestToC4C(createRequestParameters);
                        const attachmentsInResponse = attachmentResponse.data.d.results;
                        for (let i = 0; i < attachmentsInResponse.length; i++) {
                            const attachmentInDB = ticket.Attachment[i];
                            const ObjectID = attachmentsInResponse[i].ObjectID;
                            await UPDATE(Attachement, attachmentInDB.ID).set({ ObjectID: ObjectID });
                        }

                    }
                }
            }
        })

        return super.init();
    }
}
module.exports = { ServiceRequestService };

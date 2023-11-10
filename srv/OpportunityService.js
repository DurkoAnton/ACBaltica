const cds = require('@sap/cds')
//const jwt_decode = require('jwt-decode');
//const { status } = require('express/lib/response');
const { createAttachmentBody, createItemsBody, deleteOpportunityInstances } = require('./libs/utils');
const { sendRequestToC4C } = require('./libs/ManageAPICalls');
const { loadProductsAndPricesListsFromC4C } = require('./libs/dataLoading');

class OpportunityService extends cds.ApplicationService {
    async init() {

        const { Customer } = cds.entities('customer')
        const { Opportunity, Attachement, Item, ItemProduct, SalesPriceList } = this.entities;

        async function _createOpportunityInstances(opportunities) {
            opportunities.forEach(async item => {
                let opportunity = {
                    UUID: item.UUID,
                    ObjectID: item.ObjectID,
                    InternalID: item.ID,
                    ProspectPartyID: item.ProspectPartyID,
                    ProspectPartyName: item.ProspectPartyName,
                    Subject: item.Name,
                    LifeCycleStatusCode_code: item.LifeCycleStatusCode,
                    LifeCycleStatusText: item.LifeCycleStatusText,
                    MainEmployeeResponsiblePartyID: item.MainEmployeeResponsiblePartyID,
                    MainEmployeeResponsiblePartyName: item.MainEmployeeResponsiblePartyName,
                    //CreationDateTime: item.CreationDateTime,
                    CreatedBy: item.CreatedBy,
                    //LastChangeDateTime: item.LastChangeDateTime,
                    LastChangedBy: item.LastChangedBy,
                    MainContactID: item.PrimaryContactPartyID,
                }
                const attachmentFolder = item.OpportunityAttachmentFolder[0];
                let attachment;
                if (attachmentFolder) {
                    let str = attachmentFolder.Binary;
                    let content = Buffer.from(str, 'base64').toString();
                    let buffer = Buffer.from(content, 'utf-8');
                    attachment = {
                        content: buffer,
                        fileName: attachmentFolder.Name,
                        url: attachmentFolder.DocumentLink,
                        mediaType: 'text/plain'
                    }
                }
                // link to Customer
                const customerInst = await SELECT.one.from(Customer).where({InternalID : item.ProspectPartyID});
                if (customerInst){
                    opportunity.Customer_ID = customerInst.ID;
                }
                const insertResult = await INSERT(opportunity).into(Opportunity);
                if (insertResult.affectedRows > 0) {
                    const opportunityID = insertResult.results[0].values[14];
                    if (attachment){
                        attachment.Opportunity_ID = opportunityID; // link attachment and SR values[14]-id
                        await INSERT(attachment).into(Attachement);
                    }
                    // add items
                    if (item.OpportunityItem.length > 0) {
                        const items = await createItemsBody(item.OpportunityItem, ItemProduct, opportunityID);
                        await INSERT(items).into(Item);
                    }
                }
            });
        }

        this.on('LoadProducts', async (req) => {
            await loadProductsAndPricesListsFromC4C(ItemProduct, SalesPriceList, req);
        })

        this.before('READ', 'Opportunity', async req => {
            if (req._path == 'Opportunity' && req._.event == 'READ' /*&& req._._queryOptions.$top == '30'*/) { // read only for general list
                //if (req.headers["x-username"]) {
                    var email = 'andrei_matys@atlantconsult.com';
                    var partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: email });
                    if (partner){
                        req.query.where({ 'MainContactID': partner.CODE });
                    }
                //}
                if (partner) {
                    const existingOpportunities = await SELECT.from(Opportunity).where({MainContactID : partner.CODE});
                    const path = `/sap/c4c/odata/v1/c4codataapi/OpportunityCollection?$filter=PrimaryContactPartyID eq '${partner.CODE}'&$expand=OpportunityAttachmentFolder,OpportunityItem`;
                    try {
                        const createRequestParameters = {
                            method: 'get',
                            url: path,
                            headers: {
                                'content-type': 'application/json'
                            }
                        }
                        const c4cResponse = await sendRequestToC4C(createRequestParameters);
                        const remoteOpportunitites = c4cResponse.data.d.results;
                        // exclude existing rows to create only new
                        const newOpptsToCreate = remoteOpportunitites.filter(newItem => !existingOpportunities.some(existingItem => existingItem.ObjectID == newItem.ObjectID));
                        await _createOpportunityInstances(newOpptsToCreate);
                        await deleteOpportunityInstances(c4cResponse, existingOpportunities, Opportunity);
                    }
                    catch (error) {
                        req.reject({
                            message: error.message
                        });
                    }
                }
            }
        });

        // this.before('NEW', 'Item', async (req) => {
        //     req.data.OpportunityID = req.data.toOpportunity_ID;
        // })

        this.before('NEW', 'Opportunity', async (req) => {
            req.data.LifeCycleStatusCode_code = '1';
            req.data.LifeCycleStatusText = 'Open';
            var email = 'andrei_matys@atlantconsult.com';
            //if (req.headers['x-username']){
                const partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: email });
                if(partner){
                    req.data.MainContactID = partner.CODE;
                }
           // }
        })

        this.after('SAVE', 'Opportunity', async req => {
            // create new Opportunities in remote
            const opportunity = req;
            if (opportunity.UUID === null) {
                let requestBody = {
                    Name: opportunity.Subject,
                    LifeCycleStatusCode: opportunity.LifeCycleStatusCode_code,
                }
                if (opportunity.ProspectPartyID)
                    requestBody.ProspectPartyID = opportunity.ProspectPartyID;
                // add products
                const products = [];
                const items = opportunity.Items;
                for (let itemRow of items) {
                    const itemProductID = itemRow.ItemProductID;
                    const itemProduct = await SELECT.one.from(ItemProduct).where({ ID: itemProductID });
                    if (itemProduct) {
                        products.push({ ProductID: itemProduct.InternalID })
                    }
                }
                if (products.length > 0) {
                    requestBody.OpportunityItem = { results: products };
                }

                if (opportunity.Attachment && opportunity.Attachment.length !== 0) {
                    const results = [];
                    createAttachmentBody(opportunity, results);
                    requestBody.OpportunityAttachmentFolder = { results };
                }

                try {
                    let createRequestParameters = {
                        method: 'POST',
                        url: `/sap/c4c/odata/v1/c4codataapi/OpportunityCollection`,
                        data: requestBody,
                        headers: {
                            'content-type': 'application/json'
                        }
                    }
                    const createdOppt = await sendRequestToC4C(createRequestParameters);
                    if (createdOppt && createdOppt.data && createdOppt.data.d && createdOppt.data.d.results) {
                        const createdData = createdOppt.data.d.results;
                        const result = await UPDATE(Opportunity)
                            .where({ ID: opportunity.ID })
                            .with({
                                UUID: createdData.UUID,
                                ObjectID: createdData.ObjectID,
                                MainEmployeeResponsiblePartyName: createdData.MainEmployeeResponsiblePartyName,
                                InternalID: createdData.ID
                            });

                        if (opportunity.Attachment && opportunity.Attachment.length !== 0) {
                            createRequestParameters = {
                                method: 'GET',
                                url: createdData.OpportunityAttachmentFolder.__deferred.uri,
                                headers: { 'content-type': 'application/json' }
                            }
                            // save ObjectID for the first time
                            const attachmentResponse = await sendRequestToC4C(createRequestParameters);
                            const attachmentsInResponse = attachmentResponse.data.d.results;
                            for (let i = 0; i < attachmentsInResponse.length; i++) {
                                const attachmentInDB = opportunity.Attachment[i];
                                const ObjectID = attachmentsInResponse[i].ObjectID;
                                await UPDATE(Attachement, attachmentInDB.ID).set({ ObjectID: ObjectID });
                            }
                        }
                    }
                } catch (e) {
                    console.log(e)
                }
            }
        });


        this.on('updateFromRemote', async (req) => {
            const pathStart = "Opportunity(ID=";
            let opportunityID = req._path.substring(pathStart.length, pathStart.length + 36);

            const obj = await SELECT.one.from(Opportunity, opportunityID);
            if (obj.ObjectID) {
            const path = `/sap/c4c/odata/v1/c4codataapi/OpportunityCollection('${obj.ObjectID}')?$expand=OpportunityAttachmentFolder`;
            try {
                let createRequestParameters = {
                    method: 'GET',
                    url: path,
                    headers: { 'content-type': 'application/json' }
                }
                const c4cResponse = await sendRequestToC4C(createRequestParameters);
                const opportunityResponse = c4cResponse.data.d.results;

                const LastChangeDateTime = opportunityResponse.LastChangeDateTime;
                const timestamp = opportunityResponse.LastChangeDateTime.substring(LastChangeDateTime.indexOf('(') + 1, LastChangeDateTime.indexOf(')'));
                const date = new Date(Number(timestamp));
                const year = date.getFullYear();
                const month = String(date.getMonth() + 1).padStart(2, '0'); // Month is 0-indexed, so add 1 and pad with '0' if necessary
                const day = String(date.getDate()).padStart(2, '0'); // Pad day with '0' if necessary
                const formattedDate = `${year}-${month}-${day}`;

                let opportunity = {
                    InternalID: opportunityResponse.ID,
                    ProspectPartyID: opportunityResponse.ProspectPartyID,
                    ProspectPartyName: opportunityResponse.ProspectPartyName,
                    Subject: opportunityResponse.Name,
                    LifeCycleStatusCode_code: opportunityResponse.LifeCycleStatusCode,
                    MainEmployeeResponsiblePartyID: opportunityResponse.MainEmployeeResponsiblePartyID,
                    MainEmployeeResponsiblePartyName: opportunityResponse.MainEmployeeResponsiblePartyName,
                    CreatedBy: opportunityResponse.CreatedBy,
                    LastChangeDateTime: formattedDate,
                    LastChangedBy: opportunityResponse.LastChangedBy,
                    MainContactID: opportunityResponse.PrimaryContactPartyID,
                }
                // link to new Customer if it was changed
                if (opportunityResponse.ProspectPartyID){
                    const customerInst = await SELECT.one.from(Customer).where({InternalID : opportunityResponse.ProspectPartyID});
                    if (customerInst){
                        opportunity.Customer_ID = customerInst.ID;
                    }
                }
                await UPDATE(Opportunity).with(opportunity).where({ ObjectID: opportunityResponse.ObjectID });

                if (opportunityResponse.OpportunityAttachmentFolder.length) {
                    opportunityResponse.OpportunityAttachmentFolder.forEach(async attachmentResponse => {
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
                                attachment.Opportunity_ID = opportunityID;
                                await INSERT.into(Attachement).entries(attachment);
                            }
                        }
                    });
                }
                // // if no ObjectID is in remote attachments, need to delete
                // const attachmentsInDB = await SELECT(Attachement).where({ Opportunity_ID: opportunityID });

                // if (attachmentsInDB.length) {
                //     const attachmentsToBeDeleted = getObjectsWithDifferentPropertyValue(attachmentsInDB,
                //         opportunityResponse.OpportunityAttachmentFolder, "ObjectID", "ObjectID");
                //     const attachmentObjectIDsToBeDeleted = attachmentsToBeDeleted.map(item => item.ObjectID);
                //     if (attachmentObjectIDsToBeDeleted.length)
                //         await DELETE.from(Attachement).where({ ObjectID: attachmentObjectIDsToBeDeleted });
                // }

                return SELECT(Opportunity, opportunityID);
            }
            catch (error) {
                req.reject({
                    message: error.message
                });
            }
        }
        });

        return super.init();
    }
}
module.exports = { OpportunityService };

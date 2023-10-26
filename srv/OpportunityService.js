const cds = require('@sap/cds')
//const jwt_decode = require('jwt-decode');
//const { status } = require('express/lib/response');
const { getObjectsWithDifferentPropertyValue, createAttachmentBody } = require('./libs/utils');
const { sendRequestToC4C } = require('./libs/ManageAPICalls');
const { loadProductsAndPricesListsFromC4C } = require('./libs/dataLoading');

class OpportunityService extends cds.ApplicationService {
    async init() {

        const { Customer } = cds.entities('customer')
        const { Opportunity, Attachement, ItemProduct, SalesPriceList } = this.entities;

        async function _createOpportunityInstances(c4cResponse) {
            const oppts = c4cResponse.data.d.results;
            oppts.forEach(async item => {
                let opportunity = {
                    UUID: item.UUID,
                    InternalID: item.ID,
                    ProspectPartyID: item.ProspectPartyID,
                    ProspectPartyName: item.ProspectPartyName,
                    Subject: item.Name,
                    LifeCycleStatusCode: item.LifeCycleStatusCode,
                    LifeCycleStatusText: item.LifeCycleStatusText,
                    MainEmployeeResponsiblePartyID: item.MainEmployeeResponsiblePartyID,
                    MainEmployeeResponsiblePartyName: item.MainEmployeeResponsiblePartyName,
                    CreationDateTime: item.CreationDateTime,
                    CreatedBy: item.CreatedBy,
                    LastChangeDateTime: item.LastChangeDateTime,
                    LastChangedBy: item.LastChangedBy,
                    MainContactID: item.PrimaryContactPartyID,
                }
                await INSERT(opportunity).into(Opportunity);
            });
        }

        // this.before('READ', 'Opportunity', async (req) => {
        //const opptunitiesFromDB = await SELECT.from(Opportunity);
        //await DELETE.from(Opportunity);
        //     if (opptunitiesFromDB.length == 0) {
        //       cds.env.features.fetch_csrf = true;

        //       const email = 'andrei_matys@atlantconsult.com';
        //       //const email = _getCurrentUserEmail();

        //       const path = `/sap/c4c/odata/v1/c4codataapi/OpportunityCollection?$filter=ProspectPartyID eq '1000171'`;

        //       try{
        //           const destination = await getDestination('C4C_DEMO_NEW_2');
        //           const c4cResponse = await _sendRequestToC4C(destination, 'GET', path);               
        //           await _createOpportunityInstances(c4cResponse);
        //           try{
        //               await tx.commit();
        //           } catch (error) {
        //               console.log(error.message);
        //           }    
        //       }
        //       catch(error){
        //           req.reject({
        //               message: error.message
        //           });
        //       }
        //   }
        // })

        this.on('LoadProducts', async (req) => {
            await loadProductsAndPricesListsFromC4C(ItemProduct, SalesPriceList, req);
        })

        this.before('READ', 'Opportunity', async req => {
            if (req._path == 'Opportunity' && req._.event == 'READ') { // read only for general list
                if (req.headers["x-username"]) {
                    const partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: req.headers["x-username"] });
                    if (partner){
                        req.query.where({ 'MainContactID': partner.CODE });
                    }
                }
            }
        });


        this.before('NEW', 'Opportunity', async (req) => {
            req.data.LifeCycleStatusCode_code = '1';
            req.data.LifeCycleStatusText = 'Open';
            if (req.headers['x-username']){
                const partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: req.headers["x-username"] });
                if(partner){
                    req.data.MainContactID = partner.CODE;
                }
            }
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
                        await UPDATE(Opportunity)
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
            let path = `/sap/c4c/odata/v1/c4codataapi/OpportunityCollection('${obj.ObjectID}')?$expand=OpportunityAttachmentFolder`;
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

                const opportunity = {
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

                await UPDATE(Opportunity).with(opportunity).where({ ObjectID: opportunityResponse.ObjectID });

                // if (opportunityResponse.OpportunityAttachmentFolder.length) {
                //     opportunityResponse.OpportunityAttachmentFolder.forEach(async attachmentResponse => {
                //         if (attachmentResponse) {
                //             const str = attachmentResponse.Binary;
                //             const content = Buffer.from(str, 'base64').toString();
                //             const buffer = Buffer.from(content, 'utf-8');
                //             const attachment = {
                //                 content: buffer,
                //                 fileName: attachmentResponse.Name,
                //                 url: attachmentResponse.DocumentLink,
                //                 mediaType: attachmentResponse.MimeType
                //             }
                //             const attachmentInDB = await SELECT.one.from(Attachement).where({ ObjectID: attachmentResponse.ObjectID });
                //             if (attachmentInDB)
                //                 await UPDATE(Attachement, attachmentInDB.ID).with(attachment);
                //             else {
                //                 attachment.ObjectID = attachmentResponse.ObjectID;
                //                 attachment.Opportunity_ID = opportunityID;
                //                 await INSERT.into(Attachement).entries(attachment);
                //             }
                //         }
                //     });
                // }
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

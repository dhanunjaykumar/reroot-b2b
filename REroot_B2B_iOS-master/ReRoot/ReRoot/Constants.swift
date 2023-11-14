//
//  Constants.swift
//  ReRoot
//
//  Created by Dhanunjay on 03/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import Foundation

struct STRINGS {
    static let Access_Forbidden = "You are not authorised for this action"
    static let Access_Forbidden_Contact_Admin = "You are not authorised for this action.\nContact your admin."
}

struct NOTIFICATIONS {
    static let SHOW_LEFT_MENU = "SHOW_LEFT_MENU"
    static let SHOWLOGINSCREEN = "SHOWLOGINSCREEN"
    static let FETCH_REGISTRATIONS = "FETCH_REGISTRATIONS"
    static let FETCH_RECEIPT_ENTRIES = "FETCH_RECEIPT_ENTRIES"
    static let POP_CONTROLLERS =  "POP_CONTROLLERS"
    static let FETCH_CALLS = "FETCH_CALLS"
    static let FETCH_OFFERS = "FETCH_OFFERS"
    static let FETCH_SITE_VISITS = "FETCH_SITE_VISITS"
    static let FETCH_DISCOUNT_REQUESTS = "FETCH_DISCOUNT_REQUESTS"
    static let FETCH_OTHER_TASKS = "FETCH_OTHER_TASKS"
    static let FETCH_NOT_INTERESTED = "FETCH_NOT_INTERESTED"
    static let FETCH_ON_ACTION = "FETCH_ON_ACTION"
    static let FETCH_UNIT_DETAILS = "FETCH_UNIT_DETAILS"
    static let UPDATE_PROSPECT_COUNT = "UPDATE_PROSPECT_COUNT"
    static let UNIT_RESERVED = "UNIT_RESERVED"
    static let UNIT_RESERVATIONS_REVOKED = "UNIT_RESERVATIONS_REVOKED"
    static let UPDATE_DISC_APPROVALS_COUNT = "UPDATE_DISC_APPROVALS_COUNT"
    static let UPDATE_HO_ITEM_STATE = "UPDATE_HO_ITEM_STATE"
    static let UPDATE_HO_CLOSE_COMPLAINT = "UPDATE_CLOSE_COMPLAINT"
    static let UPLOAD_HANDOVER_DATA = "UPLOAD_HANDOVER_DATA"
    static let PROSPECT_DATE_CHANGED = "PROSPECT_DATE_CHANGED"
    static let DELETE_NOTIFICATION = "DELETE_NOTIFICATION"
    static let HIDE_ALL = "HIDE_ALL"
}

struct RRAPI {
    
//    #if DEBUG  //192.168.1.4 : room  //172.16.20.236 : office
//        static var serverURL = "http://172.16.20.236:3000"  ///"http://52.66.34.235:3000" : Demo
//    #else
//         static var serverURL = "http://52.66.34.235:3000"
//    #endif
    
    static var serverURL : String {
        get{
            return UserDefaults.standard.value(forKey: "url") as? String ?? "http://192.168.1.2:3000"
        }
    }
    
    static var DEFAULT_HEADER = ["User-Agent" : "RErootMobile"]
    
    static let OTP_LENGTH : Int = 4
    
    static var DASHBOARD_URL : String{
        get {
            return serverURL + "/business/%@/reports?fp=1" //prestige
        }
    }
    static var LOGIN_URL : String {
        get {
            return serverURL + "/auth/login"
        }
    }
    static var LOGOUT_URL : String{
        get{
            return serverURL + "/api/users/logout/?isAndroid=1"
        }
    }
    static var CREATE_OTP_URL : String{
        get{
            return serverURL + "/auth/createotp"
        }
    }
    static var RESEND_OTP_URL : String{
        get {
            return serverURL + "/auth/resendotp"
        }
    }
    static var VERIFY_OTP_URL : String {
        get {
            return serverURL + "/auth/verifyotp"
        }
    }
    static var CHNAGE_PASSWORD_URL: String{
        get {
            return serverURL + "/auth/changepassword"
        }
    }
    
    // ** PROJECTS API's
    // MARK:- PROJECTS API's
    
    static var PROJECTS_URL : String{
        get{
            return serverURL + "/api/business/projects/?stats=1"
        }
    }
    static var PROJECT_DETAILS : String {
        get {
            return serverURL + "/api/business/allunits/info/project?project=%@"
        }
    }
    static var UNIT_STATUS_CHANGE : String {
        get {
            return serverURL + "/api/business/units/status"
        }
    }
    static var BOOK_UNIT : String{
        get {
            return serverURL + "/api/business/prospects/booking/app"
        }
    }
    static var BOOK_UNIT_EDIT : String{
        get {
            return serverURL + "/api/business/prospects/booking/app/edit"
        }
    }
    static var API_UPDATE_CUSTOMER : String{
        get{
            return serverURL + "/api/business/prospects/client/update"
        }
    }
    static var GET_SCHEMES : String{
        get{
            return serverURL + "/api/business/schemes"
        }
    }
    //const val API_UPDATE_CUSTOMER = "/api/business/prospects/client/update"
    // MARK:- PHASE II API's  //http://52.66.34.235:3000/api/business/prospectopportunities
    
//    const val API_GET_EMPLOYEES = "/api/business/employees"
//    const val API_GET_CUSTOMERS = "/api/business/customers"
//    const val API_GET_OLD_CUSTOMERS = "/api/business/commission/oldcustomers"

//    const val API_GET_PROSPECT_BY_ID = "/api/business/prospects/getProspectById"
    
    static var API_GET_APPROVAL_BY_ID : String{
        get{
            return serverURL + "/api/business/approvals/getApprovalById"
        }
    }

    static var API_GET_PROSPECT_BY_ID : String{
        get{
            return serverURL + "/api/business/prospects/getProspectById"
        }
    }
    static var API_EDIT_SV_COMPLETION_DATE : String{
        get{
            return serverURL + "/api/business/prospects/editCompletionTime"
        }
    }
    static var API_PROSPECT_CALL : String{
        get{
            return serverURL + "/api/business/prospects/callProspect"
        }
    }
    static var API_GET_GENERALS : String{
        get{
            return serverURL + "/api/business/generals"
        }
    }
    static var GET_COMMISSION_EMPLOYEES : String{
        get{
            return serverURL + "/api/business/employees"
        }
    }
    static var API_GET_CUSTOMERS : String{
        get{
            return serverURL + "/api/business/customers"
        }
    }
    static var API_GET_OLD_CUSTOMERS : String{
        get{
            return serverURL + "/api/business/commission/oldcustomers"
        }
    }    
    static var GET_COMMISSIONS : String{
        get{
            return serverURL + "/api/business/commission/configs"
        }
    }
    static var GET_VEHICLES : String{
        get{
            return serverURL + "/api/business/prospects/vehicles"
        }
    }
    static var GET_DRIVERS : String{
        get{
            return serverURL + "/api/business/prospects/drivers"
        }
    }
    static var PROSPECTS_TAB_COUNT_WITHOUT_DATE : String {
        get{
            return serverURL + "/api/business/prospects/count?tab=%@&expired=%@"
        }
    }
    static var PROSPECTS_TAB_COUNT : String {
        get{
            return serverURL + "/api/business/prospects/count?tab=%@&expired=%@&startDate=%@&endDate=%@"
        }
    }
    static var API_COMBINED_PROSPECTS : String{
        get{
            return serverURL + "/api/business/prospects?all=1&status=%d&startDate=%@&endDate=%@" //business/prospects?all=
        }
    }
    static var API_PROSPECT_COUNT : String{
        get{
            return serverURL + "/api/business/prospects/overall?startDate=%@&endDate=%@"
        }
    }
    static var GET_EMPLOYEES : String {
        get{
            return serverURL + "/api/business/employees/active"
        }
    }
    static var GET_AVTIVE_EMPLOYEES : String{
        get{
            return serverURL + "/api/business/employees/activelist"
        }
    }
    static var TOWERS : String{
        get{
            return serverURL + "/api/business/towers/"
        }
    }
    static var BLOCKS : String {
        get{
            return serverURL + "/api/business/blocks/"
        }
    }
    static var QUICK_REGISTRATION_SEARCH : String {
        get{
            return serverURL + "/api/business/qregistration/search?key="
        }
    }
    static var QUICK_REIGSTRATION : String {
        get{
            return serverURL + "/api/business/qregistration"
        }
    }
    static var EDIT_REGISTRATION : String {
        get{
            return serverURL + "/api/business/qregistration/edit"
        }
    }
    static var GET_QR_PROSPECT_DATA : String {
        get {
            return serverURL + "/api/business/qregistration?tab="
            //http://52.66.34.235:3000/api/business/qregistration?tab=1&id=5a51d63b9368c567787f7cbc
            //http://52.66.34.235:3000/api/business/qregistration?tab=1&id=5a51e1b49368c567787f7cc9
            
            //http://52.66.34.235:3000/api/business/prospectleads?tab=1&id=5a64a02cc145c62d977954f0&status=4
        }
    }
    //http://52.66.34.235:3000/api/business/prospectleads?tab=1&id=null&status=6
    static var GET_PROSPECTS_AS_PER_PROJECT : String{
        get{
            return serverURL + "/api/business/prospectleads?tab=%d&id=%@"
        }
    }
    static var GET_LEADS_PROSPECTS_AS_PER_ORDER : String {
        get{
            return serverURL + "/api/business/prospectleads?tab=%d&id=%@&status=%d&startDate=%@&endDate=%@"
        }
    }
    static var GET_OPPORTUNITIES_PROSPECTS_AS_PER_ORDER : String {
        get{
            return serverURL + "/api/business/prospectopportunities?tab=%d&id=%@&status=%d&startDate=%@&endDate=%@"
        }
    }
    static var CHANGE_PROSPECT_STATE : String {
        get{
            return serverURL + "/api/business/prospectleads"
        }
    }
    static var CHANGE_OPPORTUNITY_PROSPECT_STATE : String {
        get{
            return serverURL + "/api/business/prospectopportunities"
        }
    }
    static var API_SOURCE_STATUS_DATA : String{
        get{
            return serverURL +  "/api/business/pssourcesandstatuses"
        }
    }
    static var API_ENQUIRY_SOURCES : String{
        get{
            return serverURL + "/api/business/enquirySources?qr=1"
        }
    }
    static var API_OFFERS_PROSPECT_CHANGE : String{
        get{
            return serverURL + "/api/business/prospects/sendoffer?view=%d"  ///View = 2
        }
    }
    static var API_GET_UNIT_PRICE : String{
        get{
            return serverURL + "/api/business/prospects/unitprice?unit=%@"
        }
    }
    static var API_APPLY_DISCOUNT : String{
        get{
            return serverURL + "/api/business/prospects/applyDiscount?tower=%@"
        }
    }
    static var API_UPDATE_TASK : String{
        get{
            return serverURL + "/api/business/prospectleads/othertask/update"
        }
    }
    static var API_UPDATE_TASK_OPPORTUNITY : String{
        get{
            return serverURL + "/api/business/prospectopportunities/othertask/update"
        }
    }
    static var API_UPDATE_PASSWORD : String{
        get{
            return serverURL + "/auth/updatepassword"
        }
    }
    static var API_GET_QR_HISTORY : String{
        get{
            return serverURL + "/api/business/prospects/history?qRId=%@&userPhone=%@"
        }
    }
    static var API_GET_PROSPECTS : String{
        get{
            return serverURL + "/api/business/prospects/customers?leads=1&opportunities=1"
        }
    }
    static var API_GET_RESERVATIONS_OF_UNIT : String{
        get{
            return serverURL + "/api/business/crm/reservedUnits?unit=%@"
        }
    }
    static var API_RESERVE_UNIT : String{
        get{
            return serverURL + "/api/business/crm/reserveUnits"
        }
    }
    static var API_UNIT_BOOKING_INFO : String{
        get{
            return serverURL + "/api/business/prospects/booking/info?bookingform=%@"
        }
    }
    static var API_REVOKE_RESERVATION : String{
        get{
            return serverURL + "/api/business/crm/revokeReservation"
        }
    }
    static var API_REVOKE_ALL_RESERVATIONS : String{
        get{
            return serverURL + "/api/business/crm/revokeAllReservations"
        }
    }
    static var API_GET_OUTSTANDINGS : String{
        get{
            return serverURL + "/api/business/customer/outstandings?project=%@"
        }
    }
    static var API_OUTSTANDING_FOLLOWUP_TIMELINE : String{
        get{
            return serverURL + "/api/business/customer/outstandings/followedup/timeline?unit=%@&customer=%@"
        }
    }
    static var API_OUTSTANDING_FOLLOWUP : String{
        get{
            return serverURL + "/api/business/customer/outstandings/followedup"
        }
    }
    static var ADD_FCM_ID : String{
        get{
            return serverURL + "/api/users/addFCMId"
        }
    }
    static var REMOVE_FCM_ID : String{
        get{
            return serverURL + "/api/users/removeFCMId"
        }
    }
    static var API_GET_TRACKER_DETAILS : String{
        get{
            return serverURL + "/api/business/agreementstatustracker?unit=%@&type=%d"
        }
    }
    static var API_UPDATE_TRACKER_DETAILS : String{
        get{
            return serverURL + "/api/business/agreementstatustracker"
        }
    }
    static var API_GET_DEFAULT_BOOKING_SETUP : String{
        get{
            return serverURL + "/api/business/prospects/bookingdefaultsetup"
        }
    }
    static var API_GET_CUSTOM_BOOKING_SETUP : String {
        get{
            return serverURL + "/api/business/prospects/bookingsetupdetails"
        }
    }
    static var API_BLOCK_RELEASE_UNIT : String{
        get{
            return serverURL + "/api/business/units/edit"
        }
    }
    static var API_EDIT_REGISTRATION_BASICS : String{
        get{
            return serverURL + "/api/business/prospects/editBasics"
        }
    }
    static var API_ASSIGN_SALES_PERSON : String{
        get{
            return serverURL + "/api/business/prospects/assignSalesPerson"
        }
    }
    static var API_PROSPECT_BOOK_UNIT_CHECK : String{
        get{
            return serverURL + "/api/business/prospects/booking/check"
        }
    }
    static var API_VIEW_OFFER : String{
        get{
            return serverURL + "/api/business/prospects/viewOffer?viewType=%d&_id=%@&isApp=true"
        }
    }
    static var API_PREVIEW_PRICE : String{
        get{
            return serverURL + "/api/business/prospects/booking/previewPrice?unit=%@&reginfo=%@&scheme=%@"
        }
    }
    // MARK: - RECEIPT ENTRY BEGIN
//    const val API_CONVERT_CURRENCY = "https://free.currencyconverterapi.com/api/v6/convert?apiKey=ac51819cc91594522ad6&q="
    
    //                           https://free.currencyconverterapi.com/api/v6/convert?q=INR_USD&compact=y&apiKey=ac51819cc91594522ad6

    static var API_CONVERT_CURRENCY : String{
        get{
            return "https://free.currencyconverterapi.com/api/v6/convert?q=%@&compact=y&apiKey=ac51819cc91594522ad6"
        }
    }
    static var API_GET_BOOKED_CLIENTS : String{
        get{
            return serverURL + "/api/business/prospects/booking/unitClients?unit=%@"
        }
    }
    static var API_GET_UNIT_TRANSACTIONS : String{
        get{
            return serverURL + "/api/business/unit/transactions?unit=%@"
        }
    }
    static var API_SEARCH_IFSC : String{
        get{
            return "https://ifsc.razorpay.com/%@"
        }
    }
    static var API_GET_PROJECT_BANK : String{
        get{
            return serverURL + "/api/business/bankaccounts?project=%@"
        }
    }
    static var API_GET_RECEIPT_ENTRIES : String{
        get{
            return serverURL + "/api/business/receiptentries?tab=%d&_id=%@"
        }
    }
    static var API_GET_RECEIPT_COUNT : String{
        get{
            return serverURL + "/api/business/receiptentries/count?tab=%d&start=2018-09-01T00:00:00.000Z&end=%@"
        }
    }
    static var API_VIEW_RECEIPT : String{
        get{
            return serverURL + "/api/business/viewreceipt?id=%@"
        }
    }
    static var API_ADD_RECEIPT_ENTRY : String{
        get{
            return serverURL + "/api/business/receiptentry/add"
        }
    }
    static var API_EDIT_RECEIPT_ENTRY : String{
        get{
            return serverURL + "/api/business/receiptentry/edit"
        }
    }
    static var API_DELETE_RECEIPT_ENTRY : String{
        get{
            return serverURL + "/api/business/receiptentry/delete?_id=%@"
        }
    }
//    const val API_GET_TRACKER_DETAILS = "/api/business/agreementstatustracker?unit="
//    const val API_UPDATE_TRACKER_DETAILS = "/api/business/agreementstatustracker"
    // MARK: - RECEIPT ENTRY END
    
    
    // MARK:-  NOTIFICATIONS BEGIN
    
    static var API_NOTIFICATIONS : String{
        get{
            return serverURL + "/api/business/notification?isApp=1"
        }
    }
    static var API_MARK_NOTIFICATION_AS_READ : String{
        get{
            return serverURL + "/api/business/notification/read"
        }
    }
    static var API_CLEAR_ALL_NOTIFICATIONS : String{
        get{
            return serverURL + "/api/business/notification/read?isApp=1&clearall=1"
        }
    }
    // MARK:-  NOTIFICATIONS END
    
    // MARK:-  USER PERMISSIONS
    static var API_GET_PERMISSIONS : String{
        get{
            return serverURL + "/api/business/permInfo"
        }
    }
    
    //MARK :- APPROVALS BEGIN
    static var API_GET_INCOMING_DISCOUNT_APPROVALS : String{
        get {
            return serverURL + "/api/business/approvals?t=incoming"
        }
    }
    static var API_GET_OUTGOING_DISCOUNT_APPROVALS : String{
        get {
            return serverURL + "/api/business/approvals?t=outgoing"
        }
    }
    static var API_APPROVE_INCOMING_APPROVAL : String{
        get{
            return serverURL + "/api/business/approvals/approve"
        }
    }
    static var API_REJECT_INCOMING_APPROVAL : String{
        get{
            return serverURL + "/api/business/approvals/reject"
        }
    }
    static var API_GET_DISCOUNT_APPROVALS : String{
        get{
            return serverURL + "/api/business/approvals?t=incoming"
        }
    }
    static var API_BOOKING_FORM_APPROVAL_PDF_VIEW : String{
        get{
            return serverURL + "/api/business/prospects/booking/view?id=%@"
        }
    }
    //MARK :- APPROVALS END
    
    //MARK :- UNIT HANDOVER BEGIN
    static var API_GET_AWS_S3CONFIG : String{
        get{
            return serverURL + "/api/business/general/s3ConfigApp"
        }
    }
    static var API_GET_SOLD_UNITS : String{
        get{
            return serverURL + "/api/business/handover/getsoldunitsForCompanyGroup"
        }
    }
    static var API_GET_TOWER_HANDOVER_ITEMS : String{
        get{
            return serverURL + "/api/business/handover/thitemsForCompany?company=%@"
        }
    }
    static var API_GET_UNIT_HANDOVER_ITEMS : String{
        get{
            return serverURL + "/api/business/handover/uhitems?company=%@"
        }
    }
    static var API_POST_UPDATE_UNIT_HANDOVER_ITEMS : String{
        get{
            return serverURL + "/api/business/handover/updateuhitems"
        }
    }
    static var API_POST_UPDATE_HANDOVER_UNIT_STATUS : String{
        get{
            return serverURL + "/api/business/handover/updateuhitemsStatus"
        }
    }
    static var API_GET_UNIT_HANDOVER_ITEMS_FOR_UNIT : String{
        get{
            return serverURL + "/api/business/handover/uhitemsForUnit?unit=%@"
        }
    }
    static var API_POST_UPDATE_HANDOVER_ITEM_COMPLAINT : String{
        get{
            return serverURL + "/api/business/handover/updateuhitemsComplaintData"
        }
    }
    //MARK :- UNIT HANDOVER END
    
    /*
 
     //Handover apis
     const val API_GET_SOLD_UNITS = "/api/business/handover/getsoldunitsForCompanyGroup"
     const val API_GET_TOWER_HANDOVER_ITEMS = "/api/business/handover/thitemsForCompany?company="
     const val API_GET_UNIT_HANDOVER_ITEMS = "/api/business/handover/uhitems?company="
     const val API_POST_UPDATE_UNIT_HANDOVER_ITEMS = "/api/business/handover/updateuhitems"
     const val API_POST_UPDATE_HANDOVER_UNIT_STATUS = "/api/business/handover/updateuhitemsStatus"
     
     const val API_GET_UNIT_HANDOVER_ITEMS_FOR_UNIT = "/api/business/handover/uhitemsForUnit?unit="
     const val API_POST_UPDATE_HANDOVER_ITEM_COMPLAINT = "/api/business/handover/updateuhitemsComplaintData"
     const val API_GET_S3CONFIG = "/api/business/general/s3ConfigApp"

     */
    
    
    
//    const val API_MARK_NOTIFICATION_AS_READ = "/api/business/notification/read"
//    const val API_CLEAR_ALL_NOTIFICATIONS = "/api/business/notification/read?isApp=1&clearall=1&userid="

    //MARK :- NOTIFICaTIONS END
    
//    const val API_PREVIEW_PRICE = "/api/business/prospects/booking/previewPrice?unit="

    ///api/business/prospects/viewOffer?viewType=2&_id=5c665ec114f61307aac8c89f
    //    const val API_VIEW_OFFER = "/api/business/prospects/viewOffer?viewType="

//    const val API_PROSPECT_BOOK_UNIT_CHECK = "/api/business/prospects/booking/check"

//    const val API_GET_DEFAULT_BOOKING_SETUP = "/api/business/prospects/bookingdefaultsetup"
//    const val API_GET_CUSTOM_BOOKING_SETUP = "/api/business/prospects/bookingsetupdetails"
    
//    const val API_GET_TRACKER_DETAILS = "/api/business/agreementstatustracker?unit="
    
    //const val API_REVOKE_RESERVATION = "/api/business/crm/revokeReservation"
//    const val API_REVOKE_ALL_RESERVATIONS = "/api/business/crm/revokeAllReservations"
    
    //const val API_RESERVE_UNIT = "/api/business/crm/reserveUnits"
    
//    const val API_GET_UNIT_PRICE = "/api/business/prospects/unitprice?unit="
    
    //http://52.66.34.235:3000/api/business/prospectleads
    /*
     
     action    {…}
     id    2
     label    1 BHK not available
     actionInfo    {…}
     comment    testing DK
     project    5a0e7b7fff6f9c7166800f8f
     regInfo    5bacce5ab54f5b2fb7610616
     registrationDate    2018-09-22T16:43:47.542Z
     registrationStatus    2
     */
    
    
    //const val
    
    //http://52.66.34.235:3000/api/business/prospectleads  // POST
    
    /*
 
     const val API_QUICK_REGISTRATION = "/api/business/qregistration"              : Done ?
     const val API_EDIT_REGISTRATION = "/api/business/qregistration/edit"          : not using
     
     const val API_GET_QR_PROSPECT_DATA = "/api/business/qregistration?tab="       : DOne
     
     const val API_GET_LEADS_PROSPECT_DATA = "/api/business/prospectleads?tab="    : DOne
     
     const val API_GET_OPPORTUNITIES_PROSPECT_DATA = "/api/business/prospectopportunities?tab=" : not done
     
     const val API_LEADS_PROSPECT_STATUS_CHANGE = "/api/business/prospectleads"  :
     
     const val API_OPPORTUNITIES_PROSPECT_STATUS_CHANGE = "/api/business/prospectopportunities"    :
     
     const val API_QUICK_REGISTRATION_SEARCH = "/api/business/qregistration/search?key="  : Done
     
     const val API_SEND_OFFER = "/api/business/prospects/sendoffer?view=" :
     
     const val API_GET_DRIVERS = "/api/business/prospects/drivers"  : DONE
     const val API_GET_VEHICLES = "/api/business/prospects/vehicles"  : DONE
     
     const val API_UPDATE_TASK = "/api/business/prospectleads/othertask/update" :
     const val API_GET_EMPLOYEES = "/api/business/employees"  :
     const val API_GET_UNIT_PRICE = "/api/business/prospects/unitprice?unit=" :
     
     const val API_APPLY_DISCOUNT = "/api/business/prospects/applyDiscount"  :
     
     const val API_PROSPECT_BOOK_UNIT = "/api/business/prospects/booking/prospect" :

     action    {…}  // prspect leads api
     id    1
     label    Schedule Call
     actionInfo    {…}
     date    2018-10-03T03:00:00.000Z
     prevLeadStatus    {…}
     actionType    1
     id    5bab4f52b54f5b2fb7610614
     status    {…}
     id    1
     label    No Response
     project    5a51d63b9368c567787f7cbc
     regInfo    5ba4e936d2c00c2974c7a9ac
     registrationDate    2018-09-21T12:51:02.433Z
     registrationStatus    1
     
     */
}



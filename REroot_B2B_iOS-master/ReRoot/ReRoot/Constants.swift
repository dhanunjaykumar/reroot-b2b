//
//  Constants.swift
//  ReRoot
//
//  Created by Dhanunjay on 03/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import Foundation

struct NOTIFICATIONS {
    static let SHOWLOGINSCREEN = "SHOWLOGINSCREEN"
    static let FETCH_REGISTRATIONS = "FETCH_REGISTRATIONS"
    static let POP_CONTROLLERS =  "POP_CONTROLLERS"
    static let FETCH_CALLS = "FETCH_CALLS"
    static let FETCH_OFFERS = "FETCH_OFFERS"
    static let FETCH_SITE_VISITS = "FETCH_SITE_VISITS"
    static let FETCH_DISCOUNT_REQUESTS = "FETCH_DISCOUNT_REQUESTS"
    static let FETCH_OTHER_TASKS = "FETCH_OTHER_TASKS"
    static let FETCH_NOT_INTERESTED = "FETCH_NOT_INTERESTED"
    static let FETCH_ON_ACTION = "FETCH_ON_ACTION"
    
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
    
    static var LOGIN_URL : String {
        get {
            return serverURL + "/auth/login/"
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
            return serverURL + "/api/business/allunits/project?project=%@"
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
    
    // MARK:- PHASE II API's
    
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
    static var SOURCE_STATUS_DATA : String{
        get{
            return serverURL + "/api/business/pssourcesandstatuses"
        }
    }
    static var PROSPECTS_TAB_COUNT : String {
        get{
            return serverURL + "/api/business/prospects/count?tab="
        }
    }
    static var GET_EMPLOYEES : String {
        get{
            return serverURL + "/api/business/employees"
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
    static var GET_LEADS_PROSPECTS_AS_PER_ORDER : String {
        get{
            return serverURL + "/api/business/prospectleads?tab=%d&id=%@&status=%d"
        }
    }
    static var GET_OPPORTUNITIES_PROSPECTS_AS_PER_ORDER : String {
        get{
            return serverURL + "/api/business/prospectopportunities?tab=%d&id=%@&status=%d"
        }
    }
    static var CHANGE_PROSPECT_STATE : String {
        get{
            return serverURL + "/api/business/prospectleads"
        }
    }
    static var API_SOURCE_STATUS_DATA : String{
        get{
            return serverURL +  "/api/business/pssourcesandstatuses"
        }
    }
    static var API_OFFERS_PROSPECT_CHANGE : String{
        get{
            return serverURL + "/api/business/prospects/sendoffer?view=%@"  ///View = 2
        }
    }
    static var API_GET_UNIT_PRICE : String{
        get{
            return serverURL + "/api/business/prospects/unitprice?unit=%@"
        }
    }
    static var API_APPLY_DISCOUNT : String{
        get{
            return serverURL + "/api/business/prospects/applyDiscount"
        }
    }
    static var API_UPDATE_TASK : String{
        get{
            return serverURL + "/api/business/prospectleads/othertask/update"
        }
    }
    static var API_UPDATE_PASSWORD : String{
        get{
            return serverURL + "/auth/updatepassword"
        }
    }
    static var API_GET_QR_HISTORY : String{
        get{
            return serverURL + "/api/business/prospects/history?qRId=%@"
        }
    }
    
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



//
//  JsonModels.swift
//  ReRoot
//
//  Created by Dhanunjay on 26/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

struct QR_HISTORY_OUTPUT : Codable {
    let status : Int?
    let data : [QR_HISTORY]?
}
struct QR_HISTORY : Codable {
    let quickregistrations : [REGISTRATIONS_RESULT]?
    let leads : [REGISTRATIONS_RESULT]?
    let opportunities : [REGISTRATIONS_RESULT]?
}

struct COMMON_OUTPUT : Codable {
    let status : Int?
    let err : String?
}

struct UNIT_PRICE_API_RESULT : Codable {
    let status : Int?
    let result : UNIT_PRICE_DETAILS?
    let err : String?
}

struct UNIT_PRICE_DETAILS : Codable {
    let billingInfo : [BILLING_INFO]?
    let premiumBillingInfo : [PREMIUM_BILLING_INFO]?
}
struct BILLING_INFO : Codable {
    let _id : String?
    let type : String?
    let name : String?
    let agreeValItem  : Int?
    let rate : Int?
    let cost : Int?
    let qty : Int?
    var selectedDiscountAmt : Double?
    var selectedDiscountPercentage : Double?
}
struct PREMIUM_BILLING_INFO : Codable{
    let _id : String?
    let name : String?
    let agreeValItem : Int?
    let billings : [BILLING_INFO]?
}

struct API_SOURCE_RESULT : Codable {
    let status : Int?
    let ss : [STATUS_SOURCES]?
}
struct STATUS_SOURCES : Codable{
    let _id : String?
    let sType : Int?
    let label : String?
    let updateBy : [UPDATEDBY]?
    let predefined : [PREDIFINED]?
}
struct PREDIFINED : Codable {
    let id : Int?
    let name : String?
    let _id : String?
//    let sub :
}

struct DRIVER_RESULT : Codable {
    let status : Int?
    let drivers : [DRIVER]?
}
struct DRIVER : Codable {
    let _id : String?
    let name : String?
    let phone : String?
    let status : Int?
    let updateBy : [UPDATEDBY]?
    let company_group : String?
    let vehicle : VEHICLE?
    
}

struct VEHICLE_RESULT : Codable {
    let status : Int?
    let vehicles : [VEHICLE]?
}
struct VEHICLE :Codable {
    let _id : String?
    let plateNo : String?
    let vehicleType : String?
    let project : PROJECT?
    let company_group : String?
    let status : Int?
    let updateBy : [UPDATEDBY]?
}

struct PROSPECT_SUBMIT_RESULT : Codable {
    let err : PROSPECT_ERROR?
    let status : Int?
}
struct PROSPECT_ERROR : Codable {
    let action : String?
    let actionInfo : String?
    let regInfo : String?
    let registrationDate : String?
    let registrationStatus : String?
}

struct REGISTRATIONS : Codable {
    let status : Int?
    let result : [REGISTRATIONS_RESULT]?
    let err : String?
}
struct REGISTRATIONS_RESULT : Codable {
    
    let _id : String?
    let __v : Int?
    let userName : String?
    let userPhone : String?
    let userEmail : String?
    let enquirySource : String?
    let company_group : String?
    let uniqueId : String?
    let status : Int?
    let registrationDate : String?
    let comment : String?
    let project : PROJECT?
    let salesPerson : SALES_PERSON?
    let updatedBy : UPDATEDBY?
    let discountApplied : Int?
    let action : ACTION?
    let actionInfo :  ACTION_INFO?
    let regInfo : String?
    let viewType : Int?
    /*
 {"status":1,"result":[{"_id":"5b1932aeb157c54c0e8ce652","status":4,"regInfo":"5b193280b157c54c0e8ce64e","userName":"Vinayak","userPhone":"9743100800","action":{"label":"Request for Discount","id":4},"project":{"_id":"5a64a02cc145c62d977954f0","name":"BJS Mahadevapura"},"discountApplied":0,"registrationDate":"2018-06-07T13:26:24.806Z","salesPerson":{"_id":"59f75afad78bc1486318bfea","email":"admin@prestige.com"},"enquirySource":"Facebook( Social Media )","actionInfo":{"projects":[{"_id":"5a64a02cc145c62d977954f0","name":"BJS Mahadevapura"}],"taskStatus":0,"units":[{"_id":"5a79e0dc7d05380e815df613","description":"11"}]}}]}
 */
    
}
struct ACTION_INFO : Codable {
    let projects : [PROJECT]?
    let taskStatus : Int?
    let units : [UNITS]?
}
struct UNITS : Codable {
    let _id : String?
    let description : String?
    let tower : String?
    let block : String?
}
struct ACTION : Codable {
    let id : Int?
    let label : String?
}
struct PROJECT : Codable {
    let _id : String?
    let name : String?
}
struct SALES_PERSON : Codable {
    let _id : String?
    let email : String?
    let userInfo : USER_INFO?
//    let name : String?
//    let phone : String?
    
}
struct USER_INFO : Codable {
    let _id : String?
    let name : String?
    let email : String?
    let phone : String?
}

struct Q_REGISTRATION_RESULT : Codable {
    let status : Int?
    let err : String?
}
struct SEARCH_RESULT : Codable {
    let result : USER_DETAILS?
    let status : Int?
    let err : String?
}
struct USER_DETAILS : Codable {
    let _id : String?
    let userEmail : String?
    let userName : String?
    let userPhone : String?
}
struct PROSPECTS : Codable {
    let status : Int?
    var result : PROSPECT_RESULT?
    let err : String?
}
struct PROSPECT_RESULT : Codable {
    let startDate : String?
    let endDate : String?
    var counts : [PROSPECT_DETAILS]?
}
struct PROSPECT_DETAILS : Codable {
    let _id : String?
    let name : String?
    let registrationCount : Int?
    let leads : PROSPECT_TYPES?
    let opportunities : PROSPECT_TYPES?
    var shouldOpen : Bool?
    var indexNumebr : Int?
}
struct PROSPECT_TYPES : Codable {
    let callCount : Int?
    let offerCount : Int?
    let siteVisitCount : Int?
    let discountRequestCount: Int?
    let otherCount : Int?
    let notInterestedCount : Int?
    
}
struct Area : Codable {
    
    let uom : String?
    let value : Int?
    
    var dictionary: [String: Any] {
        return ["uom": uom!,
                "value": value!,
        ]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
    enum CodingKeys: String, CodingKey {
        case uom  = "uom"
        case value  = "value"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        value = try values.decodeIfPresent(Int.self, forKey: .value)
        uom = try values.decodeIfPresent(String.self, forKey: .uom)
    }
}
struct UPDATEDBY : Codable{
    let _id : String?
    let date : String?
    let descp : String?
    let src : Int?
    let user : String?
    
    enum CodingKeys: String, CodingKey {
        case _id  = "_id"
        case date  = "date"
        case descp  = "descp"
        case src  = "src"
        case user  = "user"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        date = try values.decodeIfPresent(String.self, forKey: .date)
        descp = try values.decodeIfPresent(String.self, forKey: .descp)
        user = try values.decodeIfPresent(String.self, forKey: .user)
        src = try values.decodeIfPresent(Int.self, forKey: .src)
    }
}
struct STAT :Codable {
    
    let count : Int?
    let status : Int?
    
    enum CodingKeys: String, CodingKey {
        case count = "count"
        case status = "status"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        count = try values.decodeIfPresent(Int.self, forKey: .count)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
    }
}
struct SANACTIONS :Codable{
    let _id : String?
    let approver : String?
    let date : String?
    let files : [String]?
    let name : String?
    
    enum CodingKeys: String, CodingKey {
        
        case _id = "_id"
        case approver = "approver"
        case date = "date"
        case files = "files"
        case name = "name"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        approver = try values.decodeIfPresent(String.self, forKey: .approver)
        date = try values.decodeIfPresent(String.self, forKey: .date)
        files = try values.decodeIfPresent([String].self, forKey: .files)
        name = try values.decodeIfPresent(String.self, forKey: .name)
    }
    
}
struct ForgotPasswordResult : Codable{
    let err : String?
    let status : Int
    let msg : String?
}
struct projectsResult : Codable {
    let status : Int?
    let err : String?
    let projects : [ProjectInfo]?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case err = "err"
        case projects = "projects"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        err = try values.decodeIfPresent(String.self, forKey: .err)
        projects = try values.decodeIfPresent([ProjectInfo].self, forKey: .projects)
    }
    
}
struct ProjectInfo : Codable  {
    
    let FAR : Int?
    let _id : String?
    let __v: Int?
    let address : String?
    let builtUpArea : Area?
    let city : String?
    let company : String?
    let company_group : String?
    let images : [String]?
    let imagesTemp : [String]?
    let incharge : String?
    let landArea : Area?
    let name : String?
    let proj_code : String?
    let proj_type : String?
    let segment : String?
    let short_name : String?
    let state : String?
    let stats : [STAT]?
    let status : Int?
    let superBuiltUpArea : Area?
    let updateBy : [UPDATEDBY]?
    let sanctions : [SANACTIONS]?
    
    enum CodingKeys: String, CodingKey {
        
        case FAR = "FAR"
        case _id = "_id"
        case __v = "__v"
        case address = "address"
        case builtUpArea = "builtUpArea"
        case city = "city"
        case company = "company"
        case company_group = "company_group"
        case images = "images"
        case imagesTemp = "imagesTemp"
        case incharge = "incharge"
        case landArea = "landArea"
        case name = "name"
        case proj_code = "proj_code"
        case proj_type = "proj_type"
        case sanctions = "sanctions"
        case segment = "segment"
        case short_name = "short_name"
        case state = "state"
        case stats = "stats"
        case status = "status"
        case superBuiltUpArea = "superBuiltUpArea"
        case updateBy  = "updateBy"
        
    }
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        FAR = try values.decodeIfPresent(Int.self, forKey: .FAR)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        __v = try values.decodeIfPresent(Int.self, forKey: .__v)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        city = try values.decodeIfPresent(String.self, forKey: .city)
        company = try values.decodeIfPresent(String.self, forKey: .company)
        company_group = try values.decodeIfPresent(String.self, forKey: .company_group)
        images = try values.decodeIfPresent([String].self, forKey: .images)
        imagesTemp = try values.decodeIfPresent([String].self, forKey: .imagesTemp)
        incharge = try values.decodeIfPresent(String.self, forKey: .incharge)
        landArea = try values.decodeIfPresent(Area.self, forKey: .landArea)
        builtUpArea = try values.decodeIfPresent(Area.self, forKey: .builtUpArea)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        proj_code = try values.decodeIfPresent(String.self, forKey: .proj_code)
        proj_type = try values.decodeIfPresent(String.self, forKey: .proj_type)
        segment = try values.decodeIfPresent(String.self, forKey: .segment)
        short_name = try values.decodeIfPresent(String.self, forKey: .short_name)
        state = try values.decodeIfPresent(String.self, forKey: .state)
        stats = try values.decodeIfPresent([STAT].self, forKey: .stats)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        superBuiltUpArea = try values.decodeIfPresent(Area.self, forKey: .superBuiltUpArea)
        
        updateBy = try values.decodeIfPresent([UPDATEDBY].self, forKey: .updateBy)
        
        sanctions = try values.decodeIfPresent([SANACTIONS].self, forKey: .sanctions)
        
    }
}

struct ProjectDetails : Codable {
    
    let status : Int?
    let blocks : [BlockDetails]?
    let towers : [TOWERDETAILS]?
    let units : [UnitDetails]?
}
struct UnitDetails : Codable{
    let _id : String?
    let __v : Int?
    let floorPlan : [FLOOR_PLAN]?
    let project : String?
    let facing : String?
    var clientId : String?
    let tower : String?
    let block : String?
    let description : String?
    let company_group : String?
    var status : Int?
    let rate : Double?
    let agreeValItemRate : Double?
    let salevalue : Double?
    let gst : Double?
    let totalCost : Double?
    let floor : Floor?
    let unitNo : Floor?
    let otherPremiums : [Premium]?
    let updatedBy : [UPDATEDBY]?
    let floorPremium : Premium?
    let type : Type?
    let blockingReason: String?
    let bookingform: Bookingform?
}
struct FLOOR_PLAN : Codable{
    let url : String?
    let _id : String?
}
//enum BlockingReason: Codable {
//    case empty : String?
//    case managementStocks : String?
//}
struct UnitUpdateBy: Codable {
    let user: String?
    let descp, date: String?
    let src: Int?
    let id: String?
}
struct ClientList : Codable {
    let _id : String?
    let customer : String?
    let client : Client
}
struct Client : Codable {
    let _id : String?
    let name : String?
    let phone : String?
    let email : String?
    
}

struct Bookingform: Codable {
    let _id: String?
    let company_group: String?
    let bookingDate: String
    let project: String?
    let block: String?
    let tower: String?
    let unit: String?
    let prospect: String?
    let __v: Int?
    let updateBy: [UnitUpdateBy]
//    let actions: [JSONAny]
    let status: Int
    let clients: [ClientList]
    let comments, bookingLocalID: String?
    let terms: String?
    
//    enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case companyGroup = "company_group"
//        case bookingDate, project, block, tower, unit, prospect
//        case v = "__v"
//        case updateBy, actions, status, clients, comments
//        case bookingLocalID = "bookingLocalId"
//        case terms
//    }
}
struct Type : Codable{
    
    let _id : String?
    let name : String?
    let superBuiltUpArea : Area?
    let carpetArea : Area?
    let carParks : [CarParks]?
    let BillingElementForPricing : [BillingElementForPricing]?
    
}
struct BillingElementForPricing : Codable {
    let _id : String?
    let agreeValItem : Int?
}
struct Tax : Codable {
    let _id : String?
    let taxes : [Taxes]?
}
struct Taxes : Codable{
    let _id : String?
    let variants : [Varient]?
}
struct Varient : Codable {
    let name : String?
    let code : String?
    let value : Int?
    let to : String?
    let from : String?
    let _id : String?
}
struct CarParks : Codable{
    let _id : String?
    let cType : String?
    let count : Int?
}
struct Customer : Codable{
    let agreementDate : String?
    let block : String?
    let bookingDate : String?
    let comments : String?
    let company_group : String?
    let discount : Int?
    let email : String?
    let finalPossessionDate : String?
    let name : String?
    let phone :  Int?
    let prelimsPossessionDate : String?
    let project : String?
    let saleDeedDate : String?
    let tower : String?
    let unit : String?
    let updateBy : [UPDATEDBY]?
    let _id : String?
    let __v : Int?
    
}
struct Premium : Codable {
    let _id : String?
    let name : String?
}
struct Floor : Codable {
    let index : Int?
    let displayName : String?
}
struct TOWERDETAILS : Codable{
    let _id : String?
    let name : String?
    let project : String?
    let block : String?
    let short_name : String?
    let total_floors : Int?
    let starting_floor : String?
    let units_per_floor : Int?
    let company_group : String?
    let __v : Int?
    let towerType : Int?
    let updateBy : [UPDATEDBY]?
    let status : Int?
    let superBuiltUpArea : Area?
    let builtUpArea : Area?
    let landArea : Area?
}
struct BlockDetails : Codable {
    let _id : String?
    let __v : Int?
    let company_group : String?
    let name : String?
    let project : String?
    let short_name : String?
    let stage : String?
    let landArea : Area?
    let builtUpArea : Area?
    let superBuiltUpArea : Area?
    let stats : [STAT]?
    let status : Int?
    let updateBy : [UPDATEDBY]?
}
struct STATUS_CHANGE_API_RESULT : Codable {
    let oldStatus : Int?
    let status : Int?
//    let unit : UnitDetails?
}
struct STATUS_RESULT : Codable {
    let oldStatus : Int?
    let status : Int?
    let unit : UnitDetails?
}
struct BOOK_UNIT_RESULT : Codable{
    let data : URL_DATA?
    let msg : String?
    let status : Int?
}
struct URL_DATA : Codable {
    let _id : String?
    let clientId : String?
}


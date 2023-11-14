//
//  JsonModels.swift
//  ReRoot
//
//  Created by Dhanunjay on 26/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

//extension KeyedDecodingContainer {
//    func decode(forKey key: KeyedDecodingContainer.Key) throws -> Double {
//        do {
//            let str = try self.decode(String.self, forKey: key)
//
//            if let dbl = Double(str) {
//                return dbl
//            }
//        } catch DecodingError.typeMismatch {
//            return try self.decode(Double.self, forKey: key)
//        }
//        let context = DecodingError.Context(codingPath: self.codingPath,
//                                            debugDescription: "Wrong Money Value")
//        throw DecodingError.typeMismatch(Double.self, context)
//    }
//
//}

// MARK: - Outstandings
struct OutstandingTimelineResult : Codable{
    let status: Int
    let cofs: [Cof]?
}
struct Cof: Codable {
    let id, unit, customer, mode: String?
    let comment: String?
    let outstandingAmount: Double
    let companyGroup: String?
    let updateBy: [CosUpdateBy]?
    let v: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case unit, customer, mode, comment, outstandingAmount
        case companyGroup = "company_group"
        case updateBy
        case v = "__v"
    }
}
struct CosUpdateBy: Codable {
    let id: String?
    let user: User?
    let descp, date: String?
    let src: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user, descp, date, src
    }
}
struct User: Codable {
    let id, email: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
    }
}
struct OutstandingsResult: Codable {
    let status: Int
    let cos: [Cos]?
}
struct Cos: Codable {
    let unit: OutstandingUnit?
    let totalReceipt: Double?
    let demandLetterAmount: Double?
    let demandLetterTax: Double?
    let receipts: [CosReceipt]?
    let outstandingsInRange: [Double]?
    
    enum CodingKeys: String, CodingKey {
        case unit
        case totalReceipt
        case demandLetterAmount
        case demandLetterTax
        case receipts
        case outstandingsInRange
    }
    init(from decoder: Decoder) throws {
        
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        unit = try values.decodeIfPresent(OutstandingUnit.self, forKey: .unit)
        receipts = try values.decodeIfPresent([CosReceipt].self, forKey: .receipts)

        if let value = try? values.decodeIfPresent(Int.self, forKey: .totalReceipt) {
            totalReceipt = Double(value)
        } else {
            totalReceipt = try values.decodeIfPresent(Double.self, forKey: .totalReceipt)
        }
        if let value = try? values.decodeIfPresent(Int.self, forKey: .demandLetterAmount) {
            demandLetterAmount = Double(value)
        } else {
            demandLetterAmount = try values.decodeIfPresent(Double.self, forKey: .demandLetterAmount)
        }
        if let value = try? values.decodeIfPresent(Int.self, forKey: .demandLetterTax) {
            demandLetterTax = Double(value)
        } else {
            demandLetterTax = try values.decodeIfPresent(Double.self, forKey: .demandLetterTax)
        }
        if let value = try? values.decodeIfPresent([Int].self, forKey: .outstandingsInRange) {
            outstandingsInRange = value.map{ Double($0) }
        } else {
            outstandingsInRange = try values.decodeIfPresent([Double].self, forKey: .outstandingsInRange)
        }

    }

}
struct OutstandingUnit : Codable {
    let floor, unitNo: Floor?
    let id: String?
    let project, tower, block: CosBlock?
    let unitDescription: String?
    let bookingform: CosBookingform?

    enum CodingKeys: String, CodingKey {
        case floor, unitNo
        case id = "_id"
        case project, tower, block
        case unitDescription = "description"
        case bookingform
    }
}
struct CosBookingform: Codable {
    let id: String?
    let clients: [CosClient]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case clients
    }
}
struct CosClient: Codable {
    let checklist: [JSONAny]?
    let id, client: String?
    let customer: CosCustomer?
    let share: Int?

    enum CodingKeys: String, CodingKey {
        case checklist
        case id = "_id"
        case client, customer, share
    }
}
struct CosCustomer: Codable {
    let id, name: String?
    let phone: Int?
    let email: String?
    let phoneCode: String?
    let customerID: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, phone, email, phoneCode
        case customerID = "customerId"
    }
}
struct CosBlock : Codable {
    let id, name: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}
struct CosReceipt: Codable {
    let status: Int
    var id, receiptType, paymentMode: String?
    let paymentTowards: String?
    let paymentDescp: String?
    let amount: Double?
    let depositDate, receiptNumber: String?
    let chequeBank: CosChequeBank?
    let referenceNumber, chequeDate: String?

    enum CodingKeys: String, CodingKey {
        case status
        case id = "_id"
        case chequeBank
        case paymentTowards
        case receiptType, paymentMode, paymentDescp, amount, depositDate, receiptNumber, referenceNumber, chequeDate
    }
}
struct CosChequeBank: Codable {
    let bankName, bankBranch: String?
    let bankIfscCode, bankAddress: String?
}
//
//enum CosPaymentTowards: String, Codable {
//    case advanceReceipts = "Advance Receipts"
//    case againstDemandNote = "Against Demand Note"
//    case onBooking = "On Booking"
//}
// MARK: - Generals
struct Generals: Codable {
    let status: Int
    let generals: GeneralsClass?
}

// MARK: - GeneralsClass
struct GeneralsClass: Codable {
    let discountOnRate: Bool
    let id, companyGroup: String
    let pgs: [PG]
    let v: Int
    let uoms, nofs, pts, cpts: [CN]
    let fts, pis, cns, dns: [CN]
    let vendorgroup, uts: [CN]
    let budgets: [Budget]
    let uss, taxes: [JSONAny]

    enum CodingKeys: String, CodingKey {
        case discountOnRate = "discount_on_rate"
        case id = "_id"
        case companyGroup = "company_group"
        case pgs
        case v = "__v"
        case uoms, nofs, pts, cpts, fts, pis, cns, dns, vendorgroup, uts, budgets, uss, taxes
    }
}

// MARK: - Budget
struct Budget: Codable {
    let id: String
    let value: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case value
    }
}

// MARK: - CN
struct CN: Codable {
    let id, name: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}

// MARK: - PG
struct PG: Codable {
    let psgs: [CN]
    let id, name: String

    enum CodingKeys: String, CodingKey {
        case psgs
        case id = "_id"
        case name
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}

struct SCHEMES_API_RESULT : Codable {
    let status : Int
    let schemes : [SCHEMES]?
}
struct SCHEMES : Codable {
    let _id , project, name , description,endDate,startDate,compnay_group : String?
    let __v : Int?
}
struct COMMISSOIN_API_RESULT : Codable {
    let status : Int?
    let commissionconfigs : [COMMISSION_CONFIG]?
}
struct COMMISSION_CONFIG : Codable {
    let individual: Individual?
    let _id: String?
}
struct Individual: Codable {
    let kind: String?
    let id: ID?
}
struct ID: Codable {
    let isAgent: Bool?
    let _id, name: String?
    let phone: String?
    
    enum CodindKeys :String, CodingKey{
        case isAgent
        case _id
        case name
        case phone
    }
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodindKeys.self)
        
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        isAgent = try values.decodeIfPresent(Bool.self, forKey: .isAgent)
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .phone) {
            phone = String(value)
        } else {
            phone = try values.decodeIfPresent(String.self, forKey: .phone)
        }
    }
}
struct PREVIEW_OFFER_RESULT : Codable {
    let status : Int?
    let url : String?
    let msg : String?
}
struct SOLD_UNITS_OUTPUT : Codable {
    let status: Int?
    let units: [UNIT_INFO]?
}

struct LOGIN_OUTPUT : Codable {
    let status : Int
    let groupId : String
    let user : USER?
}
struct AWS_S3 : Codable {
    let status : Int?
    let s3 : S3CONFIG?
}
struct S3CONFIG : Codable {
    let accessKeyId ,secretAccessKey , region,bucket : String
}
struct USER : Codable{
    let status : Int?
    let _id , email ,company_group,company_group_name : String?
    let type : Int?
    let userInfo : USER_ROLE_INFO?
}
struct USER_ROLE_INFO : Codable{
    let _id, name, email, phone: String?
    let showCommissions : Bool?
    let promptOtp : Bool?
    let siteVisitUser : Bool?
    let roles: [Role]?
}
struct Role : Codable {
    let _id , name : String?
    let permissions : PERMISSIONS?
    let presalesActions : PRESALE_ACTION_PERMISSIONS?
}
struct PERMISSIONS : Codable{
    let _id : String?
    let create : String?
    let  edit : String?
    let delete : String?
    let view : String?
    let __v : Int?
}
struct PRESALE_ACTION_PERMISSIONS : Codable {
    let calls,offers,siteVisits,discountRequests , otherTasks,notInterested : Int?
    let _id : String?
}
struct RECEIPT_CREATE_ENTRY_OUTPUT : Codable {
    let status : Int
    let receiptEntry : RECEIPT_ENTRY?
    let msg : String?
    let err : String?
}
struct RECEIPT_ENTRY : Codable {
    let _id : String?
}
struct PaymentToWards : Codable {
    var name : String?
    var count : Int?
    var amount : Double?
    var _id : String?
}

struct UNIT_TRANSACTIONS_OUTPUT : Codable {
    let status : Int?
    let transactions : UNIT_TRANSACTIONS?
}
struct UNIT_TRANSACTIONS : Codable {
    let totalCredits : [TOTAL_CREDITS]?
    let firstInstallment : FIRST_INSTALLMENT?
    let debitDeatils : [DEBIT_DETAILS]?
}
struct TOTAL_CREDITS : Codable{
    let count : Int?
    let totalAmount : Double?
}
struct FIRST_INSTALLMENT : Codable {
    let demandLetterStatus : Int?
    let _id : String?
    let installmentName : String?
    let installmentAmount : Double?
    let balanceAmount : Double?
    let dueDate : String?
    let payDate : String?
}
struct DEBIT_DETAILS : Codable {
    let status : Int?
    let _id : String?
    let invoice_date : String?
    let total_amount : Double?
    let installments : [INSTALLMENTS]?
    let debitNotes  : [INSTALLMENTS]?
    let creditNotes : [INSTALLMENTS]?
}
struct INSTALLMENTS : Codable {
    let _id : String?
    let amount : Double?
    let taxAmount : Double?
    let id : INSTALLMENT_ID?
}
struct INSTALLMENT_ID : Codable {
    let _id : String?
    let installmentName : String?
    let installmentPercent : Double?
    let installmentAmount : Double?
    let balanceAmount : Double?
    let dueDate : String?
    let payDate : String?
    let status : Int?
    let taxAmount : Double?
    let balanceTaxAmount : Double?
    let descp : String?
    let noteType : Int?
    let demandLetterStatus : Int?
    let billings : [PAYMENT_BILLING_ELEMENT]?
    let premiumBillings : [PAYMENT_BILLING_ELEMENT]?
    let constructionAmount : Double?
    let landAmount : Double?
    let paymentSchedule : String?
//    var billingElements
//    var premiumBillingElements
    
    enum CodindKeys :String, CodingKey{
        case _id = "_id"
        case installmentName = "installmentName"
        case installmentPercent = "installmentPercent"
        case installmentAmount =  "installmentAmount"
        case balanceAmount = "balanceAmount"
        case dueDate = "dueDate"
        case payDate = "payDate"
        case status = "status"
        case taxAmount = "taxAmount"
        case balanceTaxAmount = "balanceTaxAmount"
        case descp = "descp"
        case noteType = "noteType"
        case demandLetterStatus = "demandLetterStatus"
        case billings = "billings"
        case premiumBillings = "premiumBillings"
        case constructionAmount = "constructionAmount"
        case landAmount = "landAmount"
        case paymentSchedule = "paymentSchedule"
    }
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodindKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        installmentName = try values.decodeIfPresent(String.self, forKey: .installmentName)
        paymentSchedule = try values.decodeIfPresent(String.self, forKey: .paymentSchedule)
        dueDate = try values.decodeIfPresent(String.self, forKey: .dueDate)
        
        payDate = try values.decodeIfPresent(String.self, forKey: .payDate)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        noteType = try values.decodeIfPresent(Int.self, forKey: .noteType)
        demandLetterStatus = try values.decodeIfPresent(Int.self, forKey: .demandLetterStatus)
        descp = try values.decodeIfPresent(String.self, forKey: .descp)
        
        billings = try values.decodeIfPresent([PAYMENT_BILLING_ELEMENT].self, forKey: .billings)
        premiumBillings = try values.decodeIfPresent([PAYMENT_BILLING_ELEMENT].self, forKey: .premiumBillings)


        if let value = try? values.decodeIfPresent(Int.self, forKey: .installmentPercent) {
            installmentPercent = Double(value)
        } else {
            installmentPercent = try values.decodeIfPresent(Double.self, forKey: .installmentPercent)
        }
        if let value = try? values.decodeIfPresent(Int.self, forKey: .installmentAmount) {
            installmentAmount = Double(value)
        } else {
            installmentAmount = try values.decodeIfPresent(Double.self, forKey: .installmentAmount)
        }
        if let value = try? values.decodeIfPresent(Int.self, forKey: .balanceAmount) {
            balanceAmount = Double(value)
        } else {
            balanceAmount = try values.decodeIfPresent(Double.self, forKey: .balanceAmount)
        }

        if let value = try? values.decodeIfPresent(Int.self, forKey: .taxAmount) {
            taxAmount = Double(value)
        } else {
            taxAmount = try values.decodeIfPresent(Double.self, forKey: .taxAmount)
        }
        if let value = try? values.decodeIfPresent(Int.self, forKey: .balanceTaxAmount) {
            balanceTaxAmount = Double(value)
        } else {
            balanceTaxAmount = try values.decodeIfPresent(Double.self, forKey: .balanceTaxAmount)
        }

        if let value = try? values.decodeIfPresent(Int.self, forKey: .landAmount) {
            landAmount = Double(value)
        } else {
            landAmount = try values.decodeIfPresent(Double.self, forKey: .landAmount)
        }
        if let value = try? values.decodeIfPresent(Int.self, forKey: .constructionAmount) {
            constructionAmount = Double(value)
        } else {
            constructionAmount = try values.decodeIfPresent(Double.self, forKey: .constructionAmount)
        }
    }
    
}
struct PAYMENT_BILLING_ELEMENT : Codable {
    
    let _id : String?
    let billing : String?
    var percentage: Double?
    var amount : Double?
    
    enum TempCodindKeys :String, CodingKey{
        case _id = "_id"
        case billing = "billing"
        case percentage = "percentage"
        case amount =  "amount"
    }
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: TempCodindKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        billing = try values.decodeIfPresent(String.self, forKey: .billing)
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .percentage) {
            percentage = Double(value )
        } else {
            percentage = try values.decodeIfPresent(Double.self, forKey: .percentage)
        }
        if let value = try? values.decodeIfPresent(Int.self, forKey: .amount) {
            amount = Double(value )
        } else {
            amount = try values.decodeIfPresent(Double.self, forKey: .amount)
        }
    }

}
struct IFSC_CODE_OUTPUT : Codable {
    
    let branch, address, contact, city: String?
    let district, state: String?
    let rtgs: Bool?
    let bank, bankcode, ifsc: String?
    
    enum CodingKeys: String, CodingKey {
        case branch = "BRANCH"
        case address = "ADDRESS"
        case contact = "CONTACT"
        case city = "CITY"
        case district = "DISTRICT"
        case state = "STATE"
        case rtgs = "RTGS"
        case bank = "BANK"
        case bankcode = "BANKCODE"
        case ifsc = "IFSC"
    }
}
struct PROJECT_BANK_OUTPUT : Codable {
    let status : Int?
    let bankaccounts : [BANK_ACCOUNTS]?
}
struct BANK_ACCOUNTS : Codable {
    let _id : String?
    let project : String?
    let accountNumber : Int?
    let bankName : String?
    let bankBranch : String?
    let bankIfscCode : String?
    let bankAddress : String?
    let company_group : String?
    let updateBy : [UPDATEDBY]?
}
struct PROSPECT_COUNT_OUTPUT : Codable {
    let status : Int?
    let total : PROSPECTS_COUNTS?
    let expired : PROSPECTS_COUNTS?
    let err : String?
    
}
struct PROSPECTS_COUNTS : Codable {
    let callCount, offerCount, siteVisitCount, discountRequestCount: Int
    let otherCount, notInterestedCount: Int
}
struct DISCOUNT_APPROVAL_OUTPUT : Codable {
    let status: Int
    let approvals: [APPROVAL]?
}
struct Approval_By_Id_Result : Codable {
    let status : Int?
    let approval : APPROVAL?
    let msg : String?
}
struct APPROVAL : Codable {
    let _id : String?
    let status, level: Int?
    let company_group: String?
    let unit: String?
    let approval_type: Int?
    let v: Int?
    let updateBy: [UPDATEDBY]?
    let reference: Reference?
    let requester : APPROVER?
    let approver : APPROVER?
    let remarks : String?
    let rejectReason : String?
    let approvalHistory: [APPROVAL_HISTORY]?
}
struct  APPROVAL_HISTORY : Codable {
    let approver: APPROVER?
    let level: Int?
    let rejectReason: String?
    let remarks: String?
    let created, lastModified: String?
    let status: Int?
}
struct Reference : Codable {
    let kind : String?
    let item : APPROVAL_ITEM?
    let id: String?
}
struct APPROVAL_ITEM : Codable {
    let status : Int?
    let created_on : String?
    let _id : String?
    let company_group: String?
    let updateBy : [UPDATEDBY]?
    let regInfo : REG_INFO?
    let unit : UNIT_INFO?
    let scheme : String?
    let billingsInfo : [APPROVAL_BILLING_INFO]?
    let pdc_return_date, agreement_collected_date, assignment_date: String?
    let bookingId: String?
    let cancel_reason: String?
    let transfer_unit: TRANSFER_UNIT?
    let customer: APPROVAL_CUSTOMER?
    let pricingInfo: APPROVAL_PRICING_INFO?
    let cancellation_date: String?
    let is_transfer_unit: Bool?
    let transfer_date: String?
    let new_customer: APPROVAL_NEW_CUSTOMER?
    let new_customerID: String?
    let descp : String?
    let narration : String?
    let amount : Double?
    let tax : CreditNoteTax?
    let dueDate : String?
        
    enum TempCodindKeys :String, CodingKey{
            case status
            case created_on
            case _id
            case company_group
            case updateBy
            case regInfo
            case unit
            case scheme
            case billingsInfo
            case pdc_return_date, agreement_collected_date, assignment_date
            case bookingId
            case cancel_reason
            case transfer_unit
            case customer
            case pricingInfo
            case cancellation_date
            case is_transfer_unit
            case transfer_date
            case new_customer
            case new_customerID
            case descp
            case narration
            case amount
            case tax
            case dueDate
    }
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: TempCodindKeys.self)

        status = try values.decodeIfPresent(Int.self, forKey: .status)
        created_on = try values.decodeIfPresent(String.self, forKey: ._id)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        company_group = try values.decodeIfPresent(String.self, forKey: .company_group)
        updateBy = try values.decodeIfPresent([UPDATEDBY].self, forKey: .updateBy)

        regInfo = try values.decodeIfPresent(REG_INFO.self, forKey: .regInfo)
        unit = try values.decodeIfPresent(UNIT_INFO.self, forKey: .unit)

        scheme = try values.decodeIfPresent(String.self, forKey: .scheme)
        billingsInfo = try values.decodeIfPresent([APPROVAL_BILLING_INFO].self, forKey: .billingsInfo)

        pdc_return_date = try values.decodeIfPresent(String.self, forKey: .pdc_return_date)
        agreement_collected_date = try values.decodeIfPresent(String.self, forKey: .agreement_collected_date)
        assignment_date = try values.decodeIfPresent(String.self, forKey: .assignment_date)
        bookingId = try values.decodeIfPresent(String.self, forKey: .bookingId)
        cancel_reason = try values.decodeIfPresent(String.self, forKey: .cancel_reason)
        cancellation_date = try values.decodeIfPresent(String.self, forKey: .cancellation_date)
        transfer_unit = try values.decodeIfPresent(TRANSFER_UNIT.self, forKey: .transfer_unit)
        customer = try values.decodeIfPresent(APPROVAL_CUSTOMER.self, forKey: .customer)
        pricingInfo = try values.decodeIfPresent(APPROVAL_PRICING_INFO.self, forKey: .pricingInfo)

        is_transfer_unit = try values.decodeIfPresent(Bool.self, forKey: .is_transfer_unit)
        transfer_date = try values.decodeIfPresent(String.self, forKey: .transfer_date)
        new_customer = try values.decodeIfPresent(APPROVAL_NEW_CUSTOMER.self, forKey: .new_customer)
        new_customerID = try values.decodeIfPresent(String.self, forKey: .new_customerID)
        descp = try values.decodeIfPresent(String.self, forKey: .descp)
        narration = try values.decodeIfPresent(String.self, forKey: .narration)
        dueDate = try values.decodeIfPresent(String.self, forKey: .dueDate)
        tax = try values.decodeIfPresent(CreditNoteTax.self, forKey: .tax)

        if let value = try? values.decodeIfPresent(Int.self, forKey: .amount) {
            amount = Double(value )
        } else {
            amount = try values.decodeIfPresent(Double.self, forKey: .amount)
        }
    }

    
}
struct CreditNoteTax : Codable {
    let _id : String?
    let label :String?
}
struct APPROVAL_PRICING_INFO : Codable {
    let waive_off_charges : Double?
    let tax_amount_refund : Double?
    let amount_received : Double?
    let demand_letter_amount : Double?
    let tax_received : Double?
    let cancellation_charge ,cancellation_charge_tax,amount_payable : Double?
    let is_tax_amount_refund : Bool?
    let assignment_charge : Double?
    let assignment_charge_tax : Double?
    let amount_due : Double?
    let transfer_charge_payable_by : Double?
    let assignment_charge_debit_note_reference : String?
    let assignment_charge_receipt_reference : String?
    let tax_paid : Double?
}
struct TRANSFER_UNIT : Codable {
    let _id : String?
    let description : String?
    let unitNo : Floor?
}
struct APPROVAL_CUSTOMER : Codable {
    let _id : String?
    let name : String?
    let phone : Int?
    let email : String?
}
struct APPROVAL_NEW_CUSTOMER : Codable {
    let _id : String?
    let userName : String?
    
}
struct UNIT_INFO : Codable {
    
    let unitNo : UNIT_INDEX?
    let _id : String?
    let project : PROJECT?
    let tower : PROJECT?
    let block : PROJECT?
    let description : String?
    let type: PROJECT?
    let updateBy : [UPDATEDBY?]?
    let company_group : String?
    let floorPremium : String?
    let otherPremium : [String]?
    let floor : UNIT_INDEX?
    let status : Int?
    let manageUnitStatus : Int?
    let handOverStatus : Int?
    let handoverItems : [UnitHandoverItem?]?
    let handoverHistory : [HAND_OVER_HISTORY?]?
    let bookingform : String?
    let facing, customer, landowner, blockingReason: String?
    
}
struct HAND_OVER_HISTORY : Codable {
    let modifiedDate: String?
    let status: Int?
    let user: String?
}
struct UnitHandoverItem : Codable {
    let company: String?
    let company_group: String?
    let tower: String?
    let unit, ItemId: String?
    let groupdId: String?
    let groupdName: String?
    let enabled: Bool?
    let name: String?
    let ireviewLevels : ReviewLevels?
    let creviewLevels: ReviewLevels?
    let mandatory, isNewItem: Bool?
    let handOverStatus: Int?
    let internalreviews, customerreviews: [Review?]?
    let complaintDesc: String?
    let complaintimgUrls: [String]?
    let complaintlocation: String?
    let itemHistory: [ItemHistory?]?
    let v: String?
    let _id, updatedOn: String?
    let complaintDate: Int?
}
enum CheckedLevel : Codable{
    case integer(Int)
    case bool(Bool)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(Bool.self) {
            self = .bool(x)
            return
        }
        throw DecodingError.typeMismatch(ReviewLevels.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ReviewLevels"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .bool(let x):
            try container.encode(x)
        }
    }

}
enum ReviewLevels: Codable {
    case integer(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(ReviewLevels.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ReviewLevels"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}
struct Review : Codable {
    let checked : Bool?
    let reviewType : String?
    let level : Int?
    let role : String?
    let _id : String?
    let createdDate : String?
    let reviewStatus : Int?
    let days : Int?
}
struct ItemHistory : Codable {
    let description : String?
    let handOverStatus : Int?
    let imgUrl : [String]?
    let location : String?
    let modifiedDate : String?
    let status : Int?
    let user : String?
}
struct UNIT_INDEX : Codable
{
    let index : Int?
    let displayName : String?
}
struct APPROVAL_BILLING_INFO : Codable {
    let _id : String?
    let rate : Double?
    let qty : Double?
    let type : String?
    let discountedRate : Double?
    let discountedPercent : Double?
    let discountedAmt : Double?
    let discountOnRate : Double?
    let billingElement : PELEMENT?
    let nbilling : PELEMENT?
    
    enum CodingKeys : CodingKey{
        case _id
        case rate
        case qty
        case type
        case discountedRate
        case discountedPercent
        case discountedAmt
        case discountOnRate
        case billingElement
        case nbilling
    }
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        rate = try values.decodeIfPresent(Double.self, forKey: .rate)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        billingElement = try values.decodeIfPresent(PELEMENT.self, forKey: .billingElement)
        nbilling = try values.decodeIfPresent(PELEMENT.self, forKey: .nbilling)
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .qty) {
            qty = Double(value ?? 0)
        } else {
            qty = try values.decodeIfPresent(Double.self, forKey: .qty)
        }
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .discountOnRate) {
            discountOnRate = Double(value ?? 0)
        } else {
            discountOnRate = try values.decodeIfPresent(Double.self, forKey: .discountOnRate)
        }


        if let value = try? values.decodeIfPresent(Int.self, forKey: .discountedAmt) {
            discountedAmt = Double(value ?? 0)
        } else {
            discountedAmt = try values.decodeIfPresent(Double.self, forKey: .discountedAmt)
        }
        if let value = try? values.decodeIfPresent(Int.self, forKey: .discountedPercent) {
            discountedPercent = Double(value ?? 0)
        } else {
            discountedPercent = try values.decodeIfPresent(Double.self, forKey: .discountedPercent)
        }
        if let value = try? values.decodeIfPresent(Int.self, forKey: .discountedRate) {
            discountedRate = Double(value ?? 0)
        } else {
            discountedRate = try values.decodeIfPresent(Double.self, forKey: .discountedRate)
        }
    }
    
}
struct APPROVER : Codable {
    let _id : String?
    let email : String?
    let userInfo : USER_INFO?
}
struct RECEIPT_ENTRIES_COUNT_OUTPUT : Codable {
    let status : Int?
    let tab : String?
    let result : [RECEIPT_TYPE_ENTRIES_COUNT]?
    let err : String?
}
struct RECEIPT_TYPE_ENTRIES_COUNT : Codable {
    let _id : String?
    let name : String?
    let count : Int?
    let totalcollected : Double?
}
struct RECEIPT_ENTRIES_OUTPUT : Codable{
    let status : Int?
    let receiptEntries : [RECEIPT_ENTRIES]?
    let err : RECIEPT_ERROR?
}
struct RECIEPT_ERROR : Codable {
    let message : String?
    let name : String?
}
struct RECEIPT_ENTRIES : Codable {
    let representStatus, bounceCount, bounceCharges, status,allocationStatus : Int?
    let allocationBalance : Double?
    let _id,project,block,tower,receiptType,paymentMode,paymentTowards,depositDate,company_group,receiptLocalId,receiptNumber,createdDate,currency,projectBank : String?
    let amount,curAmount ,baseAmount,taxAmount: Double?
    let unit : RECEIPT_ENTRY_UNIT?
    let customer : RECEIPT_ENTRY_CUSTOMER?
    let createdBy : CREATEDBY?
    let updateBy : [UPDATEDBY]?
    let referenceNumber, chequeDate, chequeReturnDate, returnReason: String?
    let chequeBank : CHEQUE_BANK?
    let images : [String]?
}
struct CHEQUE_BANK : Codable {
    let bankAddress : String?
    let bankBranch : String?
    let bankIfscCode : String?
    let bankName : String?
}
struct CREATEDBY : Codable {
    let _id : String?
}
struct RECEIPT_ENTRY_CUSTOMER : Codable {
    let _id,name,email,customerId,phoneCode : String?
    let phone : Int?
}
struct RECEIPT_ENTRY_UNIT : Codable {
    let status : Int?
    let _id : String
    let description : String?
    let unitNo : Floor?
}
struct USER_PERMISSIONS_OUTPUT : Codable {
    let permArray : [USER_PERMISSIONS]?
}
struct USER_PERMISSIONS : Codable {
    let name : String?
    let bit : Int?
    let module : String?
    let identifier : String?
    let page : String?
    let items : [MODULE_PERMISSION]?
}
struct MODULE_PERMISSION : Codable {
    let name : String?
    let bit : Int?
    let page : String?
}
struct ASSIGN_SALES_PERSON_OUTPUT : Codable {
    let status : Int?
}
struct BLOCK_UNIT_DEFAULTS : Codable {
    let status : Int?
    let defaults : DEFAULTS?
}
struct DEFAULTS : Codable {
    let defaultVals : Int?
    let _id : String?
}
struct NOTIFICATIONS_OUTPUT : Codable {
    let status : Int?
    let notifications : [PUSH_NOTIFICATIONS]?
}
struct PUSH_NOTIFICATIONS : Codable {
    let _id : String?
    let is_read: Bool
    let created_at : String?
    let updated_at : String?
    let user_id : String?
    let msg : String?
    let company_group : String?
    let type : String?
    let __v : Int?
    let reference : NotificationReference?
    
}
struct NotificationReference : Codable {
    let kind : String?
    let item : String?
}
struct EMPLOYEES : Codable {
    let status : Int?
    let users : [EMPLOYEE]?
}
struct EMPLOYEE : Codable {
    let userInfo : EMPLOYEE_INFO?
    let roles : [Role?]?
    let type : Int?
    let status : Int?
    let isAgent : Bool?
    let prospectData : Int?
    let fromDate : String?
    let toDate : String?
    let _id : String?
    let email : String?
    let name : String?
    let employee_id : String?
    let company_group : String?
    let registration_code : String?
    let phone : String?
    let compnay_group : String?
    let ocmpnay_group_name : String?
    let __v : Int?
//    let dob : String?
//    let gender : String?
    let user_id : String?
    let empStatus : Int?
    
}
struct COMMISSION_USERS_OUTPUT : Codable {
    let status : Int?
    let customers : [CommissionUser]?
    let users : [CommissionUser]?
}
struct CommissionUser : Codable {
    
    var _id: String?
    var phone: String?
    var isAgent : Bool?
    var type : Int?
    var name : String?
    
    enum CodingKeys : CodingKey{
        case _id
        case phone
        case isAgent
        case type
        case name
    }
    init(name : String?,phone : String?){
        self.name = name
        self.phone = phone
    }
    init(from decoder: Decoder) throws {

        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        type = try values.decodeIfPresent(Int.self, forKey: .type)
        isAgent = try values.decodeIfPresent(Bool.self, forKey: .isAgent)
        name = try values.decodeIfPresent(String.self, forKey: .name)


        if let value = try? values.decodeIfPresent(Int.self, forKey: .phone) {
            phone = String(value ?? 0)
        } else {
            phone = try values.decodeIfPresent(String.self, forKey: .phone)
        }
    }

    
}
struct EMPLOYEE_INFO : Codable {
    let roles : [String]?
    let blocks : [String]?
    let projects : [String]?
    let towers : [String]?
    let name : String?
    let _id : String?
}
struct ROLE : Codable{
    let _id : String?
    let name : String?
}
struct BOOKING_FORM_SET_UP : Codable {
    let status : Int?
    let BookingFormSetup : BOOKING_FORM_SETUP?
    let defaults : BOOKING_FORM_SETUP?
}
struct BOOKING_FORM_SETUP : Codable {
    let defaultVals : Int?
    let _id : String?
    let company_group : String?
    let TDScompliance : [COMMON_FORMAT]?
    let industry : [COMMON_FORMAT]?
    let functions : [COMMON_FORMAT]?
    let annualIncome : [COMMON_FORMAT]?
    let fundSource : [COMMON_FORMAT]?
    let bookingSource : [COMMON_FORMAT]?
    let purchasePurpose : [COMMON_FORMAT]?
    let projctType : [COMMON_FORMAT]?
    let location : [COMMON_FORMAT]?
    let paymentMode : [COMMON_FORMAT]?
    let paymentTowards : [PaymentToWards]?
    let gender : [COMMON_FORMAT]?
    let salutation : [COMMON_FORMAT]?
    let bookingCheckList : [COMMON_FORMAT]?
    let assignmentCheckList : [COMMON_FORMAT]?
    let commisionCheckList : [COMMON_FORMAT]?
    let blockReason : [COMMON_FORMAT]?
    let cancelReason : [COMMON_FORMAT]?
    let currency : [CURRENCY]?
    let countryCodes : [COUTRY_CODES]?
    let unitStatus : [UNIT_STATUS_COLOR]?
    let residentialStatus : [COMMON_FORMAT]?
}
struct COMMON_FORMAT : Codable {
    var _id : String?
    var name : String?
}
struct CURRENCY : Codable {
    let _id : String?
    let id : String?
    let currencySymbol : String?
    let currencyName : String?
}
struct COUTRY_CODES : Codable {
    let _id : String?
    let country : String?
    let shortCode : String?
    let flag : String?
    let phCode : String?
}
struct UNIT_STATUS_COLOR : Codable {
    let _id : String?
    let name : String?
    let colour : String?
    
}
struct BLOCK_REASON : Codable {
    var _id : String?
    var name : String?
}
struct AST_DETAILS : Codable {
    let status: Int?
    var astInfo: ASTInfo?
}
struct AST_UPDATE_OUTPUT : Codable {
    let status : Int?
    let astId : String?
    let err : String?
}
struct ASTInfo: Codable {
    var ast: [AST]?
    var id: String?
    var customer: Customer?
    
    enum CodingKeys: String, CodingKey {
        case ast
        case id = "_id"
        case customer
    }
}
struct AST: Codable {
    var dates: [String]?
    var id, name: String?
    
    enum CodingKeys: String, CodingKey {
        case dates
        case id = "_id"
        case name
    }
}
struct BOOKING_FORM_RESULT : Codable {
    
    let status : Int?
    let booking : BOOKING_FORM_RESULT_DETAILS?
    let tax : TAX?
    let agVal : AGVAL?
}
struct AGVAL : Codable {
    let be : Double?
    let pbe : Double?
    let total : Double?
    let finalbe : Double?
    let finalPbe : Double?
    let finalTotal : Double?
}
struct TAX : Codable {
    let be : Double?
    let pbe : Double?
    let total : Double?
    let finalbe : Double?
    let finalPbe : Double?
    let finalTotal : Double?
}

struct BOOKING_FORM_DETAILS : Codable {
    
    let _id : String?
    let status : Int?
    let company_group : String?
    let updatedBy : [UPDATEDBY]?
    let bookingDate : String?
    let prospect : PROSPECT?
    let project : String?
    let block : String?
    let tower : String?
    let comments : String?
    let salesPerson : SALES_PERSON?
    let bookingLocalId : String?
    let unitRate : UNIT_RATE?
    let clients : [UnitClient]?
//    let unit : []
    
    // actions , clients , installments Unit prices
    
}
struct BOOKING_FORM_RESULT_DETAILS : Codable {
    
    let _id : String?
    let status : Int?
    let company_group : String?
    let updatedBy : [UPDATEDBY]?
    let bookingDate : String?
    let prospect : PROSPECT?
    let project : String?
    let block : String?
    let tower : String?
    let comments : String?
    let salesPerson : String?
    let bookingLocalId : String?
    let unitRate : UNIT_RATE?
    let clients : [ClientList]?
    let installments : [INSTALLMENT_ID]?
    let scheme : SCHEME?
    //    let unit : []
    
    // actions , clients , installments Unit prices
    
}
struct SCHEME : Codable {
    let _id , name , description : String?
}
struct UNIT_RATE : Codable {
    var bes : BILLING_ELEMENTS?
    var pBes : PREMIUM_BILLING_ELEMENTS?
    let status :  Int?
    let createdOn : String?
    let _id : String?
    let project : String?
    let block : String?
    let tower : String?
    let unit : String?
    let bookingId : String?
    let total : Double?
    let discountTotal : Double?
    let finalTotal : Double?
    let company_group : String?
    let updateBy : [UPDATEDBY]?
    
}
struct PAYMENT_SCHEDULE_UNIT_RATE : Codable {
    var bes : BILLING_ELEMENTS?
    var pBes : PREMIUM_BILLING_ELEMENTS?
}
//PREMIUM_BILLING_ELEMENT_DETAILS
struct PREMIUM_BILLING_ELEMENTS : Codable {
    var pDetails : [P_BILLING_ELEMENTS]?
    let total : Double?
    let discountTotal : Double?
    let finalTotal : Double?
}
struct BILLING_ELEMENTS : Codable {
    let total : Double?
    let discountTotal : Double?
    let finalTotal : Double?
    var details : [BILLING_ELEMENT_DETAILS]?
    let pElement : PELEMENT?
}
struct P_BILLING_ELEMENTS : Codable {
    let total : Double?
    let discountTotal : Double?
    let finalTotal : Double?
    let details : [PREMIUM_BILLING_ELEMENT_DETAILS]?
    var pElement : PELEMENT?
}

struct PELEMENT : Codable {
    let _id : String?
    let name : String?
    let agreeValItem : Int?
    let taxCategory : Int?
    let elementType : Int?
    let pCost : Double?
    let finalPcost : Double?
    var taxVal : Double?
    var finalTaxVal : Double?
    var percentage : Double?
    var amount : Double?
    var viewIndex : Int?
    
    enum OneempCodindKeysOne :String, CodingKey{
        case _id
        case name
        case agreeValItem
        case taxCategory
        case elementType
        case pCost
        case finalPcost
        case taxVal
        case finalTaxVal
        case percentage
        case amount
        case viewIndex
    }
    
    init(from decoder: Decoder) throws {

        
        let values = try decoder.container(keyedBy: OneempCodindKeysOne.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        agreeValItem = try values.decodeIfPresent(Int.self, forKey: .agreeValItem)
        taxCategory = try values.decodeIfPresent(Int.self, forKey: .taxCategory)
        elementType = try values.decodeIfPresent(Int.self, forKey: .elementType)
        viewIndex = try values.decodeIfPresent(Int.self, forKey: .viewIndex)
//        pCost = try values.decodeIfPresent(Int.self, forKey: .pCost)
//        finalPcost = try values.decodeIfPresent(Int.self, forKey: .finalPcost)
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .finalPcost) {
            finalPcost = Double(value ?? 0)
        } else {
            finalPcost = try values.decodeIfPresent(Double.self, forKey: .finalPcost)
        }

        if let value = try? values.decodeIfPresent(Int.self, forKey: .pCost) {
            pCost = Double(value ?? 0)
        } else {
            pCost = try values.decodeIfPresent(Double.self, forKey: .pCost)
        }

        if let value = try? values.decodeIfPresent(Int.self, forKey: .taxVal) {
            taxVal = Double(value ?? 0)
        } else {
            taxVal = try values.decodeIfPresent(Double.self, forKey: .taxVal)
        }
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .finalTaxVal) {
            finalTaxVal = Double(value ?? 0)
        } else {
            finalTaxVal = try values.decodeIfPresent(Double.self, forKey: .finalTaxVal)
        }
        if let value = try? values.decodeIfPresent(Int.self, forKey: .percentage) {
            percentage = Double(value ?? 0)
        } else {
            percentage = try values.decodeIfPresent(Double.self, forKey: .percentage)
        }
        if let value = try? values.decodeIfPresent(Int.self, forKey: .amount) {
            amount = Double(value ?? 0)
        } else {
            amount = try values.decodeIfPresent(Double.self, forKey: .amount)
        }
    }
    
//    let finalPcost : Int?
//    let pCost : Int?
    //Taxes
}

//enum DynamicJSONProperty: Codable {
//    case double(Double)
//    case int(Int)
//    
//    init(from decoder: Decoder) throws {
//        let container =  try decoder.singleValueContainer()
//        
//        // Decode the double
//        do {
//            let doubleVal = try container.decode(Double.self)
//            self = .double(doubleVal)
//        } catch DecodingError.typeMismatch {
//            // Decode the string
//            let stringVal = try container.decode(Int.self)
//            self = .int(stringVal)
//        }
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        switch self {
//        case .double(let value):
//            try container.encode(value)
//        case .int(let value):
//            try container.encode(value)
//        }
//    }
//}

enum TAX_VALUE : Codable{
    case integer(Int)
    case double(Double)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        throw DecodingError.typeMismatch(ReviewLevels.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ReviewLevels"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .double(let x):
            try container.encode(x)
        }
    }
    
}
struct BILLING_ELEMENT_DETAILS : Codable {
    let _id : String?
    var element : ELEMENT?
    let name : String?
    let elementRate : Double?
    let qty : Double?
    let pricingType : String?
    let totalElementRate : Double?
    let discountedPercent : Double?
    let discountedRate : Double?
    let finalRate : Double?
    
    enum CodingKeys : CodingKey{
        case _id
        case element
        case name
        case elementRate
        case qty
        case pricingType
        case totalElementRate
        case discountedPercent
        case discountedRate
        case finalRate
    }
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        pricingType = try values.decodeIfPresent(String.self, forKey: .pricingType)
//        qty = try values.decodeIfPresent(Int.self, forKey: .qty)
        element = try values.decodeIfPresent(ELEMENT.self, forKey: .element)
        
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .qty) {
            qty = Double(value ?? 0)
        } else {
            qty = try values.decodeIfPresent(Double.self, forKey: .qty)
        }
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .elementRate) {
            elementRate = Double(value ?? 0)
        } else {
            elementRate = try values.decodeIfPresent(Double.self, forKey: .elementRate)
        }
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .totalElementRate) {
            totalElementRate = Double(value ?? 0)
        } else {
            totalElementRate = try values.decodeIfPresent(Double.self, forKey: .totalElementRate)
        }
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .discountedPercent) {
            discountedPercent = Double(value ?? 0)
        } else {
            discountedPercent = try values.decodeIfPresent(Double.self, forKey: .discountedPercent)
        }
        if let value = try? values.decodeIfPresent(Int.self, forKey: .discountedRate) {
            discountedRate = Double(value ?? 0)
        } else {
            discountedRate = try values.decodeIfPresent(Double.self, forKey: .discountedRate)
        }
        if let value = try? values.decodeIfPresent(Int.self, forKey: .finalRate) {
            finalRate = Double(value ?? 0)
        } else {
            finalRate = try values.decodeIfPresent(Double.self, forKey: .finalRate)
        }

    }
    
    
}
struct PREMIUM_BILLING_ELEMENT_DETAILS : Codable {
    
    let _id : String?
    let element : String?
    let name : String?
    let elementRate : Double?
    let qty : Double?
    let pricingType : String?
    let totalElementRate : Double?
    let discountedPercent : Double?
    let discountedRate : Double?
    let finalRate : Double?
    
    enum CodingKeys : CodingKey{
        case _id
        case element
        case name
        case elementRate
        case qty
        case pricingType
        case totalElementRate
        case discountedPercent
        case discountedRate
        case finalRate
    }
    
        init(from decoder: Decoder) throws {

            let values = try decoder.container(keyedBy: CodingKeys.self)
            _id = try values.decodeIfPresent(String.self, forKey: ._id)
            name = try values.decodeIfPresent(String.self, forKey: .name)
            pricingType = try values.decodeIfPresent(String.self, forKey: .pricingType)
            element = try values.decodeIfPresent(String.self, forKey: .element)
            
            //            qty = try values.decodeIfPresent(Int.self, forKey: .qty)


            if let value = try? values.decodeIfPresent(Int.self, forKey: .qty) {
                qty = Double(value ?? 0)
            } else {
                qty = try values.decodeIfPresent(Double.self, forKey: .qty)
            }
            
            if let value = try? values.decodeIfPresent(Int.self, forKey: .elementRate) {
                elementRate = Double(value ?? 0)
            } else {
                elementRate = try values.decodeIfPresent(Double.self, forKey: .elementRate)
            }
            
            if let value = try? values.decodeIfPresent(Int.self, forKey: .totalElementRate) {
                totalElementRate = Double(value ?? 0)
            } else {
                totalElementRate = try values.decodeIfPresent(Double.self, forKey: .totalElementRate)
            }
            
            if let value = try? values.decodeIfPresent(Int.self, forKey: .discountedPercent) {
                discountedPercent = Double(value ?? 0)
            } else {
                discountedPercent = try values.decodeIfPresent(Double.self, forKey: .discountedPercent)
            }
            if let value = try? values.decodeIfPresent(Int.self, forKey: .discountedRate) {
                discountedRate = Double(value ?? 0)
            } else {
                discountedRate = try values.decodeIfPresent(Double.self, forKey: .discountedRate)
            }
            if let value = try? values.decodeIfPresent(Int.self, forKey: .finalRate) {
                finalRate = Double(value ?? 0)
            } else {
                finalRate = try values.decodeIfPresent(Double.self, forKey: .finalRate)
            }
    }

}
struct ELEMENT : Codable {
    let _id : String?
    let name : String?
    var taxVal: Double?
    var finalTaxVal : Double?
    var percentage : Double?
    var amount : Double?
    var viewIndex : Int?
    
    enum TempCodindKeys :String, CodingKey{
        case _id = "_id"
        case name = "name"
        case taxVal = "taxVal"
        case finalTaxVal =  "finalTaxVal"
        case percentage = "percentage"
        case amount = "amount"
        case viewIndex = "viewIndex"
    }
    init(from decoder: Decoder) throws {

        let values = try decoder.container(keyedBy: TempCodindKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        viewIndex = try values.decodeIfPresent(Int.self, forKey: .viewIndex)
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .taxVal) {
            taxVal = Double(value ?? 0)
        } else {
            taxVal = try values.decodeIfPresent(Double.self, forKey: .taxVal)
        }

        if let value = try? values.decodeIfPresent(Int.self, forKey: .finalTaxVal) {
            finalTaxVal = Double(value ?? 0)
        } else {
            finalTaxVal = try values.decodeIfPresent(Double.self, forKey: .finalTaxVal)
        }
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .percentage) {
            percentage = Double(value ?? 0)
        } else {
            percentage = try values.decodeIfPresent(Double.self, forKey: .percentage)
        }
    }
}
struct BOOKED_UNIS_CLIENTS_API_RESULT : Codable{
    let status : Int?
    let bookings : [BOOKED_CLIENTS?]?
    let err : String?
}
struct BOOKED_CLIENTS : Codable {
    let customer: BOOKED_CUSTOMER?
}
struct BOOKED_CUSTOMER : Codable {
    let _id, name, customerId: String?
}
struct RESERVATIONS_API_RESULT : Codable{
    let status : Int?
    let reservedUnits : [RESERVED_UNITS]?
}
struct RESERVED_UNITS : Codable {
    let reserveDate : String?
    let status : Int?
    let _id : String?
    let company_group : String?
    let expiryDate : String?
    let __v : Int?
    let currProspectId : String?
    let prospect : PROSPECT?
    let unit : QR_UNITS?
    let updateBy : [RESERVE_UPDATE_BY]?
}
struct RESERVE_UPDATE_BY : Codable {
    let _id : String?
    let descp : String?
    let date : String?
    let src : Int?
    let user : RESERVE_USER?
}
struct RESERVE_USER : Codable {
    let _id : String?
    let email : String?
    let userInfo : USERINFO?
}
struct USERINFO : Codable {
    let _id : String?
    let name : String?
}
struct EMPLOYEE_MODEL : Codable {
    let name : String?
    let id : String?
}
struct PROSPECT : Codable {
    let _id : String?
    let userName : String?
    let status : Int?
    let regInfo : String?
}
struct  ALL_PROSPECTS : Codable {
    let status : Int?
    let customers : [CUSTOMER]?
}
struct CUSTOMER : Codable {
    let _id : String?
    let regInfo : REG_INFO?
}
struct REG_INFO : Codable {
    let _id : String?
    let userName : String?
    let prospectId : String?
    let userPhone : String?
    let userEmail : String?
}
struct QR_HISTORY_OUTPUT : Codable {
    let status : Int?
    let data : QR_HISTORY?
}
struct QR_HISTORY : Codable {
    let quickregistrations : QR_REGISTRATIONS?
    let leads : [QR_HISTORY_OPPORTUNITIES_OR_LEADS]?
    let opportunities : [QR_HISTORY_OPPORTUNITIES_OR_LEADS]?
    let externalfailures: [Externalfailure]?
}
// MARK: - Externalfailure
struct Externalfailure: Codable {
    let id, companyGroup: String?
    let reference: Reference?
    let request, response: String?
    let duplicates: [Duplicate]?
    let createdAt: String?
    let v, efsCount: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case companyGroup = "company_group"
        case reference, request, response, duplicates, createdAt
        case v = "__v"
        case efsCount
    }
}
// MARK: - Duplicate
struct Duplicate: Codable {
    let id, userPhone, userName, userEmail: String?
    let project: String?
    let projectName, duplicateMsg, enquirySource, enquiryDate: String?
    let enquirySourceID, oldEnquirySource, oldEnquirySourceID, regInfo: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userPhone, userName, userEmail, project, projectName, duplicateMsg, enquirySource, enquiryDate
        case enquirySourceID = "enquirySourceId"
        case oldEnquirySource
        case oldEnquirySourceID = "oldEnquirySourceId"
        case regInfo
    }
}

struct QR_HISTORY_OPPORTUNITIES_OR_LEADS : Codable {
    
    let _id : String?
    let action : ACTION?
    let actionInfo : QR_ACTION_INFO?
    
    let prevOpportunityStatus : OLD_STATUS?
    let prevLeadStatus : OLD_STATUS?
    
    let block : QR_TOWER?
    let type : QR_TOWER?
    let description : String?
    let status : Int?
    let discountAppliedStatus : Int?
    let registrationDate : String?
    let registrationStatus : Int?
    let regInfo : String?
    let unit : String?
    let project : PROJECT?
    let company_group : String?
    let salesPerson : SALES_PERSON?
    let updateBy : [UpdatedByForProspects]?
    let prospectId : String?
    let leadInfo : String?
    let date : String?
    let callHistory : [CALL_HISTORY]?
    let idleDate: String?
    let externalUrlInfos: [ExternalURLInfo]?
}
struct ExternalURLInfo: Codable {
    let id, urlType: String?
    let url: String?
    let date: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case urlType, url, date
    }
}

struct UpdatedByForProspects : Codable{
    let _id : String?
    let date : String?
    let descp : String?
    let src : Int?
    let user : USER?
    let oldSalesPerson : SALES_PERSON?
    
    enum CodingKeys: String, CodingKey {
        case _id  = "_id"
        case date  = "date"
        case descp  = "descp"
        case src  = "src"
        case user  = "user"
        case oldSalesPerson = "oldSalesPerson"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        date = try values.decodeIfPresent(String.self, forKey: .date)
        
        user = try values.decodeIfPresent(USER.self, forKey: .user)
        src = try values.decodeIfPresent(Int.self, forKey: .src)
        oldSalesPerson = try values.decodeIfPresent(SALES_PERSON.self,forKey : .oldSalesPerson)
        
        // descp = try values.decodeIfPresent(String.self, forKey: .descp)
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .descp) {
            descp = String(value ?? 0)
        } else {
            descp = try values.decodeIfPresent(String.self, forKey: .descp)
        }
        
    }
}

struct QR_ACTION_INFO : Codable {
    
    let projects : [String]?
    let taskStatus : Int?
    let taskName : String?
    let units : [QR_UNITS?]?
    let date : String?
    let driver : String?
    let vehicle : String?
    let comment : String?
    let taskDescription : String?
    let completionDate : String?
    let scheme : String?
    let fileUrl : String?

}
struct OLD_STATUS : Codable {
    let id : String?
    let actionType : Int?
    let status : QR_STATUS?
}
struct QR_STATUS : Codable {
    let id : Int?
    let label : String?
}
struct QR_UNITS : Codable {
    
    let floor : Floor?
    let unitNo : Floor?
    let _id : String?
    let project : PROJECT?
    let tower : QR_TOWER?
    let block : QR_TOWER?
    let type : QR_TOWER?
    let description : String?
    
}
struct QR_TOWER : Codable {
    let _id : String?
    let name : String?
}
struct PROSPECT_BOOK_UNIT_CHECK : Codable{
    let status : Int?
    let err : String?
    let msg : String?
    let result : UNIT_CHECK_RESULT?
}
struct UNIT_CHECK_RESULT : Codable{
    let block : String!
    let project : String!
    let tower : String!
    let unit : String!
    let prospect : UNIT_CHECK_ROSPECT?
}
struct UNIT_CHECK_ROSPECT : Codable{
    let _id : String?
    let discountAppliedStatus : Int?
    let prospectId : String?
    let regInfo : String?
}
struct ProspectCallOutput : Codable{
    
    let status : Int?
    let msg : String?
    
}
struct msg : Codable {
    let msg : String?
}
struct COMMON_OUTPUT : Codable {
    let status : Int?
    let err : String?
    let msg : String?
}
struct RESERVE_UNIT_API_RESULT : Codable {
    let status : Int?
//    let err : ERROR?
}
struct RESERVE_UNIT_API_RESULT_ONE : Codable {
    let status : Int?
//    let err : ERROR?
    let err : String?
}
struct RESERVE_UNIT_API_RESULT_TWO : Codable {
    let status : Int?
    let err : ERROR?
}

struct ERROR : Codable {
    let currProspectId : String?
    let _message : String?
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
    let rate : Double?
    let cost : Double?
    let qty : Double?
    let taxCategory : Int?
//    let tax : BillingInfoTax?
    var selectedDiscountAmt : Double?
    var selectedDiscountPercentage : Double?
    var selectedDiscountOnRate : Double?
    var cellTitleLabelText : String?
    
    enum CodingKeys: String, CodingKey {
        case _id
        case type
        case name
        case agreeValItem
        case rate
        case cost
        case qty
        case taxCategory
        case selectedDiscountAmt
        case selectedDiscountPercentage
        case selectedDiscountOnRate
        case cellTitleLabelText
    }
    
    init(from decoder: Decoder) throws {


        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        agreeValItem = try values.decodeIfPresent(Int.self, forKey: .agreeValItem)
        taxCategory = try values.decodeIfPresent(Int.self, forKey: .taxCategory)
//        qty = try values.decodeIfPresent(Int.self, forKey: .qty)
        cellTitleLabelText = try values.decodeIfPresent(String.self, forKey: .cellTitleLabelText)
        selectedDiscountAmt = try values.decodeIfPresent(Double.self, forKey: .selectedDiscountAmt)
        selectedDiscountPercentage = try values.decodeIfPresent(Double.self, forKey: .selectedDiscountPercentage)
        selectedDiscountOnRate = try values.decodeIfPresent(Double.self, forKey: .selectedDiscountOnRate)
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .qty) {
            qty = Double(value)
        } else {
            qty = try values.decodeIfPresent(Double.self, forKey: .qty)
        }
        if let value = try? values.decodeIfPresent(Int.self, forKey: .rate) {
            rate = Double(value)
        } else {
            rate = try values.decodeIfPresent(Double.self, forKey: .rate)
        }

        if let value = try? values.decodeIfPresent(Int.self, forKey: .cost) {
            cost = Double(value)
        } else {
            cost = try values.decodeIfPresent(Double.self, forKey: .cost)
        }
    }
    
}
struct PREMIUM_BILLING_INFO : Codable{
    let _id : String?
    let name : String?
    let agreeValItem : Int?
    let billings : [BILLING_INFO]?
}
struct BillingInfoTax : Codable {
    let _id : String?
    let taxes: [TaxElement]
}
struct TaxElement : Codable {
    let id: String?
    let variants: [Variant]?
}
struct Variant : Codable {
    let from,name : String?
    let value: Int?
    let code, to, id: String?
}
struct ENQUIRY_SOURCES_OUTPUT : Codable {
    let status : Int?
    let enquirySources : [NEW_ENQUIRY_SOURCES]?
}
struct NEW_ENQUIRY_SOURCES : Codable {
    let _id : String?
    let name : String?
    let displayName : String?
}
struct API_SOURCE_RESULT : Codable {
    let status : Int?
    let ss : [STATUS_SOURCES]?
    let css : [CUSTOMER_STATUS_SOURCES]?
}
struct CUSTOMER_STATUS_SOURCES : Codable{
    let _id : String?
    let sType : Int?
    let label : String?
    let company_group : String?
    let updateBy : [UPDATEDBY]?
    let data : [DATA]?
}
struct DATA : Codable {
    let _id : String?
    let name : String?
    let sub : [SUB_ENQ]?
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
    let sub : [SUB_ENQ]?
}
struct SUB_ENQ : Codable {
    let name : String?
    let _id : String?
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
struct PROSPECT_SUBMIT_RESULT_ERROR_CHECK : Codable {
    let status : Int?
    let err : OUTPUT_ERROR?
    
}
struct OUTPUT_ERROR : Codable {
    let unit : String?
}
struct PROSPECT_SUBMIT_RESULT : Codable {
    let err : PROSPECT_ERROR?
    let status : Int?
    let msg : String?
}
struct PROSPECT_SUBMIT_RESULT_ONE : Codable {
    let err : String?
    let status : Int?
    let msg : String?
}

struct PROSPECT_ERROR : Codable {
    let action : String?
    let actionInfo : String?
    let regInfo : String?
    let registrationDate : String?
    let registrationStatus : String?
    let viewType : String?
    let unit : String?
}
struct PROSPECT_STATUS_CHECK : Codable {
    let status : Int?
}
struct REGISTRATIONS : Codable {
    let status : Int?
    let result : [REGISTRATIONS_RESULT]?
//    let err : String?
}
struct QR_REGISTRATIONS : Codable{
    
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
    let updateBy : [UpdatedByForProspects]?
    let project : PROJECT?
    let salesPerson : SALES_PERSON?
    let leadStatus : String?
    let enquirySourceId : String?
    let unitType : String?
    let minBudget : Int?
    let maxBudget : Int?
    let callHistory : [CALL_HISTORY]?
    let isCommissionApplicable : Bool?
    let idleDate : String?
}
struct CALL_HISTORY : Codable{
    let id, callStatus, starttime, custNo: String?
       let exeNo, endTime: String?
       let audio: String?
       let callId, callType, pulse, answeredtime: String?
       let callBy: String?
}
struct ENQUIRY_SOURCE : Codable {
    var id : String?
    var name : String?
}
struct ProspectByIdOutput : Codable{
    let result : [REGISTRATIONS_RESULT]?
    let status : Int?
    let msg : String?
}
struct REGISTRATIONS_RESULT : Codable {
    
    var _id : String?
    var prospectId : String?
    var dob : String?
    var clientDetails : CLIENT_DETAILS?
    var __v : Int?
    var userName : String?
    var userPhone : String?
    var userPhoneCode : String?
    var alternatePhone : String?
    var alternatePhoneCode : String?
    var currProject : String?
    var userEmail : String?
    var enquirySource : String?
    var enquirySourceId : String?
    var leadStatus : String?
    var company_group : String?
    var uniqueId : String?
    var status : Int?
    var registrationDate : String?
    var comment : String?
    var unitType : String?
    var minBudget : Int?
    var maxBudget : Int?
    var project : PROJECT?
    var salesPerson : SALES_PERSON?
    var updatedBy : UPDATEDBY?
    var discountApplied : Double?
    var action : ACTION?
    var actionInfo :  ACTION_INFO?
    var regInfo : String?
    var viewType : Int?
    var unit : UNITS?
    var type : String?
    var gender : String?
    var isCommissionApplicable : Bool?
    var commissionEntity : CommissionEntity?
    /*
 {"status":1,"result":[{"_id":"5b1932aeb157c54c0e8ce652","status":4,"regInfo":"5b193280b157c54c0e8ce64e","userName":"Vinayak","userPhone":"9743100800","action":{"label":"Request for Discount","id":4},"project":{"_id":"5a64a02cc145c62d977954f0","name":"BJS Mahadevapura"},"discountApplied":0,"registrationDate":"2018-06-07T13:26:24.806Z","salesPerson":{"_id":"59f75afad78bc1486318bfea","email":"admin@prestige.com"},"enquirySource":"Facebook( Social Media )","actionInfo":{"projects":[{"_id":"5a64a02cc145c62d977954f0","name":"BJS Mahadevapura"}],"taskStatus":0,"units":[{"_id":"5a79e0dc7d05380e815df613","description":"11"}]}}]}
 */
    
}
struct CommissionEntity : Codable{
    let id : String?
    let kind : String?
}
struct CLIENT_DETAILS : Codable {
    let companyName : String?
    let designation : String?
    let industry : String?
    let locationOfWork : String?
}
struct ACTION_INFO : Codable {
    let projects : [PROJECT]?
    let taskStatus : Int?
    let units : [UNITS?]?
    let date : String?
    let vehicle :VEHICLE?
    let comment : String?
    let scheme : SCHEME?
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
    let handoverItems : [UnitHandoverItem]?
}
struct SALES_PERSON : Codable {
    let _id : String?
    let email : String?
    let userInfo : USER_INFO?
    let name : String?
    let phone : String?
}
struct USER_INFO : Codable {
    let _id : String?
    let name : String?
    let email : String?
    let phone : String?
    let roles : [String]?
}
struct Q_REGISTRATION_RESULT_ONE : Codable {
    let status : Int?
    let err : String?
}
struct Q_REGISTRATION_RESULT : Codable {
    let status : Int?
    let err : Q_REG_ERR?
}
struct Q_REGISTRATION_RESULT_CHECK : Codable {
    let status : Int?
}
struct Q_REGISTRATION_RESULT_STRING_ERROR : Codable {
    let status : Int?
    let err : String?
}

struct Q_REG_ERR : Codable {
    let id : String?
    let userEmail : String?
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
    var expired : PROSPECT_RESULT?
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
    let value : Double?
    
    var dictionary: [String: Any] {
        return ["uom": uom as? String,
                "value": value as? Double,
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
        value = try values.decodeIfPresent(Double.self, forKey: .value)
        uom = try values.decodeIfPresent(String.self, forKey: .uom)
    }
}
struct OLD_SALES_PERSON : Codable {
    let _id : String?
    let email : String?
}
struct UPDATEDBY : Codable{
    let _id : String?
    let date : String?
    let descp : String?
    let src : Int?
    let user : String?
    let oldSalesPerson : SALES_PERSON?
    
    enum CodingKeys: String, CodingKey {
        case _id  = "_id"
        case date  = "date"
        case descp  = "descp"
        case src  = "src"
        case user  = "user"
        case oldSalesPerson = "oldSalesPerson"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        date = try values.decodeIfPresent(String.self, forKey: .date)
        
        user = try values.decodeIfPresent(String.self, forKey: .user)
        src = try values.decodeIfPresent(Int.self, forKey: .src)
        oldSalesPerson = try values.decodeIfPresent(SALES_PERSON.self,forKey : .oldSalesPerson)
        
        // descp = try values.decodeIfPresent(String.self, forKey: .descp)
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .descp) {
            descp = String(value ?? 0)
        } else {
            descp = try values.decodeIfPresent(String.self, forKey: .descp)
        }
        
    }
}
struct CUSTOM_STAT : Codable{
    
    var stats : [STAT]?
    
    var array : [STAT] {
        return stats!
    }
    
    var nsArray : NSArray {
        return array as NSArray
    }
    
//    enum CodingKeys: String, CodingKey {
//        case stats = "stats"
//    }
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        stats = try values.decodeIfPresent([STAT].self, forKey: .stats)
//    }

}
struct STAT :Codable {
    
    let count : Int?
    let status : Int?
    
    var dictionary: [String: Any] {
        return ["count": count!,
                "status": status!,
        ]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
//    enum CodingKeys: String, CodingKey {
//        case count = "count"
//        case status = "status"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        count = try values.decodeIfPresent(Int.self, forKey: .count)
//        status = try values.decodeIfPresent(Int.self, forKey: .status)
//    }
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
    
    let FAR : Double?
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
    let info : String?
    
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
        case info = "info"
        
    }
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
//        FAR = try values.decodeIfPresent(Int.self, forKey: .FAR)
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .FAR) {
            FAR = Double(value)
        } else {
            FAR = try values.decodeIfPresent(Double.self, forKey: .FAR)
        }

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
        info = try values.decodeIfPresent(String.self, forKey: .info)
        
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
    let otherPremiums : [Premium?]?
    let updatedBy : [UPDATEDBY]?
    let floorPremium : Premium?
    let type : Type?
    let blockingReason: String?
    let bookingform: BOOKING_FORM_DETAILS?
    let landowner : LAND_OWNER?
    let manageUnitStatus : String?
    
    enum CodingKeys: String, CodingKey {
        case _id  = "_id"
        case __v = "--v"
        case project = "project"
        case facing = "facing"
        case clientId = "clientId"
        case tower = "tower"
        case block = "block"
        case description = "description"
        case company_group = "company_group"
        case status = "status"
        case rate = "rate"
        case agreeValItemRate = "agreeValItemRate"
        case salevalue = "salevalue"
        case gst = "gst"
        case totalCost = "totalCost"
        case floor = "floor"
        case unitNo = "unitNo"
        case otherPremiums = "otherPremiums"
        case updatedBy = "updatedBy"
        case floorPremium = "floorPremium"
        case type = "type"
        case blockingReason = "blockingReason"
        case bookingform = "bookingform"
        case landowner = "landowner"
        case manageUnitStatus = "manageUnitStatus"
        
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        __v = try values.decodeIfPresent(Int.self, forKey: .__v)
        project = try values.decodeIfPresent(String.self, forKey: .project)
        facing = try values.decodeIfPresent(String.self, forKey: .facing)
        clientId = try values.decodeIfPresent(String.self, forKey: .clientId)
        tower = try values.decodeIfPresent(String.self, forKey: .tower)
        block = try values.decodeIfPresent(String.self, forKey: .block)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        company_group = try values.decodeIfPresent(String.self, forKey: .company_group)

        status = try values.decodeIfPresent(Int.self, forKey: .status)
        rate = try values.decodeIfPresent(Double.self, forKey: .rate)
        agreeValItemRate = try values.decodeIfPresent(Double.self, forKey: .agreeValItemRate)
        salevalue = try values.decodeIfPresent(Double.self, forKey: .salevalue)
        gst = try values.decodeIfPresent(Double.self, forKey: .gst)
        totalCost = try values.decodeIfPresent(Double.self, forKey: .totalCost)

        
        floor = try values.decodeIfPresent(Floor.self, forKey: .floor)
        unitNo = try values.decodeIfPresent(Floor.self, forKey: .unitNo)
        otherPremiums = try values.decodeIfPresent([Premium?].self, forKey: .otherPremiums)
        updatedBy = try values.decodeIfPresent([UPDATEDBY].self, forKey: .updatedBy)
        floorPremium = try values.decodeIfPresent(Premium.self, forKey: .floorPremium)
        
        type = try values.decodeIfPresent(Type.self, forKey: .type)
        blockingReason = try values.decodeIfPresent(String.self, forKey: .blockingReason)
        bookingform = try values.decodeIfPresent(BOOKING_FORM_DETAILS.self, forKey: .bookingform)
        landowner = try values.decodeIfPresent(LAND_OWNER.self, forKey: .landowner)
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .manageUnitStatus) {
            manageUnitStatus = String(value)
       } else {
            manageUnitStatus = try values.decodeIfPresent(String.self, forKey: .manageUnitStatus)
       }

    }


}
struct LAND_OWNER : Codable {
    let _id : String?
    let name : String?
    let address : String?
    let contactPerson : String?
    let phoneNo : String?
    let shortName : String?
    let email : String?
}
struct OTHER_PREMIUMS : Codable {
    let otherPremiums : [Premium]?
    
    
}
struct Floor_Plan : Codable{
    var url : String?
    var _id : String?
    
    var dictionary: [String: String] {
        return ["_id": _id!,
                "url":url!,
        ]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
    enum CodingKeys: String, CodingKey {
        case _id  = "_id"
        case url  = "url"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        url = try values.decodeIfPresent(String.self, forKey: .url)
    }

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
    var _id : String?
    var customer : CLIENT_CUSTOMER?
    var client : Client
//    let checkList :
}
struct UnitClient: Codable {
    let checklist: [Checklist]?
    let id, client: String?
    let customer: CLIENT_CUSTOMER?
    let share: Int?

    enum CodingKeys: String, CodingKey {
        case checklist
        case id = "_id"
        case client, customer, share
    }
}
struct Checklist: Codable {
    let id, name: String
    let status: Bool

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, status
    }
}
struct CLIENT_CUSTOMER : Codable{
    let bookings : [String]?
    let _id : String?
    let name : String?
    let phone : Int?
    let email : String?
    let customerId : String?
    let company_group : String?
    let updatedBy : [UPDATEDBY]?
    let clientId : String?
    let __v : Int?
    let phoneCode: String?
}
struct Client : Codable {
    var _id : String?
    var name : String?
    var phone : String?
    var email : String?
    var bookingId : String?
    var company_group : String?
    var customer : String?
    var updateBy : [UPDATEDBY]?
    var phoneCode : String?
    var photo : String?
    var panCard : String?
    var panUrl : String?
    var aadhar : String?
    var aadharUrl : String?
    
//    var parameters: [String: Any] {
//        return [
//            "_id" : _id ?? "",
//            "name" : name ?? "",
//            "phone" : phone ?? "",
//            "email" : email ?? "",
//            "bookingId" : bookingId ?? "",
//            "company_group" : company_group ?? "",
//            "customer" : customer ?? "",
//            "phoneCode" : phoneCode ?? "",
//            "photo" : photo ?? "",
//            "panCard" : panCard ?? "",
//            "panUrl" : panUrl ?? "",
//            "aadhar" : aadhar ?? "",
//            "aadharUrl" : aadharUrl ?? ""
//        ]
//    }

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
    let updateBy: [UnitUpdateBy]?
//    let actions: [JSONAny]
    let status: Int?
    let clients: [ClientList]?
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
struct Type11 : Codable{
    
    let _id : String?
    let name : String?
    let superBuiltUpArea : Area?
    let carpetArea : Area?
    let balconyArea : Area?
    let carParks : [CarParks]?
    let billingElementForPricing : [BillingElementForPricing]?
    let floorPlan : [Floor_Plan]?
    
//    var dictionary: [String: Any] {
//        return ["_id": _id!,
//                "name": name!,
//                "superBuiltUpArea": superBuiltUpArea!,
//                "carpetArea":carpetArea!,
//                "balconyArea":balconyArea!,
//                "carParks" : carParks!,
//                "billingElementForPricing" : billingElementForPricing!,
//                "floorPlan":floorPlan!,
//        ]
//    }
//    var nsDictionary: NSDictionary {
//        return dictionary as NSDictionary
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case _id  = "_id"
//        case name =  "name"
//        case superBuiltUpArea = "superBuiltUpArea"
//        case carpetArea = "carpetArea"
//        case balconyArea = "balconyArea"
//        case carParks = "carParks"
//        case billingElementForPricing = "billingElementForPricing"
//        case floorPlan = "floorPlan"
//
//    }
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        _id = try values.decodeIfPresent(String.self, forKey: ._id)
//        name = try values.decodeIfPresent(String.self, forKey: .name)
//        superBuiltUpArea = try values.decodeIfPresent(Area.self, forKey: .superBuiltUpArea)
//        carpetArea = try values.decodeIfPresent(Area.self, forKey: .carpetArea)
//        balconyArea = try values.decodeIfPresent(Area.self, forKey: .balconyArea)
//        carParks = try values.decodeIfPresent([CarParks].self, forKey: .carParks)
//        billingElementForPricing = try values.decodeIfPresent([BillingElementForPricing].self, forKey: .billingElementForPricing)
//        floorPlan = try values.decodeIfPresent([Floor_Plan].self, forKey: .floorPlan)
//    }
    
}
struct Type : Codable{
    
    let _id : String?
    let name : String?
    let superBuiltUpArea : Area?
    let carpetArea : Area?
    let balconyArea : Area?
    let schemes : [String]?
    let carParks : [CarParks]?
    let billingElementForPricing : [BillingElementForPricing]?
    let floorPlan : [Floor_Plan]?
    let bathRooms : Double?
    let bedRooms : Double?
    
    var dictionary: [String: Any] {
        return ["_id": _id!,
                "name": name!,
                "superBuiltUpArea": superBuiltUpArea!,
                "carpetArea":carpetArea!,
                "balconyArea":balconyArea!,
                "carParks" : carParks!,
                "billingElementForPricing" : billingElementForPricing!,
                "floorPlan":floorPlan!,
                "schemes" : schemes as Any
        ]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
    enum CodingKeys: String, CodingKey {
        case _id  = "_id"
        case name =  "name"
        case superBuiltUpArea = "superBuiltUpArea"
        case carpetArea = "carpetArea"
        case balconyArea = "balconyArea"
        case carParks = "carParks"
        case billingElementForPricing = "billingElementForPricing"
        case floorPlan = "floorPlan"
        case schemes = "schemes"
        case bedRooms = "bedRooms"
        case bathRooms = "bathRooms"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        superBuiltUpArea = try values.decodeIfPresent(Area.self, forKey: .superBuiltUpArea)
        carpetArea = try values.decodeIfPresent(Area.self, forKey: .carpetArea)
        balconyArea = try values.decodeIfPresent(Area.self, forKey: .balconyArea)
        carParks = try values.decodeIfPresent([CarParks].self, forKey: .carParks)
        billingElementForPricing = try values.decodeIfPresent([BillingElementForPricing].self, forKey: .billingElementForPricing)
        floorPlan = try values.decodeIfPresent([Floor_Plan].self, forKey: .floorPlan)
        schemes = try values.decodeIfPresent([String].self, forKey: .schemes)
        
        if let value = try? values.decodeIfPresent(Int.self, forKey: .bedRooms) {
           bedRooms = Double(value)
       } else {
           bedRooms = try values.decodeIfPresent(Double.self, forKey: .bedRooms)
       }
//        bedRooms = try values.decodeIfPresent(Int.self, forKey: .bedRooms)
        
         if let value = try? values.decodeIfPresent(Int.self, forKey: .bathRooms) {
            bathRooms = Double(value)
        } else {
            bathRooms = try values.decodeIfPresent(Double.self, forKey: .bathRooms)
        }

        
//        bathRooms = try values.decodeIfPresent(Int.self, forKey: .bathRooms)
    }

}
struct BillingElementForPricing : Codable {
    let _id : String?
    let agreeValItem : Int?
    
    var dictionary: [String: Any] {
        return ["_id": _id!,
                "agreeValItem": agreeValItem!,
        ]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
    enum CodingKeys: String, CodingKey {
        case _id  = "_id"
        case agreeValItem  = "agreeValItem"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        agreeValItem = try values.decodeIfPresent(Int.self, forKey: .agreeValItem)
    }
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
struct CAR_PARKS_FOR_DB : Codable {
    let carPars : [CarParks]?
    
    var dictionary: [String: Any] {
        return ["carPars": carPars!]
    }
    enum CodingKeys: String, CodingKey {
        case carPars  = "carPars"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        carPars = try values.decodeIfPresent([CarParks].self, forKey: .carPars)
    }
}
struct CarParks : Codable{
    let _id : String?
    let cType : String?
    let count : Int?
    
    var dictionary: [String: Any] {
        return ["_id": _id!,
                "cType": cType!,
                "count": count!,
        ]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
    enum CodingKeys: String, CodingKey {
        case _id  = "_id"
        case cType  = "cType"
        case count  = "count"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        count = try values.decodeIfPresent(Int.self, forKey: .count)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        cType = try values.decodeIfPresent(String.self, forKey: .cType)
    }

    
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
    
    var dictionary : [String : String]{
        return ["_id" : _id!,"name" : name!,]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
    enum CodingKeys: String, CodingKey {
        case _id  = "_id"
        case name  = "name"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
    }

}
struct Floor : Codable {
    
    let index : Int?
    let displayName : String?
    
    var dictionary: [String: Any] {
        return ["index": (index != nil) ? index : -1,
                "displayName": displayName!,
        ]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
    enum CodingKeys: String, CodingKey {
        case index  = "index"
        case displayName  = "displayName"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        index = try values.decodeIfPresent(Int.self, forKey: .index)
        displayName = try values.decodeIfPresent(String.self, forKey: .displayName)
    }

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
    let images : [String]?
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


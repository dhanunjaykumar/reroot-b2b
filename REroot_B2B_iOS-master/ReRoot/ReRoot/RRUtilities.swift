//
//  RRUtilities.swift
//  ReRoot
//
//  Created by Dhanunjay on 03/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Foundation
import Reachability
import KeychainAccess
import SideMenu
import PKHUD
import FloatingPanel
import AWSS3
import FirebaseCrashlytics

//prospectStatusesArray.add("No Response")
//prospectStatusesArray.add("Not Rechable")
//prospectStatusesArray.add("Call Complete")
//prospectStatusesArray.add("Not Interested")


protocol Singleton: class {
    static var sharedInstance: Self { get }
}
enum Erro_Handler : Error{
    case FoundReserveError(String)
}
enum CommissionUserType : Int{
    case AGENT = -1
    case TYPE_USER = 1
    case TYPE_CUSTOMER = 2
    case TYPE_OLD_CUSTOMER = 3
}
enum DISCOUNT_REQUEST_STATES : Int{
    case DISCOUNT_APPLIED = 1
    case DISCOUNT_PENDING = 2
    case DISCOUNT_REJECTED = 3
}
enum USER_ROLE_TYPE : Int{
    case ADMIN = 0
    case BUSINESS_ADMIN = 1
    case EMPLOYEE = 2
}
enum USER_PERMISSION_STATUS : Int{
    case STATUS_ACTIVE = 1
    case STATUS_INACTIVE = 2
}
enum SYNC_STATE : Int{
    case SYNC_CLEAN = 0
    case SYNC_DIRTY = 1
}
enum S3_BUCKET_PATHS : String {
    case HANDOVER_BUCKET = "/Handover/complaints"
    case BOOKING_FORM_BUCKET = ""
    case RECEIPTS = "/Receipts"
}
enum HANDOVER_STATUS_TEXT : String{
    case Handover_Review = "Handover Review"
    case Internal_Review = "Internal Review"
    case Internal_Snags = "Internal Snags"
    case Customer_Review = "Customer Review"
    case Customer_Snags = "Customer Snags"
    case Final_Possession = "Final Possession"
}
enum HAND_OVER_STATUS : Int{
    case HANDOVER_REVIEW = 0
    case INTERNAL_REVIEW = 1
    case INTERNAL_SNAGS = 2
    case CUSTOMER_REVIEW = 3
    case CUSTOMER_SNGS = 4
    case FINAL_POSSESSION = 5
}
enum HAND_OVER_ITEM_STATE : Int {
    case STATUS_COMPLETED = 1
    case STATUS_INCOMPLETE = 0
}
enum NOTIFICATION_TYPES : String{

    case DISCOUNT_REQUEST = "Unit Discount Request"
    case APPROVED_DISCOUNT_REQUEST = "Unit Discount Approved"
    case REJECTED_DISCOUNT_REQUEST = "Unit Discount Rejected"
    case CANCEL_REQUEST = "Unit Cancellation Request"
    case TRANSFER_REQUEST = "Unit Transfer Request"
    case ASSIGNMENT_REQUEST = "Unit Assignment Request"
    case APPROVED_CANCEL_REQUEST = "Unit Cancel Request Approved"
    case REJECTED_CANCEL_REQUEST = "Unit Cancel Request Rejected"
    case APPROVED_TRANSFER_REQUEST = "Unit Transfer Request Approved"
    case REJECTED_TRANSFER_REQUEST = "Unit Transfer Request Rejected"
    case APPROVED_ASSIGNMENT_REQUEST = "Unit Assignment Request Approved"
    case REJECTED_ASSIGNMENT_REQUEST = "Unit Assignment Request Rejected"
    case PROSPECT_CALL_REMINDER = "Reminder: Prospect Call"
    case PROSPECT_ASSIGNED = "Prospects Assigned"
    case CALL_UPDATE = "call update"
    case DISCOUNT_APPROVAL = "Approval Reminder"
    
    //call update

}
struct URL_DICT  {
    let url : String?
    let urlType : String?
}
enum PLAN_TYPE : Int {
    case FLOOR_PLAN = 1
    case TOWER_PLAN = 2
    case HAND_OVER_ITEM = 3
}
enum APPROVAL_STATUS : Int{
    case PENDING = 0
    case APPROVED = 1
    case REJECTED = 2
    case IN_PIPELINE = 5
    case INVALIDATED = 6
}
enum APPROVAL_TYPES : Int{
    case DISCOUNT_APPROVAL = 1
    case CANCEL_UNIT_APPROVAL = 2
    case TRANSFER_UNIT_APPROVAL = 3
    case ASSIGN_UNIT_APPROVAL = 4
    case BOOKING_FORM_APPROVAL = 5
    case AGREEMENTS_PRINT_APPROVAL = 6
    case CREDIT_NOTES_APPROVAL = 7
    case DEBIT_NOTES_APPROVAL = 8
}
enum VIEW_TYPE : Int{
    case REGISTRATIONS  = 1
    case LEADS = 2
    case OPPORTUNITIES = 3
}
enum SCHEDULE_CALL_ACTIONS : Int {
    case NO_RESPONSE = 1
    case NOT_REACHABLE = 2
    case CALL_COMPLETE = 3
    case NOT_INTERESTED = 4
}
enum SITE_VISIT_ACTIONS_STRING : String{
    case GOOD = "Good"
    case SATISFIED = "Satisfactory"
    case DISSATISFIED = "Dissatisfied"
    case NOT_VISITED = "Not Visited"
    case NOT_INTERESTED = "Not Interested"
}
enum SCHEDULE_CALL_ACTIONS_STRING : String{
    case NO_RESPONSE = "No Response"
    case NOT_REACHABLE = "Not Rechable"
    case CALL_COMPLETE = "Call Complete"
    case NOT_INTERESTED = "Not Interested"
}
enum OTHER_TASK_ACTIONS_STRING : String{
    case COMPLETED = "Completed"
    case ON_HOLD = "On Hold"
    case NOT_INTERESTED = "Not Interested"
}
enum ACTION_TYPE : Int
{
    case SCHEDULE_CALL = 1
    case SEND_OFFER = 2
    case SITE_VISIT = 3
    case DISCOUNT_REQUEST = 4
    case NEW_TASK = 5
}
enum ACTION_TYPE_STRING : String {
    case SCHEDULE_CALL = "Schedule Call"
    case SEND_OFFER = "Send Offer"
    case SITE_VISTI = "Schedule Site Visit"
    case DISCOUNT_REQUEST = "Request for Discount"
    case NEW_TASK = "Add New Task"  ////CHECK THIS
}
enum BLOCK_STATUS_AS_STRING : String {
    case VACANT = "Vacant"
    case BOOKED =  "Booked"
    case SOLD = "Sold"
    case RESERVED = "Reserved"
    case BLOCKED = "Blocked"
    case HANDEDOVER = "HandedOver"
}
enum UNIT_STATUS : Int { //Unit Status 0 - Vacant, 1 - Booked, 2- Sold, 3 - Reserved, 4 - Blocked, 5 - Handed Over
    case VACANT = 0
    case BOOKED = 1
    case SOLD = 2
    case RESERVED = 3
    case BLOCKED = 4
    case HANDEDOVER = 5
}
enum ALLOCATION_STATUS : Int{
    case ALLOCATED = 1
    case NOT_ALLOCATED = 2
    case PARTIALLY_ALLOCATED = 3
}
enum RECEIPT_ENTRY_TYPE : String{
    case BOOKED_SOLD_RECEIPT = "1"
    case RESERVED_RECEIPT = "2"
}
enum PROSPECTS_TYPES : Int {
    case REGISTRATIONS
    case LEADS
    case OPPORTUNITIES
}
enum TOWER_TYPE : Int{
    case MULTI_UNIT = 0
    case SINGLE_UNIT = 1
    case VILLA = 2
}
enum S3_CONSTANTS : String{
    case HANDOVER_BUCKET = "buildez/Handover/complaints"
    case S3_URL = "https://s3.ap-south-1.amazonaws.com"
    case REGION = "ap-south-1"
    case IMAGE_COMPRESSION_RATIO = "2" //1 == originalImage, 2 = 50% compression, 4=25% compress
}
class HalfFloatingPanelLayout: FloatingPanelLayout {
    
    weak var parentVC: UIViewController!
    
    var leftConstraint: NSLayoutConstraint!
    var rightConstraint: NSLayoutConstraint!
    
    let topPadding: CGFloat = 17.0
    let sideMargin: CGFloat = 16.0
        
    init(parent: UIViewController) {
        parentVC = parent
    }

    public var initialPosition: FloatingPanelPosition {
        return .half
    }
    var supportedPositions: Set<FloatingPanelPosition> {
        return [.half]
    }
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
//        case .full: return 16.0 // A top inset from safe area
        case .half: return 245.0 // A bottom inset from the safe area
//        case .tip: return 44.0 // A bottom inset from the safe area
        default: return nil // Or `case .hidden: return nil`
        }
    }
    func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.3
    }
    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        if #available(iOS 11.0, *) {
            leftConstraint = surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0)
            rightConstraint = surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0)
        } else {
            leftConstraint = surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0)
            rightConstraint = surfaceView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0)
        }
        return [ leftConstraint, rightConstraint ]
    }
}

class FullScreenCustomPanelLayout: FloatingPanelFullScreenLayout {
    weak var parentVC: UIViewController!
    
    var leftConstraint: NSLayoutConstraint!
    var rightConstraint: NSLayoutConstraint!
    
    let topPadding: CGFloat = 17.0
    let sideMargin: CGFloat = 16.0
    
    init(parent: UIViewController) {
        parentVC = parent
    }
    
    var bottomInteractionBuffer: CGFloat = 44.0
    
    var initialPosition: FloatingPanelPosition {
        return .half
    }
    var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .half]
    }
    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 0.0
        case .half: return 261.0 //+ parentVC.layoutInsets.bottom
        //        case .tip: return 88.0 //+ parentVC.layoutInsets.bottom
        default: return nil
        }
    }
    func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.3
    }
    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        if #available(iOS 11.0, *) {
            leftConstraint = surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0)
            rightConstraint = surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0)
        } else {
            leftConstraint = surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0)
            rightConstraint = surfaceView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0)
        }
        return [ leftConstraint, rightConstraint ]
    }
}
class CustomPanelLayout: FloatingPanelFullScreenLayout {
    weak var parentVC: UIViewController!
    
    var leftConstraint: NSLayoutConstraint!
    var rightConstraint: NSLayoutConstraint!
    
    let topPadding: CGFloat = 17.0
    let sideMargin: CGFloat = 16.0
    
    init(parent: UIViewController) {
        parentVC = parent
    }
    
    var bottomInteractionBuffer: CGFloat = 44.0
    
    var initialPosition: FloatingPanelPosition {
        return .half
    }
    var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .half]
    }
    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 40.0
        case .half: return 261.0 //+ parentVC.layoutInsets.bottom
//        case .tip: return 88.0 //+ parentVC.layoutInsets.bottom
        default: return nil
        }
    }
    func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.3
    }
    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        if #available(iOS 11.0, *) {
            leftConstraint = surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0)
            rightConstraint = surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0)
        } else {
            leftConstraint = surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0)
            rightConstraint = surfaceView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0)
        }
        return [ leftConstraint, rightConstraint ]
    }
}
final class RRUtilities: Singleton {

    static var sharedInstance = RRUtilities()
    
    var isNetworkAvailable : Bool = false
    var notInterestedSources : STATUS_SOURCES!
    var drivers : [DRIVER] = []
    var vehicles : [VEHICLE] = []
    
    var prospectsStartDate : String!
    var prospectsEndDate : String!
    
    var prospectsSDate : Date!
    var prospectsEDate : Date!

    var customBookingFormSetUp : BOOKING_FORM_SETUP!
    var defaultBookingFormSetUp : BOOKING_FORM_SETUP!

    let keychain =  Keychain(service: "com.reroot.reroot-token", accessGroup: "74J9G92CMX.rerootKeyChain")
    //Keychain(service: "com.reroot.reroot-token")
    
    
    let model = DBModel()
    
    func getCurrencySymbol(forCurrencyCode code: String) -> String? {
        let locale = NSLocale(localeIdentifier: code)
        if locale.displayName(forKey: .currencySymbol, value: code) == code {
            let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: code)
        }
        return locale.displayName(forKey: .currencySymbol, value: code)
    }
    func getNetworkStatus() -> Bool {
        
        return isNetworkAvailable
        
    }
    func showLoginScreenOnAuthFailure(navigationController : UINavigationController?){
        HUD.flash(.label("Session Expires. Please login again"), delay: 1.0)
        //perform logout
        UserDefaults.standard.set(nil, forKey: "Cookie")
        UserDefaults.standard.synchronize()
        keychain["Cookie"] = nil
        navigationController?.popToRootViewController(animated: true)
        // Throw notificationt to show login view
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.SHOWLOGINSCREEN), object: nil)
        
    }
    
    func isValidEmail(emailID:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
//        let emailRegEx = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
//            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
//            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
//            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
//            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
//            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
//        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailID)
    }
    func getIndexFromHOStatus(statusStr : String)->Int{

        switch statusStr {
        case HANDOVER_STATUS_TEXT.Handover_Review.rawValue:
            return HAND_OVER_STATUS.HANDOVER_REVIEW.rawValue
        case HANDOVER_STATUS_TEXT.Internal_Review.rawValue:
            return HAND_OVER_STATUS.INTERNAL_REVIEW.rawValue
        case HANDOVER_STATUS_TEXT.Internal_Snags.rawValue:
            return HAND_OVER_STATUS.INTERNAL_SNAGS.rawValue
        case HANDOVER_STATUS_TEXT.Customer_Review.rawValue:
            return HAND_OVER_STATUS.CUSTOMER_REVIEW.rawValue
        case HANDOVER_STATUS_TEXT.Customer_Snags.rawValue:
            return HAND_OVER_STATUS.CUSTOMER_SNGS.rawValue
        case HANDOVER_STATUS_TEXT.Final_Possession.rawValue:
            return HAND_OVER_STATUS.FINAL_POSSESSION.rawValue
        default:
            break
        }
        return -1

    }
    func getHOStatusAsPerStatusForCollectionView(stattusIndex : Int)-> Dictionary<String, Any>{
        
        switch stattusIndex {
        case 0:
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR_FOR_COllECTIONVIEW.Handover_Review
            blockStatusDict["statusString"] = "Handover Review"
            blockStatusDict["shortCut"] = "HR"
            return blockStatusDict
        case 1 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR_FOR_COllECTIONVIEW.Internal_Review
            blockStatusDict["statusString"] = "Internal Review"
            blockStatusDict["shortCut"] = "IR"
            return blockStatusDict
        case 2 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR_FOR_COllECTIONVIEW.Internal_Snags
            blockStatusDict["statusString"] = "Internal Snags"
            blockStatusDict["shortCut"] = "IS"
            return blockStatusDict
        case 5 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR_FOR_COllECTIONVIEW.Final_Possession
            blockStatusDict["statusString"] = "Final Possession"
            blockStatusDict["shortCut"] = "FP"
            return blockStatusDict
        case 3 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR_FOR_COllECTIONVIEW.Customer_Review
            blockStatusDict["statusString"] = "Customer Review"
            blockStatusDict["shortCut"] = "CR"
            return blockStatusDict
        case 4 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR_FOR_COllECTIONVIEW.Customer_Snags
            blockStatusDict["statusString"] = "Customer Snags"
            blockStatusDict["shortCut"] = "CS"
            return blockStatusDict
        default:
            break
        }
        return [:]
        
    }
    func getHOStatusAsPerStatus(stattusIndex : Int)-> Dictionary<String, Any>{
        
        switch stattusIndex {
        case 0:
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR.Handover_Review
            blockStatusDict["statusString"] = "Handover Review"
            blockStatusDict["shortCut"] = "HR"
            return blockStatusDict
        case 1 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR.Internal_Review
            blockStatusDict["statusString"] = "Internal Review"
            blockStatusDict["shortCut"] = "IR"
            return blockStatusDict
        case 2 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR.Internal_Snags
            blockStatusDict["statusString"] = "Internal Snags"
            blockStatusDict["shortCut"] = "IS"
            return blockStatusDict
        case 5 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR.Final_Possession
            blockStatusDict["statusString"] = "Final Possession"
            blockStatusDict["shortCut"] = "FP"
            return blockStatusDict
        case 3 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR.Customer_Review
            blockStatusDict["statusString"] = "Customer Review"
            blockStatusDict["shortCut"] = "CR"
            return blockStatusDict
        case 4 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR.Customer_Snags
            blockStatusDict["statusString"] = "Customer Snags"
            blockStatusDict["shortCut"] = "CS"
            return blockStatusDict
        default:
            break
        }
        return [:]

    }
    func getHOStatusColorAsPerStatusString(statusString : String)-> Dictionary<String, Any>{
        
        switch statusString {
        case "Handover Review":
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR.Handover_Review
            blockStatusDict["statusString"] = "Handover Review"
            blockStatusDict["index"] = HAND_OVER_STATUS.HANDOVER_REVIEW.rawValue
            return blockStatusDict
        case "Internal Review" :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR.Internal_Review
            blockStatusDict["statusString"] = "Internal Review"
            blockStatusDict["index"] = HAND_OVER_STATUS.INTERNAL_REVIEW.rawValue
            return blockStatusDict
        case "Internal Snags" :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR.Internal_Snags
            blockStatusDict["statusString"] = "Internal Snags"
            blockStatusDict["index"] = HAND_OVER_STATUS.INTERNAL_SNAGS.rawValue
            return blockStatusDict
        case "Customer Review" :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR.Customer_Review
            blockStatusDict["statusString"] = "Customer Review"
            blockStatusDict["index"] = HAND_OVER_STATUS.CUSTOMER_REVIEW.rawValue
            return blockStatusDict
        case "Customer Snags" :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR.Customer_Snags
            blockStatusDict["statusString"] = "Customer Snags"
            blockStatusDict["index"] = HAND_OVER_STATUS.CUSTOMER_SNGS.rawValue
            return blockStatusDict
        case "Final Possession" :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.HAND_OVER_STATUS_COLOR.Final_Possession
            blockStatusDict["statusString"] = "Final Possession"
            blockStatusDict["index"] = HAND_OVER_STATUS.FINAL_POSSESSION.rawValue
            return blockStatusDict
        default:
            break
        }
        return [:]
    }
    func getNextStatusFromCurrentStatus(currentStatus : Int) -> UNIT_STATUS{
        
        switch currentStatus {
        case 0:
            return UNIT_STATUS.BOOKED
        case 1 :
            return UNIT_STATUS.SOLD
        case 2 :
           return UNIT_STATUS.RESERVED
        case 3 :
             return UNIT_STATUS.BLOCKED
        case 4 :
            return UNIT_STATUS.HANDEDOVER
        case 5 :
           return UNIT_STATUS.HANDEDOVER
        default:
            break
        }
        
        return UNIT_STATUS.BLOCKED
    }
    func getColorAccordingToStatusString(statusString : String) -> Dictionary<String, Any>{
        
        switch statusString {
        case "Vacant":
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR.vacant
            blockStatusDict["statusString"] = "Vacant"
            return blockStatusDict
        case "Booked" :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR.booked
            blockStatusDict["statusString"] = "Booked"
            return blockStatusDict
        case "Sold" :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR.sold
            blockStatusDict["statusString"] = "Sold"
            return blockStatusDict
        case "Reserve" :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR.reserved
            blockStatusDict["statusString"] = "Reserve"
            return blockStatusDict
        case "Block" :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR.blocked
            blockStatusDict["statusString"] = "Block"
            return blockStatusDict
        case "Handed Over" :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.BOLCK_STATUS_COLOR.handedOver
            blockStatusDict["statusString"] = "Handed Over"
            return blockStatusDict
        default:
            break
        }
        return [:]
    }
    func getColorAccordingToUnitStatusForCollectionView(status : Int) -> Dictionary<String, Any>{
        
        switch status {
        case 0:
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR_FOR_COLLECTIONVIEW.vacant
            blockStatusDict["statusString"] = "Vacant"
            return blockStatusDict
        case 1 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR_FOR_COLLECTIONVIEW.booked
            blockStatusDict["statusString"] = "Booked"
            return blockStatusDict
        case 2 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR_FOR_COLLECTIONVIEW.sold
            blockStatusDict["statusString"] = "Sold"
            return blockStatusDict
        case 3 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR_FOR_COLLECTIONVIEW.reserved
            blockStatusDict["statusString"] = "Reserved"
            return blockStatusDict
        case 4 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR_FOR_COLLECTIONVIEW.blocked
            blockStatusDict["statusString"] = "Blocked"
            return blockStatusDict
        case 5 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR_FOR_COLLECTIONVIEW.handedOver
            blockStatusDict["statusString"] = "Handed Over"
            return blockStatusDict
        default:
            break
        }
        
        return [:]
    }
    func getColorAccordingToUnitStatus(status : Int) -> Dictionary<String, Any>{
        
        switch status {
        case 0:
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR.vacant
            blockStatusDict["statusString"] = "Vacant"
            return blockStatusDict
        case 1 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR.booked
            blockStatusDict["statusString"] = "Booked"
            return blockStatusDict
        case 2 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR.sold
            blockStatusDict["statusString"] = "Sold"
            return blockStatusDict
        case 3 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR.reserved
            blockStatusDict["statusString"] = "Reserved"
            return blockStatusDict
        case 4 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.UNIT_STATUS_COLOR.blocked
            blockStatusDict["statusString"] = "Blocked"
            return blockStatusDict
        case 5 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.BOLCK_STATUS_COLOR.handedOver
            blockStatusDict["statusString"] = "Handed Over"
            return blockStatusDict
        default:
            break
        }
        
        return [:]
    }
    func getColorAccordingToStatusNumber(status : Int) -> Dictionary<String, Any>{
                
        switch status {
        case 0:
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.BOLCK_STATUS_COLOR.vacant
            blockStatusDict["statusString"] = "Vacant"
            return blockStatusDict
        case 1 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.BOLCK_STATUS_COLOR.booked
            blockStatusDict["statusString"] = "Booked"
            return blockStatusDict
        case 2 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.BOLCK_STATUS_COLOR.sold
            blockStatusDict["statusString"] = "Sold"
            return blockStatusDict
        case 3 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.BOLCK_STATUS_COLOR.reserved
            blockStatusDict["statusString"] = "Reserved"
            return blockStatusDict
        case 4 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.BOLCK_STATUS_COLOR.blocked
            blockStatusDict["statusString"] = "Blocked"
            return blockStatusDict
        case 5 :
            var blockStatusDict : Dictionary<String,Any> = [:]
            blockStatusDict["color"] = UIColor.BOLCK_STATUS_COLOR.handedOver
            blockStatusDict["statusString"] = "Handed Over"
            return blockStatusDict
        default:
            break
        }
        
        return [:]
    }
    func getRedableDayDateFromString(dateStr : String) -> String?{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatter.date(from: dateStr)
        
        if(date == nil){
            return nil
        }
        let tempStr = self.convertDateFormate(date: date!, dateFormat: "LLLL, yyyy")
        
//        print(tempStr)
        
        return tempStr
    }
    func getDateFromDate(date : Date)->String{
        let tempStr = self.convertDateFormate(date: date, dateFormat: "LLLL, yyyy")
        return tempStr
    }
    func getDateAndTimeFromDateStr(dateStr : String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: dateStr)
//        dateFormatter.dateFormat = "dd-MM-yyyy"

        let tempStr = self.convertDateFormate(date: date!, dateFormat: "MMM, yyyy hh:mm a")
        
        return tempStr
    }
//    func getDateStringFromServerDate(dateStr : String)->String{
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = .current
//        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        let date = dateFormatter.date(from: dateStr)
//
//        let tempStr = self.convertDateFormate(date: date!, dateFormat: "MMM, yyyy")
//
//        return tempStr
//
//    }
    func getProspectDateStringFromServerDate(dateStr : String)->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let date = dateFormatter.date(from: dateStr)

        let tempStr = self.convertDateFormate(date: date!, dateFormat: "MMM, yyyy")
        
        return tempStr
        
    }
    func getProspectDateStringFromSelectedDate(selectedDate : Date)->String{

        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
//        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        let date = dateFormatter.date(from: dateStr)

        let tempStr = self.convertDateFormate(date: selectedDate, dateFormat: "MMM, yyyy")
        
        return tempStr

        
    }

    class var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            // with notch: 44.0 on iPhone X, XS, XS Max, XR.
            // without notch: 20.0 on iPhone 8 on iOS 12+.
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
    func getDateStringFromServerDateStr(dateStr : String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatter.date(from: dateStr)
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        _ = self.convertDateFormate(date: date!, dateFormat: "MM yyyy")
        
        let tempStr = dateFormatter.string(from: date!)
//        print(tempStr)
        
        return tempStr
        
    }
    func getDateWithEnglishWord(dateStr : String)-> String{
     
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatter.date(from: dateStr)
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let temper = self.convertDateFormate(date: date!, dateFormat: "LLLL yyyy")
        
//        let tempStr = dateFormatter.string(from: date!)
//        print(tempStr)
        
        return temper

    }
    func getServerDateStringFromDate(date : Date) -> String{
        
//        "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatter.string(from: date) +  "T00:00:00.000Z"
//        print(date)
        return date

    }
    func prospectDateInGMTFormat(date : Date , isFromDate : Bool)->String{
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier:"GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        // *** Create date ***

        // *** create calendar object ***
        let calendar = Calendar.current
        
        var dateComps = calendar.dateComponents([.year, .month, .day], from: date)
        if(isFromDate){
            dateComps.hour = 00
            dateComps.minute = 00
            dateComps.second = 00
        }
        else{
            dateComps.hour = 23
            dateComps.minute = 59
            dateComps.second = 59
        }

        let tempLocalDate = calendar.date(from: dateComps)
        print(tempLocalDate ?? "")
        
        var tempLocalDStr = dateFormatter.string(from: tempLocalDate!)
        print(tempLocalDStr)
        
        if(isFromDate){
            tempLocalDStr = tempLocalDStr + ".000Z"
        }
        else{
            tempLocalDStr = tempLocalDStr + ".999Z"
        }
        print(tempLocalDStr)

        return tempLocalDStr

    }
    func getProspectDateFormat(date : Date,isFromDate : Bool)->String{
        
        let dateFormatter = DateFormatter()
        
        if(isFromDate){
            dateFormatter.dateFormat =  "yyyy-MM-dd'T'18:30:00"
        }
        else{
            dateFormatter.dateFormat =  "yyyy-MM-dd'T'18:29:59"
        }
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        var tempDate = dateFormatter.string(from: date)
        
        let actualDate = dateFormatter.date(from: tempDate)
        dateFormatter.timeZone = TimeZone(identifier:"GMT")
        dateFormatter.locale = Locale(identifier: "GMT")
        if let dataa = actualDate{
            tempDate = dateFormatter.string(from: dataa)
            print(tempDate)
        }
        
//        if(isFromDate){
//            self.prospectsSDate = actualDate
//            tempDate = "2020-05-08T18:30:00"
//        }
//        else{
//            self.prospectsEDate = actualDate
//            tempDate = "2020-05-12T18:29:59"
//        }

//        print(actualDate)
//
//        print(date)
//        print(tempDate)
//        print(tempDate)
        return tempDate
    }

    func getTimeInServerFormatFromDate(date : Date)->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatter.string(from: date)
//        print(date)
        return date
    }
    func isCurrentDayOrFutureDay(dateString : String)->Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatter.date(from: dateString)
        
        let nowDate = Date()
//        print(nowDate)
        
        if(date! > nowDate){
            return true
        }
        else if(date! < nowDate){
            return false
        }
        else{
            return false
        }
    }
    func isToday(dateStr : String)->Bool{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let date = dateFormatter.date(from: dateStr)

        return Calendar.current.isDateInToday(date!)
    }
    func isProspectToday(date : Date)->Bool{
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss"
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        let date = dateFormatter.date(from: dateStr)

        return Calendar.current.isDateInToday(date)

    }
    func getServerDateTimeFromDate(date : Date)->String{
//        "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let dateStr = dateFormatter.string(from: date)
        return dateStr
    }
    func getHistoryCellDate(dateStr : String)->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let date = dateFormatter.date(from: dateStr)

        if(Calendar.current.isDateInToday(date!))
        {
            dateFormatter.dateFormat =  "hh:mm a"
            
            return String(format: "Today • %@", dateFormatter.string(from: date!))
        }
        else{
            dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return self.convertDateFormate(date: date!, dateFormat: "MMM, yyyy • hh:mm a")
        }
    }
    func getNotificationViewDate(dateStr: String)->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatter.date(from: dateStr)
        
        if(Calendar.current.isDateInToday(date!))
        {
            dateFormatter.dateFormat =  "hh:mm a"
            
            return String(format: "Today • %@", dateFormatter.string(from: date!))
        }
        else{
            let notificatoinDate =  convertDateFormate(date: date!, dateFormat: "MMM, yyyy • hh:mm a")  //dateFormatter1.string(from: date!)
            return notificatoinDate
        }
    }
    func getReceiptEntryDate(dateStr: String)->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatter.date(from: dateStr)

        return self.convertDateFormate(date: date!, dateFormat: "MMM, yyyy")
    }
    func getDateStringFromDate(date :Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "dd MMM yyyy hh mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let tempDate = dateFormatter.string(from: date)
//        print(tempDate)
        
        return tempDate
    }
    func getDateFromServerDateString(dateStr : String)->Date?{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatter.date(from: dateStr)
        return date
    }
    func getDateWithDateFormat(dateStr : String,dateFormat: String)->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatter.date(from: dateStr)
        
        return self.convertDateFormate(date: date!, dateFormat: dateFormat)
        
    }
    func getDateWithCustomDateFormat(dateStr : String,dateFormat: String)->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatter.date(from: dateStr)
        
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date!)

    }
    func convertDateFormate(date : Date,dateFormat : String) -> String{
        // Day
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: date)
        
        // Formate
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = dateFormat
        let newDate = dateFormate.string(from: date)
        
        var day  = "\(anchorComponents.day!)"
        switch (day) {
        case "1" , "21" , "31":
            day.append("st")
        case "2" , "22":
            day.append("nd")
        case "3" ,"23":
            day.append("rd")
        default:
            day.append("th")
        }
        return day + " " + newDate
    }
    func getCurrentTimeAsString() -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd-HH-mm-ss-SSSS"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        print(dateFormatter.string(from: Date()))
        return dateFormatter.string(from: Date())
    }
    func saveImageToDocumentsFolder(_ image: UIImage, name: String,folderNameId : String)-> URL?{
        
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath =  tDocumentDirectory.appendingPathComponent(folderNameId)
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    NSLog("Couldn't create document directory")
                }
            }
            NSLog("Document directory is \(filePath)")
            
            guard let imageData = image.jpegData(compressionQuality: 0.1) else {
                return nil
            }
            do {
                let imageURL = filePath.appendingPathComponent(name)
                
//                print(imageURL)
                try imageData.write(to: imageURL)
                return imageURL
            } catch {
                return nil
            }
        }
        return nil
        
    }
    func saveImage(_ image: UIImage, name: String) -> URL? {
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        do {
            let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
//                FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
//            FileManager.default.urls(for: NSTemporaryDirectory(), in: .userDomainMask).first!.appendingPathComponent(name)
            
//            print(imageURL)
            try imageData.write(to: imageURL)
            return imageURL
        } catch {
            return nil
        }
    }
    func clearHOImages(){
        
        
    }
    func clearImagesCache() {
        let fileManager = FileManager.default
        let documentsURL = URL(fileURLWithPath: NSTemporaryDirectory()) //fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentPath = documentsURL.path
//        print(documentPath)
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
            for file in files {
                try fileManager.removeItem(atPath: "\(documentPath)/\(file)")
            }
        } catch {
            print("could not clear cache")
        }
    }
    func resize(_ image: UIImage) -> UIImage {
        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxHeight: Float = 1024.0
        let maxWidth: Float = 1024.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        //50 percent compression
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img?.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!) ?? UIImage()
    }
    func getTimelineLabel(label: String)-> String {
        
        if(label == "Re-Schedule Call" || label == "Schedule Call")
        {
            return "Call"
        }
        else if(label == "Send Offer")
        {
            return "Offer"
        }
        else if(label == "Schedule Another Site Visit" || label == "Schedule Site Visit")
        {
            return "Site Visit"
        }
        else if(label == "Request for Discount")
        {
            return "Discount Request"
        }
        else if(label == "Add New Task")
        {
            return "Other Task"
        }
        else if(label == "None")
        {
            return "None"
        }
        else
        {
            return "Not Interested"
        }
    }
    
    func uploadImge(imageDetails : AWS_INPUTS,completionHandler: @escaping (String?, Error?) -> ()){
        
        let s3Config = RRUtilities.sharedInstance.model.getS3Config()
        
        if(s3Config == nil){
            return  completionHandler(nil,nil)
        }
        
//        let accessKey = s3Config!.accessKeyId!
//        let secretKey = s3Config!.secretAccessKey!
        
//        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
//        let configuration = AWSServiceConfiguration(region:AWSRegionType.APSouth1, credentialsProvider:credentialsProvider)
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:AWSRegionType.APSouth1,
                                                                identityPoolId:"ap-south-1:dcf659d0-1fb4-4041-b392-15869ad0ae04")
        
        let configuration = AWSServiceConfiguration(region:AWSRegionType.APSouth1, credentialsProvider:credentialsProvider)

        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        var bucketName = ""
        if(imageDetails.type == AWS_TYPE.handover){
            bucketName = S3_BUCKET_PATHS.HANDOVER_BUCKET.rawValue
        }
        else if(imageDetails.type == AWS_TYPE.receiptEntry){
            let userDetail = RRUtilities.sharedInstance.model.getRRUser()
            bucketName =  "/" + (userDetail?.company_group ?? S3_BUCKET_PATHS.RECEIPTS.rawValue)
        }
        
        let S3BucketName = s3Config!.bucket! + bucketName
        
//        print(imageDetails.imageURL)
//        print(imageDetails.imageName)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = imageDetails.imageURL
        uploadRequest.key = imageDetails.imageName
        uploadRequest.bucket = S3BucketName
        uploadRequest.contentType = "image/jpeg"
        uploadRequest.acl = .private
        uploadRequest.contentDisposition = imageDetails.type.rawValue
        
//        let queueID = "com.reroot.queue" + imageDetails.type.rawValue
        
//        let queue = DispatchQueue(label: queueID, qos: DispatchQoS.userInitiated)
        
        let transferManager = AWSS3TransferManager.default()
        
        transferManager.upload(uploadRequest).continueWith { [weak self] (task) -> Any? in
            DispatchQueue.main.async {
            }
            
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
                //Failed to upload image
                //                    self?.offlineImagesArray.filter { $0 != "" }
                //selectedSectionsForExpand.filter { $0 != indexPath.section }
                completionHandler(nil,nil)

            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
//                    return absoluteString
                    completionHandler(absoluteString,nil)
                    //                        self?.imagesArray.append(absoluteString)
                }
            }
            else{
                completionHandler(nil,nil)
            }
            return nil
        }

    }
    
    func setUpFabricEvents(){
//        Answers.logLogin(withMethod: "Login",
//                         success: true,
//                         customAttributes: [
//                            "User": UserDefaults.standard.value(forKey: "userName") as! String,
//            ])
    }
    func uploadScreenEvent(screenName : String){
        
//        Answers.logCustomEvent(withName: screenName,
//                                       customAttributes: [
//                                        "User": UserDefaults.standard.value(forKey: "userName") as! String,
//            ])
    }
}
extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS = "iPhone X or iPhone XS"
        case iPhone_XR = "iPhone XR"
        case iPhone_XSMax = "iPhone XS Max"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhones_4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhones_X_XS
        case 2688:
            return .iPhone_XSMax
        default:
            return .unknown
        }
    }
}

extension UIImageView
{
    func roundCornersForAspectFit(radius: CGFloat)
    {
        if let image = self.image {
            
            //calculate drawingRect
            let boundsScale = self.bounds.size.width / self.bounds.size.height
            let imageScale = image.size.width / image.size.height
            
            var drawingRect: CGRect = self.bounds
            
            if boundsScale > imageScale {
                drawingRect.size.width =  drawingRect.size.height * imageScale
                drawingRect.origin.x = (self.bounds.size.width - drawingRect.size.width) / 2
            } else {
                drawingRect.size.height = drawingRect.size.width / imageScale
                drawingRect.origin.y = (self.bounds.size.height - drawingRect.size.height) / 2
            }
            let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    func toJSON(array: [CarParks]) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: array, options: [])
        return String(data: data, encoding: .utf8)!
    }
    
    func fromJSON(string: String) throws -> [[String: Any]] {
        let data = string.data(using: .utf8)!
        guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyObject] else {
            throw NSError(domain: NSCocoaErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])
        }
        return jsonObject.map { $0 as! [String: Any] }
    }
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
extension Formatter {
    static let ISO8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        if #available(iOS 11.0, *) {
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        } else {
            // Fallback on earlier versions
        }
        return formatter
    }()
}


extension UIColor{
    static func returnRGBColor(r:CGFloat, g:CGFloat, b:CGFloat) -> UIColor{
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    struct BOLCK_STATUS_COLOR {
        static var vacant: UIColor  { return UIColor.hexStringToUIColor(hex: "376eb0") } //dde6f4 //376eb0
        static var booked: UIColor { return UIColor.hexStringToUIColor(hex: "f67a00") }
        static var sold: UIColor { return UIColor.hexStringToUIColor(hex: "00bfac") }
        static var reserved: UIColor { return UIColor.hexStringToUIColor(hex: "f6d830") }
        static var blocked: UIColor { return UIColor.hexStringToUIColor(hex: "d0021b") }
        static var handedOver: UIColor { return UIColor.hexStringToUIColor(hex: "32a500") }
    }
    struct UNIT_STATUS_COLOR_FOR_COLLECTIONVIEW {
        static var vacant: UIColor  { return UIColor.hexStringToUIColor(hex: "dde6f4") } //dde6f4 //376eb0
        static var booked: UIColor { return UIColor.hexStringToUIColor(hex: "f67a00") }
        static var sold: UIColor { return UIColor.hexStringToUIColor(hex: "00bfac") }
        static var reserved: UIColor { return UIColor.hexStringToUIColor(hex: "f6d830") }
        static var blocked: UIColor { return UIColor.hexStringToUIColor(hex: "d0021b") }
        static var handedOver: UIColor { return UIColor.hexStringToUIColor(hex: "32a500") }
    }

    struct UNIT_STATUS_COLOR {
        static var vacant: UIColor  { return UIColor.hexStringToUIColor(hex: "376eb0") } //dde6f4 //376eb0
        static var booked: UIColor { return UIColor.hexStringToUIColor(hex: "f67a00") }
        static var sold: UIColor { return UIColor.hexStringToUIColor(hex: "00bfac") }
        static var reserved: UIColor { return UIColor.hexStringToUIColor(hex: "f6d830") }
        static var blocked: UIColor { return UIColor.hexStringToUIColor(hex: "d0021b") }
        static var handedOver: UIColor { return UIColor.hexStringToUIColor(hex: "32a500") }
    }
    struct HAND_OVER_STATUS_COLOR {
        static var Handover_Review : UIColor {return UIColor.hexStringToUIColor(hex: "376eb0")} //dde6f4
        static var Internal_Review : UIColor {return UIColor.hexStringToUIColor(hex: "f67a00")}
        static var Internal_Snags : UIColor {return UIColor.hexStringToUIColor(hex: "00bfac")}
        static var Customer_Review : UIColor {return UIColor.hexStringToUIColor(hex: "d0021b")}
        static var Customer_Snags : UIColor {return UIColor.hexStringToUIColor(hex: "32a500")}
        static var Final_Possession : UIColor {return UIColor.hexStringToUIColor(hex: "f6d830")}
    }
    struct HAND_OVER_STATUS_COLOR_FOR_COllECTIONVIEW {
        static var Handover_Review : UIColor {return UIColor.hexStringToUIColor(hex: "dde6f4")}
        static var Internal_Review : UIColor {return UIColor.hexStringToUIColor(hex: "f67a00")}
        static var Internal_Snags : UIColor {return UIColor.hexStringToUIColor(hex: "00bfac")}
        static var Customer_Review : UIColor {return UIColor.hexStringToUIColor(hex: "d0021b")}
        static var Customer_Snags : UIColor {return UIColor.hexStringToUIColor(hex: "32a500")}
        static var Final_Possession : UIColor {return UIColor.hexStringToUIColor(hex: "f6d830")}
    }
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
extension UIApplication {
    var statusBarView: UIView? {
        if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}
@objc class ClosureSleeve: NSObject {
    let closure: ()->()

    init (_ closure: @escaping ()->()) {
        self.closure = closure
    }

    @objc func invoke () {
        closure()
    }
}

extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping ()->()) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, "[\(arc4random())]", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}

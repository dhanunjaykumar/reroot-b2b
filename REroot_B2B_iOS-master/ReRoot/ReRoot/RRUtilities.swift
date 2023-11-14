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
//prospectStatusesArray.add("No Response")
//prospectStatusesArray.add("Not Rechable")
//prospectStatusesArray.add("Call Complete")
//prospectStatusesArray.add("Not Interested")

protocol Singleton: class {
    static var sharedInstance: Self { get }
}
struct URL_DICT  {
    let url : String?
    let urlType : String?
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
    case NOT_INTERESTED = "Not Interested"
}
enum SCHEDULE_CALL_ACTIONS_STRING : String{
    case NO_RESPONSE = "No Response"
    case NOT_REACHABLE = "Not Rechable"
    case CALL_COMPLETE = "Call Complete"
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
enum BLOCK_STATUS : Int { //Unit Status 0 - Vacant, 1 - Booked, 2- Sold, 3 - Reserved, 4 - Blocked, 5 - Handed Over
    case VACANT
    case BOOKED
    case SOLD
    case RESERVED
    case BLOCKED
    case HANDEDOVER
}
enum PROSPECTS_TYPES : Int {
    case REGISTRATIONS
    case LEADS
    case OPPORTUNITIES
}

final class RRUtilities: Singleton {

    static var sharedInstance = RRUtilities()
    
    var isNetworkAvailable : Bool = false
    var notInterestedSources : STATUS_SOURCES!
    var drivers : [DRIVER] = []
    var vehicles : [VEHICLE] = []
    
    let keychain = Keychain(service: "com.reroot.reroot-token")
    
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
    func showLoginScreenOnAuthFailure(navigationController : UINavigationController){
        HUD.flash(.label("Session Expires. Please login again"), delay: 1.0)
        //perform logout
        UserDefaults.standard.set(nil, forKey: "Cookie")
        UserDefaults.standard.synchronize()
        keychain["Cookie"] = nil
        navigationController.popToRootViewController(animated: true)
        // Throw notificationt to show login view
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.SHOWLOGINSCREEN), object: nil)
        
    }
    func isValidEmail(emailID:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailID)
    }
    func getNextStatusFromCurrentStatus(currentStatus : Int) -> BLOCK_STATUS{
        
        switch currentStatus {
        case 0:
            return BLOCK_STATUS.BOOKED
        case 1 :
            return BLOCK_STATUS.SOLD
        case 2 :
           return BLOCK_STATUS.RESERVED
        case 3 :
             return BLOCK_STATUS.BLOCKED
        case 4 :
            return BLOCK_STATUS.HANDEDOVER
        case 5 :
           return BLOCK_STATUS.HANDEDOVER
        default:
            break
        }
        
        return BLOCK_STATUS.BLOCKED
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
    
    func getDateStringFromServerDateStr(dateStr : String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatter.date(from: dateStr)
        print(date)
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let tempStr = dateFormatter.string(from: date!)
        print(tempStr)
        
        return tempStr
        
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
    
    struct UNIT_STATUS_COLOR {
        static var vacant: UIColor  { return UIColor.hexStringToUIColor(hex: "dde6f4") } //dde6f4 //376eb0
        static var booked: UIColor { return UIColor.hexStringToUIColor(hex: "f67a00") }
        static var sold: UIColor { return UIColor.hexStringToUIColor(hex: "00bfac") }
        static var reserved: UIColor { return UIColor.hexStringToUIColor(hex: "f6d830") }
        static var blocked: UIColor { return UIColor.hexStringToUIColor(hex: "d0021b") }
        static var handedOver: UIColor { return UIColor.hexStringToUIColor(hex: "32a500") }
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


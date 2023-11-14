//
//  Permissions.swift
//  REroot
//
//  Created by Dhanunjay on 15/05/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import Foundation
import CoreData

enum Permission_Names : String {
    
    case CRM = "CRM"
    case PRESALES = "PRESALES"
    case SALES = "SALES"
    case APPROVALS = "APPROVALS"
    
    case AGREEMENT_STATUS_TRACKER = "Agreement Status Tracker"
    case RECEIPT_ENTRY = "Receipt Entry"
    case PROSPECTS = "Prospects"
    case QUICK_REGISTRATION = "Quick Registrations"
    case BOOKING_FORM = "Booking Form"
    case PRICE_REVISION = "Price Revision"
    case DASHBOARD = "DashBoard"
    case BLOCK_RELEASE_UNIT = "Block/Release Unit"
    case RESERVE_UNIT = "Reserve Unit"
    case CANCEL_TRANSFER_UNIT = "Cancel/Transfer Unit"
    case ASSIGN_UNIT = "Assign Unit"
    case HANDOVER_SETUP = "Handover Setup"
    case HANDOVER_REVIEW = "Handover Review - App"
    case INTERNAL_REVIEW = "Internal Review - App"
    case INTERNAL_SNAGS = "Internal Snags - App"
    case CUSTOMER_REVIEW = "Customer Review - App"
    case CUSTOMER_SNAGS = "Customer Snags - App"
    case FINAL_POSSESSION = "Final Possession - App"
    case INCOMING_APPROVALS = "Incoming Approvals"
    case OUTGOING_APPROVALS = "Outgoing Approvals"
    case STATEMENT_OF_ACCOUNT = "Statement of Account"
    case CALLS = "Calls"
    case OFFERS = "Offers"
    case SITE_VISITS = "Site Visits"
    case DISCOUNT_REQUESTS = "Discount Requests"
    case OTHER_TASKS = "Other Tasks"
    case NOT_INTERESTED = "Not Interested"
    
}
enum UserRolePermissions : Int {
    case VIEW = 1
    case CREATE = 2
    case EDIT = 3
    case DELETE = 4
}
protocol SingletonOne: class {
    static var shared: Self { get }
}

final class PermissionsManager {
    
    var fetchedResultControllerPermissions : NSFetchedResultsController<Permissions>!
    
    static var shared = PermissionsManager()
    
    var isAdmin : Bool = false
    var isSigleTabEabled : Bool = false
    
//        var calls : Bool = false
//        var offers : Bool = false
//        var siteVisits : Bool = false
//        var discountRequest : Bool = false
//        var otherTasks : Bool = false
//        var notInterested : Bool = false
    //    var quickRegistration : Bool = false
    //    var bookUnit : Bool = false
    
    //Initializer access level change now
    
    private init(){
    }
    
    // Create , Edit,delete,view,
    
    func isSuperUser()->Bool{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RRUser")
        let tempUsers = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest) as! [RRUser]
        if(tempUsers.count > 0){
            
            let rruser = tempUsers[0]
            
            if(rruser.type == USER_ROLE_TYPE.ADMIN.rawValue){
                self.isAdmin = true
            }
            else{
                self.isAdmin = false
            }
        }
        else{
            self.isAdmin = true
        }
        return self.isAdmin
    }
    func getUserRolePermissions(bitNumber : Int){
        
        // get create, edit ,delete ,view
        
        //        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "RRUserRole")
        //
        //        let predicate = NSPredicate(format: "create BETWEEN %@",[bitNumber,bitNumber])
        //
        //        fetchRequest.predicate = predicate
        //
        //        let createBit = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)
        
    }
    func isPresalesPermitted()->Bool{
        return self.checkForPermission(moduleName: Permission_Names.PROSPECTS.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)
    }
    func isPresalesEditPermitted()->Bool{
        return self.checkForPermission(moduleName: Permission_Names.PROSPECTS.rawValue, permissionType: UserRolePermissions.EDIT.rawValue)
    }

    func isSalesPermitted()->Bool{
        return self.checkForPermission(moduleName: Permission_Names.BOOKING_FORM.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)
    }
    func isApprovalsPermitted()->Bool{
        return (self.checkForPermission(moduleName: Permission_Names.INCOMING_APPROVALS.rawValue, permissionType: UserRolePermissions.VIEW.rawValue) || self.checkForPermission(moduleName: Permission_Names.OUTGOING_APPROVALS.rawValue, permissionType: UserRolePermissions.VIEW.rawValue))
    }
    func isCRMPermitted()->Bool{
        return self.checkForPermission(moduleName: Permission_Names.AGREEMENT_STATUS_TRACKER.rawValue, permissionType: UserRolePermissions.VIEW.rawValue) || checkForPermission(moduleName: Permission_Names.RECEIPT_ENTRY.rawValue, permissionType: UserRolePermissions.VIEW.rawValue) || self.isManageUnitsPermitted()
    }
    func isManageUnitsPermitted()->Bool{
        
        return checkForPermission(moduleName: Permission_Names.BLOCK_RELEASE_UNIT.rawValue, permissionType: UserRolePermissions.VIEW.rawValue) || checkForPermission(moduleName: Permission_Names.RESERVE_UNIT.rawValue, permissionType: UserRolePermissions.VIEW.rawValue) || checkForPermission(moduleName: Permission_Names.CANCEL_TRANSFER_UNIT.rawValue, permissionType: UserRolePermissions.VIEW.rawValue) || checkForPermission(moduleName: Permission_Names.ASSIGN_UNIT.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)
    }
    func checkForPermission(moduleName : String,permissionType : Int)->Bool{
        
        if(self.isAdmin){
            return true
        }
        
        let request: NSFetchRequest<Permissions> = Permissions.fetchRequest()
        request.sortDescriptors = []
        var predicate : NSPredicate!
        predicate = NSPredicate(format: "name == %@",moduleName)
        request.predicate = predicate
        let permissions = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(request)
        
        let rolesReqest : NSFetchRequest<RRUserRole> = RRUserRole.fetchRequest()
        rolesReqest.sortDescriptors = []
        let userRolesPermissions = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(rolesReqest)
        
        var bit : Character = "0"
        
        if(permissions.count > 0){
            
            let permissionToGet = permissions[0]
            
            for userRole in userRolesPermissions{
                
                switch permissionType{
                case UserRolePermissions.CREATE.rawValue :
                    if(userRole.create?.count ?? 0 >= Int(permissionToGet.bit)){
                        bit = userRole.create![Int(permissionToGet.bit)]
                    }
                    break
                case UserRolePermissions.EDIT.rawValue :
                    if(userRole.edit?.count ?? 0 >=  Int(permissionToGet.bit)){
                        bit = userRole.edit![Int(permissionToGet.bit)]
                    }
                    break
                case UserRolePermissions.DELETE.rawValue :
                    if(userRole.delete?.count ?? 0 >= Int(permissionToGet.bit)){
                        bit = userRole.delete![Int(permissionToGet.bit)]
                    }
                    break
                case UserRolePermissions.VIEW.rawValue :
                    if(userRole.view?.count ?? 0 >= Int(permissionToGet.bit)){
                        bit = userRole.view![Int(permissionToGet.bit)]
                    }
                    break
                default:
                    break
                }
                if(bit == "1"){
                    return true
                }
            }
        }
        return false
    }
    
    func presalesPermissions(type : String)->Bool{
        
        if(true){ //(self.isAdmin)
            return true
        }
        
        let rolesReqest : NSFetchRequest<PresalesPermissions> = PresalesPermissions.fetchRequest()
        rolesReqest.sortDescriptors = []
        let permissions = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(rolesReqest)
        
        if(permissions.count > 0){
        
            var isPermitted = false
        
            for eachPresalePermission in permissions{
                
                if(type == "calls"){
                    if(eachPresalePermission.calls){
                        isPermitted = eachPresalePermission.calls
                        break
                    }
                }
                else if(type == "offers"){
                    if(eachPresalePermission.offers){
                        isPermitted = eachPresalePermission.offers
                        break
                    }
                }
                else if(type == "siteVisit"){
                    if(eachPresalePermission.siteVisits){
                        isPermitted = eachPresalePermission.siteVisits
                        break
                    }
                }
                else if(type == "discountRequest"){
                    if(eachPresalePermission.discountRequests){
                        isPermitted = eachPresalePermission.discountRequests
                        break
                    }
                }
                else if(type == "otherTask"){
                    if(eachPresalePermission.otherTasks){
                        isPermitted = eachPresalePermission.otherTasks
                        break
                    }
                }
                else if(type == "notInterested"){
                    if(eachPresalePermission.notInterested){
                        isPermitted = eachPresalePermission.notInterested
                        break
                    }
                }
            }
           return isPermitted
        }
        else{
            if(self.isAdmin){
                return true
            }
            else{
                return false
            }
        }
    }
    func calls()->Bool{
        return self.presalesPermissions(type: "calls")
    }
    func offers()->Bool{
        return self.presalesPermissions(type: "offers")
    }
    func siteVisits()->Bool{
        return self.presalesPermissions(type: "siteVisit")
    }
    func discountRequests()->Bool{
        return self.presalesPermissions(type: "discountRequest")
    }
    func otherTasks()->Bool{
        return self.presalesPermissions(type: "otherTask")
    }
    func notInterested()->Bool{
        return self.presalesPermissions(type: "notInterested")
    }
    func quickRegistration()->Bool{
        return self.checkForPermission(moduleName: Permission_Names.QUICK_REGISTRATION.rawValue, permissionType: UserRolePermissions.CREATE.rawValue)
    }
    func bookUnit()->Bool{
        return self.checkForPermission(moduleName: Permission_Names.BOOKING_FORM.rawValue, permissionType: UserRolePermissions.CREATE.rawValue)
    }
    func isEmployeePermitted(moduleName : String,permissionType : Int,employeeID : String)->Bool{
        
        if(self.isAdmin){
            return self.isAdmin
        }
        
        let isPermitted = self.checkForPermission(moduleName: moduleName, permissionType: permissionType)
        
        let empId = (employeeID.count > 0) ? RRUtilities.sharedInstance.model.getRRUser()?.id : nil
        if(empId != nil){
            if(empId == employeeID && isPermitted){
                return true
            }
            else{
                return false
            }
        }
        else{
            return isPermitted
        }
    }
    func isEmployePermittedForPresales(employeeID : String)->Bool{
        if(self.isAdmin){
            return self.isAdmin
        }
        let empId = (employeeID.count > 0) ? RRUtilities.sharedInstance.model.getRRUser()?.id : nil
        if(empId == employeeID){
            return true
        }
        else{
            return false
        }
    }
    func dashBoardPermitted()->Bool{
        return self.checkForPermission(moduleName: Permission_Names.DASHBOARD.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)
    }
    func getHandoverPermissionKey(status: Int)-> String{
        
        switch status {
        case 0:
            return Permission_Names.HANDOVER_REVIEW.rawValue
        case 1:
            return Permission_Names.INTERNAL_REVIEW.rawValue
        case 2:
            return Permission_Names.INTERNAL_SNAGS.rawValue
        case 3:
            return Permission_Names.CUSTOMER_REVIEW.rawValue
        case 4:
            return Permission_Names.CUSTOMER_SNAGS.rawValue
        case 5:
            return Permission_Names.FINAL_POSSESSION.rawValue
        default:
            return Permission_Names.HANDOVER_REVIEW.rawValue
        }
    }
    
}
extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}

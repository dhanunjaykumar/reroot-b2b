//
//  Model.swift
//  ReRoot
//
//  Created by Dhanunjay on 13/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import CoreData

class DBModel {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedObjectContext = NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    var persistentContainer : NSPersistentContainer!
    var uploadUnitsFetchedResultsController : NSFetchedResultsController<SoldUnits>!
    var fetchedResultsControllerHandOverItems : NSFetchedResultsController<TowerHandOverItems>!

    init() {
        managedObjectContext = appDelegate.persistentContainer.viewContext
        persistentContainer = appDelegate.persistentContainer
    }
    
    func getEmployeesByExcludingEmployee(salesPersonName : String)-> Array<Employee>{
        
//        self.persistentContainer.performBackgroundTask{ managedObjectContext in
//            var results: [JournalEntry] = []
//            do {
//                results = try context.fetch(self.surfJournalFetchRequest())
//            } catch let error as NSError {
//                print("ERROR: \(error.localizedDescription)")
//            }
//        }

        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee")
        fetchRequest.predicate = NSPredicate(format: "name != %@ && empStatus == %d",
                                             [salesPersonName],true)
        

        do {
            //            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            //            let sortDescriptors = [sortDescriptor]
            //            activityInfo.sortDescriptors = sortDescriptors
            
            let fetchedActivities = try managedObjectContext.fetch(fetchRequest) as! [Employee]
            
            return fetchedActivities
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
            //            fatalError("Failed to fetch employees: \(error)")
        }

    }
    func getAllEmployees() -> Array<Employee>{
        
//        Employee
        let activityInfo = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee")
        let predicate = NSPredicate(format: "empStatus == %d", true)
        activityInfo.predicate = predicate
        
        do {
//            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
//            let sortDescriptors = [sortDescriptor]
//            activityInfo.sortDescriptors = sortDescriptors
            
            let fetchedActivities = try managedObjectContext.fetch(activityInfo) as! [Employee]
            
            return fetchedActivities
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
            //            fatalError("Failed to fetch employees: \(error)")
        }
    }
    func getAllDrivers()-> Array<Driver>{
        let activityInfo = NSFetchRequest<NSFetchRequestResult>(entityName: "Driver")
        
        do {
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let sortDescriptors = [sortDescriptor]
            activityInfo.sortDescriptors = sortDescriptors
            
            let fetchedActivities = try managedObjectContext.fetch(activityInfo) as! [Driver]
            
            
            return fetchedActivities
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
            //            fatalError("Failed to fetch employees: \(error)")
        }
    }
    func getAllUnits(){
        let activityInfo = NSFetchRequest<NSFetchRequestResult>(entityName: "Units")
        
        do {
//            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
//            let sortDescriptors = [sortDescriptor]
//            activityInfo.sortDescriptors = sortDescriptors
            
            let fetchedActivities = try managedObjectContext.fetch(activityInfo) as! [Units]
//            print(fetchedActivities.count)
//            for tempUnit in fetchedActivities{
////                print(tempUnit.unitNo)
////                print(tempUnit.floor)
////                print(tempUnit.sectionIndex)
////                print(tempUnit.sectionTitle)
//            }
            
            
//            return fetchedActivities
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
//            return []
            //            fatalError("Failed to fetch employees: \(error)")
        }
    }
    func getNotInterestedReasons()-> Array<NotInterestedCause>{
//        NotInterestedCause
        
        let budgetInfo = NSFetchRequest<NSFetchRequestResult>(entityName: "NotInterestedCause")
        
        do {
            let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
            let sortDescriptors = [sortDescriptor]
            budgetInfo.sortDescriptors = sortDescriptors
            
            let reasons = try managedObjectContext.fetch(budgetInfo) as? [NotInterestedCause]
            
            return reasons ?? []
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
            //            fatalError("Failed to fetch employees: \(error)")
        }


    }
    func getBudgetRanges()-> Array<CustomerBudgets>{
        
        let budgetInfo = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerBudgets")
        
        do {
            let sortDescriptor = NSSortDescriptor(key: "value", ascending: true)
            let sortDescriptors = [sortDescriptor]
            budgetInfo.sortDescriptors = sortDescriptors
            
            let fetchedBudgets = try managedObjectContext.fetch(budgetInfo) as? [CustomerBudgets]
            
            return fetchedBudgets ?? []
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
            //            fatalError("Failed to fetch employees: \(error)")
        }
    }
    func getUnitTypes()-> Array<UnitTypes>{
        
        let budgetInfo = NSFetchRequest<NSFetchRequestResult>(entityName: "UnitTypes")
        
        do {
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let sortDescriptors = [sortDescriptor]
            budgetInfo.sortDescriptors = sortDescriptors
            
            let fetchedUnitTypes = try managedObjectContext.fetch(budgetInfo) as? [UnitTypes]
            return fetchedUnitTypes ?? []
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
            //            fatalError("Failed to fetch employees: \(error)")
        }
    }
    func getAllVehicles()-> Array<Vehicle>{
        let activityInfo = NSFetchRequest<NSFetchRequestResult>(entityName: "Vehicle")
        
        do {
            let sortDescriptor = NSSortDescriptor(key: "vehicleType", ascending: true)
            let sortDescriptors = [sortDescriptor]
            activityInfo.sortDescriptors = sortDescriptors
            
            let fetchedActivities = try managedObjectContext.fetch(activityInfo) as! [Vehicle]
            
            
            return fetchedActivities
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
            //            fatalError("Failed to fetch employees: \(error)")
        }
    }
    func getVehicleIDUsingVehicleType(vehicleType : String) -> String{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Vehicle")
        fetchRequest.resultType = .managedObjectResultType
        let predicate = NSPredicate(format: "vehicleType CONTAINS[c] %@", vehicleType)
        fetchRequest.predicate = predicate
        let vehicleList = try! managedObjectContext.fetch(fetchRequest)
        
        let vehicle = vehicleList[0] as! Vehicle
        
        return vehicle.id ?? ""
    }
    func getEmployeeNameUsingId(employeId : String)->String?{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee")
        fetchRequest.resultType = .managedObjectResultType
        let predicate = NSPredicate(format: "empId CONTAINS[c] %@", employeId)
        fetchRequest.predicate = predicate

        let employeeList = try! managedObjectContext.fetch(fetchRequest)
        if(employeeList.count > 0){
            let employee = employeeList[0] as! Employee
            return employee.name
        }
        else{
            return nil
        }
    }

    func getVehicleNameUsingId(vehicleID : String) -> String?
    {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Vehicle")
                fetchRequest.resultType = .managedObjectResultType
        let predicate = NSPredicate(format: "id CONTAINS[c] %@", vehicleID)
        fetchRequest.predicate = predicate
        let vehicleList = try! managedObjectContext.fetch(fetchRequest)
        
        if(vehicleList.count == 0){
            return nil
        }
        
        let vehicle = vehicleList[0] as! Vehicle
        
        if(vehicle.vehicleType == nil || vehicle.vehicleType == "(null)")
        {
            return vehicle.plateNo!
        }
        else{
            return String(format: "%@ (%@)", vehicle.plateNo! , vehicle.vehicleType!)
        }
    }
    func getPermissionsByModule(moduleName : String){
        
        
        
    }
    func getNotifications()->[Notifications]?{
        
        let activityInfo = NSFetchRequest<NSFetchRequestResult>(entityName: "Notifications")
        
        do {
            let sortDescriptor = NSSortDescriptor(key: "created_at", ascending: false)
            let sortDescriptors = [sortDescriptor]
            activityInfo.sortDescriptors = sortDescriptors
            
            let fetchedNotifications = try managedObjectContext.fetch(activityInfo) as! [Notifications]
            
            return fetchedNotifications
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
        }
    }
    func getS3Config()->AWS_S3Config?{
        
        let activityInfo = NSFetchRequest<NSFetchRequestResult>(entityName: "AWS_S3Config")

        do {
            let sortDescriptors : [NSSortDescriptor] = []
            activityInfo.sortDescriptors = sortDescriptors
            
            let s3Config = try managedObjectContext.fetch(activityInfo) as! [AWS_S3Config]
            if(s3Config.count > 0){
                let config = s3Config[0]
                return config
            }
            else{
                return nil
            }
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return nil
        }

    }
    func getHandOverItemById(itemID : String)->TowerHandOverItems?{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TowerHandOverItems")
        fetchRequest.resultType = .managedObjectResultType
        
        let predicate = NSPredicate(format: "id CONTAINS[c] %@", itemID)
        fetchRequest.predicate = predicate
        
        let hoItemsList = try! managedObjectContext.fetch(fetchRequest) as! [TowerHandOverItems]
        if(hoItemsList.count > 0){
            let hoItem = hoItemsList[0]
            return hoItem
        }
        else{
            return nil
        }
    }
    func getUnitDetailsByUnitID(unitId : String)->Units?{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Units")
        fetchRequest.resultType = .managedObjectResultType
        
        let predicate = NSPredicate(format: "id CONTAINS[c] %@", unitId)
        fetchRequest.predicate = predicate
        
        let unitsList = try! managedObjectContext.fetch(fetchRequest) as! [Units]
        if(unitsList.count > 0){
            let unit = unitsList[0]
            return unit
        }
        else{
            return nil
        }
        
    }
    func getHandoverItemById(itemID : String)->TowerHandOverItems?{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TowerHandOverItems")
        fetchRequest.resultType = .managedObjectResultType
        
        let predicate = NSPredicate(format: "itemId CONTAINS[c] %@", itemID)
        fetchRequest.predicate = predicate
        
        let unitsList = try! managedObjectContext.fetch(fetchRequest) as! [TowerHandOverItems]
        if(unitsList.count > 0){
            let unit = unitsList[0]
            return unit
        }
        else{
            return nil
        }

    }
    func getImagesOfTower(towerName : String)-> [String]{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Towers")
        fetchRequest.resultType = .managedObjectResultType
        
//        let predicate = NSPredicate(format: "name ENDSWITH %@", "BLOCK Tower A")
//        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let towersList = try! managedObjectContext.fetch(fetchRequest) as! [Towers]
        
//        print(towerName)

        if(towersList.count > 0){
         
            var imagesTower : Towers!
            
            for tempTower in towersList{
                
                if(towerName.contains(tempTower.name!)){
                    imagesTower = tempTower
                    break
                }
            }
            
            if(imagesTower == nil){
                return []
            }
            
            let tower = towersList[0] as! Towers
            
            if(imagesTower.hasImages == false){
                return []
            }
            let images =  imagesTower.images
            
//            print(images)
            return images!

            
        }
        else{
            return []
        }
        
        return []
    }
    func getDriveNameUsingID(driverID : String)->String{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Driver")
        fetchRequest.resultType = .managedObjectResultType
        let predicate = NSPredicate(format: "id CONTAINS[c] %@", driverID)
        fetchRequest.predicate = predicate
        let driverList = try! managedObjectContext.fetch(fetchRequest)
        
        if(driverList.count == 0){
            return ""
        }
        
        let driver = driverList[0] as! Driver
        
        return driver.name!
    }
    func getNewEnquirySources()-> Array<NewEnquirySources>{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewEnquirySources")
        fetchRequest.resultType = .managedObjectResultType
        
        do {
            let fetchedEnqSources = try managedObjectContext.fetch(fetchRequest) as! [NewEnquirySources]
            return fetchedEnqSources
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
            //            fatalError("Failed to fetch employees: \(error)")
        }
    }
    func getEnqSrcNameById(id : String)->NewEnquirySources?{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewEnquirySources")
        fetchRequest.predicate = NSPredicate(format: "name == %@", id)
        fetchRequest.resultType = .managedObjectResultType
        
        do {
            let fetchedEnqSources = try managedObjectContext.fetch(fetchRequest) as! [NewEnquirySources]
            if(fetchedEnqSources.count > 0){
                return fetchedEnqSources[0]
            }
            else{
                return nil
            }

        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return nil
            //            fatalError("Failed to fetch employees: \(error)")
        }

    }
    func getEnquirySources()-> Array<EnquirySources>{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "EnquirySources")
        fetchRequest.resultType = .managedObjectResultType
        
        do {
            let fetchedEnqSources = try managedObjectContext.fetch(fetchRequest) as! [EnquirySources]
            return fetchedEnqSources
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
            //            fatalError("Failed to fetch employees: \(error)")
        }
    }
    func getAllApprovalCount()->Int{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Approvals")
        fetchRequest.resultType = NSFetchRequestResultType.countResultType
        let count = try! managedObjectContext.count(for:fetchRequest)
        return count
    }
    func getApprovalsCountByType(approvalType : Int)->Int{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Approvals")
        fetchRequest.predicate = NSPredicate(format: "approval_type == %d", approvalType)
        fetchRequest.resultType = NSFetchRequestResultType.countResultType
        let count = try! managedObjectContext.count(for:fetchRequest)
        return count
    }
    func getIncomingApprovalsByType(approvalType : Int , isIncoming : Bool)->Int{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Approvals")
        fetchRequest.predicate = NSPredicate(format: "approval_type == %d AND isIncoming == %d", approvalType,isIncoming)
        fetchRequest.resultType = NSFetchRequestResultType.countResultType
        let count = try! managedObjectContext.count(for:fetchRequest)
        return count
    }
    func restApprovalsEntity(){
        
        
        let historyFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ApprovalHistory")
        historyFetch.returnsObjectsAsFaults = false
        //        pricingInfoFetch.predicate = NSPredicate(format: "approval_type == %d", approvalType)
        let historyRequest = NSBatchDeleteRequest(fetchRequest: historyFetch)
        do {
            _ = try managedObjectContext.execute(historyRequest)
//            print(result)
        } catch {
            fatalError("Failed to execute request: \(error)")
        }

        
        let pricingInfoFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ApprovalPricingInfo")
        pricingInfoFetch.returnsObjectsAsFaults = false
        //        pricingInfoFetch.predicate = NSPredicate(format: "approval_type == %d", approvalType)
        let pricingInfoRequest = NSBatchDeleteRequest(fetchRequest: pricingInfoFetch)
        do {
            _ = try managedObjectContext.execute(pricingInfoRequest)
//            print(result)
        } catch {
            fatalError("Failed to execute request: \(error)")
        }
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "BillingInfo")
        fetch.returnsObjectsAsFaults = false
        //        fetch.predicate = NSPredicate(format: "approval_type == %d", approvalType)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            _ = try managedObjectContext.execute(request)
//            print(result)
        } catch {
            fatalError("Failed to execute request: \(error)")
        }
        
        let fetch1 = NSFetchRequest<NSFetchRequestResult>(entityName: "UpdateBy")
        fetch1.returnsObjectsAsFaults = false
        fetch1.predicate = NSPredicate(format: "isApproval == %d", true)
        let request1 = NSBatchDeleteRequest(fetchRequest: fetch1)
        do {
            _ = try managedObjectContext.execute(request1)
//            print(result)
        } catch {
            fatalError("Failed to execute request: \(error)")
        }
        
        let approvalFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Approvals")
        approvalFetch.returnsObjectsAsFaults = false
//        approvalFetch.predicate = NSPredicate(format: "approval_type == %d", approvalType)
        let approvalRequest = NSBatchDeleteRequest(fetchRequest: approvalFetch)
        do {
            _ = try managedObjectContext.execute(approvalRequest)
//            print(result)
        } catch {
            fatalError("Failed to execute request: \(error)")
        }
    }
    func writePaymentToWards(paymentToWards : [PaymentToWards]){
        
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
            
            var counter = 0
            for tempPaymentType in paymentToWards{
                
                let newPaymentType = NSEntityDescription.insertNewObject(forEntityName: "PaymentTowards", into: managedObjectContext) as! PaymentTowards
                newPaymentType.name = tempPaymentType.name
                newPaymentType.id = tempPaymentType._id
                newPaymentType.index = Int16(counter)
                counter += 1
            }
            do {
                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    func writeS3Config(s3Config : S3CONFIG){
        
        self.resetEntity(entityName: "AWS_S3Config")
        
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
            
            let s3config = NSEntityDescription.insertNewObject(forEntityName: "AWS_S3Config", into: managedObjectContext) as! AWS_S3Config
            s3config.accessKeyId = s3Config.accessKeyId
            s3config.bucket = s3Config.bucket
            s3config.region = s3Config.region
            s3config.secretAccessKey = s3Config.secretAccessKey
            
            do {
                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                self.appDelegate.setUpAWSS3()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            //return results
        }
    }
    func writeGeneralsToDB(generals : GeneralsClass){
        
        self.resetEntity(entityName: "UnitTypes")
        self.resetEntity(entityName: "CustomerBudgets")
        
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
            
            let budgetRanges = generals.budgets
            let unitTypes = generals.uts

            for eachBudget in budgetRanges{
                let tempBudget = NSEntityDescription.insertNewObject(forEntityName: "CustomerBudgets", into: managedObjectContext) as! CustomerBudgets
                tempBudget.id = eachBudget.id
                tempBudget.value = Int64(eachBudget.value)
            }
            
            for eachType in unitTypes{
                let tempType = NSEntityDescription.insertNewObject(forEntityName: "UnitTypes", into: managedObjectContext) as! UnitTypes
                tempType.id = eachType.id
                tempType.name = eachType.name
            }
            
            do {
                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    func writeCurrencies(currencies : [CURRENCY]){
        
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
            
            var counter = 0
            
            for tempCurrency in currencies{
                
                let newCurrency = NSEntityDescription.insertNewObject(forEntityName: "Currency", into: managedObjectContext) as! Currency
                newCurrency.currencyName = tempCurrency.currencyName
                newCurrency.currencySymbol = tempCurrency.currencySymbol
                newCurrency.serverID = tempCurrency._id
                newCurrency.id = tempCurrency.id
                counter += 1
                
            }
            do {
                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            //return results
        }
    }
    func writeApprovals(approvals : [APPROVAL],isIncoming : Bool,completionHandler: @escaping (Bool?, Error?) -> ()){
    
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
            
            for tempApproval in approvals{
                
                let newApproval = NSEntityDescription.insertNewObject(forEntityName: "Approvals", into: managedObjectContext) as! Approvals
                
                newApproval.kind = tempApproval.reference?.kind
                newApproval.reference_item_id = tempApproval.reference?.item?._id
                newApproval.id = tempApproval._id
                newApproval.status = Int16(tempApproval.status!)
                newApproval.level = Int16(tempApproval.level!)
                newApproval.company_group = tempApproval.company_group
                newApproval.unit = tempApproval.unit
                
                newApproval.approval_type = Int16(tempApproval.approval_type!)
                newApproval.isIncoming = isIncoming
                
                newApproval.requester_id = tempApproval.requester?._id
                newApproval.requester_email = tempApproval.requester?.email
                newApproval.requester_userinfo_id = tempApproval.requester?.userInfo?._id
                newApproval.requester_userinfo_name = tempApproval.requester?.userInfo?.name
                newApproval.requester_userinfo_email = tempApproval.requester?.userInfo?.email
                newApproval.requester_userinfo_phone = tempApproval.requester?.userInfo?.phone
                
                newApproval.approver_id = tempApproval.approver?._id
                newApproval.approver_email = tempApproval.approver?.email
                newApproval.approver_userinfo_id = tempApproval.approver?.userInfo?._id
                newApproval.approver_userinfo_name = tempApproval.approver?.userInfo?.name
                newApproval.approver_userinfo_email = tempApproval.approver?.userInfo?.email
                newApproval.approver_userinfo_phone = tempApproval.approver?.userInfo?.phone
                
                newApproval.regInfo_id = tempApproval.reference?.item?.regInfo?._id
                newApproval.regInfo_userName = tempApproval.reference?.item?.regInfo?.userName
                newApproval.regInfo_userEmail = tempApproval.reference?.item?.regInfo?.userEmail
                newApproval.regInfo_userPhone = tempApproval.reference?.item?.regInfo?.userPhone
                newApproval.scheme = tempApproval.reference?.item?.scheme
            
                // ** credit note appproval
                newApproval.amount = tempApproval.reference?.item?.amount ?? 0.0
                newApproval.descp = tempApproval.reference?.item?.descp
                newApproval.dueDate = tempApproval.reference?.item?.dueDate
                newApproval.creditOrDebitTax = tempApproval.reference?.item?.tax?.label
                newApproval.narration = tempApproval.reference?.item?.narration
                // ****
                
                if tempApproval.reference?.item?.unit is String{
                    
                }
                else{
                    if(tempApproval.reference!.item?.unit != nil){
                        newApproval.unitIndex = Int64(tempApproval.reference?.item?.unit?.unitNo?.index ?? 0)
                        newApproval.unitDisplayName = tempApproval.reference?.item?.unit?.unitNo?.displayName
                    }
                }
                
                newApproval.projectId = tempApproval.reference?.item?.unit?.project?._id
                newApproval.projectName = tempApproval.reference?.item?.unit?.project?.name
                
                newApproval.towerId = tempApproval.reference?.item?.unit?.tower?._id
                newApproval.towerName = tempApproval.reference?.item?.unit?.tower?.name
                
                newApproval.blockId = tempApproval.reference?.item?.unit?.block?._id
                newApproval.blockName = tempApproval.reference?.item?.unit?.block?.name
                newApproval.unitDescription = tempApproval.reference?.item?.unit?.description
                newApproval.unit_type_id = tempApproval.reference?.item?.unit?.type?._id
                newApproval.unit_type_name = tempApproval.reference?.item?.unit?.type?.name
                
                newApproval.customer_id = tempApproval.reference?.item?.customer?._id
                newApproval.customer_name = tempApproval.reference?.item?.customer?.name
                newApproval.customer_email = tempApproval.reference?.item?.customer?.email
//                print(String(format: "%ld", (tempApproval.reference?.item?.customer?.phone) ?? 0))
                
                if(tempApproval.reference?.kind == "DebitCreditNote"){
                    
                    print(tempApproval)
                }
                
                if(tempApproval.reference?.item?.customer?.phone != nil){
                    newApproval.customer_phone = String(format: "%ld", (tempApproval.reference?.item?.customer?.phone) ?? 0)
                }
                
                newApproval.updateByDate = tempApproval.updateBy?.last?.date
                
                newApproval.new_customer_id = tempApproval.reference?.item?.new_customer?._id
                newApproval.new_customer_name = tempApproval.reference?.item?.new_customer?.userName
                
                newApproval.pdc_return_date = tempApproval.reference?.item?.pdc_return_date
                newApproval.agreement_collected_date = tempApproval.reference?.item?.agreement_collected_date
                newApproval.cancellation_date = tempApproval.reference?.item?.cancellation_date
                newApproval.cancel_reason = tempApproval.reference?.item?.cancel_reason
                
                if(tempApproval.approvalHistory != nil){
                    var counter = 0
                    for tempHistory in tempApproval.approvalHistory!{
                        
                        let newHistoryRow = NSEntityDescription.insertNewObject(forEntityName: "ApprovalHistory", into: managedObjectContext) as! ApprovalHistory
                        
                        counter += 1
                        newHistoryRow.orderID = Int32(counter)
                        newHistoryRow.approver_id = tempApproval._id
                        newHistoryRow.approval_type = Int16(tempApproval.approval_type!)
                        newHistoryRow.level = Int16(tempHistory.level!)
                        newHistoryRow.rejectReason = tempHistory.rejectReason
                        newHistoryRow.remarks = tempHistory.remarks
                        newHistoryRow.created = tempHistory.created
                        newHistoryRow.lastModified = tempHistory.lastModified
                        newHistoryRow.status = Int64(tempHistory.status!)
                        
                        newHistoryRow.approver_id = tempHistory.approver?._id
                        newHistoryRow.approver_email = tempHistory.approver?.email
                        newHistoryRow.approver_userinfo_id = tempHistory.approver?.userInfo?._id
                        newHistoryRow.approver_userinfo_phone = tempHistory.approver?.userInfo?.phone
                        newHistoryRow.approver_userinfo_name = tempHistory.approver?.userInfo?.name
                        newHistoryRow.approver_userinfo_email = tempHistory.approver?.userInfo?.email
                        
                        newApproval.addToHistory(newHistoryRow)
                        
                    }
                }
               
            
                
                var counter = 0
                if(tempApproval.reference?.item?.billingsInfo != nil){
                    
                    for tempBillingInfo in (tempApproval.reference?.item?.billingsInfo)!{
                        
                        let billingInfo = NSEntityDescription.insertNewObject(forEntityName: "BillingInfo", into: managedObjectContext) as! BillingInfo
                        
                        counter += 1
                        
                        billingInfo.orderID = Int32(counter)
                        billingInfo.id = tempBillingInfo._id
                        billingInfo.approval_id = tempApproval._id
                        billingInfo.approval_type = Int16(tempApproval.approval_type!)
                        billingInfo.billingElement_id = tempBillingInfo.billingElement?._id
                        billingInfo.billingElement_name = tempBillingInfo.billingElement?.name
                        billingInfo.sub_BillingElement_name = tempBillingInfo.nbilling?.name
                        billingInfo.billingElement_type =  Int16(tempBillingInfo.billingElement!.elementType!)
                        billingInfo.billingElement_agreeValItem = Int16(tempBillingInfo.billingElement!.agreeValItem!)
                        billingInfo.discountedAmt = tempBillingInfo.discountedAmt ?? 0.0
                        billingInfo.discountedRate = tempBillingInfo.discountedRate ?? 0.0
                        billingInfo.discountedPercent = tempBillingInfo.discountedPercent ?? 0.0
                        billingInfo.discountOnRate = tempBillingInfo.discountOnRate ?? 0.0
                        billingInfo.rate = tempBillingInfo.rate ?? 0.0
                        billingInfo.isIncoming = isIncoming
                        if(tempBillingInfo.qty != nil){
                            billingInfo.qty = tempBillingInfo.qty!
                        }
                        billingInfo.type = tempBillingInfo.type
                        
                        newApproval.addToBillingInfos(billingInfo)
                    }
                }
                
                
                for tempUpdateBy in tempApproval.updateBy!{
                    
                    let updateBy = NSEntityDescription.insertNewObject(forEntityName: "UpdateBy", into: managedObjectContext) as! UpdateBy
                    
                    updateBy.approval_id = tempApproval._id
                    updateBy.approval_type = Int16(tempApproval.approval_type!)
                    updateBy.date = tempUpdateBy.date
                    updateBy.descp = tempUpdateBy.descp
                    updateBy.src = Int32(tempUpdateBy.src!)
                    updateBy.isApproval = true
                    updateBy.id = tempUpdateBy._id
                    updateBy.user = tempUpdateBy.user
                    
                    newApproval.addToUpdateBy(updateBy)
                }
                
                if(tempApproval.reference?.item?.pricingInfo != nil){
                    
                    let pricingInfo = NSEntityDescription.insertNewObject(forEntityName: "ApprovalPricingInfo", into: managedObjectContext) as! ApprovalPricingInfo
                    
                    pricingInfo.approval_id = tempApproval._id
                    pricingInfo.approval_type = Int16(tempApproval.approval_type!)
                    pricingInfo.isIncoming = isIncoming
                    
                    let approvalPricingInfo = tempApproval.reference!.item!.pricingInfo!
                    pricingInfo.waiveOffCharges = approvalPricingInfo.waive_off_charges ?? 0.0
                    pricingInfo.transferChargePayableBy = approvalPricingInfo.transfer_charge_payable_by ?? 0.0
                    pricingInfo.taxPaid = approvalPricingInfo.tax_paid ?? 0.0
                    pricingInfo.taxReceived = approvalPricingInfo.tax_received ?? 0.0
                    pricingInfo.taxAmountRefund = approvalPricingInfo.tax_amount_refund ?? 0.0
                    pricingInfo.isTaxAmountRefund = approvalPricingInfo.is_tax_amount_refund ?? false
                    
                    pricingInfo.demandLetterAmount = approvalPricingInfo.demand_letter_amount ?? 0.0
                    pricingInfo.cancellationCharge = approvalPricingInfo.cancellation_charge ?? 0.0
                    pricingInfo.cancellationChargeTax = approvalPricingInfo.cancellation_charge_tax ?? 0.0
                    
                    
                    pricingInfo.amountDue = approvalPricingInfo.amount_due ?? 0.0
                    pricingInfo.amountPayable = approvalPricingInfo.amount_payable ?? 0.0
                    pricingInfo.amountReceived = approvalPricingInfo.amount_received ?? 0.0
                    pricingInfo.assignmentCharge = approvalPricingInfo.assignment_charge ?? 0.0
                    pricingInfo.assignmentChargeDebitNoteReference = approvalPricingInfo.assignment_charge_debit_note_reference ?? ""
                    pricingInfo.assignmentChargeReceiptReference = approvalPricingInfo.assignment_charge_receipt_reference ?? ""
                    pricingInfo.assignmentChargeTax = approvalPricingInfo.assignment_charge_tax ?? 0.0
                    
                    newApproval.pricingInfo = pricingInfo
                    
                }
            }
            do {
                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                completionHandler(true, nil)
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                completionHandler(false, nil)
            }
            
            //return results
        }
        
    }
    
    func writeOutstandings(cos : [Cos],completionHandler: @escaping (Bool?, Error?) -> ()){
        
        self.resetEntity(entityName: "CustomerOutstanding")
        self.resetEntity(entityName: "CosReceipts")
            
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
                    
            var counter = 0
            for eachCos in cos{
                
                let newOutstanding = NSEntityDescription.insertNewObject(forEntityName: "CustomerOutstanding", into: managedObjectContext) as! CustomerOutstanding
                newOutstanding.unitId = eachCos.unit?.id
                newOutstanding.unitNoIndex = Int32(eachCos.unit?.unitNo?.index ?? 0)
                newOutstanding.unitDisplayName = eachCos.unit?.unitNo?.displayName
                newOutstanding.floorIndex = Int32(eachCos.unit?.floor?.index ?? 0)
                newOutstanding.floorDisplayName = eachCos.unit?.floor?.displayName
                newOutstanding.towerId = eachCos.unit?.tower?.id
                newOutstanding.towerName = eachCos.unit?.tower?.name
                newOutstanding.projectId = eachCos.unit?.project?.id
                newOutstanding.projectName = eachCos.unit?.project?.name
                newOutstanding.blockId = eachCos.unit?.block?.id
                newOutstanding.blockName = eachCos.unit?.block?.name
                newOutstanding.bookingFormId = eachCos.unit?.bookingform?.id
                newOutstanding.demandLetterAmount = eachCos.demandLetterAmount ?? 0.0
                newOutstanding.demandLetterTax = eachCos.demandLetterTax ?? 0.0
                newOutstanding.totalReceipt = eachCos.totalReceipt ?? 0.0
                newOutstanding.outstandingsInRangs = eachCos.outstandingsInRange
                newOutstanding.lessThanThirtyDaysAmt = eachCos.outstandingsInRange![2]
                newOutstanding.thirtyToSixtyDaysAmt = eachCos.outstandingsInRange![2]
                newOutstanding.sixtyToNinetyDaysAmt = eachCos.outstandingsInRange![1]
                newOutstanding.greaterThanNinetyDaysAmt = eachCos.outstandingsInRange![0]
                newOutstanding.description1 = eachCos.unit?.unitDescription
                newOutstanding.index = Int32(counter)
                
                for cosClient in eachCos.unit?.bookingform?.clients ?? []{
                    newOutstanding.customerId = cosClient.id
                    newOutstanding.customerName = cosClient.customer?.name
                    newOutstanding.customerEmail = cosClient.customer?.email
                    newOutstanding.customerPhoneNumber = String(format: "%ld", cosClient.customer?.phone ?? 0)
                    newOutstanding.customerPhoneCode = cosClient.customer?.phoneCode
                    newOutstanding.cosCustomerId = cosClient.customer?.id
                    break
                }
                
                for eachReceipt in eachCos.receipts ?? []{
                    
                    let newCosReceipt = NSEntityDescription.insertNewObject(forEntityName: "CosReceipts", into: managedObjectContext) as! CosReceipts
                    newCosReceipt.id = eachReceipt.id
                    newCosReceipt.amount = eachReceipt.amount ?? 0.0
                    newCosReceipt.chequeDate = eachReceipt.chequeDate
                    newCosReceipt.depositDate = eachReceipt.depositDate
                    newCosReceipt.paymentDescp = eachReceipt.paymentDescp
                    newCosReceipt.paymentMode = eachReceipt.paymentMode
                    newCosReceipt.receiptNumber = eachReceipt.receiptNumber
                    newCosReceipt.receiptType = eachReceipt.receiptType
                    newCosReceipt.paymentTowards = eachReceipt.paymentTowards
                    newCosReceipt.bankAddress = eachReceipt.chequeBank?.bankAddress
                    newCosReceipt.bankBranch = eachReceipt.chequeBank?.bankBranch
                    newCosReceipt.bankIfscCode = eachReceipt.chequeBank?.bankIfscCode
                    newCosReceipt.chequeBankName = eachReceipt.chequeBank?.bankName
                    
                    newOutstanding.addToCosReceipts(newCosReceipt)
                }
                counter += 1
            }
            
            do {
                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                completionHandler(true, nil)
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                completionHandler(false, nil)
            }

        }
        
        
    }
    func writeReceitEntriesCount(entriesCount : [RECEIPT_TYPE_ENTRIES_COUNT],tab:Int,completionHandler: @escaping (Bool?, Error?) -> ()){
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ReceiptEntriesCount")
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = NSPredicate(format: "tab CONTAINS[c] %d", tab)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            _ = try managedObjectContext.execute(request)
            try managedObjectContext.save()
            
        } catch {
            fatalError("Failed to execute request: \(error)")
        }

        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
            
            for entryType in entriesCount{
                let newReceiptEntryType = NSEntityDescription.insertNewObject(forEntityName: "ReceiptEntriesCount", into: managedObjectContext) as! ReceiptEntriesCount
                newReceiptEntryType.count = Int64(entryType.count!)
                newReceiptEntryType.name =  entryType.name
                newReceiptEntryType.id = entryType._id
                newReceiptEntryType.tab = Int16(tab)
                newReceiptEntryType.totalcollected = entryType.totalcollected ?? 0.0
            }
            do {
                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                completionHandler(true, nil)
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                completionHandler(false, nil)
            }
            
            //return results
        }
    }
    func writeReceiptEntries(receiptEntries : [RECEIPT_ENTRIES],tab : Int,completionHandler: @escaping (Bool?, Error?) -> ()){
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ReceiptEntry")
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = NSPredicate(format: "tab == %d", tab)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            _ = try managedObjectContext.execute(request)
            try managedObjectContext.save()

        } catch {
            fatalError("Failed to execute request: \(error)")
        }
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
            
            for receiptEntry in receiptEntries{

                let newReceiptEntry = NSEntityDescription.insertNewObject(forEntityName: "ReceiptEntry", into: managedObjectContext) as! ReceiptEntry
                newReceiptEntry.id = receiptEntry._id
                newReceiptEntry.representStatus = Int32(receiptEntry.representStatus ?? 0)
                newReceiptEntry.bounceCount = Int32(receiptEntry.bounceCount ?? 0)
                newReceiptEntry.bounceCharges = Int64(receiptEntry.bounceCharges ?? 0)
                newReceiptEntry.status = Int32(receiptEntry.status!)
                if(receiptEntry.unit != nil && receiptEntry.unit?.status != nil){
                    newReceiptEntry.unitStatus = Int32(receiptEntry.unit!.status!)
                }
                newReceiptEntry.allocationStatus = Int32(receiptEntry.allocationStatus ?? 0)
                newReceiptEntry.allocationBalance = receiptEntry.allocationBalance ?? 0
                newReceiptEntry.images = receiptEntry.images
                newReceiptEntry.tab = Int16(tab)

                newReceiptEntry.project = receiptEntry.project
                
                let project = self.getProjectDetailsById(projectId: receiptEntry.project!)
                if(project != nil){
                    newReceiptEntry.projectName = project!.name
                }
                    
                newReceiptEntry.block = receiptEntry.block
                newReceiptEntry.tower = receiptEntry.tower
                newReceiptEntry.receiptType = receiptEntry.receiptType
                newReceiptEntry.paymentMode = receiptEntry.paymentMode
                newReceiptEntry.paymentTowards = receiptEntry.paymentTowards
                newReceiptEntry.depositDate = receiptEntry.depositDate
                newReceiptEntry.company_group = receiptEntry.company_group
                newReceiptEntry.receiptLocalId = receiptEntry.receiptLocalId
                newReceiptEntry.receiptNumber = receiptEntry.receiptNumber
                newReceiptEntry.createdDate = receiptEntry.createdDate
                newReceiptEntry.currency = receiptEntry.currency
                newReceiptEntry.createdBy = receiptEntry.createdBy?._id

                newReceiptEntry.amount = receiptEntry.amount ?? 0.0
                newReceiptEntry.curAmount = receiptEntry.curAmount ?? 0.0
                newReceiptEntry.baseAmount = receiptEntry.baseAmount ?? 0.0
                newReceiptEntry.taxAmount = receiptEntry.taxAmount ?? 00
                newReceiptEntry.projectBank = receiptEntry.projectBank

                if(receiptEntry.unit != nil){
                    newReceiptEntry.unitId = receiptEntry.unit?._id
                    newReceiptEntry.unitStatus = Int32(receiptEntry.unit!.status!)
                    newReceiptEntry.unitDescription = receiptEntry.unit?.description
                    newReceiptEntry.unitIndex = Int32(receiptEntry.unit!.unitNo!.index ?? -1)
                    newReceiptEntry.unitDisplayName = receiptEntry.unit?.unitNo?.displayName
                }

                newReceiptEntry.customerName = receiptEntry.customer?.name
                newReceiptEntry.customerEmail = receiptEntry.customer?.email
                newReceiptEntry.customerId = receiptEntry.customer?._id
                newReceiptEntry.customer_customerID = receiptEntry.customer?.customerId
                newReceiptEntry.customerPhone = String(format: "%ld", receiptEntry.customer?.phone ?? "")
                newReceiptEntry.phoneCode = receiptEntry.customer?.phoneCode
                
                newReceiptEntry.returnReason = receiptEntry.returnReason
                newReceiptEntry.referenceNumber = receiptEntry.referenceNumber
                newReceiptEntry.chequeDate = receiptEntry.chequeDate
                newReceiptEntry.chequeReturnDate = receiptEntry.chequeReturnDate
                
                let newChequeBank = NSEntityDescription.insertNewObject(forEntityName: "ChequeBank", into: managedObjectContext) as! ChequeBank
                newChequeBank.bankAddress = receiptEntry.chequeBank?.bankAddress
                newChequeBank.bankBranch = receiptEntry.chequeBank?.bankBranch
                newChequeBank.bankIfscCode = receiptEntry.chequeBank?.bankIfscCode
                newChequeBank.bankName = receiptEntry.chequeBank?.bankName
                
                newReceiptEntry.chequeBank = newChequeBank
                
                let updateBY = receiptEntry.updateBy?.first
                newReceiptEntry.updateByDate = updateBY?.date

                for tempUpdateBy in receiptEntry.updateBy!{
                    let newUpdateBy = NSEntityDescription.insertNewObject(forEntityName: "UpdateBy", into: managedObjectContext) as! UpdateBy
                    newUpdateBy.date = tempUpdateBy.date
                    newUpdateBy.descp = tempUpdateBy.descp
                    newUpdateBy.id = tempUpdateBy._id
                    newUpdateBy.user = tempUpdateBy.user
                    newUpdateBy.src = Int32(tempUpdateBy.src!)

                    newReceiptEntry.addToUpdateBy(newUpdateBy)
                }
            }
            
            do {
                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                completionHandler(true, nil)
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                completionHandler(false, nil)
            }
            
            //return results
        }
        
    }
    
    func writeAllEnquirySources(name : String,id : String,shouldReset : Bool) -> Bool{
        
        if(shouldReset){
            self.resetAllEnquirySources()
        }
         //  SOURCES ARE FROM DIFFERNT DICTS
        
//        for eSource in enquirySources{
            let newEnquirySource = NSEntityDescription.insertNewObject(forEntityName: "EnquirySources", into: managedObjectContext) as! EnquirySources
            newEnquirySource.id = id
            newEnquirySource.name = name
//        }
        do {
            try managedObjectContext.save()
            return true
        } catch let error as NSError {
            print("Could not save EnquirySources. \(error), \(error.userInfo)")
            return false
        }
    }
    func writeNotificationsToDB(notifications : [PUSH_NOTIFICATIONS]){
        
        self.resetEntity(entityName: "Notifications")
    
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
        
            for notification in notifications{
                
                let newNotificatoinObj = NSEntityDescription.insertNewObject(forEntityName: "Notifications", into: managedObjectContext) as! Notifications
                
                newNotificatoinObj.id = notification._id
                newNotificatoinObj.is_read = notification.is_read
                newNotificatoinObj.created_at = notification.created_at
                newNotificatoinObj.updated_at = notification.updated_at
                newNotificatoinObj.user_id = notification.user_id
                newNotificatoinObj.msg = notification.msg
                newNotificatoinObj.company_group = notification.company_group
                newNotificatoinObj.type = notification.type
                newNotificatoinObj.v = Int16(notification.__v ?? 0)
                newNotificatoinObj.refererenceItem = notification.reference?.item
                newNotificatoinObj.refererenceKind = notification.reference?.kind
                
                /*
                 || it.type ==  || it.type ==
                 || it.type == Notification.ASSIGNMENT_REQUEST || it.type == Notification.CANCEL_REQUEST}
 */
                
                switch notification.type {
                case NOTIFICATION_TYPES.CALL_UPDATE.rawValue:
                    newNotificatoinObj.prospectType = "CU"
                    newNotificatoinObj.isPriority = true
                    break
                case NOTIFICATION_TYPES.PROSPECT_CALL_REMINDER.rawValue:
                    newNotificatoinObj.prospectType = "PC"
                    newNotificatoinObj.isPriority = true
                    break;
                case NOTIFICATION_TYPES.PROSPECT_ASSIGNED.rawValue:
                    newNotificatoinObj.prospectType = "PR"
                    newNotificatoinObj.isAccepted = 0
                    newNotificatoinObj.isPriority = false
                    break;
                case NOTIFICATION_TYPES.DISCOUNT_REQUEST.rawValue:
                    newNotificatoinObj.prospectType = "DR"
                    newNotificatoinObj.isAccepted = 0
                    newNotificatoinObj.isPriority = true
                    break;
                case NOTIFICATION_TYPES.APPROVED_DISCOUNT_REQUEST.rawValue:
                    newNotificatoinObj.prospectType = "DR"
                    newNotificatoinObj.isAccepted = 1
                    newNotificatoinObj.isPriority = false
                    break;
                case NOTIFICATION_TYPES.REJECTED_DISCOUNT_REQUEST.rawValue:
                    newNotificatoinObj.prospectType = "DR"
                    newNotificatoinObj.isAccepted = 2
                    newNotificatoinObj.isPriority = false
                    break;
                case NOTIFICATION_TYPES.CANCEL_REQUEST.rawValue:
                    newNotificatoinObj.prospectType = "CR"
                    newNotificatoinObj.isAccepted = 0
                    newNotificatoinObj.isPriority = true
                    break;
                case NOTIFICATION_TYPES.APPROVED_CANCEL_REQUEST.rawValue:
                    newNotificatoinObj.prospectType = "CR"
                    newNotificatoinObj.isAccepted = 1
                    newNotificatoinObj.isPriority = false
                    break;
                case NOTIFICATION_TYPES.REJECTED_CANCEL_REQUEST.rawValue:
                    newNotificatoinObj.prospectType = "CR"
                    newNotificatoinObj.isAccepted = 2
                    newNotificatoinObj.isPriority = false
                    break;
                case NOTIFICATION_TYPES.ASSIGNMENT_REQUEST.rawValue:
                    newNotificatoinObj.prospectType = "AR"
                    newNotificatoinObj.isAccepted = 0
                    newNotificatoinObj.isPriority = true
                    break;
                case NOTIFICATION_TYPES.APPROVED_ASSIGNMENT_REQUEST.rawValue:
                    newNotificatoinObj.prospectType = "AR"
                    newNotificatoinObj.isAccepted = 1
                    newNotificatoinObj.isPriority = false
                    break;
                case NOTIFICATION_TYPES.REJECTED_ASSIGNMENT_REQUEST.rawValue:
                    newNotificatoinObj.prospectType = "AR"
                    newNotificatoinObj.isAccepted = 2
                    newNotificatoinObj.isPriority = false
                    break;
                case NOTIFICATION_TYPES.TRANSFER_REQUEST.rawValue:
                    newNotificatoinObj.prospectType = "TR"
                    newNotificatoinObj.isAccepted = 0
                    newNotificatoinObj.isPriority = true
                    break;
                case NOTIFICATION_TYPES.APPROVED_TRANSFER_REQUEST.rawValue:
                    newNotificatoinObj.prospectType = "TR"
                    newNotificatoinObj.isAccepted = 1
                    newNotificatoinObj.isPriority = false
                    break;
                case NOTIFICATION_TYPES.REJECTED_TRANSFER_REQUEST.rawValue:
                    newNotificatoinObj.prospectType = "TR"
                    newNotificatoinObj.isAccepted = 2
                    newNotificatoinObj.isPriority = false
                    break;
                case NOTIFICATION_TYPES.DISCOUNT_APPROVAL.rawValue:
                    newNotificatoinObj.prospectType = "DA"
                    newNotificatoinObj.isAccepted = 0
                    newNotificatoinObj.isPriority = false
                    break
                default:
                    newNotificatoinObj.prospectType = "PR"
                    newNotificatoinObj.isAccepted = 0
                    newNotificatoinObj.isPriority = false
                    break;
                }
            }
            
            do {
                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    func getSchemeByID(schemeID : String)->String{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Schemes")
        fetchRequest.resultType = .managedObjectResultType
        let predicate = NSPredicate(format: "id CONTAINS[c] %@", schemeID)
        fetchRequest.predicate = predicate
        let schemesList = try! managedObjectContext.fetch(fetchRequest)
        
        if(schemesList.count > 0){
            let scheme = schemesList[0] as! Schemes
            return scheme.name!
        }
        else{
            return ""
        }

    }
    func writeSchemesToDB(schmes : [SCHEMES]){
        
        self.resetEntity(entityName: "Schemes")
        
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
            
            for eachScheme in schmes{
                let newScheme = NSEntityDescription.insertNewObject(forEntityName: "Schemes", into: managedObjectContext) as! Schemes
                newScheme.id = eachScheme._id
                newScheme.name = eachScheme.name
                newScheme.project = eachScheme.project
                newScheme.endDate = eachScheme.endDate
                newScheme.startDate = eachScheme.startDate
                newScheme.description1 = eachScheme.description
                newScheme.company_group = eachScheme.compnay_group
            }
            
            do {
                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    func writeCommissionsToDB(commissions : [COMMISSION_CONFIG]){
        
        self.resetEntity(entityName: "Commissions")
        
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
            
            for eachCommission in commissions{
                
                let newCommission = NSEntityDescription.insertNewObject(forEntityName: "Commissions", into: managedObjectContext) as! Commissions
                newCommission.id = eachCommission._id
                newCommission.commissionID = eachCommission.individual?.id?._id
                newCommission.commissionName = eachCommission.individual?.id?.name
                newCommission.isAgent = eachCommission.individual?.id?.isAgent ?? false
                newCommission.phone = eachCommission.individual?.id?.phone //String(format: "%d", eachCommission.individual?.id?.phone ?? "")
                newCommission.kind = eachCommission.individual?.kind
            }
            
            do {
                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    func getCommissionsFromDB()-> Array<Commissions>{
        
        let activityInfo = NSFetchRequest<NSFetchRequestResult>(entityName: "Commissions")
        
        do {
            let sortDescriptor = NSSortDescriptor(key: "commissionName", ascending: true)
            let sortDescriptors = [sortDescriptor]
            activityInfo.sortDescriptors = sortDescriptors
            
            let fetchedActivities = try managedObjectContext.fetch(activityInfo) as! [Commissions]
            return fetchedActivities
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
        }
    }
    func writeAllDriversToDB(drivers : [DRIVER]) -> Bool
    {
        self.resetAllDrivers()
    
        for driver in drivers{
            
            let newDriverObj = NSEntityDescription.insertNewObject(forEntityName: "Driver", into: managedObjectContext) as! Driver
            
            newDriverObj.id = driver._id
            newDriverObj.name = driver.name
            newDriverObj.phone = driver.phone
            newDriverObj.status = Int32(driver.status!)
            newDriverObj.vehicle = driver.vehicle?._id
            
//            let vehicle = NSEntityDescription.insertNewObject(forEntityName: "Vehicle", into: managedObjectContext) as! Vehicle
//            vehicle.id = driver.vehicle?._id
//            vehicle.plateNo = driver.vehicle?.plateNo
//            vehicle.projectName = driver.vehicle?.project?.name
//            vehicle.projectId = driver.vehicle?.project?._id
//            if(driver.vehicle?.status != nil){
//                vehicle.status = Int32(driver.vehicle!.status!)
//            }
//            vehicle.vehicleType = driver.vehicle?.vehicleType
//            vehicle.company_group = driver.vehicle?.company_group
//            
//            newDriverObj.vehicles = vehicle
            
//            let vehicle = newDriverObj.vehicles
//            print(vehicle)
        }
        
        do {
            try managedObjectContext.save()
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
    }
    func writeAllVehiclesToDB(vehicles : [VEHICLE]) -> Bool{
        
        self.resetAllVehicles()
        
        for vehicle in vehicles{
            
            let newVehicleObj = NSEntityDescription.insertNewObject(forEntityName: "Vehicle", into: managedObjectContext) as! Vehicle
            
            newVehicleObj.id = vehicle._id
            newVehicleObj.plateNo = vehicle.plateNo
            newVehicleObj.company_group = vehicle.company_group
            newVehicleObj.projectName = vehicle.project?.name
            newVehicleObj.projectId = vehicle.project?._id
            newVehicleObj.vehicleType = vehicle.vehicleType
            newVehicleObj.status = Int32(vehicle.status!)
        }
        
        do {
            try managedObjectContext.save()
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
    }
    func writeEmployeeDataToDB(employees : [EMPLOYEE])-> Bool{
        
        self.resetAllEmployees()
        
        for employee in employees{
            
//            let userINfo = employee.userInfo
            
            let tempEmployee = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: managedObjectContext) as! Employee
            
            tempEmployee.empId = employee._id
            tempEmployee.id = employee.userInfo?._id
            tempEmployee.name = employee.userInfo?.name
            tempEmployee.email = employee.email
            tempEmployee.roles = employee.userInfo?.roles
            tempEmployee.projects = employee.userInfo?.projects
            tempEmployee.towers = employee.userInfo?.towers
            tempEmployee.blocks = employee.userInfo?.blocks
            tempEmployee.empStatus = (employee.empStatus == 1) ? true : false
        }

        do {
            try managedObjectContext.save()
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
    }
    func writeNotInterestedReasonsToDB(css : [CUSTOMER_STATUS_SOURCES]){
        
            self.resetEntity(entityName: "NotInterestedCause")
        
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
            
            var counter = 0
            for cSource in css{
                
                for data in cSource.data!{
                    
                    let eachReason = NSEntityDescription.insertNewObject(forEntityName: "NotInterestedCause", into: managedObjectContext) as! NotInterestedCause
                    eachReason.id = data._id
                    eachReason.name = data.name
                    eachReason.index = Int32(counter)
                    counter += 1
                    
                    //                    _ = RRUtilities.sharedInstance.model.writeAllEnquirySources(name: data.name!, id: data._id!, shouldReset: false)
                }
            }
            
            do {
                try managedObjectContext.save()
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                
            }
        }
    }
    func writeEnquirySourcesToDB(enquirySources : [NEW_ENQUIRY_SOURCES]){
        
        self.resetEntity(entityName: "NewEnquirySources")
        
        for eSource in enquirySources{
            let enqSource = NSEntityDescription.insertNewObject(forEntityName: "NewEnquirySources", into: managedObjectContext) as! NewEnquirySources
            enqSource.id = eSource._id
            enqSource.name = eSource.name
            enqSource.displayName = eSource.displayName
        }
        do {
            try managedObjectContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            
        }
    }
    func resetEntity(entityName : String){
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try managedObjectContext.execute(deleteRequest)
            try managedObjectContext.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
    func writeBlocksToDB(projectDetails: ProjectDetails,projectID : String){
        
        let allBlocks : [BlockDetails] = projectDetails.blocks!
        
        
        if((projectDetails.towers?.count)! > 0){
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Blocks")
            fetch.returnsObjectsAsFaults = false
            fetch.predicate = NSPredicate(format: "project CONTAINS[c] %@", projectID)
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            
            do {
                _ = try managedObjectContext.execute(request)
//                print(result)
                print("DELETED BLOCKSSSS")
            } catch {
                fatalError("Failed to execute request: \(error)")
            }
        }
        else{
            return
        }

        
//        self.resetEntity(entityName: "Blocks")
        
        // *** Remove Blocks **
        
//        self.resetEntity(entityName: "Blocks")
        
        var blockCounter : Int = 0
        
//        for block in allBlocks{
//
//            let tempBlockRow = NSEntityDescription.insertNewObject(forEntityName: "Blocks", into: managedObjectContext) as! Blocks
//
//            tempBlockRow.index = Int32(blockCounter)
//            blockCounter = blockCounter + 1
//            tempBlockRow.id = block._id
//            tempBlockRow.name = block.name
//            tempBlockRow.builtUpArea = block.builtUpArea?.nsDictionary
//            tempBlockRow.superBuiltUpArea = block.superBuiltUpArea?.nsDictionary
//            tempBlockRow.landArea = block.landArea?.nsDictionary
//            tempBlockRow.project = block.project
//            tempBlockRow.short_name = block.short_name
//            tempBlockRow.stage = block.stage
//            tempBlockRow.status = Int16(block.status!)
//            tempBlockRow.company_group = block.company_group
//
//            let towers = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(block._id!))! }
//
//            tempBlockRow.numberOfTowers = Int32(towers.count)
//
//            let units = projectDetails.units!.filter { ($0.block?.localizedCaseInsensitiveContains(block._id!))! }
//
//            tempBlockRow.numberOfUnits = Int64(units.count)
//
//            var customer = CUSTOM_STAT.init()
//
//            customer.stats = block.stats!
//            var tempDict : NSMutableDictionary = NSMutableDictionary.init()
////            tempDict["temper"] = customer.nsArray
//            tempDict.setValue(customer.nsArray, forKey: "temper")
//            tempBlockRow.stats = tempDict
//
////            print(tempBlockRow)
//
//
////            let orderdSet : NSMutableOrderedSet = []
////
////            if(block.stats?.count != nil){
////
////                for tempStat in block.stats!{
////                    if(tempStat.count == nil){
////                        continue
////                    }
////                    let friend1 = TempObj(context: managedObjectContext)
////                    friend1.count = Int64(tempStat.count!)
////                    friend1.status = Int16(tempStat.status!)
////                    orderdSet.add(friend1)
////                    tempBlockRow.addToBlockStats(friend1)
////                }
////
////                tempBlockRow.setValue(orderdSet, forKey: "blockStats")
////
////                print(tempBlockRow.blockStats)
////
////                //                tempPro.stats = projDict.stats as NSArray?
////                //                print("fdfdf \(tempPro.stats)")
////            }
////            else{
////                print("NO STATSSS")
////                //                 tempPro.stats = []
////                //                continue
////            }
//
//
//        }
//
//                    do {
//                        try managedObjectContext.save()
//                    } catch let error as NSError {
//                        print("Could not save. \(error), \(error.userInfo)")
//                    }
//
//        return
        
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in

            for block in allBlocks{
                
                let tempBlockRow = NSEntityDescription.insertNewObject(forEntityName: "Blocks", into: managedObjectContext) as! Blocks
                
                tempBlockRow.index = Int32(blockCounter)
                blockCounter = blockCounter + 1
                tempBlockRow.id = block._id
//                print(block.name)
                tempBlockRow.name = block.name
                tempBlockRow.builtUpArea = block.builtUpArea?.nsDictionary
                tempBlockRow.superBuiltUpArea = block.superBuiltUpArea?.nsDictionary
                let tempDct : NSDictionary = tempBlockRow.superBuiltUpArea as! NSDictionary
//                print(tempDct[""])
                tempBlockRow.landArea = block.landArea?.nsDictionary
                tempBlockRow.project = block.project
                tempBlockRow.short_name = block.short_name
                tempBlockRow.stage = block.stage
                tempBlockRow.status = Int64(block.status!)
                tempBlockRow.company_group = block.company_group
                
                let towers = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(block._id!))! }
                
                tempBlockRow.numberOfTowers = Int32(towers.count)
                var towerNamesInBlock : [String] = []
                for tempTower in towers{
                    towerNamesInBlock.append(tempTower.name!)
                }
                tempBlockRow.towers = towerNamesInBlock
                tempBlockRow.towersCount = Int32(towerNamesInBlock.count)
                
                let units = projectDetails.units!.filter { ($0.block?.localizedCaseInsensitiveContains(block._id!))! }
                
                tempBlockRow.numberOfUnits = Int64(units.count)
                
                
                var customer = CUSTOM_STAT.init()
                
//                customer.stats = block.stats!
//                let tempDict : NSMutableDictionary = NSMutableDictionary.init()
//                //            tempDict["temper"] = customer.nsArray
//                tempDict.setValue(customer.nsArray, forKey: "stats")
//                tempBlockRow.stats = tempDict
//
//                print(tempBlockRow.stats)
                
                let orderdSet : NSMutableOrderedSet = []
                
                if(block.stats?.count != nil){
                    
                    for tempStat in block.stats!{
                        if(tempStat.count == nil || tempStat.status == nil){
                            continue
                        }
                        let friend1 = TempObj(context: managedObjectContext)
                        friend1.count = Int64(tempStat.count!)
                        friend1.status = Int16(tempStat.status!)
                        orderdSet.add(friend1)
                        tempBlockRow.addToBlockStats(friend1)
                    }
                    
                    tempBlockRow.setValue(orderdSet, forKey: "blockStats")
                }
                else{
//                    print("NO STATSSS")
                }
            }
            
            
            do {
                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true

            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                
            }
        }

    }
    func writeTowersToDB(projectDetails: ProjectDetails, projectID:String)
    {
//        self.resetEntity(entityName: "Towers")
        
        if((projectDetails.towers?.count)! > 0){
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Towers")
            fetch.returnsObjectsAsFaults = false
            fetch.predicate = NSPredicate(format: "project CONTAINS[c] %@", projectID)
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            
            do {
                _ = try managedObjectContext.execute(request)
                print("DELETED TOWERSSSS")
//                print(result)
            } catch {
                fatalError("Failed to execute request: \(error)")
            }
        }
        else{
            return
        }

        
        let allTowres : [TOWERDETAILS] = projectDetails.towers!
        var towerIndex = 0
        for tower in allTowres{
         
            let tempTowerRow = NSEntityDescription.insertNewObject(forEntityName: "Towers", into: managedObjectContext) as! Towers
            
            tempTowerRow.block = tower.block
            let blocks = projectDetails.blocks!.filter { ($0._id?.localizedCaseInsensitiveContains(tower.block!))! }
            
            let filterredUnits = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(tower._id!))! }
            tempTowerRow.unitsCount = Int64(filterredUnits.count)
            tempTowerRow.blockName = blocks[0].name
            tempTowerRow.towerIndex = Int64(towerIndex)
            towerIndex = towerIndex + 1
            
            tempTowerRow.project = tower.project
            tempTowerRow.company_group = tower.company_group
            tempTowerRow.hasImages = tower.images != nil ? true : false
            tempTowerRow.id = tower._id
//            print(tower.name)
            tempTowerRow.name = tower.name
            tempTowerRow.short_name = tower.short_name
            tempTowerRow.status = Int64(tower.status!)
            tempTowerRow.builtUpArea = tower.builtUpArea?.nsDictionary
            tempTowerRow.landArea = tower.landArea?.nsDictionary
            tempTowerRow.superBuiltUpArea = tower.superBuiltUpArea?.nsDictionary
            tempTowerRow.starting_floor = tower.starting_floor
            tempTowerRow.images = tower.images
            tempTowerRow.towerType = Int16(tower.towerType!)
            
            if(tower.total_floors != nil && tower.total_floors! > 0){
                tempTowerRow.total_floors = Int64(tower.total_floors!)
            }
            else{
                tempTowerRow.total_floors = Int64(0)
            }
            if(tower.units_per_floor != nil && tower.units_per_floor! > 0){
                tempTowerRow.units_per_floor = Int64(tower.units_per_floor!)
            }
            else{
                tempTowerRow.units_per_floor = Int64(0)
            }
            
//            print(tempTowerRow.images)
            
//            tempTowerRow.images = (tower.images as! NSObject)
        }

        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        //            self.persistentContainer.performBackgroundTask { (managedObjectContext) in
        //
        //                //            managedObjectContext.save()
        //                do {
        //                    try managedObjectContext.save()
        //                    self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        //
        //                    //            self.getAllProjects()
        //                    //                return true
        //                } catch let error as NSError {
        //                    print("Could not save. \(error), \(error.userInfo)")
        //                    //                return false
        //                }
        //                //
        //            }

    }
    func buildFloatingButtonDataSource(projectDetails: ProjectDetails,projectID : String){
        
        
        
    }
    func writeUnitsToDB(projectDetails: ProjectDetails,projectID : String)
    {
     
//        let units : [UnitDetails] = projectDetails.units!
        
        // Delete existing Records?
//        self.getAllUnits()
        
//        self.resetAllUnits()
//        self.resetEntity(entityName: "LandOwner")
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "LandOwner")
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = NSPredicate(format: "project CONTAINS[c] %@", projectID)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            _ = try managedObjectContext.execute(request)
//            print(result)
        } catch {
            fatalError("Failed to execute request: \(error)")
        }

        if((projectDetails.units?.count)! > 0){
//            self.resetAllUnits()
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Units")
            fetch.returnsObjectsAsFaults = false
            fetch.predicate = NSPredicate(format: "project CONTAINS[c] %@", projectID)
            
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            
            do {
//                try managedObjectContext.persistentStoreCoordinator?.execute(request, with: managedObjectContext)
                _ = try managedObjectContext.execute(request)
//                print(result)
                print("DELETED UNITSSSSSS")
            } catch {
                fatalError("Failed to execute request: \(error)")
            }
        }
        else{
            return
        }
        
        var sectionIndex = 0
        var lastSectionTitle = ""
        
        var dbSaveCounter = 0
        
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
            
            for tempBlock in projectDetails.blocks!{
                
                let blockId = tempBlock._id
                
//                let towers = projectDetails.towers!.filter { ($0.block == blockId!) }
                var towers : [TOWERDETAILS] = []
                
                for eachTower in projectDetails.towers!{
                    if(eachTower.block == blockId!){
                        towers.append(eachTower)
                    }
                }
                
                    //(projectDetails.towers!.count > 1) ? projectDetails.towers!.filter { ($0.block == blockId!) } : projectDetails.towers ?? []
                
                for tempTower in towers{
                    
                    let towerId = tempTower._id
                    
//                    var filterredUnits = projectDetails.units!.filter { ($0.tower == towerId!) }
                    
                    var filterredUnits : [UnitDetails] = []
                    
                    for eachUnit in projectDetails.units!{
                        if(eachUnit.tower == towerId!){
                            filterredUnits.append(eachUnit)
                        }
                    }
                    
//                    if(filterredUnits.count > 0 && filterredUnits[0].floor?.index != nil){
//                        filterredUnits.sort { ($0.floor?.index ?? 0) <= ($1.floor?.index ?? 0) }
//                    }
//                    filterredUnits.sort { ($0.unitNo?.index ?? 0) <= ($1.unitNo?.index ?? 0) }
                    
                    
                    if(tempTower.towerType == 0){
                        //                    var sectionIndex = 0
                        //                    var lastFloorIndex = filterredUnits[0].floor?.index
                        for unit in filterredUnits{
                            
                            let floorIndex = unit.floor?.index
                            let floorDisplayName = unit.floor?.displayName
                            
                            var sectionTitle = ""
                            
                            if(floorIndex == nil){
                                sectionTitle = String(format: "%@ - %@ - %@", tempBlock.name! , tempTower.name!,floorDisplayName ?? "")
                            }
                            else{
                                sectionTitle = String(format: "%@ - %@ - %d", tempBlock.name! , tempTower.name!,floorIndex!)
                            }
                            
                            let tempUnitRow = NSEntityDescription.insertNewObject(forEntityName: "Units", into: managedObjectContext) as! Units
                            tempUnitRow.id = unit._id
                            tempUnitRow.unitDisplayName = unit.unitNo?.displayName
                            if(unit.unitNo != nil && unit.unitNo?.index != nil){
                                tempUnitRow.unitIndex = Int64(unit.unitNo!.index!)
                            }
                            else{
                                let unitIndex = Int(unit.unitNo!.displayName!) ?? -1
                                if(unitIndex != -1){
                                    tempUnitRow.unitIndex = Int64(unitIndex)
                                }
                            }
//                            print(tempUnitRow.unitIndex)
                            tempUnitRow.unitNo = unit.unitNo?.nsDictionary
                            //            print(unit.unitNo?.nsDictionary)
                            //            print(unit.floor?.nsDictionary)
                            tempUnitRow.floor = unit.floor?.nsDictionary
                            if(unit.floor?.index != nil){
                                tempUnitRow.floorIndex = Int32(unit.floor!.index!)
                            }
                            tempUnitRow.floorDisplayName = unit.floor?.displayName
                            //            print(unit.type?.nsDictionary)
                            ////            tempUnitRow.type = unit.type?.nsDictionary
                            //            print(tempUnitRow.type)
                            
                            tempUnitRow.sectionTitle = sectionTitle
                            
                            if(lastSectionTitle != sectionTitle){
                                //                            lastFloorIndex = floorIndex
                                if(lastSectionTitle != ""){
                                    sectionIndex = sectionIndex + 1
                                }
                                lastSectionTitle = sectionTitle
                            }
                            
                            //                        print(sectionIndex)
                            
                            tempUnitRow.sectionIndex = Int32(sectionIndex)
                            
                            //                        if(unit.floorPremium != nil){
                            //                            tempUnitRow.floorPremium = unit.floorPremium?.nsDictionary
                            //                        }
                            
                            
                            tempUnitRow.towerType = Int16(tempTower.towerType!)
                            
                            tempUnitRow.towerImageExist = ((tempTower.images?.count)! > 0) ? true : false
                            
                            tempUnitRow.project = unit.project
                            tempUnitRow.tower = unit.tower
                            tempUnitRow.block = unit.block
                            tempUnitRow.blockingReason = unit.blockingReason
                            tempUnitRow.bookingFormID = unit.bookingform?._id
                            tempUnitRow.bookingFormSatus = Int16(unit.bookingform?.status ?? -1)
                            tempUnitRow.manageUnitStatusStr = unit.manageUnitStatus
//                            print(unit.manageUnitStatus)
                            
                            tempUnitRow.blockName = tempBlock.name!
                            tempUnitRow.towerName = tempTower.name!
                            
                            tempUnitRow.schemes = (unit.type?.schemes?.count ?? 0 > 0) ? (unit.type?.schemes) : []
                            
                            if(unit.landowner != nil){
                                let landOwner = NSEntityDescription.insertNewObject(forEntityName: "LandOwner", into: managedObjectContext) as! LandOwner
                                landOwner.id = unit.landowner?._id
                                landOwner.name = unit.landowner?.name
                                landOwner.address = unit.landowner?.address
                                landOwner.contactPerson = unit.landowner?.contactPerson
                                landOwner.email = unit.landowner!.email
                                landOwner.phoneNo = unit.landowner?.phoneNo
                                landOwner.shortName = unit.landowner?.shortName
                                landOwner.parentId = unit._id
                                landOwner.project = unit.project
                                
                                tempUnitRow.hasLandOwner = true
                                
                                tempUnitRow.owner = landOwner
                            }
                            else{
                                tempUnitRow.hasLandOwner = false
                            }
                            
                            //TYpes , sales person , cleint id , sale value,
                            //superBuiltUpArea,carpet area, car parks ,billingElementForPricing , floorPlan
                            
                            if(unit.type != nil && unit.type?.carParks != nil){
                                
                                let tempCars : [CarParks] = (unit.type?.carParks)!
                                
                                var carParkCOunter = 0
                                
                                for temper in tempCars{
                                    if(temper.cType != nil){
                                        carParkCOunter = carParkCOunter + 1
                                        let carsRow = NSEntityDescription.insertNewObject(forEntityName: "UnitCarParks", into: managedObjectContext) as! UnitCarParks
                                        carsRow.id = temper._id
                                        carsRow.parentId = unit._id
                                        carsRow.count = Int64(temper.count ?? 0)
                                        carsRow.cType = temper.cType
                                        tempUnitRow.addToCarParkings(carsRow)
                                        //                                    let cars = tempUnitRow.mutableSetValue(forKey: "UnitCarParks")
                                        //                                    cars.add(carsRow)
                                    }
                                }
                                tempUnitRow.carParksCount = Int64(carParkCOunter)
                            }
                            
                            //                        print(tempUnitRow.carParkings)
                            
                            // *** BOOKING FORM CLIENTS ****
                            if(unit.bookingform?.clients?.count ?? 0 > 0){
                                let clients = unit.bookingform?.clients
                                for eachClient in clients ?? []{
                                    let customer = eachClient.customer
                                    let newClient = NSEntityDescription.insertNewObject(forEntityName: "BookingFormClients", into: managedObjectContext) as! BookingFormClients
                                    newClient.name = customer?.name
                                    newClient.customerId = customer?.customerId
                                    newClient.client = customer?.clientId
                                    newClient.phone = String(format: "%ld", customer?.phone ?? 0)
                                    newClient.email = customer?.email
                                    newClient.share = Double(eachClient.share ?? 0)
                                    tempUnitRow.addToBookedClient(newClient)
                                }
                            }
                         // *** BOOKING FORM CLIENTS ****

                            // *** car parks , Floor premium **
                            
                            if(unit.bookingform?.salesPerson?.userInfo != nil){
                                tempUnitRow.salesPersonUserInfoName = unit.bookingform?.salesPerson?.userInfo?.name
                                tempUnitRow.salesPersonUserInfoEmail = unit.bookingform?.salesPerson?.userInfo?.email
                                tempUnitRow.salesPersonUserInfoId = unit.bookingform?.salesPerson?.userInfo?._id
                                tempUnitRow.salesPersonUserInfoPhone = unit.bookingform?.salesPerson?.userInfo?.phone
                            }
                            tempUnitRow.typeName = unit.type?.name
                            if(unit.bookingform?.salesPerson != nil){
                                tempUnitRow.salesPersonId = unit.bookingform?.salesPerson?._id
                                tempUnitRow.salesPersonEmail = unit.bookingform?.salesPerson?.email
                            }
                            
                            if(unit.clientId != nil){
                                tempUnitRow.clientId = unit.clientId
                            }
                            if(unit.salevalue != nil){
                                tempUnitRow.salevalue = unit.salevalue!
                            }
                            
                            if(unit.type?.superBuiltUpArea != nil){
                                tempUnitRow.superBuiltUpArea = NSDecimalNumber.init(value: unit.type!.superBuiltUpArea!.value!)
                                if(unit.type?.superBuiltUpArea != nil && unit.type?.superBuiltUpArea?.uom != nil && unit.type?.superBuiltUpArea?.uom != "nil"){
                                    tempUnitRow.superBuiltUpAreaUOM = unit.type?.superBuiltUpArea?.uom ?? ""
                                }
                            }
                            if(unit.type?.carpetArea != nil){
                                tempUnitRow.carpetArea = NSDecimalNumber.init(value: unit.type!.carpetArea!.value!)
                                if(unit.type?.carpetArea?.uom != nil && unit.type?.carpetArea?.uom != "nil"){
                                    tempUnitRow.capetAreaUOM = unit.type?.carpetArea?.uom ?? ""
                                }
                            }
                            if(unit.type?.balconyArea != nil){
                                tempUnitRow.balconyArea = NSDecimalNumber.init(value: unit.type!.balconyArea?.value ?? 0.00)
                                tempUnitRow.balconyAreaUOM = unit.type?.balconyArea?.uom ?? ""
                            }
                            
                            tempUnitRow.agreeValItemRate = unit.agreeValItemRate ?? 0.0
                            tempUnitRow.rate = unit.rate ?? 0.0
                            tempUnitRow.gst = unit.gst ?? 0.0
                            tempUnitRow.totalCost = unit.totalCost ?? 0.0
                            
                            tempUnitRow.floorPremium = unit.floorPremium?.name
                            
                            let otherPRemiums = unit.otherPremiums
                            
                            var otherPremiumsArray : [String] = []
                            
                            for tempPremium in otherPRemiums!{
                                otherPremiumsArray.append(tempPremium?.name ?? "")
                                
                                let otherPremium = NSEntityDescription.insertNewObject(forEntityName: "OtherPremiums", into: managedObjectContext) as! OtherPremiums
                                otherPremium.name = tempPremium?.name
                                otherPremium.id = tempPremium?._id
                                otherPremium.parentId = unit._id
                                
//                                tempUnitRow.addToAllOtherPremiums(otherPremium)
                            }
                            tempUnitRow.otherPremiums = otherPremiumsArray
                            if((unit.otherPremiums?.count)! > 0){
                                tempUnitRow.otherPremiumsCount = Int32(unit.otherPremiums!.count)
                            }
                            else{
                                tempUnitRow.otherPremiumsCount = 0
                            }
                            
                            if(unit.type?.floorPlan != nil){
                                tempUnitRow.hasImages = ((unit.type?.floorPlan?.count)! > 0) ? true : false
                            }
                            
                            if(tempUnitRow.hasImages){
                                var imagesArray : [String] = []
                                let floorPlans = unit.type?.floorPlan
                                
                                for floorPlan in floorPlans!{
                                    imagesArray.append(floorPlan.url!)
                                }
                                tempUnitRow.floorPlanImages = imagesArray
                            }
                            
                            //                        tempUnitRow.type = unit.type?.nsDictionary
                            
                            tempUnitRow.status = Int64(unit.status!)
//                            if(unit.status! == 3){
//                                print("")
//                            }
                            tempUnitRow.description1 = unit.description
                            tempUnitRow.company_group = unit.company_group
                            tempUnitRow.facing = unit.facing
                            if(unit.type?.bedRooms != nil){
                                tempUnitRow.bedRooms = NSDecimalNumber.init(value: unit.type?.bedRooms ?? 0.0) //Int32(unit.type!.bedRooms!)
                            }
                            if(unit.type?.bathRooms != nil){
                                tempUnitRow.bathRooms = NSDecimalNumber.init(value: unit.type?.bathRooms ?? 0.0)//Int32(unit.type!.bathRooms!)
                            }
                            
                            //                        print(tempUnitRow)
                            
                        }
                        dbSaveCounter = dbSaveCounter + 1
                        
                        if(dbSaveCounter == 10){ //save
                            do {
                                try managedObjectContext.save()
                                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                                dbSaveCounter = 0
                            } catch let error as NSError {
                                print("Could not save. \(error), \(error.userInfo)")
                                
                            }
                        }
                    }
                    else{
                        
                        //                    var sectionIndex = 0
                        //                    var lastSectionTitle = String(format: "%@ - %@", tempBlock.name! , tempTower.name!)
                        
                        for unit in filterredUnits{
                            
                            let sectionTitle = String(format: "%@ - %@", tempBlock.name! , tempTower.name!)
                            
                            if(lastSectionTitle != sectionTitle){
                                lastSectionTitle = sectionTitle
                                //                            sectionIndex = sectionIndex + 1
                                if(lastSectionTitle != ""){
                                    sectionIndex = sectionIndex + 1
                                }
                            }
                            
                            let tempUnitRow = NSEntityDescription.insertNewObject(forEntityName: "Units", into: managedObjectContext) as! Units
                            
                            tempUnitRow.id = unit._id
                            tempUnitRow.unitDisplayName = unit.unitNo?.displayName
//                            tempUnitRow.unitIndex = unit.unitNo?.index ? Int64(unit.unitNo!.index!) : Int64(0)
                            if(unit.unitNo?.index != nil){
                            
                                tempUnitRow.unitIndex = Int64(unit.unitNo!.index!)
                                tempUnitRow.unitNo = unit.unitNo?.nsDictionary

                            }
                            else{
                                tempUnitRow.unitIndex = -1
                                tempUnitRow.unitNo = unit.unitNo?.nsDictionary
                            }
//                            print(tempUnitRow.unitIndex)
                            //            print(unit.unitNo?.nsDictionary)
                            //            print(unit.floor?.nsDictionary)
                            tempUnitRow.floor = unit.floor?.nsDictionary
                            if(unit.floor?.index != nil){
                                tempUnitRow.floorIndex = Int32(unit.floor?.index ?? 0)
                            }
                            tempUnitRow.floorDisplayName = unit.floor?.displayName
                            //            print(unit.type?.nsDictionary)
                            ////            tempUnitRow.type = unit.type?.nsDictionary
                            //            print(tempUnitRow.type)
                            
                            tempUnitRow.sectionTitle = sectionTitle
                            tempUnitRow.sectionIndex = Int32(sectionIndex)
                            
                            //                        print(sectionIndex)
                            tempUnitRow.typeName = unit.type?.name
                            //                        if(unit.floorPremium != nil){
                            tempUnitRow.floorPremium = unit.floorPremium?.name
                            //                        }
                            var otherPremiumsArray : [String] = []
                            let otherPRemiums = unit.otherPremiums
                            for tempPremium in otherPRemiums!{
                                otherPremiumsArray.append(tempPremium?.name ?? "")
                                
                                let otherPremium = NSEntityDescription.insertNewObject(forEntityName: "OtherPremiums", into: managedObjectContext) as! OtherPremiums
                                otherPremium.name = tempPremium?.name
                                otherPremium.id = tempPremium?._id
                                otherPremium.parentId = unit._id
                                
//                                tempUnitRow.addToAllOtherPremiums(otherPremium)
                                
                            }
                            tempUnitRow.otherPremiums = otherPremiumsArray
                            
                            if((unit.otherPremiums?.count)! > 0){
                                tempUnitRow.otherPremiumsCount = Int32(unit.otherPremiums!.count)
                            }
                            else{
                                tempUnitRow.otherPremiumsCount = 0
                            }
                            
                            tempUnitRow.towerType = Int16(tempTower.towerType!)
                            
                            //                        tempUnitRow.type = unit.type?.nsDictionary
                            
                            tempUnitRow.towerImageExist = ((tempTower.images?.count)! > 0) ? true : false
                            
                            tempUnitRow.project = unit.project
                            tempUnitRow.tower = unit.tower
                            tempUnitRow.block = unit.block
                            tempUnitRow.blockingReason = unit.blockingReason
                            tempUnitRow.bookingFormID = unit.bookingform?._id
                            tempUnitRow.bookingFormSatus = Int16(unit.bookingform?.status ?? -1)
                            tempUnitRow.manageUnitStatusStr = unit.manageUnitStatus
//                            print(unit.manageUnitStatus)
                            
                            tempUnitRow.schemes = (unit.type?.schemes?.count ?? 0 > 0) ? (unit.type?.schemes) : []
                            tempUnitRow.blockName = tempBlock.name!
                            tempUnitRow.towerName = tempTower.name!
                            
                            //                        print(unit.landowner)
                            
                            if(unit.type?.balconyArea != nil){
                                tempUnitRow.balconyArea = NSDecimalNumber.init(value: unit.type?.balconyArea?.value ?? 0.0)
                                tempUnitRow.balconyAreaUOM = unit.type?.balconyArea?.uom ?? ""
                                
                            }

                            
                            if(unit.landowner != nil){
                                let landOwner = NSEntityDescription.insertNewObject(forEntityName: "LandOwner", into: managedObjectContext) as! LandOwner
                                landOwner.id = unit.landowner?._id
                                landOwner.name = unit.landowner?.name
                                landOwner.address = unit.landowner?.address
                                landOwner.contactPerson = unit.landowner?.contactPerson
                                landOwner.email = unit.landowner!.email
                                landOwner.phoneNo = unit.landowner?.phoneNo
                                landOwner.shortName = unit.landowner?.shortName
                                landOwner.parentId = unit._id
                                landOwner.project = unit.project
                                
                                tempUnitRow.hasLandOwner = true
                                
                                tempUnitRow.owner = landOwner
                            }
                            else{
                                tempUnitRow.hasLandOwner = false
                            }
                            
                            
                            //TYpes , sales person , cleint id , sale value,
                            //superBuiltUpArea,carpet area, car parks ,billingElementForPricing , floorPlan
                            
                            if(unit.type != nil && unit.type?.carParks != nil){
                                
                                let tempCars : [CarParks] = (unit.type?.carParks)!
                                
                                var carParkCOunter = 0
                                
                                for temper in tempCars{
                                    if(temper.cType != nil){
                                        carParkCOunter = carParkCOunter + 1
                                        let carsRow = NSEntityDescription.insertNewObject(forEntityName: "UnitCarParks", into: managedObjectContext) as! UnitCarParks
                                        carsRow.id = temper._id
                                        carsRow.parentId = unit._id
                                        carsRow.count = Int64(temper.count ?? 0)
                                        carsRow.cType = temper.cType
                                        tempUnitRow.addToCarParkings(carsRow)
                                        //                                    let cars = tempUnitRow.mutableSetValue(forKey: "UnitCarParks")
                                        //                                    cars.add(carsRow)
                                    }
                                }
                                tempUnitRow.carParksCount = Int64(carParkCOunter)
                            }
                        
                            //                        print(tempUnitRow.carParks)
                            
                            // *** car parks , Floor premium **
                            
                               // *** BOOKING FORM CLIENTS ****
                               if(unit.bookingform?.clients?.count ?? 0 > 0){
                                   let clients = unit.bookingform?.clients
                                   for eachClient in clients ?? []{
                                       let customer = eachClient.customer
                                       let newClient = NSEntityDescription.insertNewObject(forEntityName: "BookingFormClients", into: managedObjectContext) as! BookingFormClients
                                       newClient.name = customer?.name
                                       newClient.customerId = customer?.customerId
                                       newClient.client = customer?.clientId
                                       newClient.phone = String(format: "%ld", customer?.phone ?? 0)
                                       newClient.email = customer?.email
                                       newClient.share = Double(eachClient.share ?? 0)
                                       tempUnitRow.addToBookedClient(newClient)
                                   }
                               }
                            // *** BOOKING FORM CLIENTS ****

                            
                            if(unit.bookingform?.salesPerson?.userInfo != nil){
                                tempUnitRow.salesPersonUserInfoName = unit.bookingform?.salesPerson?.userInfo?.name
                                tempUnitRow.salesPersonUserInfoEmail = unit.bookingform?.salesPerson?.userInfo?.email
                                tempUnitRow.salesPersonUserInfoId = unit.bookingform?.salesPerson?.userInfo?._id
                                tempUnitRow.salesPersonUserInfoPhone = unit.bookingform?.salesPerson?.userInfo?.phone
                            }
                            if(unit.bookingform?.salesPerson != nil){
                                tempUnitRow.salesPersonId = unit.bookingform?.salesPerson?._id
                                tempUnitRow.salesPersonEmail = unit.bookingform?.salesPerson?.email
                            }
                            
                            if(unit.clientId != nil){
                                tempUnitRow.clientId = unit.clientId
                            }
                            
                            if(unit.salevalue != nil){
                                tempUnitRow.salevalue = unit.salevalue!
                            }
                            
                            if(unit.type?.superBuiltUpArea != nil){
                                tempUnitRow.superBuiltUpArea = NSDecimalNumber.init(value: unit.type!.superBuiltUpArea!.value!)
                                tempUnitRow.superBuiltUpAreaUOM = unit.type?.superBuiltUpArea?.uom ?? ""
                            }
                            if(unit.type?.carpetArea != nil){
                                tempUnitRow.carpetArea = NSDecimalNumber.init(value: unit.type!.carpetArea!.value!)
                                tempUnitRow.capetAreaUOM = unit.type?.carpetArea?.uom ?? ""
                            }
                            //                        tempUnitRow.billingElementForPricing = unit.type?.billingElementForPricing
                            
                            //                        tempUnitRow.type = unit.type?.nsDictionary
                            
                            //                        let tempTypeDict : NSDictionary = tempUnitRow.type as! NSDictionary
                            
                            //                        print(tempTypeDict)
                            
                            tempUnitRow.agreeValItemRate = unit.agreeValItemRate ?? 0.0
                            tempUnitRow.rate = unit.rate ?? 0.0
                            tempUnitRow.gst = unit.gst ?? 0.0
                            tempUnitRow.totalCost = unit.totalCost ?? 0.0
                            
                            tempUnitRow.description1 = unit.description
                            tempUnitRow.company_group = unit.company_group
                            tempUnitRow.facing = unit.facing
                            if(unit.type?.bedRooms != nil){
                                tempUnitRow.bedRooms = NSDecimalNumber.init(value: unit.type?.bedRooms ?? 0.0) //Int32(unit.type!.bedRooms!)
                            }
                            if(unit.type?.bathRooms != nil){
                                tempUnitRow.bathRooms = NSDecimalNumber.init(value: unit.type?.bathRooms ?? 0.0) //Int32(unit.type!.bathRooms!)
                            }
                            tempUnitRow.status = Int64(unit.status!)
//                            if(unit.status! == 3){
//                                print("")
//                            }
                            if(unit.type?.floorPlan != nil){
                                tempUnitRow.hasImages = ((unit.type?.floorPlan?.count)! > 0) ? true : false
                            }
                            if(tempUnitRow.hasImages){
                                var imagesArray : [String] = []
                                let floorPlans = unit.type?.floorPlan
                                
                                for floorPlan in floorPlans!{
                                    imagesArray.append(floorPlan.url!)
                                }
                                tempUnitRow.floorPlanImages = imagesArray
                            }
                            //                        do {
                            //                            try managedObjectContext.save()
                            //                        } catch let error as NSError {
                            //                            print("Could not save. \(error), \(error.userInfo)")
                            //                        }
                            
                        }
                        if(dbSaveCounter == 10){ //save
                            do {
                                try managedObjectContext.save()
                                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                                dbSaveCounter = 0
                            } catch let error as NSError {
                                print("Could not save. \(error), \(error.userInfo)")
                                
                            }
                        }

                    }
                }
            }
            do {
                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                
            }
        }
        
        return

        
//        let lastFloorIndex = filterredUnits[0].floor?.index
//
//        if(tempTower.towerType == 0){
//            lastSectionTitle = String(format: "%@ - %@ - %d", tempBlock.name! , tempTower.name!,lastFloorIndex!)
//        }
//        else{
//            lastSectionTitle = String(format: "%@ - %@", tempBlock.name! , tempTower.name!)
//        }

//        for tempBlock in projectDetails.blocks!{
//
//            let blockId = tempBlock._id
//            let towers = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }
//
//            for tempTower in towers{
//
//                let towerId = tempTower._id
//
//                var filterredUnits = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(towerId!))! }
//
//                filterredUnits.sort { ($0.floor?.index!)! <= ($1.floor?.index!)! }
//
//                if(tempTower.towerType == 0){
////                    var sectionIndex = 0
////                    var lastFloorIndex = filterredUnits[0].floor?.index
//                    for unit in filterredUnits{
//
//                        let floorIndex = unit.floor?.index
//
//                        let sectionTitle = String(format: "%@ - %@ - %d", tempBlock.name! , tempTower.name!,floorIndex!)
//
//                        let tempUnitRow = NSEntityDescription.insertNewObject(forEntityName: "Units", into: managedObjectContext) as! Units
//
//                        tempUnitRow.id = unit._id
//                        tempUnitRow.unitDisplayName = unit.unitNo?.displayName
//                        tempUnitRow.unitIndex = Int64(unit.unitNo!.index!)
//                        print(tempUnitRow.unitIndex)
//                        tempUnitRow.unitNo = unit.unitNo?.nsDictionary
//                        //            print(unit.unitNo?.nsDictionary)
//                        //            print(unit.floor?.nsDictionary)
//                        tempUnitRow.floor = unit.floor?.nsDictionary
//                        tempUnitRow.floorIndex = Int32(unit.floor!.index!)
//                        tempUnitRow.floorDisplayName = unit.floor?.displayName
//                        //            print(unit.type?.nsDictionary)
//                        ////            tempUnitRow.type = unit.type?.nsDictionary
//                        //            print(tempUnitRow.type)
//
//                        tempUnitRow.sectionTitle = sectionTitle
//
//                        if(lastSectionTitle != sectionTitle){
////                            lastFloorIndex = floorIndex
//                            if(lastSectionTitle != ""){
//                                sectionIndex = sectionIndex + 1
//                            }
//                            lastSectionTitle = sectionTitle
//                        }
//
////                        print(sectionIndex)
//
//                        tempUnitRow.sectionIndex = Int32(sectionIndex)
//
////                        if(unit.floorPremium != nil){
////                            tempUnitRow.floorPremium = unit.floorPremium?.nsDictionary
////                        }
//
//                        tempUnitRow.towerType = Int16(tempTower.towerType!)
//
//                        tempUnitRow.towerImageExist = ((tempTower.images?.count)! > 0) ? true : false
//
//                        tempUnitRow.project = unit.project
//                        tempUnitRow.tower = unit.tower
//                        tempUnitRow.block = unit.block
//                        tempUnitRow.blockingReason = unit.blockingReason
//                        tempUnitRow.bookingFormID = unit.bookingform?._id
//
//                        tempUnitRow.blockName = tempBlock.name!
//                        tempUnitRow.towerName = tempTower.name!
//
//                        if(unit.landowner != nil){
//                            let landOwner = NSEntityDescription.insertNewObject(forEntityName: "LandOwner", into: managedObjectContext) as! LandOwner
//                            landOwner.id = unit.landowner?._id
//                            landOwner.name = unit.landowner?.name
//                            landOwner.address = unit.landowner?.address
//                            landOwner.contactPerson = unit.landowner?.contactPerson
//                            landOwner.email = unit.landowner!.email
//                            landOwner.phoneNo = unit.landowner?.phoneNo
//                            landOwner.shortName = unit.landowner?.shortName
//
//                            tempUnitRow.hasLandOwner = true
//
//                            tempUnitRow.owner = landOwner
//                        }
//                        else{
//                            tempUnitRow.hasLandOwner = false
//                        }
//
//                        //TYpes , sales person , cleint id , sale value,
//                        //superBuiltUpArea,carpet area, car parks ,billingElementForPricing , floorPlan
//
//                        if(unit.type != nil && unit.type?.carParks != nil){
//
//                            let tempCars : [CarParks] = (unit.type?.carParks)!
//
//                            var carParkCOunter = 0
//
//                            for temper in tempCars{
//                                if(temper.cType != nil){
//                                    carParkCOunter = carParkCOunter + 1
//                                    let carsRow = NSEntityDescription.insertNewObject(forEntityName: "UnitCarParks", into: managedObjectContext) as! UnitCarParks
//                                    carsRow.id = temper._id
//                                    carsRow.parentId = unit._id
//                                    carsRow.count = Int64(temper.count!)
//                                    carsRow.cType = temper.cType
//                                    tempUnitRow.addToCarParkings(carsRow)
//                                    //                                    let cars = tempUnitRow.mutableSetValue(forKey: "UnitCarParks")
//                                    //                                    cars.add(carsRow)
//                                }
//                            }
//                            tempUnitRow.carParksCount = Int64(carParkCOunter)
//                        }
//
////                        print(tempUnitRow.carParkings)
//
//                        // *** car parks , Floor premium **
//
//                        if(unit.bookingform?.salesPerson?.userInfo != nil){
//                            tempUnitRow.salesPersonUserInfoName = unit.bookingform?.salesPerson?.userInfo?.name
//                            tempUnitRow.salesPersonUserInfoEmail = unit.bookingform?.salesPerson?.userInfo?.email
//                            tempUnitRow.salesPersonUserInfoId = unit.bookingform?.salesPerson?.userInfo?._id
//                            tempUnitRow.salesPersonUserInfoPhone = unit.bookingform?.salesPerson?.userInfo?.phone
//                        }
//                        tempUnitRow.typeName = unit.type?.name
//                        if(unit.bookingform?.salesPerson != nil){
//                            tempUnitRow.salesPersonId = unit.bookingform?.salesPerson?._id
//                            tempUnitRow.salesPersonEmail = unit.bookingform?.salesPerson?.email
//                        }
//
//                        if(unit.clientId != nil){
//                            tempUnitRow.clientId = unit.clientId
//                        }
//                        if(unit.salevalue != nil){
//                            tempUnitRow.salevalue = unit.salevalue!
//                        }
//
//                        if(unit.type?.superBuiltUpArea != nil){
//                            tempUnitRow.superBuiltUpArea = Int64(unit.type!.superBuiltUpArea!.value!)
//                            if(unit.type?.superBuiltUpArea != nil && unit.type?.superBuiltUpArea?.uom != nil && unit.type?.superBuiltUpArea?.uom != "nil"){
//                                tempUnitRow.superBuiltUpAreaUOM = unit.type?.superBuiltUpArea?.uom ?? ""
//                            }
//                        }
//                        if(unit.type?.carpetArea != nil){
//                            tempUnitRow.carpetArea = Int64(unit.type!.carpetArea!.value!)
//                            if(unit.type?.carpetArea?.uom != nil && unit.type?.carpetArea?.uom != "nil"){
//                                tempUnitRow.capetAreaUOM = unit.type?.carpetArea?.uom ?? ""
//                            }
//                        }
////                        tempUnitRow.billingElementForPricing = unit.type?.billingElementForPricing
//
////                        tempUnitRow.type = unit.type?.nsDictionary
//
////                        let tempTypeDict : NSDictionary = tempUnitRow.type as! NSDictionary
//
////                        print(tempTypeDict)
//
//                        tempUnitRow.agreeValItemRate = unit.agreeValItemRate ?? 0.0
//                        tempUnitRow.rate = unit.rate ?? 0.0
//                        tempUnitRow.gst = unit.gst ?? 0.0
//                        tempUnitRow.totalCost = unit.totalCost ?? 0.0
//
//                        tempUnitRow.floorPremium = unit.floorPremium?.name
//
//                        let otherPRemiums = unit.otherPremiums
//
//                        var otherPremiumsArray : [String] = []
//
//                        for tempPremium in otherPRemiums!{
//                            otherPremiumsArray.append(tempPremium.name!)
//                        }
//                        tempUnitRow.otherPremiums = otherPremiumsArray
//                        if((unit.otherPremiums?.count)! > 0){
//                            tempUnitRow.otherPremiumsCount = Int32(unit.otherPremiums!.count)
//                        }
//                        else{
//                            tempUnitRow.otherPremiumsCount = 0
//                        }
//
//                        if(unit.type?.floorPlan != nil){
//                            tempUnitRow.hasImages = ((unit.type?.floorPlan?.count)! > 0) ? true : false
//                        }
//
//                        if(tempUnitRow.hasImages){
//                            var imagesArray : [String] = []
//                            let floorPlans = unit.type?.floorPlan
//
//                            for floorPlan in floorPlans!{
//                                imagesArray.append(floorPlan.url!)
//                            }
//                            tempUnitRow.floorPlanImages = imagesArray
//                        }
//
////                        tempUnitRow.type = unit.type?.nsDictionary
//
//                        tempUnitRow.description1 = unit.description
//                        tempUnitRow.company_group = unit.company_group
//                        tempUnitRow.facing = unit.facing
//
//                        tempUnitRow.status = Int64(unit.status!)
//
////                        print(tempUnitRow)
//
//                    }
//                }
//                else{
//
////                    var sectionIndex = 0
////                    var lastSectionTitle = String(format: "%@ - %@", tempBlock.name! , tempTower.name!)
//
//                    for unit in filterredUnits{
//
//                        let sectionTitle = String(format: "%@ - %@", tempBlock.name! , tempTower.name!)
//
//                        if(lastSectionTitle != sectionTitle){
//                            lastSectionTitle = sectionTitle
////                            sectionIndex = sectionIndex + 1
//                            if(lastSectionTitle != ""){
//                                sectionIndex = sectionIndex + 1
//                            }
//                        }
//
//                        let tempUnitRow = NSEntityDescription.insertNewObject(forEntityName: "Units", into: managedObjectContext) as! Units
//
//                        tempUnitRow.id = unit._id
//                        tempUnitRow.unitDisplayName = unit.unitNo?.displayName
//                        tempUnitRow.unitIndex = Int64(unit.unitNo!.index!)
//                        print(tempUnitRow.unitIndex)
//                        tempUnitRow.unitNo = unit.unitNo?.nsDictionary
//                        //            print(unit.unitNo?.nsDictionary)
//                        //            print(unit.floor?.nsDictionary)
//                        tempUnitRow.floor = unit.floor?.nsDictionary
//                        tempUnitRow.floorIndex = Int32(unit.floor!.index!)
//                        tempUnitRow.floorDisplayName = unit.floor?.displayName
//                        //            print(unit.type?.nsDictionary)
//                        ////            tempUnitRow.type = unit.type?.nsDictionary
//                        //            print(tempUnitRow.type)
//
//                        tempUnitRow.sectionTitle = sectionTitle
//                        tempUnitRow.sectionIndex = Int32(sectionIndex)
//
////                        print(sectionIndex)
//                        tempUnitRow.typeName = unit.type?.name
////                        if(unit.floorPremium != nil){
//                            tempUnitRow.floorPremium = unit.floorPremium?.name
////                        }
//                        var otherPremiumsArray : [String] = []
//                        let otherPRemiums = unit.otherPremiums
//                        for tempPremium in otherPRemiums!{
//                            otherPremiumsArray.append(tempPremium.name!)
//                        }
//                        tempUnitRow.otherPremiums = otherPremiumsArray
//                        if((unit.otherPremiums?.count)! > 0){
//                            tempUnitRow.otherPremiumsCount = Int32(unit.otherPremiums!.count)
//                        }
//                        else{
//                            tempUnitRow.otherPremiumsCount = 0
//                        }
//
//                        tempUnitRow.towerType = Int16(tempTower.towerType!)
//
////                        tempUnitRow.type = unit.type?.nsDictionary
//
//                        tempUnitRow.towerImageExist = ((tempTower.images?.count)! > 0) ? true : false
//
//                        tempUnitRow.project = unit.project
//                        tempUnitRow.tower = unit.tower
//                        tempUnitRow.block = unit.block
//                        tempUnitRow.blockingReason = unit.blockingReason
//                        tempUnitRow.bookingFormID = unit.bookingform?._id
//
//
//                        tempUnitRow.blockName = tempBlock.name!
//                        tempUnitRow.towerName = tempTower.name!
//
////                        print(unit.landowner)
//
//                        if(unit.landowner != nil){
//                            let landOwner = NSEntityDescription.insertNewObject(forEntityName: "LandOwner", into: managedObjectContext) as! LandOwner
//                            landOwner.id = unit.landowner?._id
//                            landOwner.name = unit.landowner?.name
//                            landOwner.address = unit.landowner?.address
//                            landOwner.contactPerson = unit.landowner?.contactPerson
//                            landOwner.email = unit.landowner!.email
//                            landOwner.phoneNo = unit.landowner?.phoneNo
//                            landOwner.shortName = unit.landowner?.shortName
//
//                            tempUnitRow.hasLandOwner = true
//
//                            tempUnitRow.owner = landOwner
//                        }
//                        else{
//                            tempUnitRow.hasLandOwner = false
//                        }
//
//
//                        //TYpes , sales person , cleint id , sale value,
//                        //superBuiltUpArea,carpet area, car parks ,billingElementForPricing , floorPlan
//
//                        let tempDict : NSMutableDictionary = NSMutableDictionary.init()
//                        var tempperCars : [CarParks] = []
//                        if(unit.type != nil && unit.type?.carParks != nil){
//
//                            let tempCars : [CarParks] = (unit.type?.carParks)!
//
//                            for temper in tempCars{
//                                if(temper.cType != nil){
////                                    tempperCars.append(temper)
//
//                                    let carsRow = NSEntityDescription.insertNewObject(forEntityName: "UnitCarParks", into: managedObjectContext) as! UnitCarParks
//                                    carsRow.id = temper._id
//                                    carsRow.parentId = unit._id
//                                    carsRow.count = Int64(temper.count!)
//                                    carsRow.cType = temper.cType
//                                    tempUnitRow.addToCarParkings(carsRow)
////                                    let cars = tempUnitRow.mutableSetValue(forKey: "UnitCarParks")
////                                    cars.add(carsRow)
//
//                                }
//                            }
////                            print(tempUnitRow.carParkings)
////                            if(tempperCars.count > 0){
////                                tempDict["carParks"] = unit.type?.carParks
////                                tempUnitRow.carParks = tempDict as NSDictionary
////                            tempUnitRow.addToCarParks
//
////                            }
////                            else{
////                                tempDict["carParks"] = [:]
////                                tempUnitRow.carParks = tempDict as NSDictionary
////                            }
//                        }
////                        print(tempUnitRow.carParks)
//
//                        // *** car parks , Floor premium **
//
//                        if(unit.bookingform?.salesPerson?.userInfo != nil){
//                            tempUnitRow.salesPersonUserInfoName = unit.bookingform?.salesPerson?.userInfo?.name
//                            tempUnitRow.salesPersonUserInfoEmail = unit.bookingform?.salesPerson?.userInfo?.email
//                            tempUnitRow.salesPersonUserInfoId = unit.bookingform?.salesPerson?.userInfo?._id
//                            tempUnitRow.salesPersonUserInfoPhone = unit.bookingform?.salesPerson?.userInfo?.phone
//                        }
//                        if(unit.bookingform?.salesPerson != nil){
//                            tempUnitRow.salesPersonId = unit.bookingform?.salesPerson?._id
//                            tempUnitRow.salesPersonEmail = unit.bookingform?.salesPerson?.email
//                        }
//
//                        if(unit.clientId != nil){
//                            tempUnitRow.clientId = unit.clientId
//                        }
//
//                        if(unit.salevalue != nil){
//                            tempUnitRow.salevalue = unit.salevalue!
//                        }
//
//                        if(unit.type?.superBuiltUpArea != nil){
//                            tempUnitRow.superBuiltUpArea = Int64(unit.type!.superBuiltUpArea!.value!)
//                            tempUnitRow.superBuiltUpAreaUOM = unit.type?.superBuiltUpArea?.uom ?? ""
//                        }
//                        if(unit.type?.carpetArea != nil){
//                            tempUnitRow.carpetArea = Int64(unit.type!.carpetArea!.value!)
//                            tempUnitRow.capetAreaUOM = unit.type?.carpetArea?.uom ?? ""
//                        }
//                        //                        tempUnitRow.billingElementForPricing = unit.type?.billingElementForPricing
//
////                        tempUnitRow.type = unit.type?.nsDictionary
//
////                        let tempTypeDict : NSDictionary = tempUnitRow.type as! NSDictionary
//
////                        print(tempTypeDict)
//
//                        tempUnitRow.agreeValItemRate = unit.agreeValItemRate ?? 0.0
//                        tempUnitRow.rate = unit.rate ?? 0.0
//                        tempUnitRow.gst = unit.gst ?? 0.0
//                        tempUnitRow.totalCost = unit.totalCost ?? 0.0
//
//                        tempUnitRow.description1 = unit.description
//                        tempUnitRow.company_group = unit.company_group
//                        tempUnitRow.facing = unit.facing
//                        tempUnitRow.status = Int64(unit.status!)
//
//                        if(unit.type?.floorPlan != nil){
//                            tempUnitRow.hasImages = ((unit.type?.floorPlan?.count)! > 0) ? true : false
//                        }
//                        if(tempUnitRow.hasImages){
//                            var imagesArray : [String] = []
//                            let floorPlans = unit.type?.floorPlan
//
//                            for floorPlan in floorPlans!{
//                                imagesArray.append(floorPlan.url!)
//                            }
//                            tempUnitRow.floorPlanImages = imagesArray
//                        }
////                        do {
////                            try managedObjectContext.save()
////                        } catch let error as NSError {
////                            print("Could not save. \(error), \(error.userInfo)")
////                        }
//
//                    }
//                }
//            }
//        }
        
//        for unit in units{
//
//            let tempUnitRow = NSEntityDescription.insertNewObject(forEntityName: "Units", into: managedObjectContext) as! Units
//
//            tempUnitRow.id = unit._id
//            tempUnitRow.unitDisplayName = unit.unitNo?.displayName
//            tempUnitRow.unitIndex = Int32(unit.unitNo!.index!)
//            tempUnitRow.unitNo = unit.unitNo?.nsDictionary
////            print(unit.unitNo?.nsDictionary)
////            print(unit.floor?.nsDictionary)
//            tempUnitRow.floor = unit.floor?.nsDictionary
//            tempUnitRow.floorIndex = Int32(unit.floor!.index!)
//            tempUnitRow.floorDisplayName = unit.floor?.displayName
////            print(unit.type?.nsDictionary)
//////            tempUnitRow.type = unit.type?.nsDictionary
////            print(tempUnitRow.type)
//            tempUnitRow.project = unit.project
//            tempUnitRow.tower = unit.tower
//            tempUnitRow.block = unit.block
//            tempUnitRow.blockingReason = unit.blockingReason
//            tempUnitRow.bookingFormID = unit.bookingform?._id
//
//            tempUnitRow.agreeValItemRate = unit.agreeValItemRate ?? 0.0
//            tempUnitRow.rate = unit.rate ?? 0.0
//            tempUnitRow.gst = unit.gst ?? 0.0
//            tempUnitRow.totalCost = unit.totalCost ?? 0.0
//
//            tempUnitRow.description1 = unit.description
//            tempUnitRow.company_group = unit.company_group
//            tempUnitRow.facing = unit.facing
//        }
        
//        do {
//            try managedObjectContext.save()
//            //            self.getAllProjects()
////            return true
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
////            return false
//        }
        
//        do {
//            try managedObjectContext.save()
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
        
//        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
//
//            for unit in units{
//
//                let tempUnitRow = NSEntityDescription.insertNewObject(forEntityName: "Units", into: managedObjectContext) as! Units
//
//                tempUnitRow.id = unit._id
//                tempUnitRow.unitDisplayName = unit.unitNo?.displayName
//                tempUnitRow.unitIndex = Int32(unit.unitNo!.index!)
//                tempUnitRow.unitNo = unit.unitNo?.nsDictionary
//                //            print(unit.unitNo?.nsDictionary)
//                //            print(unit.floor?.nsDictionary)
//                tempUnitRow.floor = unit.floor?.nsDictionary
//                tempUnitRow.floorIndex = Int32(unit.floor!.index!)
//                tempUnitRow.floorDisplayName = unit.floor?.displayName
//                //            print(unit.type?.nsDictionary)
//                ////            tempUnitRow.type = unit.type?.nsDictionary
//                //            print(tempUnitRow.type)
//                tempUnitRow.project = unit.project
//                tempUnitRow.tower = unit.tower
//                tempUnitRow.block = unit.block
//                tempUnitRow.blockingReason = unit.blockingReason
//                tempUnitRow.bookingFormID = unit.bookingform?._id
//
//                tempUnitRow.agreeValItemRate = unit.agreeValItemRate ?? 0.0
//                tempUnitRow.rate = unit.rate ?? 0.0
//                tempUnitRow.gst = unit.gst ?? 0.0
//                tempUnitRow.totalCost = unit.totalCost ?? 0.0
//
//                tempUnitRow.description1 = unit.description
//                tempUnitRow.company_group = unit.company_group
//                tempUnitRow.facing = unit.facing
//            }
//            do {
//                try managedObjectContext.save()
//                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
//
//                //            self.getAllProjects()
////                return true
//            } catch let error as NSError {
//                print("Could not save. \(error), \(error.userInfo)")
////                return false
//            }
////
//        }
    }
    func writeAllProjectsToDB(projectsArray : [ProjectInfo]) -> Bool {
        
        self.resetProjectsEntity()
        var counter = 1
        
//        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
//
//
//            do {
//                try managedObjectContext.save()
//                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
////                completionHandler(true,nil)
//                return true
//            } catch let error as NSError {
//                print("Could not save. \(error), \(error.userInfo)")
////                completionHandler(false,nil)
//                return false
//            }
//        }
        
        for projDict in projectsArray{
            
            //            print(projDict)
            
            let tempPro = NSEntityDescription.insertNewObject(forEntityName: "Project", into: managedObjectContext) as! Project
            
            tempPro.address = projDict.address;
            tempPro.far = Int64(projDict.FAR ?? 0.0)
            tempPro.city = projDict.city
            tempPro.company = projDict.company
            tempPro.company_group = projDict.company_group
            tempPro.id = projDict._id
            tempPro.images = projDict.images
            tempPro.imagesTemp = projDict.imagesTemp
            tempPro.incharge = projDict.incharge
            tempPro.info = projDict.info
            tempPro.orderId = Int64(counter)
            counter += 1
            //            guard let name = projDict.landArea else{
            //                return
            //            }
            
            //            let person = Project(context: context)
            //            person.add
            
            
            if((projDict.landArea?.nsDictionary) != nil){
                tempPro.landArea = projDict.landArea?.nsDictionary
            }
            //            print(tempPro.landArea)
            
            tempPro.name = projDict.name
            
            if((projDict.builtUpArea?.nsDictionary) != nil){
                tempPro.builtUpArea = projDict.builtUpArea?.nsDictionary
            }
            if((projDict.superBuiltUpArea?.nsDictionary) != nil){
                tempPro.superBuiltUpArea = projDict.superBuiltUpArea?.nsDictionary
            }
            tempPro.proj_code = projDict.proj_code
            tempPro.proj_type = projDict.proj_type
            tempPro.status = Int16(projDict.status!)
            tempPro.state = projDict.state
            
            let orderdSet : NSMutableOrderedSet = []
            if(projDict.stats?.count != nil){
                
                for tempStat in projDict.stats!{
                    if(tempStat.count == nil){
                        continue
                    }
                    if(tempStat.status != nil){
                        let friend1 = TempObj(context: managedObjectContext)
                        friend1.count = Int64(tempStat.count!)
                        friend1.status = Int16(tempStat.status!)
                        orderdSet.add(friend1)
                        tempPro.addToProStat(friend1)
                    }
                }
                
                tempPro.setValue(orderdSet, forKey: "proStat")
                //                tempPro.stats = projDict.stats as NSArray?
                //                print("fdfdf \(tempPro.stats)")
            }
            else{
//                print("NO STATSSS")
                //                 tempPro.stats = []
                //                continue
            }
            
            tempPro.segment = projDict.segment
            tempPro.short_name = projDict.short_name
            
            //            if((projDict.updateBy?.count)! > 0){
            //                tempPro.updateBy = projDict.updateBy as NSArray?
            //            }
            //            if((projDict.sanctions?.count)! > 0){
            //                tempPro.sanctions = projDict.sanctions as NSArray?
            //            }
            //            tempPro.sanctions = projDict.sanctions.?NSDictionary
            
            //            tempPro.sanctions = projDict.sanctions.nsc
            //            tempPro.sanctions = projDict.sanctions.
            
            //            do {
            //                try managedObjectContext.save()
            //                return true
            //            } catch let error as NSError {
            //                print("Could not save. \(error), \(error.userInfo)")
            //                return false
            //            }
            
        }
//        activityInfo.activitiesArray = activityArray as NSArray
//        activityInfo.idForUploadCheck = UUID().uuidString.lowercased()
        
        do {
            try managedObjectContext.save()
//            self.getAllProjects()
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }

//        return false
    }
    func writeRRUser(loggedInUser : USER,completionHandler: @escaping (Bool, Error?) -> ()){
        
        self.resetEntity(entityName: "RRUser")
        self.resetEntity(entityName: "RRUserRole")
        self.resetEntity(entityName: "PresalesPermissions")
        
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
            
            let rrUser = NSEntityDescription.insertNewObject(forEntityName: "RRUser", into: managedObjectContext) as! RRUser
            rrUser.id = loggedInUser._id
            rrUser.company_group = loggedInUser.company_group
            rrUser.company_group_name = loggedInUser.company_group_name
            rrUser.email = loggedInUser.email
            rrUser.name = loggedInUser.userInfo?.phone
            rrUser.status = Int32(loggedInUser.status!)
            rrUser.type = Int32(loggedInUser.type!)
            rrUser.phone = loggedInUser.userInfo?.phone
            
            if(loggedInUser.userInfo?.roles != nil && (loggedInUser.userInfo?.roles!.count)! > 0){
                
                for userRole in (loggedInUser.userInfo?.roles)!{
                    
                    let tempUesrRole : RRUserRole = NSEntityDescription.insertNewObject(forEntityName: "RRUserRole", into: managedObjectContext) as! RRUserRole
                    
                    tempUesrRole.roleID = userRole._id
                    tempUesrRole.name = userRole.name
                    tempUesrRole.permissionsID = userRole.permissions?._id
                    tempUesrRole.create = userRole.permissions?.create
                    tempUesrRole.delete = userRole.permissions?.delete
                    tempUesrRole.edit = userRole.permissions?.edit
                    tempUesrRole.view = userRole.permissions?.view
                    
                    let userPresalesPermissions : PresalesPermissions = NSEntityDescription.insertNewObject(forEntityName: "PresalesPermissions", into: managedObjectContext) as! PresalesPermissions

                    userPresalesPermissions.calls = (userRole.presalesActions?.calls == 1) ? true : false
                    userPresalesPermissions.offers = (userRole.presalesActions?.offers == 1) ? true : false
                    userPresalesPermissions.siteVisits = (userRole.presalesActions?.siteVisits == 1) ? true : false
                    userPresalesPermissions.discountRequests = (userRole.presalesActions?.discountRequests == 1) ? true : false
                    userPresalesPermissions.otherTasks = (userRole.presalesActions?.otherTasks == 1) ? true : false
                    userPresalesPermissions.notInterested = (userRole.presalesActions?.notInterested == 1) ? true : false
                    
                    rrUser.addToUserRoles(tempUesrRole)
                    rrUser.addToPresales(userPresalesPermissions)
                    
                }
            }
            do {
                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                completionHandler(true,nil)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                completionHandler(false,nil)
            }
        }
    }
    func writeSoldUnitsToDB(soldUnits : [UNIT_INFO],completionHandler: @escaping (Bool, Error?) -> ()){
        
        self.resetEntity(entityName: "SoldUnits")
        self.resetEntity(entityName: "TowerHandOverItems") // check for offline parameter and reset if false
        self.resetEntity(entityName: "Reviews")
        self.resetEntity(entityName: "SoldUnitProjects")
        self.resetEntity(entityName: "SoldUnitTowers")
        self.resetEntity(entityName: "UnitHandOverHistory")
        self.resetEntity(entityName: "UnitHandOverItemHistory")
        //UnitHandOverHistory
        
        let tempSoldUnits = soldUnits
        
//        tempSoldUnits.sort { ($0.project?._id!)! <= ($1.project?._id!)! }
        
//        print(tempSoldUnits)
        
        
//        let predicate = NSPredicate.init(format: "dial_code CONTAINS[cd] %@",self.countryCodeTextField.text!)
//        let fileredArray : NSArray = self.countryCodesArray.filtered(using: predicate) as NSArray

        
//        var filterredUnits = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(towerId!))! }

        //5a64a02cc145c62d977954f0
        
//        var temper = soldUnits.filter(($0.project.id?.localizedCaseInsensitiveContains("towerId"))!)
        
        //Fetch and Delete updateBy with batch delete
        var sectionIndex = 0
        var lastSectionTitle = ""
        var lastProjectID = ""
        var soldUnitProjectDetails : Dictionary<String,Dictionary<String,String>> = [:]
        
        for tempUnit in tempSoldUnits{
            
            var projectDetails : Dictionary<String,String> = [:]
//            if("5a51e1b49368c567787f7cc9" ==  tempUnit.project?._id){
                projectDetails["id"] = tempUnit.project?._id
                projectDetails["name"] = tempUnit.project?.name
                
                soldUnitProjectDetails[tempUnit.project!._id!] = projectDetails
//            }
        }
        
        
        /*
 
         let blockId = tempBlock._id
         let towers = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }
         
         for tempTower in towers{
         
         let towerId = tempTower._id
         
         var filterredUnits = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(towerId!))! }
         
         filterredUnits.sort { ($0.floor?.index ?? 0) <= ($1.floor?.index ?? 0) }
         
         */
        
        
        
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
            
            for projectIdKey in soldUnitProjectDetails.keys{
//                filterredUnits.filter{ ($0.status == selectedStatus) }
                
                var unitsProjectWise = tempSoldUnits.filter{ ($0.project?._id == projectIdKey) }
                
//                unitsProjectWise.sort( by: { $0.tower!._id! < $1.tower!._id! })

//                unitsProjectWise.sort( by: { $0.block!._id! < $1.block!._id! })
                
                
                let allBlocks : NSMutableOrderedSet = []
                let allTowers : NSMutableOrderedSet = []
                
                var allTowersDict : Dictionary<String,[String]> = [:] ///block is Key and
                
                var allUnits : NSMutableOrderedSet = []
                
                for temppper in unitsProjectWise{
                    
//                    unitsProjectWise.filter { ($0.block!._id!.localizedCaseInsensitiveContains(temppper.block!._id!)) }
                    
                    allBlocks.add(temppper.block!._id!)
                    
//                    allTowers.insert(temppper.tower!._id!)
                    allTowers.add(temppper.tower!._id!)
                    
                    if(allTowersDict[temppper.block!._id!] != nil){
                        
                        var towersArray = allTowersDict[temppper.block!._id!]
                        
                        if(!towersArray!.contains(temppper.tower!._id!)){
                            towersArray?.append(temppper.tower!._id!)
                            allTowersDict[temppper.block!._id!] = towersArray
                        }
                    }
                    else{
                        let towersArray : [String] = [temppper.tower!._id!]
                        allTowersDict[temppper.block!._id!] = towersArray
                    }
                    
                    allUnits.add(temppper._id!)
                    
                }
//                print(allTowers)
//                print(allTowersDict)
                
//                var unitsToFiler = unitsProjectWise
                let allblocksArray = allBlocks.array as! [String]
                
                var blockIndexCounter : Int = 0
                var towerIndexCounter : Int = 0
                
                for eachBlock in allblocksArray{
                    
                        // filter all blocks
                    
//                   let filteredBlocks = unitsToFiler.filter{ ($0.block!._id == eachBlock) }
                    
                    var towersArray : Array<String> = allTowersDict[eachBlock]!
//                    towersArray.sort(by: { $0 <= $1 })
                    
//                    towersArray.sort( by: { $0 < $1 })
                    
                    for eachTower in towersArray{
                        
                        // filter units tower wise
                        
                        var unitsOfTower =  unitsProjectWise.filter{ ($0.tower!._id == eachTower) }
                        
                        unitsOfTower.sort { ($0.floor?.index ?? 0) <= ($1.floor?.index ?? 0) }
                        
                        let tempSoldUnitTower = NSEntityDescription.insertNewObject(forEntityName: "SoldUnitTowers", into: managedObjectContext) as! SoldUnitTowers
                        let unitInfo = unitsOfTower[0]
                        tempSoldUnitTower.towerName = unitInfo.tower?.name
                        tempSoldUnitTower.blockName = unitInfo.block?.name
                        tempSoldUnitTower.blockIndex = Int32(blockIndexCounter)
                        tempSoldUnitTower.towerIndex = Int32(towerIndexCounter)
                        tempSoldUnitTower.projectId = projectIdKey
//                        "aravind villasblkARow A14"
                        for soldUnit in unitsOfTower{
                            
                            let tempSoldUnit = NSEntityDescription.insertNewObject(forEntityName: "SoldUnits", into: managedObjectContext) as! SoldUnits

                            let sectionTitle = String(format: "%@ - %@ - %d", (soldUnit.block?.name ?? "") , (soldUnit.tower?.name ?? ""),(soldUnit.floor?.index ?? 0))
                            
                            if(lastSectionTitle != sectionTitle){
                                
                                if(lastSectionTitle != ""){
                                    sectionIndex = sectionIndex + 1
                                }
                                lastSectionTitle = sectionTitle
                            }
                            
//                            print(sectionIndex)
//                            print(sectionTitle)
                            
                            tempSoldUnit.sectionTitle = sectionTitle
                            tempSoldUnit.sectionIndex = Int64(sectionIndex)
                            
                            tempSoldUnit.towerForFloat = String(format: "%@ - %d", (soldUnit.tower?.name ?? ""),(soldUnit.floor?.index ?? 0))
                            
                            var projectDetails : Dictionary<String,String> = [:]
                            projectDetails["id"] = soldUnit.project?._id
                            projectDetails["name"] = soldUnit.project?.name
                            
                            soldUnitProjectDetails[soldUnit.project!._id!] = projectDetails
                            
                            tempSoldUnit.blockId = soldUnit.block?._id
                            tempSoldUnit.blockName = soldUnit.block?.name
                            tempSoldUnit.blockingReason = soldUnit.blockingReason
                            tempSoldUnit.bookingform = soldUnit.bookingform
                            tempSoldUnit.company_group = soldUnit.company_group
                            tempSoldUnit.customer = soldUnit.customer
                            tempSoldUnit.facing = soldUnit.facing
                            tempSoldUnit.floorDisplayName = soldUnit.floor?.displayName
                            tempSoldUnit.floorIndex = Int64(soldUnit.floor?.index ?? 0)
                            tempSoldUnit.floorPremium = soldUnit.floorPremium
                            tempSoldUnit.handOverStatus = Int16(soldUnit.handOverStatus ?? -1)
                            tempSoldUnit.id = soldUnit._id
                            tempSoldUnit.isOffline = false
                            tempSoldUnit.landowner = soldUnit.landowner
                            tempSoldUnit.manageUnitStatus = Int16(soldUnit.manageUnitStatus ?? -1)
                            tempSoldUnit.otherPremiums = soldUnit.otherPremium
                            tempSoldUnit.projectId = soldUnit.project?._id
                            tempSoldUnit.projectName = soldUnit.project?.name
                            tempSoldUnit.status = Int16(soldUnit.status ?? 0)
                            tempSoldUnit.towerId = soldUnit.tower?._id
                            tempSoldUnit.towerName = soldUnit.tower?.name
                            tempSoldUnit.unitDescription = soldUnit.description
                            tempSoldUnit.unitDisplayName = soldUnit.unitNo?.displayName
                            tempSoldUnit.unitIndex = Int64(soldUnit.unitNo?.index ?? 0)
                            tempSoldUnit.unitTypeID = soldUnit.type?._id
                            tempSoldUnit.unitTypeName = soldUnit.type?.name
                            tempSoldUnit.blockIndex = Int32(blockIndexCounter)
                            tempSoldUnit.towerIndex = Int32(towerIndexCounter)
                            tempSoldUnit.syncDirty = Int16(SYNC_STATE.SYNC_CLEAN.rawValue)
                            
                            
                            // tower hand over itesm
                            
                            let towerHandOverItems = soldUnit.tower?.handoverItems
                            
                            if(towerHandOverItems != nil && towerHandOverItems!.count > 0){
                                
                                for handOverUnit in towerHandOverItems!{
                                    
                                    let tempHandOverUnit = NSEntityDescription.insertNewObject(forEntityName: "TowerHandOverItems", into: managedObjectContext) as! TowerHandOverItems
                                    
                                    tempHandOverUnit.isTowerHandOver = false
                                    tempHandOverUnit.company = handOverUnit.company
                                    tempHandOverUnit.company_group = handOverUnit.company_group
                                    tempHandOverUnit.complaintDate = Int64(handOverUnit.complaintDate ?? 0)
                                    tempHandOverUnit.complaintDesc = handOverUnit.complaintDesc
                                    tempHandOverUnit.complaintimgUrls = handOverUnit.complaintimgUrls
                                    tempHandOverUnit.complaintlocation = handOverUnit.complaintlocation
                                    tempHandOverUnit.enabled = (handOverUnit.enabled)!
                                    tempHandOverUnit.groupdId = handOverUnit.groupdId
                                    tempHandOverUnit.groupdName = handOverUnit.groupdName
                                    tempHandOverUnit.handOverStatus = Int32(handOverUnit.handOverStatus ?? -1)
                                    tempHandOverUnit.id = handOverUnit._id
                                    tempHandOverUnit.isNewItem = handOverUnit.isNewItem ?? false
                                    tempHandOverUnit.itemId = handOverUnit.ItemId
                                    tempHandOverUnit.mandatory = (handOverUnit.mandatory)!
                                    tempHandOverUnit.name = handOverUnit.name
                                    tempHandOverUnit.tower = handOverUnit.tower
                                    tempHandOverUnit.unit = handOverUnit.unit
                                    tempHandOverUnit.updatedOn = handOverUnit.updatedOn
                                    tempHandOverUnit.hasOfflineImages = false
                                    
                                    let itemInternalReview = handOverUnit.internalreviews
                                    var internalIndexer = 0
                                    if(itemInternalReview != nil && itemInternalReview!.count > 0){
                                        
                                        for eachItem in itemInternalReview!{
                                            
                                            let itemIR = NSEntityDescription.insertNewObject(forEntityName: "Reviews", into: managedObjectContext) as! Reviews
                                            itemIR.checked = eachItem!.checked!
                                            itemIR.id = eachItem!._id
                                            itemIR.createdDate = eachItem!.createdDate
                                            itemIR.level = Int32(eachItem!.level!)
                                            itemIR.reviewStatus = Int32(eachItem!.reviewStatus!)
                                            itemIR.reviewType = eachItem?.reviewType
                                            itemIR.index = Int64(internalIndexer)
                                            itemIR.role = eachItem!.role
//                                            itemIR.days = Int32(eachItem!.days ?? -1)
                                            tempHandOverUnit.addToInternalReviews(itemIR)
                                            internalIndexer += 1
                                        }
                                    }
                                    
                                    let itemCustomerReviews = handOverUnit.customerreviews
                                    var customerIndexer = 0
                                    if(itemCustomerReviews != nil && itemCustomerReviews!.count > 0){
                                        
                                        for eachItem in itemCustomerReviews!{
                                            
                                            let itemIR = NSEntityDescription.insertNewObject(forEntityName: "Reviews", into: managedObjectContext) as! Reviews
                                            itemIR.checked = eachItem!.checked!
                                            itemIR.id = eachItem!._id
                                            itemIR.createdDate = eachItem!.createdDate
                                            itemIR.level = Int32(eachItem!.level!)
                                            itemIR.reviewStatus = Int32(eachItem!.reviewStatus!)
                                            itemIR.reviewType = eachItem?.reviewType
                                            itemIR.index = Int64(customerIndexer)
                                            itemIR.role = eachItem!.role
//                                            itemIR.days = Int32(eachItem!.days ?? -1)
                                            tempHandOverUnit.addToCustomerReviews(itemIR)
                                            
                                            customerIndexer += 1
                                        }
                                    }
                                    
                                    let itemHistory = handOverUnit.itemHistory
                                    
                                    var itemIndexer : Int = 0
                                    if(itemHistory != nil){
                                        
                                        for tempItem in itemHistory!{
                                            
                                            let itemHO = NSEntityDescription.insertNewObject(forEntityName: "UnitHandOverItemHistory", into: managedObjectContext) as! UnitHandOverItemHistory
                                            itemHO.modifiedDate = tempItem!.modifiedDate
                                            itemHO.status = Int32(tempItem!.status!)
                                            itemHO.handOverStatus = Int32(tempItem!.handOverStatus!)
                                            itemHO.itemDescription = tempItem?.description
                                            itemHO.imgUrl = tempItem?.imgUrl
                                            itemHO.location = tempItem?.location
                                            itemHO.user = tempItem?.user
                                            itemHO.index = Int64(itemIndexer)
                                            itemIndexer += 1
                                            
                                            tempHandOverUnit.addToItemHistory(itemHO)
                                        }
                                    }
                                    
                                    tempSoldUnit.addToTowerHandOverUnits(tempHandOverUnit)
                                    
                                    //                        tempHandOverUnit.ireviewLevels
                                    //                        tempHandOverUnit.creviewLevels = handOverUnit?.creviewLevels
                                    
                                }
                            }
                            
                            
                            if(soldUnit.handoverItems!.count > 0){
                                
                                for handOverUnit in soldUnit.handoverItems!{
                                    
                                    //                        print(handOverUnit?.creviewLevels.self)
                                    
                                    let tempHandOverUnit = NSEntityDescription.insertNewObject(forEntityName: "TowerHandOverItems", into: managedObjectContext) as! TowerHandOverItems
                                    
                                    tempHandOverUnit.isTowerHandOver = false
                                    tempHandOverUnit.company = handOverUnit?.company
                                    tempHandOverUnit.company_group = handOverUnit?.company_group
                                    tempHandOverUnit.complaintDate = Int64(handOverUnit?.complaintDate ?? 0)
                                    tempHandOverUnit.complaintDesc = handOverUnit?.complaintDesc
                                    tempHandOverUnit.complaintimgUrls = handOverUnit?.complaintimgUrls
                                    tempHandOverUnit.complaintlocation = handOverUnit?.complaintlocation
                                    tempHandOverUnit.enabled = (handOverUnit?.enabled)!
                                    tempHandOverUnit.groupdId = handOverUnit?.groupdId
                                    tempHandOverUnit.groupdName = handOverUnit?.groupdName
                                    tempHandOverUnit.handOverStatus = Int32(handOverUnit?.handOverStatus ?? -1)
                                    tempHandOverUnit.id = handOverUnit?._id
                                    tempHandOverUnit.isNewItem = (handOverUnit?.isNewItem)!
                                    tempHandOverUnit.itemId = handOverUnit?.ItemId
                                    tempHandOverUnit.mandatory = (handOverUnit?.mandatory)!
                                    tempHandOverUnit.name = handOverUnit?.name
                                    tempHandOverUnit.tower = handOverUnit?.tower
                                    tempHandOverUnit.unit = handOverUnit?.unit
                                    tempHandOverUnit.updatedOn = handOverUnit?.updatedOn
                                    tempHandOverUnit.hasOfflineImages = false
                                    
                                    let itemInternalReview = handOverUnit?.internalreviews
                                    var internalIndexer = 0
                                    if(itemInternalReview != nil && itemInternalReview!.count > 0){
                                        
                                        for eachItem in itemInternalReview!{
                                            
                                            let itemIR = NSEntityDescription.insertNewObject(forEntityName: "Reviews", into: managedObjectContext) as! Reviews
                                            itemIR.checked = eachItem!.checked!
                                            itemIR.id = eachItem!._id
                                            itemIR.createdDate = eachItem!.createdDate
                                            itemIR.level = Int32(eachItem!.level!)
                                            itemIR.reviewStatus = Int32(eachItem!.reviewStatus!)
                                            itemIR.reviewType = eachItem?.reviewType
                                            itemIR.index = Int64(internalIndexer)
                                            tempHandOverUnit.addToInternalReviews(itemIR)
                                            internalIndexer += 1
                                        }
                                    }
                                    
                                    let itemCustomerReviews = handOverUnit?.customerreviews
                                    var customerIndexer = 0
                                    if(itemCustomerReviews != nil && itemCustomerReviews!.count > 0){
                                        
                                        for eachItem in itemCustomerReviews!{
                                            
                                            let itemIR = NSEntityDescription.insertNewObject(forEntityName: "Reviews", into: managedObjectContext) as! Reviews
                                            itemIR.checked = eachItem!.checked!
                                            itemIR.id = eachItem!._id
                                            itemIR.createdDate = eachItem!.createdDate
                                            itemIR.level = Int32(eachItem!.level!)
                                            itemIR.reviewStatus = Int32(eachItem!.reviewStatus!)
                                            itemIR.reviewType = eachItem?.reviewType
                                            itemIR.index = Int64(customerIndexer)
                                            tempHandOverUnit.addToCustomerReviews(itemIR)
                                            
                                            customerIndexer += 1
                                        }
                                    }
                                    
                                    let itemHistory = handOverUnit?.itemHistory
                                    
                                    var itemIndexer : Int = 0
                                    if(itemHistory != nil){
                                    
                                        for tempItem in itemHistory!{
                                            
                                            let itemHO = NSEntityDescription.insertNewObject(forEntityName: "UnitHandOverItemHistory", into: managedObjectContext) as! UnitHandOverItemHistory
                                            itemHO.modifiedDate = tempItem!.modifiedDate
                                            itemHO.status = Int32(tempItem!.status!)
                                            itemHO.handOverStatus = Int32(tempItem!.handOverStatus!)
                                            itemHO.itemDescription = tempItem?.description
                                            itemHO.imgUrl = tempItem?.imgUrl
                                            itemHO.location = tempItem?.location
                                            itemHO.user = tempItem?.user
                                            itemHO.index = Int64(itemIndexer)
                                            itemIndexer += 1
                                            
                                            tempHandOverUnit.addToItemHistory(itemHO)
                                        }
                                    }
                                    
                                    tempSoldUnit.addToHandOverUnits(tempHandOverUnit)
                                    
                                    //                        tempHandOverUnit.ireviewLevels
                                    //                        tempHandOverUnit.creviewLevels = handOverUnit?.creviewLevels
                                    
                                }
                            }
                            
                            if(soldUnit.handoverHistory != nil && soldUnit.handoverHistory!.count > 0){
                                var indexer = 0
                                for handOverHistory in soldUnit.handoverHistory!
                                {
                                    
                                    let tempHandOverUnitHistory = NSEntityDescription.insertNewObject(forEntityName: "UnitHandOverHistory", into: managedObjectContext) as! UnitHandOverHistory
                                    
                                    tempHandOverUnitHistory.modifiedDate = handOverHistory?.modifiedDate
                                    tempHandOverUnitHistory.user = handOverHistory?.user
                                    tempHandOverUnitHistory.status = Int32(handOverHistory?.status ?? 0)
                                    tempHandOverUnitHistory.index = Int64(indexer)
                                    tempSoldUnit.addToHandOverHistory(tempHandOverUnitHistory)
                                    indexer += 1
//                                    tempSoldUnit.addToHandOverHistory(tempHandOverUnitHistory)
//                                    tempSoldUnit.addToHandOverHistory(tempHandOverUnitHistory)

                                }
                            }
                        }
                        towerIndexCounter += towerIndexCounter
                    }
                    blockIndexCounter += blockIndexCounter
                }
                //                for soldUnit in unitsProjectWise{ }
            }
            
            
            
            // write project details
            for projectId in soldUnitProjectDetails.keys{
                
                let soldUnitProject = NSEntityDescription.insertNewObject(forEntityName: "SoldUnitProjects", into: managedObjectContext) as! SoldUnitProjects
                
                let projectDetails : Dictionary<String,String> = soldUnitProjectDetails[projectId]!
                
                soldUnitProject.projectID = projectDetails["id"]
                soldUnitProject.projectName = projectDetails["name"]
            }
            
            
            do {
//                print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")

                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                completionHandler(true,nil)
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                completionHandler(false,nil)
            }
        }
    }
    func uploadOfflineHandOverData(shouldPostNotification : Bool,isFromHomeView : Bool){
        
        //fetch all units with diryt state upload them and make dirty to clean
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            return
        }
        
        let request: NSFetchRequest<SoldUnits> = SoldUnits.fetchRequest()
        
        let predicate = NSPredicate(format: "syncDirty == %d",SYNC_STATE.SYNC_DIRTY.rawValue)
        
        request.predicate = predicate
        
        request.sortDescriptors = []
        
        let fileManager = FileManager.default
        
        uploadUnitsFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        
        do {
            try uploadUnitsFetchedResultsController?.performFetch()
            
            let fetchedUnits : [SoldUnits] = uploadUnitsFetchedResultsController.fetchedObjects ?? []
            
            if(fetchedUnits.count == 0){
                if(shouldPostNotification && !isFromHomeView){
                    NotificationCenter.default.post(name: NSNotification.Name("FetchHandOverUnits"), object: nil)
                }else if(shouldPostNotification && isFromHomeView){
                    NotificationCenter.default.post(name: NSNotification.Name("FetchHandOverUnitsFromHome"), object: nil)
                }
                return
            }
            
            for eachUnit in fetchedUnits{
                
                // fetch items related to Untis and upload each item images and sycn to DB
                
                let request: NSFetchRequest<TowerHandOverItems> = TowerHandOverItems.fetchRequest()
                let predicate = NSPredicate(format: "unit CONTAINS[c] %@ AND hasOfflineImages == %d",eachUnit.id!,true)
                request.predicate = predicate
                request.sortDescriptors = []
                
                fetchedResultsControllerHandOverItems = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
                
                do {
                    try fetchedResultsControllerHandOverItems.performFetch()
                    
                    let unitHandOverItems : [TowerHandOverItems] = fetchedResultsControllerHandOverItems.fetchedObjects ?? []
                    if(unitHandOverItems.count == 0){
                        self.uploadHandOverUnitsWithoutImageChanges(shouldPostNotification: shouldPostNotification,isFromHomeView: isFromHomeView)
                    }
                    else{
                        var uploadImagesCount = 0
                        for eachItem in unitHandOverItems{
                            
                            if(eachItem.offlineImges != nil && eachItem.offlineImges!.count > 0){
                                //Upload all images
                                uploadImagesCount += eachItem.offlineImges!.count
                                // upload image and remove local path  n image  and add it to complainimages
                                let imagesArray : [String] = eachItem.offlineImges!
                                for imageUrl in imagesArray{
                                    
                                    // get image
                                    let imageDetails = AWS_INPUTS(imageName: URL.init(string: imageUrl)?.lastPathComponent, imageURL: URL.init(string: imageUrl), type: AWS_TYPE.handover)
                                    RRUtilities.sharedInstance.uploadImge(imageDetails: imageDetails, completionHandler: { (responeStr , error) in
                                        if(responeStr != nil){
                                            
                                            //imageUrl
                                            
                                            eachItem.complaintimgUrls?.append(responeStr!)
                                            
                                            eachItem.offlineImges = eachItem.offlineImges?.filter{ $0 != imageUrl }
                                            
                                            if(fileManager.fileExists(atPath: imageUrl)){
                                                try! fileManager.removeItem(at: URL.init(string: imageUrl)!)
                                            }
                                            //save
                                            if(eachItem.offlineImges!.count == 0){
                                                //change
                                                eachUnit.didUploadAllImages = true
                                                //call one funtion to check saved imags count same then upload all units  ** and refresh data?
                                                uploadImagesCount -= 1
                                                if(uploadImagesCount == 0){
                                                    self.didFinishUploadinItemImages(shouldPostNotification: shouldPostNotification,isFromHomeView: isFromHomeView)
                                                }
                                            }
                                            
//                                            print(eachItem.complaintimgUrls) //SAVE
                                        }
                                        else{
                                            //append this to DB as failed to upload , and try next time ***
                                            
                                            eachItem.offlineImges = eachItem.offlineImges?.filter{ $0 != imageUrl }
                                            
                                            if(eachItem.offlineImges!.count == 0){
                                                //change
                                                eachUnit.didUploadAllImages = true
                                                //call one funtion to check saved imags count same then upload all units  ** and refresh data?
                                                uploadImagesCount -= 1
                                                if(uploadImagesCount == 0){
                                                    self.didFinishUploadinItemImages(shouldPostNotification: shouldPostNotification,isFromHomeView: isFromHomeView)
                                                }
                                            }
//                                            print(imageUrl)
                                        }
                                    })
                                }
                            }
                        }
                        if(uploadImagesCount == 0){
                            self.didFinishUploadinItemImages(shouldPostNotification: shouldPostNotification,isFromHomeView: isFromHomeView)
                        }
                    }
                    
                }
                catch {
                    fatalError("Error in fetching records")
                }
            }
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    func uploadHandOverUnitsWithoutImageChanges(shouldPostNotification : Bool,isFromHomeView : Bool){
        if(self.uploadUnitsFetchedResultsController == nil){
            return
        }
        ServerAPIs.syncOfflineHandoverUnits(units: self.uploadUnitsFetchedResultsController.fetchedObjects!, completionHandler: {(responseObject,error) in
            for eachObj in self.uploadUnitsFetchedResultsController.fetchedObjects!{
                eachObj.syncDirty = Int16(SYNC_STATE.SYNC_CLEAN.rawValue)
            }
            do{
                try self.managedObjectContext.save()
                print("saved")
                
                let request: NSFetchRequest<SoldUnits> = SoldUnits.fetchRequest()
                
                let predicate = NSPredicate(format: "syncDirty == %d",SYNC_STATE.SYNC_DIRTY.rawValue)
                
                request.predicate = predicate
                
                request.sortDescriptors = []
                
                self.uploadUnitsFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
                try! self.uploadUnitsFetchedResultsController.performFetch()

                print("uploadUnitsFetchedResultsController.fetchedObjects!")
                print(self.uploadUnitsFetchedResultsController.fetchedObjects!)
            }
            catch{
                
            }
            if(shouldPostNotification && !isFromHomeView){
                NotificationCenter.default.post(name: NSNotification.Name("FetchHandOverUnits"), object: nil)
            }else if(shouldPostNotification && isFromHomeView){
                NotificationCenter.default.post(name: NSNotification.Name("FetchHandOverUnitsFromHome"), object: nil)
            }
            if(responseObject?.status == 1){
                
            }
        })
    }
    func didFinishUploadinItemImages(shouldPostNotification : Bool,isFromHomeView : Bool){
        
        //check for count match **
        var dirtyCountUnitsFetchedResultsController : NSFetchedResultsController<SoldUnits>!
        var uploadCountUnitsFetchedResultsController : NSFetchedResultsController<SoldUnits>!
        
        let request: NSFetchRequest<SoldUnits> = SoldUnits.fetchRequest()
        
        let predicate = NSPredicate(format: "syncDirty == %d",SYNC_STATE.SYNC_DIRTY.rawValue)
        request.predicate = predicate
        request.sortDescriptors = []
        dirtyCountUnitsFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        
        try! dirtyCountUnitsFetchedResultsController.performFetch()
        
        let predicate1 = NSPredicate(format: "didUploadAllImages == %d",true)
        request.predicate = predicate1
        request.sortDescriptors = []
        uploadCountUnitsFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)

        try! uploadCountUnitsFetchedResultsController.performFetch()
        
        if(uploadCountUnitsFetchedResultsController.fetchedObjects?.count == dirtyCountUnitsFetchedResultsController.fetchedObjects?.count){
             //start uploading units
            
            ServerAPIs.syncOfflineHandoverUnits(units: uploadCountUnitsFetchedResultsController.fetchedObjects!, completionHandler: {(responseObject,error) in
                if(shouldPostNotification && !isFromHomeView){
                    NotificationCenter.default.post(name: NSNotification.Name("FetchHandOverUnits"), object: nil)
                }else if(shouldPostNotification && isFromHomeView){
                    NotificationCenter.default.post(name: NSNotification.Name("FetchHandOverUnitsFromHome"), object: nil)
                }
                if(responseObject?.status == 1){
                    
                }
            })
        }
        else{
            //still uploading images
        }
        
    }
    func getSoldUnitsProjectList() -> Array<SoldUnitProjects>{
        
        let projects = NSFetchRequest<SoldUnitProjects>(entityName: "SoldUnitProjects")
        projects.resultType = .dictionaryResultType
        
        do {
            let projectList = try managedObjectContext.fetch(projects)
            return projectList
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
        }
    }
    func writeAllPermissonsToDB(permissions : [USER_PERMISSIONS]){
        
        self.resetEntity(entityName: "Permissions")
        self.resetEntity(entityName: "ModulePermissions")
        
        self.persistentContainer.performBackgroundTask { (managedObjectContext) in
            
            for tempPermission in permissions{
                
                let permissionsObj = NSEntityDescription.insertNewObject(forEntityName: "Permissions", into: managedObjectContext) as! Permissions
                
                permissionsObj.name = tempPermission.name
                permissionsObj.bit = Int32(tempPermission.bit!)
                permissionsObj.identifier = tempPermission.identifier
                permissionsObj.module = tempPermission.module
                permissionsObj.page = tempPermission.page
                
//                print(tempPermission.name ?? "",tempPermission.module ?? "",tempPermission.identifier ?? "")
                
//                if(tempPermission.name == "Prospects"){
//
//                    print("Prospects")
//                }
//                if(tempPermission.name == "Prospects"){
//
//                    print("Prospects")
//                }


                for moduleItem in tempPermission.items ?? []{
                    
//                    let modulePermissionObj = NSEntityDescription.insertNewObject(forEntityName: "ModulePermissions", into: managedObjectContext) as! ModulePermissions
                    
                    let modulePermissionObj = NSEntityDescription.insertNewObject(forEntityName: "Permissions", into: managedObjectContext) as! Permissions
                    modulePermissionObj.name = moduleItem.name
                    modulePermissionObj.page = moduleItem.page
                    modulePermissionObj.bit = Int32(moduleItem.bit!)
                    
//                    permissionsObj.addToModules(modulePermissionObj)
                }
            }
            
            do {
                try managedObjectContext.save()
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    func getAllUnitsNamesOfProject(projectID : String,unitName : String){
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Units")
        fetchRequest.resultType = .dictionaryResultType

        let predicate = NSPredicate(format: "project CONTAINS[c] %@", projectID) //AND description1 CONTAINS[c] %@
        fetchRequest.propertiesToFetch = ["description1","id"]
        fetchRequest.predicate = predicate
        
        let unitsList = try! managedObjectContext.fetch(fetchRequest)
//        print(unitsList)
    }
    func getPaymentTowardsTypes()->[NSDictionary]{

        let fetchRequest =  NSFetchRequest<NSDictionary>(entityName: "PaymentTowards")
        fetchRequest.resultType = .dictionaryResultType

        fetchRequest.propertiesToFetch = ["name"]

        var paymentToWardsList = try! managedObjectContext.fetch(fetchRequest)
//        var dictionay = NSDictionary.init(object: "All", forKey: "name" as NSCopying)

        let tempDict = NSMutableDictionary.init()
        tempDict["name"] = "All"
        
        paymentToWardsList.insert(tempDict, at: 0)
        
        return paymentToWardsList
    }
    func getSelectedTowerDetailsByTowerId(towerId : String) -> Towers?{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Towers")

        let predicate = NSPredicate(format: "id CONTAINS[c] %@", towerId)
        fetchRequest.predicate = predicate
        let towersList = try! managedObjectContext.fetch(fetchRequest)
        
        if(towersList.count > 0){
            let tower = towersList[0]
            return (tower as! Towers)
        }
        else{
            return nil
        }
    }
    func getSelectedBlockDetailsByBlockId(blockID : String) -> Blocks?{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Blocks")
        
        let predicate = NSPredicate(format: "id CONTAINS[c] %@", blockID)
        fetchRequest.predicate = predicate
        let blocksList = try! managedObjectContext.fetch(fetchRequest)
        if(blocksList.count > 0){
            let block = blocksList[0]
            return (block as! Blocks)
        }
        else{
            return nil
        }
    }
    func getProjectDetailsById(projectId:String) -> Project?
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
//        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "id CONTAINS[c] %@", projectId)
        fetchRequest.predicate = predicate
        let projectList = try! managedObjectContext.fetch(fetchRequest)
        
        if(projectList.count > 0){
            let project = projectList[0]
            return (project as! Project)
        }
        else{
            return nil
        }
        
    }
    func getUnitsByTowerId(towerID : String)->[Units]?{
     
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Units")
        
        let predicate = NSPredicate(format: "tower CONTAINS[c] %@ AND status == %d", towerID,0)
        fetchRequest.predicate = predicate
        let unitsList = try! managedObjectContext.fetch(fetchRequest)
        
        return (unitsList as! [Units])
    }
    func getUnitsByOnyTowerID(towerID : String)->[Units]?{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Units")
        
        let predicate = NSPredicate(format: "tower CONTAINS[c] %@", towerID)
        fetchRequest.predicate = predicate
        let unitsList = try! managedObjectContext.fetch(fetchRequest)
        
        return (unitsList as! [Units])
    }

    func getSelectedProjectUnitsByProjectId(projectId : String) -> [Units]?{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Units")
        
        let predicate = NSPredicate(format: "project CONTAINS[c] %@", projectId)
        fetchRequest.predicate = predicate
        let unitsList = try! managedObjectContext.fetch(fetchRequest)
        
//        print(unitsList)
        
//        let unitDetails = unitsList[0]
        
        return (unitsList as! [Units])
    }
    func getTowersByBlockId(blockID : String) -> [Towers]?{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Towers")
        
        let predicate = NSPredicate(format: "block CONTAINS[c] %@", blockID)
        fetchRequest.predicate = predicate
        let towersList = try! managedObjectContext.fetch(fetchRequest)
        
        return (towersList as! [Towers])

    }
    func getSelectedProjettTowersByProjectId(projectId : String) -> [Towers]?{
     
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Towers")
        
        let predicate = NSPredicate(format: "project CONTAINS[c] %@", projectId)
        fetchRequest.predicate = predicate
        let towersList = try! managedObjectContext.fetch(fetchRequest)
        
//        print(towersList)
        
        return (towersList as! [Towers])

    }
    func getSelectedProjectBlocksByProjectId(projectId : String) -> [Blocks]?{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Blocks")
        
        let predicate = NSPredicate(format: "project CONTAINS[c] %@", projectId)
        fetchRequest.predicate = predicate
        let blocksList = try! managedObjectContext.fetch(fetchRequest)
        
//        print(blocksList)
        
//        let blockDetails = blocksList[0]
        
        return (blocksList as? [Blocks])
    }
    func notificationsCount()->Int{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notifications")
        fetchRequest.resultType = NSFetchRequestResultType.countResultType
        let count = try! managedObjectContext.count(for:fetchRequest)
        return count
    }
    func getProjectsCount() -> Int{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        fetchRequest.resultType = NSFetchRequestResultType.countResultType
        let count = try! managedObjectContext.count(for:fetchRequest)
        return count
    }
    func getRRUser()->RRUser?{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RRUser")
        fetchRequest.resultType = NSFetchRequestResultType.managedObjectResultType
        let user = try! managedObjectContext.fetch(fetchRequest)
        if(user.count > 0){
            let tempUser = user[0] as! RRUser
            return tempUser
        }
        else{
            return nil
        }
    }
    func getCountOfItemGroup(unit : String,groupdName : String, mandatory : Bool,handOverStatus : Int)->Int{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TowerHandOverItems")
        fetchRequest.resultType = NSFetchRequestResultType.countResultType
        
        let predicate = NSPredicate(format: "unit CONTAINS[c] %@ AND groupdName CONTAINS[c] %@ AND mandatory == %d AND handOverStatus == %d", unit,groupdName,mandatory,handOverStatus)
        fetchRequest.predicate = predicate

        let count = try! managedObjectContext.count(for:fetchRequest)
        return count
    }
    func checkForMandatoryItems(unit : String, mandatory : Bool,handOverStatus : Int)->Int{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TowerHandOverItems")
        fetchRequest.resultType = NSFetchRequestResultType.countResultType
        
        let predicate = NSPredicate(format: "unit CONTAINS[c] %@ AND mandatory == %d AND handOverStatus == %d", unit,mandatory,handOverStatus)
        fetchRequest.predicate = predicate
        
        let count = try! managedObjectContext.count(for:fetchRequest)
        return count
    }
    func getUnitsCountForProject(projectId : String)-> Int{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Units")
        fetchRequest.resultType = NSFetchRequestResultType.countResultType
        let predicate = NSPredicate(format: "project CONTAINS[c] %@", projectId)
        fetchRequest.predicate = predicate

        let count = try! managedObjectContext.count(for:fetchRequest)
        return count
    }
    func getAllProjectRecords() -> Array<Project>{
        
        let projects = NSFetchRequest<Project>(entityName: "Project")
        projects.resultType = .dictionaryResultType
        
        do {
            let projectList = try managedObjectContext.fetch(projects)
            
//            for project in projectList{
//
//                for stat in project.proStat!{
//                    print(stat)
//                }
//            }
            
            return projectList
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
        }
    }
    func resetAllEmployees(){
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try managedObjectContext.execute(deleteRequest)
            try managedObjectContext.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
    func resetAllUnits(){
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Units")
        deleteFetch.returnsObjectsAsFaults = false
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try managedObjectContext.execute(deleteRequest)
            try managedObjectContext.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
    func resetAllVehicles(){
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Vehicle")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try managedObjectContext.execute(deleteRequest)
            try managedObjectContext.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
    func resetAllDrivers(){
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Driver")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try managedObjectContext.execute(deleteRequest)
            try managedObjectContext.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
    func resetAllEnquirySources() {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "EnquirySources")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try managedObjectContext.execute(deleteRequest)
            try managedObjectContext.save()
        }
        catch
        {
            print ("There was an error resetAllEnquirySources")
        }
    }
    func resetProjectsEntity() {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try managedObjectContext.execute(deleteRequest)
            try managedObjectContext.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
    func updateUnitStatusWithID(unitID : String,status : Int){
        
    }
    func updateStatusOfSelectedUnit(selectedProjectId : String,oldStatus : Int, updatedStatus : Int){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        fetchRequest.predicate = NSPredicate(format: "id = %@",
                                             argumentArray: [selectedProjectId])
        do {
            let results = try managedObjectContext.fetch(fetchRequest) as? [Project]
            if results?.count != 0 { // Atleast one was returned
                
                // In my case, I only updated the first item in results
                
                let project = results![0]
                
                let statssss : NSMutableOrderedSet = project.value(forKey: "proStat") as! NSMutableOrderedSet
                
                for stat in statssss{
                    
                    let actualStats = stat as! TempObj
                    
                    if(Int(actualStats.status) == updatedStatus){
                        actualStats.count = actualStats.count + 1
                    }
                    if(actualStats.status == oldStatus){
                        if((actualStats.count - 1) == 0){
                            actualStats.count = 0
                        }
                        else{
                            actualStats.count = actualStats.count - 1
                        }
                    }
                }
                
                results![0].setValue(statssss, forKey: "proStat")
            }
        } catch {
            print("Fetch Failed: \(error)")
        }
        
        do {
            try managedObjectContext.save()
            print("Project statuses updated")
        }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
        
    }
    func getAllProjects() -> Array<Project>{
        
        let activityInfo = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        
        do {
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let sortDescriptors = [sortDescriptor]
            activityInfo.sortDescriptors = sortDescriptors

            let fetchedActivities = try managedObjectContext.fetch(activityInfo) as! [Project]
//            print("fetchedActivities \(fetchedActivities)")
            
//            for projDict in fetchedActivities{
//                print(projDict.address)
//            }
            
//            for project in fetchedActivities{
//
//                let statssss : NSMutableOrderedSet = project.value(forKey: "proStat") as! NSMutableOrderedSet
//                print("stsaa \(String(describing: statssss))")
//
////                for temperrr in statssss{
////                    print(statssss)
////                    let tester = temperrr as! TempObj
////                    print(tester.count)
////                    print(tester.status)
////                }
//
////                if(statssss != nil){
////                    for temperr in statssss{
////                        print(temperr.status)
////                    }
////                }
////                for stat in statssss{
////
////                }
////
//            }

            
            return fetchedActivities
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
            //            fatalError("Failed to fetch employees: \(error)")
        }
    }
    func saveContext () {
        guard self.managedObjectContext.hasChanges else { return }

        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
}

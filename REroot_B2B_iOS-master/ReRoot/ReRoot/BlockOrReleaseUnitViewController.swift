//
//  BlockOrReleaseUnitViewController.swift
//  REroot
//
//  Created by Dhanunjay on 07/12/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import CoreData

protocol UnitStatusChangeDelegateDelegate: class {
    func didFinishUnitStatusChange(selectedUnit : Units,selectedIndexPath : IndexPath,unitStatus : Int)
}

class BlockOrReleaseUnitViewController: UIViewController,UIPopoverControllerDelegate,UIPopoverPresentationControllerDelegate,HidePopUp,UITextFieldDelegate{
    
    var isFromCRM : Bool = false
    @IBOutlet var releaseUnitButton: UIButton!
    @IBOutlet var blockUnitButton: UIButton!
    @IBOutlet weak var heightOfButtonsView: NSLayoutConstraint!
    @IBOutlet var buttonsView: UIView!
    var selectedUnitIndexPath : IndexPath!
    weak var delegate:UnitStatusChangeDelegateDelegate?
    var selectedBlockingReason : String!
    @IBOutlet var titleInfoView: UIView!
    var selectedUnit : Units!
    @IBOutlet var unitNameDetailsLabel: UILabel!
    var blockReasons : [COMMON_FORMAT] = []
    @IBOutlet var reasonsTextField: UITextField!
    
    @IBOutlet var unitTypeLabel: UILabel!
    @IBOutlet var statusTypeLabel: UILabel!
    @IBOutlet var unitNameLabel: UILabel!
    
    var projectName = String()
    var blockName = String()
    var towerName = String()
    var floorName = String()
    var unitType = String()
    var unitDetailsString = String()

    @objc func injected() {
        
//        self.getBlockingReasons()
    }

    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        titleInfoView.clipsToBounds = true
        
        titleInfoView.layer.masksToBounds = false
        titleInfoView.layer.shadowColor = UIColor.lightGray.cgColor
        titleInfoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        titleInfoView.layer.shadowOpacity = 0.4
        titleInfoView.layer.shadowRadius = 1.0
        titleInfoView.layer.shouldRasterize = true
        titleInfoView.layer.borderColor = UIColor.lightGray.cgColor
        
        titleInfoView.layer.shouldRasterize = true
        titleInfoView.layer.rasterizationScale = UIScreen.main.scale
        self.view.bringSubviewToFront(titleInfoView)
        
        
        buttonsView.clipsToBounds = true
        
        buttonsView.layer.masksToBounds = false
        buttonsView.layer.shadowColor = UIColor.lightGray.cgColor
        buttonsView.layer.shadowOffset = CGSize(width: 0, height: -2)
        
        buttonsView.layer.shadowOpacity = 0.4
        buttonsView.layer.shadowRadius = 1.0
        buttonsView.layer.shouldRasterize = true
        buttonsView.layer.borderColor = UIColor.lightGray.cgColor
        
        buttonsView.layer.shouldRasterize = true
        buttonsView.layer.rasterizationScale = UIScreen.main.scale
        self.view.bringSubviewToFront(buttonsView)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("handleBack"), object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        var tempBlockReason = COMMON_FORMAT.init()
        
        tempBlockReason.name = "None"
        tempBlockReason._id = "None"
        
        self.blockReasons.append(tempBlockReason)
        
        reasonsTextField.delegate = self
        unitNameLabel.text = String(format: "%@ (%@)", selectedUnit.unitDisplayName!,selectedUnit.description1!)
        unitNameLabel.textColor = UIColor.hexStringToUIColor(hex: "34495e")
        
        let colorDict  = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: Int(selectedUnit!.status))
        statusTypeLabel.textColor = colorDict["color"] as? UIColor
        statusTypeLabel.text = colorDict["statusString"] as? String
        
        unitTypeLabel.text = selectedUnit.typeName ?? "-"
        unitTypeLabel.textColor = UIColor.hexStringToUIColor(hex: "34495e")

        unitDetailsString = String(format: "%@ > %@ > %@ > %d > %@ > %@ (%@)", projectName,blockName,towerName,selectedUnit.floorIndex,unitType,selectedUnit.unitDisplayName!,selectedUnit.description1!)
        unitNameDetailsLabel.textColor = UIColor.hexStringToUIColor(hex: "184c67") //384a5a
        unitNameDetailsLabel.text = unitDetailsString
        
        if(selectedUnit.blockingReason != nil && (selectedUnit.blockingReason?.count)! > 0){
            self.reasonsTextField.text = selectedUnit.blockingReason
            self.selectedBlockingReason = selectedUnit.blockingReason
        }
        else{
            self.reasonsTextField.text = "None"
            self.selectedBlockingReason = "None"
        }

        self.blockReasons += RRUtilities.sharedInstance.defaultBookingFormSetUp.blockReason! + RRUtilities.sharedInstance.customBookingFormSetUp.blockReason!

        print(blockReasons)
        
        if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.BLOCK_RELEASE_UNIT.rawValue, permissionType: UserRolePermissions.CREATE.rawValue) || !PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.BLOCK_RELEASE_UNIT.rawValue, permissionType: UserRolePermissions.EDIT.rawValue)){
            self.heightOfButtonsView.constant = 0
            self.buttonsView.isHidden = true
        }
    }
    func showPopUp(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .BLOCKED_REASONS
        vc.preferredContentSize = CGSize(width: 250, height: self.blockReasons.count * 44)
        
        if(CGFloat((self.blockReasons.count * 44)) > (self.view.frame.size.height - 150)){
            
            vc.preferredContentSize = CGSize(width: 250, height: (self.view.frame.size.height - 150))
        }
        else{
            let widht : Float = Float(self.view.frame.size.width - 70.0)
            vc.preferredContentSize = CGSize(width: Int(widht) , height: (blockReasons.count - 1) * 44)
        }
        
        vc.blockReasonsDataSource = self.blockReasons
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.down
        popOver?.sourceView = self.reasonsTextField

        
        vc.delegate = self
        popOver?.sourceRect = reasonsTextField.frame
        
        self.present(navigationContoller, animated: true, completion: nil)
    }

    // MARK: - URLS
    
    func getDefaultBookingSetup(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.progress)
        
        let urlString = String(format: RRAPI.API_GET_DEFAULT_BOOKING_SETUP)
    
//        print(urlString)
        
        AF.request(RRAPI.API_GET_DEFAULT_BOOKING_SETUP, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(RESERVATIONS_API_RESULT.self, from: responseData)
//                    print(urlResult)
                    
                    if(urlResult.status == 1){
                    }
                    else if(urlResult.status == -1){
                    }
                    else if(urlResult.status == 0){ ///fail status
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    func getCustomBookingSetup(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.progress)
        
        let urlString = String(format: RRAPI.API_GET_CUSTOM_BOOKING_SETUP)
        
//        print(urlString)
        
        AF.request(RRAPI.API_GET_CUSTOM_BOOKING_SETUP, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(BOOKING_FORM_SET_UP.self, from: responseData)
//                    print(urlResult)
                    
                    if(urlResult.status == 1){
//                        self.blockReasons = urlResult.BookingFormSetup?.blockReason
//                        self.blockReasons += (urlResult.BookingFormSetup?.blockReason)!
//                        let arrayaa = urlResult.BookingFormSetup?.blockReason
//                        self.blockReasons.append(arrayaa)

                    }
                    else if(urlResult.status == -1){
                    }
                    else if(urlResult.status == 0){ ///fail status
                    }
                    
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    // MARK: - ACTION CALLS
    @IBAction func releaseUnit(_ sender: Any) {
        self.blockOrReleaseSelectedUnit(sender as! UIButton)
    }
    @IBAction func blockUnit(_ sender: Any) {
        self.blockOrReleaseSelectedUnit(sender as! UIButton)
    }
    func blockOrReleaseSelectedUnit(_ sender: UIButton){
    
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }

        HUD.show(.progress)
        
        var blockedUnitDetails : Dictionary<String,Any> = [:]
        
        blockedUnitDetails["_id"] = selectedUnit.id
        if(sender.tag == 1)
        {
            blockedUnitDetails["status"] = UNIT_STATUS.BLOCKED.rawValue //selectedUnit.status
            blockedUnitDetails["oldStatus"] = UNIT_STATUS.VACANT.rawValue
        }
        else{
            blockedUnitDetails["status"] = UNIT_STATUS.VACANT.rawValue //selectedUnit.status
            blockedUnitDetails["oldStatus"] = UNIT_STATUS.BLOCKED.rawValue

            if(selectedUnit.status == UNIT_STATUS.VACANT.rawValue){
                HUD.flash(.label("Cannot release vacant unit(s)"), delay: 1.0)
                return
            }
        }
       blockedUnitDetails["unitDescription"] = self.selectedUnit.description1
        blockedUnitDetails["projectName"] = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: self.selectedUnit.project!)?.name ?? ""
        
        if(sender.tag == 1){
            if(self.selectedBlockingReason == "None"){
                HUD.flash(.label("Please select a reason for blocking"), delay: 1.0)
                return
            }
            blockedUnitDetails["blockingReason"] = self.selectedBlockingReason
            
            if(self.selectedBlockingReason.count == 0){
                HUD.flash(.label("Please select a reason for blocking"), delay: 1.0)
                return
            }
        }
        else{
            self.selectedBlockingReason = "None"
            blockedUnitDetails["blockingReason"] = ""
        }
        
        var blockedUnitsArray : Array<Dictionary<String,Any>> = []
        blockedUnitsArray.append(blockedUnitDetails)
        
        print(blockedUnitDetails)
        print(blockedUnitsArray)
        
        var parameters : Dictionary<String,Any> = [:]
        
        parameters["units"] = blockedUnitsArray
        
        ServerAPIs.blockOrReleaseSelectedUnit(parameters: parameters, tag: sender.tag, completionHandler: ({ responseObject , error in

            if(responseObject != nil){

                if(responseObject?.status == 1){
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_UNIT_DETAILS), object: nil)
                    if(sender.tag == 1){
                        HUD.flash(.label("UNIT BLOCKED SUCCESSFULLY"), delay: 1.5)
                        if(self.isFromCRM){
                            self.updateUnitStatusInDatabase(unitStatus: UNIT_STATUS.BLOCKED.rawValue)
                        }
                        else{
                            self.updateUnitStatusInDatabase(unitStatus: UNIT_STATUS.BLOCKED.rawValue)
                            self.delegate?.didFinishUnitStatusChange(selectedUnit: self.selectedUnit, selectedIndexPath: self.selectedUnitIndexPath, unitStatus: UNIT_STATUS.BLOCKED.rawValue)
                        }
                    }
                    else{
                        HUD.flash(.label("UNIT RELEASED SUCCESSFULLY"), delay: 1.5)
                        if(self.isFromCRM){
                            self.updateUnitStatusInDatabase(unitStatus: UNIT_STATUS.VACANT.rawValue)
                        }
                        else{
                            self.updateUnitStatusInDatabase(unitStatus: UNIT_STATUS.BLOCKED.rawValue)
                            self.delegate?.didFinishUnitStatusChange(selectedUnit: self.selectedUnit, selectedIndexPath: self.selectedUnitIndexPath, unitStatus: UNIT_STATUS.VACANT.rawValue)
                        }
                    }
                    if(self.isFromCRM){
                        self.perform(#selector(self.popController), with: nil, afterDelay: 1.0)
                    }else{
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else if((responseObject?.status == -1)){
                    HUD.flash(.label(responseObject?.err), delay: 1.5)
                }
                else if((responseObject?.status == 0)){
                    HUD.flash(.label(responseObject?.err), delay: 1.5)
                }
            }
            else{

            }
        }))
        
        

    }
    @objc func popController(){
        self.dismiss(animated: true, completion: nil)
    }
    func updateUnitStatusInDatabase(unitStatus : Int){
        
        RRUtilities.sharedInstance.model.updateStatusOfSelectedUnit(selectedProjectId: selectedUnit.project!, oldStatus: Int(selectedUnit.status),updatedStatus: unitStatus)
        
        let unitDetsils = RRUtilities.sharedInstance.model.getUnitDetailsByUnitID(unitId: selectedUnit.id!)
        
        let childContext = NSManagedObjectContext(
            concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = RRUtilities.sharedInstance.model.managedObjectContext
        
        let childEntry = childContext.object(
            with: unitDetsils!.objectID) as? Units
        
        childEntry?.status = Int64(unitStatus)
        childEntry?.blockingReason = self.selectedBlockingReason
        
        childContext.perform {
            do {
                try childContext.save()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            RRUtilities.sharedInstance.model.saveContext()
        }
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - HIDE POPUP
    func didSelectProject(optionType: String, optionIndex: Int) {
        print(optionType)
        
        self.selectedBlockingReason = optionType
        self.reasonsTextField.text = optionType
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });

    }
    
    func didSelectOptionForUnitsView(selectedIndex: Int) {
        
    }
    
    func shouldShowUnitsWithSelectedStatus(selectedStatus: Int) {
        
    }
    
    func showSelectedTowerFromFloatButton(selectedTower: Towers, selectedBlock: String) {
        
    }
    func didFinishTask(optionType: String, optionIndex: Int) {
        
    }
    
    // MARK: - TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField == reasonsTextField) {
            //show popup
            self.showPopUp()
            return false
        }
        return true
        
    }
    //MARK: - popOver
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

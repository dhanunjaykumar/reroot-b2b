//
//  ReserveUnitViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 29/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import CoreData

class ReserveUnitViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    @IBOutlet weak var heightOfReserveButton: NSLayoutConstraint!
    @IBOutlet var revokeAllRsrvsButton: UIButton!
    @IBOutlet var reservButtonView: UIView!
    var rsrvTableViewDataSource : [RESERVED_UNITS] = []
    @IBOutlet var heightOfReservationInfoView: NSLayoutConstraint!
    var isFromCRM : Bool = false
    weak var delegate:UnitStatusChangeDelegateDelegate?
    var selectedUnitIndexPath : IndexPath!
    
    @IBOutlet var heightOfReservationsTableView: NSLayoutConstraint!
    @IBOutlet var reservationsInfoView: UIView!
    @IBOutlet var reservationsTableView: UITableView!
    
    @IBOutlet var clientIdLabel: UILabel!
    @IBOutlet var clientNameLabel: UILabel!
    @IBOutlet var unitTypeLabel: UILabel!
    @IBOutlet var unitStatusLabel: UILabel!
    @IBOutlet var unitDescriptionLabel: UILabel!
    @IBOutlet var unitNameDetailsLabel: UILabel!
    @IBOutlet var titleInfoView: UIView!
    var selectedUnit : Units!
    var selectedCustomerInfo : CUSTOMER!
    var unitDetailsString = String()
    
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
        
        reservButtonView.clipsToBounds = true
        
        reservButtonView.layer.masksToBounds = false
        reservButtonView.layer.shadowColor = UIColor.lightGray.cgColor
        reservButtonView.layer.shadowOffset = CGSize(width: 0, height: -2)
        
        reservButtonView.layer.shadowOpacity = 0.4
        reservButtonView.layer.shadowRadius = 1.0
        reservButtonView.layer.shouldRasterize = true
        reservButtonView.layer.borderColor = UIColor.lightGray.cgColor
        
        reservButtonView.layer.shouldRasterize = true
        reservButtonView.layer.rasterizationScale = UIScreen.main.scale
        self.view.bringSubviewToFront(reservButtonView)

    }
    @objc func injected() {
        configureView()
    }
    func configureView(){
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(selectedCustomerInfo)
        unitNameDetailsLabel.text = unitDetailsString
        unitNameDetailsLabel.textColor = UIColor.hexStringToUIColor(hex: "006b98")

        unitDescriptionLabel.text = String(format: "%@ (%@)", selectedUnit!.unitDisplayName!,selectedUnit.description1!)
        unitDescriptionLabel.textColor = UIColor.hexStringToUIColor(hex: "34495e")
        
        let colorDict  = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: Int(selectedUnit!.status))
        unitStatusLabel.textColor = colorDict["color"] as? UIColor
        unitStatusLabel.text = colorDict["statusString"] as? String
        
        unitTypeLabel.text = selectedUnit.typeName ?? "-"
        unitTypeLabel.textColor = UIColor.hexStringToUIColor(hex: "34495e")
        
        clientNameLabel.text = selectedCustomerInfo.regInfo?.userName
        if(selectedCustomerInfo.regInfo?.prospectId != nil){
            clientIdLabel.text = selectedCustomerInfo.regInfo?.prospectId
        }
        else{
            clientIdLabel.text = "-"
        }
        
        let nib = UINib(nibName: "ReservationTableViewCell", bundle: nil)
        reservationsTableView.register(nib, forCellReuseIdentifier: "reservQueueCell")
        
        reservationsTableView.tableFooterView = UIView()
        
        reservationsTableView.estimatedRowHeight = UITableView.automaticDimension
        reservationsTableView.rowHeight = UITableView.automaticDimension
        
        self.getReserations()
        
        if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.RESERVE_UNIT.rawValue, permissionType: UserRolePermissions.CREATE.rawValue)){
            self.reservButtonView.isHidden = true
            self.heightOfReserveButton.constant = 0
            return
        }
    }
    func configureReservationsTableView(){
        
        self.reservationsTableView.reloadData()
        
    }
    @IBAction func reserveUnit(_ sender: Any) {
        
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
        var parameters : Dictionary<String,String> = [:]

        parameters["prospect"] = selectedCustomerInfo.regInfo?._id
        parameters["unit"] = selectedUnit.id
        parameters["currProspectId"] = selectedCustomerInfo._id
        parameters["duration"] = "3"

        parameters["unitNo"] = String(format: "%d", Int(selectedUnit.unitIndex))
        parameters["unitDescription"] = selectedUnit.description1
        parameters["projectName"] = selectedUnit.project
        parameters["userName"] = selectedCustomerInfo.regInfo?.userName
        parameters["src"] = "3"
//        print(parameters)
        print(RRAPI.API_RESERVE_UNIT)
        AF.request(RRAPI.API_RESERVE_UNIT, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                HUD.hide()
//                print(response)
                let str = String(data: response.data!, encoding: .utf8)
                print(str!)

                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                let urlResult = try! JSONDecoder().decode(RESERVE_UNIT_API_RESULT.self, from: responseData)
                
                if(urlResult.status == 1){ // success
                    
//                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_UNIT_DETAILS), object: nil)
                    var  infoDict : Dictionary<String,Any> = [:]
                    infoDict["unitStatus"] = UNIT_STATUS.RESERVED.rawValue
                    infoDict["isReserve"] = true
                    if(self.isFromCRM){
                        self.updateUnitStatusInDatabase(unitStatus: UNIT_STATUS.RESERVED.rawValue)
                    }
                    else{
                        self.delegate?.didFinishUnitStatusChange(selectedUnit: self.selectedUnit, selectedIndexPath: self.selectedUnitIndexPath, unitStatus: UNIT_STATUS.RESERVED.rawValue)
                    }
                    HUD.flash(.label("Unit reserved successfully"), delay: 1.0)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.UNIT_RESERVED), object: nil, userInfo: infoDict)
                    if(self.isFromCRM){
                        self.perform(#selector(self.popController), with: nil, afterDelay: 1.0)
                    }else{
                        self.navigationController?.popViewController(animated: true)
                    }
//                    self.navigationController?.popViewController(animated: false)
                    
                }
                else if(urlResult.status == -1){
                    let urlResult1 = try! JSONDecoder().decode(RESERVE_UNIT_API_RESULT_ONE.self, from: responseData)
                    HUD.flash(.label(urlResult1.err), delay: 1.0) //_message
                    return
                }
                else if(urlResult.status == 0){
                    
//                    guard let output : Dictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
//                        print("error trying to convert data to JSON")
//                        return
//                    }
//                    if(output["err"]){
//                        HUD.flash(.label(output["err"]), delay: 1.0) //_message
//                    }

                    do{
                        let urlResult1 = try JSONDecoder().decode(RESERVE_UNIT_API_RESULT_TWO.self, from: responseData)
                        if(urlResult1  == nil){
                            let urlResult2 = try JSONDecoder().decode(RESERVE_UNIT_API_RESULT_ONE.self, from: responseData)
                            if(urlResult2 != nil){
                                HUD.flash(.label(urlResult2.err), delay: 1.0) //_message
                            }
                            else{
                                throw Erro_Handler.FoundReserveError("Reservation Error")
                            }
                        }
                        else{
                            HUD.flash(.label(urlResult1.err?._message), delay: 2.0)
                        }
                    }
                    catch let error{
                        print(error)
                        HUD.flash(.label(error.localizedDescription), delay: 2.0)
                    }
                }
                // make tableview data
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    @objc func popController()
    {
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
    func getReserations(){
        
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
        
        let urlString = String(format: RRAPI.API_GET_RESERVATIONS_OF_UNIT, selectedUnit.id!)
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                    let urlResult = try! JSONDecoder().decode(RESERVATIONS_API_RESULT.self, from: responseData)
//                    print(urlResult)
                    self.rsrvTableViewDataSource.removeAll()
                    self.reservationsTableView.reloadData()
                    if(urlResult.status == 1){
                        self.rsrvTableViewDataSource = urlResult.reservedUnits ?? []
                        self.reservationsTableView.delegate = self
                        self.reservationsTableView.dataSource = self
                        if(self.rsrvTableViewDataSource.count == 0){
                            self.reservationsInfoView.isHidden = true
                        }
                        self.reservationsTableView.reloadData()
                        self.heightOfReservationInfoView.constant = CGFloat(self.rsrvTableViewDataSource.count * 80)
                        self.heightOfReservationInfoView.constant = self.reservationsTableView.contentSize.height + 70
                        self.reservationsTableView.superview?.layoutIfNeeded()
                        self.heightOfReservationsTableView.constant = self.reservationsTableView.contentSize.height
                    }
                    else if(urlResult.status == -1){
                        self.heightOfReservationInfoView.constant = 0
                        self.heightOfReservationInfoView.constant = 0
                        self.reservationsInfoView.isHidden = true
                    }
                    else if(urlResult.status == 0){ ///fail status
                        self.heightOfReservationInfoView.constant = 0
                        self.heightOfReservationInfoView.constant = 0
                        self.reservationsInfoView.isHidden = true
                    }
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    // MARK: -  Tableview  Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rsrvTableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell : ReservationTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "reservQueueCell",
            for: indexPath) as! ReservationTableViewCell
        
        let reservation : RESERVED_UNITS = self.rsrvTableViewDataSource[indexPath.row]
        
        cell.reservationHolderNameLabel.text = String(format: "#%d %@", indexPath.row + 1 ,(reservation.prospect?.userName)!)
        
        let tempUpdate = reservation.updateBy?.last
        
        let userInfo = tempUpdate?.user!.userInfo
        
        if(userInfo?.name != nil && (userInfo?.name?.count)! > 0){
            cell.reservedByLabel.text = String(format: "Reserved By: %@", userInfo!.name ?? "")
        }
        else{
            cell.reservedByLabel.text = String(format: "Reserved By: %@", "Super admin")
        }
        
        cell.revokeButton.addTarget(self, action: #selector(revokeReservation(_:)), for: .touchUpInside)
        cell.revokeButton.tag = indexPath.row
        
        let fromDate = RRUtilities.sharedInstance.getRedableDayDateFromString(dateStr: reservation.reserveDate!)
        let toDate = RRUtilities.sharedInstance.getRedableDayDateFromString(dateStr: reservation.expiryDate!)
        
        cell.fromDateLabel.text = fromDate
        cell.toDateLabel.text = toDate
        
        return cell
    }
    
    
//    {
//
//        let cell : ReservationTableViewCell = tableView.dequeueReusableCell(
//            withIdentifier: "reservQueueCell",
//            for: indexPath) as! ReservationTableViewCell
//
//        let reservation : RESERVED_UNITS = self.rsrvTableViewDataSource[indexPath.row]
//
//        cell.reservationHolderNameLabel.text = reservation.prospect?.userName
//        cell.reservationHolderNameLabel.textColor = UIColor.hexStringToUIColor(hex: "006b98")
//
//        let fromDate = RRUtilities.sharedInstance.getRedableDayDateFromString(dateStr: reservation.reserveDate!)
//        let toDate = RRUtilities.sharedInstance.getRedableDayDateFromString(dateStr: reservation.expiryDate!)
//
//        cell.revokeButton.addTarget(self, action: #selector(revokeReservation(_:)), for: .touchUpInside)
//        cell.revokeButton.tag = indexPath.row
//
//        cell.fromDateLabel.text = fromDate
//        cell.toDateLabel.text = toDate
//        cell.fromDateLabel.textColor = UIColor.hexStringToUIColor(hex: "006b98")
//        cell.toDateLabel.textColor = UIColor.hexStringToUIColor(hex: "006b98")
//        return cell
//
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
    }
    // MARK: - REVOKE REServations
    @objc func revokeReservation(_ sender : UIButton){
        
        if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.RESERVE_UNIT.rawValue, permissionType: UserRolePermissions.DELETE.rawValue)){
            HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
            return
        }
        
        let selectedRsrvIndex = sender.tag
        
        if(self.rsrvTableViewDataSource.count == 1){
            self.revokeAllReservations(sender)
        }
        else{
            self.revokeSelectedReservation(selectedIndex: selectedRsrvIndex)
        }
    }
    func revokeSelectedReservation(selectedIndex : Int){
        
        if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.RESERVE_UNIT.rawValue, permissionType: UserRolePermissions.DELETE.rawValue)){
            HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
            return
        }

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
        
        let urlString = String(format: RRAPI.API_REVOKE_RESERVATION, selectedUnit.id!)
        
        
        // r_id  //r._id
        // next id
        var parameters : Dictionary<String,String> = [:]
        
        let selectedReservation = self.rsrvTableViewDataSource[selectedIndex]
        
        if(selectedIndex + 1 <= self.rsrvTableViewDataSource.count){
            let nextReservation = self.rsrvTableViewDataSource[selectedIndex]
            parameters["nextRId"] = nextReservation._id
        }
        
        parameters["rId"] = selectedReservation._id
        
        parameters["unitNo"] = String(format: "%d", Int(selectedUnit.unitIndex))
        parameters["unitDescription"] = selectedUnit.description1
        parameters["projectName"] = selectedUnit.project
        parameters["userName"] = selectedCustomerInfo.regInfo?.userName
        parameters["src"] = "3"
        
//        print(parameters)
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
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
                    let urlResult = try! JSONDecoder().decode(COMMON_OUTPUT.self, from: responseData)
//                    print(urlResult)
                    
                    if(urlResult.status == 1){
                        self.getReserations()
                    }
                    else if(urlResult.status == -1){
                        //Logout
                    }
                    else{ ///fail status
                        
                    }
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    @IBAction func revokeAllReservations(_ sender: Any) {
        
        if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.RESERVE_UNIT.rawValue, permissionType: UserRolePermissions.DELETE.rawValue)){
            HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
            return
        }

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
        
        let urlString = String(format: RRAPI.API_REVOKE_ALL_RESERVATIONS)
        
        var parameters : Dictionary<String,Any> = [:]
        
        var arrayOfRsrvIds : [String] = []
        
        for reseration in self.rsrvTableViewDataSource{
            arrayOfRsrvIds.append(reseration._id!)
        }
        
        parameters["rIds"] = arrayOfRsrvIds
        parameters["unit"] = selectedUnit.id
        
        parameters["unitNo"] = String(format: "%d", Int(selectedUnit.unitIndex))
        parameters["unitDescription"] = selectedUnit.description1
        parameters["projectName"] = selectedUnit.project
        parameters["userName"] = selectedCustomerInfo.regInfo?.userName
        parameters["src"] = 3
//        print(parameters)
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    
                    HUD.hide()
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try! JSONDecoder().decode(COMMON_OUTPUT.self, from: responseData)
                    
//                    print(urlResult)
                    
                    if(urlResult.status == 1){
                        //fetch all again // send notification to fetch again
                        
//                        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_UNIT_DETAILS), object: nil)
                        var  infoDict : Dictionary<String,Any> = [:]
                        infoDict["unitStatus"] = UNIT_STATUS.VACANT.rawValue
                        infoDict["isRevoke"] = true
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATIONS.UNIT_RESERVATIONS_REVOKED), object: nil, userInfo: infoDict)

//                        self.delegate?.didFinishUnitStatusChange(selectedUnit: self.selectedUnit, selectedIndexPath: self.selectedUnitIndexPath, unitStatus: UNIT_STATUS.VACANT.rawValue)
                        self.navigationController?.popViewController(animated: true)
                        self.navigationController?.popViewController(animated: false)
                        HUD.flash(.label("Reservation(s) revoked successfully."), delay: 2.0)
                    }
                    else if(urlResult.status == -1){
                        //Logout
                        HUD.flash(.label(urlResult.err), delay: 1.0)
                        
                    }
                    else{ ///fail status
                        HUD.flash(.label(urlResult.err), delay: 1.0)
                    }
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
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

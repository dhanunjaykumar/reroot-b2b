//
//  AgreementViewController.swift
//  REroot
//
//  Created by Dhanunjay on 07/06/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import PKHUD
import CoreData

class AgreementViewController: UIViewController {

    var agreementType : Int!
    var isFromCRM : Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var saveButtonView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    var selectedUnitName : String!
    var unitPath : String!
    var selectedUnit : Units!
    var selectedIndexPathForUnit : IndexPath!
    weak var unitStatusDelegate:UnitStatusChangeDelegateDelegate?
    
    var shouldUpdateUnitStatusToSold : Bool = false
    
    @IBOutlet weak var agreementTypeLabel: UILabel!
    @IBOutlet weak var unitNamePathLabel: UILabel!
    @IBOutlet weak var unitNameLabel: UILabel!
    @IBOutlet weak var unitStatusNameLabel: UILabel!
    @IBOutlet weak var unitTypeLabel: UILabel!
    
    var astTableViewDataSource : [AST]?
    var astInfo : ASTInfo!
    
    // MARK: - ViewController Life cycle
    // MARK: - View LIfe cycle
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        titleView.clipsToBounds = true
        
        titleView.layer.masksToBounds = false
        titleView.layer.shadowColor = UIColor.lightGray.cgColor
        titleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        titleView.layer.shadowOpacity = 0.4
        titleView.layer.shadowRadius = 1.0
        titleView.layer.shouldRasterize = true
        titleView.layer.borderColor = UIColor.lightGray.cgColor
        
        titleView.layer.shouldRasterize = true
        titleView.layer.rasterizationScale = UIScreen.main.scale
        self.view.bringSubviewToFront(titleView)
        
        if(PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.AGREEMENT_STATUS_TRACKER.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)){
            saveButtonView.clipsToBounds = true
            
            saveButtonView.layer.masksToBounds = false
            saveButtonView.layer.shadowColor = UIColor.lightGray.cgColor
            saveButtonView.layer.shadowOffset = CGSize(width: 0, height: -1)
            
            saveButtonView.layer.shadowOpacity = 0.4
            saveButtonView.layer.shadowRadius = 1.0
            saveButtonView.layer.shouldRasterize = true
            saveButtonView.layer.borderColor = UIColor.lightGray.cgColor
            
            saveButtonView.layer.shouldRasterize = true
            saveButtonView.layer.rasterizationScale = UIScreen.main.scale
            self.view.bringSubviewToFront(saveButtonView)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("handleBack"), object: nil)
    }
    @objc func injected(){
        self.configureView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureView()
    }
    func configureView(){
        
        if(agreementType == AGREEMENT_TYPES.Sales_Agreement){
            self.agreementTypeLabel.text = "SALE AGREEMENT"
        }
        else{
            self.agreementTypeLabel.text = "ASSIGNMENT AGREEMENT"
        }
        
        if(PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.AGREEMENT_STATUS_TRACKER.rawValue, permissionType: UserRolePermissions.CREATE.rawValue) || PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.AGREEMENT_STATUS_TRACKER.rawValue, permissionType: UserRolePermissions.EDIT.rawValue)){
            self.saveButtonView.isHidden = false
        }
        else{
            self.saveButtonView.isHidden = true
        }
        
        let nib = UINib(nibName: "AgreementDateTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "agreementDateCell")
        self.tableView.tableFooterView = UIView()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.unitNamePathLabel.text = self.unitPath
        self.unitNamePathLabel.textColor = UIColor.hexStringToUIColor(hex: "184c67")
        self.unitNameLabel.text = String(format: "%@ (%@)", selectedUnit!.unitDisplayName!,selectedUnit.description1!)
        self.unitTypeLabel.text = self.selectedUnit.typeName ?? "--"
        let colorDict = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: Int(selectedUnit.status))
        self.unitStatusNameLabel.text = colorDict["statusString"] as? String
        self.unitStatusNameLabel.textColor = colorDict["color"] as? UIColor
    }
    func showDatePicker(textField : UITextField){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "datePicker") as! DatePickerViewController
        vc.shouldSetDateLimit = false
        vc.preferredContentSize = CGSize(width: 250, height: 195)
        vc.selectedFieldTag = textField.tag
        vc.delegate = self
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        
        popOver?.sourceView = textField
        vc.delegate = self
        self.present(navigationContoller, animated: true, completion: nil)
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func save(_ sender: Any) {
        
        HUD.show(.progress, onView: self.view)
        ServerAPIs.updateAgreemenetStatus(forUnit: self.selectedUnit.id!, type: self.agreementType, modifiedAST: self.astTableViewDataSource!, forId: self.astInfo.id,completionHandler: { (responseObject,error) in
                HUD.hide()
            if(responseObject?.status == 1){
                if(self.shouldUpdateUnitStatusToSold){
                    if(self.isFromCRM){
                        self.updateUnitStatusInDatabase(unitStatus: UNIT_STATUS.SOLD.rawValue)
                    }
                    else{
                        self.unitStatusDelegate?.didFinishUnitStatusChange(selectedUnit: self.selectedUnit, selectedIndexPath: self.selectedIndexPathForUnit, unitStatus: UNIT_STATUS.SOLD.rawValue)
                    }
                }
                HUD.flash(.label("Saved Succesfully"), delay: 1.0)
                self.perform(#selector(self.popController), with: nil, afterDelay: 1.0)
            }
            else{
                if(responseObject?.err != nil){
                    HUD.flash(.label(responseObject?.err?.description ?? "Connection timed out"), delay: 1.0)

                }
                else{
                    HUD.flash(.label("Something went wrong. Try again."), delay: 1.0)
                }
            }
        })
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
    @objc func popController(){
        if(self.isFromCRM){
            self.dismiss(animated: true, completion: nil)
        }
        else{
            self.navigationController?.popViewController(animated: true)
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
extension AgreementViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return astTableViewDataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : AgreementDateTableViewCell = tableView.dequeueReusableCell(withIdentifier: "agreementDateCell", for: indexPath) as! AgreementDateTableViewCell
        
        let ast : AST = astTableViewDataSource![indexPath.row]
        
        cell.agreementTypeLabel.text = ast.name
        
        let dates = ast.dates
        if(dates != nil && dates?.count ?? 0 >= 1){
            let agreementDate = RRUtilities.sharedInstance.getDateWithEnglishWord(dateStr: dates![0])
            print(agreementDate)
            cell.dateTextField.text = agreementDate
        }
        else{
            cell.dateTextField.text = ""
        }
        cell.dateTextField.delegate = self
        cell.dateTextField.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(indexPath.row)
        
    }
    

}
extension AgreementViewController : UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // show date picker
        self.showDatePicker(textField: textField)
        print(textField.tag)
        return false
    }
}
extension AgreementViewController : DateSelectedFromPicker{
    
    func didSelectDate(optionType: Date, optionIndex: Int) {
        
        if(optionIndex == -1){
            self.hidePopUp()
            return
        }
        
        let timeStamp = optionType.timeIntervalSince1970
        print(timeStamp)
        
        var selectedAst : AST = self.astTableViewDataSource![optionIndex]
        var datesOfAST = selectedAst.dates
        
        if(datesOfAST == nil){
            datesOfAST = []
        }
        
        let dateString = Formatter.ISO8601.string(from: optionType)   // "2018-01-23T03:06:46.232Z"

        datesOfAST?.removeAll()
        datesOfAST?.append(dateString)
        
        selectedAst.dates = datesOfAST
        self.astTableViewDataSource![optionIndex] = selectedAst
        
        if(optionIndex == self.astTableViewDataSource!.count - 1){
            self.shouldUpdateUnitStatusToSold = true
        }
        
        self.tableView.reloadData()
        self.hidePopUp()

    }
    func hidePopUp(){
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
}
extension AgreementViewController : UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

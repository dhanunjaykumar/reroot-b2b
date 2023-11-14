//
//  ProjectSelectionViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 03/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import DropDown
import Alamofire
import PKHUD

protocol ProjectSelectorDelegate : class {

    func didSelectProject(projectID : String,unitID : String,selectedAction : Int)
    //dateAndTime: datePicker.date
}

class ProjectSelectionViewController: UIViewController,UITextFieldDelegate ,VechicleAndDriverDelegate {
  
    var selctedScheduleCallOption : Int!
    weak var delegate:ProjectSelectorDelegate?

    var statusID : Int? = 0
    var isFromRegistrations = false
    
    var selectedAction = 0
    var selectedDate : Date!
    var selectedProspect : REGISTRATIONS_RESULT!
    
    var projectDetails : ProjectDetails!
    var projectsArray : Array<Project> = []
    
    var projectNamesArray : [String] = []
    var blockNamesArray : [String] = []
    var towerNamesArray : [String] = []
    var unitNamesArray : [String] = []
    
    @IBOutlet var cancelButon: UIButton!
    @IBOutlet var proceedButton: UIButton!
    
    @IBOutlet var towerNameTextField: UITextField!
    @IBOutlet var unitNameTextField: UITextField!

    @IBOutlet var blockNameTextField: UITextField!
    @IBOutlet var projectNameTextField: UITextField!
    
    let blcokSelectionDropDown = DropDown()
    let towerSelectionDropDown = DropDown()
    let unitSelectionDropDown = DropDown()
    
    var selectedProject : Project!
    var selectedProspectDetails : PROSPECT_DETAILS!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        projectNameTextField.delegate = self
        blockNameTextField.delegate = self
        towerNameTextField.delegate = self
        unitNameTextField.delegate = self
        
        definesPresentationContext = true
        
        self.projectsArray = RRUtilities.sharedInstance.model.getAllProjects()
        
        if(self.projectsArray.count == 0){
            HUD.flash(.label("There are no projects!"))
        }
        else{
            for project in self.projectsArray{
                projectNamesArray.append(project.name!)
            }
        }
        projectNameTextField.text = selectedProject.name
        projectNameTextField.isEnabled = false
        
        let urlString = String(format:RRAPI.PROJECT_DETAILS, selectedProject.id!)
        self.getSelectedProjectDetails(urlString: urlString)
        
    }
    func setupBlocksDropDown() {
        blcokSelectionDropDown.anchorView = blockNameTextField
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        blcokSelectionDropDown.bottomOffset = CGPoint(x: 0, y: blockNameTextField.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        blcokSelectionDropDown.dataSource = self.blockNamesArray
        
        // Action triggered on selection
        blcokSelectionDropDown.selectionAction = { [weak self] (index, item) in
//            self?.projectNameTextField.setTitle(item, for: .normal)
            self?.blockNameTextField.text = item
            self?.setupTowersDropDown(selectedBlockName: item)
        }
    }
    func setupTowersDropDown(selectedBlockName : String){
        //setupTowersDropDown
        
        // get towers related to block
        
//        let blocks = projectDetails.blocks
        
        let selectedBlocks = projectDetails.blocks!.filter { ($0.name == selectedBlockName) }
        
        let selectedBlcok : BlockDetails = selectedBlocks[0]
        
        let selctedBlockId = selectedBlcok._id
        
        let filterredTowers = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(selctedBlockId!))! }
        
        self.towerNamesArray.removeAll()
        for tower in filterredTowers{
            self.towerNamesArray.append(tower.name!)
        }
        towerNameTextField.becomeFirstResponder()
        
        towerSelectionDropDown.anchorView = towerNameTextField
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        towerSelectionDropDown.bottomOffset = CGPoint(x: 0, y: towerNameTextField.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        towerSelectionDropDown.dataSource = self.towerNamesArray
        
        // Action triggered on selection
        towerSelectionDropDown.selectionAction = { [weak self] (index, item) in
            //            self?.projectNameTextField.setTitle(item, for: .normal)
            self?.towerNameTextField.text = item
            self?.setupUnitsDropDown(selectedTowerName: item)
        }
        
        towerNameTextField.becomeFirstResponder()
        
    }
    func setupUnitsDropDown(selectedTowerName : String) {
        
        let selectedTowers = projectDetails.towers!.filter { ($0.name == selectedTowerName) }
        
        let selectedTower : TOWERDETAILS = selectedTowers[0]
        
        let selectedTowerId = selectedTower._id

        
        let filterredunits = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(selectedTowerId!))! }
        
        print(filterredunits)
        
        self.unitNamesArray.removeAll()
        
        for tempUnit in filterredunits{
            self.unitNamesArray.append(tempUnit.description!)
        }
        
        
        unitSelectionDropDown.anchorView = unitNameTextField
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        unitSelectionDropDown.bottomOffset = CGPoint(x: 0, y: unitNameTextField.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        unitSelectionDropDown.dataSource = self.unitNamesArray
        
        // Action triggered on selection
        unitSelectionDropDown.selectionAction = { [weak self] (index, item) in
            //            self?.projectNameTextField.setTitle(item, for: .normal)
            self?.unitNameTextField.text = item
//            self?.setupUnitsDropDown(selectedTowerName: item)
        }
        
        unitNameTextField.becomeFirstResponder()
    }
    
    func getSelectedProjectDetails(urlString: String){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.labeledProgress(title: "", subtitle: nil))
        
        Alamofire.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success :
                
                print(response)
                
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                let urlResult = try! JSONDecoder().decode(ProjectDetails.self, from: responseData)
                
                print(urlResult)
                
                self.projectDetails = urlResult

                let blocks = self.projectDetails.blocks
                
                self.blockNamesArray.removeAll()
                
                for tempBlock in blocks!{
                    self.blockNamesArray.append(tempBlock.name!)
                }
                
                self.setupBlocksDropDown()

                
//                self.blocksArray.removeAll()
//                self.currentBlocksArray.removeAll()
//
//                self.refreshControl?.endRefreshing()
//                self.unitRefreshControl?.endRefreshing()
//
//                self.blocksArray = urlResult.blocks
//                self.currentBlocksArray = self.blocksArray // for search bar purpose
//                self.projectDetails = urlResult
//                self.buildDataSourceAsFloorWise()
//                self.makeFloatButtonPopUpDataSource()
//
//                self.mTableView.reloadData()
//                self.reloadCollectionView()
                HUD.hide()
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
            }
        }
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func proceed(_ sender: Any) {
//        blcokSelectionDropDown.show()
        
        let selectedUnitName = unitNameTextField.text
        
        if(selectedUnitName?.count == 0)
        {
            HUD.flash(.label("Please selct Unit to proceed"))
            return
        }else{
            
            let selectedUnits = projectDetails.units!.filter { ($0.description! == selectedUnitName) }
            
            let selectedUnit : UnitDetails = selectedUnits[0]
            
            if(selectedAction == ACTION_TYPE.SITE_VISIT.rawValue){
                //Present drive details from here
                self.showVehicleAndDriverPicker(forActionType: ACTION_TYPE.SITE_VISIT)
            }
            else if(selectedAction == ACTION_TYPE.DISCOUNT_REQUEST.rawValue){
                self.delegate?.didSelectProject(projectID: selectedProject.id!, unitID: selectedUnit._id!,selectedAction: self.selectedAction)
            }
            else{
                self.delegate?.didSelectProject(projectID: selectedProject.id!, unitID: selectedUnit._id!,selectedAction: self.selectedAction)
            }
        }

        
    }
    // MARK:- Textfield delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
//        if ((textField == dateOfBookingTextField) || (textField == saleDeedDateTextField) || (textField == agreementDateTextField) || (textField == possessionFinalDateTextField) || (textField == possessionDatePrelimTextField)) {
////            self.showDatePicker(textField: textField)
//            return false
//        }
        self.view.endEditing(true)
        if(textField == projectNameTextField)
        {
            // show projects
        }
        else if(textField == blockNameTextField){
            blcokSelectionDropDown.show()
        }
        else if(textField == towerNameTextField){
            towerSelectionDropDown.show()
        }
        else if(textField == unitNameTextField){
            unitSelectionDropDown.show()
        }
        
        return true
        
    }
    
    // MARK: - Methods
    func showVehicleAndDriverPicker(forActionType : ACTION_TYPE){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vehicleController = storyboard.instantiateViewController(withIdentifier :"vechiclesController") as! VechicleAndDriverSelectionViewController
        vehicleController.delegate = self
        vehicleController.selectedAction = forActionType.rawValue
        
        vehicleController.selectedDate = self.selectedDate
        vehicleController.selectedProspect = self.selectedProspect
        vehicleController.selectedProject = self.selectedProject
        vehicleController.selectedAction = forActionType.rawValue
        vehicleController.isFromRegistrations = isFromRegistrations
//        vehicleController.prospectDetails = self.selectedProspect
        vehicleController.selectedProjectId = selectedProject.id!
        vehicleController.statusID = self.statusID
        vehicleController.selctedScheduleCallOption = self.selctedScheduleCallOption
//        vehicleController.selctedScheduleCallOption = 
        
        let selectedUnitName = unitNameTextField.text

        let selectedUnits = projectDetails.units!.filter { ($0.description! == selectedUnitName) }
        
        let selectedUnit : UnitDetails = selectedUnits[0]
        
        vehicleController.selectedUnitId = selectedUnit._id

        self.present(vehicleController, animated: true, completion: nil)
        
    }
    func didSelectVehicleAndDriver(driveID: String, vehicleID: String, selectedAction: Int) {
        
        if(selectedAction == ACTION_TYPE.SITE_VISIT.rawValue)
        {
            // submit site visit details to server
            
            let selectedUnits = projectDetails.units!.filter { ($0.description! == unitNameTextField.text!) }
            
            let selectedUnit : UnitDetails = selectedUnits[0]
            
            self.delegate?.didSelectProject(projectID: selectedProject.id!, unitID: selectedUnit._id!, selectedAction: selectedAction)
            
        }
        else{
            
        }
    }
    // MARK: -
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

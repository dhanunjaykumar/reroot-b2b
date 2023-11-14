//
//  ProjectSelectionViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 03/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
//import DropDown
import Alamofire
import PKHUD
import CoreData

protocol ProjectSelectorDelegate : class {

    func didSelectProject(projectID : String,unitID : String,selectedAction : Int, comments:String,scheme : String)
    //dateAndTime: datePicker.date
}

class ProjectSelectionViewController: UIViewController,UITextFieldDelegate ,VechicleAndDriverDelegate {
  
    @IBOutlet weak var commentsVIew: UIView!
    @IBOutlet weak var schemeSelectionView: UIView!
    @IBOutlet weak var heightOfSchemeSelectionView: NSLayoutConstraint!
    @IBOutlet weak var schemeTitleView: UIView!
    @IBOutlet weak var schemeNameLabel: UILabel!
    
    var selectedLabel : String!
    var selctedLabelIndex : Int!
    
    var selectedScheme : Schemes!
    var selectedUnit : Units!
    var selectedUnitID : String!
//    var selectedProjectID : String!
    var selectedBlockID : String!
    var selectedTowerID : String!
    
    var selectedUnitName : String!
    var siteVisitParameters : Dictionary<String,Any> = [:]
    var isFromNotification = false
    var selctedScheduleCallOption : Int!
    weak var delegate:ProjectSelectorDelegate?
    var prospectDetails : REGISTRATIONS_RESULT!

    var statusID : Int? = 0
    var isFromRegistrations = false
    var viewType : VIEW_TYPE!
    var tabId : Int!
    var selectedAction = 0
    var selectedDate : Date!
//    var selectedProspect : REGISTRATIONS_RESULT!
    
    var projectDetails : ProjectDetails!
    var projectsArray : Array<Project> = []
    
    var projectNamesArray : [String] = []
    var blockNamesArray : [Blocks] = []
    var towerNamesArray : [Towers] = []
    var unitNamesArray : [Units] = []
    
    var keyboardHeight: CGFloat!
    
    @IBOutlet var cancelButon: UIButton!
    @IBOutlet var proceedButton: UIButton!
    @IBOutlet var commentTextView: KMPlaceholderTextView!
    
    @IBOutlet var towerNameTextField: UITextField!
    @IBOutlet var unitNameTextField: UITextField!

    @IBOutlet var blockNameTextField: UITextField!
    @IBOutlet var projectNameTextField: UITextField!
    
    let blcokSelectionDropDown = DropDown()
    let towerSelectionDropDown = DropDown()
    let unitSelectionDropDown = DropDown()
    let projectSelectionDropDown = DropDown()

    
    var selectedProject : Project!
//    var selectedProspectDetails : PROSPECT_DETAILS!
    
    // MARK:- Controller
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    @objc
    func keyboardWillAppear(notification: NSNotification?) {
        
        guard let keyboardFrame = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }
        
            projectSelectionDropDown.direction = .any
            projectSelectionDropDown.bottomOffset = CGPoint(x: 0, y: keyboardHeight)
        
            blcokSelectionDropDown.direction = .any
            blcokSelectionDropDown.bottomOffset = CGPoint(x: 0, y: keyboardHeight)
        
            unitSelectionDropDown.direction = .any
            unitSelectionDropDown.bottomOffset = CGPoint(x: 0, y: keyboardHeight)
        
            towerSelectionDropDown.direction = .any
            towerSelectionDropDown.bottomOffset = CGPoint(x: 0, y: keyboardHeight + 150)
        
        
//        tableViewBottomLayoutConstraint.constant = keyboardHeight
    }
    
    @objc
    func keyboardWillDisappear(notification: NSNotification?) {
        
//        tableViewBottomLayoutConstraint.constant = 0.0
        blcokSelectionDropDown.bottomOffset = CGPoint(x: 0, y: blockNameTextField.bounds.height)
        
        towerSelectionDropDown.bottomOffset = CGPoint(x: 0, y: towerNameTextField.bounds.height)
        unitSelectionDropDown.bottomOffset = CGPoint(x: 0, y: unitNameTextField.bounds.height)


    }
    @objc func showBlockSelectionView(){
        self.blcokSelectionDropDown.show()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        print(selectedProspect)
//        print(prospectDetails)
        
        
        commentsVIew.layer.cornerRadius = 8.0
        commentsVIew.layer.borderWidth = 0.2
        commentsVIew.layer.borderColor = UIColor.lightGray.cgColor

        schemeTitleView.layer.cornerRadius = 8.0
        schemeTitleView.layer.borderWidth = 0.2
        schemeTitleView.layer.borderColor = UIColor.lightGray.cgColor
        schemeNameLabel.text = "None"
        
        let tapSchemeGuesture = UITapGestureRecognizer.init(target: self, action: #selector(showSchemesForSelection))
        schemeTitleView.addGestureRecognizer(tapSchemeGuesture)

        let tapGuesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyBoard))
        self.view.addGestureRecognizer(tapGuesture)

        projectNameTextField.delegate = self
        blockNameTextField.delegate = self
        towerNameTextField.delegate = self
        unitNameTextField.delegate = self
        
        blcokSelectionDropDown.showingBlocks = true
        towerSelectionDropDown.showingTowers = true
        unitSelectionDropDown.showingUnits = true
        projectSelectionDropDown.showingProjects = true
        
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
//        projectNameTextField.text = selectedProject?.name
//        if(selectedProject != nil){
//            projectNameTextField.isEnabled = false
//        }
//        else{
//            projectNameTextField.isEnabled = true
//        }
        self.setupProejctsDropDown()

        if(prospectDetails != nil && prospectDetails.project != nil){

            let project = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: (prospectDetails.project?._id)!)

            if(project != nil){ //(project != nil)
                if let unit =  prospectDetails.unit{
                    let tower = RRUtilities.sharedInstance.model.getSelectedTowerDetailsByTowerId(towerId: (unit.tower)!)
                    let block = RRUtilities.sharedInstance.model.getSelectedBlockDetailsByBlockId(blockID: (unit.block)!)
                    let unit = RRUtilities.sharedInstance.model.getUnitDetailsByUnitID(unitId: (unit._id)!)
                    if(unit != nil){
                        
                        self.selectedBlockID = unit!.block
                        self.selectedTowerID = unit!.tower
                        self.selectedUnitID = unit!.id
                        self.selectedUnit = unit
                        (unit!.schemes?.count ?? 0 > 0) ? self.shouldShowSchemeSelectionView(shouldShow: true) : self.shouldShowSchemeSelectionView(shouldShow: false)
                        blockNameTextField.text = block?.name
                        towerNameTextField.text = tower?.name
                        unitNameTextField.text = unit!.description1
//                        RRUtilities.sharedInstance.model.getAllUnitsNamesOfProject(projectID: project!.id!, unitName: unit!.description1!)
                        let projectID = prospectDetails.project?._id

                        self.blockNamesArray = RRUtilities.sharedInstance.model.getSelectedProjectBlocksByProjectId(projectId: projectID!)!
                        self.unitNamesArray = RRUtilities.sharedInstance.model.getSelectedProjectUnitsByProjectId(projectId: projectID!)!
                        self.towerNamesArray = RRUtilities.sharedInstance.model.getSelectedProjettTowersByProjectId(projectId: projectID!)!

                        self.setupBlocksDropDown()
                        
                        self.perform(#selector(showBlockSelectionView), with: nil, afterDelay: 0.6)

                    }
                    else{
                        let projectID = prospectDetails.project?._id
                        let urlString = String(format:RRAPI.PROJECT_DETAILS, selectedProject.id!)
                        self.getSelectedProjectDetails(urlString: urlString)
                    }
                 }
                else{
                    
                    self.blockNamesArray = RRUtilities.sharedInstance.model.getSelectedProjectBlocksByProjectId(projectId: project!.id!)!
                    if(self.blockNamesArray.count == 0){
                        let urlString = String(format:RRAPI.PROJECT_DETAILS, selectedProject.id!)
                        self.getSelectedProjectDetails(urlString: urlString)
                    }
                    else{
                        self.setupBlocksDropDown()
                        self.perform(#selector(showBlockSelectionView), with: nil, afterDelay: 0.6)
                        
//                        self.blockNameTextField.becomeFirstResponder()
//                        blcokSelectionDropDown.bottomOffset = CGPoint(x: 0, y: blockNameTextField.bounds.height)
                    }
                    
                }
                projectNameTextField.text = project?.name
            }
            else{
                 // project doesn't exist in DB
                if(selectedProject == nil){
                    return
                }
                let urlString = String(format:RRAPI.PROJECT_DETAILS, selectedProject?.id ?? "")

                ///check in DB , if not then call ***

                self.getSelectedProjectDetails(urlString: urlString)

            }
        }
        else{
            print("no prospect")
//            self.projectNameTextField.becomeFirstResponder()
            self.projectSelectionDropDown.show()
            self.view.endEditing(true)
        }
        
        self.shouldShowSchemeSelectionView(shouldShow: false)
        
//        let urlString = String(format:RRAPI.PROJECT_DETAILS, selectedProject.id!)
//
//        ///check in DB , if not then call ***
//
//        self.getSelectedProjectDetails(urlString: urlString)

        
        // check project exist or not ***
//
//        if(prospectDetails.unit != nil){
//            //fetch all names and update them
//
//        }
//        else{
//            let urlString = String(format:RRAPI.PROJECT_DETAILS, selectedProject.id!)
//
//            ///check in DB , if not then call ***
//
//            self.getSelectedProjectDetails(urlString: urlString)
//        }
        
        
//        DropDown.startListeningToKeyboard()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    @objc func hideKeyBoard(){
        self.view.endEditing(true)
    }
    func shouldShowSchemeSelectionView(shouldShow : Bool){
        
        if(shouldShow){
            self.heightOfSchemeSelectionView.constant = 90
            self.schemeSelectionView.isHidden = false
            schemeTitleView.isHidden = false
        }
        else{
            self.heightOfSchemeSelectionView.constant = 0
            self.schemeSelectionView.isHidden = true
            schemeTitleView.isHidden = true
        }
    }
    @objc func showSchemesForSelection(){
        
        let schemes = self.fetchSchemesForSelectdUnit()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let schemesPopOver = (storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController)
        schemesPopOver.dataSourceType = .SCHEMES
        schemesPopOver.preferredContentSize = CGSize(width:  300, height: (schemes.count - 1) * 44)
        
        if(schemes.count == 0){
            schemesPopOver.preferredContentSize = CGSize(width:  300, height:1)
        }
        let navigationContoller = UINavigationController(rootViewController: schemesPopOver)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        
        schemesPopOver.schemesDataSource = schemes
        
        popOver?.sourceView = schemeNameLabel
        
        schemesPopOver.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    func fetchSchemesForSelectdUnit()->[Schemes]{
        
        let entity = NSEntityDescription.entity(forEntityName: "Schemes", in: RRUtilities.sharedInstance.model.managedObjectContext)
        let noneScheme = Schemes.init(entity: entity!, insertInto: nil)
        noneScheme.name  = "None"
        noneScheme.id = "None"
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Schemes")
        
        do {
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let sortDescriptors = [sortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            
            let fetchedSchemes = try RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest) as! [Schemes]
            
            var schemesForUnit : [Schemes] = []
            schemesForUnit.append(noneScheme)
            
            if(fetchedSchemes.count > 0){
                let definedSchemes =  self.selectedUnit!.schemes!
                for eachSchemeId in definedSchemes{
                    let filteredSchmes = fetchedSchemes.filter({ $0.id == eachSchemeId })
                    if(filteredSchmes.count == 1){
                        schemesForUnit.append(filteredSchmes[0])
                    }
                }
            }
            
            return schemesForUnit
            
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
            return []
        }
        
    }
    func setupProejctsDropDown(){
        projectSelectionDropDown.anchorView = projectNameTextField
        projectSelectionDropDown.bottomOffset = CGPoint(x: 0, y: projectNameTextField.bounds.height)
        projectSelectionDropDown.dataSource = self.projectsArray
        
        if(self.projectsArray.count == 0){
            HUD.flash(.label("No Projects Available"), delay: 1.5)
            return
        }
        
        projectSelectionDropDown.selectionAction = { [weak self] (index, item) in
            //            self?.projectNameTextField.setTitle(item, for: .normal)
            let project = item as! Project
            self?.projectNameTextField.text = project.name
            self?.selectedProject = project
            self?.blockNamesArray = RRUtilities.sharedInstance.model.getSelectedProjectBlocksByProjectId(projectId: project.id!)!
            if(self?.blockNamesArray.count == 0){
                let urlString = String(format:RRAPI.PROJECT_DETAILS, self?.selectedProject.id! ?? "")
                self?.getSelectedProjectDetails(urlString: urlString)
            }
            else{
                self?.setupBlocksDropDown()
            }
            self?.view.endEditing(true)
            if(self?.prospectDetails.project?._id == nil){
                self?.blcokSelectionDropDown.show()
            }
            
//            let block = item as! Blocks
//            self?.blockNameTextField.text = block.name
//            self?.selectedBlockID = block.id
//            self?.setupTowersDropDown(selectedBlockName: block.id!)
//            self?.towerSelectionDropDown.show()
        }


    }
    func setupBlocksDropDown() {
        blcokSelectionDropDown.anchorView = blockNameTextField
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        blcokSelectionDropDown.bottomOffset = CGPoint(x: 0, y: blockNameTextField.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        blcokSelectionDropDown.dataSource = self.blockNamesArray
        
        if(self.blockNamesArray.count == 0){
            HUD.flash(.label("No Blocks Available"), delay: 1.5)
            return
        }
        // Action triggered on selection
        blcokSelectionDropDown.selectionAction = { [weak self] (index, item) in
//            self?.projectNameTextField.setTitle(item, for: .normal)
            self?.view.endEditing(true)
            let block = item as! Blocks
            self?.blockNameTextField.text = block.name
            self?.selectedBlockID = block.id
            self?.setupTowersDropDown(selectedBlockName: block.id!)
            self?.towerSelectionDropDown.show()
        }
    } //
    func setupTowersDropDown(selectedBlockName : String){
        //setupTowersDropDown
        
        // get towers related to block
        
//        let blocks = projectDetails.blocks
        
//        let selectedBlocks = projectDetails.blocks!.filter { ($0.name == selectedBlockName) }
//
//        let selectedBlcok : BlockDetails = selectedBlocks[0]
//
//        let selctedBlockId = selectedBlcok._id
//
//        let filterredTowers = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(selctedBlockId!))! }
//
//        self.towerNamesArray.removeAll()
//        let projectID = self.selectedProject.id ?? self.prospectDetails.project?._id
        self.towerNamesArray = RRUtilities.sharedInstance.model.getTowersByBlockId(blockID: selectedBlockName)!
        
//        for tower in filterredTowers{
//            self.towerNamesArray.append(tower.name!)
//        }
//        towerNameTextField.becomeFirstResponder()
        
        if(self.towerNamesArray.count == 0){
            HUD.flash(.label("No Towers Available"), delay: 1.5)
            return
        }
        
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
            let tower = item as! Towers
            self?.view.endEditing(true)
            self?.towerNameTextField.text = tower.name
            self?.selectedTowerID = tower.id
            self?.setupUnitsDropDown(selectedTowerName: tower.id!)
            self?.unitSelectionDropDown.show()
        }
        
//        towerNameTextField.becomeFirstResponder()
        
    }
    func setupUnitsDropDown(selectedTowerName : String) {
        
        self.unitNamesArray.removeAll()
        self.unitNamesArray = RRUtilities.sharedInstance.model.getUnitsByTowerId(towerID: selectedTowerName)!
        
        if(self.unitNamesArray.count == 0){
            HUD.flash(.label("No Units Available"), delay: 1.0)
            return
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
            let unit = item as! Units
            self?.unitNameTextField.text = String(format: "%d (%@)", unit.unitIndex,unit.description1!)
//            self?.selectedUnitName = filterredunits[index].description
            self?.selectedUnitID = unit.id
            self?.selectedUnit = unit
            (unit.schemes?.count ?? 0 > 0) ? self?.shouldShowSchemeSelectionView(shouldShow: true) : self?.shouldShowSchemeSelectionView(shouldShow: false)
//            self?.setupUnitsDropDown(selectedTowerName: item)
        }
        
//        unitNameTextField.becomeFirstResponder()
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
//        HUD.show(.labeledProgress(title: "", subtitle: nil))
        
//        HUD.show(.progress)
        HUD.show(.progress, onView: self.view)

        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success :
                
//                print(response)
                
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                do{
                    let urlResult = try JSONDecoder().decode(ProjectDetails.self, from: responseData)
                    
                    //                print(urlResult)
                    
                    //                self.projectDetails = urlResult
                    //
                    //                let blocks = self.projectDetails.blocks
                    if(urlResult.status != 1){
                        HUD.flash(.label("Couldn't fetch project details"), delay: 1.0)
                        return
                    }
                    if(urlResult.blocks?.isEmpty == false){
                        RRUtilities.sharedInstance.model.writeBlocksToDB(projectDetails: urlResult, projectID: self.selectedProject.id!)
                    }
                    if(urlResult.towers?.isEmpty == false){
                        RRUtilities.sharedInstance.model.writeTowersToDB(projectDetails: urlResult, projectID: self.selectedProject.id!)
                    }
                    if(urlResult.units?.isEmpty == false){
                        RRUtilities.sharedInstance.model.writeUnitsToDB(projectDetails: urlResult, projectID: self.selectedProject.id!)
                    }
                    
                    sleep(1)
                    
                    self.blockNamesArray.removeAll()
                    let projectID = self.selectedProject?.id ?? self.prospectDetails.project?._id
                    
                    self.blockNamesArray = RRUtilities.sharedInstance.model.getSelectedProjectBlocksByProjectId(projectId: projectID!)!
                    
                    //                for tempBlock in blocks!{
                    //                    self.blockNamesArray.append(tempBlock.name!)
                    //                }
                    
                    self.setupBlocksDropDown()
                    
                    if let projectId = self.prospectDetails.project?._id{
                        
                    }
                    
                    if let unit = self.prospectDetails.unit{
                        let tower = RRUtilities.sharedInstance.model.getSelectedTowerDetailsByTowerId(towerId: (unit.tower)!)
                        let block = RRUtilities.sharedInstance.model.getSelectedBlockDetailsByBlockId(blockID: (unit.block)!)
                        let unit = RRUtilities.sharedInstance.model.getUnitDetailsByUnitID(unitId: (unit._id)!)
                        
                        let projectID = self.prospectDetails.project?._id
                        
                        self.blockNamesArray = RRUtilities.sharedInstance.model.getSelectedProjectBlocksByProjectId(projectId: projectID!)!
                        
                        if(unit != nil){
                            self.selectedBlockID = unit!.block
                            self.selectedTowerID = unit!.tower
                            self.selectedUnitID = unit!.id
                            self.selectedUnit = unit
                            (unit!.schemes?.count ?? 0 > 0) ? self.shouldShowSchemeSelectionView(shouldShow: true) : self.shouldShowSchemeSelectionView(shouldShow: false)
                            self.blockNameTextField.text = block?.name
                            self.towerNameTextField.text = tower?.name
                            self.unitNameTextField.text = unit!.description1
                            self.setupBlocksDropDown()
                            self.blcokSelectionDropDown.hide()
                        }
                        else{
                            self.setupBlocksDropDown()
                            self.perform(#selector(self.showBlockSelectionView), with: nil, afterDelay: 0.6)
                        }
                        
                    }
                    else{
                        self.view.endEditing(true)
                        self.blcokSelectionDropDown.show()
                        self.blcokSelectionDropDown.bottomOffset = CGPoint(x: 0, y: self.blockNameTextField.bounds.height)
                    }
                    
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
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
        
        let selectedUnitName = unitNameTextField.text
        
//        if(selectedUnitName?.count == 0)
//        {
//            HUD.flash(.label("Please selct Unit to proceed"))
//            return
//        }else{
        
//            let selectedUnits = projectDetails.units!.filter { ($0.description! == self.selectedUnitName) }
//
//            let selectedUnit : UnitDetails = selectedUnits[0]
            
            if(selectedAction == ACTION_TYPE.SITE_VISIT.rawValue){
                //Present drive details from here
                self.showVehicleAndDriverPicker(forActionType: ACTION_TYPE.SITE_VISIT, comments: commentTextView.text)
            }
            else if(selectedAction == ACTION_TYPE.DISCOUNT_REQUEST.rawValue){
                self.delegate?.didSelectProject(projectID: selectedProject.id ?? "", unitID: selectedUnitID ?? "",selectedAction: self.selectedAction, comments: commentTextView.text,scheme: self.selectedScheme?.id ?? "")
            }
            else{
                self.delegate?.didSelectProject(projectID: selectedProject.id ?? "", unitID: selectedUnitID ?? "",selectedAction: self.selectedAction, comments: commentTextView.text,scheme: self.selectedScheme?.id ?? "")
            }
//        }
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
            self.projectSelectionDropDown.show()
            projectSelectionDropDown.bottomOffset = CGPoint(x: 0, y: projectNameTextField.bounds.height)

        }
        else if(textField == blockNameTextField){
            blcokSelectionDropDown.show()
            blcokSelectionDropDown.bottomOffset = CGPoint(x: 0, y: blockNameTextField.bounds.height)
        }
        else if(textField == towerNameTextField){
            towerSelectionDropDown.show()
            towerSelectionDropDown.bottomOffset = CGPoint(x: 0, y: towerNameTextField.bounds.height)
        }
        else if(textField == unitNameTextField){
            unitSelectionDropDown.show()
            unitSelectionDropDown.bottomOffset = CGPoint(x: 0, y: unitNameTextField.bounds.height)
        }
        self.view.endEditing(true)
        return true
        
    }
    
    // MARK: - Methods
    func showVehicleAndDriverPicker(forActionType : ACTION_TYPE,comments: String){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vehicleController = storyboard.instantiateViewController(withIdentifier :"vechiclesController") as! VechicleAndDriverSelectionViewController
        vehicleController.delegate = self
        vehicleController.selectedAction = forActionType.rawValue
        vehicleController.viewType = self.viewType
        vehicleController.comments = comments
        vehicleController.selectedDate = self.selectedDate
        if(self.prospectDetails != nil){
            vehicleController.selectedProspect = self.prospectDetails
        }
//        vehicleController.prospectDetails = self.prospectDetails
        
        if(prospectDetails != nil){
            vehicleController.selectedProspect = prospectDetails
        }
        vehicleController.selectedProject = self.selectedProject
        vehicleController.selectedAction = forActionType.rawValue
        vehicleController.isFromRegistrations = isFromRegistrations
//        vehicleController.prospectDetails = self.selectedProspect
        vehicleController.selectedProjectId = selectedProject.id!
        vehicleController.statusID = self.statusID
        vehicleController.comment = commentTextView.text
        vehicleController.selctedScheduleCallOption = self.selctedScheduleCallOption
//        vehicleController.selctedScheduleCallOption = 
        
//        let selectedUnitName = unitNameTextField.text

//        let selectedUnits = projectDetails.units!.filter { ($0.description! == self.selectedUnitName) }
//
//        let selectedUnit : UnitDetails = selectedUnits[0]
        
        vehicleController.selectedUnitId = selectedUnitID //selectedUnit._id
        vehicleController.selectedSchemeID = self.selectedScheme?.id ?? ""

        self.present(vehicleController, animated: true, completion: nil)
        
    }
    func didSelectVehicleAndDriver(driveID: String?, vehicleID: String?, selectedAction: Int) {
        
        if(selectedAction == ACTION_TYPE.SITE_VISIT.rawValue)
        {
            // submit site visit details to server
            
//            let selectedUnits = projectDetails.units!.filter { ($0.description! == self.selectedUnitName) }
//
//            let selectedUnit : UnitDetails = selectedUnits[0]
            
            self.delegate?.didSelectProject(projectID: selectedProject.id ?? "", unitID: selectedUnitID ?? "", selectedAction: selectedAction, comments: commentTextView.text,scheme: self.selectedScheme?.id ?? "")
            
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

extension ProjectSelectionViewController : UIPopoverPresentationControllerDelegate,HidePopUp {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func didSelectScheme(selectedScheme: Schemes) {
        
        if(!RRUtilities.sharedInstance.getNetworkStatus()){
            HUD.flash(.label("Couldn't connect to internet"))
            return
        }
        
        self.schemeNameLabel.text = selectedScheme.name
        self.selectedScheme = selectedScheme
        
//        HUD.show(.progress, onView: self.view)
        
//        ServerAPIs.getUnitPreviewPrice(regInfo: "", unitID: selectedUnit.id!, scheme: selectedScheme.id ,completionHandler: {(bookingFormResult, error) in
//            if(bookingFormResult?.status == 1){
//                self.bookingFormOutput = bookingFormResult
//                self.bookingFormDetails = bookingFormResult?.booking
//                self.buildUnitDetailsView()
//            }
//            else{
//                self.buildUnitDetailsView()
//            }
//            HUD.hide()
//        })
        
        let tmpController :UIViewController! = self.presentedViewController;
        if(tmpController != nil){
            self.dismiss(animated: false, completion: {()->Void in
                tmpController.dismiss(animated: false, completion: nil);
            });
        }
    }
    
}

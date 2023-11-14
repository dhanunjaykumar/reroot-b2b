//
//  ProspectDatePickerViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 02/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import PKHUD
import FloatingPanel

protocol DateSelectedFromTimePicker: class {

    func didSelectDateAndTime(dateAndTime : Date , selectedAction : Int,comment : String) //action is schedule call etc
    func didSelectDateAndTimeAndProjectIds(dateAndTime : Date , selectedAction : Int,projectId : String,comment : String)
}


class ProspectDatePickerViewController: UIViewController,ProjectSelectorDelegate,RegistrationSearchDelegate {
    
    
    @IBOutlet var commentTextView: KMPlaceholderTextView!
    var selectedProjectIds : [String]!
    var selectedLabel : String!
    var selctedLabelIndex : Int!
    var emailId : String!
    var selctedScheduleCallOption : Int!
    var isFromNotification = false
    var prevSelectedStatus : Int = 0
    var selectedDate : Date!
    var isFromRegistrations = false
    var statusID : Int? = 0
    var viewType : VIEW_TYPE!
    var tabId : Int! // viewType or tabId both are same
    @IBOutlet var datePicker: UIDatePicker!
    var selectedAction = 0
    var selectedProspect : REGISTRATIONS_RESULT!
    
    weak var delegate:DateSelectedFromTimePicker?
    
    @objc func datePickerValueChanged(datePicker: UIDatePicker) {
        
//        if datePicker.date.minute % 15 != 0 {
//            if datePicker.date.minute > 45 {
//                datePicker.date += 60*60
//            }
//            datePicker.date = datePicker.date.nextHourQuarter
//        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.minimumDate = Date().addingTimeInterval(30*60)
        print(selectedProspect)
        
//        definesPresentationContext = true
    }
    
    @IBAction func dateSelected(_ sender: Any) {
        
        // submit status to server with date
//        self.delegate?.didSelectDateAndTime(dateAndTime: datePicker.date)
        
        if(datePicker.date < Date().addingTimeInterval(30*60)){
            HUD.flash(.label("Selected time should be at least 30 minutes post the current time"), delay: 1.0)
        }
        
        if(selectedAction > 0){
            if(selectedAction == ACTION_TYPE.SITE_VISIT.rawValue){
                if(statusID == nil){
                    //from registrations
                    self.delegate?.didSelectDateAndTime(dateAndTime: datePicker.date, selectedAction: selectedAction, comment: commentTextView.text)
                    return
                }
              //Show project details from here **
                if(statusID == 1){
                    self.showProjectSelectionView(forActionType: ACTION_TYPE.SITE_VISIT)
                }
                else if(statusID == 2){
                    //show drivers view
                    self.showVehicleAndDriverPicker(forActionType: ACTION_TYPE.SITE_VISIT)
                }
                else if(statusID == 3){
                    self.showProjectSelectionView(forActionType: ACTION_TYPE.SITE_VISIT)
                }
                else if(statusID == 5){
                    self.showProjectSelectionView(forActionType: ACTION_TYPE.SITE_VISIT)
                }
                else if(statusID == 4){
                    self.showProjectSelectionView(forActionType: ACTION_TYPE.SITE_VISIT)
                }
                else if(statusID == 6){
                    self.showProjectSelectionView(forActionType: ACTION_TYPE.SITE_VISIT)
                }
            }
            else{
                if(selectedProspect?.project == nil){ //statusID == 6 &&
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let registerController = storyboard.instantiateViewController(withIdentifier :"registratoinProSearch") as! RegistrationSearchViewController
                    registerController.delegate = self
//                    registerController.modalPresentationStyle = .overCurrentContext
//                    registerController.modalTransitionStyle = .crossDissolve
                    registerController.shouldShowRadioButton = true
                    let fpc = FloatingPanelController()
                    fpc.surfaceView.cornerRadius = 6.0
                    fpc.surfaceView.shadowHidden = false
                    fpc.set(contentViewController: registerController)
                    fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
                    fpc.track(scrollView: registerController.tableView)
                    self.present(fpc, animated: true, completion: nil)
                    return
                }
                self.delegate?.didSelectDateAndTime(dateAndTime: datePicker.date, selectedAction: selectedAction, comment: commentTextView.text)
            }
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    func didSelectInterestedProjects(projectNames: [String], projectIds: [String]) {
        
        self.delegate?.didSelectDateAndTimeAndProjectIds(dateAndTime: datePicker.date, selectedAction: selectedAction, projectId: projectIds[0], comment: commentTextView.text)
    }

    func showProjectSelectionView(forActionType : ACTION_TYPE){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let projectSeletionController = storyboard.instantiateViewController(withIdentifier :"projectSelection") as! ProjectSelectionViewController
//        projectSeletionController.delegate = self
        //selectedProject
        
        if(selectedProspect.project != nil){
            let projectID = selectedProspect.project?._id
            let tempProjct = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: projectID!)
            print(tempProjct)
            projectSeletionController.selectedProject = tempProjct
        }
        projectSeletionController.selectedDate = datePicker.date
        print(projectSeletionController.selectedDate)
        print(datePicker.date)

        projectSeletionController.viewType = self.viewType
        projectSeletionController.tabId = self.tabId

//        projectSeletionController.selectedProspect = selectedProspect
        projectSeletionController.prospectDetails = selectedProspect
        projectSeletionController.selectedAction = forActionType.rawValue
        projectSeletionController.isFromRegistrations = self.isFromRegistrations
        projectSeletionController.statusID = self.statusID
        projectSeletionController.selctedScheduleCallOption = self.selctedScheduleCallOption
        projectSeletionController.modalPresentationStyle = .overCurrentContext
        self.present(projectSeletionController, animated: true, completion: nil)
        
    }
    func showVehicleAndDriverPicker(forActionType : ACTION_TYPE){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vehicleController = storyboard.instantiateViewController(withIdentifier :"vechiclesController") as! VechicleAndDriverSelectionViewController
//        vehicleController.delegate = self
        vehicleController.selectedAction = forActionType.rawValue
        
        vehicleController.selectedDate = datePicker.date
        vehicleController.viewType = self.viewType
        vehicleController.selectedProspect = self.selectedProspect
        vehicleController.emailId  = self.emailId
//        vehicleController.selectedProject = self.selectedProject
        vehicleController.selectedAction = forActionType.rawValue
        vehicleController.isFromRegistrations = isFromRegistrations
        //        vehicleController.prospectDetails = self.selectedProspect
//        vehicleController.selectedProjectId = selectedProject.id!
        vehicleController.statusID = self.statusID
        vehicleController.comment = commentTextView.text
        
        vehicleController.viewType = self.viewType
        vehicleController.tabId = self.tabId

        
//        let selectedUnitName = unitNameTextField.text
//
//        let selectedUnits = projectDetails.units!.filter { ($0.description! == selectedUnitName) }
//
//        let selectedUnit : UnitDetails = selectedUnits[0]
        
//        vehicleController.selectedUnitId = selectedUnit._id
        
        self.present(vehicleController, animated: true, completion: nil)
        
    }
    func didSelectProject(projectID: String, unitID: String, selectedAction: Int, comments : String,scheme : String)
    {
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_ON_ACTION), object: nil)
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func hide(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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

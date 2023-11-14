//
//  ProspectDatePickerViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 02/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

protocol DateSelectedFromTimePicker: class {

    func didSelectDateAndTime(dateAndTime : Date , selectedAction : Int) //action is schedule call etc
}


class ProspectDatePickerViewController: UIViewController,ProjectSelectorDelegate {
    
    var selctedScheduleCallOption : Int!
    var prevSelectedStatus : Int = 0
    var selectedDate : Date!
    var isFromRegistrations = false
    var statusID : Int? = 0
    @IBOutlet var datePicker: UIDatePicker!
    var selectedAction = 0
    var selectedProspect : REGISTRATIONS_RESULT!
    
    weak var delegate:DateSelectedFromTimePicker?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        datePicker.minimumDate = Date()
        definesPresentationContext = true

    }
    
    @IBAction func dateSelected(_ sender: Any) {
        
        // submit status to server with date
//        self.delegate?.didSelectDateAndTime(dateAndTime: datePicker.date)
        
        if(selectedAction > 0){
            if(selectedAction == ACTION_TYPE.SITE_VISIT.rawValue){
              //Show project details from here **
                if(statusID == 1){
                    self.showProjectSelectionView(forActionType: ACTION_TYPE.SITE_VISIT)
                }
                else if(statusID == 2){
                    //show drivers view
                    self.showVehicleAndDriverPicker(forActionType: ACTION_TYPE.SITE_VISIT)
                }
            }
            else{
                self.delegate?.didSelectDateAndTime(dateAndTime: datePicker.date, selectedAction: selectedAction)
            }
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    func showProjectSelectionView(forActionType : ACTION_TYPE){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let projectSeletionController = storyboard.instantiateViewController(withIdentifier :"projectSelection") as! ProjectSelectionViewController
//        projectSeletionController.delegate = self
        //selectedProject
        let projectID = selectedProspect.project!._id
        let tempProjct = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: projectID!)
        print(tempProjct)
        projectSeletionController.selectedDate = datePicker.date
        projectSeletionController.selectedProspect = selectedProspect
        projectSeletionController.selectedProject = tempProjct
        projectSeletionController.selectedAction = forActionType.rawValue
        projectSeletionController.isFromRegistrations = self.isFromRegistrations
        projectSeletionController.statusID = self.statusID
        projectSeletionController.selctedScheduleCallOption = self.selctedScheduleCallOption
        self.present(projectSeletionController, animated: true, completion: nil)
        
    }
    func showVehicleAndDriverPicker(forActionType : ACTION_TYPE){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vehicleController = storyboard.instantiateViewController(withIdentifier :"vechiclesController") as! VechicleAndDriverSelectionViewController
//        vehicleController.delegate = self
        vehicleController.selectedAction = forActionType.rawValue
        
        vehicleController.selectedDate = datePicker.date
        vehicleController.selectedProspect = self.selectedProspect
//        vehicleController.selectedProject = self.selectedProject
        vehicleController.selectedAction = forActionType.rawValue
        vehicleController.isFromRegistrations = isFromRegistrations
        //        vehicleController.prospectDetails = self.selectedProspect
//        vehicleController.selectedProjectId = selectedProject.id!
        vehicleController.statusID = self.statusID
        
//        let selectedUnitName = unitNameTextField.text
//
//        let selectedUnits = projectDetails.units!.filter { ($0.description! == selectedUnitName) }
//
//        let selectedUnit : UnitDetails = selectedUnits[0]
        
//        vehicleController.selectedUnitId = selectedUnit._id
        
        self.present(vehicleController, animated: true, completion: nil)
        
    }
    func didSelectProject(projectID: String, unitID: String, selectedAction: Int) {
        
        //
        
        
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

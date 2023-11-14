//
//  OutstandingsViewController.swift
//  REroot
//
//  Created by Dhanunjay Kumar Mocharla on 15/11/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import PKHUD

struct OutStanding {
    var prId : String
    var blId : String
    var twId : String
    var uId : String
    var range : String
}

class OutstandingsViewController: UIViewController {

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var blockNameTextField: UITextField!
    @IBOutlet weak var towerNameTextField: UITextField!
    @IBOutlet weak var unitNameTextField: UITextField!
    @IBOutlet weak var rangeTextField: UITextField!
    var outStandingParams = OutStanding(prId: "", blId: "", twId: "", uId: "", range: "")
    var rangesArray : [String] = []
    
    
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
        
        //        titleView.layer.shadowPath = UIBezierPath(roundedRect: titleView.bounds, cornerRadius: 10).cgPath
        titleView.layer.shouldRasterize = true
        titleView.layer.rasterizationScale = UIScreen.main.scale
        self.view.bringSubviewToFront(titleView)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let imageView = UIImageView.init(frame: CGRect(x: 6, y: 0, width: 24, height: 64))
        let emailImage = UIView.init(frame: CGRect(x: 0, y: 0, width: 40, height: 64))
        let guestureOne = UITapGestureRecognizer.init(target: self, action: #selector(showProjects))
        emailImage.addGestureRecognizer(guestureOne)
        emailImage.addSubview(imageView)
        imageView.image = UIImage.init(named: "prefill_icon")
        emailImage.isUserInteractionEnabled = true
        imageView.contentMode = .center
        projectNameTextField.rightView = emailImage
        projectNameTextField.rightViewMode = .always
        
        let imageView1 = UIImageView.init(frame: CGRect(x: 6, y: 0, width: 24, height: 64))
        let blockImageView = UIView.init(frame: CGRect(x: 0, y: 0, width: 40, height: 64))
        let guestureTwo = UITapGestureRecognizer.init(target: self, action: #selector(showBlocks))
        blockImageView.addGestureRecognizer(guestureTwo)
        blockImageView.addSubview(imageView1)
        imageView1.image = UIImage.init(named: "prefill_icon")
        imageView1.contentMode = .center
        blockNameTextField.rightView = blockImageView
        blockNameTextField.rightViewMode = .always

        let imageView2 = UIImageView.init(frame: CGRect(x: 6, y: 0, width: 24, height: 64))
        let towerImageView = UIView.init(frame: CGRect(x: 0, y: 0, width: 40, height: 64))
        let guestureThree = UITapGestureRecognizer.init(target: self, action: #selector(showTowers))
        towerImageView.addGestureRecognizer(guestureThree)
        towerImageView.addSubview(imageView2)
        imageView2.image = UIImage.init(named: "prefill_icon")
        imageView2.contentMode = .center
        towerNameTextField.rightView = towerImageView
        towerNameTextField.rightViewMode = .always

        let imageView3 = UIImageView.init(frame: CGRect(x: 6, y: 0, width: 24, height: 64))
        let unitImageView = UIView.init(frame: CGRect(x: 0, y: 0, width: 40, height: 64))
        let guestureFour = UITapGestureRecognizer.init(target: self, action: #selector(showUnits))
        unitImageView.addGestureRecognizer(guestureFour)
        unitImageView.addSubview(imageView3)
        imageView3.image = UIImage.init(named: "prefill_icon")
        imageView3.contentMode = .center
        unitNameTextField.rightView = unitImageView
        unitNameTextField.rightViewMode = .always

        unitNameTextField.delegate = self
        blockNameTextField.delegate = self
        towerNameTextField.delegate = self
        projectNameTextField.delegate = self
        rangeTextField.delegate = self
        rangeTextField.text = "All"
        self.outStandingParams.range = "-1"

        let unitTypeImage = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 52, height: 64))
        unitTypeImage.contentMode = UIView.ContentMode.scaleAspectFit
        unitTypeImage.image = UIImage.init(named: "downArrow")
        rangeTextField.rightView = unitTypeImage
        rangeTextField.rightViewMode = .always

                
        rangesArray = ["All","Greater than 90 days","60 - 90 days","30 - 60 days","Less than 30 days"]

    }
    @objc func showProjects(){
        _ = self.textFieldShouldBeginEditing(self.projectNameTextField)
    }
    @objc func showBlocks(){
        _ =  self.textFieldShouldBeginEditing(self.blockNameTextField)
    }
    @objc func showTowers(){
        _ = self.textFieldShouldBeginEditing(self.towerNameTextField)
    }
    @objc func showUnits(){
        _ = self.textFieldShouldBeginEditing(self.unitNameTextField)
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func fetchOutstandings(_ sender: Any) {
        
        if self.outStandingParams.prId.isEmpty{
            HUD.flash(.label("Please select project"), delay: 1.0)
            return
        }
        HUD.show(.progress, onView: self.view)
        ServerAPIs.getOutstandingsForSelectedProject(outStandingParameters: self.outStandingParams, completion: { result in
            DispatchQueue.main.async { [weak self] in
                HUD.hide()
                switch result {
                case .success:
                    let listController = OutstandingsListViewController(nibName: "OutstandingsListViewController", bundle: nil)
                    listController.modalPresentationStyle = .fullScreen
                    self?.navigationController?.pushViewController(listController, animated: true)
                    break
                case .failure(let error):
                    HUD.flash(.label(error.localizedDescription), delay: 1.0)
                    break
                }
            }
        })
    }
    
    func showRanges(){
        
        // Show Pop Up
        self.view.endEditing(true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .OUTSTANDING_RANGES
        vc.preferredContentSize = CGSize(width:  300, height: (self.rangesArray.count - 1) * 44)
        
        if(CGFloat((self.rangesArray.count * 44)) > (self.view.frame.size.height - 150)){
            
            vc.preferredContentSize = CGSize(width: 300, height: (self.view.frame.size.height - 150))
        }
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        vc.outstandingRanges = self.rangesArray
        
        popOver?.sourceView = rangeTextField
        
        vc.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)
        
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
extension OutstandingsViewController : UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if(rangeTextField == textField){
            self.showRanges()
            return false
        }

        let projectSearchController = ProjectSearchViewController(nibName: "ProjectSearchViewController", bundle: nil)
        projectSearchController.isOutStanding = true
        projectSearchController.modalPresentationStyle = .fullScreen
        
        if !self.outStandingParams.prId.isEmpty{
            let project = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: self.outStandingParams.prId)
            projectSearchController.selectedProject = project
        }

        if(projectNameTextField == textField){
            projectSearchController.didSelectId = { [weak self] (projectId,projectName) in
                if(self?.projectNameTextField.text != projectName){
                    self?.outStandingParams = OutStanding(prId: "", blId: "", twId: "", uId: "", range: "")
                    self?.blockNameTextField.text = ""
                    self?.towerNameTextField.text = ""
                    self?.unitNameTextField.text = ""
                }
                self?.outStandingParams.prId = projectId ?? ""
                self?.projectNameTextField.text = projectName
            }
            projectSearchController.shouldShowProjects = true
            self.navigationController?.pushViewController(projectSearchController, animated: true)
            return false
        }
        if(projectSearchController.selectedProject == nil){
            HUD.flash(.label("Please select project"), delay: 1.4)
            return false
        }
        if(blockNameTextField == textField){
            projectSearchController.shouldShowBlocks = true
            projectSearchController.selectedBlockId = self.outStandingParams.blId
            projectSearchController.didSelectId = { [weak self] (blockId,blockName) in
                
                if(self?.blockNameTextField.text != blockName){
                    self?.towerNameTextField.text = ""
                    self?.unitNameTextField.text = ""
                }

                self?.outStandingParams.blId = blockId ?? ""
                self?.blockNameTextField.text = blockName ?? ""
            }
        }
        else if(towerNameTextField == textField){
            if(self.outStandingParams.blId.isEmpty){
                HUD.flash(.label("Please select block"), delay: 1.4)
                return false
            }
            projectSearchController.shouldShowTowers = true
            projectSearchController.selectedBlockId = self.outStandingParams.blId
            projectSearchController.selectedTowerId = self.outStandingParams.twId
            projectSearchController.didSelectId = { [weak self] (towerId,towerName) in
                
                if(self?.towerNameTextField.text != towerName){
                    self?.unitNameTextField.text = ""
                }
                self?.outStandingParams.twId = towerId ?? ""
                self?.towerNameTextField.text = towerName
            }
        }
        else if(unitNameTextField == textField){
            if(self.outStandingParams.twId.isEmpty){
                HUD.flash(.label("Please select tower"), delay: 1.4)
                return false
            }
            projectSearchController.shouldShowUnits = true
            projectSearchController.selectedBlockId = self.outStandingParams.blId
            projectSearchController.selectedTowerId = self.outStandingParams.twId
            projectSearchController.selectedUnitId = self.outStandingParams.uId
            projectSearchController.didSelectId = { [weak self] (unitId,unitName) in
                self?.outStandingParams.uId = unitId ?? ""
                self?.unitNameTextField.text = unitName ?? ""
            }
        }
        
        self.navigationController?.pushViewController(projectSearchController, animated: true)
        return false
    }
    
}
extension OutstandingsViewController : HidePopUp{
    func didSelectOutStandingRange(selectedRange : String,index : Int)
    {
        self.rangeTextField.text = selectedRange
        self.outStandingParams.range = String(format: "%d", index - 1)
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });

    }
}
extension OutstandingsViewController : UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

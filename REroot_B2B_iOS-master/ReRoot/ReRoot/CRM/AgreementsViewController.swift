//
//  AgreementsViewController.swift
//  REroot
//
//  Created by Dhanunjay on 07/06/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import PKHUD

protocol AgreementsDelegate : class {
    func didSelectAgreementType(agreementType : Int)
}
extension AgreementsDelegate{
    func didSelectAgreementType(agreementType : Int){}
}
struct AGREEMENT_TYPES {
    static let Sales_Agreement = 1
    static let Assigment_Agreement = 2
}
class AgreementsViewController: UIViewController {

    @IBOutlet weak var assignmentAgreementLabel: UILabel!
    @IBOutlet weak var saleAgreementLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var heightOfUnitNameLabel: NSLayoutConstraint!
    @IBOutlet weak var unitNameLabel: UILabel!
    @IBOutlet weak var assigmentAgreementView: UIView!
    @IBOutlet weak var saleAgreementView: UIView!
    @IBOutlet weak var saleImageView: UIImageView!
    @IBOutlet weak var assignmentImageView: UIImageView!
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var heightOfTitleView: NSLayoutConstraint!
    var isFromCrm : Bool = false
    var isFromManageUnits : Bool = false
    
    weak var delegate : AgreementsDelegate?
    var selectedUnitName : String!
    
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
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        self.configureView()
    }
    func configureView(){
        
        if(isFromCrm){
            heightOfUnitNameLabel.constant = 0
            unitNameLabel.isHidden = true
            if(isFromManageUnits){
                self.titleLabel.text = "MANAGE UNITS"
                self.saleAgreementLabel.text = "Block/Release Units"
                self.assignmentAgreementLabel.text = "Reserve Units"
                self.saleImageView.image = UIImage.init(named: "block")
                self.assignmentImageView.image = UIImage.init(named: "leads_icon")
            }
        }
        else{
            self.titleView.isHidden = true
            self.heightOfTitleView.constant = 0
        }
        
        saleImageView.layer.cornerRadius = 8
        saleImageView.clipsToBounds = true
        
        assignmentImageView.layer.cornerRadius = 8
        assignmentImageView.clipsToBounds = true

        self.redrawView(view: saleAgreementView)
        self.redrawView(view: assigmentAgreementView)
        self.unitNameLabel.text = self.selectedUnitName ?? ""
    }
    func redrawView(view: UIView) {
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.3
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func showProjectSelection(agreementType : Int,isResverve : Bool,isBlockOrRelease : Bool){
        let projectSearchController = ProjectSearchViewController(nibName: "ProjectSearchViewController", bundle: nil)
        projectSearchController.agreementType = agreementType
        projectSearchController.isReserve = isResverve
        projectSearchController.isBlockOrRelease = isBlockOrRelease
        projectSearchController.modalPresentationStyle = .fullScreen
        let tempNavigator = UINavigationController.init(rootViewController: projectSearchController)
        tempNavigator.navigationBar.isHidden = true
        tempNavigator.modalPresentationStyle = .fullScreen
        self.present(tempNavigator, animated: true, completion: nil)
    }
    @IBAction func showSaleAgreeementView(_ sender: Any) {
        if(isFromCrm){
            if(isFromManageUnits){
                self.showProjectSelection(agreementType : -1,isResverve : false ,isBlockOrRelease : true)
                return
            }
            self.showProjectSelection(agreementType: AGREEMENT_TYPES.Sales_Agreement, isResverve : false ,isBlockOrRelease : false)
            return
        }
        self.delegate?.didSelectAgreementType(agreementType: AGREEMENT_TYPES.Sales_Agreement)
    }
    
    @IBAction func showAssignmentAgreementView(_ sender: Any) {
        if(isFromCrm){
            if(isFromManageUnits){
                if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.BLOCK_RELEASE_UNIT.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)){
                    HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
                    return
                }
                self.showProjectSelection(agreementType : -1,isResverve : true ,isBlockOrRelease : false)
                return
            }
            self.showProjectSelection(agreementType: AGREEMENT_TYPES.Assigment_Agreement, isResverve : false ,isBlockOrRelease : false)
            return
        }
        self.delegate?.didSelectAgreementType(agreementType: AGREEMENT_TYPES.Assigment_Agreement)
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

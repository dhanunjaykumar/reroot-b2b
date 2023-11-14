//
//  HandOverItemsViewController.swift
//  REroot
//
//  Created by Dhanunjay on 24/05/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import CoreData
import FloatingPanel

protocol ItemActionsFinish : class {
    func uploadHandoverUnits()
}
extension ItemActionsFinish{
    func uploadHandoverUnits(){}
}
class HandOverItemsViewController: UIViewController {

    weak var delegate : ItemActionsFinish?
    var fetchedResultsControllerHandOverItems : NSFetchedResultsController<TowerHandOverItems>!
    
    let fpc = FloatingPanelController()
    
    var isPermittedToEdit : Bool = false
    
    @IBOutlet weak var popUpSourceView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    var selectedUnit : SoldUnits!
    
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.uploadHandoverUnits()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.fetchHandOverItems()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureView()
    }
    func configureView(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchHandOverItems), name: NSNotification.Name("FecthHandOverItems"), object: nil)
        //                    NotificationCenter.default.post(name: NSNotification.Name("FecthHandOverItems"), object: nil)


        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = 120

        let nib = UINib(nibName: "HandOverItemTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "hoItemCell")
        
        //itemHistory
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.titleLabel.text = selectedUnit.unitDescription ?? ""
        
        self.fetchHandOverItems()
    }
    @objc func fetchHandOverItems(){
        
        let request: NSFetchRequest<TowerHandOverItems> = TowerHandOverItems.fetchRequest()
        
        let predicate = NSPredicate(format: "unit CONTAINS[c] %@", selectedUnit.id!)
        request.predicate = predicate
        
        let sort1 = NSSortDescriptor(key: #keyPath(TowerHandOverItems.groupdName), ascending: true)
        request.sortDescriptors = [sort1]
        
        fetchedResultsControllerHandOverItems = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: "groupdName", cacheName:nil)
        
        do {
            try fetchedResultsControllerHandOverItems.performFetch()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func showHandOverHistory(_ sender: Any) {
        
        let quickController = QuickLinksViewController(nibName: "QuickLinksViewController", bundle: nil)
        quickController.cellType = TabelViewCellType.HANDOVER_HOSTORY
        quickController.handOverItemHistory = selectedUnit!.handOverHistory?.allObjects as! [UnitHandOverHistory]
        quickController.handOverItemHistory.sort( by: { $0.index <= $1.index })
        quickController.titleText = String(format: "%@ (%@)", selectedUnit.unitDisplayName!,selectedUnit.unitDescription!)
        self.showFloatingPanel(controller: quickController)
    }
    
    //MARK: - FLOAT PANEL BEGIN
    @objc func moveFpcViewToFull() {
        fpc.move(to: .full, animated: true)
    }
    func showFloatingPanel(controller : QuickLinksViewController){
        
        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false
        
        fpc.delegate = self
        
        fpc.set(contentViewController: controller)
        
        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        
        fpc.track(scrollView: controller.tableView)
        
        self.present(fpc, animated: true, completion: nil)
    }
    func showHistoryItemsForSelection(controller : EditHOItemsViewController){
        
        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false
        
        fpc.delegate = self
        
        fpc.set(contentViewController: controller)
        
        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        
        fpc.track(scrollView: controller.tableView)
        
        self.present(fpc, animated: true, completion: nil)

    }
    //MARK: - FLOAT PANEL END

}
extension HandOverItemsViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsControllerHandOverItems.sections!.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : HandOverItemTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "hoItemCell",
            for: indexPath) as! HandOverItemTableViewCell

//        cell.openMandatoryItemsLabel.text = "100"
//        cell.

        let sectionInfo = self.fetchedResultsControllerHandOverItems.sections![indexPath.section]
        
        let sectionItems = sectionInfo.objects! as! [TowerHandOverItems]
        
        // write query for selected groudName & handover status & mandotry or not
        
        //HAND_OVER_ITEM_STATE
        
        let firstObj = sectionItems[0]
        
       let mandCompletedCount = RRUtilities.sharedInstance.model.getCountOfItemGroup(unit: firstObj.unit!, groupdName: firstObj.groupdName!, mandatory: true,handOverStatus: HAND_OVER_ITEM_STATE.STATUS_COMPLETED.rawValue)
        
        let mandInCompletedCount = RRUtilities.sharedInstance.model.getCountOfItemGroup(unit: firstObj.unit!, groupdName: firstObj.groupdName!, mandatory: true,handOverStatus: HAND_OVER_ITEM_STATE.STATUS_INCOMPLETE.rawValue)
        
        let totalMandateCount = mandCompletedCount + mandInCompletedCount
        
        cell.totalMandatoryItemsLabel.text = String(format: "%d", totalMandateCount)
        cell.openMandatoryItemsLabel.text = String(format: "%d", mandInCompletedCount)
        cell.closedMandatoryItemsLabel.text = String(format: "%d", mandCompletedCount)

        let notMandCompletedCount = RRUtilities.sharedInstance.model.getCountOfItemGroup(unit: firstObj.unit!, groupdName: firstObj.groupdName!, mandatory: false,handOverStatus: HAND_OVER_ITEM_STATE.STATUS_COMPLETED.rawValue)
        
        let notMandInCompletedCount = RRUtilities.sharedInstance.model.getCountOfItemGroup(unit: firstObj.unit!, groupdName: firstObj.groupdName!, mandatory: false,handOverStatus: HAND_OVER_ITEM_STATE.STATUS_INCOMPLETE.rawValue)
        
        let totalNonMandateCount = notMandCompletedCount + notMandInCompletedCount
        
        cell.totalItemsLabel.text = String(format: "%d", totalNonMandateCount)
        cell.closedItemsLabel.text = String(format: "%d", notMandCompletedCount)
        cell.openItemsLabel.text = String(format: "%d", notMandInCompletedCount)
        
        cell.subContentView.layer.cornerRadius = 4
        cell.subContentView.layer.borderWidth = 2
        cell.subContentView.layer.borderColor = UIColor.clear.cgColor
        cell.subContentView.layer.shadowRadius = 4
        cell.subContentView.layer.masksToBounds = false
        cell.subContentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.subContentView.layer.shadowRadius = 2
        cell.subContentView.layer.shadowOpacity = 0.3
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // show items **
        print("")
        // fetch for seleted section ***
        
        // query to get groupd items
        
        // pass unit , groupdname n fetch there as need to modify there **
        
        let sectionInfo = self.fetchedResultsControllerHandOverItems.sections![indexPath.section]
        let sectionItems = sectionInfo.objects! as! [TowerHandOverItems]
        let firstObj = sectionItems[0]

        let editItemController = EditHOItemsViewController(nibName: "EditHOItemsViewController", bundle: nil)
        editItemController.selectedUnit = self.selectedUnit
        editItemController.selectedGroupDName = firstObj.groupdName
        editItemController.isPermittedToEdit = self.isPermittedToEdit
        editItemController.delegate = self
        self.showHistoryItemsForSelection(controller: editItemController)
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionInfo = self.fetchedResultsControllerHandOverItems.sections![section]
        let fistObj = sectionInfo.objects![0] as! TowerHandOverItems
        
        let label: UILabel = {
            let lb = UILabel()
            lb.translatesAutoresizingMaskIntoConstraints = false
            lb.text = fistObj.groupdName
            lb.textColor = .black
            lb.font = UIFont(name: "Montserrat-Regular", size: 12)
            lb.numberOfLines = 0
            lb.lineBreakMode = .byWordWrapping
            lb.backgroundColor = .white
            lb.numberOfLines = 0
            return lb
        }()
        
        let header: UIView = {
            let hd = UIView()
            hd.backgroundColor = .white
            hd.addSubview(label)
            label.leadingAnchor.constraint(equalTo: hd.leadingAnchor, constant: 12).isActive = true
            label.topAnchor.constraint(equalTo: hd.topAnchor, constant: 14).isActive = true
            label.trailingAnchor.constraint(equalTo: hd.trailingAnchor, constant: 10).isActive = true
            label.bottomAnchor.constraint(equalTo: hd.bottomAnchor, constant: 0).isActive = true
            return hd
        }()
        return header

    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
}
extension HandOverItemsViewController : FloatingPanelControllerDelegate{
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return  CustomPanelLayout(parent: self)
    }
}
extension HandOverItemsViewController : CompalintDialog{
    
    func showComplaintDialog(selectedHandOverItem : TowerHandOverItems,buttonIndex : Int) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let complaintController = storyboard.instantiateViewController(withIdentifier: "complaintView") as! HandOverComplaintViewController
        complaintController.selectedHandOverItem = selectedHandOverItem
        complaintController.isModalInPopover = true
        complaintController.buttonIndex = buttonIndex

        let navigationContoller = UINavigationController(rootViewController: complaintController)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover

        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)

        
        complaintController.preferredContentSize = CGSize(width: 320, height: 330)
//        navigationContoller.preferredContentSize = CGSize(width: 320, height: 400)
        
        popOver?.sourceView = self.popUpSourceView
        
//        popOver?.sourceRect = self.tableView.center
        
        popOver?.passthroughViews = nil
        
        // Preseting usint root view controller
        
        let window = UIApplication.shared.keyWindow
        if let modalVC = window!.rootViewController?.presentedViewController {
            modalVC.present(navigationContoller, animated: true, completion: nil)
        } else {
            window!.rootViewController!.present(navigationContoller, animated: true, completion: nil)
        }
    }
}
extension HandOverItemsViewController : UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
extension HandOverItemsViewController : ImageDelegate{
    func showHandOverItemImges(imagesArray: [String]) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let floorPlanController = storyboard.instantiateViewController(withIdentifier :"floorPlan") as! FloorPlanViewController
        floorPlanController.planType = PLAN_TYPE.HAND_OVER_ITEM
        floorPlanController.handOverImages = imagesArray
//        floorPlanController.selectedHandOverItem = self.selectedHandOverItem
        self.navigationController?.pushViewController(floorPlanController, animated: true)
    }
}


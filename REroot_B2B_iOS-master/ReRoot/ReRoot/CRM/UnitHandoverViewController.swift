//
//  UnitHandoverViewController.swift
//  REroot
//
//  Created by Dhanunjay on 17/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import CoreData
import FloatingPanel
import AWSS3
import SDWebImage

class UnitHandoverViewController: UIViewController,UICollectionViewDelegateFlowLayout {

    var refreshControl : UIRefreshControl?
    var indexPathForScroll : IndexPath!

    var floatPopUpRowCounter : Int!
    @IBOutlet weak var statusLabel: UILabel!
    var fetchedResultsControllerProjects : NSFetchedResultsController<SoldUnitProjects>!
    var soldUnitsfetchedResultsController : NSFetchedResultsController<SoldUnits>!
    

    @IBOutlet weak var popUpSourceView: UIView!
    var projectsList : Array<Dictionary<String,String>>!
    var blocksButton : ButtonView!
    @IBOutlet weak var titleInfoView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var projectTitleLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var statusCollectionView: UICollectionView!
    var unitHandOverStatusArray : [String] = []
    var selectedStatusToShow : Int = -1
    var selectedProject : SoldUnitProjects!
    var indexPathForUnitSelection : IndexPath!
    var isPermitted : Bool = false
    
    @IBOutlet weak var heightOfCollectionView: NSLayoutConstraint!
    @IBOutlet weak var topConstraintOfCollectionView: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraintOfCollectionView: NSLayoutConstraint!
    var popUpDataDict = Dictionary<String,Array<String>>()
    var orderedBlocksArrayForPopUp = NSMutableOrderedSet()

    
    // MARK: - View LIfe cycle
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
        
    }
    @objc func injected(){
        
        self.configureView()
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.configureView()
        self.buildFloatingButton()
    }
    func getHStateforState(hsState : Int)->[String]{
        
        switch hsState {
        case 0:
            return [HANDOVER_STATUS_TEXT.Internal_Review.rawValue]
        case 1:
            return [HANDOVER_STATUS_TEXT.Internal_Review.rawValue]
        case 2:
            return [HANDOVER_STATUS_TEXT.Internal_Snags.rawValue,HANDOVER_STATUS_TEXT.Customer_Review.rawValue]
        case 3:
            return [HANDOVER_STATUS_TEXT.Internal_Review.rawValue]
        case 4:
            return [HANDOVER_STATUS_TEXT.Customer_Snags.rawValue,HANDOVER_STATUS_TEXT.Final_Possession.rawValue]
        case 5:
            return [HANDOVER_STATUS_TEXT.Internal_Review.rawValue]
        case 5:
            return [HANDOVER_STATUS_TEXT.Customer_Snags.rawValue]
        default:
            return [HANDOVER_STATUS_TEXT.Internal_Review.rawValue]
        }
    }
    
    func configureView(){
        

        self.statusCollectionView.register(UINib(nibName: "ColorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "colorCell")

        self.unitHandOverStatusArray = ["Handover Review","Internal Review","Internal Snags","Customer Review","Customer Snags","Final Possession"]
        
        self.collectionView.register(UINib(nibName: "UnitDetailsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "unitCell")
        
        let tempLayout1 = UICollectionViewFlowLayout.init()
        tempLayout1.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
//        let itemWidth = ((collectionView.bounds.size.width - 10) / CGFloat(4)).rounded(.down)
//        tempLayout1.itemSize =  CGSize(width: itemWidth, height: itemWidth)

//        tempLayout1.itemSize = UICollectionViewFlowLayout.automaticSize
//        tempLayout1.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        tempLayout1.headerReferenceSize =  CGSize(width: self.view.frame.size.width, height: 50)
//        tempLayout1.footerReferenceSize = CGSize(width: self.view.frame.size.width, height: 50)
        tempLayout1.minimumInteritemSpacing = 2
        tempLayout1.minimumLineSpacing = 5
        tempLayout1.scrollDirection = .vertical

        collectionView.collectionViewLayout = tempLayout1
        collectionView.backgroundColor = UIColor.hexStringToUIColor(hex: "f0f7ff")
        self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "f0f7ff")
        
        let tempLayout2 = UICollectionViewFlowLayout.init()
        tempLayout2.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tempLayout2.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        tempLayout2.minimumInteritemSpacing = 0
        tempLayout2.minimumLineSpacing = 0
        tempLayout2.scrollDirection = .horizontal
        statusCollectionView.collectionViewLayout = tempLayout2

        self.statusCollectionView.delegate = self
        self.statusCollectionView.dataSource = self
        self.statusCollectionView.reloadData()
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.black
        refreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        self.collectionView.addSubview(refreshControl!)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(getHandoverUnits), name: NSNotification.Name("FetchHandOverUnits"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name("UpdateUIOnNetowrkBack"), object: nil)
        
        self.fetchAllProjects()
        
        self.perform(#selector(reloadInex), with: nil, afterDelay: 0.5)
    }
    @objc func reloadCollectionView(){
//        heightOfCollectionView
        self.collectionView.reloadData()
//        sleep(1)
//        self.heightOfCollectionView.constant = self.collectionView.contentSize.height + 200
//        self.collectionView.contentSize.height += 200
        self.collectionView.layoutIfNeeded()
        self.view.layoutIfNeeded()
    }
    @objc func reloadInex(){
        self.statusCollectionView.reloadItems(at: [IndexPath.init(row: 4, section: 0)])
        self.statusCollectionView.reloadItems(at: [IndexPath.init(row: 5, section: 0)])
        self.statusCollectionView.reloadItems(at: [IndexPath.init(row: 5, section: 0)])
        self.statusCollectionView.reloadItems(at: [IndexPath.init(row: 0, section: 0)])
    }
    @objc func refreshList() {
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            //** if fetched data is there show that **
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            self.refreshControl?.endRefreshing()
            return
        }
        self.updateHandoverData(shouldPostNotification: true)
    }
    @objc func updateHandoverData(shouldPostNotification : Bool){
//        RRUtilities.sharedInstance.model.uploadOfflineHandOverData(shouldPostNotification: shouldPostNotification,isFromHomeView: false)
        SyncHelper.shared.uploadHandoverData(completionHandler: {(response,error) in
            self.getHandoverUnits()
        })
    }
    @objc func getHandoverUnits(){
        self.refreshControl?.beginRefreshing()
        self.soldUnitsfetchedResultsController.delegate = nil
        ServerAPIs.getSoldUnitsForCompanyGroup(completionHandler: { (responseObejct , error) in
            if(responseObejct?.status == 1){

                self.soldUnitsfetchedResultsController.delegate = nil
                RRUtilities.sharedInstance.model.writeSoldUnitsToDB(soldUnits: responseObejct!.units!, completionHandler:   {(response,error) in
                    if(response){
                        DispatchQueue.main.async {
                            self.fetchProjectDetailsByProjectId(projectId: self.selectedProject.projectID!)
                        }
                    }
                    else{
                        
                    }
                })
//                sleep(UInt32(1))
            }
            
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }

        })

    }
    @objc func updateUI(){
        self.fetchAllProjects()
    }
    func fetchAllProjects(){
        
        let request: NSFetchRequest<SoldUnitProjects> = SoldUnitProjects.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(SoldUnitProjects.projectName), ascending: true)
        request.sortDescriptors = [sort]
        
        fetchedResultsControllerProjects = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        
        do {
            try fetchedResultsControllerProjects?.performFetch()
            _ = fetchedResultsControllerProjects?.fetchedObjects
            if(fetchedResultsControllerProjects!.fetchedObjects!.count > 0){
                let project = fetchedResultsControllerProjects.object(at: IndexPath.init(row: 0, section: 0))
                self.selectedProject = project
                self.projectTitleLabel.text = project.projectName
                self.fetchProjectDetailsByProjectId(projectId: project.projectID!)
            }
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    func fetchProjectDetailsByProjectId(projectId : String){
        
        let request: NSFetchRequest<SoldUnits> = SoldUnits.fetchRequest()
        
        var predicate = NSPredicate(format: "projectId CONTAINS[c] %@", projectId)
        if(selectedStatusToShow != -1){
           predicate = NSPredicate(format: "projectId CONTAINS[c] %@ AND handOverStatus == %d", projectId,selectedStatusToShow)
        }
        request.predicate = predicate
        
        let sort1 = NSSortDescriptor(key: #keyPath(SoldUnits.sectionIndex), ascending: true)
        let sort = NSSortDescriptor(key: #keyPath(SoldUnits.floorIndex), ascending: true)
        let tempSort = NSSortDescriptor(key: #keyPath(SoldUnits.unitIndex), ascending: true)
        request.sortDescriptors = [sort1,sort,tempSort]
        
        soldUnitsfetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: "sectionIndex", cacheName:nil)
        soldUnitsfetchedResultsController.delegate = self
        
        do {
            try soldUnitsfetchedResultsController?.performFetch()
//            _ = soldUnitsfetchedResultsController?.fetchedObjects
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.reloadCollectionView()
            if((soldUnitsfetchedResultsController?.sections!.count)! <= 1){
                self.shouldHideFloatButton(shouldShow: false)
            }
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    
    
    func buildFloatingButton(){
        self.blocksButton?.removeFromSuperview()
        self.blocksButton = nil
        
        if(self.soldUnitsfetchedResultsController == nil || self.soldUnitsfetchedResultsController.fetchedObjects?.count == 0){
            //            self.buildFloatingButton()
            return
        }
        
        self.blocksButton = ButtonView.instanceFromNib() as? ButtonView
        self.blocksButton.backgroundColor = UIColor.green
        
        if(self.soldUnitsfetchedResultsController.fetchedObjects!.count > 0){
            let tempUnit : SoldUnits = self.soldUnitsfetchedResultsController.object(at: IndexPath(row: 0, section: 0))
            self.blocksButton.mTitleLabel?.text = tempUnit.sectionTitle
        }
        
        self.blocksButton.center = self.view.center
        
        self.blocksButton.clipsToBounds = true
        
        self.blocksButton.layer.masksToBounds = false
        self.blocksButton.layer.shadowColor = UIColor.lightGray.cgColor
        self.blocksButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        self.blocksButton.layer.shadowOpacity = 0.4
        self.blocksButton.layer.shadowRadius = 2.0
        self.blocksButton.layer.shouldRasterize = true
        self.blocksButton.layer.borderColor = UIColor.white.cgColor
        self.blocksButton.layer.shouldRasterize = true
        self.blocksButton.layer.rasterizationScale = UIScreen.main.scale
        self.blocksButton.layer.cornerRadius = 20
        
        self.blocksButton.center.y = self.view.center.y + (self.view.frame.size.height/2 - 80)
        self.blocksButton.subView.layer.cornerRadius = 20
        //        self.blocksButton.frame.size = CGSize.init(width: 160, height: 40)
        
        let tapGuesture = UITapGestureRecognizer.init(target: self, action: #selector(showBlocks))
        self.blocksButton.addGestureRecognizer(tapGuesture)
        
        //        self.blocksButton.isHidden = false
//        print(self.blocksButton)
        self.view.addSubview(self.blocksButton)
        
        self.view.bringSubviewToFront(self.blocksButton)
        
//        self.view.backgroundColor = UIColor.orange
    }
    func makeFloatButtonPopUpDataSource(){
        
        popUpDataDict.removeAll()
        orderedBlocksArrayForPopUp.removeAllObjects()
        
        let sections = self.soldUnitsfetchedResultsController.sections
        
        for eachSection in sections!{
            
            let firstObj : SoldUnits = eachSection.objects![0] as! SoldUnits
            
            orderedBlocksArrayForPopUp.add(firstObj.blockName!)
            
            if(popUpDataDict[firstObj.blockName!] != nil){
                var towerNames = popUpDataDict[firstObj.blockName!]
                towerNames?.append(firstObj.towerForFloat!)
                popUpDataDict[firstObj.blockName!] = towerNames

            }
            else{
                var towerNames : Array<String> = []
                towerNames.append(firstObj.towerForFloat!)
                popUpDataDict[firstObj.blockName!] = towerNames
            }
        }
        
//        print(popUpDataDict)
        
    }
    @objc func showBlocks(){
        
        self.makeFloatButtonPopUpDataSource()
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .SOLD_UNITS_FLOAT_MENU
        var counter = orderedBlocksArrayForPopUp.count
        
        for tempKey in self.popUpDataDict.keys{
//            print(tempKey)
            let towers = self.popUpDataDict[tempKey]
            counter += towers!.count
        }
        
        if(counter == 1 ){
            vc.preferredContentSize = CGSize(width: 250, height: 44)
        }
        else{
            vc.preferredContentSize = CGSize(width: 250, height: ((counter-1) * 44))
        }
        
        if(CGFloat((counter * 44)) > (self.view.frame.size.height - 150)){
            
            vc.preferredContentSize = CGSize(width: 250, height: (self.view.frame.size.height - 150))
        }
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.down
        if(orderedBlocksArrayForPopUp.count > 0){
            vc.oderedSectionTitlesForFloatButton = orderedBlocksArrayForPopUp.array as! [String]
        }
        vc.selectedProjectId = selectedProject.projectID ?? ""
        vc.handOverFloatButtonMenu = self.popUpDataDict
        //        popOver?.barButtonItem = sender as? UIBarButtonItem
        
        popOver?.sourceView = blocksButton.mCenterLabelForPopUp
        
        //            popOver?.sourceRect = CGRect(x: self.view.center.x, y: projectsButton.frame.origin.y - 80, width: projectsButton.frame.size.width, height: projectsButton.frame.size.height)
        //            popOver?.sourceView?.frame.origin.x = self.view.center.x
        vc.delegate = self
        //        popOver?.sourceRect = optionsButton.frame
        
        self.present(navigationContoller, animated: true, completion: nil)
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func showProjectsPopUp(_ sender: Any) {
        
        //fetchedResultsControllerProjects
        
        if(self.fetchedResultsControllerProjects!.fetchedObjects!.count > 0){
            //show popup
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
            vc.dataSourceType = .SOLD_UNITS_PROJECTS
            vc.preferredContentSize = CGSize(width: 250, height: (self.fetchedResultsControllerProjects!.fetchedObjects!.count - 1) * 44)
            
            if(CGFloat(((self.fetchedResultsControllerProjects!.fetchedObjects!.count - 1) * 44)) > (self.view.frame.size.height - 150)){
                vc.preferredContentSize = CGSize(width: 250, height: (self.view.frame.size.height - 150))
            }
            
            if(self.fetchedResultsControllerProjects!.fetchedObjects!.count == 1){
                vc.preferredContentSize = CGSize(width: 250, height: 1)
            }
            
            let navigationContoller = UINavigationController(rootViewController: vc)
            navigationContoller.navigationBar.isHidden = true
            navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
            
            let popOver =  navigationContoller.popoverPresentationController
            popOver?.delegate = self
            popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
            vc.handOverProjects = self.fetchedResultsControllerProjects!.fetchedObjects!
            
            popOver?.sourceView = self.popUpSourceView
            
            vc.delegate = self
            
            self.present(navigationContoller, animated: true, completion: nil)
        }
        
    }
    @objc func longTap(_ sender: UIGestureRecognizer){
//        print("Long tap")
        if sender.state == .began {
            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
            //            print(sender.view)
            
            let tapLocation = sender.location(in: self.collectionView)
            let indexPath : IndexPath = collectionView.indexPathForItem(at: tapLocation)!
//            print(indexPath.section)
//            print(indexPath.row)
            
            //Check for permisson first
            
            let tempUnit =  self.soldUnitsfetchedResultsController.object(at: indexPath)
            self.indexPathForUnitSelection = indexPath
            
            let pemissionKey = PermissionsManager.shared.getHandoverPermissionKey(status: Int(tempUnit.handOverStatus))
            
            if(PermissionsManager.shared.checkForPermission(moduleName: pemissionKey, permissionType: UserRolePermissions.EDIT.rawValue)){
                self.isPermitted = true
                let statusMenuArray = self.getHStateforState(hsState: Int(tempUnit.handOverStatus+1))
                
                // pass to pop Up //get string and
                self.showStatusChangePopUpForUnit(statusOptions: statusMenuArray)
            }
            else{
                HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
            }
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
        }
    }
    func showStatusChangePopUpForUnit(statusOptions : [String]){
        
        let selectedCell = collectionView.cellForItem(at: indexPathForUnitSelection)
        
        let tempUnit = self.soldUnitsfetchedResultsController.object(at: indexPathForUnitSelection)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .STATUS
        vc.isHandOverStatus = true
        vc.preferredContentSize = CGSize(width: 200, height: statusOptions.count * 55)
        
        vc.selectedIndexForUnitsView =  Int(tempUnit.unitIndex)
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        vc.tableViewDataSourceOne = statusOptions
        vc.isHandOverStatus = true
        
        if(selectedCell?.isMember(of: UnitDetailsCollectionViewCell.self))!{
            let selectedCell = selectedCell as! UnitDetailsCollectionViewCell
            popOver?.sourceView = selectedCell.subView
        }else
        {
            popOver?.sourceView = selectedCell?.contentView
        }
        
        vc.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)

    }
    @IBAction func shosUnitStatusPopUp(_ sender: Any) {
        self.showPopUpToShowBlockAsPerSelectedStatus()
    }
    func showPopUpToShowBlockAsPerSelectedStatus(){
        
        var tempArray : [String] = self.unitHandOverStatusArray
        tempArray.insert("All Units", at: 0)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .SHOW_STATUS_WISE
        vc.isHandOverStatus = true
        vc.preferredContentSize = CGSize(width: 200, height: unitHandOverStatusArray.count * 55)
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        vc.tableViewDataSourceOne = tempArray
        popOver?.sourceView = self.statusLabel
        
        vc.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)
        
    }

    func shouldHideFloatButton(shouldShow : Bool){
        if(blocksButton != nil){
            blocksButton.isHidden = !shouldShow
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
extension UnitHandoverViewController : UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
extension UnitHandoverViewController : HidePopUp{
    
    func showSelectedTowerForSoldUnitsFloat(selectedTowerName: String, selectedBlock: String) {
        
        let selectedTowerTitle  = String(format: "%@ - %@", selectedBlock,selectedTowerName)

        var sectionCounter = 0
        let sections =  self.soldUnitsfetchedResultsController.sections
        
        for eachSection in sections!{
            
            let firstObj : SoldUnits = eachSection.objects![0] as! SoldUnits
            
            if(firstObj.sectionTitle == selectedTowerTitle){
                //scroll to section
                
                if let attributes = collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: sectionCounter)) {
                    let offsetY = attributes.frame.origin.y - collectionView.contentInset.top
//                    if #available(iOS 11.0, *) {
//                        offsetY -= collectionView.safeAreaInsets.top
//                    }
                    collectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true) // or animated: false
                }
                break
            }
            sectionCounter += 1
        }
        
        self.hidePopUp()
        
        
    }
    
    func didSelectProject(optionType: String, optionIndex: Int) {
        
        let project : SoldUnitProjects = self.fetchedResultsControllerProjects.object(at: IndexPath.init(row: optionIndex, section: 0))
        self.projectTitleLabel.text = project.projectName
        self.selectedProject = project
        // fetch project details
        self.fetchProjectDetailsByProjectId(projectId: project.projectID!)
        self.hidePopUp()
    }
    func shouldShowUnitsWithSelectedStatus(selectedStatus : Int) {
        
        if(selectedStatus == -1){
            // Show all
            self.statusLabel.text = "All Units"
        }
        else{
            // show selected one
            // fetch handoverStatus Wise
            
            self.statusLabel.text = self.unitHandOverStatusArray[selectedStatus]
        }
        self.selectedStatusToShow = selectedStatus
        self.fetchProjectDetailsByProjectId(projectId: self.selectedProject.projectID!)
        self.hidePopUp()
    }
    func didFinishTask(optionType:String  ,optionIndex: Int){
            print(optionType)
        //perform change call
        self.hidePopUp()
        
        let selectedUnit = self.soldUnitsfetchedResultsController.object(at:indexPathForUnitSelection)
        
        let mandCompletedCount = RRUtilities.sharedInstance.model.checkForMandatoryItems(unit: selectedUnit.id!, mandatory: true, handOverStatus: HAND_OVER_ITEM_STATE.STATUS_INCOMPLETE.rawValue)
        
        if(mandCompletedCount > 0){
            HUD.flash(.label("Close mandatory items to update review status."), delay: 1.0)
            return
        }
        else{
             // continue to change the state /// should support offline also **
            // unit id , unit selected status , and add current action to history and pass that
            let selectedHandOverStatus = RRUtilities.sharedInstance.getIndexFromHOStatus(statusStr: optionType)
            let unitId = selectedUnit.id
//            let unitName = selectedUnit.floorDisplayName
            //selectedUnit.handOverHistory?.count
            
            let tempHandOverUnitHistory = NSEntityDescription.insertNewObject(forEntityName: "UnitHandOverHistory", into: RRUtilities.sharedInstance.model.managedObjectContext) as! UnitHandOverHistory
            tempHandOverUnitHistory.status = Int32(selectedHandOverStatus)
            tempHandOverUnitHistory.modifiedDate = RRUtilities.sharedInstance.getTimeInServerFormatFromDate(date: Date())
            tempHandOverUnitHistory.user = "Super Admin"
            tempHandOverUnitHistory.index = Int64(selectedUnit.handOverHistory!.count + 1)

//            print(tempHandOverUnitHistory)

            let childContext = NSManagedObjectContext(
                concurrencyType: .privateQueueConcurrencyType)
            childContext.parent = RRUtilities.sharedInstance.model.managedObjectContext
            
            let childEntry = childContext.object(
                with: selectedUnit.objectID) as? SoldUnits
            
            childEntry!.addToHandOverHistory(tempHandOverUnitHistory)  //add history item
            childEntry!.handOverStatus = Int16(selectedHandOverStatus) // Update status **
            
            // check for internet : if offline store to DB and update UI , else call server api and update UI
            
            if !RRUtilities.sharedInstance.getNetworkStatus(){
                childEntry?.syncDirty = Int16(SYNC_STATE.SYNC_DIRTY.rawValue)
                childContext.perform {
                    do {
                        try childContext.save()
                    } catch let error as NSError {
                        fatalError("Error: \(error.localizedDescription)")
                    }
                    RRUtilities.sharedInstance.model.saveContext()
                }
                self.reloadCollectionView()
            }
            else{
                
                //        childEntry?.complaintDesc = "testing"
                let handOverHistory = childEntry!.handOverHistory!.allObjects as! [UnitHandOverHistory]
                
                ServerAPIs.updateUHUnitStatus(selectedUnit : selectedUnit,unitName : selectedUnit.unitDisplayName!, projectName:selectedUnit.projectName!,unitDescription:selectedUnit.unitDescription!,unitId: unitId!, unitStatus: selectedHandOverStatus, historyItems:handOverHistory , completionHandler: { (responseObject, error) in
                    if(responseObject?.status == 1){
                        childEntry?.syncDirty = Int16(SYNC_STATE.SYNC_CLEAN.rawValue)
                    }else{
                        childEntry?.syncDirty = Int16(SYNC_STATE.SYNC_DIRTY.rawValue)
                    }
                    
                    DispatchQueue.main.async {
                        childContext.perform {
                            do {
                                try childContext.save()
                            } catch let error as NSError {
                                fatalError("Error: \(error.localizedDescription)")
                            }
                            RRUtilities.sharedInstance.model.saveContext()
                        }
                        self.reloadCollectionView()
                    }
                })
            }
            
        }

    }

    func hidePopUp(){
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    
}
extension UnitHandoverViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if(collectionView == self.statusCollectionView){
            return 1
        }
        if (self.soldUnitsfetchedResultsController!.sections!.count > 0) {
            self.collectionView.restore()
            
        } else {
            
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
            messageLabel.text = "No data available"
            messageLabel.textColor = .black
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
            messageLabel.sizeToFit()
            
            self.collectionView.backgroundView = messageLabel;
        }
        return soldUnitsfetchedResultsController!.sections!.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.statusCollectionView){
            return self.unitHandOverStatusArray.count
        }
        let sectionInfo = soldUnitsfetchedResultsController!.sections![section]
        return sectionInfo.numberOfObjects
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == self.statusCollectionView){
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCollectionViewCell
            
            let statucColorDict = RRUtilities.sharedInstance.getHOStatusColorAsPerStatusString(statusString: self.unitHandOverStatusArray[indexPath.row])

//            print(statucColorDict)
            cell.contentView.layoutIfNeeded()
            cell.clipsToBounds = true
//            cell.contentView.backgroundColor = .darkGray
            cell.statusTitleLabel.numberOfLines = 0
            cell.statusTitleLabel.adjustsFontSizeToFitWidth = true
            cell.statusTitleLabel.minimumScaleFactor=0.5;
            
            cell.heightOfContentView.constant = 70
            
            cell.statusTitleLabel.lineBreakMode = .byWordWrapping
            cell.statusTitleLabel.font = UIFont.init(name: "Montserrat-Regular", size: 10)
            cell.statusTitleLabel.text = statucColorDict["statusString"] as? String
            cell.statusColorIndicatorView.backgroundColor = statucColorDict["color"] as? UIColor
            cell.statusTitleLabel.adjustsFontSizeToFitWidth = true
            cell.subContentView.backgroundColor = UIColor.hexStringToUIColor(hex: "f8fbff")
            cell.subContentView.layoutIfNeeded()
            cell.statusTitleLabel.preferredMaxLayoutWidth = 70
//            cell.invali
//            cell.widthOfTiltleLabel.constant = 93
//            cell.subContentView.layoutIfNeeded()

//            cell.layoutIfNeeded()
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "unitCell", for: indexPath) as! UnitDetailsCollectionViewCell
        
        let tempUnit : SoldUnits = self.soldUnitsfetchedResultsController.object(at: indexPath)

//        if(indexPath.section == self.soldUnitsfetchedResultsController.sections!.count - 1){
//            let sectinInfo = self.soldUnitsfetchedResultsController.sections![indexPath.section]
        
//            let counter = sectinInfo.numberOfObjects

//            let numberOfRows = counter / 4
//
//            if(numberOfRows != 1 && (indexPath.row + 1) % 4 != 0){
//                cell.bottomOfSubView.constant = 0
//            }
//            else if(numberOfRows == 1){
//                cell.bottomOfSubView.constant = 110
//            }
//            else{
//                cell.bottomOfSubView.constant = 110
//            }
            
//            if(indexPath.row == sectinInfo.numberOfObjects-1){
//            }
//        }
//        else{
//            cell.bottomOfSubView.constant = 0
//        }
        
        cell.unitImageView.isHidden = true
        
        cell.unitNumberLabel.text =  tempUnit.unitDescription
        
        cell.subView.layer.cornerRadius = 8
        
        let statucColorDict = RRUtilities.sharedInstance.getHOStatusAsPerStatusForCollectionView(stattusIndex: Int(tempUnit.handOverStatus))
        
        if(tempUnit.handOverStatus == 0){
            let statucColorDict = RRUtilities.sharedInstance.getHOStatusAsPerStatus(stattusIndex: Int(tempUnit.handOverStatus))

            cell.unitNumberLabel.textColor = statucColorDict["color"] as? UIColor
        }
        else{
            cell.unitNumberLabel.textColor = .white
        }

        cell.subView.backgroundColor = statucColorDict["color"] as? UIColor
        
        cell.landOwnerLabel.isHidden = true
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        cell.subView.addGestureRecognizer(longGesture)
        
        cell.subView.layoutIfNeeded()
        cell.layoutIfNeeded()

        cell.unitNumberLabel.preferredMaxLayoutWidth = (collectionView.frame.size.width - 48) / 4
        
        cell.unitCellWidthConstraint.constant = (collectionView.frame.size.width - 48) / 4

        cell.unitNumberLabel.setNeedsLayout()
        cell.unitNumberLabel.setNeedsDisplay()
        cell.unitNumberLabel.layoutIfNeeded()
        
        cell.reloadInputViews()
        
        cell.unitNumberLabel.layoutIfNeeded()
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(collectionView == self.collectionView){
            
            let hoItemsController = HandOverItemsViewController(nibName: "HandOverItemsViewController", bundle: nil)
            hoItemsController.delegate = self
            let tempUnit = self.soldUnitsfetchedResultsController.object(at: indexPath)
            hoItemsController.selectedUnit = tempUnit
            
            self.indexPathForUnitSelection = indexPath
            
            let pemissionKey = PermissionsManager.shared.getHandoverPermissionKey(status: Int(tempUnit.handOverStatus))
            
            if(PermissionsManager.shared.checkForPermission(moduleName: pemissionKey, permissionType: UserRolePermissions.EDIT.rawValue)){
                self.isPermitted = true
            }
            else{
                self.isPermitted = false
            }
            
            hoItemsController.isPermittedToEdit = self.isPermitted
            self.navigationController?.pushViewController(hoItemsController, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            
            let headerView  = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "handOverHeaderID", for: indexPath) as! HandOverCollectionReusableView
            //            headerView.layoutSubviews()
            
            let sectionInfo = self.soldUnitsfetchedResultsController!.sections![indexPath.section]
            let tempUnit = sectionInfo.objects![0] as! SoldUnits
            
            headerView.sectionTitleLabel?.text =  tempUnit.sectionTitle
            
            return headerView
            
//        case UICollectionView.elementKindSectionFooter: break
            
//            let headerView  = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "handOverHeaderID", for: indexPath) as! HandOverCollectionReusableView
//            headerView.backgroundColor = .red
//            return headerView
//            break
        default:
            fatalError("Unexpected element kind")
            break
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if(collectionView == self.statusCollectionView){
//            let itemWidth = (collectionView.bounds.size.width - 48) / 4
            return CGSize(width: 70, height: 70)
        }

//        if(indexPath.section == self.soldUnitsfetchedResultsController.sections!.count - 1){
//
////            let sectinInfo = self.soldUnitsfetchedResultsController.sections![indexPath.section]
////            if(indexPath.row == sectinInfo.numberOfObjects - 1){
////                let itemWidth = (collectionView.bounds.size.width - 48) / 4
////                return CGSize(width: itemWidth, height: 180)
////            }
////            else{
////
////            }
//        }
//        else{
//        }

        let itemWidth = (collectionView.bounds.size.width - 48) / 4
        return CGSize(width: itemWidth, height: 70)
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        if let indexPath : IndexPath = self.collectionView.indexPathsForVisibleItems.first {
            let sectionInfo = self.soldUnitsfetchedResultsController!.sections![indexPath.section]
            if(sectionInfo.numberOfObjects  > 0){
                let tempOBj = sectionInfo.objects![0] as! SoldUnits
                blocksButton.mTitleLabel.text = tempOBj.sectionTitle
            }
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if(self.soldUnitsfetchedResultsController!.sections!.count > 0 && self.collectionView.indexPathsForVisibleItems.sorted().first != nil){
            let indexPath : IndexPath = self.collectionView.indexPathsForVisibleItems.first ?? IndexPath.init()
            let sectionInfo = self.soldUnitsfetchedResultsController!.sections![indexPath.section]
            if(sectionInfo.numberOfObjects  > 0){
                let tempOBj = sectionInfo.objects![0] as! SoldUnits
                blocksButton.mTitleLabel.text = tempOBj.sectionTitle
            }
            blocksButton.subView.layoutIfNeeded()
        }
        
        let tempIndexPaths = self.collectionView.indexPathsForVisibleItems.sorted()
        let tempIndexPath = tempIndexPaths.last

        if(tempIndexPath != nil && tempIndexPath?.section == (self.soldUnitsfetchedResultsController!.sections!.count - 1)){
            if(self.soldUnitsfetchedResultsController!.sections!.count == 1){
                return
            }
            self.bottomConstraintOfCollectionView.constant = 100
            self.indexPathForScroll = tempIndexPath!
            self.perform(#selector(scrollToIndexPath), with: nil, afterDelay: 0.1)
        }
        else{
            self.bottomConstraintOfCollectionView.constant = 0
        }
    }
    @objc func scrollToIndexPath(){
        DispatchQueue.main.async {
            if(self.indexPathForScroll != nil){
                self.collectionView.scrollToItem(at: self.indexPathForScroll, at: .bottom, animated: true)
                self.indexPathForScroll = nil
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let indexPath : IndexPath = self.collectionView.indexPathsForVisibleItems.sorted().first {
            let sectionInfo = self.soldUnitsfetchedResultsController!.sections![indexPath.section]
            if(sectionInfo.numberOfObjects  > 0){
                let tempOBj = sectionInfo.objects![0] as! SoldUnits
                if(blocksButton != nil){
                    blocksButton.mTitleLabel.text = tempOBj.sectionTitle
                }
            }
        }
    }
}
extension UnitHandoverViewController  : NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if(controller == self.soldUnitsfetchedResultsController){
            self.reloadCollectionView()
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if(controller == self.soldUnitsfetchedResultsController){
            switch (type) {
            case .insert:
                if let indexPath = newIndexPath {
                    self.collectionView.insertItems(at: [indexPath])
                }
                break;
            case .delete:
                if let indexPath = indexPath {
                    self.collectionView.deleteItems(at: [indexPath])
                }
                break;
            case .update:
                self.collectionView.reloadItems(at: [indexPath!])
                break;
            default:
                print("...")
            }
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if(controller == self.soldUnitsfetchedResultsController){
            self.reloadCollectionView()
        }
    }
}
extension UnitHandoverViewController : ItemActionsFinish{
    func uploadHandoverUnits() {
        self.updateHandoverData(shouldPostNotification: false)
    }
}

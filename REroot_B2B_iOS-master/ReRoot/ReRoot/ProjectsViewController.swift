//
//  ProjectsViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 11/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import SDWebImage
import CoreData
import FloatingPanel

class ProjectsViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout,UIPopoverPresentationControllerDelegate,HidePopUp,UISearchBarDelegate,FloatingPanelControllerDelegate{
    
    @IBOutlet weak var widthOfNotificationsView: NSLayoutConstraint!
    @IBOutlet weak var notificationsView: UIView!
    @IBOutlet weak var widthOfReportsButton: NSLayoutConstraint!
    let fpc = FloatingPanelController()
    var selectedProjectID : String!
    var fetchedResultsControllerProjects:NSFetchedResultsController<Project>?
    var refreshControl: UIRefreshControl?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notificationsCountLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var mTableView: UITableView!
    var projectsArray : Array<Project> = []
    var currentProjectsArray : Array<Project> = []
    
    @IBOutlet var reportsButton: UIButton!
    var mCollectionViewDataSource : Array<STAT> = []
    var projectsButton : ButtonView!
    var selectedIndexPath : IndexPath!
    
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
        searchBar.isHidden = true
        titleLabel.isHidden = false
        searchButton.isHidden = false
        reportsButton.isHidden = false
    }
    func fetchAllProjects(){
        
        let request: NSFetchRequest<Project> = Project.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Project.name), ascending: true)
        request.sortDescriptors = [sort]

        fetchedResultsControllerProjects = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
//        fetchedResultsControllerProjects?.delegate = self
    

        do {
            try fetchedResultsControllerProjects?.performFetch()
            _ = fetchedResultsControllerProjects?.fetchedObjects
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.black

        self.updateNotificationCountLabel()
        self.notificationsCountLabel.layer.masksToBounds = true
        self.notificationsCountLabel.layer.cornerRadius = 10

        let nib = UINib(nibName: "ProjectDetailsTableViewCell", bundle: nil)
        mTableView.register(nib, forCellReuseIdentifier: "projectCell")
        mTableView.tableFooterView = UIView()
        
        projectsButton = ButtonView.instanceFromNib() as? ButtonView
        projectsButton.backgroundColor = UIColor.white
        self.view.addSubview(projectsButton)
        
        projectsButton.mTitleLabel?.text = "PROJECTS"
        
        if(RRUtilities.sharedInstance.model.getAllProjects().count > 0){
            self.fetchAllProjects()
            self.mTableView.delegate = self
            self.mTableView.dataSource = self
            self.mTableView.reloadData()
        }
        else{
            self.getProjects(UIButton())
        }
        
        projectsButton.center = self.view.center
        self.view.bringSubviewToFront(projectsButton)
        
        projectsButton.clipsToBounds = true
        
        projectsButton.layer.masksToBounds = false
        projectsButton.layer.shadowColor = UIColor.lightGray.cgColor
        projectsButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        projectsButton.layer.shadowOpacity = 0.4
        projectsButton.layer.shadowRadius = 2.0
        projectsButton.layer.shouldRasterize = true
        projectsButton.layer.borderColor = UIColor.white.cgColor
        projectsButton.layer.shouldRasterize = true
        projectsButton.layer.rasterizationScale = UIScreen.main.scale
        projectsButton.layer.cornerRadius = 20

        projectsButton.center.y = self.view.center.y + (self.view.frame.size.height/2 - 80)
        projectsButton.subView.layer.cornerRadius = 20
        projectsButton.frame.size = CGSize.init(width: 160, height: 40)
        
        let tapGuesture = UITapGestureRecognizer.init(target: self, action: #selector(showProjects))
        projectsButton.addGestureRecognizer(tapGuesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchUpdatedProjects), name: Notification.Name("updateProjects"), object: nil)
        
        self.addRefreshControl()
        if(!PermissionsManager.shared.dashBoardPermitted()){
            self.reportsButton.isHidden = true
            self.widthOfReportsButton.constant = 0
        }
        self.getEmployess()
    }
    func addRefreshControl() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.black
        refreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        mTableView.addSubview(refreshControl!)
    }
    @objc func refreshList() {


        self.getProjects(UIButton())
    }

    //MARK: - Tableview Delegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        tableView.estimatedRowHeight = 400 // standard tableViewCell height
        tableView.rowHeight = UITableView.automaticDimension
        
//        let numOfRows: Int =  (self.fetchedResultsControllerProjects?.sections?.count)! //self.currentProjectsArray.count
        
        /*fetchResultController's .section method returns array of NSFetchedResultsSectionInfo objects. As we have not provided any section info, sections */
        guard let sections = self.fetchedResultsControllerProjects!.sections else {
            return 0
        }
        
        /*get number of rows count for each section*/
        let sectionInfo = sections[section]

        if (sectionInfo.numberOfObjects > 0)
        {
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No data available"
            noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
//        print(sectionInfo.numberOfObjects)
        return sectionInfo.numberOfObjects

//        return numOfRows //self.currentProjectsArray.count //RRUtilities.sharedInstance.model.getProjectsCount()  //projectsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProjectDetailsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "projectCell",
            for: indexPath) as! ProjectDetailsTableViewCell
        
//        cell.mCollectinView.register(BlockInfoCollectionViewCell.self, forCellWithReuseIdentifier: "blockCell")

        cell.mCollectinView.delegate = self;
        cell.mCollectinView.dataSource = self;
        cell.mCollectinView.mParentIndexPath = indexPath
        
        cell.mCollectinView.backgroundColor = UIColor.hexStringToUIColor(hex: "fff5f4")
//        cell.mCollectinView.layoutIfNeeded()
//
//        print(cell.mCollectinView)
        
        let projecct = fetchedResultsControllerProjects!.object(at: indexPath) //self.currentProjectsArray[indexPath.row]
        
        cell.projectNameLabel.text = projecct.name?.uppercased()
        cell.cityNameLabel.text = projecct.city?.uppercased()
        
        if(projecct.imagesTemp != nil && (projecct.imagesTemp?.count)! > 0){
            
            var urlString : String = (projecct.imagesTemp?[0])!
            
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//            print(urlString)
            
            DispatchQueue.global().async {
                let url = ServerAPIs.getSingleSingedUrl(url: urlString)
                cell.mImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "App-Default"),options: SDWebImageOptions(rawValue: 0), completed: { image, error, cacheType, imageURL in
                     // your rest code
                    print(error)
                })
            }
            
//            cell.mImageView.sd_setImage(with: URL(string: "https://s3-ap-south-1.amazonaws.com/buildez/ABC+Developers/bookingform/12155_Screenshot20200929at11.34.18PM.png"), placeholderImage: UIImage(named: "project_image_default"), options:[.highPriority])
            
            
        }
        else{
            cell.mImageView.image = UIImage(named: "project_image_default")
        }
        cell.mImageView.clipsToBounds = true
        cell.mImageView.layer.cornerRadius = 8.0
//        cell.mImageView.layer.masksToBounds = true
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(showProjectInfo(_:)))
        cell.mSubContentView.addGestureRecognizer(longGesture)
        
        cell.mSubContentView.layer.cornerRadius = 8
        cell.mSubContentView.layer.borderWidth = 0.5
        cell.mSubContentView.layer.borderColor = UIColor.hexStringToUIColor(hex: "f0f7ff").cgColor
//        cell.mSubContentView.layer.shadowRadius = 0
        cell.mSubContentView.layer.masksToBounds = false
        cell.mSubContentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.mSubContentView.layer.shadowRadius = 0.5
        cell.mSubContentView.layer.shadowOpacity = 0.1

//        cell.mCollectinView.layer.cornerRadius = 8
        
        cell.mCollectinView.clipsToBounds = true
        cell.mCollectinView.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            cell.mCollectinView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }

        cell.collectionViewHolder.clipsToBounds = true
        cell.collectionViewHolder.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            cell.collectionViewHolder.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }

        
//        cell.mCollectinView.layer.cornerRadius = 8
//        cell.mCollectinView.layer.borderWidth = 1.0
//        cell.mCollectinView.layer.borderColor = UIColor.hexStringToUIColor(hex: "f6f6f6").cgColor

        
        cell.mSubContentView.bringSubviewToFront(cell.projectNameLabel)
        cell.mSubContentView.bringSubviewToFront(cell.cityNameLabel)
//        cell.mSubContentView.layer.cornerRadius = 8.0
        cell.mCollectinView.mParentIndexPath = indexPath
        cell.mCollectinView.reloadData()
        cell.mImageView.layer.masksToBounds = true
        cell.mImageView.layer.cornerRadius = 8.0
        cell.overLayImageView.layer.masksToBounds = true
        cell.overLayImageView.layer.cornerRadius = 8.0
        cell.layoutIfNeeded()
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //PROJECT_DETAILS
        self.view.endEditing(true)
        selectedIndexPath = indexPath
        let projecct =  self.fetchedResultsControllerProjects!.object(at: indexPath) //self.currentProjectsArray[indexPath.row]

        let urlString = String(format:RRAPI.PROJECT_DETAILS, projecct.id!)
        selectedProjectID = projecct.id
        self.hideKeyBoard()
       showDetailsOfSelectedProject(urlString: urlString)
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    //MARK: - CollectionView Delegate & DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6 //** Statuses
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let tempCollectionView = collectionView as! CustomCollectionView
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "blockCell", for: indexPath) as! BlockInfoCollectionViewCell
        
//        print("row is \(tempCollectionView.mParentIndexPath.row)")
        
//        let projecct = self.projectsArray[tempCollectionView.mParentIndexPath.row]
        
//        let statssss : NSMutableOrderedSet = projecct.value(forKey: "proStat") as! NSMutableOrderedSet

        let statucColorDict  = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: indexPath.row)
        cell.backgroundColor = UIColor.hexStringToUIColor(hex: "fff5f4")
        cell.mSubContentView.backgroundColor = UIColor.hexStringToUIColor(hex: "fff5f4")
//        cell.mSubContentView.backgroundColor = statucColorDict["color"] as? UIColor
        cell.mStatusTypeLabel.text = statucColorDict["statusString"] as? String
        cell.mStatusTypeLabel.textColor = UIColor.lightGray
        let tempCountDict =  self.getStatusOfBlocks(indexPath: tempCollectionView.mParentIndexPath,collIndexPath: indexPath)
//        cell.mStatusTypeNumberLabel.text = String(tempCountDict["count"]! as! Int)
        
        cell.mStatusTypeNumberLabel.text =  String(format:"%d", tempCountDict["count"]!)
        cell.mStatusTypeNumberLabel.textColor = statucColorDict["color"] as? UIColor
//        cell.mStatusTypeLabel.preferredMaxLayoutWidth = 50;

        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let itemWidth = (self.mTableView.frame.size.width - 50)/6
        return CGSize.init(width: itemWidth, height: 70)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("COLL CELL SELECTED")
        self.view.endEditing(true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        print("width is \(cell.frame.size.width)")
    }
    
    //MARK: - Methods
    @objc func showProjectInfo(_ sender: UIGestureRecognizer){
//        print("Long tap")
        if sender.state == .began {
//            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
            //            print(sender.view)
            
            let tapLocation = sender.location(in: mTableView)
            let indexPath : IndexPath = mTableView.indexPathForRow(at: tapLocation)!
//            print(indexPath.section)
//            print(indexPath.row)
            
            let project = self.fetchedResultsControllerProjects?.object(at: indexPath)
            
            let infoController = ProjectInfoViewController(nibName: "ProjectInfoViewController", bundle: nil)
            infoController.selectedProject = project
            
            fpc.surfaceView.cornerRadius = 6.0
            fpc.surfaceView.shadowHidden = false
            
            fpc.delegate = self
            
            fpc.set(contentViewController: infoController)
            
            fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
            
            fpc.track(scrollView: infoController.scrollView)
            
            self.present(fpc, animated: true, completion: nil)
            
        }
    }
    //MARK: - FLOAT PANEL DELEGATE BEGIN
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return  CustomPanelLayout(parent: self)
    }
    //MARK: - FLOAT PANEL DELEGATE END
    @objc func fetchUpdatedProjects(){
        self.fetchAllProjects()
        self.mTableView.reloadData()
    }
    @objc func showProjects(){
        
//        print("seleted")
        
        if(self.fetchedResultsControllerProjects!.fetchedObjects!.count > 0){
            //show popup
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
            vc.dataSourceType = .PROJECTS
            vc.preferredContentSize = CGSize(width: 250, height: (self.fetchedResultsControllerProjects!.fetchedObjects!.count - 1) * 44)
            
            if(CGFloat((self.fetchedResultsControllerProjects!.fetchedObjects!.count * 44)) > (self.view.frame.size.height - 150)){
                
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
            popOver?.permittedArrowDirections = UIPopoverArrowDirection.down
            vc.tableViewDataSource = self.fetchedResultsControllerProjects!.fetchedObjects!
            
            popOver?.sourceView = projectsButton.mCenterLabelForPopUp
            
            vc.delegate = self
            
            self.present(navigationContoller, animated: true, completion: nil)
        }
    }
    func shouldShowUnitsWithSelectedStatus(selectedStatus: Int) {
        
    }
    func showSelectedTowerFromFloatButton(selectedTower: Towers, selectedBlock: String) {
        
    }
    func didSelectProject(optionType : String,optionIndex: Int){
        
        self.selectedIndexPath = IndexPath.init(row: optionIndex, section: 0) as IndexPath
        let projecct =  self.fetchedResultsControllerProjects!.fetchedObjects![optionIndex] //self.projectsArray[optionIndex]
        
        let urlString = String(format:RRAPI.PROJECT_DETAILS, projecct.id!)
        
        //        let urlString = String(format:RRAPI.PROJECT_DETAILS, optionType)
        selectedProjectID = projecct.id
        showDetailsOfSelectedProject(urlString: urlString)
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    func didFinishTask(optionType: String, optionIndex: Int) {
        
        self.selectedIndexPath = IndexPath.init(row: optionIndex, section: 0)
        let projecct = self.fetchedResultsControllerProjects!.fetchedObjects![optionIndex] //self.projectsArray[optionIndex]
        
        let urlString = String(format:RRAPI.PROJECT_DETAILS, projecct.id!)

//        let urlString = String(format:RRAPI.PROJECT_DETAILS, optionType)
        selectedProjectID = projecct.id
        showDetailsOfSelectedProject(urlString: urlString)
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    func didSelectOptionForUnitsView(selectedIndex: Int) {
        
    }

    func getStatusOfBlocks(indexPath : IndexPath, collIndexPath : IndexPath) -> Dictionary<String, Int>{
        
        let projecct = fetchedResultsControllerProjects!.object(at: indexPath) //self.projectsArray[indexPath.row]
        
            var collectionCellDict : Dictionary<String , Int> = [:]
            
            let statssss : NSMutableOrderedSet = projecct.value(forKey: "proStat") as! NSMutableOrderedSet
//            print("stsaa \(String(describing: statssss))")
            var isStatusAvailable = false
            for temperrr in statssss{
//                print(statssss)
                let tester = temperrr as! TempObj
                
                if(collIndexPath.row == tester.status){
                    isStatusAvailable = true
                    collectionCellDict["count"] = Int(tester.count)
//                    collectionCellDict["status"] = tester.status
//                    collectionCellDict["color"] = UIColor.BOLCK_STATUS_COLOR.vacant
                    break
                }
                
//                print(tester.count)
//                print(tester.status)
            }
            
            if(isStatusAvailable == false){
                collectionCellDict["count"] = 0
//                collectionCellDict["status"] = indexPath.row
            }

            
        return collectionCellDict
        
//        let statssss : NSMutableOrderedSet = projecct.value(forKey: "proStat") as! NSMutableOrderedSet
//        print("stsaa \(String(describing: statssss))")
//
//        var statusDict : Dictionary<String,Any> = [:]
//
//        for temperrr in statssss{
//            print(statssss)
//            let tester = temperrr as! TempObj
//
//            print(tester.count)
//            print(tester.status)
//        }
//        CPU_STATE_USER
    }
    
    func getProjectDetails(urlString : String, completionHandler: @escaping (ProjectDetails?, Error?) -> ()) -> () {
        
        if(RRUtilities.sharedInstance.keychain["Cookie"] == nil){
            RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController)
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
        HUD.show(.labeledProgress(title: "", subtitle: nil))

        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                print("response")
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    completionHandler(nil, nil)
                    return
                }
//                let urlResult = try! JSONDecoder().decode(ProjectDetails11.self, from: responseData)
                
//                 completionHandler(result, nil)
                do{
                    let urlResult = try JSONDecoder().decode(ProjectDetails.self, from: responseData)
                    
                    
                    if(urlResult.blocks != nil && urlResult.towers != nil && urlResult.towers != nil){
                        
                        RRUtilities.sharedInstance.model.writeBlocksToDB(projectDetails: urlResult, projectID: self.selectedProjectID)
                        RRUtilities.sharedInstance.model.writeTowersToDB(projectDetails: urlResult, projectID: self.selectedProjectID)
                        RRUtilities.sharedInstance.model.writeUnitsToDB(projectDetails: urlResult, projectID: self.selectedProjectID)
                        
                    }
                    
                    //                print(urlResult)
                    
                    completionHandler(urlResult, nil)
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,error)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
//                completionHandler(result, nil)
                 completionHandler(nil, error)
//                return result
                break
            }
        }
    }
    @IBAction func showNotifications(_ sender: Any) {
        if(RRUtilities.sharedInstance.model.notificationsCount() == 0){
            HUD.flash(.label("There are no notificatins to show"), delay: 1.0)
            self.updateNotificationCountLabel()
            return
        }
        let notificationsController = NotificationsViewController(nibName: "NotificationsViewController", bundle: nil)
        self.navigationController?.pushViewController(notificationsController, animated: true)
    }
    @objc func updateNotificationCountLabel(){
        let count = RRUtilities.sharedInstance.model.notificationsCount()
        self.notificationsCountLabel.text = String(format: "%d",count)
        if(count > 0){
            self.notificationsCountLabel.isHidden = false
        }else{
            self.notificationsCountLabel.isHidden = true
        }
    }
    @IBAction func getProjects(_ sender: Any) {
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            //** if fetched data is there show that **
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            self.refreshControl?.endRefreshing()
            return
        }
        
        //        print("cookie is \(String(describing: RRUtilities.sharedInstance.keychain["Cookie"]))")
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.labeledProgress(title: "", subtitle: nil))
        AF.request(RRAPI.PROJECTS_URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{
            response in
            switch response.result {
            case .success :
//                print(response)

                do{
//                    print(response)
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(projectsResult.self, from: responseData)
                    
//                    print(urlResult)
                    
                    if(urlResult.status == 1){
                        let isWritten = RRUtilities.sharedInstance.model.writeAllProjectsToDB(projectsArray: urlResult.projects!)
                        self.fetchAllProjects()
                        
                        if(isWritten){
                            
                            self.refreshControl?.endRefreshing()
                            
                            self.mTableView.delegate = self
                            self.mTableView.dataSource = self
                            self.mTableView.reloadData()
                        }
                        HUD.hide()
                        return
                    }
                    else if(urlResult.status == -1){
                        self.showLoginScreenOnAuthFailure()
                        HUD.hide()
                        return
                    }
                    
                    guard let projectsResult : Dictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                    }
                    
                    let status = projectsResult["status"] as! Int
                    
                    if(status == -1){ //Authentication Issue
                        
                        self.showLoginScreenOnAuthFailure()
                        HUD.hide()
                        return
                    }
                    else{
                        
                        self.mTableView.delegate = self
                        self.mTableView.dataSource = self
                        self.mTableView.reloadData()
                        HUD.hide()
                    }
                }
                catch let parseError as NSError {
                                        print("JSON Error \(parseError.localizedDescription)")
                }
                break;
            case .failure(let error):
                HUD.hide()
                HUD.flash(.label(error.localizedDescription), delay: 1.0)
                self.navigationController?.popToRootViewController(animated: true)
                print(error)
            }
        }
    }
    func showDetailsOfSelectedProject(urlString : String){
        
        if(self.projectExist()){
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailsController = storyboard.instantiateViewController(withIdentifier :"ProjectDetails") as! ProjectDetailsViewController
            
            let projecct = fetchedResultsControllerProjects!.object(at: selectedIndexPath)

            detailsController.selectedProject =  projecct
            
            detailsController.projectsArray = self.projectsArray
            self.navigationController?.pushViewController(detailsController, animated: true)

            return
        }
        
        self.getProjectDetails(urlString: urlString,completionHandler: { responseObject, error in
            
//            print("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
            
            if(error == nil){
                //success
                if(responseObject?.status == 1){
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let detailsController = storyboard.instantiateViewController(withIdentifier :"ProjectDetails") as! ProjectDetailsViewController
                    detailsController.projectDetails = responseObject
                    detailsController.selectedProject =  self.fetchedResultsControllerProjects!.object(at: self.selectedIndexPath)
                    //self.projectsArray[self.selectedIndexPath.row]
                    detailsController.projectsArray = self.projectsArray
                    
//                    RRUtilities.sharedInstance.model.writeBlocksToDB(projectDetails: responseObject!)
//                    RRUtilities.sharedInstance.model.writeTowersToDB(projectDetails: responseObject!)
//                    RRUtilities.sharedInstance.model.writeUnitsToDB(projectDetails: responseObject!)

                    self.navigationController?.pushViewController(detailsController, animated: true)

                }
                else if(responseObject?.status == 0){
                    DispatchQueue.main.async {
                        HUD.hide()
//                        HUD.flash(.label("Unit List is Empty!"), delay: 1.5)
                        
                        let alertController = UIAlertController(title: "Empty", message: "This project doesn't have any data.", preferredStyle: .alert)
                        let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                            print("You've pressed default");
                        }
                        alertController.addAction(action1)

                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                else if(responseObject?.status == -1){
                    //show login screren as not authentication
                    self.showLoginScreenOnAuthFailure()
                }
            }
            else{
                
            }
            HUD.hide()
            return
        });
    }
    func projectExist()->Bool{
        
        let request: NSFetchRequest<Units> = Units.fetchRequest()
        request.resultType = NSFetchRequestResultType.countResultType
        
        let projecct = fetchedResultsControllerProjects!.object(at: selectedIndexPath)
        let predicate = NSPredicate(format: "project CONTAINS[c] %@", projecct.id!)
        request.predicate = predicate
        
        do {
            let count = try! RRUtilities.sharedInstance.model.managedObjectContext.count(for: request)
            
            if(count > 0){
//                print(count)
                return true
            }
            else{
                return false
            }
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    func showLoginScreenOnAuthFailure(){
        HUD.flash(.label("Session Expires. Please login again"), delay: 1.0)
        //perform logout
        RRUtilities.sharedInstance.keychain["Cookie"] = nil
        self.navigationController?.popToRootViewController(animated: true)
        // Throw notificationt to show login view
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.SHOWLOGINSCREEN), object: nil)

    }
    
    @IBAction func showReports(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 11.0, *) {
            let preSalesController = storyboard.instantiateViewController(withIdentifier :"webView") as! WebViewController
            preSalesController.isFromReports = true
            self.navigationController?.pushViewController(preSalesController, animated: true)
            return
        } else {
            // Fallback on earlier versions
        }
    }
    @IBAction func showSeachBar(_ sender: Any) {
        searchBar.isHidden = false
        searchBar.delegate = self
        searchButton.isHidden = true
        titleLabel.isHidden = true
        reportsButton.isHidden = true
        notificationsView.isHidden = true
        searchBar.becomeFirstResponder()
    }
    @IBAction func backToHome(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print(searchText)
        var predicate: NSPredicate?
        if searchText.count > 0 {
            predicate = NSPredicate(format: "(name contains[cd] %@)", searchText)
        } else {
            predicate = nil
        }
        
        fetchedResultsControllerProjects!.fetchRequest.predicate = predicate

        do {
            try fetchedResultsControllerProjects!.performFetch()
            mTableView.reloadData()
        } catch let err {
            print(err)
        }
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//        print(selectedScope)
        self.fetchAllProjects()
        mTableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
        // Hide the cancel button
//        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
        searchBar.isHidden = true
        titleLabel.isHidden = false
        searchButton.isHidden = false
        reportsButton.isHidden = false
        notificationsView.isHidden = false
        self.hideKeyBoard()
        self.fetchAllProjects()
        mTableView.reloadData()
    }
    func hideKeyBoard()
    {
        self.view.endEditing(true)
        self.searchBar.endEditing(true)
    }
    //MARK: - popOver
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getEmployess(){
            
            if !RRUtilities.sharedInstance.getNetworkStatus()
            {
                //** if fetched data is there show that **
                HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
                return
            }
            let headers: HTTPHeaders = [
                "User-Agent" : "RErootMobile",
                "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
            ]
//            HUD.show(.progress)

    //        print(RRAPI.GET_EMPLOYEES)
            
            AF.request(RRAPI.GET_EMPLOYEES, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
                response in
                switch response.result {
                case .success( _):
    //                print(response)
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    
                    do{
                        let urlResult = try JSONDecoder().decode(EMPLOYEES.self, from: responseData)
                        
                        if(urlResult.status == -1 ){
                            RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController)
                            HUD.hide()
                            return
                        }
                        else{
                        
                            let isWritten = RRUtilities.sharedInstance.model.writeEmployeeDataToDB(employees: urlResult.users!)
                            if(isWritten){
                                print("Saved VEHICLES TO DB")
                            }
                            else{
                                print("FAILED TO WRITE VEHICLES To DB")
                            }
                        }
//                        HUD.hide()
                    }
                    catch let error{
//                        HUD.hide()
//                        HUD.flash(.label(error.localizedDescription))
                    }
                    // make tableview data
                    break
                case .failure(let error):
//                    print(error)
//                    HUD.hide()
//                    HUD.flash(.label(error.localizedDescription))
                    break
                }
            }
        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension ProjectsViewController  : NSFetchedResultsControllerDelegate{

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        /*This delegate method will be called first.As the name of this method "controllerWillChangeContent" suggets write some logic for table view to initiate insert row or delete row or update row process. After beginUpdates method the next call will be for :

         - (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath

         */
        print("A. NSFetchResultController controllerWillChangeContent :)")
        self.mTableView.beginUpdates()
    }

    /*This delegate method will be called second. This method will give information about what operation exactly started taking place a insert, a update, a delete or a move. The enum NSFetchedResultsChangeType will provide the change types.


     public enum NSFetchedResultsChangeType : UInt {

     case insert

     case delete

     case move

     case update
     }

     */
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        print("B. NSFetchResultController didChange NSFetchedResultsChangeType \(type.rawValue):)")
    }

    /*The last delegate call*/
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.mTableView.endUpdates()
    }
}

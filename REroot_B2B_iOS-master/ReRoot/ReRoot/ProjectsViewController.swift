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


class ProjectsViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout,UIPopoverPresentationControllerDelegate,HidePopUp,UISearchBarDelegate{
    
    var refreshControl: UIRefreshControl?
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var titleView: UIView!
    @IBOutlet var mTableView: UITableView!
    var projectsArray : Array<Project> = []
    var currentProjectsArray : Array<Project> = []
    
    var mCollectionViewDataSource : Array<STAT> = []
    var projectsButton : ButtonView!
    var selectedIndexPath : NSIndexPath!
    
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

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false

        let nib = UINib(nibName: "ProjectDetailsTableViewCell", bundle: nil)
        mTableView.register(nib, forCellReuseIdentifier: "projectCell")
        mTableView.tableFooterView = UIView()
        
        projectsButton = ButtonView.instanceFromNib() as? ButtonView
        projectsButton.backgroundColor = UIColor.white
        self.view.addSubview(projectsButton)
        
        projectsButton.mTitleLabel?.text = "PROJECTS"
        
        self.getProjects(UIButton())
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
        
        let numOfRows: Int = self.currentProjectsArray.count

        if (numOfRows > 0)
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
        
        return numOfRows //self.currentProjectsArray.count //RRUtilities.sharedInstance.model.getProjectsCount()  //projectsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProjectDetailsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "projectCell",
            for: indexPath) as! ProjectDetailsTableViewCell
        
//        cell.mCollectinView.register(BlockInfoCollectionViewCell.self, forCellWithReuseIdentifier: "blockCell")

        cell.mCollectinView.delegate = self;
        cell.mCollectinView.dataSource = self;
        cell.mCollectinView.mParentIndexPath = indexPath
        
//        cell.mCollectinView.layoutIfNeeded()
//
//        print(cell.mCollectinView)
        
        let projecct = self.currentProjectsArray[indexPath.row]
        
        cell.projectNameLabel.text = projecct.name?.uppercased()
        cell.cityNameLabel.text = projecct.city?.uppercased()
//        cell.mParentIndexPath = indexPath as NSIndexPath
                
//        cell.mImageView.sd_setImage(with: projecct.imagesTemp?[0], placeholderImage: nil, options: .SDWebImageRetryFailed, completed: nil)
        
        if((projecct.imagesTemp?.count)! > 0){
//            print(indexPath.row)
//            print("IMage URL \(String(describing: projecct.imagesTemp?[0]))")
            let urlString : String = (projecct.imagesTemp?[0])!
                //.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
//            cell.mImageView.sd_setImage(with: URL(string:urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!), placeholderImage: UIImage(named: "project_image_default"))
            
//            cell.mImageView.sd_setImage(with: URL(string:urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!), placeholderImage:UIImage(named: "placeholder.png"))

            
//            cell.mImageView.af_setImage(withURL: urlString)
//            print(URL(string: (projecct.imagesTemp?[0])!))
//            cell.mImageView.sd_setImage(with: URL(string: (projecct.imagesTemp?[0])!), placeholderImage: UIImage(named: "placeholder.png"), options:SDWebImageOptions(rawValue: 5), completed: nil)
            
            cell.mImageView.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "project_image_default"), options:[.highPriority])
        }
        else{
            cell.mImageView.image = UIImage(named: "project_image_default")
        }
        cell.mImageView.clipsToBounds = true
        cell.mImageView.layer.cornerRadius = 8.0
//        cell.mImageView.layer.masksToBounds = true
        
        cell.mSubContentView.bringSubviewToFront(cell.projectNameLabel)
        cell.mSubContentView.bringSubviewToFront(cell.cityNameLabel)
        cell.mSubContentView.layer.cornerRadius = 8.0
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
        selectedIndexPath = indexPath as NSIndexPath
        let projecct = self.currentProjectsArray[indexPath.row]

        let urlString = String(format:RRAPI.PROJECT_DETAILS, projecct.id!)
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
        return 5 //** Statuses
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let tempCollectionView = collectionView as! CustomCollectionView
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "blockCell", for: indexPath) as! BlockInfoCollectionViewCell
        
//        print("row is \(tempCollectionView.mParentIndexPath.row)")
        
//        let projecct = self.projectsArray[tempCollectionView.mParentIndexPath.row]
        
//        let statssss : NSMutableOrderedSet = projecct.value(forKey: "proStat") as! NSMutableOrderedSet

        let statucColorDict  = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: indexPath.row)
        
//        cell.mSubContentView.backgroundColor = statucColorDict["color"] as? UIColor
        cell.mStatusTypeLabel.text = statucColorDict["statusString"] as? String
        cell.mStatusTypeLabel.textColor = UIColor.lightGray
        let tempCountDict =  self.getStatusOfBlocks(indexPath: tempCollectionView.mParentIndexPath as NSIndexPath,collIndexPath: indexPath as NSIndexPath)
//        cell.mStatusTypeNumberLabel.text = String(tempCountDict["count"]! as! Int)
        
        cell.mStatusTypeNumberLabel.text =  String(format:"%d", tempCountDict["count"]!)
        cell.mStatusTypeNumberLabel.textColor = statucColorDict["color"] as? UIColor
        cell.mStatusTypeLabel.preferredMaxLayoutWidth = 50;

        return cell
        
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
//        return CGSize.init(width: 20, height: 70)
//    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("COLL CELL SELECTED")
        self.view.endEditing(true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        print("width is \(cell.frame.size.width)")
    }
    
    //MARK: - Methods
    @objc func fetchUpdatedProjects(){
        
        self.projectsArray = RRUtilities.sharedInstance.model.getAllProjects()
        self.currentProjectsArray = self.projectsArray
        
        self.mTableView.reloadData()
    }
    @objc func showProjects(){
        
//        print("seleted")
        if(self.projectsArray.count > 0){
            //show popup
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
            vc.dataSourceType = .PROJECTS
            vc.preferredContentSize = CGSize(width: 250, height: self.projectsArray.count * 44)
            
            if(CGFloat((self.projectsArray.count * 44)) > (self.view.frame.size.height - 150)){
                
                vc.preferredContentSize = CGSize(width: 250, height: (self.view.frame.size.height - 150))
            }

            
            let navigationContoller = UINavigationController(rootViewController: vc)
            navigationContoller.navigationBar.isHidden = true
            navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
            
            let popOver =  navigationContoller.popoverPresentationController
            popOver?.delegate = self
            popOver?.permittedArrowDirections = UIPopoverArrowDirection.down
            vc.tableViewDataSource = self.projectsArray
            //        popOver?.barButtonItem = sender as? UIBarButtonItem
            
            popOver?.sourceView = projectsButton.mCenterLabelForPopUp
            
//            popOver?.sourceRect = CGRect(x: self.view.center.x, y: projectsButton.frame.origin.y - 80, width: projectsButton.frame.size.width, height: projectsButton.frame.size.height)
//            popOver?.sourceView?.frame.origin.x = self.view.center.x
            vc.delegate = self
            //        popOver?.sourceRect = optionsButton.frame
            
            self.present(navigationContoller, animated: true, completion: nil)
        }
    }
    func shouldShowUnitsWithSelectedStatus(selectedStatus: Int) {
        
    }
    func showSelectedTowerFromFloatButton(selectedTower: TOWERDETAILS, selectedBlock: String) {
        
    }
    func didSelectProject(optionType : String,optionIndex: Int){
        
        self.selectedIndexPath = NSIndexPath.init(row: optionIndex, section: 0)
        let projecct = self.projectsArray[optionIndex]
        
        let urlString = String(format:RRAPI.PROJECT_DETAILS, projecct.id!)
        
        //        let urlString = String(format:RRAPI.PROJECT_DETAILS, optionType)
        
        showDetailsOfSelectedProject(urlString: urlString)
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    func didFinishTask(optionType: String, optionIndex: Int) {
        
        self.selectedIndexPath = NSIndexPath.init(row: optionIndex, section: 0)
        let projecct = self.projectsArray[optionIndex]
        
        let urlString = String(format:RRAPI.PROJECT_DETAILS, projecct.id!)

//        let urlString = String(format:RRAPI.PROJECT_DETAILS, optionType)
        
        showDetailsOfSelectedProject(urlString: urlString)
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    func didSelectOptionForUnitsView(selectedIndex: Int) {
        
    }

    func getStatusOfBlocks(indexPath : NSIndexPath, collIndexPath : NSIndexPath) -> Dictionary<String, Int>{
        
        let projecct = self.projectsArray[indexPath.row]
        
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
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    completionHandler(nil, nil)
                    return
                }
                let urlResult = try! JSONDecoder().decode(ProjectDetails.self, from: responseData)
                
//                print(urlResult)

                completionHandler(urlResult, nil)
//                 completionHandler(result, nil)
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
        Alamofire.request(RRAPI.PROJECTS_URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{
            response in
            switch response.result {
            case .success :
//                print(response)

                do{
                    print(response)
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try! JSONDecoder().decode(projectsResult.self, from: responseData)
                    
//                    print(urlResult)
                    
                    if(urlResult.status == 1){
                        let isWritten = RRUtilities.sharedInstance.model.writeAllProjectsToDB(projectsArray: urlResult.projects!)
                        
                        if(isWritten){
                            
                            self.projectsArray.removeAll()
                            self.currentProjectsArray.removeAll()
                            
                            self.projectsArray = RRUtilities.sharedInstance.model.getAllProjects()
                            self.currentProjectsArray = self.projectsArray
//                            print(self.projectsArray)
                            
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
                    
                    //                    print(projectsResult)
                    let status = projectsResult["status"] as! Int
                    
                    if(status == -1){ //Authentication Issue
                        
                        self.showLoginScreenOnAuthFailure()
                        HUD.hide()
                        return
                    }
                    else{
                        
                        //                        self.projectsArray = projectsResult["projects"] as! Array<Any>
                        //
                        //                        print(self.projectsArray)
                        //
                        //                        for projectDict in self.projectsArray{
                        //                            let tempDict : Dictionary<String,Any> = projectDict as! Dictionary<String,Any>
                        //                            print("name \(tempDict["name"])")
                        //                        }
                        
                        self.mTableView.delegate = self
                        self.mTableView.dataSource = self
                        self.mTableView.reloadData()
                        HUD.hide()
                    }
                }
                catch let parseError as NSError {
                                        print("JSON Error \(parseError.localizedDescription)")
                }
                
                //                let urlResult = try! JSONDecoder().decode(otpResult.self, from: responseData)
                //
                //                print(urlResult)
                //
                //                if(urlResult.status == 0){
                //                    HUD.flash(.label("Invalid Email ID"), delay: 1.0)
                //                    return
                //                }
                //                else{
                //                    HUD.flash(.label("OTP Sent Successfully"), delay: 1.0)
                //                }
                
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
        
        self.getProjectDetails(urlString: urlString,completionHandler: { responseObject, error in
            
//            print("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
            
            if(error == nil){
                //success
                if(responseObject?.status == 1){
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let detailsController = storyboard.instantiateViewController(withIdentifier :"ProjectDetails") as! ProjectDetailsViewController
                    detailsController.projectDetails = responseObject
                    detailsController.selectedProject = self.projectsArray[self.selectedIndexPath.row]
                    detailsController.projectsArray = self.projectsArray
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
    func showLoginScreenOnAuthFailure(){
        HUD.flash(.label("Session Expires. Please login again"), delay: 1.0)
        //perform logout
        RRUtilities.sharedInstance.keychain["Cookie"] = nil
        self.navigationController?.popToRootViewController(animated: true)
        // Throw notificationt to show login view
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.SHOWLOGINSCREEN), object: nil)

    }
    
    @IBAction func showSeachBar(_ sender: Any) {
        searchBar.isHidden = false
        searchBar.delegate = self
        searchButton.isHidden = true
        titleLabel.isHidden = true
        searchBar.becomeFirstResponder()
    }
    @IBAction func backToHome(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        currentProjectsArray = projectsArray.filter({ Project -> Bool in
            switch searchBar.selectedScopeButtonIndex {
            case 0:
                if searchText.isEmpty { return true }
                return Project.name!.lowercased().contains(searchText.lowercased())
            default:
                return false
            }
        })
        self.mTableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(selectedScope)
        switch selectedScope {
        case 0:
            currentProjectsArray = projectsArray
        default:
            break
        }
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
        self.hideKeyBoard()
        self.currentProjectsArray = self.projectsArray
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}



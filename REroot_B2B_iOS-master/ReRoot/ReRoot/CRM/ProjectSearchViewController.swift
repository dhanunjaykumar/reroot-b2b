//
//  ProjectSearchViewController.swift
//  REroot
//
//  Created by Dhanunjay on 21/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import PKHUD

struct AGREEMENT_TYPE_STRINGS  {
    let saleAgreement = "SALE AGREEMENT"
    let assignmentAgreemetn = "ASSIGNMENT AGREEMENT"
}

class ProjectSearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    @IBOutlet weak var heightOfProjectInfoLabel: NSLayoutConstraint!
    @IBOutlet weak var projectInfoLabel: UILabel!
    
    var selectedProject : Project!
    var selectedUnit : Units!
    var selectedClient : String!
    
    var agreementType : Int = -1
    
    var didSelectId: ((String?,String?) -> Void)?
    
    var isBlockOrRelease : Bool = false
    var isReserve : Bool = false
    
    // *** OUTSTANIDING RELATED **
    
    var isOutStanding : Bool = false
    var shouldShowBlocks : Bool = false
    var shouldShowTowers : Bool = false
    var shouldShowProjects : Bool = false
    var selectedUnitId : String!
    var selectedBlockId : String!
    var selectedTowerId : String!
    
//    var selectedProjectId : String! // ** To get blocks, towers, units
    
    // *** OUTSTANIDING RELATED ***
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var selectedPathInfoLabel: UILabel!
    
    @IBOutlet var heightOfHorizantalLine: NSLayoutConstraint!
    @IBOutlet var heightOfUnitDetailsLabel: NSLayoutConstraint!
    var reservationsDataSource : [RESERVED_UNITS]!
    var reserveDataSourceForSearch : [RESERVED_UNITS] = []
    
    var bookedClientsDataSource : [BOOKED_CLIENTS]!
    var bookedClientDataSourceForSearch : [BOOKED_CLIENTS] = []
    
    @IBOutlet var titleLabel: UILabel!
    var fetchedResultsControllerProjects:NSFetchedResultsController<Project>?
    var fetchedResultsControllerUnits : NSFetchedResultsController<Units>!
    var fetchedResultsControllerBlocks : NSFetchedResultsController<Blocks>!
    var fetchedResultsControllerTowers : NSFetchedResultsController<Towers>!


    var showingProjects : Bool = true
    var shouldShowUnits : Bool = false
    var shouldShowClients : Bool = false
    
    var searchText = ""
    
    @IBOutlet var titleView: UIView!
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.configureView()
        
    }
    
    func configureView(){
        //projectNameCell
        
        if(!self.isOutStanding){
            self.heightOfProjectInfoLabel.constant = 0
            self.projectInfoLabel.isHidden = true
        }
        else{
            self.heightOfProjectInfoLabel.constant = 40
            self.projectInfoLabel.isHidden = false
        }
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.black

        let attributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-Medium", size: 14.0), NSAttributedString.Key.foregroundColor: UIColor.black]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attributes as [NSAttributedString.Key : Any]

        NotificationCenter.default.addObserver(self, selector: #selector(setUpControllerOnBackFromSuccessor), name: NSNotification.Name("handleBack"), object: nil)

        heightOfUnitDetailsLabel.constant = 0
        heightOfHorizantalLine.constant = 0
        var font = UIFont(name: "Montserrat-Bold", size: 11.0)
        
        if(UIDevice.current.screenType == .iPhones_5_5s_5c_SE || UIDevice.current.screenType == .iPhones_4_4S){
            font = UIFont(name: "Montserrat-Bold", size: 11.0)
        }
        else{
            font = UIFont(name: "Montserrat-Bold", size: 12.0)
        }
        
        titleLabel.text = "SELECT PROJECT - RECEIPT ENTRY"
        
        searchBar.placeholder = "Search for Project"

        if(agreementType == AGREEMENT_TYPES.Sales_Agreement){
            titleLabel.text = "SELECT PROJECT - SALE AGREEMENT"
        }
        else if(agreementType == AGREEMENT_TYPES.Assigment_Agreement){
            titleLabel.text = "SELECT PROJECT - ASSIGNMENT AGREEMENT"
        }
        else if(isBlockOrRelease){
            titleLabel.text = "SELECT PROJECT - BLOCK/RELEASE UNIT"
        }
        else if(isOutStanding){
            if(shouldShowBlocks){
                titleLabel.text = "SELECT BLOCK"
                self.searchBar.placeholder = "search block"
                self.projectInfoLabel.text = self.selectedProject.name
            }
            else if(shouldShowTowers){
                titleLabel.text = "SELECT TOWER"
                self.searchBar.placeholder = "search tower"
                let block =  RRUtilities.sharedInstance.model.getSelectedBlockDetailsByBlockId(blockID: self.selectedBlockId)
                self.projectInfoLabel.text = String(format: "%@ - %@ - %@", self.selectedProject.name ?? "",block?.name ?? "")
            }
            else if(shouldShowProjects){
                titleLabel.text = "SELECT PROJECT"
                self.searchBar.placeholder = "search project"
                self.heightOfProjectInfoLabel.constant = 0
                self.projectInfoLabel.isHidden = true
            }
            else if(shouldShowUnits){
                titleLabel.text = "SELECT UNIT"
                self.searchBar.placeholder = "search unit / description"
                let block =  RRUtilities.sharedInstance.model.getSelectedBlockDetailsByBlockId(blockID: self.selectedBlockId)
                let tower = RRUtilities.sharedInstance.model.getSelectedTowerDetailsByTowerId(towerId: self.selectedTowerId)
                if let unit = self.selectedUnit{
                    self.projectInfoLabel.text = String(format: "%@ - %@ - %@ - %@", self.selectedProject.name ?? "",block?.name ?? "",tower?.name ?? "",unit.unitDisplayName ?? "")
                }
                else{
                    self.projectInfoLabel.text = String(format: "%@ - %@ - %@", self.selectedProject.name ?? "",block?.name ?? "",tower?.name ?? "")
                }
            }
        }
        else if(isReserve){
            titleLabel.text = "SELECT PROJECT - RESERVE UNIT"
        }
        
        titleLabel.font = font
       
        searchBar.delegate = self
        
//        selectedPathInfoLabel.text = selectedProject.name
        
        let nib = UINib(nibName: "ProjectNameTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "projectNameCell")
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.estimatedRowHeight = 51
        self.tableView.rowHeight = UITableView.automaticDimension
        
        if(isOutStanding){
            if(shouldShowBlocks){
                self.fetchBlocksForProject(projectId: selectedProject.id ?? "")
            }
            else if(shouldShowTowers){
                self.fetchTowersForProject(projectId: selectedProject.id ?? "")
            }
            else if(shouldShowUnits){
                self.fetchUnits(shouldFetch: true)
            }
            else{
                self.fetchProjects()
            }
        }
        else{
            self.fetchProjects()
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    func fetchUnits(shouldFetch : Bool){

        if(shouldFetch && RRUtilities.sharedInstance.model.getUnitsCountForProject(projectId: selectedProject.id!) == 0){
            let urlString = String(format:RRAPI.PROJECT_DETAILS, selectedProject.id!)
            self.getSelectedProjectDetails(urlString: urlString)
            return
        }
        
        let request: NSFetchRequest<Units> = Units.fetchRequest()
        let sort1 = NSSortDescriptor(key: #keyPath(Units.floorIndex), ascending: true)
        let sort = NSSortDescriptor(key: #keyPath(Units.unitIndex), ascending: true)
        request.sortDescriptors = [sort1,sort]
        
        var predicate = NSPredicate(format: "project CONTAINS[c] %@ AND (status == %d OR status == %d OR status == %d)", selectedProject.id!,UNIT_STATUS.BOOKED.rawValue,UNIT_STATUS.RESERVED.rawValue,UNIT_STATUS.SOLD.rawValue)
        
        
        if(searchText.count > 0){
            if(self.isOutStanding){
                if let towerID = self.selectedTowerId{
                    predicate = NSPredicate(format: "project CONTAINS[c] %@ AND (status == %d OR status == %d OR status == %d) AND description1 CONTAINS[c] %@ AND tower == %@", selectedProject.id!,UNIT_STATUS.BOOKED.rawValue,UNIT_STATUS.RESERVED.rawValue,UNIT_STATUS.SOLD.rawValue,searchText,towerID)
                }
            }
            else{
                predicate = NSPredicate(format: "project CONTAINS[c] %@ AND (status == %d OR status == %d OR status == %d) AND description1 CONTAINS[c] %@", selectedProject.id!,UNIT_STATUS.BOOKED.rawValue,UNIT_STATUS.RESERVED.rawValue,UNIT_STATUS.SOLD.rawValue,searchText)
            }
        }
        
        if(agreementType > 0){
            predicate = NSPredicate(format: "project CONTAINS[c] %@ AND (status == %d OR status == %d)", selectedProject.id!,UNIT_STATUS.BOOKED.rawValue,UNIT_STATUS.SOLD.rawValue)
            if(searchText.count > 0){
                predicate = NSPredicate(format: "project CONTAINS[c] %@ AND (status == %d OR status == %d) AND description1 CONTAINS[c] %@", selectedProject.id!,UNIT_STATUS.BOOKED.rawValue,UNIT_STATUS.SOLD.rawValue,searchText)
            }
        }
        else if(isBlockOrRelease){
            predicate = NSPredicate(format: "project CONTAINS[c] %@ AND (status == %d OR status == %d)", selectedProject.id!,UNIT_STATUS.VACANT.rawValue,UNIT_STATUS.BLOCKED.rawValue)
            if(searchText.count > 0){
                predicate = NSPredicate(format: "project CONTAINS[c] %@ AND (status == %d OR status == %d) AND description1 CONTAINS[c] %@", selectedProject.id!,UNIT_STATUS.VACANT.rawValue,UNIT_STATUS.BLOCKED.rawValue,searchText)
            }
        }
        else if(isReserve){
            predicate = NSPredicate(format: "project CONTAINS[c] %@ AND (status == %d OR status == %d)", selectedProject.id!,UNIT_STATUS.VACANT.rawValue,UNIT_STATUS.RESERVED.rawValue)
            if(searchText.count > 0){
                predicate = NSPredicate(format: "project CONTAINS[c] %@ AND (status == %d OR status == %d) AND description1 CONTAINS[c] %@", selectedProject.id!,UNIT_STATUS.VACANT.rawValue,UNIT_STATUS.RESERVED.rawValue,searchText)
            }
        }
        
        request.predicate = predicate
        
        fetchedResultsControllerUnits = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        
        do {
            try fetchedResultsControllerUnits.performFetch()
            self.tableView.reloadData()
        }
        catch {
            fatalError("Error in fetching records")
        }
        self.tableView.separatorStyle = .none
        self.tableView.separatorStyle = .singleLine
    }
    func fetchProjects(){
        
        if(RRUtilities.sharedInstance.model.getProjectsCount() == 0){
            self.getProjects(UIButton())
        }
        else{
            let request: NSFetchRequest<Project> = Project.fetchRequest()
            let sort = NSSortDescriptor(key: #keyPath(Project.name), ascending: true)
            request.sortDescriptors = [sort]
            
            fetchedResultsControllerProjects = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
            
            do {
                try fetchedResultsControllerProjects?.performFetch()
                self.tableView.reloadData()
            }
            catch {
                fatalError("Error in fetching records")
            }
        }
        self.tableView.separatorStyle = .none
        self.tableView.separatorStyle = .singleLine
    }
    func fetchBlocksForProject(projectId : String){
            
        if(RRUtilities.sharedInstance.model.getUnitsCountForProject(projectId: selectedProject.id!) == 0){
            let urlString = String(format:RRAPI.PROJECT_DETAILS, selectedProject.id!)
            self.getSelectedProjectDetails(urlString: urlString)
            return
        }
        
        let request: NSFetchRequest<Blocks> = Blocks.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Blocks.project), ascending: true)
        request.sortDescriptors = [sort]
        if(self.searchText.count > 0){
            request.predicate = NSPredicate(format: "project == %@ AND name CONTAINS[c] %@", projectId,self.searchText)
        }
        else{
            request.predicate = NSPredicate(format: "project == %@", projectId)
        }
        
        fetchedResultsControllerBlocks = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        
        do {
            try fetchedResultsControllerBlocks?.performFetch()
            self.tableView.reloadData()
        }
        catch {
            fatalError("Error in fetching records")
        }
        
    }
    func fetchTowersForProject(projectId : String){
        if(RRUtilities.sharedInstance.model.getUnitsCountForProject(projectId: selectedProject.id!) == 0){
            let urlString = String(format:RRAPI.PROJECT_DETAILS, selectedProject.id!)
            self.getSelectedProjectDetails(urlString: urlString)
            return
        }
        self.fetchUnits(shouldFetch: true)
        let request: NSFetchRequest<Towers> = Towers.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Towers.project), ascending: true)
        request.sortDescriptors = [sort]
        
        if(self.searchText.count > 0){
            request.predicate = NSPredicate(format: "project == %@ AND name CONTAINS[c] %@", projectId,self.searchText)
        }
        else{
            request.predicate = NSPredicate(format: "project == %@ AND block == %@", projectId,self.selectedBlockId)
        }
        fetchedResultsControllerTowers = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        
        do {
            try fetchedResultsControllerTowers?.performFetch()
            self.tableView.reloadData()
        }
        catch {
            fatalError("Error in fetching records")
        }
        
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
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success :
                
                //                print(response)
                
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                let urlResult = try! JSONDecoder().decode(ProjectDetails.self, from: responseData)
                
                if(urlResult.blocks == nil || urlResult.towers == nil || urlResult.units == nil || urlResult.units?.count == 0 || urlResult.towers?.count == 0){
                    HUD.hide()
                    
                    let alertController = UIAlertController(title: "Empty", message: "This project doesn't have any data.", preferredStyle: .alert)
                    let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                        print("You've pressed default");
                    }
                    alertController.addAction(action1)
                    
                    self.shouldShowUnits = false
                    self.shouldShowClients = false
                    self.fetchProjects()
                    self.tableView.reloadData()
                    self.selectedProject = nil
                    self.selectedPathInfoLabel.text = ""
                    if(self.selectedUnit == nil && (self.isReserve || self.isBlockOrRelease)){
                        self.popController()
                    }

                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                if(self.selectedProject.id != nil){
                    RRUtilities.sharedInstance.model.writeUnitsToDB(projectDetails: urlResult, projectID: self.selectedProject.id!)
                    RRUtilities.sharedInstance.model.writeBlocksToDB(projectDetails: urlResult, projectID: self.selectedProject.id!)
                    RRUtilities.sharedInstance.model.writeTowersToDB(projectDetails: urlResult, projectID: self.selectedProject.id!)
                    sleep(2)
                    if(self.isOutStanding)
                    {
                        if(self.shouldShowBlocks){
                            self.fetchBlocksForProject(projectId: self.selectedProject.id!)
                        }
                        else if(self.shouldShowTowers){
                            self.fetchTowersForProject(projectId: self.selectedProject.id!)
                        }
                        else if(self.shouldShowUnits){
                            self.fetchUnits(shouldFetch: false)
                        }
                    }
                    else{
                        self.fetchUnits(shouldFetch: false)
                    }
                }
                
                HUD.hide()
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
            }
        }
    }
    @IBAction func getProjects(_ sender: Any) {
        
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
        HUD.show(.labeledProgress(title: "", subtitle: nil))
        
        AF.request(RRAPI.PROJECTS_URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{
            response in
            switch response.result {
            case .success :
                //                print(response)
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(projectsResult.self, from: responseData)
                    
                    HUD.hide()

                    if(urlResult.status == 1){
                        let isWritten = RRUtilities.sharedInstance.model.writeAllProjectsToDB(projectsArray: urlResult.projects!)
                    
                        if(isWritten){
                            self.fetchProjects()
                        }
                        return
                    }
                    else if(urlResult.status == -1){
//                        RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                        return
                    }
                }
                catch let parseError as NSError {
                    print("JSON Error \(parseError.localizedDescription)")
                }
                break;
            case .failure(let error):
                HUD.hide()
                HUD.flash(.label(error.localizedDescription), delay: 1.0)
                print(error)
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        
        if(self.isOutStanding){
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if(selectedClient != nil){
            
            return
        }
        if(selectedUnit != nil){
            
            if(agreementType == AGREEMENT_TYPES.Sales_Agreement){
                titleLabel.text = "SELECT UNIT - SALE AGREEMENT"
            }
            else if(agreementType == AGREEMENT_TYPES.Assigment_Agreement){
                titleLabel.text = "SELECT UNIT - ASSIGNMENT AGREEMENT"
            }
            else if(isBlockOrRelease){
                titleLabel.text = "SELECT UNIT - BLOCK/RELEASE UNIT"
            }
            else if(isReserve){
                titleLabel.text = "SELECT UNIT - RESERVE UNIT"
            }
            else{
                titleLabel.text = "SELECT UNIT - RECEIPT ENTRY"
            }

            self.shouldShowClients = false
            self.shouldShowUnits = true
            self.fetchUnits(shouldFetch: true)
            self.tableView.reloadData()
            selectedUnit = nil
            selectedPathInfoLabel.text = selectedProject.name
            
            return
        }
        
        if(selectedProject != nil){
            self.shouldShowUnits = false
            self.shouldShowClients = false
            self.fetchProjects()
            self.tableView.reloadData()
            selectedProject = nil
            selectedPathInfoLabel.text = ""
            if(selectedUnit == nil && (isReserve || isBlockOrRelease)){
                self.popController()
            }
            return
        }
        self.popController()
    }
    @objc func setUpControllerOnBackFromSuccessor(){
        self.shouldShowClients = false
        self.shouldShowUnits = true
        self.fetchUnits(shouldFetch: true)
        self.tableView.reloadData()
        selectedUnit = nil
        selectedPathInfoLabel.text = selectedProject.name
    }
    func popController(){
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //        print(searchText)
        
        if(searchText == ""){
            DispatchQueue.main.async {
                self.restoreView()
                self.searchBar.endEditing(true)
                self.view.endEditing(true)
            }
            return
        }

        if(selectedProject == nil){
            var predicate: NSPredicate?
            if searchText.count > 0 {
                predicate = NSPredicate(format: "(name contains[cd] %@)", searchText)
            } else {
                predicate = nil
            }
            
            let request: NSFetchRequest<Project> = Project.fetchRequest()
            let sort = NSSortDescriptor(key: #keyPath(Project.name), ascending: true)
            request.sortDescriptors = [sort]
            request.predicate = predicate
            
            fetchedResultsControllerProjects = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
            
            do {
                try fetchedResultsControllerProjects!.performFetch()
                self.tableView.reloadData()
            } catch let err {
                print(err)
            }

        }
        else if(self.shouldShowBlocks){
            self.searchText = searchText
            self.fetchBlocksForProject(projectId: self.selectedProject.id!)
            self.tableView.reloadData()
        }
        else if(self.shouldShowTowers){
            self.searchText = searchText
            self.fetchTowersForProject(projectId: self.selectedProject.id!)
            self.tableView.reloadData()
        }
        else if(self.shouldShowUnits){
            
            var predicate: NSPredicate?
            if searchText.count > 0 {
                predicate = NSPredicate(format: "description1 CONTAINS[c] %@", searchText)
            } else {
                predicate = nil
            }
//            fetchedResultsControllerUnits!.fetchRequest.predicate = predicate
            
            self.searchText = searchText
            self.fetchUnits(shouldFetch: true)
            self.tableView.reloadData()

//            do {
//                try fetchedResultsControllerUnits!.performFetch()
//                tableView.reloadData()
//            } catch let err {
//                print(err)
//            }
        }
        else if(self.shouldShowClients){
            if(selectedUnit.status == UNIT_STATUS.RESERVED.rawValue){
                //($0.tower?.localizedCaseInsensitiveContains(tower._id!))
                self.reservationsDataSource = self.reserveDataSourceForSearch.filter { (($0.prospect?.userName!.localizedCaseInsensitiveContains(searchText))!) }
                tableView.reloadData()
            }
            else{
                self.bookedClientsDataSource = self.bookedClientDataSourceForSearch.filter {(($0.customer?.name!.localizedCaseInsensitiveContains(searchText))!) }
                tableView.reloadData()
            }
            self.tableView.separatorStyle = .none
            self.tableView.separatorStyle = .singleLine
        }
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.restoreView()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        self.restoreView()
        searchBar.text = ""
        self.view.endEditing(true)
        self.searchBar.endEditing(true)
        // Hide the cancel button
        //        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
        
    }
    func restoreSearchBox(){
        
        self.searchBar.text = ""
        self.searchText = ""
//        self.searchBar.resignFirstResponder()
        if(selectedProject == nil){
            self.searchBar.placeholder = "Search project"
        }
        else if(self.shouldShowUnits){
            self.searchBar.placeholder = "Search Unit"
        }
        else if(self.shouldShowClients){
            self.searchBar.placeholder = "Search Client"
        }
        else if(self.shouldShowBlocks){
            self.searchBar.placeholder = "Search Block"
        }
        else if(self.shouldShowTowers){
            self.searchBar.placeholder = "Search Tower"
        }

    }
    func restoreView(){
        self.searchBar.text = ""
        self.searchText = ""
        if(selectedProject == nil){
            self.searchBar.placeholder = "Search project"
            self.fetchProjects()
        }
        else if(self.shouldShowBlocks){
            self.searchBar.placeholder = "Search Block"
            self.fetchBlocksForProject(projectId: self.selectedProject.id!)
        }
        else if(self.shouldShowTowers){
            self.searchBar.placeholder = "Search Tower"
            self.fetchTowersForProject(projectId: self.selectedProject.id!)
        }
        else if(self.shouldShowUnits){
            self.searchBar.placeholder = "Search Unit"
            self.fetchUnits(shouldFetch: true)
        }
        else if(self.shouldShowClients){
            self.searchBar.placeholder = "Search Client"
            if(selectedUnit.status == UNIT_STATUS.RESERVED.rawValue){
                self.reservationsDataSource = self.reserveDataSourceForSearch
            }
            else{
                self.bookedClientsDataSource = self.bookedClientDataSourceForSearch
            }
        }
        self.tableView.reloadData()
    }
    //MARK: - Tableview Delegate & DataSource
    func updateNoDataLabel(isUnits : Bool){
        
        let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        noDataLabel.text = "No data available"
        if(isUnits){
            noDataLabel.text = "No data available"  //"No Resreved/Booked/Sold Units available"
        }
        else{
            if(selectedProject == nil){
                noDataLabel.text = "Project not found"
            }
            else if(selectedUnit == nil){
                noDataLabel.text = "Unit not found"
            }
            else{
                noDataLabel.text = "Clients not found"
            }
        }
        noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
        noDataLabel.textColor     = UIColor.black
        noDataLabel.textAlignment = .center
        tableView.backgroundView  = noDataLabel
        tableView.separatorStyle  = .none
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(shouldShowUnits){
            if ((fetchedResultsControllerUnits?.fetchedObjects?.count ?? 0) > 0)
            {
                tableView.backgroundView = nil
            }
            else
            {
                self.updateNoDataLabel(isUnits: shouldShowUnits)
            }
            return (fetchedResultsControllerUnits?.fetchedObjects?.count ?? 0)
        }
        else if(shouldShowBlocks){
            if ((fetchedResultsControllerBlocks?.fetchedObjects?.count ?? 0) > 0)
            {
                tableView.backgroundView = nil
            }
            else
            {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text = "No data available"
                noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
                noDataLabel.textColor     = UIColor.black
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
            return (fetchedResultsControllerBlocks?.fetchedObjects?.count ?? 0)
        }
        else if(shouldShowTowers){
            if ((fetchedResultsControllerTowers?.fetchedObjects?.count ?? 0) > 0)
            {
                tableView.backgroundView = nil
            }
            else
            {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text = "No data available"
                noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
                noDataLabel.textColor     = UIColor.black
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
            return (fetchedResultsControllerTowers?.fetchedObjects?.count ?? 0)
        }
        else if(shouldShowClients){
            
            if ((self.reservationsDataSource != nil && self.reservationsDataSource.count > 0) || (self.bookedClientsDataSource != nil && self.bookedClientsDataSource.count > 0))
            {
                tableView.backgroundView = nil
            }
            else
            {
                self.updateNoDataLabel(isUnits: shouldShowUnits)
            }
            if(selectedUnit.status == UNIT_STATUS.RESERVED.rawValue){
                return reservationsDataSource.count
            }
            else{
                return bookedClientsDataSource.count
            }
        }
        else{
            
            if ((fetchedResultsControllerProjects?.fetchedObjects?.count ?? 0) > 0)
            {
                tableView.backgroundView = nil
            }
            else
            {
                self.updateNoDataLabel(isUnits: shouldShowUnits)
            }
            return (fetchedResultsControllerProjects?.fetchedObjects?.count ?? 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProjectNameTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "projectNameCell",
            for: indexPath) as! ProjectNameTableViewCell
        
        if(isOutStanding){
            cell.widthOfImageView.constant = 40
        }
        else{
            cell.widthOfImageView.constant = 0
        }

        if(shouldShowUnits){
            let unit = self.fetchedResultsControllerUnits.object(at: indexPath)
            cell.projectNameLabel.text = String(format: "%@ (%@)", unit.unitDisplayName!,unit.description1!)
            let statusDict = RRUtilities.sharedInstance.getColorAccordingToUnitStatus(status: Int(unit.status))
            cell.unitStatusLabel.text = statusDict["statusString"] as? String
            cell.unitStatusLabel.textColor = statusDict["color"] as? UIColor
            cell.heightOfUnitStatusLabel.constant = 18
            if(unit.status == UNIT_STATUS.BLOCKED.rawValue){
                cell.widthOfRightLabel.constant = 150
                cell.rightLabel.text = unit.blockingReason
            }
            else{
                cell.widthOfRightLabel.constant = 0
                cell.rightLabel.text = ""
            }
            if(isOutStanding){
                if(unit.id == selectedUnitId){
                    cell.redioButtonImageView.image = UIImage.init(named: "radio_on")
                }
                else{
                    cell.redioButtonImageView.image = UIImage.init(named: "radio_off")
                }
            }
        }
        else if(isOutStanding && shouldShowBlocks){
            let block = self.fetchedResultsControllerBlocks.object(at: indexPath)
            cell.projectNameLabel.text = block.name
            cell.heightOfUnitStatusLabel.constant = 0
            cell.widthOfRightLabel.constant = 0
            if(isOutStanding){
                if(block.id == selectedBlockId){
                    cell.redioButtonImageView.image = UIImage.init(named: "radio_on")
                }
                else{
                    cell.redioButtonImageView.image = UIImage.init(named: "radio_off")
                }
            }
        }
        else if(isOutStanding && shouldShowTowers){
            let tower = self.fetchedResultsControllerTowers.object(at: indexPath)
            cell.projectNameLabel.text = tower.name
            cell.heightOfUnitStatusLabel.constant = 0
            cell.widthOfRightLabel.constant = 0
            if(isOutStanding){
                if(tower.id == selectedTowerId){
                    cell.redioButtonImageView.image = UIImage.init(named: "radio_on")
                }
                else{
                    cell.redioButtonImageView.image = UIImage.init(named: "radio_off")
                }
            }
        }
        else if(shouldShowClients){
            if(selectedUnit.status == UNIT_STATUS.RESERVED.rawValue){
                let clietDetails = reservationsDataSource[indexPath.row]
                cell.projectNameLabel.text = clietDetails.prospect?.userName
                cell.heightOfUnitStatusLabel.constant = 0
                cell.rightLabel.text = clietDetails.prospect?._id
            }
            else{
                let clietDetails = bookedClientsDataSource[indexPath.row]
                cell.projectNameLabel.text = clietDetails.customer?.name
                cell.heightOfUnitStatusLabel.constant = 0
                cell.rightLabel.text = clietDetails.customer?.customerId
            }
            cell.widthOfRightLabel.constant = 100
        }
        else{
            cell.widthOfRightLabel.constant = 0
            let project = fetchedResultsControllerProjects?.object(at: indexPath)
            cell.projectNameLabel.text = project?.name
            cell.heightOfUnitStatusLabel.constant = 0
            if(selectedProject != nil && selectedProject.name == project?.name){
                cell.redioButtonImageView.image = UIImage.init(named: "radio_on")
            }
            else{
                cell.redioButtonImageView.image = UIImage.init(named: "radio_off")
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(isOutStanding){
            
            if(shouldShowBlocks){
                let selecteBlock = self.fetchedResultsControllerBlocks?.object(at: indexPath)
                didSelectId?(selecteBlock?.id,selecteBlock?.name)
            }
            else if(shouldShowTowers){
                let selecteTower = self.fetchedResultsControllerTowers?.object(at: indexPath)
                didSelectId?(selecteTower?.id,selecteTower?.name)
            }
            else if(shouldShowUnits){
                let selecteUnit = self.fetchedResultsControllerUnits?.object(at: indexPath)
                didSelectId?(selecteUnit?.id,String(format: "%@ (%@)", selecteUnit?.unitDisplayName ?? "",selecteUnit?.description1 ?? ""))
            }
            else{
                selectedProject = self.fetchedResultsControllerProjects?.object(at: indexPath)
                didSelectId?(selectedProject.id,selectedProject.name)
            }
            tableView.reloadData()
            self.navigationController?.popViewController(animated: true)
            return
        }
        if(selectedProject == nil){
            if(indexPath.row > (self.fetchedResultsControllerProjects?.fetchedObjects!.count)! - 1){
                return
            }
            selectedProject = self.fetchedResultsControllerProjects?.object(at: indexPath)
            
            if(agreementType == AGREEMENT_TYPES.Sales_Agreement){
                titleLabel.text = "SELECT UNIT - SALE AGREEMENT"
            }
            else if(agreementType == AGREEMENT_TYPES.Assigment_Agreement){
                titleLabel.text = "SELECT UNIT - ASSIGNMENT AGREEMENT"
            }
            else if(isBlockOrRelease){
                titleLabel.text = "SELECT UNIT - BLOCK/RELEASE UNIT"
            }
            else if(isReserve){
                titleLabel.text = "SELECT UNIT - RESERVE UNIT"
            }
            else if(isOutStanding){
            }
            else{
                titleLabel.text = "SELECT UNIT - RECEIPT ENTRY"
            }
            shouldShowUnits = true
            searchBar.placeholder = "Search for Unit"
            heightOfUnitDetailsLabel.constant = 22
            heightOfHorizantalLine.constant = 1
            selectedPathInfoLabel.text = selectedProject.name!
            self.fetchUnits(shouldFetch: true)
        }
        else if(selectedUnit == nil){
            selectedUnit = self.fetchedResultsControllerUnits.object(at: indexPath)
            //Fetch booked or sold or reserved Prospects for that unit ***
            
            if(agreementType == AGREEMENT_TYPES.Sales_Agreement){
                titleLabel.text = "SELECT CLIENT - SALE AGREEMENT"
            }
            else if(agreementType == AGREEMENT_TYPES.Assigment_Agreement){
                titleLabel.text = "SELECT CLIENT - ASSIGNMENT AGREEMENT"
            }
            else if(isBlockOrRelease){
                titleLabel.text = "SELECT CLIENT - BLOCK/RELEASE UNIT"
            }
            else if(isReserve){
                titleLabel.text = "SELECT CLIENT - RESEVE UNIT"
            }
            else if(isOutStanding){
                
            }
            else{
                self.titleLabel.text = "SELECT CLIENT - RECEIPT ENTRY"
            }
            
            if(agreementType > 0){
                
                let agControlelr = AgreementViewController(nibName: "AgreementViewController", bundle: nil)
                
                let unitDetailsString = String(format: "%@ > %@ > %@ > %d > %@ > %@ (%@)", self.selectedProject.name!,selectedUnit.blockName!,selectedUnit.towerName!,selectedUnit.floorIndex,selectedUnit.typeName ?? "",selectedUnit.unitDisplayName!,selectedUnit.description1!)
                agControlelr.unitPath = unitDetailsString
                agControlelr.selectedUnit = selectedUnit
                agControlelr.isFromCRM = true
                HUD.show(.progress, onView: self.view)
                ServerAPIs.getAggreementDatesByType(forUnit: selectedUnit.id!, type: agreementType, completionHandler: { (responseObject,nil) in
                    
                    HUD.hide()
                    if(responseObject?.status == 1){
                        agControlelr.astTableViewDataSource = responseObject?.astInfo?.ast
                        agControlelr.astInfo = responseObject?.astInfo
                        
                        if(self.agreementType == AGREEMENT_TYPES.Sales_Agreement){
                            agControlelr.agreementType = self.agreementType
                        }
                        else if(self.agreementType == AGREEMENT_TYPES.Assigment_Agreement){
                            agControlelr.agreementType = self.agreementType
                        }
                        self.navigationController?.pushViewController(agControlelr, animated: true)
                    }
                    else{
                        HUD.flash(.label("Couldn't get agreements"), delay: 1.0)
                    }
                })
            }
            else if(isBlockOrRelease){
                
//                let unitDetailsString = String(format: "%@ > %@ > %@ > %d > %@ > %@ (%@)", self.selectedProject.name!,selectedUnit.blockName!,selectedUnit.towerName!,selectedUnit.floorIndex,selectedUnit.typeName ?? "",selectedUnit.unitDisplayName!,selectedUnit.description1!)
                
                let blockOrReserveController = BlockOrReleaseUnitViewController(nibName: "BlockOrReleaseUnitViewController", bundle: nil)
                blockOrReserveController.selectedUnit = self.selectedUnit
//                blockOrReserveController.delegate = self
//                blockOrReserveController.selectedUnitIndexPath = self.indexPathForUnitSelection
                
                blockOrReserveController.projectName = self.selectedProject.name!
                blockOrReserveController.isFromCRM = true
                
                blockOrReserveController.blockName = selectedUnit.blockName!
                blockOrReserveController.towerName = selectedUnit.towerName!
                
                blockOrReserveController.unitType = selectedUnit.typeName ?? ""
                
                self.navigationController?.pushViewController(blockOrReserveController, animated: true)
                
            }
            else if(isReserve){
                
                searchBar.placeholder = "Search for Client"
                selectedPathInfoLabel.text = String(format: "%@ > %@ (%@)", selectedProject.name!,selectedUnit.unitDisplayName!,selectedUnit.description1!)
                HUD.show(.progress, onView: self.view)
                ServerAPIs.getProspectsForReservation(completionHandler: { (responseObject , error) in
                    HUD.hide()
                    if(responseObject != nil && responseObject?.status == 1){
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let reservationsController = storyboard.instantiateViewController(withIdentifier: "reservationsView") as! ReservationsViewController
                        reservationsController.selectedUnit = self.selectedUnit
                        reservationsController.delegate = self
                        reservationsController.tableViewDataSource = responseObject!.customers!
                        
                        reservationsController.projectName = self.selectedProject.name!
                        reservationsController.isFromCRM = true
                        
                        reservationsController.blockName = self.selectedUnit.blockName!
                        reservationsController.towerName = self.selectedUnit.towerName!
                        
                        reservationsController.unitType = self.selectedUnit.typeName ?? ""
                        
                        self.navigationController?.pushViewController(reservationsController, animated: true)

                    }
                    else{
                        HUD.flash(.label("Couldn't fetch prospects.Try later"), delay: 1.0)
                    }
                })
                
                
            }
            else{
                
                self.shouldShowClients = true
                self.shouldShowUnits = false

                searchBar.placeholder = "Search for Client"
                selectedPathInfoLabel.text = String(format: "%@ > %@ (%@)", selectedProject.name!,selectedUnit.unitDisplayName!,selectedUnit.description1!)
                if(selectedUnit.status == UNIT_STATUS.RESERVED.rawValue){
                    ServerAPIs.getReservationsQueue(selectedUnitId: selectedUnit.id!,completionHandler: {responseObject, error in
                        if(responseObject?.status == 1){
                            DispatchQueue.main.async {
                                self.reservationsDataSource = responseObject?.reservedUnits
                                self.reserveDataSourceForSearch = responseObject?.reservedUnits ?? []
                                self.tableView.reloadData()
                            }
                        }
                        else{
                            self.reserveDataSourceForSearch  = []
                            self.reservationsDataSource = []
                            self.tableView.reloadData()
                        }
                    })
                }
                else{
                    //getBookedOrSoldUnitClients
                    
                    ServerAPIs.getBookedOrSoldUnitClients(selectedUnitId: selectedUnit.id!,completionHandler: {responseObject, error in
                        if(responseObject?.status == 1){
                            DispatchQueue.main.async {
                                self.reservationsDataSource = nil
                                self.reserveDataSourceForSearch = []
                                
                                self.bookedClientsDataSource = (responseObject?.bookings as! [BOOKED_CLIENTS])
                                self.bookedClientDataSourceForSearch = (responseObject?.bookings!) as! [BOOKED_CLIENTS]
                                self.tableView.reloadData()
                            }
                        }
                        else{
                            self.bookedClientsDataSource = []
                            self.bookedClientDataSourceForSearch = []
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        }
        else if(selectedClient == nil){
            // show receipt entry form ****
            
            
                let receiptFormController = ReceiptEntryFormViewController(nibName: "ReceiptEntryFormViewController", bundle: nil)
                if(selectedUnit.status == UNIT_STATUS.RESERVED.rawValue){
                    receiptFormController.selectedClient = reservationsDataSource[indexPath.row]
                }
                else{
                    if let customer = self.bookedClientsDataSource[indexPath.row].customer{
                        receiptFormController.selectedBookedClint = customer
                    }
                }
                print(self.selectedUnit)
                
                receiptFormController.selectedUnit = self.selectedUnit
                receiptFormController.selectedProject = self.selectedProject
                self.navigationController?.pushViewController(receiptFormController, animated: true)
            
        }
        
        self.restoreSearchBox()

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
extension ProjectSearchViewController :  ProjectSearchDelegate{
    func didClickBack() {
        self.back(UIButton())
    }
}

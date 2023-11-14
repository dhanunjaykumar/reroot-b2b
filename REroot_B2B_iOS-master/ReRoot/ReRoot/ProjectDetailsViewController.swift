//
//  ProjectDetailsViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 14/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import CoreData
import FloatingPanel


class ProjectDetailsViewController: UIViewController ,UIPopoverPresentationControllerDelegate,HidePopUp,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource,BookUnitDelegate,UISearchBarDelegate,UICollectionViewDelegateFlowLayout,UnitStatusChangeDelegateDelegate
{
    var fetchedResultControllerLandOwerUnits : NSFetchedResultsController<LandOwner>!
    var fetchedResultsControllerBlocks : NSFetchedResultsController<Blocks>!
    var fetchedResultsControllerTowers : NSFetchedResultsController<Towers>!
    var fetchedResultsControllerProjects : NSFetchedResultsController<Project>!
    var fetchedResultsControllerUnits : NSFetchedResultsController<Units>!
    var selectedProject : Project!
    
    var searchText : String = ""

    @IBOutlet weak var bottomConstraintOfUnitsCollectionView: NSLayoutConstraint!
    @IBOutlet weak var landOnwerSwitch: UISwitch!
    var fetchingLimit : Int = 0
    var oldContentOffset = CGPoint.zero
    var selectedStatusForFilter : Int!
    var lastSelectedStatusOption : Int = -1
    var footerLabel : UILabel!
    var selectedBlockInUnitBlocksView : String!
    var refreshControl: UIRefreshControl?
    var unitRefreshControl : UIRefreshControl?
    @IBOutlet weak var popUpSourceView: UIView!
    @IBOutlet weak var totalUnitsCountLabel: UILabel!
    var popUpDataDict = Dictionary<String,Array<Towers>>()
    var orderedBlocksArrayForPopUp = NSMutableOrderedSet()
    var floatPopUpRowCounter : Int!
    
    @IBOutlet weak var widthOfFilterButton: NSLayoutConstraint!
    @IBOutlet weak var filterButton: UIButton!
    var projectsArray : [Project] = []
    
    @IBOutlet weak var colorCollectionView: UICollectionView!
//    var currentTitlesOfBlocks = Array<String>()
//    var currentUnitsDataSource : Dictionary<String,Array<UnitDetails>> = [:]
    @IBOutlet weak var titleSubView: UIView!
    var currentBlocksArray : [BlockDetails]!
    var blocksArray : [BlockDetails]!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var statusLabel: UILabel!
    var selectedIndexForDetailedProjectView : Int!
    var statusArray : Array<String>!
    var selectedIndexPath : IndexPath!
    var selectedProjectIndexPath : IndexPath!
    var indexPathForUnitSelection : IndexPath!
    @IBOutlet weak var mUnitsCollectionView: UICollectionView!
    @IBOutlet weak var unitsView: UIView!
    @IBOutlet weak var popUpSourceLabel: UILabel!
    @IBOutlet weak var projectTitleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    var mCollectionViewDataSource : Array! = []
    var projectDetails : ProjectDetails!
    @IBOutlet weak var subPartTypeLabel: UILabel!
    @IBOutlet weak var allBlocksLabel: UILabel!
    @IBOutlet weak var allBlocksView: UIView!
    @IBOutlet weak var mProjectsSubPartsTypeView: UIView!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var mCollectionView: CustomCollectionView!
    var collectionViewDataSource : [STAT]!
    var totalNumberOfFloors : Int = 0
    var blocksButton : ButtonView!
    var orderdSectionTitls = NSMutableOrderedSet()
    
    @IBOutlet weak var landOwnerDetailsView : UIView!
    @IBOutlet weak var landOwnerNameLabel: UILabel!
    @IBOutlet weak var landOwnerNameView: UIView!
    var numberOfSections : Dictionary<String,Array<UnitDetails>> = [:]
    var selectedLandOwnerName : String = "None"
    
    @IBOutlet weak var heightOfLOParentView: NSLayoutConstraint!
    @IBOutlet weak var heightOfLODetailsView: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraintOfOwnerNameView: NSLayoutConstraint!
    @IBOutlet weak var widthConstraintOfOwnerNameView: NSLayoutConstraint!
    
    let fpc = FloatingPanelController()
    
    lazy var selectedCarpetAreaArray : [String] = []
    lazy var selectedTypeNamesArray : [String] = []
    lazy var selectedFacingNamesArray : [String] = []
    lazy var selectedBuiltUpAreasArray : [String] = []
    lazy var selectedBedRoomsArray : [String] = []
    lazy var selectedBathRoomsArray : [String] = []
    lazy var selectedFloorPremiums : [String] = []
    lazy var selectedOtherPremiums : [String] = []
    lazy var selectedMiscArray : [String] = []
    lazy var tableViewSectionsSelectedCountDict : Dictionary<Int,Int> = [:]
    
    //MARK: - ViewController life cycle
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
        
        
        /*
         let key  = currentTitlesOfBlocks[section]
         let unitsArray : Array<UnitDetails> = (currentUnitsDataSource[key])!
         currentTitlesOfBlocks
         */
        
        colorCollectionView.reloadData()
        titleView.bringSubviewToFront(self.titleSubView)
        
        DispatchQueue.global().async {
            self.fetchAllProjects()
        }
        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.black
        NotificationCenter.default.addObserver(self, selector: #selector(updateUnitStaus(_:)), name: Notification.Name(NOTIFICATIONS.UNIT_RESERVED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUnitStaus(_:)), name: Notification.Name(NOTIFICATIONS.UNIT_RESERVATIONS_REVOKED), object: nil)
        
        searchBar.isHidden = true
        
        selectedIndexForDetailedProjectView = 0
        statusArray =  ["Vacant","Booked","Sold","Reserved","Blocked","Handed Over"] //["Reserved","Block"]
        
        //0 - Vacant, 1 - Booked, 2- Sold, 3 - Reserved, 4 - Blocked, 5 - Handed Over
        
        self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "f1f7ff")
        
        mCollectionView.register(UINib(nibName: "BlockInfoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "blockCell")
        mUnitsCollectionView.register(UINib(nibName: "SingleUnitCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "singleUnit")
        colorCollectionView.register(UINib(nibName: "ColorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "colorCell")
        mUnitsCollectionView.register(UINib(nibName: "UnitDetailsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "unitCell")
        
        

//        let temper  = UINib(nibName: "HeaderCollectionReusableView", bundle: nil)
//        mUnitsCollectionView.register(UINib(nibName: "UnitHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "unitHeader")
//
//        mUnitsCollectionView.register(UnitHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "unitHeader")

        
        //collectionView.register(UINib(nibName: collectionViewHeaderFooterReuseIdentifier bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier:collectionViewHeaderFooterReuseIdentifier)


        let tapGuesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyBoard))
        tapGuesture.cancelsTouchesInView = false
        mUnitsCollectionView.addGestureRecognizer(tapGuesture)
        
        leadingConstraintOfOwnerNameView.constant = 0
        widthConstraintOfOwnerNameView.constant = 0
        self.landOwnerNameView.isHidden = true

        let ownerGuesture = UITapGestureRecognizer.init(target: self, action: #selector(showLandOwnersPopUp))
        landOwnerNameView.addGestureRecognizer(ownerGuesture)
        
//        mUnitsCollectionView.register(UnitHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "unitHeader")  // UICollectionReusableView

        
//        mUnitsCollectionView.register(UINib(nibName: "UnitCollectionReusableView", bundle: nil), forCellWithReuseIdentifier: "unitHeader")
        
        let tempLayout = UICollectionViewFlowLayout.init()
        tempLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tempLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        tempLayout.minimumInteritemSpacing = 0
        tempLayout.minimumLineSpacing = 0
        tempLayout.scrollDirection = .horizontal
        mCollectionView.collectionViewLayout = tempLayout
        
//        mCollectionView.backgroundColor = .orange
        print(mCollectionView.frame.size.width)
        
//        print(projectDetails)
        
        footerLabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.size.height - 50, width:self.view.frame.size.width , height: 50))

        self.fetchAllUnits()
        self.fetchAllBlocks()
        self.fetchAllTowers()
        
//        blocksArray = projectDetails.blocks
//        currentBlocksArray = blocksArray // for search bar purpose
        
        mCollectionView.delegate = self
        mCollectionView.dataSource = self
        
        let nib = UINib(nibName: "BlockDetailsTableViewCell", bundle: nil)
        mTableView.register(nib, forCellReuseIdentifier: "blockDetailCell")

        mTableView.estimatedRowHeight = UITableView.automaticDimension // standard tableViewCell height
        mTableView.rowHeight = UITableView.automaticDimension

        mTableView.delegate = self
        mTableView.dataSource = self

        mTableView.tableFooterView = UIView()
        
        mCollectionView.scrollToItem(at: IndexPath.init(row: 5, section: 0), at: .left, animated: true)
//        mTableView.estimatedSectionFooterHeight = 50.0
        
        
//        UIView* v = [[UIView alloc] initWithFrame:self.view.bounds];
//        CGFloat labelHeight = 30;
//        CGFloat padding = 5;
//        UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(0, v.frame.size.height - labelHeight - padding, self.view.frame.size.width, labelHeight)];
//        l.text = @"Hello World";
//        [v addSubview:l];
//        [self.tableView setBackgroundView:v];

        
        projectTitleLabel.text = String(format: "%@ - %@", selectedProject.name!,selectedProject.city ?? "")
        projectTitleLabel.isUserInteractionEnabled = true
        
        unitsView.isHidden = true
        
//        buildDataSourceAsFloorWise()
        
        let tempLayout1 = UICollectionViewFlowLayout.init()
//        tempLayout1.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tempLayout1.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        tempLayout1.itemSize = CGSize(width: self.view.frame.size.width/4, height: 70)
        tempLayout1.itemSize = UICollectionViewFlowLayout.automaticSize
//        tempLayout1.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        tempLayout1.headerReferenceSize =  CGSize(width: self.mUnitsCollectionView.frame.size.width, height: 50)
        // CGSizeMake(self.mUnitsCollectionView.frame.size.width, 50);
        tempLayout1.minimumInteritemSpacing = 2
        tempLayout1.minimumLineSpacing = 5
        tempLayout1.scrollDirection = .vertical
        mUnitsCollectionView.collectionViewLayout = tempLayout1
        mUnitsCollectionView.backgroundColor = UIColor.hexStringToUIColor(hex: "f0f7ff")
        statusLabel.isHidden = true
        
        
        let tempLayout2 = UICollectionViewFlowLayout.init()
        tempLayout2.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tempLayout2.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        tempLayout2.minimumInteritemSpacing = 10
        tempLayout2.minimumLineSpacing = 0
        tempLayout2.scrollDirection = .horizontal
        colorCollectionView.collectionViewLayout = tempLayout2
        
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.reloadData()
         
        self.addRefreshControl()
        
        mUnitsCollectionView.delegate = self
        mUnitsCollectionView.dataSource = self
        mUnitsCollectionView.reloadData()
        
//        let urlString = String(format:RRAPI.PROJECT_DETAILS, selectedProject.id!)
//        self.getSelectedProjectDetails(urlString: urlString)
        
        footerLabel.text = String(format: "Total Units : %d", (self.fetchedResultsControllerUnits.fetchedObjects?.count)!)
        footerLabel.font = UIFont(name: "Montserrat-Regular", size: 14)
        footerLabel.textAlignment = .center
        self.view.addSubview(footerLabel)
        
//        self.mCollectionView.backgroundColor = UIColor.hexStringToUIColor(hex: "f0f7ff")
        self.landOwnerDetailsView.backgroundColor = UIColor.hexStringToUIColor(hex: "f0f7ff")
        self.totalUnitsCountLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "f0f7ff")
        
        self.showLandOwnerDetailsView()
        self.shouldShowFilterButton(shouldShow: false)
    }
    func shouldShowFilterButton(shouldShow : Bool){
        if(shouldShow){
            self.widthOfFilterButton.constant = 50
            self.filterButton.isHidden = !shouldShow
        }
        else{
            self.widthOfFilterButton.constant = 0
            self.filterButton.isHidden = !shouldShow
        }
    }
    func showLandOwnerDetailsView(){
        
        let request: NSFetchRequest<LandOwner> = LandOwner.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(LandOwner.shortName), ascending: true)
        request.sortDescriptors = [sort]
        
        let predicate = NSPredicate(format: "project CONTAINS[c] %@", self.selectedProject.id!)
        request.predicate = predicate
        
        fetchedResultControllerLandOwerUnits = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        
        do {
            try fetchedResultControllerLandOwerUnits?.performFetch()
            
            if(fetchedResultControllerLandOwerUnits!.fetchedObjects!.count > 0){
                self.landOwnerDetailsView.isHidden = false
                self.heightOfLOParentView.constant = 125
                self.heightOfLODetailsView.constant = 50
            }
            else{
                self.landOwnerDetailsView.isHidden = true
                self.heightOfLODetailsView.constant = 0
                self.heightOfLOParentView.constant = 75
            }
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    func projectExist()->Bool{
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Units")
        //Units.fetchRequest()
        request.resultType = NSFetchRequestResultType.countResultType
        
        let projecct = fetchedResultsControllerProjects!.object(at: self.selectedProjectIndexPath)
        let predicate = NSPredicate(format: "project CONTAINS[c] %@", projecct.id!)
        request.predicate = predicate
        
        do {
            let tempUnits = try [RRUtilities.sharedInstance.model.managedObjectContext .count(for: request)]
            
            if(tempUnits.count > 0){
//                print(tempUnits.count)
                if(tempUnits[0] == 0){
                    return false
                }
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
    func fetchAllProjects(){
        
        let request: NSFetchRequest<Project> = Project.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Project.name), ascending: true)
        request.sortDescriptors = [sort]
        
        fetchedResultsControllerProjects = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        fetchedResultsControllerProjects?.delegate = self
        
        do {
            try fetchedResultsControllerProjects?.performFetch()
            _ = fetchedResultsControllerProjects?.fetchedObjects
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    func fetchUnitsWithSearchString(locSeachText : String){
        if(locSeachText == ""){
            self.fetchAllUnits()
            return
        }
        let request: NSFetchRequest<Units> = Units.fetchRequest()
//        request.fetchBatchSize = 20
        let sort = NSSortDescriptor(key: #keyPath(Units.sectionIndex), ascending: true)
        request.sortDescriptors = [sort]
        
        var predicate = NSPredicate(format: "description1 CONTAINS[c] %@ AND project CONTAINS[c] %@", locSeachText,self.selectedProject.id ?? "")
        
        if(landOnwerSwitch.isOn){
             if(selectedLandOwnerName == "None"){
                predicate = NSPredicate(format: "project CONTAINS[c] %@ AND description1 CONTAINS[c] %@ AND (bookedClient.name CONTAINS[c] %@ OR bookedClient.phone CONTAINS[c] %@) AND hasLandOwner contains[c] %d AND owner.name == %@", self.selectedProject.id ?? "",locSeachText,locSeachText,locSeachText,landOnwerSwitch.isOn,selectedLandOwnerName)
                request.predicate = predicate
            }
             else{
                predicate = NSPredicate(format: "project CONTAINS[c] %@ AND description1 CONTAINS[c] %@ AND (bookedClient.name CONTAINS[c] %@ OR bookedClient.phone CONTAINS[c] %@) AND hasLandOwner contains[c] %d",self.selectedProject.id ?? "",locSeachText,locSeachText,locSeachText,landOnwerSwitch.isOn)
                request.predicate = predicate
            }
        }
        else{
            predicate = NSPredicate(format: "project CONTAINS[c] %@ AND description1 CONTAINS[c] %@ OR (bookedClient.name CONTAINS[c] %@ OR bookedClient.phone CONTAINS[c] %@)",self.selectedProject.id ?? "", locSeachText,locSeachText,locSeachText)
            request.predicate = predicate
        }
        
        fetchedResultsControllerUnits = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: "sectionIndex", cacheName:nil)
        fetchedResultsControllerUnits.delegate = self
        
        do {
            try fetchedResultsControllerUnits.performFetch()
            self.totalUnitsCountLabel.text = String(format: "Total Units : %d", (self.fetchedResultsControllerUnits.fetchedObjects?.count)!)
        }
        catch {
            fatalError("Error in fetching records")
        }

    }
    func fetchUnitsWithSelectedStatus(selectedStatus : Int){
        
        if(selectedStatus == -1){
            self.fetchAllUnits()
            self.mUnitsCollectionView.reloadData()
            return
        }
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Units")
        fetchRequest.resultType = .dictionaryResultType
        let predicater = NSPredicate(format: "project CONTAINS[c] %@", self.selectedProject.id!) //AND description1 CONTAINS[c] %@
        fetchRequest.predicate = predicater
        fetchRequest.propertiesToFetch = ["capetAreaUOM"]
        fetchRequest.returnsDistinctResults = true
        let carpetUomsArray = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)
        fetchRequest.propertiesToFetch = ["superBuiltUpAreaUOM"]
        let superAreaUomsArray = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)

        var unitTypeFilters : [NSPredicate] = []
        
        for eachType in self.selectedTypeNamesArray{
            unitTypeFilters.append(NSPredicate(format: "typeName == %@", eachType))
        }
        
        var unitFacingFilter : [NSPredicate] = []
        for eachFacing in self.selectedFacingNamesArray{
            unitFacingFilter.append(NSPredicate(format: "facing CONTAINS[c] %@", eachFacing))
        }
        
        var builtUpFilters : [NSPredicate] = []
        for eachBuiltUp in self.selectedBuiltUpAreasArray{
            var tempBuiltUp = eachBuiltUp
            for eachUom in superAreaUomsArray{
                let uomStr : String = eachUom["superBuiltUpAreaUOM"] as! String
                if(tempBuiltUp.contains(uomStr)){
                    tempBuiltUp = tempBuiltUp.replacingOccurrences(of: String(format: " %@", uomStr), with: "")
                }
            }
            builtUpFilters.append(NSPredicate(format: "superBuiltUpArea CONTAINS[c] %@", tempBuiltUp))
        }

        var carperAreaFilters : [NSPredicate] = []
        for eachCarpetArea in self.selectedCarpetAreaArray{
            var tempCarpet = eachCarpetArea
            for eachUom in carpetUomsArray{
                let uomStr : String = eachUom["capetAreaUOM"] as! String
                if(tempCarpet.contains(uomStr)){
                    tempCarpet = tempCarpet.replacingOccurrences(of: String(format: " %@", uomStr), with: "")
                }
            }
            carperAreaFilters.append(NSPredicate(format: "carpetArea CONTAINS[c] %@", tempCarpet))
        }
        
        var floorPremiumFilter : [NSPredicate] = []
        for eachPremium in self.selectedFloorPremiums{
            floorPremiumFilter.append(NSPredicate(format: "floorPremium == %@", eachPremium))
        }
        
        var otherPremiumFilter : [NSPredicate] = []
        for eachPremium in self.selectedOtherPremiums{

            let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "OtherPremiums")
            fetchRequest.resultType = .dictionaryResultType
            fetchRequest.propertiesToFetch = ["parentId"]
            let predicate = NSPredicate(format: "name CONTAINS[c] %@", eachPremium)
            fetchRequest.predicate = predicate
            let premiumsss = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)
            
            var otherPremUnits : [String] = []
            if(premiumsss.count > 0){
                for eachPremium in premiumsss{
                    if let prentId = eachPremium["parentId"] as? String{
                        otherPremUnits.append(prentId)
                    }
                }
                
                otherPremiumFilter.append(NSPredicate(format: "id IN %@", otherPremUnits)) //#keyPath(Units.allOtherPremiums),
            }
        }
        
        var miscArrayFilter : [NSPredicate] = []
        for eachMisc in self.selectedMiscArray{
            if(eachMisc == "Non Premium"){
                miscArrayFilter.append(NSPredicate(format: "floorPremium == nil AND otherPremiumsCount == 0"))
            }
        }

        
        let request: NSFetchRequest<Units> = Units.fetchRequest()
        request.fetchBatchSize = 20
        let sort1 = NSSortDescriptor(key: #keyPath(Units.sectionIndex), ascending: true)
//        request.sortDescriptors = [sort]
        
        let shouldEnable = UserDefaults.standard.bool(forKey: "Unit Description Enabled")
        
        if(shouldEnable){
            let floorSort = NSSortDescriptor(key: #keyPath(Units.floorIndex), ascending: true)
            let sort = NSSortDescriptor(key: #keyPath(Units.unitIndex), ascending: true)
            request.sortDescriptors = [sort1,floorSort,sort]
        }
        else{
            let sort = NSSortDescriptor(key: #keyPath(Units.floorIndex), ascending: true)
            let tempSort = NSSortDescriptor(key: #keyPath(Units.unitIndex), ascending: true)
            request.sortDescriptors = [sort1,tempSort,sort]
        }

        
        var predicate = NSPredicate(format: "status == %d AND project == %@", selectedStatus,self.selectedProject.id!)

        if(landOnwerSwitch.isOn){
            if(selectedLandOwnerName != "None"){
                predicate = NSPredicate(format: "status == %d AND project == %@ AND hasLandOwner contains[c] %d AND owner.name == %@", selectedStatus,self.selectedProject.id!,landOnwerSwitch.isOn,selectedLandOwnerName)
                request.predicate = predicate
            }
            else{
                predicate = NSPredicate(format: "status == %d AND project == %@ AND hasLandOwner contains[c] %d", selectedStatus,self.selectedProject.id!,landOnwerSwitch.isOn)
                request.predicate = predicate
            }
        }
        else{
            predicate = NSPredicate(format: "status == %d AND project == %@", selectedStatus,self.selectedProject.id!)
            request.predicate = predicate
        }
        
        var allPredicates = unitTypeFilters
        allPredicates.append(contentsOf: unitFacingFilter)
        allPredicates.append(contentsOf: builtUpFilters)
        allPredicates.append(contentsOf: carperAreaFilters)
        allPredicates.append(contentsOf: floorPremiumFilter)
        allPredicates.append(contentsOf: otherPremiumFilter)
        allPredicates.append(contentsOf: miscArrayFilter)
        allPredicates.append(predicate)
        
        if(!self.searchText.isEmpty){
            if(shouldEnable){
                let nameOrPhoneNumberPredicate = NSPredicate(format: "bookedClient.name CONTAINS[c] %@ OR bookedClient.phone CONTAINS[c] %@ OR description1 CONTAINS[c] %@",self.searchText,self.searchText,self.searchText)
                allPredicates.append(nameOrPhoneNumberPredicate)
            }
            else{
                let nameOrPhoneNumberPredicate = NSPredicate(format: "bookedClient.name CONTAINS[c] %@ OR bookedClient.phone CONTAINS[c] %@ OR unitDisplayName CONTAINS[c] %@",self.searchText,self.searchText,self.searchText)
                allPredicates.append(nameOrPhoneNumberPredicate)
            }
        }

        let compounPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: allPredicates)
        
        request.predicate = compounPredicate

        
        fetchedResultsControllerUnits = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: "sectionIndex", cacheName:nil)
        fetchedResultsControllerUnits.delegate = self
        
        do {
            try fetchedResultsControllerUnits.performFetch()
            
            if(self.fetchedResultsControllerUnits!.sections!.count > 0){
                let tempUnit : Units = self.fetchedResultsControllerUnits.object(at: IndexPath(row: 0, section: 0))
                blocksButton.mTitleLabel?.text = tempUnit.sectionTitle
            }
            self.totalUnitsCountLabel.text = String(format: "Total Units : %d", (self.fetchedResultsControllerUnits.fetchedObjects?.count)!)
            mUnitsCollectionView.reloadData()
            
            if(self.fetchedResultsControllerUnits.fetchedObjects?.count == 0)
            {
                self.blocksButton?.isHidden = true
            }
            else if(self.landOnwerSwitch.isOn){
                self.blocksButton?.isHidden = true
            }
            else{
                self.blocksButton?.isHidden = false
            }
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    @objc func fetchAllUnits(){
        
        if(self.selectedStatusForFilter != nil && self.selectedStatusForFilter != -1){
            self.fetchUnitsWithSelectedStatus(selectedStatus: selectedStatusForFilter)
            self.mUnitsCollectionView.reloadData()
            return
        }

        // get UOMs 
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Units")
        fetchRequest.resultType = .dictionaryResultType
        let predicater = NSPredicate(format: "project CONTAINS[c] %@", self.selectedProject.id!) //AND description1 CONTAINS[c] %@
        fetchRequest.predicate = predicater
        fetchRequest.propertiesToFetch = ["capetAreaUOM"]
        fetchRequest.returnsDistinctResults = true
        let carpetUomsArray = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)
        fetchRequest.propertiesToFetch = ["superBuiltUpAreaUOM"]
        let superAreaUomsArray = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)
        
        
        let request: NSFetchRequest<Units> = Units.fetchRequest()
//        request.fetchBatchSize = 20
        let sort1 = NSSortDescriptor(key: #keyPath(Units.sectionIndex), ascending: true)
        
        let shouldEnable = UserDefaults.standard.bool(forKey: "Unit Description Enabled")

        if(shouldEnable){
            let floorSort = NSSortDescriptor(key: #keyPath(Units.floorIndex), ascending: true)
            let unitDipalyName = NSSortDescriptor(key: #keyPath(Units.unitDisplayName), ascending: true)
            let tempSort = NSSortDescriptor(key: #keyPath(Units.unitIndex), ascending: true)

            request.sortDescriptors = [sort1,floorSort,tempSort,unitDipalyName] //[sort1,floorSort,sort]
        }
        else{
            let sort = NSSortDescriptor(key: #keyPath(Units.floorIndex), ascending: true)
            let tempSort = NSSortDescriptor(key: #keyPath(Units.unitIndex), ascending: true)
            let unitDipalyName = NSSortDescriptor(key: #keyPath(Units.unitDisplayName), ascending: true)
            request.sortDescriptors = [sort1,sort,tempSort,unitDipalyName] //[sort1,sort,tempSort]
        }
        
        var predicate = NSPredicate(format: "project == %@", selectedProject.id!)
        
        var unitTypeFilters : [NSPredicate] = []
        
        for eachType in self.selectedTypeNamesArray{
            unitTypeFilters.append(NSPredicate(format: "typeName == %@", eachType))
        }
        
        var unitFacingFilter : [NSPredicate] = []
        for eachFacing in self.selectedFacingNamesArray{
            unitFacingFilter.append(NSPredicate(format: "facing CONTAINS[c] %@", eachFacing))
        }
        
        var builtUpFilters : [NSPredicate] = []
        for eachBuiltUp in self.selectedBuiltUpAreasArray{
            var tempBuiltUp = eachBuiltUp
            for eachUom in superAreaUomsArray{
                let uomStr : String = eachUom["superBuiltUpAreaUOM"] as! String
                if(tempBuiltUp.contains(uomStr)){
                    tempBuiltUp = tempBuiltUp.replacingOccurrences(of: String(format: " %@", uomStr), with: "")
                }
            }
            builtUpFilters.append(NSPredicate(format: "superBuiltUpArea CONTAINS[c] %@", tempBuiltUp))
        }
        
        var carperAreaFilters : [NSPredicate] = []
        for eachCarpetArea in self.selectedCarpetAreaArray{
            var tempCarpet = eachCarpetArea
            for eachUom in carpetUomsArray{
                let uomStr : String = eachUom["capetAreaUOM"] as! String
                if(tempCarpet.contains(uomStr)){
                    tempCarpet = tempCarpet.replacingOccurrences(of: String(format: " %@", uomStr), with: "")
                }
            }
            carperAreaFilters.append(NSPredicate(format: "carpetArea CONTAINS[c] %@", tempCarpet))
        }
        
        var bedRoomsFilter : [NSPredicate] = []
        for roomsCount in self.selectedBedRoomsArray{
            bedRoomsFilter.append(NSPredicate(format: "bedRooms.description == %@", roomsCount))
        }

        var bathRoomsFilter : [NSPredicate] = []
        for roomsCount in self.selectedBathRoomsArray{
            bathRoomsFilter.append(NSPredicate(format: "bathRooms.description == %@", roomsCount))
        }

        var floorPremiumFilter : [NSPredicate] = []
        for eachPremium in self.selectedFloorPremiums{
            floorPremiumFilter.append(NSPredicate(format: "floorPremium == %@", eachPremium))
        }
        
        var otherPremiumFilter : [NSPredicate] = []
        for eachPremium in self.selectedOtherPremiums{
                        
            let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "OtherPremiums")
            fetchRequest.resultType = .dictionaryResultType
            fetchRequest.propertiesToFetch = ["parentId"]
            let predicate = NSPredicate(format: "name CONTAINS[c] %@", eachPremium)
            fetchRequest.predicate = predicate
            let premiumsss = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)
            
            var otherPremUnits : [String] = []
            if(premiumsss.count > 0){
                for eachPremium in premiumsss{
                    if let prentId = eachPremium["parentId"] as? String{
                        otherPremUnits.append(prentId)
                    }
                }
                otherPremiumFilter.append(NSPredicate(format: "id IN %@", otherPremUnits)) //#keyPath(Units.allOtherPremiums),
            }
        }
        var miscArrayFilter : [NSPredicate] = []
        for eachMisc in self.selectedMiscArray{
            if(eachMisc == "Non Premium"){
                miscArrayFilter.append(NSPredicate(format: "floorPremium == nil AND otherPremiumsCount == 0"))
            }
        }
        
        if(landOnwerSwitch.isOn){
            if(selectedLandOwnerName == "None"){
                predicate = NSPredicate(format: "project == %@ AND hasLandOwner == %d", selectedProject.id!,landOnwerSwitch.isOn)
//                request.predicate = predicate
            }
            else{
                predicate = NSPredicate(format: "project == %@ AND hasLandOwner == %d AND owner.name == %@", selectedProject.id!,landOnwerSwitch.isOn,selectedLandOwnerName)
//                request.predicate = predicate
            }
        }
        else{
            predicate = NSPredicate(format: "project == %@", selectedProject.id!)
//            request.predicate = predicate
        }
        
        
        var allPredicates : [NSPredicate] = []
        
        allPredicates.append(predicate)

        if(!self.searchText.isEmpty){
            if(shouldEnable){
                let nameOrPhoneNumberPredicate = NSPredicate(format: "bookedClient.name CONTAINS[c] %@ OR bookedClient.phone CONTAINS[c] %@ OR description1 CONTAINS[c] %@",self.searchText,self.searchText,self.searchText)
                allPredicates.append(nameOrPhoneNumberPredicate)
            }
            else{
                let nameOrPhoneNumberPredicate = NSPredicate(format: "bookedClient.name CONTAINS[c] %@ OR bookedClient.phone CONTAINS[c] %@ OR unitDisplayName CONTAINS[c] %@",self.searchText,self.searchText,self.searchText)
                allPredicates.append(nameOrPhoneNumberPredicate)
            }
        }


        if(unitTypeFilters.count > 0)
        {
            let compounPredicate = NSCompoundPredicate.init(type: .or, subpredicates: unitTypeFilters)
            allPredicates.append(compounPredicate)
        }
        
        if(unitFacingFilter.count > 0)
        {
            let compounPredicate = NSCompoundPredicate.init(type: .or, subpredicates: unitFacingFilter)
            allPredicates.append(compounPredicate)
        }

        if(builtUpFilters.count > 0)
        {
            let compounPredicate = NSCompoundPredicate.init(type: .or, subpredicates: builtUpFilters)
            allPredicates.append(compounPredicate)
        }
        if(carperAreaFilters.count > 0)
        {
            let compounPredicate = NSCompoundPredicate.init(type: .or, subpredicates: carperAreaFilters)
            allPredicates.append(compounPredicate)
        }
        
        if(bedRoomsFilter.count > 0)
        {
            let bedRoomCompounPredicate = NSCompoundPredicate.init(type: .or, subpredicates: bedRoomsFilter)
            allPredicates.append(bedRoomCompounPredicate)
        }

        if(bathRoomsFilter.count > 0)
        {
            let compounPredicate = NSCompoundPredicate.init(type: .or, subpredicates: bathRoomsFilter)
            allPredicates.append(compounPredicate)
        }
        
        if(floorPremiumFilter.count > 0)
        {
            let compounPredicate = NSCompoundPredicate.init(type: .or, subpredicates: floorPremiumFilter)
            allPredicates.append(compounPredicate)
        }

        if(otherPremiumFilter.count > 0)
        {
            let compounPredicate = NSCompoundPredicate.init(type: .or, subpredicates: otherPremiumFilter)
            allPredicates.append(compounPredicate)
        }
        
        if(miscArrayFilter.count > 0){
            let compounPredicate = NSCompoundPredicate.init(type: .or, subpredicates: miscArrayFilter)
            allPredicates.append(compounPredicate)
        }

        
        let compounPredicate = NSCompoundPredicate.init(type: .and, subpredicates: allPredicates) //NSCompoundPredicate(andPredicateWithSubpredicates: allPredicates)

        request.predicate = compounPredicate
        
        fetchedResultsControllerUnits = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: "sectionIndex", cacheName:nil)
        fetchedResultsControllerUnits.delegate = self
        
        do {
            try fetchedResultsControllerUnits.performFetch()
            self.mUnitsCollectionView.reloadData()
            self.perform(#selector(adjustCollectionView), with: nil, afterDelay: 0.3)
            footerLabel.text = String(format: "Total Units : %d", (self.fetchedResultsControllerUnits.fetchedObjects?.count)!)
            self.totalUnitsCountLabel.text = String(format: "Total Units : %d", (self.fetchedResultsControllerUnits.fetchedObjects?.count)!)
            if((self.fetchedResultsControllerUnits.fetchedObjects?.count)! > 0){
                self.buildFloatingButton()
                self.showLandOwnerDetailsView()
                if(self.landOnwerSwitch.isOn){
                    self.blocksButton?.isHidden = true
                }
            }
            else{
                self.blocksButton?.isHidden = true
            }

        
//            for tempSection in fetchedResultsControllerUnits!.sections!{
//                print(tempSection.name)
//                print(tempSection.numberOfObjects)
//            }
//            let sectionInfo = self.fetchedResultsControllerUnits!.sections![0]
//            blocksButton.mTitleLabel.text = sectionInfo.name
            
//            for tempUnit in fetchedResultsControllerUnits!.fetchedObjects!{
//                print(tempUnit.sectionIndex)
//            }
//            mUnitsCollectionView.reloadData()
        }
        catch {
            fatalError("Error in fetching records")
        }

        if(self.fetchedResultsControllerUnits.fetchedObjects?.count == 0){
//            self.fetchAllUnits()
            if(fetchingLimit < 3){
                fetchingLimit = fetchingLimit + 1
//                self.performSelector(onMainThread: #selector(fetchAllUnits), with: nil, waitUntilDone: true)
                self.perform(#selector(fetchAllUnits), with: nil, afterDelay: 1.0)
            }
        }
    }
    @objc func adjustCollectionView(){
        
        self.mUnitsCollectionView.contentSize.height += 80
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

    }
    func fetchAllBlocks(){
        
        let request: NSFetchRequest<Blocks> = Blocks.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Blocks.index), ascending: true)
        request.sortDescriptors = [sort]

        let predicate = NSPredicate(format: "project CONTAINS[c] %@", selectedProject.id!)
        request.predicate = predicate

        fetchedResultsControllerBlocks = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        fetchedResultsControllerBlocks.delegate = self
        
        do {
            try fetchedResultsControllerBlocks.performFetch()
            mTableView.reloadData()
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    func fetchAllTowers(){
        
        let request: NSFetchRequest<Towers> = Towers.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Towers.towerIndex), ascending: true)
        request.sortDescriptors = [sort]
        
        let predicate = NSPredicate(format: "project CONTAINS[c] %@", selectedProject.id!)
        request.predicate = predicate
        
        if(fetchedResultsControllerTowers != nil){
            fetchedResultsControllerTowers.delegate = nil
            fetchedResultsControllerTowers = nil
        }
        
        fetchedResultsControllerTowers = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: "blockName", cacheName:nil)
        fetchedResultsControllerTowers.delegate = self
        
        do {
            try fetchedResultsControllerTowers.performFetch()
            mTableView.reloadData()
        }
        catch let error{
            print(error)
            fatalError("Error in fetching records")
        }
    }
    @IBAction func showOnlyLandOwnerUnits(_ sender: Any) {
        
        UIView.animate(withDuration: 2.0, animations: {
            if(self.landOnwerSwitch.isOn == false){
                self.landOwnerNameLabel.text = "None"
                self.selectedLandOwnerName = "None"
                self.leadingConstraintOfOwnerNameView.constant = 0
                self.widthConstraintOfOwnerNameView.constant = 0
                self.landOwnerNameView.isHidden = true
            }
            else{
                self.widthConstraintOfOwnerNameView.constant = (self.view.frame.size.width/2.0 - 1)
                self.leadingConstraintOfOwnerNameView.constant = 1
                self.landOwnerNameView.isHidden = false
            }
        }, completion: nil)

        if(selectedStatusForFilter == -1 || selectedStatusForFilter == nil){
            self.fetchAllUnits()
        }
        else{
            self.fetchUnitsWithSelectedStatus(selectedStatus: selectedStatusForFilter)
        }
    }
    @objc func showLandOwnersPopUp(){
        
        //fetcha all land owners
        
        if(landOnwerSwitch.isOn == false){
            return
        }
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "LandOwner")
        fetchRequest.resultType = .dictionaryResultType
        
        let predicate = NSPredicate(format: "project CONTAINS[c] %@", selectedProject.id!)
        fetchRequest.propertiesToFetch = ["name"]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.predicate = predicate
        
        var ownerNames = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)
        
        var tempDict : Dictionary<String,String> = [:]
        tempDict["name"] = "None"
        
        ownerNames.insert(tempDict as NSDictionary, at: 0)
        
//        print(ownerNames)

        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .LANDOWNER
        vc.landOwnersDataSorce = ownerNames as! Array<Dictionary<String, String>>
        var counter = 0
        if(ownerNames.count > 1){
            counter = ownerNames.count - 1
        }
        
        if(ownerNames.count == 1){
            vc.preferredContentSize = CGSize(width: 250, height: 1)
        }
        else{
            vc.preferredContentSize = CGSize(width: 250, height: counter * 44)
        }
        
        if(CGFloat((counter * 44)) > (self.view.frame.size.height - 150)){
            vc.preferredContentSize = CGSize(width: 250, height: (self.view.frame.size.height - 150))
        }
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
//        vc.tableViewDataSource = self.fetchedResultsControllerProjects!.fetchedObjects!
        
        popOver?.sourceView = self.landOwnerNameLabel

        vc.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)

    }
    func addRefreshControl() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.black
        refreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        mTableView.addSubview(refreshControl!)
        
        
        unitRefreshControl = UIRefreshControl()
        unitRefreshControl?.tintColor = UIColor.black
        unitRefreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        mUnitsCollectionView.addSubview(unitRefreshControl!)

    }
    @objc func refreshList() {
        
//        self.getProjects(UIButton())
//        let projecct = selectedProject
        
        let urlString = String(format:RRAPI.PROJECT_DETAILS, selectedProject.id!)
//        self.hideKeyBoard()
        self.getSelectedProjectDetails(urlString: urlString)
    }

    func buildFloatingButton(){
        blocksButton?.removeFromSuperview()
        blocksButton = nil
        blocksButton = ButtonView.instanceFromNib() as? ButtonView
        blocksButton.backgroundColor = UIColor.white
        self.view.addSubview(blocksButton)
        
//        if(self.fetchedResultsControllerUnits.fetchedObjects?.count == 0){
////            self.buildFloatingButton()
//            return
//        }
        let tempUnit : Units = self.fetchedResultsControllerUnits.object(at: IndexPath(row: 0, section: 0))
        blocksButton.mTitleLabel?.text = tempUnit.sectionTitle

        blocksButton.center = self.view.center
        self.view.bringSubviewToFront(blocksButton)
        
        blocksButton.clipsToBounds = true
        
        blocksButton.layer.masksToBounds = false
        blocksButton.layer.shadowColor = UIColor.lightGray.cgColor
        blocksButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        blocksButton.layer.shadowOpacity = 0.4
        blocksButton.layer.shadowRadius = 2.0
        blocksButton.layer.shouldRasterize = true
        blocksButton.layer.borderColor = UIColor.white.cgColor
        blocksButton.layer.shouldRasterize = true
        blocksButton.layer.rasterizationScale = UIScreen.main.scale
        blocksButton.layer.cornerRadius = 20
        
        blocksButton.center.y = self.view.center.y + (self.view.frame.size.height/2 - 80)
        blocksButton.subView.layer.cornerRadius = 20
//        blocksButton.frame.size = CGSize.init(width: 160, height: 40)
        
        let tapGuesture = UITapGestureRecognizer.init(target: self, action: #selector(showBlocks))
        blocksButton.addGestureRecognizer(tapGuesture)
        
        blocksButton.isHidden = true
        if(subPartTypeLabel.text == "Units" && self.fetchedResultsControllerUnits.fetchedObjects!.count > 0){
            blocksButton.isHidden = false
        }
    }
    @objc func hideKeyBoard(){
        
        self.view.endEditing(true)
//        self.searchBar.endEditing(true)
//
////        searchBar.isHidden = false
////        titleSubView.isHidden = false
////        searchButton.isHidden = false
//        self.showSearchBar(searchBar)
//        self.view.endEditing(true)

    }
    @objc func showBlocks() {
        
        //show blocks pop up
        
//        if(popUpDataDict.keys.count == 0){
//            return
//        }
        self.makeFloatButtonPopUpDataSource()
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .BLOCKS_FLOAT_BUTTON
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
        vc.selectedProjectId = selectedProject.id ?? ""
        vc.tableViewDataSource2 = self.popUpDataDict
        //        popOver?.barButtonItem = sender as? UIBarButtonItem
        
        popOver?.sourceView = blocksButton.mCenterLabelForPopUp
        
        //            popOver?.sourceRect = CGRect(x: self.view.center.x, y: projectsButton.frame.origin.y - 80, width: projectsButton.frame.size.width, height: projectsButton.frame.size.height)
        //            popOver?.sourceView?.frame.origin.x = self.view.center.x
        vc.delegate = self
        //        popOver?.sourceRect = optionsButton.frame
        
        self.present(navigationContoller, animated: true, completion: nil)
    }
    func makeFloatButtonPopUpDataSource(){
//        return
        floatPopUpRowCounter = 0
//        popUpDataDict.removeAll()
//        orderedBlocksArrayForPopUp.removeAllObjects()
//
        let blocks : [Blocks] = self.fetchedResultsControllerBlocks.fetchedObjects! //projectDetails.blocks!
        
        for tempBlock in blocks{

            // get all towers related to block
            let blockId = tempBlock.id

            let request: NSFetchRequest<Towers> = Towers.fetchRequest()
            let sort = NSSortDescriptor(key: #keyPath(Towers.towerIndex), ascending: true)
            request.sortDescriptors = [sort]

            let predicate = NSPredicate(format: "block CONTAINS[c] %@", blockId!)
            request.predicate = predicate

            let tempFetchedResultsControllerTowers = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)

            do {
                try tempFetchedResultsControllerTowers.performFetch()

                let filterredTowers : [Towers] = tempFetchedResultsControllerTowers.fetchedObjects! //projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }

                var towersArray : [Towers] = [Towers]()

                for tempTower in filterredTowers{
                    let towerId = tempTower.id
                    let filterredUnits = RRUtilities.sharedInstance.model.getUnitsByOnyTowerID(towerID: tempTower.id!)
//                    let filterredUnits = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(towerId!))! }
                    /// fetch units for tower
                    if(filterredUnits != nil && filterredUnits!.count > 0){
                        towersArray.append(tempTower)
                    }
                }
                if(towersArray.count > 0){
                    orderedBlocksArrayForPopUp.add(tempBlock.name!)
                    floatPopUpRowCounter = floatPopUpRowCounter + towersArray.count
                    popUpDataDict[tempBlock.name!] = towersArray
                }
            }
            catch {
                fatalError("Error in fetching records")
            }
        }
        
//        print(popUpDataDict)
//        print(popUpDataDict.keys)
//        floatPopUpRowCounter = floatPopUpRowCounter + popUpDataDict.keys.count
        
    }

    func buildDataSourceAsFloorWise(){
        
//        for tower in projectDetails.towers!{
//            totalNumberOfFloors += tower.total_floors!
//        }
        
//        currentTitlesOfBlocks = orderdSectionTitls.array as! [String]
//        currentUnitsDataSource = numberOfSections // for search
        
//        currentTitlesOfBlocks.removeAll()
//        currentUnitsDataSource.removeAll()
        orderdSectionTitls.removeAllObjects()
        numberOfSections.removeAll()
        
        // number blocks , each block with towers and then each tower with floors , floor with units
        
//        let blocks = projectDetails.blocks!
        
//        for tempBlock in blocks{
//
//            let blockId = tempBlock._id
//
//            //get towers related to block Id
//
//            let towers = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }
//
//            //parse based on tower type :
//
//            for tempTower in towers{
////                print(tempTower)
//
//                //get units related to towers and index them as per the floor
//
//                let towerId = tempTower._id
//
//                var filterredUnits = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(towerId!))! }
//
//                filterredUnits.sort { ($0.floor?.index!)! <= ($1.floor?.index!)! }
//
////                for tempUnit in filterredUnits{
////                    print(tempUnit.unitNo?.index)
////                }
//                if(tempTower.towerType == 0){
//
//                    // ** Build dictionary **
//
//                    for tempUnit in filterredUnits{
//                        // tempUnit
//                        let floorIndex = tempUnit.floor?.index
////                        print(floorIndex ?? "")
//
//                        let sectionTitle = String(format: "%@ - %@ - %d", tempBlock.name! , tempTower.name!,floorIndex!)
//
//                        orderdSectionTitls.add(sectionTitle)
//
//                        var unitArray = numberOfSections[sectionTitle]
//
//                        if(unitArray == nil){
//                            unitArray = [tempUnit]
//                            numberOfSections[sectionTitle] = unitArray
//                        }
//                        else{
//                            unitArray?.append(tempUnit)
////                            unitArray?.sort( by: { Int($0.description!) ?? 0 < Int($1.description!) ?? 0 })
////                            print(tempUnit.description)
//                            unitArray?.sort( by: { $0.unitNo?.index! ?? 0 < $1.unitNo?.index! ?? 0 })
////                            unitArray?.sort( by: { $0.unitNo?.index! ?? 0 < $1.unitNo?.index! ?? 0 })
//                            numberOfSections[sectionTitle] = unitArray
//                        }
//                    }
//                }
//                else
//                {
//
//                    for tempUnit in filterredUnits{
//                        // tempUnit
////                        let floorIndex = tempUnit.floor?.index
////                        print(floorIndex ?? "")
//
//                        let sectionTitle = String(format: "%@ - %@", tempBlock.name! , tempTower.name!)
//
//                        orderdSectionTitls.add(sectionTitle)
//
//                        var unitArray = numberOfSections[sectionTitle]
//
//                        if(unitArray == nil){
//                            unitArray = [tempUnit]
//                            numberOfSections[sectionTitle] = unitArray
//                        }
//                        else{
//                            unitArray?.append(tempUnit)
//                            print(tempUnit.floor?.index,tempUnit.floor?.displayName)
//                            print(tempUnit.unitNo?.index,tempUnit.unitNo?.displayName)
//
//
//
////                            if(tempTower.towerType == 1){
////                                unitArray?.sort( by: { $0.unitNo!.displayName! < $1.unitNo!.displayName! })
////                            }
////                            else if(tempTower.towerType == 2){
////                                unitArray?.sort( by: { $0.unitNo?.index! ?? 0 < $1.unitNo?.index! ?? 0 })
//
////                            print("tower type \(tempTower.towerType)")
////                            if(sectionTitle == "Block A - Row A"){
////                                print("tower type \(tempTower.towerType)")
////                            }
////                            if(tempTower.towerType == 2){
////                                unitArray = unitArray?.reversed()
////                            }
////                            unitArray?.sort( by: { Int($0.description!) ?? 0 < Int($1.description!) ?? 0 })
//                            unitArray?.sort( by: { $0.unitNo?.index! ?? 0 < $1.unitNo?.index! ?? 0 })
////                            print(tempUnit.description)
////                            }
//                            numberOfSections[sectionTitle] = unitArray
////                            for temperOne in unitArray ?? []{
////                                print(temperOne.description)
////                            }
//                        }
//                    }
//                }
////                print(numberOfSections.keys)
////                print(orderdSectionTitls)
//            }
//
////            print(numberOfSections.keys)
////            print(orderdSectionTitls)
////            currentTitlesOfBlocks = orderdSectionTitls.array as! [String]
////            currentUnitsDataSource = numberOfSections // for search
////            if(currentTitlesOfBlocks.count > 0){
////                blocksButton.mTitleLabel.text = currentTitlesOfBlocks[0]
////            }
//        }
    }
    //MARK: - Tableview Delegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = self.fetchedResultsControllerBlocks!.sections else {
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
            noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
            noDataLabel.text          = "No data available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return sectionInfo.numberOfObjects //currentBlocksArray.count //(projectDetails.blocks?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : BlockDetailsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "blockDetailCell",
            for: indexPath) as! BlockDetailsTableViewCell
        
        let block : Blocks = self.fetchedResultsControllerBlocks!.object(at: indexPath) //currentBlocksArray[indexPath.row]
        let name = block.name
        cell.mBlockNameLabel.text = name
                
        cell.unitsCountLabel.text = String(format: "Units: %d", block.numberOfUnits)
        
        cell.mTowersInfoLabel.text = String(format: "Towers/Rows : %d", block.numberOfTowers)
        
        cell.mCollectionView.delegate = self
        cell.mCollectionView.dataSource = self
        
        cell.mCollectionView.mParentIndexPath = indexPath
        
        cell.subContentView.layer.cornerRadius = 8
        cell.subContentView.layer.borderWidth = 2
        cell.subContentView.layer.borderColor = UIColor.clear.cgColor
        cell.subContentView.layer.shadowRadius = 4
        cell.subContentView.layer.masksToBounds = false
        cell.subContentView.layer.shadowOffset = .zero
        cell.subContentView.layer.shadowRadius = 2
        cell.subContentView.layer.shadowOpacity = 0.3
//        cell.subContentView.layer.borderColor = UIColor.white.cgColor
        
//        cell.contentView.bringSubviewToFront(cell.subContentView)
        
        return cell
    }
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
//
//        let footerLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width:footerView.frame.size.width , height: 50))
//        footerLabel.text = String(format: "Total Units : %d", (projectDetails.units?.count)!)
//        footerLabel.font = UIFont(name: "Montserrat-Regular", size: 14)
//        footerLabel.textAlignment = .center
//        footerLabel.backgroundColor = UIColor.orange
//        footerView.addSubview(footerLabel)
//
//        return footerView
//    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let tempCell = cell as! BlockDetailsTableViewCell
            tempCell.mCollectionView.reloadData()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectedBlockInUnitBlocksView
        
        let block : Blocks = self.fetchedResultsControllerBlocks!.object(at: indexPath) //currentBlocksArray[indexPath.row]
//        let name = block.name
        
        let blockId = block.id
        
        //        let towers = projectDetails.towers!
        
        //        let towerID = projectDetails.towers![section]._id
//        let filteredTowers = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }

//        selectedBlockInUnitBlocksView = String(format: "%@ - %@", block.name,filteredUnits[0].name)
        //
        self.mCollectionView.isHidden = true
        unitsView.isHidden = false
        footerLabel.isHidden = true
        self.view.bringSubviewToFront(unitsView)
        self.mTableView.isHidden = true
        self.shouldShowFilterButton(shouldShow: true)
//        unitsView.backgroundColor = UIColor.green
        
//        mUnitsCollectionView.delegate = self
//        mUnitsCollectionView.dataSource = self
//        mUnitsCollectionView.reloadData()
//        selectedIndexForDetailedProjectView = 1
//
//        let lastSection = currentTitlesOfBlocks.count - 1
        
//        if(lastSection != -1){
//            let key  = currentTitlesOfBlocks[lastSection]
//            let unitsArray : Array<UnitDetails> = (currentUnitsDataSource[key])!
//            let lastRow = unitsArray.count - 1
//            let indexPath = IndexPath(item: lastRow, section: lastSection)
//            self.mUnitsCollectionView.reloadItems(at: [indexPath])
//            self.colorCollectionView.reloadData()
            //        mUnitsCollectionView.reloadData()
            //        mUnitsCollectionView.layoutIfNeeded()
            
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                //            self.reloadCollectionView()
//                self.mUnitsCollectionView.reloadItems(at: [indexPath])
//            }
//        }
        selectedIndexForDetailedProjectView = 1
        if(selectedIndexForDetailedProjectView == 1){
            allBlocksLabel.text = "All Units"
            allBlocksLabel.textAlignment = .left
            statusLabel.isHidden = false
            
            if(blocksButton != nil){
                blocksButton?.isHidden = false
                self.view.bringSubviewToFront(blocksButton)
            }
            subPartTypeLabel.text = "Units"
            
        }
        else{
            allBlocksLabel.text = "All Blocks"
            allBlocksLabel.textAlignment = .center
            statusLabel.isHidden = true
            blocksButton.isHidden = true
            self.view.bringSubviewToFront(blocksButton)
            subPartTypeLabel.text = "Summary"
        }
        
//        let filteredTowers = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }

        //fetch tower with ID and find index of that in units n scroll to that index
        
        var tempFetchedResultsControllerTowers : NSFetchedResultsController<Towers>!
        
        let request: NSFetchRequest<Towers> = Towers.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Towers.towerIndex), ascending: true)
        request.sortDescriptors = [sort]
        
        let predicate = NSPredicate(format: "block CONTAINS[c] %@", blockId!)
        request.predicate = predicate
        
        tempFetchedResultsControllerTowers = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        
        do {
            try tempFetchedResultsControllerTowers.performFetch()
          }
        catch {
            fatalError("Error in fetching records")
        }
        
        if(tempFetchedResultsControllerTowers.fetchedObjects!.count > 0){
            
            self.showSelectedTowerFromFloatButton(selectedTower: tempFetchedResultsControllerTowers.fetchedObjects![0], selectedBlock: block.name!)
        }
        DispatchQueue.main.async {
            self.mUnitsCollectionView.reloadData()
        }

    }
    func resetTopFileter(){
        
        self.selectedStatusForFilter = -1
        self.landOnwerSwitch.isOn = false
        
        if(selectedIndexForDetailedProjectView == 1){
            allBlocksLabel.text = "All Units"
            allBlocksLabel.textAlignment = .left
            statusLabel.isHidden = false
            
            if(blocksButton != nil){
                blocksButton?.isHidden = false
                self.view.bringSubviewToFront(blocksButton)
            }
            subPartTypeLabel.text = "Units"
            
        }
        else{
            allBlocksLabel.text = "All Blocks"
            allBlocksLabel.textAlignment = .center
            statusLabel.isHidden = true
            if(blocksButton != nil){
                blocksButton.isHidden = true
                self.view.bringSubviewToFront(blocksButton)
            }
            subPartTypeLabel.text = "Summary"
        }
    }
    //MARK: - CollectionView Delegate & DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if(collectionView === mUnitsCollectionView){
            
            if (self.fetchedResultsControllerUnits!.sections!.count > 0) {
                self.mUnitsCollectionView.restore()
            } else {
                
                let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: mUnitsCollectionView.bounds.size.width, height: mUnitsCollectionView.bounds.size.height))
                messageLabel.text = "No data available"
                messageLabel.textColor = .black
                messageLabel.numberOfLines = 0;
                messageLabel.textAlignment = .center;
                messageLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
                messageLabel.sizeToFit()
                
                self.mUnitsCollectionView.backgroundView = messageLabel;
            }
            
            return fetchedResultsControllerUnits!.sections!.count
        }
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView === mUnitsCollectionView){
            
//            let towerID = projectDetails.towers![section]._id
//            let filteredUnits = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(towerID!))! }
//
//            return filteredUnits.count
//            let key  = currentTitlesOfBlocks[section]
//            let unitsArray : Array<UnitDetails> = (currentUnitsDataSource[key])!
            
            let sectionInfo = fetchedResultsControllerUnits!.sections![section]
            return sectionInfo.numberOfObjects
            
//            return unitsArray.count
        }
        
        return 6 //** Statuses
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
//
//        if(collectionView == mUnitsCollectionView){
//            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//            let totalSpace = flowLayout.sectionInset.left
//                + flowLayout.sectionInset.right
//                + (flowLayout.minimumInteritemSpacing * CGFloat(4 - 1))
//            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(4))
//            return CGSize(width: size, height: size)
//        }
//        else{
//            return CGSize(width: 0, height: 0)
//        }
//
//    }
//    func collectionView(collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//
//        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//        let totalSpace = flowLayout.sectionInset.left
//            + flowLayout.sectionInset.right
//            + (flowLayout.minimumInteritemSpacing * CGFloat(4 - 1))
//        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(4))
//        return CGSize(width: size, height: size)
//    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView === colorCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCollectionViewCell
            
            let statucColorDict = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: indexPath.row)
            cell.contentView.layoutIfNeeded()
            cell.statusTitleLabel.text = statucColorDict["statusString"] as? String
            cell.statusColorIndicatorView.backgroundColor = statucColorDict["color"] as? UIColor
            
            cell.subContentView.backgroundColor = UIColor.hexStringToUIColor(hex: "f8fbff")
            cell.subContentView.layoutIfNeeded()
            
            cell.statusTitleLabel.numberOfLines = 1
            cell.statusTitleLabel.font = UIFont(name: "Montserrat-Regular", size: 14)
            
            cell.leadingOfColorLabel.constant = 0
            cell.trailingOfColorLabel.constant = 0
//            cell.statusTitleLabel.preferredMaxLayoutWidth = 40

            cell.layoutIfNeeded()
            return cell
        }
        else if(collectionView === mCollectionView){
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "blockCell", for: indexPath) as! BlockInfoCollectionViewCell
            
            let statucColorDict = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: indexPath.row)
            
            cell.mSubContentView.backgroundColor = statucColorDict["color"] as? UIColor
            cell.mStatusTypeLabel.text = statucColorDict["statusString"] as? String
            cell.mStatusTypeLabel.textColor = UIColor.white
            let tempCountDict =  self.getStatusOfUnit(indexPath: indexPath,isBlock: false,parentIndexPath: indexPath)
//            cell.mStatusTypeNumberLabel.text = String(tempCountDict["count"]! )
            
//            cell.trailingConstraintOfStatusTypeLabel.constant = 0
//            cell.leadContraintOfStatusTypeLabel.constant = 0
            
            cell.mStatusTypeNumberLabel.text =  String(format:"%d", tempCountDict["count"]!)
            cell.mStatusTypeNumberLabel.textColor = UIColor.white
            cell.widthConstraintOfBlockCell.constant = (mCollectionView.frame.size.width / 6)
//            cell.mStatusTypeLabel.preferredMaxLayoutWidth = 70;
            
            return cell

        }
        else if(collectionView === mUnitsCollectionView){
         
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "unitCell", for: indexPath) as! UnitCollectionViewCell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "unitCell", for: indexPath) as! UnitDetailsCollectionViewCell
            
//            let key : String = currentTitlesOfBlocks[indexPath.section]
//            let unitsArray = currentUnitsDataSource[key]
            
            
            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
            
//            let towerID = projectDetails.towers![indexPath.section]._id
//            let filteredUnits : [UnitDetails] = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(towerID!))! }
//
//            let unitIndex = filteredUnits[indexPath.row].unitNo?.index
//b
//            print(indexPath.section)
//            print(indexPath.row)
//            let tempUnit : UnitDetails = unitsArray![indexPath.row]
            
            
//            let sectionInfo = fetchedResultsControllerUnits!.sections![indexPath.section]
            
//            print(sectionInfo.numberOfObjects)
            
            // sort the objects
            
//            let sortedUnits = self.sortUnitsAsPerUnitNumberForSection(sectionToSort: indexPath.section)

            let tempUnit : Units = self.fetchedResultsControllerUnits.object(at: indexPath) //sortedUnits[indexPath.row]
            //self.fetchedResultsControllerUnits.object(at: indexPath)
            //sortedUnits[indexPath.row] //sectionInfo.objects![indexPath.row] as! Units

//            let towerId = tempUnit.tower
            
            let towerType =  tempUnit.towerType // tempTower[0].towerType
            
            let statucColorDict  = RRUtilities.sharedInstance.getColorAccordingToUnitStatusForCollectionView(status: Int(tempUnit.status))
            
            if(tempUnit.status == UNIT_STATUS.VACANT.rawValue){
                let statucColorDict = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: UNIT_STATUS.VACANT.rawValue)

                cell.unitNumberLabel.textColor = statucColorDict["color"] as? UIColor
            }
            else{
                cell.unitNumberLabel.textColor = .white
            }
            if(towerType == 0){
                
                if(tempUnit.floorPremium != nil ){ //(tempUnit.otherPremiums != nil && (tempUnit.otherPremiums?.count)! > 0)
                    cell.unitImageView.isHidden = false
                }
                else{
                    cell.unitImageView.isHidden = true
                }
                
                if((tempUnit.otherPremiums?.count ?? 0 > 0) || (tempUnit.extraPremiums?.count ?? 0 > 0)){
                    cell.premiumUnitImageView.isHidden = false
                }
                else{
                    cell.premiumUnitImageView.isHidden = true
                }
                
//                manageUnitStatus
                
                if(tempUnit.manageUnitStatusStr == "1C"){ //Cancel
                    cell.unitStatusLabel.text = "C"
                    cell.unitStatusLabel.isHidden = false
                }
                else if(tempUnit.manageUnitStatusStr == "1T"){ //Transfer
                    cell.unitStatusLabel.text = "T"
                    cell.unitStatusLabel.isHidden = false
                }
                else if(tempUnit.manageUnitStatusStr == "2"){
                    cell.unitStatusLabel.text = "OT"
                    cell.unitStatusLabel.isHidden = false
                }
                else{
                    cell.unitStatusLabel.text = ""
                    cell.unitStatusLabel.isHidden = true
                }
                
                if(tempUnit.bookingFormSatus == 2){
                    cell.unitApprovedStatusLabel.text = "A"
                    cell.unitApprovedStatusLabel.isHidden = false
                }
                else{
                    cell.unitApprovedStatusLabel.text = ""
                    cell.unitApprovedStatusLabel.isHidden = true
                }
//                else if(tempUnit.stat){
//
//                }
//                cell.unitNumberLabel.text =  tempUnit.description1//String(format: "%d", (tempUnit.unitNo?.index!)!)
                
                let shouldEnable = UserDefaults.standard.bool(forKey: "Unit Description Enabled")
                
                if(shouldEnable){
                    cell.unitNumberLabel.text = tempUnit.description1
                }
                else{
                    cell.subView.layoutIfNeeded()
                    cell.unitNumberLabel.layoutIfNeeded()
                    cell.unitNumberLabel.text = String(format: "%d", (tempUnit.unitIndex))
                    if(tempUnit.unitIndex == -1){
                        cell.unitNumberLabel.text = tempUnit.unitDisplayName
                    }
                    cell.contentView.layoutSubviews()
                }
                
                cell.unitNumberLabel.preferredMaxLayoutWidth = (collectionView.frame.size.width - 48) / 4

                cell.unitCellWidthConstraint.constant = (collectionView.frame.size.width - 48) / 4
                
//                print(cell.unitNumberLabel.preferredMaxLayoutWidth)

                cell.subView.layer.cornerRadius = 4
                cell.subView.backgroundColor = statucColorDict["color"] as? UIColor
                
                if(tempUnit.hasLandOwner){
                    cell.landOwnerLabel.isHidden = false
                }
                else{
                    cell.landOwnerLabel.isHidden = true
                }
                
                cell.subView.addGestureRecognizer(longGesture)
                
                cell.subView.layoutIfNeeded()
                cell.layoutIfNeeded()
                cell.unitNumberLabel.setNeedsLayout()
                cell.unitNumberLabel.setNeedsDisplay()
                cell.unitNumberLabel.layoutIfNeeded()
                
                cell.reloadInputViews()
                return cell
            }
            else if(towerType == 1){
                
                let singleUnitCell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleUnit", for: indexPath) as! SingleUnitCollectionViewCell
                
                if(tempUnit.status == UNIT_STATUS.VACANT.rawValue){
                    let statucColorDict = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: UNIT_STATUS.VACANT.rawValue)

                    singleUnitCell.floorNameLabel.textColor = statucColorDict["color"] as? UIColor
                }
                else{
                    singleUnitCell.floorNameLabel.textColor = .white
                }
                
                let shouldEnable = UserDefaults.standard.bool(forKey: "Unit Description Enabled")
                
                if(shouldEnable){
                    singleUnitCell.floorNameLabel.text = tempUnit.description1
                    singleUnitCell.unitIndexLabel.text = ""
                    singleUnitCell.heightOfUnitIndexLabel.constant = 0
                }
                else{
                    singleUnitCell.floorNameLabel.text = String(format: "%d", (tempUnit.floorIndex))
                    singleUnitCell.unitIndexLabel.text = ""
                    singleUnitCell.heightOfUnitIndexLabel.constant = 0
                }
                
                
                if(tempUnit.manageUnitStatusStr == "1C"){ //Cancel
                    singleUnitCell.unitStatusLabel.text = "C"
                    singleUnitCell.unitStatusLabel.isHidden = false
                }
                else if(tempUnit.manageUnitStatusStr == "1T"){ //Transfer
                    singleUnitCell.unitStatusLabel.text = "T"
                    singleUnitCell.unitStatusLabel.isHidden = false
                }
                else if(tempUnit.manageUnitStatusStr == "2"){
                    singleUnitCell.unitStatusLabel.text = "OT"
                    singleUnitCell.unitStatusLabel.isHidden = false
                }
                else{
                    singleUnitCell.unitStatusLabel.text = ""
                    singleUnitCell.unitStatusLabel.isHidden = true
                }
                
                if(tempUnit.bookingFormSatus == 2){
                    singleUnitCell.unitApprovedStatusLabel.text = "A"
                    singleUnitCell.unitApprovedStatusLabel.isHidden = false
                }
                else{
                    singleUnitCell.unitApprovedStatusLabel.text = ""
                    singleUnitCell.unitApprovedStatusLabel.isHidden = true
                }


                let cellWidth = (collectionView.frame.size.width - 24) / 2

                singleUnitCell.floorNameLabel.preferredMaxLayoutWidth = cellWidth
                
                singleUnitCell.widthOfCell.constant = cellWidth

                if(tempUnit.hasLandOwner){
                    singleUnitCell.landOwnerLabel.isHidden = false
                }
                else{
                    singleUnitCell.landOwnerLabel.isHidden = true
                }
                
                singleUnitCell.subView.backgroundColor = statucColorDict["color"] as? UIColor
                singleUnitCell.subView.layer.cornerRadius = 4.0

                singleUnitCell.widthOfCell.constant = cellWidth
                singleUnitCell.subView.addGestureRecognizer(longGesture)
                singleUnitCell.layoutIfNeeded()

                if(tempUnit.floorPremium != nil){
                    singleUnitCell.unitImageView.isHidden = false
                }
                else{
                    singleUnitCell.unitImageView.isHidden = true
                }
                if(tempUnit.otherPremiums?.count ?? 0 > 0 || tempUnit.extraPremiums?.count ?? 0 > 0){
                    singleUnitCell.premiumUnitImageView.isHidden = false
                }
                else{
                    singleUnitCell.premiumUnitImageView.isHidden = true
                }
                return singleUnitCell
                
            }
            else if(towerType == 2){
                
                if(tempUnit.floorPremium != nil){
                    cell.unitImageView.isHidden = false
                }
                else{
                    cell.unitImageView.isHidden = true
                }
                if((tempUnit.otherPremiums?.count ?? 0 > 0) || (tempUnit.extraPremiums?.count ?? 0 > 0)){
                    cell.premiumUnitImageView.isHidden = false
                }
                else{
                    cell.premiumUnitImageView.isHidden = true
                }
                                
                if(tempUnit.manageUnitStatusStr == "1C"){ //Cancel
                    cell.unitStatusLabel.text = "C"
                    cell.unitStatusLabel.isHidden = false
                }
                else if(tempUnit.manageUnitStatusStr == "1T"){ //Transfer
                    cell.unitStatusLabel.text = "T"
                    cell.unitStatusLabel.isHidden = false
                }
                else if(tempUnit.manageUnitStatusStr == "2"){ //Assign
                    cell.unitStatusLabel.text = "OT"
                    cell.unitStatusLabel.isHidden = false
                }
                else{
                    cell.unitStatusLabel.text = ""
                    cell.unitStatusLabel.isHidden = true
                }
                
                if(tempUnit.bookingFormSatus == 2){
                    cell.unitApprovedStatusLabel.text = "A"
                    cell.unitApprovedStatusLabel.isHidden = false
                }
                else{
                    cell.unitApprovedStatusLabel.text = ""
                    cell.unitApprovedStatusLabel.isHidden = true
                }

                // Booking form status

//                cell.unitNumberLabel.text =  tempUnit.description//String(format: "%d", (tempUnit.unitNo?.index!)!)
                
                let shouldEnable = UserDefaults.standard.bool(forKey: "Unit Description Enabled")
                
                if(shouldEnable){
                    cell.unitNumberLabel.text = tempUnit.description1
                }
                else{
                    
                    cell.subView.layoutIfNeeded()
                    cell.unitNumberLabel.layoutIfNeeded()
                    cell.unitNumberLabel.text = String(format: "%d", (tempUnit.unitIndex))
                    if(tempUnit.unitIndex == -1){
                        cell.unitNumberLabel.text = tempUnit.unitDisplayName
                    }
                    cell.contentView.layoutSubviews()
                }

                if(tempUnit.hasLandOwner){
                    cell.landOwnerLabel.isHidden = false
                }
                else{
                    cell.landOwnerLabel.isHidden = true
                }

//                cell.unitNumberLabel.preferredMaxLayoutWidth = 72;
                cell.unitNumberLabel.preferredMaxLayoutWidth = (collectionView.frame.size.width - 48) / 4
                
                cell.unitCellWidthConstraint.constant = (collectionView.frame.size.width - 48) / 4
//                cell.unitNumberLabel.preferredMaxLayoutWidth = cell.unitCellWidthConstraint.constant;
                
//                print(cell.unitNumberLabel.preferredMaxLayoutWidth)
                
                cell.subView.layer.cornerRadius = 4
                cell.subView.backgroundColor = statucColorDict["color"] as? UIColor
                
                cell.subView.addGestureRecognizer(longGesture)
                
                cell.subView.layoutIfNeeded()
                cell.layoutIfNeeded()
                
                cell.unitNumberLabel.layoutIfNeeded()
                return cell
            }            
            return cell

        }
        else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "blockCell", for: indexPath) as! BlockInfoCollectionViewCell
            
            let tempCollectionView = collectionView as! CustomCollectionView
//            print(tempCollectionView.mParentIndexPath.row)
//            let block : BlockDetails = currentBlocksArray[tempCollectionView.mParentIndexPath.row]
            //self.fetchedResultsControllerBlocks!.object(at: tempCollectionView.mParentIndexPath)
            //currentBlocksArray[tempCollectionView.mParentIndexPath.row]
            
            let tmepBlcok : Blocks = self.fetchedResultsControllerBlocks.object(at: tempCollectionView.mParentIndexPath)
            
//            print(tmepBlcok.blockStats)
            
            let statucColorDict  = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: indexPath.row)
            
            let tempCountDict =  self.getStatusOfUnit(indexPath: indexPath,isBlock: true,parentIndexPath: tempCollectionView.mParentIndexPath)

//            print(tempCountDict)

            if((self.fetchedResultsControllerBlocks.fetchedObjects!.count) > 0){
                
//                if(block.stats != nil){
//                    let statsArray : [STAT] = block.stats!
                
//                    print(statsArray)
                    
                    cell.mSubContentView.backgroundColor = UIColor.white
                    cell.mStatusTypeLabel.text = statucColorDict["statusString"] as? String
                    cell.mStatusTypeLabel.textColor = UIColor.lightGray
                    
//                    cell.mStatusTypeNumberLabel.text  = String(format: "%d", statusOfCell.count!)
//                    cell.mStatusTypeNumberLabel.textColor = statucColorDict["color"] as? UIColor

//                    cell.mStatusTypeNumberLabel.text = String(tempCountDict["count"]! )
                
                    cell.mStatusTypeNumberLabel.text =  String(format:"%d", tempCountDict["count"]!)
                cell.mStatusTypeNumberLabel.textColor = statucColorDict["color"] as? UIColor

//                    var isStatusAvailable = false
                
//                    for statusOfCell in statsArray{
//
//                        if(indexPath.row == statusOfCell.status){
//                            isStatusAvailable = true
////                            print("status")
////                            print(statusOfCell.status)
//                            cell.mStatusTypeNumberLabel.text  = String(format: "%d", statusOfCell.count!)
//                            cell.mStatusTypeNumberLabel.textColor = statucColorDict["color"] as? UIColor
//                            break
//                        }
//                    }
                    
//                    if(isStatusAvailable == false){
//                        cell.mStatusTypeNumberLabel.text  = "0"
//                        cell.mStatusTypeNumberLabel.textColor = statucColorDict["color"] as? UIColor
//                    }
//                }
//                else{
//
//                    cell.mSubContentView.backgroundColor = UIColor.white
//                    cell.mStatusTypeLabel.text = statucColorDict["statusString"] as? String
//                    cell.mStatusTypeLabel.textColor = UIColor.lightGray
//
//                    cell.mStatusTypeNumberLabel.text  = "0"
//                    cell.mStatusTypeNumberLabel.textColor = statucColorDict["color"] as? UIColor
//                }
            }
            
//            let tempCountDict =  self.getStatusOfBlocks(indexPath:  tempCollectionView.mParentIndexPath as NSIndexPath)
//            cell.mStatusTypeNumberLabel.text = String(tempCountDict["count"]! )
//
//            cell.mStatusTypeNumberLabel.text =  String(format:"%d", tempCountDict["count"]!)
//            cell.mStatusTypeNumberLabel.textColor = UIColor.white
//            cell.mStatusTypeLabel.preferredMaxLayoutWidth = 70;
            
            return cell
        }
    }
    func sortUnitsAsPerUnitNumberForSection(sectionToSort : Int)->[Units]{
        
        let sectionInfo = self.fetchedResultsControllerUnits.sections![sectionToSort]
        var tempUnits = sectionInfo.objects as! [Units]
        
//        let temper = tempUnits.sorted(by: { $0.name < $1.name })

        
        let shouldEnable = UserDefaults.standard.bool(forKey: "Unit Description Enabled")
        
//        if(shouldEnable){
//            tempUnits.sort(by: { $0.unitDisplayName < $1.unitDisplayName })
//        }
//        else{
            tempUnits.sort(by: { $0.unitIndex < $1.unitIndex })
//        }
        
        return tempUnits
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        print("COLL CELL SELECTED")
        
        //blockWiseController
//        self.searchBar.endEditing(true)
        
        if(collectionView == colorCollectionView){
            return
        }
        
        if(collectionView != mCollectionView && collectionView != mUnitsCollectionView ){
            unitsView.isHidden = false
            footerLabel.isHidden = true
            self.view.bringSubviewToFront(unitsView)
            self.mTableView.isHidden = true
            self.shouldShowFilterButton(shouldShow: true)
//            unitsView.backgroundColor = UIColor.green
            
//            mUnitsCollectionView.delegate = self
//            mUnitsCollectionView.dataSource = self
            mUnitsCollectionView.reloadData()
            selectedIndexForDetailedProjectView = 1
            
//            let lastSection = currentTitlesOfBlocks.count - 1
            
//            if(lastSection != -1){
////                let key  = currentTitlesOfBlocks[lastSection]
////                let unitsArray : Array<UnitDetails> = (currentUnitsDataSource[key])!
////                let lastRow = unitsArray.count - 1
////                let indexPath = IndexPath(item: lastRow, section: lastSection)
////                self.mUnitsCollectionView.reloadItems(at: [indexPath])
////                self.colorCollectionView.reloadData()
////                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
////                    //            self.reloadCollectionView()
////                    self.mUnitsCollectionView.reloadItems(at: [indexPath])
////                }
//            }
            //        mUnitsCollectionView.reloadData()
            //        mUnitsCollectionView.layoutIfNeeded()
            
            
            

           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                self.view.bringSubviewToFront(self.colorCollectionView)
                self.colorCollectionView.reloadData()
            }


            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.reloadCollectionView()
            }
            
            if(selectedIndexForDetailedProjectView == 1){
                allBlocksLabel.text = "All Units"
                allBlocksLabel.textAlignment = .left
                statusLabel.isHidden = false
                if(blocksButton != nil){
                    blocksButton.isHidden = false
                    self.view.bringSubviewToFront(blocksButton)
                }
                subPartTypeLabel.text = "Units"
            }
            else{
                allBlocksLabel.text = "All Blocks"
                allBlocksLabel.textAlignment = .center
                statusLabel.isHidden = true
                blocksButton.isHidden = true
                self.view.bringSubviewToFront(blocksButton)
                subPartTypeLabel.text = "Summary"
            }
            if(self.mTableView.cellForRow(at: indexPath) != nil)
            {
                let selectedCell : BlockDetailsTableViewCell = (self.mTableView.cellForRow(at: indexPath) as! BlockDetailsTableViewCell)
                
                if(self.fetchedResultsControllerBlocks.fetchedObjects!.count > 0){
                    // get tableiview cell then get indexpath of collectionview
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        let block : Blocks = self.fetchedResultsControllerBlocks.object(at: selectedCell.mCollectionView.mParentIndexPath)  //self.currentBlocksArray[selectedCell.mCollectionView.mParentIndexPath.row]
                        
                        let blockId = block.id
                        var tempFetchedResultsControllerTowers : NSFetchedResultsController<Towers>!
                        
                        let request: NSFetchRequest<Towers> = Towers.fetchRequest()
                        let sort = NSSortDescriptor(key: #keyPath(Towers.towerIndex), ascending: true)
                        request.sortDescriptors = [sort]
                        
                        let predicate = NSPredicate(format: "block CONTAINS[c] %@", blockId!)
                        request.predicate = predicate
                        
                        tempFetchedResultsControllerTowers = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
                        
                        do {
                            try tempFetchedResultsControllerTowers.performFetch()
                        }
                        catch {
                            fatalError("Error in fetching records")
                        }
                        
//                        if(tempFetchedResultsControllerTowers.fetchedObjects!.count > 0){
//
//                            self.showSelectedTowerFromFloatButton(selectedTower: tempFetchedResultsControllerTowers.fetchedObjects![0], selectedBlock: block.name!)
//                        }
                    }
                }

            }
        }
        else if(collectionView === mCollectionView){
            // show only units with selected status
            
            unitsView.isHidden = false
            footerLabel.isHidden = true
            self.view.bringSubviewToFront(unitsView)
            self.mTableView.isHidden = true
            self.shouldShowFilterButton(shouldShow: true)
//            unitsView.backgroundColor = UIColor.green
            
//            mUnitsCollectionView.delegate = self
//            mUnitsCollectionView.dataSource = self
//            mUnitsCollectionView.reloadData()
            
//            self.parseUnitsWithSelectedStatus(selectedStatus: indexPath.row)
            self.selectedStatusForFilter = indexPath.row
            self.fetchUnitsWithSelectedStatus(selectedStatus: indexPath.row)
//            self.shouldShowUnitsWithSelectedStatus(selectedStatus: indexPath.row)
            
            // Reset data source with selected status
//            self.parseUnitsWithSelectedStatus(selectedStatus: indexPath.row)
            
            let statusColorDict = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: indexPath.row)
            
            if(indexPath.row == -1){
                allBlocksLabel.text = "All Units"
            }else{
                allBlocksLabel.text = statusColorDict["statusString"] as? String
            }
            allBlocksLabel.textAlignment = .left
            statusLabel.isHidden = false
            if(blocksButton != nil){
                blocksButton.isHidden = false
                self.view.bringSubviewToFront(blocksButton)
            }
            subPartTypeLabel.text = "Units"

            
//            let statucColorDict = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: indexPath.row)
//
//            self.view.bringSubviewToFront(blocksButton)
//
//            selectedIndexForDetailedProjectView = 1
//
//            if(selectedIndexForDetailedProjectView == 1){
//                allBlocksLabel.text =  statucColorDict["statusString"] as? String
//                allBlocksLabel.textAlignment = .left
//                statusLabel.isHidden = false
//                blocksButton.isHidden = false
//                statusLabel.isHidden = false
//                blocksButton.isHidden = false
//                self.view.bringSubviewToFront(blocksButton)
//                subPartTypeLabel.text = "Units"
//            }
//            else{
//                allBlocksLabel.text = "All Blocks"
//                allBlocksLabel.textAlignment = .center
//                statusLabel.isHidden = true
//                blocksButton.isHidden = true
//                self.view.bringSubviewToFront(blocksButton)
//                subPartTypeLabel.text = "Summary"
//            }
        }
       else if(collectionView === mUnitsCollectionView){
            
            if !RRUtilities.sharedInstance.getNetworkStatus()
            {
                HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
                return
            }

            let bookingFormController = BookingFormViewController(nibName: "BookingFormViewController", bundle: nil)

            bookingFormController.selectedUnit = self.fetchedResultsControllerUnits.object(at: indexPath)
            bookingFormController.unitStatusDelegate = self
            bookingFormController.selectedUnitIndexPath = indexPath
             self.selectedIndexPath = indexPath
             self.indexPathForUnitSelection = indexPath
             
//             let key : String = currentTitlesOfBlocks[indexPath.section]
//             var unitsArray = currentUnitsDataSource[key]
             //            bookingFormController.indexPathOfSelectedUnit = indexPath
            
//            let sortedUnits = self.sortUnitsAsPerUnitNumberForSection(sectionToSort: indexPath.section)
//
//            let tempUnit : Units =  sortedUnits[indexPath.row] //sectionInfo.objects![indexPath.row] as! Units
        
//            if(tempUnit == nil){
//                print("NO UNIT DETAILS ???")
//            }
//             bookingFormController.unitStatusDelegate = self
//                bookingFormController.selectedUnitIndexPath = indexPath
            
             self.navigationController?.pushViewController(bookingFormController, animated: true)
             return
            
            // show book unit view
            /*
            selectedIndexPath = indexPath
            self.indexPathForUnitSelection = indexPath
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailsController = storyboard.instantiateViewController(withIdentifier :"bookUnit") as! BookUnitViewController
            detailsController.delegate = self
            let key : String = currentTitlesOfBlocks[indexPath.section]
            var unitsArray = currentUnitsDataSource[key]
            detailsController.indexPathOfSelectedUnit = indexPath
            let tempUnit : UnitDetails = unitsArray![indexPath.row]
            detailsController.selectedUnit = tempUnit
            let nextStatus : UNIT_STATUS = RRUtilities.sharedInstance.getNextStatusFromCurrentStatus(currentStatus: tempUnit.status!)
            print(nextStatus.rawValue)
            self.navigationController?.pushViewController(detailsController, animated: true)

            */
            
//            print(tempUnit.status)
//            tempUnit.status = 10
//            unitsArray![indexPath.row] = tempUnit
//            numberOfSections[key] = unitsArray
//            print(tempUnit.status)
//
////            let key : String = orderdSectionTitls[indexPath.section] as! String
//            var unitsArray1 = numberOfSections[key]
//            var tempUnit1 : UnitDetails = unitsArray1![indexPath.row]
//            print(tempUnit1.status)
            
//            self.changeStatusOfSelectedUnit(selectedUnitId: tempUnit._id!, status: tempUnit.status!)
            
//            self.present(detailsController, animated: true, completion: nil)
            
//            self.navigationController?.pushViewController(detailsController, animated: true)

            // Show pop up of statuses on long press .
//            return
        }
    }
    func reloadCollectionView(){
        
//        DispatchQueue.main.async {
//            self.mUnitsCollectionView.reloadItems(at: self.mUnitsCollectionView.indexPathsForVisibleItems)
//            self.mUnitsCollectionView.reloadData()
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            //            self.view.bringSubviewToFront(self.mUnitsCollectionView)
            //            self.mUnitsCollectionView.reloadData()
            
            self.mUnitsCollectionView.reloadItems(at: self.mUnitsCollectionView.indexPathsForVisibleItems)
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
            self.mUnitsCollectionView.reloadData()
        }

    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        print("width is \(cell.frame.size.width)")
        if(collectionView == mUnitsCollectionView){
//            mUnitsCollectionView.layoutIfNeeded()
            
        }
        else if(collectionView == colorCollectionView){
            colorCollectionView.layoutIfNeeded()
        }
//        collectionView.layoutIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView == self.mUnitsCollectionView){
            
            let tempUnit : Units = self.fetchedResultsControllerUnits.object(at: indexPath) //sortedUnits[indexPath.row]
            let towerType =  tempUnit.towerType
            
            if(towerType == 0 || towerType == 2){
                return CGSize(width: (collectionView.frame.size.width - 48) / 4, height: 70)
            }
            else{
                return CGSize(width: (collectionView.frame.size.width - 48) / 2, height: 70)
            }
        }
        else if(collectionView == self.colorCollectionView){
            let itemWidth = (collectionView.bounds.size.width) / 5.5
            return CGSize(width: itemWidth, height: 60)
        }
        else if(collectionView == self.mCollectionView){
            let itemWidth = (mCollectionView.bounds.size.width) / 4
            return CGSize(width: itemWidth, height: 70)
        }else{
            let itemWidth = (collectionView.bounds.size.width) / 6
            return CGSize(width: itemWidth, height: 70)
        }
    }


    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
//        if(collectionView === mUnitsCollectionView){
//            print("")
//        }``
        
            switch kind {
                
            case UICollectionView.elementKindSectionHeader:
                
//                mUnitsCollectionView.register(HeaderCollectionReusableView.self, forCellWithReuseIdentifier: "unitHeader")
                //                mUnitsCollectionView.register(UINib(nibName: "HeaderCollectionReusableView", bundle: Bundle.main), forCellWithReuseIdentifier: "unitHeader")

//                self.mUnitsCollectionView.register(UINib(nibName: "HeaderCollectionReusableView", bundle: nil), forCellWithReuseIdentifier: "unitHeader")

                
                let headerView  = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "unitHeader", for: indexPath) as! UnitHeaderCollectionReusableView
//                headerView.layoutIfNeeded()
                //            headerView.frame = CGRect(0 , 0, self.view.frame.width, 40)
                headerView.viewTowerPlanButton.addTarget(self, action: #selector(showTowerPlan(_:)), for: .touchUpInside)
                headerView.viewTowerPlanButton.tag = indexPath.section
                let sectionInfo = self.fetchedResultsControllerUnits!.sections![indexPath.section]
                let tempUnit = sectionInfo.objects![0] as! Units
                headerView.titleLabel.text =  tempUnit.sectionTitle //sectionInfo.objects[0].
                
                if(tempUnit.towerImageExist){
                    headerView.viewTowerPlanButton.isHidden = false
                    headerView.heightOfPlanButton.constant = 25
                }
                else{
                    headerView.viewTowerPlanButton.isHidden = true
                    headerView.heightOfPlanButton.constant = 0
                }
                
                //currentTitlesOfBlocks[indexPath.section]
//                let imagesArray =  RRUtilities.sharedInstance.model.getImagesOfTower(towerName: currentTitlesOfBlocks[indexPath.section])
//                headerView.backgroundColor = UIColor.clear
//                if(imagesArray.count > 0){
////                    print(imagesArray)
//                }
//                else{
//                    headerView.viewTowerPlanButton.isHidden = true
//                    headerView.heightOfPlanButton.constant = 0
//                }
//                print(currentTitlesOfBlocks)
                
                //            headerView.backgroundColor = UIColor.green
                return headerView
                
                //        case UICollectionElementKindSectionFooter:
                //            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
                //
                //            footerView.backgroundColor = UIColor.green
                //            return footerView
                
//            case UICollectionView.elementKindSectionFooter:
//
//                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "unitHeader", for: indexPath) as! UnitHeaderCollectionReusableView
//                headerView.titleLabel.text = String(format: "Total Units : %d", projectDetails.units!.count)
//                headerView.backgroundColor = UIColor.red
//                return headerView

            default:
                fatalError("Unexpected element kind")
                break
//                assert(false, "Unexpected element kind")
            }
    }
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
    //        if(collectionView == mUnitsCollectionView){
    //            let cellWidth = collectionView.frame.size.width / 4
    //            return CGSize(width: 100.0, height: 100.0)
    //        }
    //        else{
    //            return CGSize(width: 0.0, height: 0.0)
    //        }
    //    }
    @IBAction func viewTowerPlan(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let floorPlanController = storyboard.instantiateViewController(withIdentifier :"floorPlan") as! FloorPlanViewController
        floorPlanController.planType = PLAN_TYPE.TOWER_PLAN
        self.navigationController?.pushViewController(floorPlanController, animated: true)
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        if(!unitsView.isHidden){
            if let indexPath : IndexPath = self.mUnitsCollectionView.indexPathsForVisibleItems.first {
                let sectionInfo = self.fetchedResultsControllerUnits!.sections![indexPath.section]
                if(sectionInfo.numberOfObjects  > 0){
                    let tempOBj = sectionInfo.objects![0] as! Units
                    blocksButton.mTitleLabel.text = tempOBj.sectionTitle
                }
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if(!unitsView.isHidden){
            if(self.fetchedResultsControllerUnits!.sections!.count > 0 && self.mUnitsCollectionView.indexPathsForVisibleItems.first != nil){
                let indexPath : IndexPath = self.mUnitsCollectionView.indexPathsForVisibleItems.first ?? IndexPath.init()
                let sectionInfo = self.fetchedResultsControllerUnits!.sections![indexPath.section]
                if(sectionInfo.numberOfObjects  > 0){
                    let tempOBj = sectionInfo.objects![0] as! Units
                    blocksButton.mTitleLabel.text = tempOBj.sectionTitle
                }
                blocksButton.subView.layoutIfNeeded()
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(!unitsView.isHidden){
            if let indexPath : IndexPath = self.mUnitsCollectionView.indexPathsForVisibleItems.first {
                let sectionInfo = self.fetchedResultsControllerUnits!.sections![indexPath.section]
                if(sectionInfo.numberOfObjects  > 0){
                    let tempOBj = sectionInfo.objects![0] as! Units
                    if(blocksButton != nil){
                        blocksButton.mTitleLabel.text = tempOBj.sectionTitle
                    }
                }
            }
            let scrollViewHeight = scrollView.frame.size.height
            let scrollContentSizeHeight = scrollView.contentSize.height
            let scrollOffset = scrollView.contentOffset.y
            
            if (scrollOffset == 0)
            {
                // then we are at the top
            }
            else if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
            {
//                bottomConstraintOfUnitsCollectionView.constant = 80
                // then we are at the end
                
//                scrollView.contentOffset.y += 1
                
//                let contentOffset =  scrollView.contentOffset.y - oldContentOffset.y
//
//                scrollView.contentOffset.y = scrollView.contentOffset.y + 80
//
//                if contentOffset > 0 && scrollView.contentOffset.y > 0 {
//                    if ( topViewTopConstraint.constant > -130 ) {
//                        topViewTopConstraint.constant -= contentOffset
//                        scrollView.contentOffset.y -= contentOffset
//                    }
//                }
            }
            else{
//                bottomConstraintOfUnitsCollectionView.constant = 0
            }

        }
    }

    //MARK: - popover controller delegate
    func shouldShowUnitsWithSelectedStatus(selectedStatus : Int){
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
        // Reset data source with selected status
        self.parseUnitsWithSelectedStatus(selectedStatus: selectedStatus)
    
        let statusColorDict = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: selectedStatus)
        
        if(selectedStatus == -1){
            allBlocksLabel.text = "All Units"
        }else{
            allBlocksLabel.text = statusColorDict["statusString"] as? String
        }
        lastSelectedStatusOption = selectedStatus
        allBlocksLabel.textAlignment = .left
        statusLabel.isHidden = false
//        blocksButton.isHidden = false
        self.view.bringSubviewToFront(blocksButton)
        subPartTypeLabel.text = "Units"

    }
    func parseUnitsWithSelectedStatus(selectedStatus : Int)
    {
        self.selectedStatusForFilter = selectedStatus
        self.fetchUnitsWithSelectedStatus(selectedStatus: selectedStatus)
        return
        
//        numberOfSections.removeAll()
//        orderdSectionTitls.removeAllObjects()
//
//        let blocks = projectDetails.blocks!
//
//        for tempBlock in blocks{
//
//            let blockId = tempBlock._id
//
//            //get towers related to block Id
//
//            let towers = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }
//
//            for tempTower in towers{
////                print(tempTower)
//
//                //get units related to towers and index them as per the floor
//
//                let towerId = tempTower._id
//
//                var filterredUnits = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(towerId!))! }
//
//                if(selectedStatus != -1){
//                    filterredUnits = filterredUnits.filter{ ($0.status == selectedStatus) }
//                }
//
//                //                filterredUnits.sort { $0.description! < $1.description! }
//                // Build dictionary **
//
//                if(tempTower.towerType == 0){
//                    for tempUnit in filterredUnits{
//                        // tempUnit
//                        let floorIndex = tempUnit.floor?.index
////                        print(floorIndex ?? "")
//
//                        let sectionTitle = String(format: "%@ - %@ - %d", tempBlock.name! , tempTower.name!,floorIndex!)
//
//                        orderdSectionTitls.add(sectionTitle)
//
//                        var unitArray = numberOfSections[sectionTitle]
//
//                        if(unitArray == nil){
//                            unitArray = [tempUnit]
//                            numberOfSections[sectionTitle] = unitArray
//                        }
//                        else{
//                            unitArray?.append(tempUnit)
//                            unitArray?.sort( by: { Int($0.description!) ?? 0 < Int($1.description!) ?? 0 })
//                            numberOfSections[sectionTitle] = unitArray
//                        }
//                    }
//
//                }
//                else
//                {
//                    for tempUnit in filterredUnits{
//                        // tempUnit
//                        let floorIndex = tempUnit.floor?.index
////                        print(floorIndex ?? "")
//
//                        let sectionTitle = String(format: "%@ - %@", tempBlock.name! , tempTower.name!)
//
//                        orderdSectionTitls.add(sectionTitle)
//
//                        var unitArray = numberOfSections[sectionTitle]
//
//                        if(unitArray == nil){
//                            unitArray = [tempUnit]
//                            numberOfSections[sectionTitle] = unitArray
//                        }
//                        else{
//                            unitArray?.append(tempUnit)
////                            print(tempUnit.description)
//                            unitArray?.sort( by: { Int($0.description!) ?? 0 <= Int($1.description!) ?? 0 })
////                            unitArray?.sort( by: { $0.description! < $1.description! })
//                            numberOfSections[sectionTitle] = unitArray
//                        }
//                    }
//
//                }
//
////                print(numberOfSections.keys)
////                print(orderdSectionTitls)
//            }
//
//            print(numberOfSections.keys)
//            print(orderdSectionTitls)
//
////            currentUnitsDataSource = numberOfSections
////            currentTitlesOfBlocks = (orderdSectionTitls.array as? [String])!
//
//            self.mUnitsCollectionView.reloadData()
////            if(currentTitlesOfBlocks.count > 0){
////                blocksButton.mTitleLabel.text = currentTitlesOfBlocks[0]
////            }
////            else{
////                //
////            }
//        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.reloadCollectionView()
//        }

    }
    @objc func updateUnitStaus(_ notification: NSNotification){
        
        //        return
        //        pageMenu.configureUserInterface()
        //        return
        //        pageMenu.menuItems[0].titleLabel!.text = "testser"
        //        var controller = pageMenu.controllerArray[0] as! CallsViewController
        //        controller.title = "tester"
        //        pageMenu.controllerArray.insert(controller, at: 0)
        //        pageMenu.resetTitleForControllerWithIndex()
        
        if let dict = notification.userInfo as Dictionary? {
            //            pageMenu.setUpUserInterface()
            //            pageMenu.menuScrollView.reloadInputViews()

//            self.setCountOfControllers(dict: dict as! Dictionary<String, Int>)
            if(dict["isReserve"] != nil && (dict["isReserve"] as! Bool) == true){
                let unit = self.fetchedResultsControllerUnits.object(at: self.indexPathForUnitSelection)
                self.didFinishUnitStatusChange(selectedUnit: unit, selectedIndexPath: self.indexPathForUnitSelection, unitStatus: UNIT_STATUS.RESERVED.rawValue)
            }
            else if(dict["isRevoke"] != nil && (dict["isRevoke"] as! Bool) == true){
                let unit = self.fetchedResultsControllerUnits.object(at: self.indexPathForUnitSelection)
                self.didFinishUnitStatusChange(selectedUnit: unit, selectedIndexPath: self.indexPathForUnitSelection, unitStatus: UNIT_STATUS.VACANT.rawValue)
            }
        }
        
    }
    func didSelectLandOwnerName(ownerName : String,selectedOption : Int){
        
        self.selectedLandOwnerName = ownerName
        
        self.landOwnerNameLabel.text = ownerName
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
        
        self.fetchAllUnits()

    }
    func didFinishUnitStatusChange(selectedUnit: Units, selectedIndexPath: IndexPath, unitStatus: Int) {
        
        RRUtilities.sharedInstance.model.updateStatusOfSelectedUnit(selectedProjectId: selectedUnit.project!, oldStatus: Int(selectedUnit.status)
            , updatedStatus: unitStatus)

//        RRUtilities.sharedInstance.model.managedObjectContext = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType);
        
//        let bgContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        let moc = RRUtilities.sharedInstance.model.managedObjectContext
//        bgContext.parent = moc
        
//        bgContext
        
        //[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType]

//        let unitDetsils =  self.fetchedResultsControllerUnits.object(at: selectedIndexPath)
        
        let unitDetsils = RRUtilities.sharedInstance.model.getUnitDetailsByUnitID(unitId: selectedUnit.id!)

        let childContext = NSManagedObjectContext(
            concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = RRUtilities.sharedInstance.model.managedObjectContext

        let childEntry = childContext.object(
            with: unitDetsils!.objectID) as? Units
        
        childEntry?.status = Int64(unitStatus)
        
        childContext.perform {
            do {
                try childContext.save()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            
            RRUtilities.sharedInstance.model.saveContext()
        }
        
//        unitDetsils!.status = Int64(unitStatus)
//        self.mUnitsCollectionView.reloadItems(at: [selectedIndexPath])
        
//        RRUtilities.sharedInstance.model.managedObjectContext = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType);
        
        

//        NotificationCenter.default.post(name: Notification.Name("updateProjects"), object: nil)

    }
    
    func didFinishBookUnit(clientId : String,bookedUnit : Units,selectedIndexPath : IndexPath){
        // Update Unit
        //update Datasource
        // collapse view
        

//        let key : String = sectionInfo.name
//
//        var unitsArray = self.currentUnitsDataSource[key]
        
        //Get Unit using its ID : and update 
        let unitDetsils =  RRUtilities.sharedInstance.model.getUnitDetailsByUnitID(unitId: bookedUnit.id!)
        
//        let sortedUnits  = self.sortUnitsAsPerUnitNumberForSection(sectionToSort: self.indexPathForUnitSelection.section)
//        let tempUnit : Units =  sortedUnits[self.indexPathForUnitSelection.row]
//        let prevState = bookedUnit.status
        let changedStatus =  Int(bookedUnit.status) + 1
        
        unitDetsils!.status = Int64(changedStatus)
        
//        print(tempUnit.status ?? "")
//        tempUnit.status = Int64(changedStatus) //changedStatus.rawValue
        
        RRUtilities.sharedInstance.model.saveContext()
        
//        print(tempUnit.status ?? "")
        
        
//        unitsArray![self.indexPathForUnitSelection.row] = tempUnit
//        self.currentUnitsDataSource[key] = unitsArray
//        self.numberOfSections[key] = unitsArray
//
//        var unitsArray1 = self.numberOfSections[key]
//        let tempUnit1 : UnitDetails = unitsArray1![self.indexPathForUnitSelection.row]
        

        self.mUnitsCollectionView.reloadItems(at: [selectedIndexPath])
        
        //  *** update status of project in db
        
//        RRUtilities.sharedInstance.model.updateStatusOfSelectedUnit(selectedProjectId: tempUnit.project!, oldStatus: bookedUnit.status!
//            , updatedStatus: bookedUnit.status!+1)
        
        NotificationCenter.default.post(name: Notification.Name("updateProjects"), object: nil)
        
        //  *** update status of project in db

        
        
        self.dismiss(animated: true, completion: nil)
        
        // change in db also?
    }
    func didSelectProject(optionType : String,optionIndex: Int){
        
        self.selectedProjectIndexPath = IndexPath.init(row: optionIndex, section: 0)
        let projecct =  self.fetchedResultsControllerProjects!.fetchedObjects![optionIndex]
        self.selectedProject = self.fetchedResultsControllerProjects.fetchedObjects![optionIndex]

        //self.projectsArray[optionIndex]
        
        let urlString = String(format:RRAPI.PROJECT_DETAILS, projecct.id!)

        self.projectTitleLabel.text = String(format: "%@ - %@", projecct.name!,projecct.city ?? "")
        self.resetTopFileter()
        if(self.projectExist()){
            self.selectedProject = self.fetchedResultsControllerProjects.fetchedObjects![optionIndex]
            sleep(UInt32(0.3))
            self.fetchAllBlocks()
            sleep(UInt32(0.45))
            self.fetchAllTowers()
            sleep(UInt32(0.20))
            self.fetchAllUnits()
            self.mTableView.reloadData()
            footerLabel.text = String(format: "Total Units : %d", (self.fetchedResultsControllerUnits.fetchedObjects?.count)!)
            self.mUnitsCollectionView.reloadData()
//            self.showLandOwnerDetailsView()
        }else{
            self.getSelectedProjectDetails(urlString: urlString)
        }
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }

    func didFinishTask(optionType: String, optionIndex: Int) {
//        print(optionType)
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
//
//        let key = currentTitlesOfBlocks[indexPathForUnitSelection.section]
//        let unitsArray : Array<UnitDetails> = (currentUnitsDataSource[key])!
        
//        let selectedUnit = unitsArray[indexPathForUnitSelection.row]
        
//        let sortedUnits  = self.sortUnitsAsPerUnitNumberForSection(sectionToSort: self.indexPathForUnitSelection.section)
        let selectedUnit : Units = self.fetchedResultsControllerUnits.object(at: self.indexPathForUnitSelection)
        //sortedUnits[self.indexPathForUnitSelection.row]

        
        if(selectedUnit.status == UNIT_STATUS.RESERVED.rawValue){
            //fetch reservations info
            self.getReservationDetails(selectedUnit: selectedUnit)
        }
        else{
            var statusToPassToServer = 0
            
            if(optionType == "Block"){
                statusToPassToServer = UNIT_STATUS.BLOCKED.rawValue
//                self.getCustomBookingSetUpDetails(selectedUnit: selectedUnit)
                self.showBlockOrReleaseController(selectedUnit: selectedUnit)
                return
            }
            else if(optionType == "Reserve"){
                statusToPassToServer = UNIT_STATUS.RESERVED.rawValue
                self.getReservationDetails(selectedUnit: selectedUnit)
                return
            }
            self.changeStatusOfSelectedUnit(selectedUnitId: selectedUnit.id!,status: statusToPassToServer)
        }

    }
    func didSelectOptionForUnitsView(selectedIndex : Int){
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
//        print(selectedIndex)
        selectedIndexForDetailedProjectView = selectedIndex
        
        // parse
//        self.buildDataSourceAsFloorWise()
        self.fetchAllUnits()
        
        if(selectedIndex == 0){ //show summary
            // hide units view
            unitsView.isHidden = true
            footerLabel.isHidden = false
//            unitsView.backgroundColor = UIColor.green
            blocksButton.isHidden = true
            self.mTableView.isHidden = false
            self.mCollectionView.isHidden = false
        }
        else{ //show units
            unitsView.isHidden = false
            footerLabel.isHidden = true
            blocksButton.isHidden = false
            self.view.bringSubviewToFront(unitsView)
            self.mTableView.isHidden = true
            self.mCollectionView.isHidden = true
            self.shouldShowFilterButton(shouldShow: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reloadCollectionView()
            }
            self.view.bringSubviewToFront(blocksButton)
        }
        if(selectedIndexForDetailedProjectView == 1){
            allBlocksLabel.text = "All Units"
            allBlocksLabel.textAlignment = .left
            statusLabel.isHidden = false
            subPartTypeLabel.text = "Units"
        }
        else{
            allBlocksLabel.text = "All Blocks"
            allBlocksLabel.textAlignment = .center
            statusLabel.isHidden = true
            subPartTypeLabel.text = "Summary"
        }
    }
    func showSelectedTowerFromFloatButton(selectedTower: Towers, selectedBlock: String) {
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController?.dismiss(animated: false, completion: nil);
        });

        let selectedTowerTitle  = String(format: "%@ - %@", selectedBlock,selectedTower.name!)
        
        var tempFetchedResultsControllerUnits : NSFetchedResultsController<Units>!
        
        let request: NSFetchRequest<Units> = Units.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Units.sectionIndex), ascending: true)
        request.sortDescriptors = [sort]
        
        let predicate = NSPredicate(format: "sectionTitle CONTAINS[c] %@", selectedTowerTitle)
        request.predicate = predicate
        
        tempFetchedResultsControllerUnits = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: "sectionIndex", cacheName:nil)

        do {
            try tempFetchedResultsControllerUnits.performFetch()
            
            if((tempFetchedResultsControllerUnits.fetchedObjects?.count)! > 0){
//                print(tempFetchedResultsControllerUnits.fetchedObjects?.count)
                var indexpath = self.fetchedResultsControllerUnits.indexPath(forObject: tempFetchedResultsControllerUnits.object(at: IndexPath(row: 0, section: 0)))
                
                if(indexpath != nil){
                    indexpath?.row = 0
//                    mUnitsCollectionView.reloadItems(at: [indexpath!])
//                    sleep(UInt32(0.5))
                    
//                    let sectionInfo = self.fetchedResultsControllerUnits!.sections![indexPath.section]
                    var sectionCounter = 0
                    for tempSectionInfo in self.fetchedResultsControllerUnits!.sections!{
//                        print(tempSectionInfo)
//                        print(tempSectionInfo.number)
                        
                        let tempUnit = tempSectionInfo.objects![0] as! Units
//                        headerView.titleLabel.text =  tempUnit.sectionTitle //sectionInfo.objects[0].
                        let title : String = tempUnit.sectionTitle!
                        if(title.contains(selectedTowerTitle)){
                            //movew to indexpath
                            break;
                        }
                        else{
                            print(title,selectedTowerTitle)
                        }
                        sectionCounter += 1
                    }
                    
                    indexpath?.section = sectionCounter
                    
                    mUnitsCollectionView.scrollToItem(at: indexpath!, at: .centeredVertically, animated: true)
                    mUnitsCollectionView.reloadItems(at: [indexpath!])
                }
            }
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    
    //MARK: - popOver
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        self.searchText = searchText
        if(unitsView.isHidden){ // Blocks Search
            if searchText.isEmpty
            {
                self.fetchAllBlocks()
            }
            else{
                let request: NSFetchRequest<Blocks> = Blocks.fetchRequest()
                let sort = NSSortDescriptor(key: #keyPath(Blocks.name), ascending: true)
                request.sortDescriptors = [sort]
                
                let predicate = NSPredicate(format: "name CONTAINS[c] %@ AND project CONTAINS[c] %@", searchText,self.selectedProject.id ?? "")
                request.predicate = predicate
                
                fetchedResultsControllerBlocks = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
                fetchedResultsControllerBlocks.delegate = self
                
                do {
                    try fetchedResultsControllerBlocks.performFetch()
                }
                catch {
                    fatalError("Error in fetching records")
                }
            }
//            currentBlocksArray = blocksArray.filter({ BlockDetails -> Bool in
//                switch searchBar.selectedScopeButtonIndex {
//                case 0:
//                    if searchText.isEmpty { return true }
//                    return BlockDetails.name!.lowercased().contains(searchText.lowercased())
//                default:
//                    return false
//                }
//            })
            self.mTableView.reloadData()
        }
        else{
            // Units search
            if(searchText.count == 0){
                
//                currentUnitsDataSource = numberOfSections
//                currentTitlesOfBlocks = (orderdSectionTitls.array as? [String])!
                
                self.fetchAllUnits()
                mUnitsCollectionView.reloadData()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    self.reloadCollectionView()
//                }

            }else{
                
//                self.fetchUnitsWithSearchString(locSeachText: searchText)
                self.fetchAllUnits()
                mUnitsCollectionView.reloadData()
//                self.parseUnitsAsPerSearchString(searchText: searchText)
                
//                currentUnitsDataSource = numberOfSections.filter({ $0.key.lowercased().contains(searchText.lowercased())})
//                //            print(filtered)
//                currentTitlesOfBlocks = orderdSectionTitls.array.filter{ ($0 as! String).lowercased().contains(searchText.lowercased()) } as! [String]
////                print(currentTitlesOfBlocks)
//                if(currentUnitsDataSource.count == 0){
//                    mUnitsCollectionView.reloadData()
//                }else{
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        self.reloadCollectionView()
//                    }
//                }
            }
        }
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.searchText = ""
        if(unitsView.isHidden){
            
            switch selectedScope {
            case 0:
                    self.fetchAllBlocks()
            default:
                break
            }

            mTableView.reloadData()
        }
        else{
            switch selectedScope {
            case 0: break
//                currentUnitsDataSource = numberOfSections
//                currentTitlesOfBlocks = (orderdSectionTitls.array as? [String])!
                self.fetchAllBlocks()
            default:
                break
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.reloadCollectionView()
            }
        }
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
        self.searchText = ""
        // Hide the cancel button
        //        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
        searchBar.isHidden = true
        titleSubView.isHidden = false
        searchButton.isHidden = false
        self.shouldShowFilterButton(shouldShow: true)
        if(unitsView.isHidden){
            self.fetchAllBlocks()
            mTableView.reloadData()
        }
        else{
//            currentUnitsDataSource = numberOfSections
//            currentTitlesOfBlocks = (orderdSectionTitls.array as? [String])!
//            self.buildDataSourceAsFloorWise()
            self.fetchAllUnits()
            self.mUnitsCollectionView.reloadData()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                self.reloadCollectionView()
//            }
        }
        self.view.endEditing(true)
    }
//    func parseUnitsAsPerSearchString(searchText : String)
//    {
//        numberOfSections.removeAll()
//        orderdSectionTitls.removeAllObjects()
//
//        //        let blocks = projectDetails.blocks!
//
//        //        for tempBlock in blocks{
//
//        //            let blockId = tempBlock._id
//
//        //get towers related to block Id
//
//        //            let towers = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }
//
//        //            for tempTower in towers{
//        //                print(tempTower)
//
//        //get units related to towers and index them as per the floor
//
//        //                let towerId = tempTower._id
//
//        var filterredUnits = projectDetails.units!.filter { ($0.description?.localizedCaseInsensitiveContains(searchText))! }
//
//        //                if(selectedStatus != -1){
//        //                    filterredUnits = filterredUnits.filter{ ($0.status == selectedStatus) }
//        //                }
//
//        //                filterredUnits.sort { $0.description! < $1.description! }
//
//        filterredUnits.sort { ($0.floor?.index!)! <= ($1.floor?.index!)! }
//
//        // Build dictionary **
//
//        for tempUnit in filterredUnits.reversed(){
//            // tempUnit
//            let floorIndex = tempUnit.floor?.index
//            //                    print(floorIndex ?? "")
//
//
//            let tempBlock =  projectDetails.blocks?.filter{ ($0._id?.localizedCaseInsensitiveContains(tempUnit.block!))! }
//            let tempTower = projectDetails.towers!.filter { ($0._id?.localizedCaseInsensitiveContains(tempUnit.tower!))! }
//
//            if(tempBlock?.count == 0 || tempTower.count == 0){
//                continue
//            }
//            let towerDetails = tempTower[0]
//
//            if(towerDetails.towerType == 0){
//                let sectionTitle = String(format: "%@ - %@ - %d", tempBlock![0].name! , tempTower[0].name!,floorIndex!)
//
//                orderdSectionTitls.add(sectionTitle)
//
//                var unitArray = numberOfSections[sectionTitle]
//
//                if(unitArray == nil){
//                    unitArray = [tempUnit]
//                    numberOfSections[sectionTitle] = unitArray
//                }
//                else{
//                    unitArray?.append(tempUnit)
//                    unitArray?.sort( by: { Int($0.description!) ?? 0 <= Int($1.description!) ?? 0 })
//                    numberOfSections[sectionTitle] = unitArray
//                }
//            }
//            else{
//                let sectionTitle = String(format: "%@ - %@", tempBlock![0].name! , tempTower[0].name!)
//
//                orderdSectionTitls.add(sectionTitle)
//
//                var unitArray = numberOfSections[sectionTitle]
//
//                if(unitArray == nil){
//                    unitArray = [tempUnit]
//                    numberOfSections[sectionTitle] = unitArray
//                }
//                else{
//                    unitArray?.append(tempUnit)
//                    unitArray?.sort( by: { Int($0.description!) ?? 0 <= Int($1.description!) ?? 0 })
//                    //                            print(unitArray as Any)
//                    numberOfSections[sectionTitle] = unitArray
//                }
//            }
//        }
//        //                print(numberOfSections.keys)
//        //                print(orderdSectionTitls)
//        //            }
//
//        print(numberOfSections.keys)
//        print(orderdSectionTitls)
//
//        //            currentUnitsDataSource = numberOfSections
//        //            currentTitlesOfBlocks = (orderdSectionTitls.array as? [String])!
//        //            if(currentTitlesOfBlocks.count > 0){
//        //                blocksButton.mTitleLabel.text = currentTitlesOfBlocks[0]
//        //            }
//        //            else{
//        //                //
//        //            }
//        //        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
//            self.reloadCollectionView()
//        }
//
//    }
    //MARK: - METHODS
    func getReservationDetails(selectedUnit : Units){
        
        if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.RESERVE_UNIT.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)){
            HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
            return
        }
        //GET_ALL_RESERVATIONS
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            self.refreshControl?.endRefreshing()
            self.unitRefreshControl?.endRefreshing()
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.labeledProgress(title: "", subtitle: nil))

        AF.request(RRAPI.API_GET_PROSPECTS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success :
                
//                print(response)
                
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                do{
                    let urlResult = try JSONDecoder().decode(ALL_PROSPECTS.self, from: responseData)
                    
                    //                print(urlResult)
                    
                    if(urlResult.status == 1){
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let reservationsController = storyboard.instantiateViewController(withIdentifier: "reservationsView") as! ReservationsViewController
                        reservationsController.selectedUnit = selectedUnit
                        
                        
                        reservationsController.tableViewDataSource = urlResult.customers!
                        
                        reservationsController.projectName = self.selectedProject.name!
                        
                        
                        reservationsController.blockName = selectedUnit.blockName!
                        reservationsController.towerName = selectedUnit.towerName!
                        
                        reservationsController.unitType = selectedUnit.typeName ?? ""
                        
                        self.navigationController?.pushViewController(reservationsController, animated: true)
                    }
                    else{
                        
                    }
                    
                    HUD.hide()
                    
                }
                catch let error{
                    HUD.hide()
                    HUD.flash(.label(error.localizedDescription))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
            }
        }
    }
    @objc func fetchUnitDetails(){
        // fetchUnitDetails
        self.refreshList()
    }
    func resetFilters(){
        
        self.selectedTypeNamesArray.removeAll()
        self.selectedFacingNamesArray.removeAll()
        self.selectedBuiltUpAreasArray.removeAll()
        self.selectedCarpetAreaArray.removeAll()
        self.selectedBedRoomsArray.removeAll()
        self.selectedBathRoomsArray.removeAll()
        self.selectedFloorPremiums.removeAll()
        self.selectedOtherPremiums.removeAll()
        self.selectedMiscArray.removeAll()
        
    }
    func getSelectedProjectDetails(urlString: String){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            self.refreshControl?.endRefreshing()
            self.unitRefreshControl?.endRefreshing()
            return
        }
        self.resetFilters()
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
//                let str = String(decoding: response.data ?? Data(), as: UTF8.self)
//                print(str)

                
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                do{
                    let urlResult = try! JSONDecoder().decode(ProjectDetails.self, from: responseData)
                    
                    if(urlResult.blocks == nil || urlResult.towers == nil || urlResult.units == nil){
                        HUD.hide()
                        
                        let alertController = UIAlertController(title: "Empty", message: "This project doesn't have any data.", preferredStyle: .alert)
                        let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                            print("You've pressed default");
                        }
                        alertController.addAction(action1)
                        
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    
                    RRUtilities.sharedInstance.model.writeBlocksToDB(projectDetails: urlResult, projectID: self.selectedProject.id!)
                    RRUtilities.sharedInstance.model.writeTowersToDB(projectDetails: urlResult, projectID: self.selectedProject.id!)
                    RRUtilities.sharedInstance.model.writeUnitsToDB(projectDetails: urlResult, projectID: self.selectedProject.id!)
                    sleep(1)
                    
                    self.fetchAllBlocks()
                    self.fetchAllUnits()
                    
                    self.allBlocksLabel.text = "All Units"
                    
                    self.mTableView.delegate = self
                    self.mTableView.dataSource = self
                    
                    self.mTableView.reloadData()
                    
                    //                print(urlResult)
                    
                    //                self.blocksArray.removeAll()
                    //                self.currentBlocksArray.removeAll()
                    
                    self.refreshControl?.endRefreshing()
                    self.unitRefreshControl?.endRefreshing()
                    
                    self.footerLabel.text = String(format: "Total Units : %d", (urlResult.units?.count)!)
                    
                    //                self.blocksArray = urlResult.blocks
                    //                self.currentBlocksArray = self.blocksArray // for search bar purpose
                    //                self.projectDetails = urlResult
                    self.buildDataSourceAsFloorWise()
                    self.makeFloatButtonPopUpDataSource()
                    
                    self.mTableView.reloadData()
                    self.mUnitsCollectionView.reloadData()
                    self.showLandOwnerDetailsView()
                    //                self.reloadCollectionView()
                    
                    
                    HUD.hide()
                    
                }
                catch let error{
                    HUD.hide()
                    HUD.flash(.label(error.localizedDescription))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
            }
        }
    }
    @IBAction func showFilterView(_ sender: Any) {
        
        let filterController = FiltersViewController(nibName: "FiltersViewController", bundle: nil)
        
        filterController.selectedTypeNamesArray = self.selectedTypeNamesArray
        filterController.selectedFacingNamesArray = self.selectedFacingNamesArray
        filterController.selectedBuiltUpAreasArray = self.selectedBuiltUpAreasArray
        filterController.selectedCarpetAreaArray = self.selectedCarpetAreaArray
        filterController.selectedBedRoomsArray = self.selectedBedRoomsArray
        filterController.selectedBathRoomsArray = self.selectedBathRoomsArray
        filterController.selectedFloorWisePremiumsArray = self.selectedFloorPremiums
        filterController.selectedOtherPremiumsArray = self.selectedOtherPremiums
        filterController.selectedMiscArray = self.selectedMiscArray
        filterController.tableViewSectionsSelectedCountDict = self.tableViewSectionsSelectedCountDict
        filterController.selectedProjectId = self.selectedProject.id!
        filterController.delegate = self
        
        filterController.isFromUnitsView = true
        
        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false
        
        fpc.delegate = self
        
        fpc.set(contentViewController: filterController)
        
        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        
        fpc.track(scrollView: filterController.tableView)

        self.present(fpc, animated: true, completion: nil)
        

    }
    
    @IBAction func showSearchBar(_ sender: Any) {
        searchBar.isHidden = false
        searchButton.isHidden = true
        titleSubView.isHidden = true
        if(unitsView.isHidden){
            searchBar.placeholder = "Search Block"
        }else{
            searchBar.placeholder = "Search Unit by name or phone"
        }
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        self.shouldShowFilterButton(shouldShow: false)
    }
    @IBAction func showProjects(_ sender: Any) {
        
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
            popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
            vc.tableViewDataSource = self.fetchedResultsControllerProjects!.fetchedObjects!
            
            popOver?.sourceView = popUpSourceView
            
            vc.delegate = self
            
            self.present(navigationContoller, animated: true, completion: nil)
        }
    }
    
    @IBAction func showPopUpToShowBlockAsPerSelectedStatus(_ sender: Any) {
     
        self.view.endEditing(true)
        if(allBlocksLabel.text == "All Blocks"){
            return
        }
        var tempArray : [String] = self.statusArray
        tempArray.insert("All Units", at: 0)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .SHOW_STATUS_WISE
        vc.preferredContentSize = CGSize(width: 150, height: statusArray.count * 44)
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0) //UIPopoverArrowDirection.any
        vc.tableViewDataSourceOne = tempArray
        //        vc.heightOfTitlesView.constant = 50
//        vc.selectedIndexForUnitsView = indexPath.row + 1
        popOver?.sourceView = allBlocksView //selectedCell.subView
        
        vc.delegate = self
        
        self.present(navigationContoller, animated: true, completion: nil)

    }
    @IBAction func showPopForBlocksOrUnits(_ sender: Any) {
        
        self.view.endEditing(true)
        let dataSource = ["Summary","Units"]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .SUMMARY_OR_UNITS
        vc.preferredContentSize = CGSize(width: 130, height: 44)
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        vc.selectedIndexForUnitsView = selectedIndexForDetailedProjectView
        vc.tableViewDataSourceOne = dataSource
        
        popOver?.sourceView = popUpSourceLabel
        
        vc.delegate = self
        self.present(navigationContoller, animated: true, completion: nil)
        
    }
    func getStatusOfUnit(indexPath : IndexPath,isBlock : Bool,parentIndexPath : IndexPath) -> Dictionary<String, Int>{
        
        let projecct = selectedProject
        
        var collectionCellDict : Dictionary<String , Int> = [:]
        
        var keyPath = "proStat"
        
        var statssss : NSMutableOrderedSet!
        
        if(isBlock){
            keyPath = "blockStats"
            statssss = (self.fetchedResultsControllerBlocks!.object(at: parentIndexPath).value(forKey: keyPath) as! NSMutableOrderedSet)
        }else{
            statssss = projecct!.value(forKey: keyPath) as! NSMutableOrderedSet
        }
        
        
        
        
        var isStatusAvailable = false
        
        for temperrr in statssss{
            
            let tester = temperrr as! TempObj
            
            if(indexPath.row == tester.status){
                isStatusAvailable = true
                collectionCellDict["count"] = Int(tester.count)
                break
            }
        }
        
        if(isStatusAvailable == false){
            collectionCellDict["count"] = 0
        }
        return collectionCellDict
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func changeStatusOfSelectedUnit(selectedUnitId : String, status : Int){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        var parameters : Dictionary<String,Any> = Dictionary()
        //11:     status: { type : Number, default: 0}, // Unit Status 0 - Vacant, 1 - Booked, 2- Sold, 3 - Reserved, 4 - Blocked, 5 - Handed Over
        parameters["status"] = status
        parameters["_id"] = selectedUnitId
        parameters["src"] = 3
        
        HUD.show(.labeledProgress(title: "Changing status...", subtitle: nil))
        
        AF.request(RRAPI.UNIT_STATUS_CHANGE, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
//                    guard let loginResult : Dictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
//                        print("error trying to convert data to JSON")
//                        return
//                    }
//                    print(loginResult)
                    
                    let urlResult = try JSONDecoder().decode(STATUS_CHANGE_API_RESULT.self, from: responseData)
                    
//                    let key : String = self.currentTitlesOfBlocks[self.indexPathForUnitSelection.section]
//                    
//                    var unitsArray = self.currentUnitsDataSource[key]
                    
//                    var tempUnit : UnitDetails = unitsArray![self.indexPathForUnitSelection.row]
                    
//                    let sortedUnits  = self.sortUnitsAsPerUnitNumberForSection(sectionToSort: self.indexPathForUnitSelection.section)
                    let tempUnit : Units =  self.fetchedResultsControllerUnits.object(at: self.indexPathForUnitSelection) //sortedUnits[self.indexPathForUnitSelection.row]
                    

//                    let prevState = tempUnit.status
//                    print(urlResult.status)
                    let changedStatus =  urlResult.oldStatus //RRUtilities.sharedInstance.getNextStatusFromCurrentStatus(currentStatus: status)
//                    print(tempUnit.status ?? "")
                    tempUnit.status = Int64(changedStatus!) //changedStatus.rawValue
//                    print(tempUnit.status ?? "")
                    RRUtilities.sharedInstance.model.saveContext()
//                    unitsArray![self.indexPathForUnitSelection.row] = tempUnit
//                    self.currentUnitsDataSource[key] = unitsArray
//                    self.numberOfSections[key] = unitsArray
                    
//                    var unitsArray1 = self.numberOfSections[key]
//                    let tempUnit1 : UnitDetails = unitsArray1![self.indexPathForUnitSelection.row]
//                    print(tempUnit1.status ?? "")
//                    self.mUnitsCollectionView.reloadData()
                    self.mUnitsCollectionView.reloadItems(at: [self.indexPathForUnitSelection as IndexPath])

                    //  *** update status of project in db

//                    RRUtilities.sharedInstance.model.updateStatusOfSelectedUnit(selectedProjectId: tempUnit.project!, oldStatus: prevState!
//                        , updatedStatus: urlResult.oldStatus!)
                    
                    NotificationCenter.default.post(name: Notification.Name("updateProjects"), object: nil)
                    
                    //  *** update status of project in db
                    
//                    print(urlResult)
                    //
                    //                completionHandler(urlResult, nil)
                    //                 completionHandler(result, nil)
                    HUD.hide()

                }
                catch{
                    
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                //                completionHandler(result, nil)
//                completionHandler(nil, error)
                //                return result
                break
            }
        }
    }
    @objc func showTowerPlan(_ sender: UIButton){
        print(sender.tag)
        
        mUnitsCollectionView.convert(sender.frame.origin, to: sender)
    
        let tempINdex : IndexPath = IndexPath.init(item: 0, section: sender.tag)
        let tempView : UnitHeaderCollectionReusableView = mUnitsCollectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: tempINdex) as! UnitHeaderCollectionReusableView
    
        // show Tower images
        
        /// get images :
        
        let imagesArray =  RRUtilities.sharedInstance.model.getImagesOfTower(towerName: tempView.titleLabel.text!)

        if(imagesArray.count > 0){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let floorPlanController = storyboard.instantiateViewController(withIdentifier :"floorPlan") as! FloorPlanViewController
            floorPlanController.planType = PLAN_TYPE.TOWER_PLAN
            //        floorPlanController.floorPlans = selectedUnit.type?.floorPlan ?? []
                    floorPlanController.towerPlans = imagesArray
            self.navigationController?.pushViewController(floorPlanController, animated: true)
        }

    }
    @objc func longTap(_ sender: UIGestureRecognizer){
//        print("Long tap")
        if sender.state == .began {
            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
//            print(sender.view)
            
            let tapLocation = sender.location(in: mUnitsCollectionView)
            let indexPath : IndexPath = mUnitsCollectionView.indexPathForItem(at: tapLocation)!
//            print(indexPath.section)
//            print(indexPath.row)

            let tempUnit =  self.fetchedResultsControllerUnits.object(at: indexPath)
            self.indexPathForUnitSelection = indexPath

            if(tempUnit.status == UNIT_STATUS.HANDEDOVER.rawValue){
                return
            }
            
            if(tempUnit.status == UNIT_STATUS.SOLD.rawValue){
                
                if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.AGREEMENT_STATUS_TRACKER.rawValue, permissionType: UserRolePermissions.VIEW.rawValue))
                {
                    HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
                    return
                }
                self.showAgreementTypesPopUp(selectedUnit: tempUnit)
                return
            }
            if(tempUnit.status == UNIT_STATUS.BOOKED.rawValue){
                if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.AGREEMENT_STATUS_TRACKER.rawValue, permissionType: UserRolePermissions.VIEW.rawValue))
                {
                    HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
                    return
                }
                self.showAgreementTypesPopUp(selectedUnit: tempUnit)
                return
            }
            let shouldAllow = PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.RESERVE_UNIT.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)
            if(!shouldAllow)
            {
                HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
                return
            }
            if(tempUnit.status == UNIT_STATUS.RESERVED.rawValue){
                self.getReservationDetails(selectedUnit: tempUnit)
                return
            }
            if(tempUnit.status == UNIT_STATUS.BLOCKED.rawValue){
//                self.getCustomBookingSetUpDetails(selectedUnit: tempUnit)
                self.showBlockOrReleaseController(selectedUnit: tempUnit)
                return
            }
            
//            if let cell : UnitCollectionViewCell = mUnitsCollectionView.cellForItem(at: indexPath) as! UnitCollectionViewCell{
////                currentIndex = cell.tag
//                print(cell.unitNumberLabel.text)
//            }

            showPopUpForStatusSelection(indexPath : indexPath)

        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
        }
    }
    func showAgreementTypesPopUp(selectedUnit : Units){
        
        let agreemenTypesController = AgreementsViewController(nibName: "AgreementsViewController", bundle: nil)
        agreemenTypesController.delegate = self
        
       agreemenTypesController.selectedUnitName = String(format: "%@ (%@)", selectedUnit.unitDisplayName ?? "",selectedUnit.description1 ?? "")
        
        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false
        
        fpc.delegate = self
        
        fpc.set(contentViewController: agreemenTypesController)
        
        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        
        
        self.present(fpc, animated: true, completion: nil)

        
    }
    func showBlockOrReleaseController(selectedUnit : Units){
        
        if(!PermissionsManager.shared.checkForPermission(moduleName: Permission_Names.BLOCK_RELEASE_UNIT.rawValue, permissionType: UserRolePermissions.VIEW.rawValue)){
            HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
            return
        }
        
        let blockOrReserveController = BlockOrReleaseUnitViewController(nibName: "BlockOrReleaseUnitViewController", bundle: nil)
        blockOrReserveController.selectedUnit = selectedUnit
        blockOrReserveController.delegate = self
        blockOrReserveController.selectedUnitIndexPath = self.indexPathForUnitSelection
        
        blockOrReserveController.projectName = self.selectedProject.name!
        
        blockOrReserveController.blockName = selectedUnit.blockName!
        blockOrReserveController.towerName = selectedUnit.towerName!
        
        blockOrReserveController.unitType = selectedUnit.typeName ?? ""
        
        self.navigationController?.pushViewController(blockOrReserveController, animated: true)
    }
    func getCustomBookingSetUpDetails(selectedUnit : Units){
        
        //GET_ALL_RESERVATIONS
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            self.refreshControl?.endRefreshing()
            self.unitRefreshControl?.endRefreshing()
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.labeledProgress(title: "", subtitle: nil))
        
        let url = RRAPI.API_GET_DEFAULT_BOOKING_SETUP
    
        print(url)
        
        let anotherURl = RRAPI.API_GET_CUSTOM_BOOKING_SETUP
        
        print(anotherURl)
        
        AF.request(RRAPI.API_GET_CUSTOM_BOOKING_SETUP, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success :
//                print(response)

                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(BOOKING_FORM_SET_UP.self, from: responseData)
                    
                    if(urlResult.status == 1){
                        
                    }
                    else if(urlResult.status == -1){
                        
                    }
                    else{
                        
                    }
                    
                    HUD.hide()

                }
                catch let error{
                    HUD.hide()
                    HUD.flash(.label(error.localizedDescription))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
            }
        }
        
    }
    @IBAction func showStatusChangePopUp(_ sender: Any) {
        showPopUpForStatusSelection(indexPath : selectedIndexPath)
    }
    func showPopUpForStatusSelection(indexPath : IndexPath){
        
//        let selectedCell : UnitCollectionViewCell = mUnitsCollectionView.cellForItem(at: indexPath as IndexPath) as!UnitCollectionViewCell
        
        let selectedCell = mUnitsCollectionView.cellForItem(at: indexPath as IndexPath)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .STATUS
        
        let statusesArray = ["Reserve","Block"]
        
        vc.preferredContentSize = CGSize(width: 150, height: statusesArray.count * 44 + 8)
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0) //UIPopoverArrowDirection.any
        vc.tableViewDataSourceOne = statusesArray
//        vc.heightOfTitlesView.constant = 50
        vc.selectedIndexForUnitsView = indexPath.row + 1
        
//        if(selectedCell?.isKind(of: UnitCollectionViewCell.self))!{
//            popOver?.sourceView = selectedCell.subView
//        }

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
extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .red
        messageLabel.backgroundColor = .orange
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
extension ProjectDetailsViewController  : NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

//        print("A. NSFetchResultController controllerWillChangeContent :)")
        if(controller == self.fetchedResultsControllerBlocks){
            self.mTableView.beginUpdates()
        }
        if(controller == self.fetchedResultsControllerUnits){
            self.mUnitsCollectionView.reloadData()
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if(controller == self.fetchedResultsControllerUnits){
            switch type {
            case .insert: break
//                mUnitsCollectionView.insertRows(at: [newIndexPath!], with: .automatic)
            case .delete: break
//                mUnitsCollectionView.deleteRows(at: [indexPath!], with: .automatic)
            case .update:
//            let cell = mUnitsCollectionView.cellForItem(at: indexPath!) as! UnitDetailsCollectionViewCell
            mUnitsCollectionView.reloadItems(at: [indexPath!])
                break
//                let cell = tableView.cellForRow(at: indexPath!) as! TeamCell
//                configure(cell: cell, for: indexPath!)
            case .move: break
//                tableView.deleteRows(at: [indexPath!], with: .automatic)
//                tableView.insertRows(at: [newIndexPath!], with: .automatic)
            }
        }
//        print("B. NSFetchResultController didChange NSFetchedResultsChangeType \(type.rawValue):)")
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if(controller == self.fetchedResultsControllerBlocks){
            self.mTableView.endUpdates()
        }
        if(controller == self.fetchedResultsControllerUnits){
            self.mUnitsCollectionView.reloadData()
        }
    }
}
extension ProjectDetailsViewController : FloatingPanelControllerDelegate{
    //MARK: - FLOAT PANEL BEGIN
    //MARK: - FLOATING PANEL DELGATE
    @objc func moveFpcViewToFull() {
        fpc.move(to: .full, animated: true)
    }
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return  CustomPanelLayout(parent: self)
        //FullScreenCustomPanelLayout
    }

//    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
//        return HalfFloatingPanelLayout(parent: self)
//    }
    func floatingPanelShouldBeginDragging(_ vc: FloatingPanelController) -> Bool{
        return true
    }
}
extension ProjectDetailsViewController : AgreementsDelegate{
    
    func didSelectAgreementType(agreementType: Int) {
    
        self.dismiss(animated: true, completion: nil)

        let agControlelr = AgreementViewController(nibName: "AgreementViewController", bundle: nil)
        
        let selectedUnit = self.fetchedResultsControllerUnits.object(at: self.indexPathForUnitSelection)
        
        let unitDetailsString = String(format: "%@ > %@ > %@ > %d > %@ > %@ (%@)", self.selectedProject.name!,selectedUnit.blockName!,selectedUnit.towerName!,selectedUnit.floorIndex,selectedUnit.typeName ?? "",selectedUnit.unitDisplayName!,selectedUnit.description1!)
        agControlelr.unitPath = unitDetailsString
        agControlelr.selectedUnit = selectedUnit
        
        
        ServerAPIs.getAggreementDatesByType(forUnit: selectedUnit.id!, type: agreementType, completionHandler: { (responseObject,nil) in
            
            if(responseObject?.status == 1){
                
                agControlelr.astTableViewDataSource = responseObject?.astInfo?.ast
                agControlelr.astInfo = responseObject?.astInfo
                
                if(agreementType == AGREEMENT_TYPES.Sales_Agreement){
                    agControlelr.agreementType = agreementType
                }
                else if(agreementType == AGREEMENT_TYPES.Assigment_Agreement){
                    agControlelr.agreementType = agreementType
                }
                self.navigationController?.pushViewController(agControlelr, animated: true)
            }
            else{
                HUD.flash(.label(""))
            }
        })
    }
}
extension ProjectDetailsViewController : FilterDelegate{
    
    func didFinishUnitFilterSelection(selectedTypeNamesArray : [String],selectedFacingNamesArray : [String],selectedBuiltUpAreasArray : [String],selectedCarpetAreasArray : [String],selectedBedRoomsArray : [String],selectedBathRoomsArray: [String],selectedFloorPremiums : [String],selectedOtherPremiums : [String],selectedMiscArray : [String], shouldDismiss : Bool,tableViewSectionsSelectedCountDict:Dictionary<Int,Int>) {
        
        self.resetFilters()
        
        if(selectedTypeNamesArray.count > 0 || selectedFacingNamesArray.count > 0 || selectedBuiltUpAreasArray.count > 0 || selectedCarpetAreasArray.count > 0 || selectedBedRoomsArray.count > 0 || selectedBathRoomsArray.count > 0 || selectedFloorPremiums.count > 0 || selectedOtherPremiums.count > 0 || selectedMiscArray.count > 0){
            self.filterButton.setImage(UIImage.init(named: "filter1"), for: .normal)
        }
        else{
            self.filterButton.setImage(UIImage.init(named: "filter"), for: .normal)
        }

        self.selectedTypeNamesArray = selectedTypeNamesArray
        self.selectedFacingNamesArray = selectedFacingNamesArray
        self.selectedBuiltUpAreasArray = selectedBuiltUpAreasArray
        self.selectedCarpetAreaArray = selectedCarpetAreasArray
        self.selectedBedRoomsArray = selectedBedRoomsArray
        self.selectedBathRoomsArray = selectedBathRoomsArray
        self.selectedFloorPremiums = selectedFloorPremiums
        self.selectedOtherPremiums = selectedOtherPremiums
        self.selectedMiscArray = selectedMiscArray
        self.tableViewSectionsSelectedCountDict = tableViewSectionsSelectedCountDict
        
        self.fetchAllUnits()
        
        if(shouldDismiss){
            self.dismiss(animated: true, completion: nil)
        }

    }
    
}

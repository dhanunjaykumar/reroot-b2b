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

class ProjectDetailsViewController: UIViewController ,UIPopoverPresentationControllerDelegate,HidePopUp,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource,BookUnitDelegate,UISearchBarDelegate,UICollectionViewDelegateFlowLayout
{
    var selectedBlockInUnitBlocksView : String!

    var refreshControl: UIRefreshControl?
    var unitRefreshControl : UIRefreshControl?
    @IBOutlet var popUpSourceView: UIView!
    var popUpDataDict = Dictionary<String,Array<TOWERDETAILS>>()
    var orderedBlocksArrayForPopUp = NSMutableOrderedSet()
    var floatPopUpRowCounter : Int!
    
    var projectsArray : Array<Project> = []

    @IBOutlet var colorCollectionView: UICollectionView!
    var currentTitlesOfBlocks = Array<String>()
    var currentUnitsDataSource : Dictionary<String,Array<UnitDetails>> = [:]
    @IBOutlet var titleSubView: UIView!
    var currentBlocksArray : [BlockDetails]!
    var blocksArray : [BlockDetails]!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var statusLabel: UILabel!
    var selectedIndexForDetailedProjectView : Int!
    var statusArray : Array<String>!
    var selectedIndexPath : IndexPath!
    var selectedProjectIndexPath : IndexPath!
    var indexPathForUnitSelection : IndexPath!
    @IBOutlet var mUnitsCollectionView: UICollectionView!
    @IBOutlet var unitsView: UIView!
    @IBOutlet var popUpSourceLabel: UILabel!
    @IBOutlet var projectTitleLabel: UILabel!
    @IBOutlet var titleView: UIView!
    var mCollectionViewDataSource : Array! = []
    var projectDetails : ProjectDetails!
    @IBOutlet var subPartTypeLabel: UILabel!
    @IBOutlet var allBlocksLabel: UILabel!
    @IBOutlet var allBlocksView: UIView!
    @IBOutlet var mProjectsSubPartsTypeView: UIView!
    @IBOutlet var mTableView: UITableView!
    @IBOutlet var mCollectionView: CustomCollectionView!
    var selectedProject : Project!
    var collectionViewDataSource : [STAT]!
    var totalNumberOfFloors : Int = 0
    var blocksButton : ButtonView!
    var orderdSectionTitls = NSMutableOrderedSet()
    
    var numberOfSections : Dictionary<String,Array<UnitDetails>> = [:]

    
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
        
        self.makeFloatButtonPopUpDataSource()
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchBar.isHidden = true
        
        selectedIndexForDetailedProjectView = 0
        statusArray = ["Vacant","Booked","Sold","Reserved","Blocked"]
        
        //0 - Vacant, 1 - Booked, 2- Sold, 3 - Reserved, 4 - Blocked, 5 - Handed Over
        
        self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "f1f7ff")
        
        mCollectionView.register(UINib(nibName: "BlockInfoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "blockCell")
        mUnitsCollectionView.register(UINib(nibName: "SingleUnitCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "singleUnit")
        colorCollectionView.register(UINib(nibName: "ColorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "colorCell")


        let tapGuesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyBoard))
        tapGuesture.cancelsTouchesInView = false
        mUnitsCollectionView.addGestureRecognizer(tapGuesture)
        
        
//        mUnitsCollectionView.register(UnitHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "unitHeader")  // UICollectionReusableView

        
//        mUnitsCollectionView.register(UINib(nibName: "UnitCollectionReusableView", bundle: nil), forCellWithReuseIdentifier: "unitHeader")
        
        let tempLayout = UICollectionViewFlowLayout.init()
        tempLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tempLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        tempLayout.minimumInteritemSpacing = 0
        tempLayout.minimumLineSpacing = 0
        tempLayout.scrollDirection = .horizontal
        mCollectionView.collectionViewLayout = tempLayout
        
        print(projectDetails)
        
        blocksArray = projectDetails.blocks
        currentBlocksArray = blocksArray // for search bar purpose
        
        mCollectionView.delegate = self
        mCollectionView.dataSource = self
        
        let nib = UINib(nibName: "BlockDetailsTableViewCell", bundle: nil)
        mTableView.register(nib, forCellReuseIdentifier: "blockDetailCell")

        mTableView.estimatedRowHeight = 400 // standard tableViewCell height
        mTableView.rowHeight = UITableView.automaticDimension

        mTableView.delegate = self
        mTableView.dataSource = self

        mTableView.tableFooterView = UIView()
        
        projectTitleLabel.text = String(format: "%@ - %@", selectedProject.name!,selectedProject.city!)
//        buildDataSourceForBlockWise()
        
        self.buildFloatingButton()
        unitsView.isHidden = true
        
        buildDataSourceAsFloorWise()
        
        let tempLayout1 = UICollectionViewFlowLayout.init()
//        tempLayout1.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tempLayout1.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        tempLayout1.itemSize = CGSize(width: self.view.frame.size.width/4, height: 70)
        tempLayout1.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        tempLayout1.headerReferenceSize =  CGSize(width: self.mUnitsCollectionView.frame.size.width, height: 50)
        // CGSizeMake(self.mUnitsCollectionView.frame.size.width, 50);
        tempLayout1.minimumInteritemSpacing = 0
        tempLayout1.minimumLineSpacing = 5
        tempLayout1.scrollDirection = .vertical
        mUnitsCollectionView.collectionViewLayout = tempLayout1
        mUnitsCollectionView.backgroundColor = UIColor.hexStringToUIColor(hex: "f0f7ff")

        statusLabel.isHidden = true
        
        
        let tempLayout2 = UICollectionViewFlowLayout.init()
        tempLayout2.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tempLayout2.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        tempLayout2.minimumInteritemSpacing = 0
        tempLayout2.minimumLineSpacing = 0
        tempLayout2.scrollDirection = .horizontal
        colorCollectionView.collectionViewLayout = tempLayout2
        
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        
        self.addRefreshControl()
        

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
        blocksButton = ButtonView.instanceFromNib() as? ButtonView
        blocksButton.backgroundColor = UIColor.white
        self.view.addSubview(blocksButton)
        
        blocksButton.mTitleLabel?.text = "Blocks"

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
    }
    @objc func hideKeyBoard(){
        
        self.view.endEditing(true)
        self.searchBar.endEditing(true)
        
        searchBar.isHidden = true
        titleSubView.isHidden = false
        searchButton.isHidden = false

    }
    @objc func showBlocks() {
        
        //show blocks pop up
        
        if(popUpDataDict.keys.count == 0){
            return
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .BLOCKS_FLOAT_BUTTON
        vc.preferredContentSize = CGSize(width: 250, height: (floatPopUpRowCounter * 44) - 44)
        
        if(CGFloat((floatPopUpRowCounter * 44)) > (self.view.frame.size.height - 150)){
            
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
        
        floatPopUpRowCounter = 0
        popUpDataDict.removeAll()
        orderedBlocksArrayForPopUp.removeAllObjects()
        
        let blocks = projectDetails.blocks!
        
        for tempBlock in blocks{
            
            // get all towers related to block
            let blockId = tempBlock._id
            let filterredTowers = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }
            
            var towersArray : [TOWERDETAILS] = [TOWERDETAILS]()
            
            for tempTower in filterredTowers{
                
                let towerId = tempTower._id
                let filterredUnits = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(towerId!))! }
                
                if(filterredUnits.count > 0){
                    towersArray.append(tempTower)
                }
            }
            if(towersArray.count > 0){
                orderedBlocksArrayForPopUp.add(tempBlock.name!)
                floatPopUpRowCounter = floatPopUpRowCounter + towersArray.count
                popUpDataDict[tempBlock.name!] = filterredTowers
            }
        }
        
        print(popUpDataDict)
        print(popUpDataDict.keys)
        
        floatPopUpRowCounter = floatPopUpRowCounter + popUpDataDict.keys.count
        
    }

    func buildDataSourceAsFloorWise(){
        
//        for tower in projectDetails.towers!{
//            totalNumberOfFloors += tower.total_floors!
//        }
        
//        currentTitlesOfBlocks = orderdSectionTitls.array as! [String]
//        currentUnitsDataSource = numberOfSections // for search
        
        currentTitlesOfBlocks.removeAll()
        currentUnitsDataSource.removeAll()
        orderdSectionTitls.removeAllObjects()
        numberOfSections.removeAll()
        
        // number blocks , each block with towers and then each tower with floors , floor with units
        
        let blocks = projectDetails.blocks!
        
        for tempBlock in blocks{
            
            let blockId = tempBlock._id
            
            //get towers related to block Id
            
            let towers = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }
            
            //parse based on tower type :
            
            for tempTower in towers{
                print(tempTower)
                
                //get units related to towers and index them as per the floor
                
                let towerId = tempTower._id
                
                var filterredUnits = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(towerId!))! }
                
                filterredUnits.sort { ($0.floor?.index!)! <= ($1.floor?.index!)! }
                
                if(tempTower.towerType == 0){
                    
                    // ** Build dictionary **
                    
                    for tempUnit in filterredUnits{
                        // tempUnit
                        let floorIndex = tempUnit.floor?.index
                        print(floorIndex ?? "")
                        
                        let sectionTitle = String(format: "%@ - %@ - %d", tempBlock.name! , tempTower.name!,floorIndex!)
                        
                        orderdSectionTitls.add(sectionTitle)
                        
                        var unitArray = numberOfSections[sectionTitle]
                        
                        if(unitArray == nil){
                            unitArray = [tempUnit]
                            numberOfSections[sectionTitle] = unitArray
                        }
                        else{
                            unitArray?.append(tempUnit)
                            unitArray?.sort( by: { $0.description! < $1.description! })
                            numberOfSections[sectionTitle] = unitArray
                        }
                    }
                }
                else
                {
                    
                    for tempUnit in filterredUnits{
                        // tempUnit
                        let floorIndex = tempUnit.floor?.index
                        print(floorIndex ?? "")
                        
                        let sectionTitle = String(format: "%@ - %@", tempBlock.name! , tempTower.name!)
                        
                        orderdSectionTitls.add(sectionTitle)
                        
                        var unitArray = numberOfSections[sectionTitle]
                        
                        if(unitArray == nil){
                            unitArray = [tempUnit]
                            numberOfSections[sectionTitle] = unitArray
                        }
                        else{
                            unitArray?.append(tempUnit)
                            unitArray?.sort( by: { $0.description! < $1.description! })
                            numberOfSections[sectionTitle] = unitArray
                        }
                    }
                }
                print(numberOfSections.keys)
                print(orderdSectionTitls)
            }
            
            print(numberOfSections.keys)
            print(orderdSectionTitls)
            currentTitlesOfBlocks = orderdSectionTitls.array as! [String]
            currentUnitsDataSource = numberOfSections // for search
            if(currentTitlesOfBlocks.count > 0){
                blocksButton.mTitleLabel.text = currentTitlesOfBlocks[0]
            }
        }
    }
    //MARK: - Tableview Delegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numOfRows: Int = currentBlocksArray.count
        
        if (numOfRows > 0)
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

        
        return numOfRows //currentBlocksArray.count //(projectDetails.blocks?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : BlockDetailsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "blockDetailCell",
            for: indexPath) as! BlockDetailsTableViewCell
        
        let block : BlockDetails = currentBlocksArray[indexPath.row]
        let name = block.name
        cell.mBlockNameLabel.text = name
        
        let blockId = block._id
        
//        let towers = projectDetails.towers!
        
//        let towerID = projectDetails.towers![section]._id
        let filteredUnits = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }

        print(filteredUnits)
        
        cell.mTowersInfoLabel.text = String(format: "%d Towers/Rows", filteredUnits.count)
        
        cell.mCollectionView.delegate = self
        cell.mCollectionView.dataSource = self
        
        cell.mCollectionView.mParentIndexPath = indexPath
        
        cell.subContentView.layer.cornerRadius = 4
        cell.subContentView.layer.borderWidth = 2
        cell.subContentView.layer.borderColor = UIColor.clear.cgColor
        cell.subContentView.layer.shadowRadius = 4
        cell.subContentView.layer.masksToBounds = false
        cell.subContentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.subContentView.layer.shadowRadius = 2
        cell.subContentView.layer.shadowOpacity = 0.3
        
        cell.contentView.bringSubviewToFront(cell.subContentView)
        
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let tempCell = cell as! BlockDetailsTableViewCell
            tempCell.mCollectionView.reloadData()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectedBlockInUnitBlocksView
        
        let block : BlockDetails = currentBlocksArray[indexPath.row]
//        let name = block.name
        
        let blockId = block._id
        
        //        let towers = projectDetails.towers!
        
        //        let towerID = projectDetails.towers![section]._id
        let filteredUnits = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }

//        selectedBlockInUnitBlocksView = String(format: "%@ - %@", block.name,filteredUnits[0].name)
        //
        unitsView.isHidden = false
        self.view.bringSubviewToFront(unitsView)
        unitsView.backgroundColor = UIColor.green
        
        mUnitsCollectionView.delegate = self
        mUnitsCollectionView.dataSource = self
        selectedIndexForDetailedProjectView = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.reloadCollectionView()
        }
        
        if(selectedIndexForDetailedProjectView == 1){
            allBlocksLabel.text = "All Units"
            allBlocksLabel.textAlignment = .left
            statusLabel.isHidden = false
            blocksButton.isHidden = false
            self.view.bringSubviewToFront(blocksButton)
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
        if(filteredUnits.count > 0){
            self.showSelectedTowerFromFloatButton(selectedTower: filteredUnits[0], selectedBlock: block.name!)
        }
    }
    //MARK: - CollectionView Delegate & DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(collectionView === mUnitsCollectionView){
            
            if (currentTitlesOfBlocks.count > 0) {
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

            return currentTitlesOfBlocks.count //numberOfSections.keys.count // Number of sections  //(projectDetails.towers?.count)!
        }
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView === mUnitsCollectionView){
            
//            let towerID = projectDetails.towers![section]._id
//            let filteredUnits = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(towerID!))! }
//
//            return filteredUnits.count
            let key  = currentTitlesOfBlocks[section]
            let unitsArray : Array<UnitDetails> = (currentUnitsDataSource[key])!
            
            return unitsArray.count
        }
        
        return 5 //** Statuses
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView === colorCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCollectionViewCell
            
            let statucColorDict = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: indexPath.row)
            cell.contentView.layoutIfNeeded()
            cell.statusTitleLabel.text = statucColorDict["statusString"] as? String
            cell.statusColorIndicatorView.backgroundColor = statucColorDict["color"] as? UIColor
            
            cell.subContentView.backgroundColor = UIColor.hexStringToUIColor(hex: "f8fbff")
            cell.subContentView.layoutIfNeeded()
            cell.statusTitleLabel.preferredMaxLayoutWidth = 70

            cell.layoutIfNeeded()
            return cell
        }
        else if(collectionView === mCollectionView){
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "blockCell", for: indexPath) as! BlockInfoCollectionViewCell
            
            let statucColorDict = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: indexPath.row)
            
            cell.mSubContentView.backgroundColor = statucColorDict["color"] as? UIColor
            cell.mStatusTypeLabel.text = statucColorDict["statusString"] as? String
            cell.mStatusTypeLabel.textColor = UIColor.white
            let tempCountDict =  self.getStatusOfBlocks(indexPath: indexPath)
            cell.mStatusTypeNumberLabel.text = String(tempCountDict["count"]! )
            
            cell.mStatusTypeNumberLabel.text =  String(format:"%d", tempCountDict["count"]!)
            cell.mStatusTypeNumberLabel.textColor = UIColor.white
            cell.mStatusTypeLabel.preferredMaxLayoutWidth = 70;
            
            return cell

        }
        else if(collectionView === mUnitsCollectionView){
         
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "unitCell", for: indexPath) as! UnitCollectionViewCell

            
            let key : String = currentTitlesOfBlocks[indexPath.section]
            let unitsArray = currentUnitsDataSource[key]
            
            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
            
//            let towerID = projectDetails.towers![indexPath.section]._id
//            let filteredUnits : [UnitDetails] = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(towerID!))! }
//
//            let unitIndex = filteredUnits[indexPath.row].unitNo?.index
//
            let tempUnit : UnitDetails = unitsArray![indexPath.row]

            let towerId = tempUnit.tower
            
            let tempTower = projectDetails.towers!.filter { ($0._id?.localizedCaseInsensitiveContains(towerId!))! }
            
            let towerType = tempTower[0].towerType
            
            let statucColorDict  = RRUtilities.sharedInstance.getColorAccordingToUnitStatus(status: tempUnit.status!)

            if(towerType == 0){
                
                if(tempUnit.floorPremium != nil){
                    cell.unitImageView.isHidden = false
                }
                else{
                    cell.unitImageView.isHidden = true
                }
                cell.unitNumberLabel.text =  tempUnit.description//String(format: "%d", (tempUnit.unitNo?.index!)!)
                
                cell.unitNumberLabel.preferredMaxLayoutWidth = 72;
                
                cell.subView.layer.cornerRadius = 8
                cell.subView.backgroundColor = statucColorDict["color"] as? UIColor
                
                cell.subView.addGestureRecognizer(longGesture)

            }
            else if(towerType ==  1){
                
                let singleUnitCell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleUnit", for: indexPath) as! SingleUnitCollectionViewCell
                
                let shouldEnable = UserDefaults.standard.bool(forKey: "Unit Description Enabled")
                
                if(shouldEnable){
                    singleUnitCell.floorNameLabel.text = tempUnit.description
                    singleUnitCell.unitIndexLabel.text = String(format: "%d", (tempUnit.floor?.index)!)
                    singleUnitCell.heightOfUnitIndexLabel.constant = 30
                }
                else{
                    singleUnitCell.floorNameLabel.text = String(format: "%d", (tempUnit.floor?.index)!)
                    singleUnitCell.unitIndexLabel.text = ""
                    singleUnitCell.heightOfUnitIndexLabel.constant = 0
                }
                
                singleUnitCell.subView.backgroundColor = statucColorDict["color"] as? UIColor
                singleUnitCell.subView.layer.cornerRadius = 8.0

                let cellWidth = (collectionView.frame.size.width - 24) / 2
                singleUnitCell.widthOfCell.constant = cellWidth
                singleUnitCell.subView.addGestureRecognizer(longGesture)
                

                if(tempUnit.floorPremium != nil){
                    singleUnitCell.unitImageView.isHidden = false
                }
                else{
                    singleUnitCell.unitImageView.isHidden = true
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
                cell.unitNumberLabel.text =  tempUnit.description//String(format: "%d", (tempUnit.unitNo?.index!)!)
                
                cell.unitNumberLabel.preferredMaxLayoutWidth = 72;
                
                cell.subView.layer.cornerRadius = 8
                cell.subView.backgroundColor = statucColorDict["color"] as? UIColor
                
                cell.subView.addGestureRecognizer(longGesture)

            }
            
            
            
            return cell

        }
        else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "blockCell", for: indexPath) as! BlockInfoCollectionViewCell
            
            let tempCollectionView = collectionView as! CustomCollectionView
            print(tempCollectionView.mParentIndexPath.row)
            let block : BlockDetails = currentBlocksArray[tempCollectionView.mParentIndexPath.row]
            let statucColorDict  = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: indexPath.row)

            if((currentBlocksArray.count) > 0){
                
                if(block.stats != nil){
                    let statsArray : [STAT] = block.stats!
                    
                    print(statsArray)
                    
                    cell.mSubContentView.backgroundColor = UIColor.white
                    cell.mStatusTypeLabel.text = statucColorDict["statusString"] as? String
                    cell.mStatusTypeLabel.textColor = UIColor.lightGray
                    
                    var isStatusAvailable = false
                    
                    for statusOfCell in statsArray{
                        
                        if(indexPath.row == statusOfCell.status){
                            isStatusAvailable = true
//                            print("status")
//                            print(statusOfCell.status)
                            cell.mStatusTypeNumberLabel.text  = String(format: "%d", statusOfCell.count!)
                            cell.mStatusTypeNumberLabel.textColor = statucColorDict["color"] as! UIColor
                            break
                        }
                    }
                    
                    if(isStatusAvailable == false){
                        cell.mStatusTypeNumberLabel.text  = "0"
                        cell.mStatusTypeNumberLabel.textColor = statucColorDict["color"] as! UIColor
                    }
                }
                else{
                    
                    cell.mSubContentView.backgroundColor = UIColor.white
                    cell.mStatusTypeLabel.text = statucColorDict["statusString"] as? String
                    cell.mStatusTypeLabel.textColor = UIColor.lightGray
                    
                    cell.mStatusTypeNumberLabel.text  = "0"
                    cell.mStatusTypeNumberLabel.textColor = statucColorDict["color"] as! UIColor
                }
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        print("COLL CELL SELECTED")
        
        //blockWiseController
//        self.searchBar.endEditing(true)
        
        if(collectionView != mCollectionView && collectionView != mUnitsCollectionView ){
            unitsView.isHidden = false
            self.view.bringSubviewToFront(unitsView)
            unitsView.backgroundColor = UIColor.green
            
            mUnitsCollectionView.delegate = self
            mUnitsCollectionView.dataSource = self
            selectedIndexForDetailedProjectView = 1
            
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.view.bringSubviewToFront(self.colorCollectionView)
                self.colorCollectionView.reloadData()
            }


            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.reloadCollectionView()
            }
            
            if(selectedIndexForDetailedProjectView == 1){
                allBlocksLabel.text = "All Units"
                allBlocksLabel.textAlignment = .left
                statusLabel.isHidden = false
                blocksButton.isHidden = false
                self.view.bringSubviewToFront(blocksButton)
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
                
                if(currentBlocksArray.count > 0){
                    // get tableiview cell then get indexpath of collectionview
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        let block : BlockDetails = self.currentBlocksArray[selectedCell.mCollectionView.mParentIndexPath.row]
                        
                        let blockId = block._id
                        
                        let filteredUnits = self.projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }
                        
                        if(filteredUnits.count > 0){
                            self.showSelectedTowerFromFloatButton(selectedTower: filteredUnits[0], selectedBlock: block.name!)
                        }
                        else{
                            
                        }
                    }
                }

            }
        }
        else if(collectionView === mCollectionView){
            // show only units with selected status
            
            unitsView.isHidden = false
            self.view.bringSubviewToFront(unitsView)
            unitsView.backgroundColor = UIColor.green
            
            mUnitsCollectionView.delegate = self
            mUnitsCollectionView.dataSource = self
            
            self.parseUnitsWithSelectedStatus(selectedStatus: indexPath.row)
            
            let statucColorDict = RRUtilities.sharedInstance.getColorAccordingToStatusNumber(status: indexPath.row)
            
            self.view.bringSubviewToFront(blocksButton)
            
            selectedIndexForDetailedProjectView = 1
            
            if(selectedIndexForDetailedProjectView == 1){
                allBlocksLabel.text =  statucColorDict["statusString"] as? String
                allBlocksLabel.textAlignment = .left
                statusLabel.isHidden = false
                blocksButton.isHidden = false
                statusLabel.isHidden = false
                blocksButton.isHidden = false
                self.view.bringSubviewToFront(blocksButton)
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
        }
       else if(collectionView === mUnitsCollectionView){
            
            // show book unit view
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
            let nextStatus : BLOCK_STATUS = RRUtilities.sharedInstance.getNextStatusFromCurrentStatus(currentStatus: tempUnit.status!)
            print(nextStatus.rawValue)
            
            
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
            
            self.present(detailsController, animated: true, completion: nil)
            
//            self.navigationController?.pushViewController(detailsController, animated: true)

            // Show pop up of statuses on long press .
            return
        }
    }
    func reloadCollectionView(){

        mUnitsCollectionView.reloadData()
        
        DispatchQueue.main.async {
            self.mUnitsCollectionView.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        print("width is \(cell.frame.size.width)")
        if(collectionView == mUnitsCollectionView){
            mUnitsCollectionView.layoutIfNeeded()
        }
        else if(collectionView == colorCollectionView){
            colorCollectionView.layoutIfNeeded()
        }
//        collectionView.layoutIfNeeded()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
            switch kind {
                
            case UICollectionView.elementKindSectionHeader:
                
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "unitHeader", for: indexPath) as! UnitHeaderCollectionReusableView
                //            headerView.frame = CGRect(0 , 0, self.view.frame.width, 40)
                
                headerView.titleLabel.text = currentTitlesOfBlocks[indexPath.section]
                //            headerView.backgroundColor = UIColor.green
                return headerView
                
                //        case UICollectionElementKindSectionFooter:
                //            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
                //
                //            footerView.backgroundColor = UIColor.green
                //            return footerView
                
            default:
                fatalError("Unexpected element kind")
                break
//                assert(false, "Unexpected element kind")
            }
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        if(!unitsView.isHidden){
            if let indexPath : IndexPath = self.mUnitsCollectionView.indexPathsForVisibleItems.first {
                blocksButton.mTitleLabel.text = currentTitlesOfBlocks[indexPath.section]
            }
        }
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
//        let cellWidth = collectionView.frame.size.width / 4
//        return CGSize(width: 100.0, height: 100.0)
//    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if(!unitsView.isHidden){
            if(currentTitlesOfBlocks.count > 0){
                
                let indexPath : IndexPath = self.mUnitsCollectionView.indexPathsForVisibleItems.first!
                blocksButton.mTitleLabel.text = currentTitlesOfBlocks[indexPath.section]
                blocksButton.subView.layoutIfNeeded()
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(!unitsView.isHidden){
            if let indexPath : IndexPath = self.mUnitsCollectionView.indexPathsForVisibleItems.first {
                blocksButton.mTitleLabel.text = currentTitlesOfBlocks[indexPath.section]
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
        allBlocksLabel.textAlignment = .left
        statusLabel.isHidden = false
        blocksButton.isHidden = false
        self.view.bringSubviewToFront(blocksButton)
        subPartTypeLabel.text = "Units"

    }
    func parseUnitsWithSelectedStatus(selectedStatus : Int)
    {
        numberOfSections.removeAll()
        orderdSectionTitls.removeAllObjects()
        
        let blocks = projectDetails.blocks!
        
        for tempBlock in blocks{
            
            let blockId = tempBlock._id
            
            //get towers related to block Id
            
            let towers = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }
            
            for tempTower in towers{
                print(tempTower)
                
                //get units related to towers and index them as per the floor
                
                let towerId = tempTower._id
                
                var filterredUnits = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(towerId!))! }
                
                if(selectedStatus != -1){
                    filterredUnits = filterredUnits.filter{ ($0.status == selectedStatus) }
                }
                
                //                filterredUnits.sort { $0.description! < $1.description! }
                filterredUnits.sort { ($0.floor?.index!)! <= ($1.floor?.index!)! }
                // Build dictionary **
                
                if(tempTower.towerType == 0){
                    for tempUnit in filterredUnits{
                        // tempUnit
                        let floorIndex = tempUnit.floor?.index
                        print(floorIndex ?? "")
                        
                        let sectionTitle = String(format: "%@ - %@ - %d", tempBlock.name! , tempTower.name!,floorIndex!)
                        
                        orderdSectionTitls.add(sectionTitle)
                        
                        var unitArray = numberOfSections[sectionTitle]
                        
                        if(unitArray == nil){
                            unitArray = [tempUnit]
                            numberOfSections[sectionTitle] = unitArray
                        }
                        else{
                            unitArray?.append(tempUnit)
                            unitArray?.sort( by: { $0.description! < $1.description! })
                            numberOfSections[sectionTitle] = unitArray
                        }
                    }

                }
                else
                {
                    for tempUnit in filterredUnits{
                        // tempUnit
                        let floorIndex = tempUnit.floor?.index
                        print(floorIndex ?? "")
                        
                        let sectionTitle = String(format: "%@ - %@", tempBlock.name! , tempTower.name!)
                        
                        orderdSectionTitls.add(sectionTitle)
                        
                        var unitArray = numberOfSections[sectionTitle]
                        
                        if(unitArray == nil){
                            unitArray = [tempUnit]
                            numberOfSections[sectionTitle] = unitArray
                        }
                        else{
                            unitArray?.append(tempUnit)
                            unitArray?.sort( by: { $0.description! < $1.description! })
                            numberOfSections[sectionTitle] = unitArray
                        }
                    }

                }
                
                print(numberOfSections.keys)
                print(orderdSectionTitls)
            }
            
            print(numberOfSections.keys)
            print(orderdSectionTitls)
            
            currentUnitsDataSource = numberOfSections
            currentTitlesOfBlocks = (orderdSectionTitls.array as? [String])!
            if(currentTitlesOfBlocks.count > 0){
                blocksButton.mTitleLabel.text = currentTitlesOfBlocks[0]
            }
            else{
                //
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.reloadCollectionView()
        }

    }
    func didFinishBookUnit(clientId : String,bookedUnit : UnitDetails,selectedIndexPath : IndexPath){
        // Update Unit
        //update Datasource
        // collapse view
        
        
        
        let key : String = self.currentTitlesOfBlocks[self.indexPathForUnitSelection.section]
        
        var unitsArray = self.currentUnitsDataSource[key]
        
        var tempUnit : UnitDetails = unitsArray![self.indexPathForUnitSelection.row]
//        let prevState = bookedUnit.status
        let changedStatus =  bookedUnit.status! + 1
        
        print(tempUnit.status ?? "")
        tempUnit.status = changedStatus //changedStatus.rawValue
        print(tempUnit.status ?? "")
        
        unitsArray![self.indexPathForUnitSelection.row] = tempUnit
        self.currentUnitsDataSource[key] = unitsArray
        self.numberOfSections[key] = unitsArray
        
        var unitsArray1 = self.numberOfSections[key]
        let tempUnit1 : UnitDetails = unitsArray1![self.indexPathForUnitSelection.row]
        print(tempUnit1.status ?? "")

        self.mUnitsCollectionView.reloadItems(at: [selectedIndexPath])
        
        //  *** update status of project in db
        
        RRUtilities.sharedInstance.model.updateStatusOfSelectedUnit(selectedProjectId: tempUnit.project!, oldStatus: bookedUnit.status!
            , updatedStatus: bookedUnit.status!+1)
        
        NotificationCenter.default.post(name: Notification.Name("updateProjects"), object: nil)
        
        //  *** update status of project in db

        
        
        self.dismiss(animated: true, completion: nil)
        
        // change in db also?
    }
    func didSelectProject(optionType : String,optionIndex: Int){
        
        self.selectedProjectIndexPath = IndexPath.init(row: optionIndex, section: 0)
        let projecct = self.projectsArray[optionIndex]
        
        let urlString = String(format:RRAPI.PROJECT_DETAILS, projecct.id!)
//
        //        let urlString = String(format:RRAPI.PROJECT_DETAILS, optionType)
//
        self.getSelectedProjectDetails(urlString: urlString)
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }

    func didFinishTask(optionType: String, optionIndex: Int) {
        print(optionType)
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
        
        let key = currentTitlesOfBlocks[indexPathForUnitSelection.section]
        let unitsArray : Array<UnitDetails> = (currentUnitsDataSource[key])!
        
        let selectedUnit = unitsArray[indexPathForUnitSelection.row]
        
        changeStatusOfSelectedUnit(selectedUnitId: selectedUnit._id!,status: optionIndex)

    }
    func didSelectOptionForUnitsView(selectedIndex : Int){
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
        print(selectedIndex)
        selectedIndexForDetailedProjectView = selectedIndex
        
        // parse
        self.buildDataSourceAsFloorWise()
        
        if(selectedIndex == 0){ //show summary
            // hide units view
            unitsView.isHidden = true
            unitsView.backgroundColor = UIColor.green
            blocksButton.isHidden = true
        }
        else{ //show units
            unitsView.isHidden = false
            blocksButton.isHidden = false
            self.view.bringSubviewToFront(unitsView)
            
            mUnitsCollectionView.delegate = self
            mUnitsCollectionView.dataSource = self
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
    func showSelectedTowerFromFloatButton(selectedTower: TOWERDETAILS, selectedBlock: String) {
        
        let tmpController :UIViewController! = self.presentedViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });

        let selectedTowerTitle  = String(format: "%@ - %@", selectedBlock,selectedTower.name!)
    
        var counter = 0
        var found = false
        var tempIndexPath = IndexPath()
        for tempSectionTitle in currentTitlesOfBlocks{
            if(tempSectionTitle.hasPrefix(selectedTowerTitle)){
                tempIndexPath = IndexPath.init(row: 0, section: counter)
                found = true
                break
            }
            counter = counter + 1
        }
        
        if(found){
            mUnitsCollectionView.scrollToItem(at: tempIndexPath, at: .top, animated: true)
        }
        
    }
    

    //MARK: - popOver
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        if(unitsView.isHidden){ // Blocks Search
            currentBlocksArray = blocksArray.filter({ BlockDetails -> Bool in
                switch searchBar.selectedScopeButtonIndex {
                case 0:
                    if searchText.isEmpty { return true }
                    return BlockDetails.name!.lowercased().contains(searchText.lowercased())
                default:
                    return false
                }
            })
            self.mTableView.reloadData()
        }
        else{
            // Units search
            if(searchText.count == 0){
                
                currentUnitsDataSource = numberOfSections
                currentTitlesOfBlocks = (orderdSectionTitls.array as? [String])!
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.reloadCollectionView()
                }

            }else{
                
                self.parseUnitsAsPerSearchString(searchText: searchText)
                
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
    func parseUnitsAsPerSearchString(searchText : String)
    {
        numberOfSections.removeAll()
        orderdSectionTitls.removeAllObjects()
        
//        let blocks = projectDetails.blocks!
        
//        for tempBlock in blocks{
        
//            let blockId = tempBlock._id
        
            //get towers related to block Id
            
//            let towers = projectDetails.towers!.filter { ($0.block?.localizedCaseInsensitiveContains(blockId!))! }
        
//            for tempTower in towers{
//                print(tempTower)
            
                //get units related to towers and index them as per the floor
                
//                let towerId = tempTower._id
                
                var filterredUnits = projectDetails.units!.filter { ($0.description?.localizedCaseInsensitiveContains(searchText))! }
                
//                if(selectedStatus != -1){
//                    filterredUnits = filterredUnits.filter{ ($0.status == selectedStatus) }
//                }
                
                //                filterredUnits.sort { $0.description! < $1.description! }
        
                filterredUnits.sort { ($0.floor?.index!)! <= ($1.floor?.index!)! }
        
                // Build dictionary **
        
                for tempUnit in filterredUnits{
                    // tempUnit
                    let floorIndex = tempUnit.floor?.index
                    print(floorIndex ?? "")
                    
                    
                    let tempBlock =  projectDetails.blocks?.filter{ ($0._id?.localizedCaseInsensitiveContains(tempUnit.block!))! }
                    let tempTower = projectDetails.towers!.filter { ($0._id?.localizedCaseInsensitiveContains(tempUnit.tower!))! }
                    
                    if(tempBlock?.count == 0 || tempTower.count == 0){
                        continue
                    }
                    let towerDetails = tempTower[0]
                    
                    if(towerDetails.towerType == 0){
                        let sectionTitle = String(format: "%@ - %@ - %d", tempBlock![0].name! , tempTower[0].name!,floorIndex!)
                        
                        orderdSectionTitls.add(sectionTitle)
                        
                        var unitArray = numberOfSections[sectionTitle]
                        
                        if(unitArray == nil){
                            unitArray = [tempUnit]
                            numberOfSections[sectionTitle] = unitArray
                        }
                        else{
                            unitArray?.append(tempUnit)
                            unitArray?.sort( by: { $0.description! < $1.description! })
                            numberOfSections[sectionTitle] = unitArray
                        }
                    }
                    else{
                        let sectionTitle = String(format: "%@ - %@", tempBlock![0].name! , tempTower[0].name!)
                        
                        orderdSectionTitls.add(sectionTitle)
                        
                        var unitArray = numberOfSections[sectionTitle]
                        
                        if(unitArray == nil){
                            unitArray = [tempUnit]
                            numberOfSections[sectionTitle] = unitArray
                        }
                        else{
                            unitArray?.append(tempUnit)
                            unitArray?.sort( by: { $0.description! < $1.description! })
                            numberOfSections[sectionTitle] = unitArray
                        }
                    }
                }
                print(numberOfSections.keys)
                print(orderdSectionTitls)
//            }
            
            print(numberOfSections.keys)
            print(orderdSectionTitls)
            
            currentUnitsDataSource = numberOfSections
            currentTitlesOfBlocks = (orderdSectionTitls.array as? [String])!
//            if(currentTitlesOfBlocks.count > 0){
//                blocksButton.mTitleLabel.text = currentTitlesOfBlocks[0]
//            }
//            else{
//                //
//            }
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.reloadCollectionView()
        }
        
    }
//    {
//
//        var filterredUnits = projectDetails.units!.filter { ($0.description?.localizedCaseInsensitiveContains(searchText))! }
//
//        print(filterredUnits)
//
//        filterredUnits.sort { ($0.floor?.index!)! <= ($1.floor?.index!)! }
//
//
//    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(selectedScope)
        
        if(unitsView.isHidden){
            
            switch selectedScope {
            case 0:
                currentBlocksArray = blocksArray
            default:
                break
            }

            mTableView.reloadData()
        }
        else{
            switch selectedScope {
            case 0:
                currentUnitsDataSource = numberOfSections
                currentTitlesOfBlocks = (orderdSectionTitls.array as? [String])!
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
        // Hide the cancel button
        //        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
        searchBar.isHidden = true
        titleSubView.isHidden = false
        searchButton.isHidden = false
        if(unitsView.isHidden){
            mTableView.reloadData()
        }
        else{
            currentUnitsDataSource = numberOfSections
            currentTitlesOfBlocks = (orderdSectionTitls.array as? [String])!
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.reloadCollectionView()
            }
        }
        self.view.endEditing(true)
    }

    //MARK: - METHODS
    func getSelectedProjectDetails(urlString: String){
        
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

        Alamofire.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success :
                
                print(response)
                
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                let urlResult = try! JSONDecoder().decode(ProjectDetails.self, from: responseData)
                
                print(urlResult)
                
                self.blocksArray.removeAll()
                self.currentBlocksArray.removeAll()
                
                self.refreshControl?.endRefreshing()
                self.unitRefreshControl?.endRefreshing()

                self.blocksArray = urlResult.blocks
                self.currentBlocksArray = self.blocksArray // for search bar purpose
                self.projectDetails = urlResult
                self.buildDataSourceAsFloorWise()
                self.makeFloatButtonPopUpDataSource()
                
                self.mTableView.reloadData()
                self.reloadCollectionView()
                
                
                HUD.hide()
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
            }
        }
    }
    @IBAction func showSearchBar(_ sender: Any) {
        searchBar.isHidden = false
        searchButton.isHidden = true
        titleSubView.isHidden = true
        if(unitsView.isHidden){
            searchBar.placeholder = "Search Block"
        }else{
            searchBar.placeholder = "Search Unit"
        }
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
    }
    @IBAction func showProjects(_ sender: Any) {
        
        if(self.projectsArray.count > 0){
            //show popup
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
            vc.dataSourceType = .PROJECTS
            vc.preferredContentSize = CGSize(width: 250, height: self.projectsArray.count * 44)
            
            if(CGFloat((self.projectsArray.count * 44)) > (self.view.frame.size.height - 80)){
                
                vc.preferredContentSize = CGSize(width: 250, height: (self.view.frame.size.height - 150))
            }
            
            let navigationContoller = UINavigationController(rootViewController: vc)
            navigationContoller.navigationBar.isHidden = true
            navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
            
            let popOver =  navigationContoller.popoverPresentationController
            popOver?.delegate = self
            popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
            vc.tableViewDataSource = self.projectsArray
            
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
    func getStatusOfBlocks(indexPath : IndexPath) -> Dictionary<String, Int>{
        
        let projecct = selectedProject
        
        var collectionCellDict : Dictionary<String , Int> = [:]
        
        let statssss : NSMutableOrderedSet = projecct!.value(forKey: "proStat") as! NSMutableOrderedSet
        
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
        
        HUD.show(.labeledProgress(title: "Changing status...", subtitle: nil))
        
        Alamofire.request(RRAPI.UNIT_STATUS_CHANGE, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                print(response)
                do{
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    guard let loginResult : Dictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                    }
                    print(loginResult)
                    
                    let urlResult = try! JSONDecoder().decode(STATUS_CHANGE_API_RESULT.self, from: responseData)
                    
                    let key : String = self.currentTitlesOfBlocks[self.indexPathForUnitSelection.section]
                    
                    var unitsArray = self.currentUnitsDataSource[key]
                    
                    var tempUnit : UnitDetails = unitsArray![self.indexPathForUnitSelection.row]
                    let prevState = tempUnit.status
//                    print(urlResult.status)
                    let changedStatus =  urlResult.oldStatus //RRUtilities.sharedInstance.getNextStatusFromCurrentStatus(currentStatus: status)
                    print(tempUnit.status ?? "")
                    tempUnit.status = changedStatus //changedStatus.rawValue
                    print(tempUnit.status ?? "")
                    
                    unitsArray![self.indexPathForUnitSelection.row] = tempUnit
                    self.currentUnitsDataSource[key] = unitsArray
                    self.numberOfSections[key] = unitsArray
                    
                    var unitsArray1 = self.numberOfSections[key]
                    let tempUnit1 : UnitDetails = unitsArray1![self.indexPathForUnitSelection.row]
                    print(tempUnit1.status ?? "")
                    
                    self.mUnitsCollectionView.reloadItems(at: [self.indexPathForUnitSelection as IndexPath])

                    //  *** update status of project in db

                    RRUtilities.sharedInstance.model.updateStatusOfSelectedUnit(selectedProjectId: tempUnit.project!, oldStatus: prevState!
                        , updatedStatus: urlResult.oldStatus!)
                    
                    NotificationCenter.default.post(name: Notification.Name("updateProjects"), object: nil)
                    
                    //  *** update status of project in db
                    
                    print(urlResult)
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
    
    @objc func longTap(_ sender: UIGestureRecognizer){
        print("Long tap")
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
//            print(sender.view)
            
            let tapLocation = sender.location(in: mUnitsCollectionView)
            let indexPath : IndexPath = mUnitsCollectionView.indexPathForItem(at: tapLocation)!
            print(indexPath.section)
            print(indexPath.row)

            indexPathForUnitSelection = indexPath
            
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

    @IBAction func showStatusChangePopUp(_ sender: Any) {
        showPopUpForStatusSelection(indexPath : selectedIndexPath)
    }
    func showPopUpForStatusSelection(indexPath : IndexPath){
        
//        let selectedCell : UnitCollectionViewCell = mUnitsCollectionView.cellForItem(at: indexPath as IndexPath) as!UnitCollectionViewCell
        
        let selectedCell = mUnitsCollectionView.cellForItem(at: indexPath as IndexPath)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! PopOverViewController
        vc.dataSourceType = .STATUS
        vc.preferredContentSize = CGSize(width: 150, height: self.statusArray.count * 44 + 8)
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0) //UIPopoverArrowDirection.any
        vc.tableViewDataSourceOne = self.statusArray
//        vc.heightOfTitlesView.constant = 50
        vc.selectedIndexForUnitsView = indexPath.row + 1
        
//        if(selectedCell?.isKind(of: UnitCollectionViewCell.self))!{
//            popOver?.sourceView = selectedCell.subView
//        }

        if(selectedCell?.isMember(of: UnitCollectionViewCell.self))!{
            let selectedCell = selectedCell as! UnitCollectionViewCell
            popOver?.sourceView = selectedCell.subView
        }else
        {
            popOver?.sourceView = selectedCell?.contentView
        }
        
        vc.delegate = self

        self.present(navigationContoller, animated: true, completion: nil)

    }
    func buildDataSourceForBlockWise()  {
        
        // sections
        // number of cells in sections

    // Predicate to fetch all units related to tower
        
        let towerID = projectDetails.towers![0]._id
        
        let totalNumberOfFloors = projectDetails.towers![0].total_floors

//        print(totalNumberOfFloors)
        
        let filterredUnits = projectDetails.units!.filter { ($0.tower?.localizedCaseInsensitiveContains(towerID!))! }
        
//        var floorWiseUnits = Dictionary<>
        
        for index in 1...totalNumberOfFloors!{
            print(index)
            
        }
        
        print(filterredUnits)

        
//        let mallNamePredicate = NSPredicate(format: "tower contains %@", towerID!)
//        let filteredWithPredicate = (projectDetails.units! as NSArray).filtered(using: mallNamePredicate)

        
//        let filteredData = projectDetails.units!.filter{
//            let string = $0["tower"] as! String
//
//            return string.hasPrefix(towerID)
//        }

        
//        let filterArray: [Any] = projectDetails.units!.filter { NSPredicate(format: "(tower contains[c] %@)", towerID!).evaluate(with: $0) }
//
//        print("filterredActors")
//
        
        
//        var collectionViewDataSource : [String : Array<Any>] = [:]
////        collectionViewDataSource["sections"] =
//
//        var towerWiseSectionsData : [String : Any]
//
////        let numberOfTowers = projectDetails.towers?.count
////        let numberOfBlocks = projectDetails.blocks?.count
////        let numberOfUnits = projectDetails.units?.count
//
////        collectionViewDataSource["sections"] = projectDetails.towers
//
//
//        for indexer in 0..<((projectDetails.towers?.count)!-1){
//
////            print(indexer)
//            print(projectDetails.towers![indexer].name)
//
////            collectionViewDataSource[indexer]
//        }
        
        
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


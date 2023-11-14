//
//  PopOverViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 16/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import CoreData

protocol HidePopUp: class {
    func didSelectProject(optionType : String,optionIndex: Int)
    func didFinishTask(optionType : String,optionIndex: Int)
    func didSelectOptionForUnitsView(selectedIndex : Int)
    func shouldShowUnitsWithSelectedStatus(selectedStatus : Int)
    func showSelectedTowerFromFloatButton(selectedTower : Towers,selectedBlock : String)
    func showSelectedTowerForSoldUnitsFloat(selectedTowerName : String,selectedBlock : String)
    func didSelectLandOwnerName(ownerName : String,selectedOption : Int)
    func didSelectRow(selectedRowText : String,selectedIndex : Int)
    func didSelectProjectBankAccount(bankAccount : BANK_ACCOUNTS,selectedIndex : Int)
    func didSelectCurrency(selectedCurrency : CURRENCY,selectedIndex : Int)
    func didSelectCountryCode(countryCode : String,countryName : String,forFieldIndex: Int)
    func didSelectCommision(selectedCommission : CommissionUser)
    func didSelectScheme(selectedScheme : Schemes)
    func didSelectUnitType(selectedUnitType : UnitTypes)
    func didSelectMinBudget(selectedRange : CustomerBudgets)
    func didSelectMaxBudget(selectedRange : CustomerBudgets)
    func didSelectOutStandingRange(selectedRange : String,index : Int)
}
extension HidePopUp {
    func didSelectOutStandingRange(selectedRange : String,index : Int){
    }
    func didSelectUnitType(selectedUnitType : UnitTypes){
    }
    func didSelectMinBudget(selectedRange : CustomerBudgets){
    }
    func didSelectMaxBudget(selectedRange : CustomerBudgets){
    }
    func didSelectScheme(selectedScheme : Schemes){}
    func didSelectCommision(selectedCommission : CommissionUser){
    }
    func showSelectedTowerForSoldUnitsFloat(selectedTowerName : String,selectedBlock : String){
        
    }
    func didSelectCountryCode(countryCode : String,countryName : String,forFieldIndex: Int){
    }
    func didSelectCurrency(selectedCurrency : CURRENCY,selectedIndex : Int){
        
    }
    func didSelectProject(optionType : String,optionIndex: Int){
    }
    func didFinishTask(optionType : String,optionIndex: Int)
    {
        
    }
    func didSelectOptionForUnitsView(selectedIndex : Int)
    {
    }
    func shouldShowUnitsWithSelectedStatus(selectedStatus : Int)
    {
    }
    func showSelectedTowerFromFloatButton(selectedTower : Towers,selectedBlock : String)
    {
    }
    func didSelectLandOwnerName(ownerName : String,selectedOption : Int){
        // leaving this empty
    }
    func didSelectRow(selectedRowText : String,selectedIndex : Int){
        
    }
    func didSelectProjectBankAccount(bankAccount : BANK_ACCOUNTS,selectedIndex : Int)
    {
    }

}

enum DATA_SOURCE_TYPE {
    case PROJECTS
    case ALL_BLOCKS
    case SUMMARY_OR_UNITS
    case STATUS
    case SHOW_STATUS_WISE
    case HAND_OVER_STATUS_WISE
    case BLOCKS_FLOAT_BUTTON
    case SOURCES
    case URLS
    case BLOCKED_REASONS
    case PAYMENT_TOWARDS
    case ENQUIRY_SOURCES
    case LANDOWNER
    case COMMON
    case BANK_ACCOUNTS
    case CURRENCIES
    case OWNER_IMAGES_POP_UP
    case COUNTRY_CODE
    case SOLD_UNITS_PROJECTS
    case SOLD_UNITS_FLOAT_MENU
    case COMMISIONS
    case SCHEMES
    case UNIT_TYPES
    case BUDGET_RANGES
    case OUTSTANDING_RANGES
}
class PopOverViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var isMinBudget : Bool = false
    var countryCodeFieldIndex : Int!
    lazy var isReceiptEntry : Bool = false
    lazy var oderedSectionTitlesForFloatButton = [String]()
    var selectedIndexForUnitsView : Int!
    @IBOutlet var heightOfTitlesView: NSLayoutConstraint!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var mTableView: UITableView!
    var tableViewDataSource2 : Dictionary<String,Array<Towers>> = [:]
    lazy var handOverFloatButtonMenu : Dictionary<String,Array<String>> = [:]
    lazy var tableViewDataSource : Array<Project> =  []
    weak var delegate:HidePopUp?
    lazy var tableViewDataSourceOne : Array<String> = []
    lazy var landOwnersDataSorce : Array<Dictionary<String,String>> = []
    var dataSourceType : DATA_SOURCE_TYPE!
    lazy var blockReasonsDataSource : [COMMON_FORMAT] = []
    lazy var paymentTowardsDataSource : [PaymentToWards] = []
    lazy var titleString : String = ""
    lazy var subTitleString : String = ""
    lazy var enquiryDataSource : [NewEnquirySources] = [] //[EnquirySources]
    lazy var bankAccountsDataSource : [BANK_ACCOUNTS] = []
    lazy var budgetRanges : [CustomerBudgets] = []
    lazy var unitTypes : [UnitTypes] = []
    lazy var isHandOverStatus : Bool = false
    lazy var handOverProjects : [SoldUnitProjects] = []
    
    lazy var fetchedResultsControllerTowers : NSFetchedResultsController<Towers> = NSFetchedResultsController.init()
    lazy var fetchedResultsControllerUnits : NSFetchedResultsController<Units> = NSFetchedResultsController.init()
    lazy var selectedProjectId : String = ""
    lazy var commonDataSource : [String] = []
    lazy var currenciesDataSource : [CURRENCY] = []
    lazy var countryCodeDataSouce : NSArray = []
    lazy var commissionsDataSource : [CommissionUser] = []
    lazy var schemesDataSource : [Schemes] = []
    lazy var outstandingRanges : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if(dataSourceType == DATA_SOURCE_TYPE.BLOCKS_FLOAT_BUTTON){
            self.fetchAllTowersWithProjectId(projectId: selectedProjectId)
//            self.fetchUnits(projectId: selectedProjectId)
        }
        
//        if(dataSourceType == DATA_SOURCE_TYPE.SOLD_UNITS_FLOAT_MENU){
//            self.buildHOFloatButton()
//        }
        
        mTableView.delegate = self
        mTableView.dataSource = self
        
        
        if((dataSourceType == DATA_SOURCE_TYPE.ENQUIRY_SOURCES) || (dataSourceType == DATA_SOURCE_TYPE.SOURCES) || (dataSourceType == DATA_SOURCE_TYPE.PROJECTS) || dataSourceType == DATA_SOURCE_TYPE.SUMMARY_OR_UNITS || dataSourceType == DATA_SOURCE_TYPE.SHOW_STATUS_WISE || dataSourceType == DATA_SOURCE_TYPE.BLOCKS_FLOAT_BUTTON || dataSourceType == DATA_SOURCE_TYPE.URLS || dataSourceType == DATA_SOURCE_TYPE.BLOCKED_REASONS || dataSourceType == DATA_SOURCE_TYPE.PAYMENT_TOWARDS || dataSourceType == DATA_SOURCE_TYPE.LANDOWNER || dataSourceType == DATA_SOURCE_TYPE.COMMON || dataSourceType == DATA_SOURCE_TYPE.BANK_ACCOUNTS || dataSourceType == DATA_SOURCE_TYPE.OWNER_IMAGES_POP_UP || dataSourceType == DATA_SOURCE_TYPE.COUNTRY_CODE || dataSourceType == DATA_SOURCE_TYPE.SOLD_UNITS_PROJECTS || dataSourceType == DATA_SOURCE_TYPE.SOLD_UNITS_FLOAT_MENU || dataSourceType == DATA_SOURCE_TYPE.CURRENCIES || dataSourceType == DATA_SOURCE_TYPE.COMMISIONS || dataSourceType == DATA_SOURCE_TYPE.SCHEMES || dataSourceType == DATA_SOURCE_TYPE.UNIT_TYPES || dataSourceType == DATA_SOURCE_TYPE.BUDGET_RANGES || dataSourceType == DATA_SOURCE_TYPE.OUTSTANDING_RANGES){
            heightOfTitlesView.constant = 0
        }
        
//        if(dataSourceType == DATA_SOURCE_TYPE.COMMON){
//            titleLabel.text = "Select Option"
//            subTitleLabel.text = ""
//        }
//        if(dataSourceType == DATA_SOURCE_TYPE.BANK_ACCOUNTS){
//            titleLabel.text = "Select Deposite Bank"
//            subTitleLabel.text = ""
//        }
        
        if(dataSourceType == DATA_SOURCE_TYPE.STATUS){
            if(isReceiptEntry){
                heightOfTitlesView.constant = 0
            }
            else{
                if(isHandOverStatus){
                    titleLabel.textAlignment = .left
                    subTitleLabel.textAlignment = .left
                }
                titleLabel.text = "Change Status"
                subTitleLabel.text = String(format: "Selected Unit : %u", selectedIndexForUnitsView)
            }
        }

        let headerNib = UINib.init(nibName: "PopUpHeaderView", bundle: Bundle.main)
        mTableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "PopUpHeaderView")

        mTableView.tableFooterView = UIView()

//        mTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)

    }
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        mTableView.removeObserver(self, forKeyPath: "contentSize")
//    }
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        self.preferredContentSize = mTableView.contentSize
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func fetchAllTowersWithProjectId(projectId : String){
        
        let request: NSFetchRequest<Towers> = Towers.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Towers.name), ascending: true)
        let sort1 = NSSortDescriptor(key: #keyPath(Towers.blockName), ascending: false)
        request.sortDescriptors = [sort1,sort]
        
        let predicate = NSPredicate(format: "project CONTAINS[c] %@ AND unitsCount > %d", projectId,0)
        request.predicate = predicate
        
        fetchedResultsControllerTowers = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: "blockName", cacheName:nil)
        
        do {
            try fetchedResultsControllerTowers.performFetch()
        }
        catch {
            fatalError("Error in fetching records")
        }
        // fetchedResultsControllerUnits
    }
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        if(dataSourceType == DATA_SOURCE_TYPE.BLOCKS_FLOAT_BUTTON){
            
            return tableViewDataSource2.keys.count //(self.fetchedResultsControllerTowers.sections?.count)!
        }
        if(dataSourceType == DATA_SOURCE_TYPE.SOLD_UNITS_FLOAT_MENU)
        {
            return handOverFloatButtonMenu.keys.count
        }

        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(dataSourceType == DATA_SOURCE_TYPE.OUTSTANDING_RANGES){
            return outstandingRanges.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.CURRENCIES){
            return currenciesDataSource.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.UNIT_TYPES){
            return unitTypes.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.BUDGET_RANGES){
            return budgetRanges.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.COUNTRY_CODE){
            return countryCodeDataSouce.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SOLD_UNITS_PROJECTS){
            return handOverProjects.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.COMMON){
            return commonDataSource.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.PROJECTS){
            return tableViewDataSource.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SUMMARY_OR_UNITS)
        {
            return tableViewDataSourceOne.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.STATUS || dataSourceType == DATA_SOURCE_TYPE.URLS)
        {
            return tableViewDataSourceOne.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SHOW_STATUS_WISE || dataSourceType == DATA_SOURCE_TYPE.SOURCES)
        {
            return tableViewDataSourceOne.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.OWNER_IMAGES_POP_UP){
            return tableViewDataSourceOne.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.BLOCKED_REASONS){
            return blockReasonsDataSource.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.PAYMENT_TOWARDS){
            return paymentTowardsDataSource.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.ENQUIRY_SOURCES){
            return enquiryDataSource.count
        }
//        else if(dataSourceType == DATA_SOURCE_TYPE.PAYMENT_TOWARDS){
//            return landOwnersDataSorce.count
//        }
        else if(dataSourceType == DATA_SOURCE_TYPE.BANK_ACCOUNTS){
            return bankAccountsDataSource.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SOLD_UNITS_FLOAT_MENU){
            let key = oderedSectionTitlesForFloatButton[section]
            let towers = handOverFloatButtonMenu[key]
            return towers!.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.BLOCKS_FLOAT_BUTTON){
            
            let key = oderedSectionTitlesForFloatButton[section]
            let towers = tableViewDataSource2[key]
            
            return (towers?.count)!
            
//            let sectionInfo = fetchedResultsControllerTowers.sections![section]
//            return sectionInfo.numberOfObjects
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.COMMISIONS){
            return commissionsDataSource.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SCHEMES){
            return schemesDataSource.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.LANDOWNER){
            return landOwnersDataSorce.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "popUpCell", for:indexPath) as! PopOverTableViewCell
        
        // Configure the cell...
        if(dataSourceType == DATA_SOURCE_TYPE.OUTSTANDING_RANGES){
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
            cell.mTitleLabel.text = outstandingRanges[indexPath.row]
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.CURRENCIES)
        {
            let currency =  currenciesDataSource[indexPath.row]
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
            cell.mTitleLabel.text = String(format: "%@ - %@ - %@", currency.currencyName!,currency.id!, currency.currencySymbol ?? "")
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.UNIT_TYPES){
            let unitType = unitTypes[indexPath.row]
            
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
            cell.mTitleLabel.text = unitType.name
            
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.BUDGET_RANGES){
            let budgetRange = budgetRanges[indexPath.row]
            
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
            cell.mTitleLabel.text = String(format: "%d", budgetRange.value)
            
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.COUNTRY_CODE){
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
            
            let tempDict : NSDictionary = self.countryCodeDataSouce[indexPath.row] as! NSDictionary
            cell.mTitleLabel.text = String(format: "%@ (%@)", tempDict["name"] as! String,tempDict["dial_code"] as! String)  //tempDict["name"] + tempDict["dial_code"]
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SOLD_UNITS_PROJECTS){
            
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
            
            let project = handOverProjects[indexPath.row]
            
            cell.mTitleLabel.text = project.projectName
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.BANK_ACCOUNTS){
            let projectBank = bankAccountsDataSource[indexPath.row]
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
            let bankDetails = String(format: "%d - %@ \n (%@)", projectBank.accountNumber! , projectBank.bankName!,projectBank.bankBranch!)
            cell.mTitleLabel.text = bankDetails
            //projectBank.accountNumber! + "-" + projectBank.bankName! + "\n"  + projectBank.bankBranch!
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.COMMON){
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
            cell.mTitleLabel.text = commonDataSource[indexPath.row]
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.COMMISIONS){
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
            let commission = commissionsDataSource[indexPath.row]
            cell.mTitleLabel.text = String(format: "%@ (%@)", commission.name ?? "",commission.phone ?? "")
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SCHEMES){
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
            let scheme = schemesDataSource[indexPath.row]
            cell.mTitleLabel.text = scheme.name
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.ENQUIRY_SOURCES){
            let enqSource = enquiryDataSource[indexPath.row]
            cell.mTitleLabel.text = enqSource.displayName
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.PROJECTS){
            let project = tableViewDataSource[indexPath.row]
            cell.mTitleLabel.text = String(format: "%@ - %@", project.name! , project.city ?? "")
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.BLOCKED_REASONS){
            let blockedReason = blockReasonsDataSource[indexPath.row]
            cell.mTitleLabel.text = blockedReason.name
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.PAYMENT_TOWARDS){
            
            let paymentTowards = self.paymentTowardsDataSource[indexPath.row]

            if(isReceiptEntry){
                
                var titleTextStr = paymentTowards.name
                
                if(paymentTowards.count != nil && paymentTowards.count! > 0){
                    let counter = String(format: " (%d)", paymentTowards.count!)
                    titleTextStr?.append(counter)
                }
                if(paymentTowards.amount != nil && paymentTowards.amount! > 0.0){
                    let amountStr = String(format: " - %.2f", paymentTowards.amount!)
                    titleTextStr?.append(amountStr)
                }
                cell.mTitleLabel.text = titleTextStr
            }
            else{
                cell.mTitleLabel.text = paymentTowards.name
            }
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8

        }
//        else if(dataSourceType == DATA_SOURCE_TYPE.PAYMENT_TOWARDS){
//            let ownerDict = landOwnersDataSorce[indexPath.row]
//            cell.mTitleLabel.text = ownerDict["name"]
//            cell.widthOfImageHolderView.constant = 0
//            cell.roundedView.isHidden = true
//            cell.leadingOfTitleLabel.constant = 8
//        }
        else if(dataSourceType == DATA_SOURCE_TYPE.LANDOWNER){
            let ownerDict = landOwnersDataSorce[indexPath.row]
            cell.mTitleLabel.text = ownerDict["name"]
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SUMMARY_OR_UNITS){
            let project = tableViewDataSourceOne[indexPath.row]
            cell.mTitleLabel.text = String(format: "%@", project)
            cell.mImageView.isHidden = true
            
//            cell.widthOfImageView.constant = 40
            if(selectedIndexForUnitsView  == indexPath.row){
                cell.roundedView.backgroundColor = UIColor.green
            }
            else{
                cell.roundedView.backgroundColor = UIColor.clear
            }
//            cell.mImageView.layer.cornerRadius = cell.mImageView.frame.size.width/2
//            cell.mImageView.clipsToBounds = true
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.OWNER_IMAGES_POP_UP){
           
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
            
            let title = tableViewDataSourceOne[indexPath.row]
            cell.mTitleLabel.text = String(format: "%@", title)
            cell.mImageView.isHidden = true

        }
        else if(dataSourceType == DATA_SOURCE_TYPE.URLS){
            
            let project = tableViewDataSourceOne[indexPath.row]
            cell.mTitleLabel.text = String(format: "%@", project)
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 0
//            let colorsDict = RRUtilities.sharedInstance.getColorAccordingToUnitStatus(status: indexPath.row)
//            cell.roundedView.backgroundColor = colorsDict["color"] as? UIColor
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.STATUS){
            
            let project = tableViewDataSourceOne[indexPath.row]
            cell.mTitleLabel.text = String(format: "%@", project)
            cell.roundedView.isHidden = false
            cell.leadingOfTitleLabel.constant = 6
            if(self.isReceiptEntry){
                cell.widthOfImageHolderView.constant = 0
                cell.roundedView.isHidden = true
                cell.leadingOfTitleLabel.constant = 8
            }
//            let colorsDict = RRUtilities.sharedInstance.getColorAccordingToUnitStatus(status: indexPath.row)
            
            if(isHandOverStatus){
                cell.leadingOfSubView.constant = 12
                cell.leadingOfTitleLabel.constant = 8
//                cell.mTitleLabel.textAlignment = .center
                cell.widthOfImageView.constant = 24
                let colorsDict = RRUtilities.sharedInstance.getHOStatusColorAsPerStatusString(statusString: project)
                cell.roundedView.backgroundColor = colorsDict["color"] as? UIColor
            }
            else{
                let colorsDict = RRUtilities.sharedInstance.getColorAccordingToStatusString(statusString: project)
                cell.roundedView.backgroundColor = colorsDict["color"] as? UIColor
            }
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SHOW_STATUS_WISE){
            let title = tableViewDataSourceOne[indexPath.row]
            cell.mTitleLabel.text = String(format: "%@", title)
            cell.roundedView.isHidden = false
            cell.leadingOfTitleLabel.constant = 6
            if(indexPath.row != 0){
                if(isHandOverStatus){
                    let colorsDict =  RRUtilities.sharedInstance.getHOStatusColorAsPerStatusString(statusString: title)
                    cell.roundedView.backgroundColor = colorsDict["color"] as? UIColor
                }else{
                    let colorsDict =  RRUtilities.sharedInstance.getColorAccordingToUnitStatus(status: indexPath.row-1)
                    cell.roundedView.backgroundColor = colorsDict["color"] as? UIColor
                }
            }
            else{
                cell.roundedView.backgroundColor = UIColor.clear
            }
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SOLD_UNITS_FLOAT_MENU){
            
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 10
            
            let key = oderedSectionTitlesForFloatButton[indexPath.section]
            let towersArray = handOverFloatButtonMenu[key]
            
            let tempTower = towersArray![indexPath.row]
            
            cell.mTitleLabel.text = tempTower
            cell.mTitleLabel.textAlignment = .center

        }
        else if(dataSourceType == DATA_SOURCE_TYPE.BLOCKS_FLOAT_BUTTON){ // *******
            
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 10

            let key = oderedSectionTitlesForFloatButton[indexPath.section]
            let towersArray = tableViewDataSource2[key]!

            let tempTower = towersArray[indexPath.row]
            
//            let tempBlock : Towers = fetchedResultsControllerTowers.object(at: indexPath)
//            print(tempBlock.name)
            cell.mTitleLabel.text = tempTower.name
            cell.mTitleLabel.textAlignment = .center
            
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SOURCES){
            
            let project = tableViewDataSourceOne[indexPath.row]
            cell.mTitleLabel.text = String(format: "%@", project)

            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
        }
//        cell.optionLabel.text = tableViewDataSource[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(dataSourceType == DATA_SOURCE_TYPE.OUTSTANDING_RANGES){
            self.delegate?.didSelectOutStandingRange(selectedRange: outstandingRanges[indexPath.row], index: indexPath.row)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.CURRENCIES)
        {
            let currency = currenciesDataSource[indexPath.row]
            self.delegate?.didSelectCurrency(selectedCurrency: currency, selectedIndex: indexPath.row)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.UNIT_TYPES){
            let selectedUnitType = unitTypes[indexPath.row]
            self.delegate?.didSelectUnitType(selectedUnitType: selectedUnitType)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.BUDGET_RANGES){
            let selectedBudget = budgetRanges[indexPath.row]
            if(isMinBudget){
                self.delegate?.didSelectMinBudget(selectedRange: selectedBudget)
            }
            else{
                self.delegate?.didSelectMaxBudget(selectedRange: selectedBudget)
            }
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.COMMISIONS){
            self.delegate?.didSelectCommision(selectedCommission: commissionsDataSource[indexPath.row])
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SCHEMES){
            self.delegate?.didSelectScheme(selectedScheme: schemesDataSource[indexPath.row])
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.COUNTRY_CODE){
            
            let tempDict : NSDictionary = self.countryCodeDataSouce[indexPath.row] as! NSDictionary
            print(tempDict)
            self.delegate?.didSelectCountryCode(countryCode: tempDict["dial_code"] as! String, countryName: tempDict["name"] as! String, forFieldIndex: countryCodeFieldIndex ?? -1)
        }
        else if((dataSourceType == DATA_SOURCE_TYPE.SOLD_UNITS_PROJECTS)){
            
            let project = handOverProjects[indexPath.row]
            self.delegate?.didSelectProject(optionType: project.projectID!, optionIndex: indexPath.row)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.BANK_ACCOUNTS){
            let projectBank = bankAccountsDataSource[indexPath.row]
            self.delegate?.didSelectProjectBankAccount(bankAccount: projectBank, selectedIndex: indexPath.row)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.COMMON){
            self.delegate?.didSelectRow(selectedRowText: commonDataSource[indexPath.row], selectedIndex: indexPath.row)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.PROJECTS){
            let selectedProject = tableViewDataSource[indexPath.row]
            self.delegate?.didSelectProject(optionType:selectedProject.id!  ,optionIndex: indexPath.row)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.BLOCKED_REASONS){
            let selectedProject = blockReasonsDataSource[indexPath.row]
            self.delegate?.didSelectProject(optionType:selectedProject.name!  ,optionIndex: indexPath.row)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.PAYMENT_TOWARDS){
            let selectedPaymetToWards = self.paymentTowardsDataSource[indexPath.row]
            self.delegate?.didSelectProject(optionType:selectedPaymetToWards.name!  ,optionIndex: indexPath.row)
        }
//        else if(dataSourceType == DATA_SOURCE_TYPE.PAYMENT_TOWARDS){
//            let ownerDict = landOwnersDataSorce[indexPath.row]
//            self.delegate?.didFinishTask(optionType: ownerDict["name"]!, optionIndex: indexPath.row)
//        }
        else if(dataSourceType == DATA_SOURCE_TYPE.OWNER_IMAGES_POP_UP){
            let title = tableViewDataSourceOne[indexPath.row]
            self.delegate?.didFinishTask(optionType: title, optionIndex: indexPath.row)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SUMMARY_OR_UNITS){
//            let selectedString = tableViewDataSourceOne[indexPath.row]
//            self.delegate?.didFinishTask(optionType:selectedString  ,optionIndex: indexPath.row)
            self.delegate?.didSelectOptionForUnitsView(selectedIndex: indexPath.row)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.LANDOWNER){
            let ownerDict = landOwnersDataSorce[indexPath.row]
            self.delegate?.didSelectLandOwnerName(ownerName: ownerDict["name"]!, selectedOption: indexPath.row)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.STATUS || dataSourceType == DATA_SOURCE_TYPE.URLS){
            let selectedString = tableViewDataSourceOne[indexPath.row]
            self.delegate?.didFinishTask(optionType:selectedString  ,optionIndex: indexPath.row)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SHOW_STATUS_WISE){
            if(indexPath.row == 0){
                self.delegate?.shouldShowUnitsWithSelectedStatus(selectedStatus: -1)
            }
            else{
                self.delegate?.shouldShowUnitsWithSelectedStatus(selectedStatus: indexPath.row-1)
            }
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SOLD_UNITS_FLOAT_MENU){
            
            let key = oderedSectionTitlesForFloatButton[indexPath.section]
            let towersArray = handOverFloatButtonMenu[key]!
            
            let tower = towersArray[indexPath.row]

            self.delegate?.showSelectedTowerForSoldUnitsFloat(selectedTowerName: tower, selectedBlock: key)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.BLOCKS_FLOAT_BUTTON){
            
            let key = oderedSectionTitlesForFloatButton[indexPath.section]
            let towersArray = tableViewDataSource2[key]!
            
            let tower = towersArray[indexPath.row]
            
//            let tempBlock : Towers =  self.fetchedResultsControllerTowers.object(at: indexPath)//towersArray[indexPath.row]
            
            self.delegate?.showSelectedTowerFromFloatButton(selectedTower: tower, selectedBlock: tower.blockName!)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.ENQUIRY_SOURCES){
            self.delegate?.didFinishTask(optionType: enquiryDataSource[indexPath.row].displayName!, optionIndex: indexPath.row)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SOURCES){
            self.delegate?.didFinishTask(optionType: tableViewDataSourceOne[indexPath.row], optionIndex: indexPath.row)
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if(dataSourceType == DATA_SOURCE_TYPE.BLOCKS_FLOAT_BUTTON){
            
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PopUpHeaderView") as! PopUpHeaderView
            
            let key = oderedSectionTitlesForFloatButton[section]
//            let sectionInfo = fetchedResultsControllerTowers.sections![section]
            
            headerView.headerTitleLabel.text = key // fetchedResultsControllerTowers.sectionIndexTitles[section]
            
            return headerView
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SOLD_UNITS_FLOAT_MENU){
            
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PopUpHeaderView") as! PopUpHeaderView

            let key = oderedSectionTitlesForFloatButton[section]

            headerView.headerTitleLabel.text = key
            
            return headerView
            
        }
        else{
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(self.isHandOverStatus){
            return 55
        }
        else{
            return 44
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if(dataSourceType == DATA_SOURCE_TYPE.BLOCKS_FLOAT_BUTTON || dataSourceType == DATA_SOURCE_TYPE.SOLD_UNITS_FLOAT_MENU){
            
            return 44
        }
        else{
            return 0
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

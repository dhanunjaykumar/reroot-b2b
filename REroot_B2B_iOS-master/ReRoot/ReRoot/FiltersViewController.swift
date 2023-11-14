//
//  FiltersViewController.swift
//  REroot
//
//  Created by Dhanunjay on 22/04/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import PKHUD
import CoreData

protocol FilterDelegate : class {
    func didFinishFilterSelection(selectedProjecsArray : [String],selectedSalesPersonsArray : [String],selectedStatsuArray : [String],selectedOverDueDataArray : [String],selectedFloorPremiums : [String],selectedOtherPremiums : [String],selectedMiscArray : [String],shouldDismis : Bool,selectedEnquirySources : [String],selectedNotInterestedReasons : [String])
    func didFinishUnitFilterSelection(selectedTypeNamesArray : [String],selectedFacingNamesArray : [String],selectedBuiltUpAreasArray : [String],selectedCarpetAreasArray : [String],selectedBedRoomsArray : [String],selectedBathRoomsArray: [String],selectedFloorPremiums : [String],selectedOtherPremiums : [String],selectedMiscArray : [String], shouldDismiss : Bool,tableViewSectionsSelectedCountDict : Dictionary<Int,Int>)
}
extension FilterDelegate{
    func didFinishFilterSelection(selectedProjecsArray : [String],selectedSalesPersonsArray : [String],selectedStatsuArray : [String],selectedOverDueDataArray : [String],selectedFloorPremiums : [String],selectedOtherPremiums : [String],selectedMiscArray : [String],shouldDismis : Bool,selectedEnquirySources : [String],selectedNotInterestedReasons : [String]){
        print("")
    }
    func didFinishUnitFilterSelection(selectedTypeNamesArray : [String],selectedFacingNamesArray : [String],selectedBuiltUpAreasArray : [String],selectedCarpetAreasArray : [String],selectedBedRoomsArray : [String],selectedBathRoomsArray: [String],selectedFloorPremiums : [String],selectedOtherPremiums : [String],selectedMiscArray : [String], shouldDismiss : Bool,tableViewSectionsSelectedCountDict : Dictionary<Int,Int>)
    {
        
    }
}

class FiltersViewController: UIViewController,UIScrollViewDelegate {

    var tableViewSectionsExpandDict : Dictionary<Int,Bool> = [:] // section and its selected value
    var tableViewSectionsSelectedCountDict : Dictionary<Int,Int> = [:] //  section and its seletd count values
    @IBOutlet weak var heightOfSearchBar: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var heightOfTableView: NSLayoutConstraint!
    @IBOutlet weak var saveOptionsButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate:FilterDelegate?

    var tableViewDataSource : Dictionary<String,Array<String>> = [:]
    
    var projectsArray : [String] = []
    var salesPersonsArray : [String] = []
    var notInterestedReasons : [String] = []
    var enquirySources : [String] = []
    var currentStatusArray : [String] = []
    var orderedSectionsArray : [String] = []
    
    var selectedProjectsArray : [String] = []
    var selectedSalesPersonsArray : [String] = []
    var selectedStatsuArray : [String] = []
    var selectedOverDueDataArray : [String] = []
    
    var isLeadsAvailable : Bool = false
    var isOpportunitiesAvailable : Bool = false
    
    // *** FOR UNIT FILTER
    var isFromUnitsView : Bool = false
    var selectedCarpetAreaArray : [String] = []
    var selectedTypeNamesArray : [String] = []
    var selectedFacingNamesArray : [String] = []
    var selectedBuiltUpAreasArray : [String] = []
    var selectedBedRoomsArray : [String] = []
    var selectedBathRoomsArray : [String] = []
    var selectedFloorWisePremiumsArray : [String] = []
    var selectedOtherPremiumsArray : [String] = []
    var selectedMiscArray : [String] = [] // Non premium
    var selectedEnquirySourcesArray : [String] = []
    var selectedNotInterestedReasonsArray : [String] = []

    
    var unitTypesArray : [String] = []
    var facingTypesArray : [String] = []
    var builtUpsArray : [String] = []
    var carpetAreasArray : [String] = []
    var bedRoomsArray : [String] = []
    var bathRoomsArray : [String] = []
    var floorWisePremiumsArray : [String] = []
    var otherPremiumsArray : [String] = []
    var miscArray : [String] = [] // Non premium
    var selectedProjectId : String = ""
    
    
    //Unit type, Unit Facing , Super Built UP Area, Carpet Area
    
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureView()
    }
    func configureView(){
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.black

        resetButton.layer.cornerRadius = 8
        resetButton.layer.borderWidth = 1.0
        resetButton.layer.borderColor = UIColor.lightGray.cgColor
        
        saveOptionsButton.backgroundColor = UIColor.hexStringToUIColor(hex: "0a55a1")
        
        let nib = UINib(nibName: "FilterTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "filterCell")
        
        let headerNib = UINib.init(nibName: "FiltersSectionHeaderView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "FiltersSectionHeaderView")

        tableViewSectionsExpandDict[0] = true
        
//        let headerNib1 = UINib.init(nibName: "PopUpHeaderView", bundle: Bundle.main)
//        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "PopUpHeaderView")
        
        tableView.tableFooterView = UIView()

        if(isFromUnitsView)
        {
            searchBar.delegate = self
            heightOfSearchBar.constant = 50
            orderedSectionsArray = ["Unit Facing","Super Built-Up Area","Carpet Area","Unit Type","No.Of Bedrooms","No.Of Bathrooms","Floor Premium","Other Premium","Misc."]
            
            self.getUnitFilters()
        }
        else{
            heightOfSearchBar.constant = 0

            if(self.isLeadsAvailable){
                currentStatusArray = ["Leads"]
            }
            if(self.isOpportunitiesAvailable){
                currentStatusArray.append("Opportunities")
            }

            if(currentStatusArray.count > 0){
                orderedSectionsArray = ["Overdue Prospects","Projects","Current Status","Sales Person","Enquiry Source","Not ineterested Reasons"]
            }
            else{
                orderedSectionsArray = ["Overdue Prospects","Projects","Sales Person","Enquiry Source","Not ineterested Reasons"]
            }
            
            tableViewDataSource["Overdue Prospects"] = ["Outdated Only"]
            tableViewDataSource["Projects"] = projectsArray
            if(currentStatusArray.count > 0){
                tableViewDataSource["Current Status"] = currentStatusArray
            }
            if(self.enquirySources.count > 0){
                tableViewDataSource["Enquiry Source"] = self.enquirySources.filter( {$0 != ""} )
            }
            if(self.notInterestedReasons.count > 0){
                self.notInterestedReasons.insert("General", at: 0)
                tableViewDataSource["Not ineterested Reasons"] = self.notInterestedReasons
            }

            tableViewDataSource["Sales Person"] = salesPersonsArray

        }
//        print(orderedSectionsArray)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        heightOfTableView.constant = self.tableView.contentSize.height
    }
    func getUnitFilters(){
        
        
        self.unitTypesArray.removeAll()
        self.facingTypesArray.removeAll()
        self.builtUpsArray.removeAll()
        self.carpetAreasArray.removeAll()
        
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Units")
        fetchRequest.resultType = .dictionaryResultType
        
        let predicate = NSPredicate(format: "project CONTAINS[c] %@", self.selectedProjectId) //AND description1 CONTAINS[c] %@
        
        fetchRequest.propertiesToFetch = ["typeName"]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.predicate = predicate
        let typeNames = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)
        var typeNamesArray : [String] = []
        for eachDict in typeNames{
            if let typeName = eachDict["typeName"]{
                typeNamesArray.append(typeName as! String)
            }
        }
        
//        fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Units")
//        fetchRequest.resultType = .dictionaryResultType
//        fetchRequest.predicate = predicate

        fetchRequest.propertiesToFetch = ["facing"]
        fetchRequest.returnsDistinctResults = true
        let facingTypes = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)
        var facingTypesArray : [String] = []
        for eachDict in facingTypes{
            if let facingName = eachDict["facing"]{
                facingTypesArray.append(facingName as! String)
            }
        }

        fetchRequest.propertiesToFetch = ["superBuiltUpArea","superBuiltUpAreaUOM"]
        fetchRequest.returnsDistinctResults = true
        let superBuiltUpAreas = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)
        var builtUpAreas : [String] = []
        for eachDict in superBuiltUpAreas{
            if let tempDecimal = eachDict["superBuiltUpArea"]{
                if let tempUOM = eachDict["superBuiltUpAreaUOM"]{
                    builtUpAreas.append(String(format: "%@ %@", (tempDecimal as! Decimal).description,tempUOM as!
                String))
                }
            }
        }

        fetchRequest.propertiesToFetch = ["carpetArea","capetAreaUOM"]
        fetchRequest.returnsDistinctResults = true
        let carpetAreas = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)
        var carpetAreasArray : [String] = []
        for eachDict in carpetAreas{
            if let tempCarpetArea = eachDict["carpetArea"]{
                if let carpetUOM = eachDict["capetAreaUOM"]{
                    carpetAreasArray.append(String(format: "%@ %@", (tempCarpetArea as! Decimal).description,carpetUOM as! String))
                }
            }
        }
        fetchRequest.propertiesToFetch = ["bedRooms"]
        fetchRequest.returnsDistinctResults = true
        let bedRooms = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)
        for eachBedRoom in bedRooms{
            let bedRoomsCount = eachBedRoom["bedRooms"] as! NSDecimalNumber
            if(bedRoomsCount.doubleValue > 0.0){
                self.bedRoomsArray.append(String(format: "%@", bedRoomsCount.description))
            }
        }
        self.bedRoomsArray = self.bedRoomsArray.sorted()
        
        fetchRequest.propertiesToFetch = ["bathRooms"]
        fetchRequest.returnsDistinctResults = true
        let bathRooms = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)
        for eachBathRoom in bathRooms{
            let bathRoomsCount = eachBathRoom["bathRooms"] as! NSDecimalNumber
            if(bathRoomsCount.doubleValue > 0.0){
                self.bathRoomsArray.append(String(format: "%@", bathRoomsCount.description))
            }
        }

        var floorWisePremiumsArray : [String] = []
        fetchRequest.propertiesToFetch = ["floorPremium"]
        fetchRequest.returnsDistinctResults = true
        let floorPremiums = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)
        for eachFloor in floorPremiums{
            if let floorPremium = eachFloor["floorPremium"] as? String{
                floorWisePremiumsArray.append(floorPremium)
            }
        }
        
        var otherPremiumsArray : [String] = []
        fetchRequest.propertiesToFetch = ["otherPremiums"]
        fetchRequest.returnsDistinctResults = true
        let otherPremiums = try! RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequest)
        for eachPremium in otherPremiums{
            if let otherPremiums = eachPremium["otherPremiums"] as? [String]{
                otherPremiumsArray.append(contentsOf: otherPremiums)
            }
        }
        
        
//        let fetchRequestOne = NSFetchRequest<NSDictionary>(entityName: "Units")

//        let predicate = NSPredicate(format: "(floorPremium == nil OR floorPremium.length == 0)") //OR otherPremiums == nil
//        let predicate1 = NSPredicate(format: "(otherPremiums == nil OR otherPremiums.length == 0)")
//        //(otherPremiums == nil OR otherPremiums.length == 0)
//        fetchRequestOne.resultType = .dictionaryResultType
//        fetchRequestOne.returnsDistinctResults = false
//        fetchRequestOne.propertiesToFetch?.removeAll()
//        let compounPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate,predicate1])
//        fetchRequestOne.predicate = compounPredicate
//        do{
//            let nonPremiums = try RRUtilities.sharedInstance.model.managedObjectContext.fetch(fetchRequestOne)
//            print(nonPremiums.count)
//        }
//        catch {
//            print(error)
//        }

//        let compounPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: allPredicates)
//
//        request.predicate = compounPredicate

        
        
        self.bathRoomsArray = self.bathRoomsArray.sorted()
        
        if(self.bedRoomsArray.count  > 0){
            tableViewDataSource["No.Of Bedrooms"] = self.bedRoomsArray
        }
        else{
            orderedSectionsArray.remove(at: orderedSectionsArray.firstIndex(of: "No.Of Bedrooms")!)
        }

        if(self.bathRoomsArray.count  > 0){
            tableViewDataSource["No.Of Bathrooms"] = self.bathRoomsArray
        }
        else{
            orderedSectionsArray.remove(at: orderedSectionsArray.firstIndex(of: "No.Of Bathrooms")!)
        }

        if(typeNamesArray.count > 0){
            tableViewDataSource["Unit Type"] = typeNamesArray
            unitTypesArray = typeNamesArray
        }
        else{
            orderedSectionsArray.remove(at: orderedSectionsArray.firstIndex(of: "Unit Type")!)
        }

        if(facingTypesArray.count > 0){
            tableViewDataSource["Unit Facing"] = facingTypesArray
            self.facingTypesArray = facingTypesArray
        }
        else{
            orderedSectionsArray.remove(at: orderedSectionsArray.firstIndex(of: "Unit Facing")!)
        }
        
        if(builtUpAreas.count > 0){
            tableViewDataSource["Super Built-Up Area"] = builtUpAreas
            self.builtUpsArray = builtUpAreas
        }
        else{
            orderedSectionsArray.remove(at: orderedSectionsArray.firstIndex(of: "Super Built-Up Area")!)
        }

        if(carpetAreasArray.count > 0){
            tableViewDataSource["Carpet Area"] = carpetAreasArray
            self.carpetAreasArray = carpetAreasArray
        }
        else{
            orderedSectionsArray.remove(at: orderedSectionsArray.firstIndex(of: "Carpet Area")!)
        }

        if(floorWisePremiumsArray.count > 0){
            self.floorWisePremiumsArray = floorWisePremiumsArray
            tableViewDataSource["Floor Premium"] = self.floorWisePremiumsArray
        }
        else{
            orderedSectionsArray.remove(at: orderedSectionsArray.firstIndex(of: "Floor Premium")!)
        }
        
        if(otherPremiumsArray.count > 0){
            self.otherPremiumsArray = otherPremiumsArray
            tableViewDataSource["Other Premium"] = self.otherPremiumsArray
        }
        else{
            orderedSectionsArray.remove(at: orderedSectionsArray.firstIndex(of: "Other Premium")!)
        }
        self.miscArray.append("Non Premium")
        tableViewDataSource["Misc."] = self.miscArray

    }

    // MARK: - ACTIONS
    @IBAction func applyFilter(_ sender: Any) {
        // pass the options through delegate
        if(isFromUnitsView){
            self.delegate?.didFinishUnitFilterSelection(selectedTypeNamesArray: self.selectedTypeNamesArray, selectedFacingNamesArray: self.selectedFacingNamesArray, selectedBuiltUpAreasArray: self.selectedBuiltUpAreasArray, selectedCarpetAreasArray: self.selectedCarpetAreaArray, selectedBedRoomsArray: self.selectedBedRoomsArray, selectedBathRoomsArray: self.selectedBathRoomsArray, selectedFloorPremiums: self.selectedFloorWisePremiumsArray, selectedOtherPremiums: self.selectedOtherPremiumsArray, selectedMiscArray: self.selectedMiscArray,shouldDismiss:true, tableViewSectionsSelectedCountDict: self.tableViewSectionsSelectedCountDict)
        }
        else{
            self.delegate?.didFinishFilterSelection(selectedProjecsArray: self.selectedProjectsArray, selectedSalesPersonsArray: self.selectedSalesPersonsArray, selectedStatsuArray: self.selectedStatsuArray, selectedOverDueDataArray: self.selectedOverDueDataArray, selectedFloorPremiums: self.selectedFloorWisePremiumsArray, selectedOtherPremiums: self.selectedOtherPremiumsArray, selectedMiscArray: self.selectedMiscArray,shouldDismis: true, selectedEnquirySources: self.selectedEnquirySourcesArray, selectedNotInterestedReasons: self.selectedNotInterestedReasonsArray)
        }
    }
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func resetFilters(_ sender: Any) {
        
        self.selectedOverDueDataArray.removeAll()
        self.selectedStatsuArray.removeAll()
        self.selectedSalesPersonsArray.removeAll()
        self.selectedProjectsArray.removeAll()
        self.selectedTypeNamesArray.removeAll()
        self.selectedFacingNamesArray.removeAll()
        self.selectedBuiltUpAreasArray.removeAll()
        self.selectedCarpetAreaArray.removeAll()
        self.tableView.reloadData()
        HUD.flash(.label("Filter is reset"), delay: 1.5)
        
        self.delegate?.didFinishUnitFilterSelection(selectedTypeNamesArray: self.selectedTypeNamesArray, selectedFacingNamesArray: self.selectedFacingNamesArray, selectedBuiltUpAreasArray: self.selectedBuiltUpAreasArray, selectedCarpetAreasArray: self.selectedCarpetAreaArray, selectedBedRoomsArray: self.selectedBedRoomsArray, selectedBathRoomsArray: self.selectedBathRoomsArray, selectedFloorPremiums: self.selectedFloorWisePremiumsArray, selectedOtherPremiums: self.selectedOtherPremiumsArray, selectedMiscArray: self.selectedMiscArray,shouldDismiss:false, tableViewSectionsSelectedCountDict: self.tableViewSectionsSelectedCountDict)

        self.delegate?.didFinishFilterSelection(selectedProjecsArray: self.selectedProjectsArray, selectedSalesPersonsArray: self.selectedSalesPersonsArray, selectedStatsuArray: self.selectedStatsuArray, selectedOverDueDataArray: self.selectedOverDueDataArray, selectedFloorPremiums: self.selectedFloorWisePremiumsArray, selectedOtherPremiums: self.selectedOtherPremiumsArray, selectedMiscArray: self.selectedMiscArray,shouldDismis: false, selectedEnquirySources: self.selectedEnquirySourcesArray, selectedNotInterestedReasons: self.selectedNotInterestedReasonsArray)
        
//        self.delegate?.didFinishFilterSelection(selectedProjecsArray: self.selectedProjectsArray, selectedSalesPersonsArray: self.selectedSalesPersonsArray, selectedStatsuArray: self.selectedStatsuArray, selectedOverDueDataArray: self.selectedOverDueDataArray, selectedFloorPremiums: self.selectedFloorWisePremiumsArray, selectedOtherPremiums: self.selectedOtherPremiumsArray, selectedMiscArray: self.selectedMiscArray,shouldDismis: false, selectedEnquirySources: self.selectedEnquirySourcesArray, selectedNotInterestedReasons: self.selectedNotInterestedReasonsArray)

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

extension FiltersViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return tableViewDataSource.keys.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let keysArray : [String] = Array(tableViewDataSource.keys)
        let sectionName = orderedSectionsArray[section]
        let sectionDataSource = tableViewDataSource[sectionName]

        if let shouldExpand = tableViewSectionsExpandDict[section]{
            if(shouldExpand){
                return sectionDataSource?.count ?? 0
            }
            else{
                return 0
            }
        }
        else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : FilterTableViewCell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath) as! FilterTableViewCell
        
        let sectionName = orderedSectionsArray[indexPath.section]
        
        if(isFromUnitsView){
            if(sectionName == "Floor Premium"){
                
                let tempFloorsArray = tableViewDataSource["Floor Premium"]
                let floorPremiums = tempFloorsArray![indexPath.row]
                cell.filterNameLabel.text = floorPremiums
                if(self.selectedFloorWisePremiumsArray.contains(floorPremiums)){
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
                }
                else{
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedFloorWisePremiumsArray.count
            }
            else if(sectionName == "Other Premium"){
                let tempFloorsArray = tableViewDataSource["Other Premium"]
                let otherPremiums = tempFloorsArray![indexPath.row]
                cell.filterNameLabel.text = otherPremiums
                if(self.selectedOtherPremiumsArray.contains(otherPremiums)){
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
                }
                else{
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedOtherPremiumsArray.count
            }
            else if(sectionName == "Misc."){
                
                let tempFloorsArray = tableViewDataSource["Misc."]
                let otherPremiums = tempFloorsArray![indexPath.row]
                cell.filterNameLabel.text = otherPremiums
                if(self.selectedMiscArray.contains(otherPremiums)){
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
                }
                else{
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedMiscArray.count
            }
            else if(sectionName == "No.Of Bedrooms"){
                
                let tempBathroomsArray = tableViewDataSource["No.Of Bedrooms"]
                let noOfBedRooms = tempBathroomsArray![indexPath.row]
                cell.filterNameLabel.text = noOfBedRooms
                
                if(selectedBedRoomsArray.contains(noOfBedRooms)){
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
                }
                else{
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedBedRoomsArray.count
            }
            else if(sectionName == "No.Of Bathrooms"){
                
                let tempBathroomsArray = tableViewDataSource["No.Of Bathrooms"]
                let noOfBedRooms = tempBathroomsArray![indexPath.row]
                cell.filterNameLabel.text = noOfBedRooms
                
                if(selectedBathRoomsArray.contains(noOfBedRooms)){
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
                }
                else{
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedBathRoomsArray.count
            }
            else if(sectionName == "Unit Type"){
                
                let typeNamesArray = tableViewDataSource["Unit Type"]
                let typeName = typeNamesArray![indexPath.row]
                
                cell.filterNameLabel.text = typeName
                
                if(selectedTypeNamesArray.contains(typeName)){
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
                }
                else{
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedTypeNamesArray.count
            }
            else if(sectionName == "Unit Facing"){
                
                let typeNamesArray = tableViewDataSource["Unit Facing"]
                let typeName = typeNamesArray![indexPath.row]
                
                cell.filterNameLabel.text = typeName
                
                if(selectedFacingNamesArray.contains(typeName)){
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
                }
                else{
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedFacingNamesArray.count
//                ["Unit Type","Unit Facing","Super Built-Up Area","Carpet Area"]
            }
            else if(sectionName == "Super Built-Up Area"){
                
                let typeNamesArray = tableViewDataSource["Super Built-Up Area"]
                let typeName = typeNamesArray![indexPath.row]
                
                cell.filterNameLabel.text = typeName
                
                if(selectedBuiltUpAreasArray.contains(typeName)){
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
                }
                else{
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedBuiltUpAreasArray.count
            }
            else if(sectionName == "Carpet Area"){
                
                let typeNamesArray = tableViewDataSource["Carpet Area"]
                let typeName = typeNamesArray![indexPath.row]
                
                cell.filterNameLabel.text = typeName
                
                if(selectedCarpetAreaArray.contains(typeName)){
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
                }
                else{
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedCarpetAreaArray.count
            }
        }
        else{
            
            if(sectionName == "Overdue Prospects"){
                if(selectedOverDueDataArray.count == 0){
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
                }
                else{
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
                }
                cell.filterNameLabel.text = "Outdated Only"
                
            }
            else if(sectionName == "Projects"){
                
                let projectNamesArray = tableViewDataSource["Projects"]
                let projectName = projectNamesArray![indexPath.row]
                
                cell.filterNameLabel.text = projectName
                
                if(selectedProjectsArray.contains(projectName)){
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
                }
                else{
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
                }
                
            }
            else if(sectionName == "Current Status"){
                
                let leadStatusArray = tableViewDataSource["Current Status"]
                let leadType = leadStatusArray![indexPath.row]
                
                cell.filterNameLabel.text = leadType
                
                if(selectedStatsuArray.contains(leadType)){
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
                }
                else{
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
                }
                
            }
            else if(sectionName == "Sales Person"){
                
                let salesPersonNamesArray = tableViewDataSource["Sales Person"]
                let personName = salesPersonNamesArray![indexPath.row]
                
                cell.filterNameLabel.text = personName
                
                if(selectedSalesPersonsArray.contains(personName)){
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
                }
                else{
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
                }
            }
            else if(sectionName == "Enquiry Source"){
                
                let salesPersonNamesArray = tableViewDataSource["Enquiry Source"]
                let personName = salesPersonNamesArray![indexPath.row]
                cell.filterNameLabel.text = personName

                if(selectedEnquirySourcesArray.contains(personName)){
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
                }
                else{
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
                }
            }
            else if(sectionName == "Not ineterested Reasons"){
                
                let salesPersonNamesArray = tableViewDataSource["Not ineterested Reasons"]
                let personName = salesPersonNamesArray![indexPath.row]
                cell.filterNameLabel.text = personName

                if(selectedNotInterestedReasonsArray.contains(personName)){
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_on")
                }
                else{
                    cell.checkBoxImageView.image = UIImage.init(named: "checkbox_off")
                }

            }

        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.heightOfTableView.constant = self.tableView.contentSize.height

        let sectionName = orderedSectionsArray[indexPath.section]
        let tempArray = tableViewDataSource[sectionName]
        let selectedItem = tempArray![indexPath.row]

        if(isFromUnitsView){
            
            if(sectionName == "Floor Premium"){
                
                if(self.selectedFloorWisePremiumsArray.contains(selectedItem)){
                    let index = self.selectedFloorWisePremiumsArray.firstIndex(of: selectedItem)
                    self.selectedFloorWisePremiumsArray.remove(at: index!)
                }
                else{
                    self.selectedFloorWisePremiumsArray.append(selectedItem)
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedFloorWisePremiumsArray.count
            }
            else if(sectionName == "Other Premium"){
                
                if(self.selectedOtherPremiumsArray.contains(selectedItem)){
                    let index = self.selectedOtherPremiumsArray.firstIndex(of: selectedItem)
                    self.selectedOtherPremiumsArray.remove(at: index!)
                }
                else{
                    self.selectedOtherPremiumsArray.append(selectedItem)
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedOtherPremiumsArray.count
            }
            else if(sectionName == "Misc."){
                if(self.selectedMiscArray.contains(selectedItem)){
                    let index = self.selectedMiscArray.firstIndex(of: selectedItem)
                    self.selectedMiscArray.remove(at: index!)
                }
                else{
                    self.selectedMiscArray.append(selectedItem)
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedMiscArray.count
            }
            else if(sectionName == "No.Of Bedrooms"){
                
                if(self.selectedBedRoomsArray.contains(selectedItem)){
                    let index = self.selectedBedRoomsArray.firstIndex(of: selectedItem)
                    self.selectedBedRoomsArray.remove(at: index!)
                }
                else{
                    self.selectedBedRoomsArray.append(selectedItem)
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedBedRoomsArray.count
            }
            else if(sectionName == "No.Of Bathrooms"){
                
                if(self.selectedBathRoomsArray.contains(selectedItem)){
                    let index = self.selectedBathRoomsArray.firstIndex(of: selectedItem)
                    self.selectedBathRoomsArray.remove(at: index!)
                }
                else{
                    self.selectedBathRoomsArray.append(selectedItem)
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedBathRoomsArray.count
            }
            else if(sectionName == "Unit Type"){
                
                if(self.selectedTypeNamesArray.contains(selectedItem)){
                    let index = self.selectedTypeNamesArray.firstIndex(of: selectedItem)
                    self.selectedTypeNamesArray.remove(at: index!)
                }
                else{
                    self.selectedTypeNamesArray.append(selectedItem)
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedTypeNamesArray.count
            }
            else if(sectionName == "Unit Facing"){
                
                if(self.selectedFacingNamesArray.contains(selectedItem)){
                    let index = self.selectedFacingNamesArray.firstIndex(of: selectedItem)
                    self.selectedFacingNamesArray.remove(at: index!)
                }
                else{
                    self.selectedFacingNamesArray.append(selectedItem)
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedFacingNamesArray.count
            }
            else if(sectionName == "Super Built-Up Area"){
                
                if(self.selectedBuiltUpAreasArray.contains(selectedItem)){
                    let index = self.selectedBuiltUpAreasArray.firstIndex(of: selectedItem)
                    self.selectedBuiltUpAreasArray.remove(at: index!)
                }
                else{
                    self.selectedBuiltUpAreasArray.append(selectedItem)
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedBuiltUpAreasArray.count
            }
            else if(sectionName == "Carpet Area"){
                
                if(self.selectedCarpetAreaArray.contains(selectedItem)){
                    let index = self.selectedCarpetAreaArray.firstIndex(of: selectedItem)
                    self.selectedCarpetAreaArray.remove(at: index!)
                }
                else{
                    self.selectedCarpetAreaArray.append(selectedItem)
                }
                tableViewSectionsSelectedCountDict[indexPath.section] = self.selectedCarpetAreaArray.count
            }
        }
        else{
            if(sectionName == "Overdue Prospects"){
                if(self.selectedOverDueDataArray.contains(selectedItem)){
                    let index = self.selectedOverDueDataArray.firstIndex(of: selectedItem)
                    self.selectedOverDueDataArray.remove(at: index!)
                }
                else{
                    self.selectedOverDueDataArray.append(selectedItem)
                }
            }
            else if(sectionName == "Projects"){
                
                if(self.selectedProjectsArray.contains(selectedItem)){
                    let index = self.selectedProjectsArray.firstIndex(of: selectedItem)
                    self.selectedProjectsArray.remove(at: index!)
                }
                else{
                    self.selectedProjectsArray.append(selectedItem)
                }
            }
            else if(sectionName == "Current Status"){
                
                if(self.selectedStatsuArray.contains(selectedItem)){
                    let index = self.selectedStatsuArray.firstIndex(of: selectedItem)
                    self.selectedStatsuArray.remove(at: index!)
                }
                else{
                    self.selectedStatsuArray.append(selectedItem)
                }
            }
            else if(sectionName == "Sales Person"){
                
                if(self.selectedSalesPersonsArray.contains(selectedItem)){
                    let index = self.selectedSalesPersonsArray.firstIndex(of: selectedItem)
                    self.selectedSalesPersonsArray.remove(at: index!)
                }
                else{
                    self.selectedSalesPersonsArray.append(selectedItem)
                }
            }
            else if(sectionName == "Enquiry Source"){
                
                if(self.selectedEnquirySourcesArray.contains(selectedItem)){
                    let index = self.selectedEnquirySourcesArray.firstIndex(of: selectedItem)
                    self.selectedEnquirySourcesArray.remove(at: index!)
                }
                else{
                    self.selectedEnquirySourcesArray.append(selectedItem)
                }
            }
            else if(sectionName == "Not ineterested Reasons"){
                
                if(self.selectedNotInterestedReasonsArray.contains(selectedItem)){
                    let index = self.selectedNotInterestedReasonsArray.firstIndex(of: selectedItem)
                    self.selectedNotInterestedReasonsArray.remove(at: index!)
                }
                else{
                    self.selectedNotInterestedReasonsArray.append(selectedItem)
                }

            }
        }
        self.tableView.reloadData()
    }
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let sectionName = orderedSectionsArray[section]
//        return sectionName
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FiltersSectionHeaderView") as! FiltersSectionHeaderView

        let key = orderedSectionsArray[section]
        let count = tableViewSectionsSelectedCountDict[section]
        if(tableViewSectionsSelectedCountDict[section] != nil && count ?? 0 > 0){
            headerView.headerTitleLabel.text = String(format: "    %@(Selected:%d)", key,count!)
        }
        else{
            headerView.headerTitleLabel.text = String(format: "    %@", key)
        }
        
        let tapGuesture = UITapGestureRecognizer.init(target: self, action: #selector(shoudlExpandSection(_:)))
        headerView.subContentView.addGestureRecognizer(tapGuesture)
        
        headerView.indicatorImageView.image = UIImage.init(named: "downArrow")

        if let shouldExpand = tableViewSectionsExpandDict[section]{
            if(shouldExpand){
                headerView.indicatorImageView.image = UIImage.init(named: "upArrow")
            }
            else{
                headerView.indicatorImageView.image = UIImage.init(named: "downArrow")
            }
        }
        
        headerView.headerTitleLabel.font = UIFont.init(name: "Montserrat-Bold", size: 15)
        headerView.headerTitleLabel.textAlignment = .left
        headerView.headerTitleLabel.textColor = UIColor.hexStringToUIColor(hex: "9B9B9B")
        headerView.subContentView.backgroundColor = UIColor.hexStringToUIColor(hex: "EEEEEE")
        headerView.subContentView.tag = section
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.heightOfTableView.constant = self.tableView.contentSize.height
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.heightOfTableView.constant = self.tableView.contentSize.height
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.heightOfTableView.constant = self.tableView.contentSize.height
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.tableView.reloadData()
    }
    @objc func shoudlExpandSection(_ gestureRecognizer: UIGestureRecognizer){
        
        let tempView = gestureRecognizer.view!
        
        if let sectionSelected = tableViewSectionsExpandDict[tempView.tag]{
            tableViewSectionsExpandDict[tempView.tag] = !sectionSelected
        }
        else{
            tableViewSectionsExpandDict[tempView.tag] = true
        }
        self.tableView.reloadData()
        
    }
}
extension FiltersViewController : UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print(searchText)
        
        orderedSectionsArray.removeAll()
        if(searchText != ""){
//            tableViewDataSource["Unit Type"] = self.unitTypesArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
//            tableViewDataSource["Unit Facing"] = self.facingTypesArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
//            tableViewDataSource["Super Built-Up Area"] = self.builtUpsArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
//            tableViewDataSource["Carpet Area"] = self.carpetAreasArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
//            tableViewDataSource["Unit Type"] = self.unitTypesArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
//            tableViewDataSource["No.Of Bedrooms"] = self.bedRoomsArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
//            tableViewDataSource["No.Of Bathrooms"] = self.bathRoomsArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
//            tableViewDataSource["Floor Premium"] = self.floorWisePremiumsArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
//            tableViewDataSource["Other Premium"] = self.otherPremiumsArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
//            tableViewDataSource["Misc."] = self.miscArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
            
            if(self.facingTypesArray.filter({ $0.localizedCaseInsensitiveContains(searchText)}).count > 0){
                tableViewDataSource["Unit Facing"] = self.facingTypesArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
                orderedSectionsArray.append("Unit Facing")
            }
            else{
                tableViewDataSource.removeValue(forKey: "Unit Facing")
            }
            
            if(self.builtUpsArray.filter({ $0.localizedCaseInsensitiveContains(searchText)}).count > 0){
                tableViewDataSource["Super Built-Up Area"] = self.builtUpsArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
                orderedSectionsArray.append("Super Built-Up Area")
            }
            else{
                tableViewDataSource.removeValue(forKey: "Super Built-Up Area")
            }

            if(self.carpetAreasArray.filter({ $0.localizedCaseInsensitiveContains(searchText)}).count > 0){
                tableViewDataSource["Carpet Area"] = self.carpetAreasArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
                orderedSectionsArray.append("Carpet Area")
            }
            else{
                tableViewDataSource.removeValue(forKey: "Carpet Area")
            }
            
            if(self.unitTypesArray.filter({ $0.localizedCaseInsensitiveContains(searchText)}).count > 0){
                tableViewDataSource["Unit Type"] = self.unitTypesArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
                orderedSectionsArray.append("Unit Type")
            }
            else{
                tableViewDataSource.removeValue(forKey: "Unit Type")
            }

            if(self.bedRoomsArray.filter({ $0.localizedCaseInsensitiveContains(searchText)}).count > 0){
                tableViewDataSource["No.Of Bedrooms"] = self.bedRoomsArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
                orderedSectionsArray.append("No.Of Bedrooms")
            }
            else{
                tableViewDataSource.removeValue(forKey: "No.Of Bedrooms")
            }

            if(self.bathRoomsArray.filter({ $0.localizedCaseInsensitiveContains(searchText)}).count > 0){
                tableViewDataSource["No.Of Bathrooms"] = self.bathRoomsArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
                orderedSectionsArray.append("No.Of Bathrooms")
            }
            else{
                tableViewDataSource.removeValue(forKey: "No.Of Bathrooms")
            }

            if(self.floorWisePremiumsArray.filter({ $0.localizedCaseInsensitiveContains(searchText)}).count > 0){
                tableViewDataSource["Floor Premium"] = self.floorWisePremiumsArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
                orderedSectionsArray.append("Floor Premium")
            }
            else{
                tableViewDataSource.removeValue(forKey: "Floor Premium")
            }

            if(self.otherPremiumsArray.filter({ $0.localizedCaseInsensitiveContains(searchText)}).count > 0){
                tableViewDataSource["Other Premium"] = self.otherPremiumsArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
                orderedSectionsArray.append("Other Premium")
            }
            else{
                tableViewDataSource.removeValue(forKey: "Other Premium")
            }

            if(self.miscArray.filter({ $0.localizedCaseInsensitiveContains(searchText)}).count > 0){
                tableViewDataSource["Misc."] = self.miscArray.filter({ $0.localizedCaseInsensitiveContains(searchText)})
                orderedSectionsArray.append("Misc.")
            }
            else{
                tableViewDataSource.removeValue(forKey: "Misc.")
            }

        }
        else{
            //        orderedSectionsArray = ["Unit Facing","Super Built-Up Area","Carpet Area","Unit Type","No.Of Bedrooms","No.Of Bathrooms","Floor Premium","Other Premium","Misc."]

            if(self.facingTypesArray.count > 0){
                tableViewDataSource["Unit Facing"] = self.facingTypesArray
                orderedSectionsArray.append("Unit Facing")
            }
            if(self.builtUpsArray.count > 0){
                tableViewDataSource["Super Built-Up Area"] = self.builtUpsArray
                orderedSectionsArray.append("Super Built-Up Area")
            }
            if(self.carpetAreasArray.count > 0){
                tableViewDataSource["Carpet Area"] = self.carpetAreasArray
                orderedSectionsArray.append("Carpet Area")
            }
            if(self.unitTypesArray.count > 0){
                tableViewDataSource["Unit Type"] = self.unitTypesArray
                orderedSectionsArray.append("Unit Type")
            }
            if(self.bedRoomsArray.count > 0){
                tableViewDataSource["No.Of Bedrooms"] = self.bedRoomsArray
                orderedSectionsArray.append("No.Of Bedrooms")
            }
            if(self.bathRoomsArray.count > 0){
                tableViewDataSource["No.Of Bathrooms"] = self.bathRoomsArray
                orderedSectionsArray.append("No.Of Bathrooms")
            }
            if(self.floorWisePremiumsArray.count > 0){
                tableViewDataSource["Floor Premium"] = self.floorWisePremiumsArray
                orderedSectionsArray.append("Floor Premium")
            }
            if(self.otherPremiumsArray.count > 0){
                tableViewDataSource["Other Premium"] = self.otherPremiumsArray
                orderedSectionsArray.append("Other Premium")
            }
            if(self.miscArray.count > 0){
                tableViewDataSource["Misc."] = self.miscArray
                orderedSectionsArray.append("Misc.")
            }

        }
        self.tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        if(self.facingTypesArray.count > 0){
            tableViewDataSource["Unit Facing"] = self.facingTypesArray
            orderedSectionsArray.append("Unit Facing")
        }
        if(self.builtUpsArray.count > 0){
            tableViewDataSource["Super Built-Up Area"] = self.builtUpsArray
            orderedSectionsArray.append("Super Built-Up Area")
        }
        if(self.carpetAreasArray.count > 0){
            tableViewDataSource["Carpet Area"] = self.carpetAreasArray
            orderedSectionsArray.append("Carpet Area")
        }
        if(self.unitTypesArray.count > 0){
            tableViewDataSource["Unit Type"] = self.unitTypesArray
            orderedSectionsArray.append("Unit Type")
        }
        if(self.bedRoomsArray.count > 0){
            tableViewDataSource["No.Of Bedrooms"] = self.bedRoomsArray
            orderedSectionsArray.append("No.Of Bedrooms")
        }
        if(self.bathRoomsArray.count > 0){
            tableViewDataSource["No.Of Bathrooms"] = self.bathRoomsArray
            orderedSectionsArray.append("No.Of Bathrooms")
        }
        if(self.floorWisePremiumsArray.count > 0){
            tableViewDataSource["Floor Premium"] = self.floorWisePremiumsArray
            orderedSectionsArray.append("Floor Premium")
        }
        if(self.otherPremiumsArray.count > 0){
            tableViewDataSource["Other Premium"] = self.otherPremiumsArray
            orderedSectionsArray.append("Other Premium")
        }
        if(self.miscArray.count > 0){
            tableViewDataSource["Misc."] = self.miscArray
            orderedSectionsArray.append("Misc.")
        }
        self.tableView.reloadData()
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        if(self.facingTypesArray.count > 0){
            tableViewDataSource["Unit Facing"] = self.facingTypesArray
            orderedSectionsArray.append("Unit Facing")
        }
        if(self.builtUpsArray.count > 0){
            tableViewDataSource["Super Built-Up Area"] = self.builtUpsArray
            orderedSectionsArray.append("Super Built-Up Area")
        }
        if(self.carpetAreasArray.count > 0){
            tableViewDataSource["Carpet Area"] = self.carpetAreasArray
            orderedSectionsArray.append("Carpet Area")
        }
        if(self.unitTypesArray.count > 0){
            tableViewDataSource["Unit Type"] = self.unitTypesArray
            orderedSectionsArray.append("Unit Type")
        }
        if(self.bedRoomsArray.count > 0){
            tableViewDataSource["No.Of Bedrooms"] = self.bedRoomsArray
            orderedSectionsArray.append("No.Of Bedrooms")
        }
        if(self.bathRoomsArray.count > 0){
            tableViewDataSource["No.Of Bathrooms"] = self.bathRoomsArray
            orderedSectionsArray.append("No.Of Bathrooms")
        }
        if(self.floorWisePremiumsArray.count > 0){
            tableViewDataSource["Floor Premium"] = self.floorWisePremiumsArray
            orderedSectionsArray.append("Floor Premium")
        }
        if(self.otherPremiumsArray.count > 0){
            tableViewDataSource["Other Premium"] = self.otherPremiumsArray
            orderedSectionsArray.append("Other Premium")
        }
        if(self.miscArray.count > 0){
            tableViewDataSource["Misc."] = self.miscArray
            orderedSectionsArray.append("Misc.")
        }
        self.tableView.reloadData()
    }

}

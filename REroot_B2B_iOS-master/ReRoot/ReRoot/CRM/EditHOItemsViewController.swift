//
//  EditHOItemsViewController.swift
//  REroot
//
//  Created by Dhanunjay on 27/05/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import CoreData

protocol CompalintDialog : class {
    func showComplaintDialog(selectedHandOverItem : TowerHandOverItems, buttonIndex : Int)
}
extension CompalintDialog{
    func showComplaintDialog(selectedHandOverItem : TowerHandOverItems, buttonIndex : Int){
    }
}
class EditHOItemsViewController: UIViewController {
    
    @IBOutlet weak var groupNameLabel: UILabel!
    var fetchedResultsControllerHandOverItems : NSFetchedResultsController<TowerHandOverItems>!
 
    @IBOutlet weak var tableView: UITableView!
    var selectedUnit : SoldUnits!
    var selectedGroupDName : String!
    var selectedIndexPath : IndexPath!
    
    var selectedSectionsForExpand : [Int] = []
    
    weak var delegate : CompalintDialog?
    
    var isPermittedToEdit : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveItemComplaint), name: NSNotification.Name(NOTIFICATIONS.UPDATE_HO_ITEM_STATE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeComplaintView), name: NSNotification.Name(NOTIFICATIONS.UPDATE_HO_CLOSE_COMPLAINT), object: nil)
        
        
        self.configureView()
    }
    func configureView(){
        
        self.tableView.tableFooterView = UIView()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension

        let nib = UINib(nibName: "EditHOTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "editHOItem")
        
        let nib1 = UINib(nibName: "ItemHistoryTableViewCell", bundle: nil)
        self.tableView.register(nib1, forCellReuseIdentifier: "itemHistoryCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .white
        self.tableView.backgroundColor = UIColor.hexStringToUIColor(hex: "f9f9f9")
        
        self.groupNameLabel.text = self.selectedGroupDName
        
        self.fetchItemsToModify()
    }
    func fetchItemsToModify(){
        
        let request: NSFetchRequest<TowerHandOverItems> = TowerHandOverItems.fetchRequest()
        
        let predicate = NSPredicate(format: "unit CONTAINS[c] %@ AND groupdName == %@", selectedUnit.id!,selectedGroupDName)
        request.predicate = predicate
        
        let sort = NSSortDescriptor(key: #keyPath(TowerHandOverItems.name), ascending: true)
        request.sortDescriptors = [sort]
        
        fetchedResultsControllerHandOverItems = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: "name", cacheName:nil)
        fetchedResultsControllerHandOverItems.delegate = self
        
        do {
            try fetchedResultsControllerHandOverItems.performFetch()
            self.tableView.reloadData()
        }
        catch {
            fatalError("Error in fetching records")
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
extension EditHOItemsViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        print(self.fetchedResultsControllerHandOverItems.sections?.count)
        return (self.fetchedResultsControllerHandOverItems.sections?.count)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsControllerHandOverItems.sections![section]
        
        if(selectedSectionsForExpand.contains(section)){
            let handOverItem = sectionInfo.objects![0] as! TowerHandOverItems
            return (handOverItem.itemHistory?.count)! + 1
        }
        return sectionInfo.numberOfObjects
    }
    func shouldAddNewLine(tempStr : String)->Bool{
        if(tempStr.count > 0){
            return true
        }
        else{
            return false
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if(selectedSectionsForExpand.contains(indexPath.section) && indexPath.row > 0){
            
            // itemHistoryCell
            
            let cell : ItemHistoryTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: "itemHistoryCell",
                for: indexPath) as! ItemHistoryTableViewCell

            let sectionInfo = self.fetchedResultsControllerHandOverItems.sections![indexPath.section]
            let handOverItem = sectionInfo.objects![0] as! TowerHandOverItems
            var itemHistory = handOverItem.itemHistory!.allObjects as! [UnitHandOverItemHistory]
            
            itemHistory.sort( by: { $0.index <= $1.index })
            
            let tempItemHistory = itemHistory[indexPath.row-1]
            
            if(indexPath.row - 1 == itemHistory.count)
            {
                cell.vLineView.isHidden = true
            }
            else{
                cell.vLineView.isHidden = false
            }
            
            var infoString = ""
            
            if(tempItemHistory.itemDescription?.count ?? 0 > 0){
                infoString.append(String(format: "Description: %@", tempItemHistory.itemDescription!))
            }
            if(tempItemHistory.location != nil && tempItemHistory.location!.count > 0){
                if(self.shouldAddNewLine(tempStr: infoString)){
                    infoString.append("\n")
                }
                infoString.append(String(format: "Location: %@", tempItemHistory.location!))
            }
            if(tempItemHistory.modifiedDate != nil && tempItemHistory.modifiedDate!.count > 0){
                if(self.shouldAddNewLine(tempStr: infoString)){
                    infoString.append("\n")
                }
                infoString.append(RRUtilities.sharedInstance.getNotificationViewDate(dateStr: tempItemHistory.modifiedDate!))
            }
            
            cell.itemDescriptionLabel.text = infoString
            
            if(tempItemHistory.status == 1){
                cell.itemStateImageView.image = UIImage.init(named: "otp_success_icon")
                let colorDict = RRUtilities.sharedInstance.getHOStatusAsPerStatus(stattusIndex: Int(tempItemHistory.handOverStatus))
                let handOverState = colorDict["statusString"] as! String
                cell.itemStateInfoLabel.text = String(format: "%@ marked it as Completed in %@", tempItemHistory.user!,handOverState)
            }
            else{
                cell.itemStateImageView.image = UIImage.init(named: "reject")
                let colorDict = RRUtilities.sharedInstance.getHOStatusAsPerStatus(stattusIndex: Int(tempItemHistory.handOverStatus))
                let handOverState = colorDict["statusString"] as! String
                cell.itemStateInfoLabel.text = String(format: "%@ marked it as Incomplete in %@", tempItemHistory.user!,handOverState)
            }
            
            return cell
        }
        else{
            
            let cell : EditHOTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: "editHOItem",
                for: indexPath) as! EditHOTableViewCell

            let handOverItem = self.fetchedResultsControllerHandOverItems.object(at: indexPath)
            
            if(handOverItem.mandatory){
                cell.itemNameLabel.textColor = UIColor.hexStringToUIColor(hex: "00920d")
                cell.itemNameLabel.text = String(format: "%@%@", handOverItem.name!,"\u{002A}")
            }
            else{
                cell.itemNameLabel.textColor = UIColor.hexStringToUIColor(hex: "4a4a4a")
                cell.itemNameLabel.text = handOverItem.name
            }
            
            if(handOverItem.handOverStatus == HAND_OVER_ITEM_STATE.STATUS_COMPLETED.rawValue){
                
                cell.checkBoxButton.setImage(UIImage.init(named: "checkbox_on"), for: .normal)
                cell.checkBoxButton.isSelected = true
                cell.removeButton.setImage(UIImage.init(named: "cross"), for: .normal)
            }
            else if(handOverItem.handOverStatus == HAND_OVER_ITEM_STATE.STATUS_INCOMPLETE.rawValue){

                cell.checkBoxButton.isSelected = false
                cell.checkBoxButton.setImage(UIImage.init(named: "checkbox_off"), for: .normal)
                cell.removeButton.setImage(UIImage.init(named: "attach"), for: .normal)
            }
            
            cell.checkBoxButton.addTarget(self, action: #selector(didClickItemCheckOrUnCheck(_:)), for: .touchUpInside)
            cell.removeButton.addTarget(self, action: #selector(didClickRemoveItem(_:)), for: .touchUpInside)
            cell.checkBoxButton.tag = indexPath.section
            cell.removeButton.tag = indexPath.section
            
            if(!self.isPermittedToEdit){
                cell.checkBoxButton.isEnabled = false
                cell.removeButton.isEnabled = false
            }
            else{
                cell.checkBoxButton.isEnabled = true
                cell.removeButton.isEnabled = true
            }
            
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if(indexPath.row == 0){
            
            let handOverItem = self.fetchedResultsControllerHandOverItems.object(at: indexPath)

            if(selectedSectionsForExpand.contains(indexPath.section))
            {
                selectedSectionsForExpand = selectedSectionsForExpand.filter { $0 != indexPath.section }
            }
            else
            {
                // expand
                selectedSectionsForExpand.append(indexPath.section)
            }
            print(selectedSectionsForExpand)
            
            self.tableView.reloadData()
        }
    }
    @objc func closeComplaintView(_ notification: NSNotification){
        if let dict = notification.userInfo as Dictionary? {
            
            if((dict["buttonIndex"] as! Int) == 1){
                let cell : EditHOTableViewCell = self.tableView.cellForRow(at: self.selectedIndexPath) as! EditHOTableViewCell
                cell.checkBoxButton.setImage(UIImage.init(named: "checkbox_on"), for: .normal) //Un check after save button click
                cell.checkBoxButton.isSelected = true
            }
            else{
                
            }
        }
    }
    @objc func saveItemComplaint(_ notification: NSNotification){
        
        if let dict = notification.userInfo as Dictionary? {
            if((dict["isSave"] as! Int) == 1){
                
                if((dict["buttonIndex"] as! Int) == 1){
                    
                    let cell : EditHOTableViewCell = self.tableView.cellForRow(at: self.selectedIndexPath) as! EditHOTableViewCell

                    cell.checkBoxButton.setImage(UIImage.init(named: "checkbox_off"), for: .normal) //Un check after save button click
                    cell.checkBoxButton.isSelected = false
                    
                    cell.removeButton.setImage(UIImage.init(named: "attach"), for: .normal) //Un check after save button click

                }
                else if((dict["buttonIndex"] as! Int) == 2){
                    
                    let cell : EditHOTableViewCell = self.tableView.cellForRow(at: self.selectedIndexPath) as! EditHOTableViewCell
                    cell.checkBoxButton.setImage(UIImage.init(named: "checkbox_off"), for: .normal) //Un check after save button click
                    cell.checkBoxButton.isSelected = false
                    cell.removeButton.setImage(UIImage.init(named: "attach"), for: .normal) //Un check after save button click
                    
                }
            }
            else{ //remove button
                let cell = self.tableView.cellForRow(at: self.selectedIndexPath)
                let button : UIButton = cell?.viewWithTag(self.selectedIndexPath.section) as! UIButton
                button.setImage(UIImage.init(named: "attach"), for: .normal) //Un check after save button click
                button.isSelected = false
            }
        }
        selectedUnit.syncDirty = Int16(SYNC_STATE.SYNC_DIRTY.rawValue)
        RRUtilities.sharedInstance.model.saveContext()
        self.fetchItemsToModify()
    }
    @objc func didClickItemCheckOrUnCheck(_ sender: UIButton){
        
        // get handover item
        let handOverItem = self.fetchedResultsControllerHandOverItems.object(at: IndexPath.init(row: 0, section: sender.tag))
        
        print(handOverItem.name)
        self.selectedIndexPath = IndexPath.init(row: 0, section: sender.tag)
        
        if(sender.isSelected){
            
            sender.setImage(UIImage.init(named: "checkbox_off"), for: .normal) //Un check after save button click
            sender.isSelected = false
            
            self.showCompaintController(selectedHandOverItem: handOverItem,buttonIndex: 1)
            
        }
        else{
            // show complaint box **
            
            //show as pop Up
            
            
            sender.setImage(UIImage.init(named: "checkbox_on"), for: .normal)
            sender.isSelected = true
            
            // change the state of selected Item **
            
            let childContext = NSManagedObjectContext(
                concurrencyType: .privateQueueConcurrencyType)
            childContext.parent = RRUtilities.sharedInstance.model.managedObjectContext
            
            let childEntry = childContext.object(
                with: handOverItem.objectID) as? TowerHandOverItems
            
            childEntry?.handOverStatus = Int32(HAND_OVER_ITEM_STATE.STATUS_COMPLETED.rawValue)
            
//            selectedUnit.syncDirty = Int16(SYNC_STATE.SYNC_DIRTY.rawValue)
            
            let childContextOne = NSManagedObjectContext(
                concurrencyType: .privateQueueConcurrencyType)
            childContextOne.parent = RRUtilities.sharedInstance.model.managedObjectContext
            
            let childEntryOne = childContextOne.object(
                with: selectedUnit.objectID) as? SoldUnits
            
            childEntryOne?.syncDirty = Int16(SYNC_STATE.SYNC_DIRTY.rawValue)

            
            childContext.perform {
                do {
                    try childContext.save()
                    try childContextOne.save()
                } catch let error as NSError {
                    fatalError("Error: \(error.localizedDescription)")
                }
                RRUtilities.sharedInstance.model.saveContext()
                NotificationCenter.default.post(name: NSNotification.Name("FecthHandOverItems"), object: nil)
            }
            self.tableView.reloadData()
        }
    }
    func showCompaintController(selectedHandOverItem : TowerHandOverItems,buttonIndex : Int){
        self.delegate?.showComplaintDialog(selectedHandOverItem: selectedHandOverItem, buttonIndex: buttonIndex)
    }
    @objc func didClickRemoveItem(_ sender: UIButton){
//         print(sender.tag)
        
        // remove image or attach image
        
        let handOverItem = self.fetchedResultsControllerHandOverItems.object(at: IndexPath.init(row: 0, section: sender.tag))
        self.selectedIndexPath = IndexPath.init(row: 0, section: sender.tag)

        if(handOverItem.handOverStatus == HAND_OVER_ITEM_STATE.STATUS_INCOMPLETE.rawValue){ //show complain
            self.showCompaintController(selectedHandOverItem: handOverItem, buttonIndex: 2)
        }
        else{ //Remove
            self.showCompaintController(selectedHandOverItem: handOverItem, buttonIndex: 2)
        }
        
    }
}

extension EditHOItemsViewController  : NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if(controller == self.fetchedResultsControllerHandOverItems){
            self.tableView.beginUpdates()
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if(controller == self.fetchedResultsControllerHandOverItems){
            switch (type) {
            case .insert:
                if let indexPath = newIndexPath {
                    self.tableView.insertRows(at: [indexPath], with: .fade)
                }
                break;
            case .delete:
                if let indexPath = indexPath {
                   self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
                break;
            case .update:
                self.tableView.reloadRows(at: [indexPath!], with: .automatic)
                break;
            default:
                print("...")
            }
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if(controller == self.fetchedResultsControllerHandOverItems){
            
            self.tableView.endUpdates()
        }
    }
}

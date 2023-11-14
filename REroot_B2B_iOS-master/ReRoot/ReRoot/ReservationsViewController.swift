//
//  ReservationsViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 29/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

protocol ProjectSearchDelegate : class {
    func didClickBack()
}
extension ProjectSearchDelegate{
    func didClickBack(){}
}
class ReservationsViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
    
    weak var delegate : ProjectSearchDelegate?
    var selectedUnit : Units!
    @IBOutlet var titleInfoView: UIView!
    @IBOutlet var tableVIew: UITableView!
    @IBOutlet var unitNameDetailsLabel: UILabel!
    @IBOutlet var searchBar: UISearchBar!
    var tableViewDataSource : [CUSTOMER] = []
    var currentTableViewDataSource : [CUSTOMER] = []
    var selectedIndexPath : IndexPath!
    
    var isFromCRM : Bool = false
    
    var projectName = String()
    var blockName = String()
    var towerName = String()
    var floorName = String()
    var unitType = String()
    var unitDetailsString = String()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        self.tableViewDataSource = tableViewDataSource.sorted(by: <#T##(CUSTOMER, CUSTOMER) throws -> Bool#>)
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.black

        self.tableViewDataSource = tableViewDataSource.sorted(by: { $0.regInfo?.userName ?? "" < $1.regInfo?.userName ?? "" })
        
        self.currentTableViewDataSource = tableViewDataSource
        
        let nib = UINib(nibName: "RegInfoTableViewCell", bundle: nil)
        tableVIew.register(nib, forCellReuseIdentifier: "regInfoCell")

        tableVIew.delegate = self
        tableVIew.dataSource = self
        tableVIew.tableFooterView = UIView()
        
        tableVIew.estimatedRowHeight = UITableView.automaticDimension
        tableVIew.rowHeight = 44
        
        searchBar.delegate = self
//        searchBar.showsCancelButton = true

        // get unit name flow **
        
         unitDetailsString = String(format: "%@ > %@ > %@ > %d > %@ > %@ (%@)", projectName,blockName,towerName,selectedUnit.floorIndex,unitType,selectedUnit!.unitDisplayName!,selectedUnit.description1!)
        unitNameDetailsLabel.textColor = UIColor.hexStringToUIColor(hex: "184c67") //384a5a
        unitNameDetailsLabel.text = unitDetailsString
        
    

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.currentTableViewDataSource.count > 0)
        {
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "Client not found"
            noDataLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return self.currentTableViewDataSource.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : RegInfoTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "regInfoCell",
            for: indexPath) as! RegInfoTableViewCell
        
        let regInfo : REG_INFO = currentTableViewDataSource[indexPath.row].regInfo!
        
        cell.customerNameLabel.text = regInfo.userName
        cell.prospectIdLabel.text = regInfo.prospectId
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //let myViewController = MyViewController(nibName: "MyViewController", bundle: nil)
        
        let reserveController = ReserveUnitViewController(nibName: "ReserveUnitViewController", bundle: nil)
        reserveController.selectedUnit = self.selectedUnit
        reserveController.isFromCRM = self.isFromCRM
        reserveController.selectedUnitIndexPath = self.selectedIndexPath
        reserveController.unitDetailsString = self.unitDetailsString
        reserveController.selectedCustomerInfo = currentTableViewDataSource[indexPath.row]
        self.navigationController?.pushViewController(reserveController, animated: true)
        
    }
    @IBAction func back(_ sender: Any) {
        self.delegate?.didClickBack()
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        currentTableViewDataSource = tableViewDataSource.filter({ CUSTOMER -> Bool in
            switch searchBar.selectedScopeButtonIndex {
            case 0:
                if searchText.isEmpty { return true }
                else{
                    
                    let userName = CUSTOMER.regInfo!.userName!
                    let prospectId = CUSTOMER.regInfo!.prospectId ?? ""
                    
                    return  userName.lowercased().contains(searchText.lowercased()) || prospectId.lowercased().contains(searchText.lowercased())

                }
                
//                if(CUSTOMER.regInfo!.prospectId != nil && CUSTOMER.regInfo!.prospectId!.contains(searchText.lowercased())){
//                    return CUSTOMER.regInfo!.prospectId!.contains(searchText.lowercased())
//                }
//                else{
//                    return CUSTOMER.regInfo!.userName!.lowercased().contains(searchText.lowercased())//CUSTOMER.regInfo!.prospectId?.contains(searchText.lowercased())
//                }
//                if(CUSTOMER.regInfo!.userName!.lowercased().contains(searchText.lowercased())){
//                    return CUSTOMER.regInfo!.userName!.lowercased().contains(searchText.lowercased())
//                }
//                else if(CUSTOMER.regInfo!.prospectId != nil && CUSTOMER.regInfo!.prospectId!.contains(searchText.lowercased())){
//                    return CUSTOMER.regInfo!.prospectId!.contains(searchText.lowercased())
//                }
//                else{
//                    return CUSTOMER.regInfo!.userName!.lowercased().contains(searchText.lowercased())
//                }
                

                
            default:
                return false
            }
        })
        self.tableVIew.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(selectedScope)
        switch selectedScope {
        case 0:
            currentTableViewDataSource = tableViewDataSource
        default:
            break
        }
        self.tableVIew.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
        // Hide the cancel button
        searchBar.showsCancelButton = false
        self.hideKeyBoard()
        self.currentTableViewDataSource = self.tableViewDataSource
        tableVIew.reloadData()
    }
    func hideKeyBoard()
    {
        self.view.endEditing(true)
        //        self.searchBar.endEditing(true)
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

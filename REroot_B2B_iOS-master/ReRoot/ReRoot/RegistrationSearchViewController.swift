//
//  RegistrationSearchViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 21/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

protocol RegistrationSearchDelegate : class {
    func didSelectInterestedProjects(projectNames : [String],projectIds : [String])
    func didSelectEnquirySource(selectedSource : String,optionIndex: Int,enqSource : NewEnquirySources)
    func didSelectCommission(commission : CommissionUser)
}
extension RegistrationSearchDelegate{
//    func didSelectEnquirySource(selectedSource : String,optionIndex: Int){
//    }
    func didSelectCommission(commission : CommissionUser)
    {
    }
    func didSelectEnquirySource(selectedSource : String,optionIndex: Int,enqSource : NewEnquirySources){
        
    }
}

class RegistrationSearchViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
    
    @IBOutlet weak var infoLabel: UILabel!
    lazy var enquiryDataSource : [NewEnquirySources] = [] //[EnquirySources]
    var isEnquirySources = false
    
    lazy var commissionsDataSource : [CommissionUser] = []
    var isCommission = false
    
    @IBOutlet var searchBar: UISearchBar!
    var shouldShowRadioButton : Bool = false
    
    @IBOutlet var closeButton: UIButton!
    var projectsArray : Array<Project> = []
    var currentProjectsArray : Array<Project> = []
    var currentSourcesArray : Array<NewEnquirySources> = []
    var currentCommissionsArray : Array<CommissionUser> = []
    weak var delegate:RegistrationSearchDelegate?

    var selectedProjectNamesArray = [String]()
    var selectedProjectIds  = [String]()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var proceedButton: UIButton!
    
    //MARK: - methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.black

        self.projectsArray = RRUtilities.sharedInstance.model.getAllProjects()
        self.currentProjectsArray = self.projectsArray
        
        if(isCommission){
            currentCommissionsArray = self.commissionsDataSource
        }
        else if(isEnquirySources){
            currentSourcesArray = self.enquiryDataSource
        }

        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        searchBar.delegate = self
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = 60
        
        let bar = UIToolbar()
        let flexBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let reset = UIBarButtonItem(title: "PROCEED", style: .plain, target: self, action: #selector(resetTapped))
        bar.items = [flexBar,reset]
        bar.sizeToFit()
        searchBar.inputAccessoryView = bar
        searchBar.showsCancelButton = true
        if(isCommission){
            self.infoLabel.text = "Select Comission Entity"
        }
        if(isEnquirySources){
            self.infoLabel.text = "Select Enquiry Source"
        }
    }
    @objc func resetTapped(){
            self.proceed(UIButton())
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.currentProjectsArray.count
        
        if(isEnquirySources){
            return currentSourcesArray.count
        }
        if(isCommission){
            return currentCommissionsArray.count
        }
        
        if (self.currentProjectsArray.count > 0)
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
        return self.currentProjectsArray.count

        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : RegisterSearchTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "registerSearch",
            for: indexPath) as! RegisterSearchTableViewCell
        
        
        if(isEnquirySources){
            
            let tempProject = self.currentSourcesArray[indexPath.row]
            cell.titleLabel.text = tempProject.displayName

            if(selectedProjectNamesArray.contains(tempProject.displayName ?? "")){
                cell.mImageView.image = UIImage.init(named: "radio_on")
            }
            else{
                cell.mImageView.image = UIImage.init(named: "radio_off")
            }

            return cell
        }
        else if(isCommission){
            
            let commission = currentCommissionsArray[indexPath.row]
            cell.titleLabel.text = String(format: "%@ (%@)", commission.name ?? "",commission.phone ?? "")

            if(selectedProjectNamesArray.contains(cell.titleLabel.text!)){
                cell.mImageView.image = UIImage.init(named: "radio_on")
            }
            else{
                cell.mImageView.image = UIImage.init(named: "radio_off")
            }

            return cell

        }
        else{
            let tempProject = self.currentProjectsArray[indexPath.row]
            cell.titleLabel.text = tempProject.name

            if(shouldShowRadioButton){
                if(selectedProjectNamesArray.contains(tempProject.name!)){
                    cell.mImageView.image = UIImage.init(named: "radio_on")
                }
                else{
                    cell.mImageView.image = UIImage.init(named: "radio_off")
                }
            }
            else{
                
                if(selectedProjectNamesArray.contains(tempProject.name!)){
                    cell.mImageView.image = UIImage.init(named: "checkbox_on")
                }
                else{
                    cell.mImageView.image = UIImage.init(named: "checkbox_off")
                }
            }

        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if(isEnquirySources){
            let selectedOne = self.currentSourcesArray[indexPath.row]
            
            selectedProjectNamesArray.removeAll()
            selectedProjectNamesArray.append(selectedOne.displayName ?? "")
            tableView.reloadData()

            self.delegate?.didSelectEnquirySource(selectedSource: selectedOne.displayName ?? "", optionIndex: indexPath.row, enqSource: selectedOne)
            return
        }
        if(isCommission){
            
            let selectedOne = self.currentCommissionsArray[indexPath.row]
            
            selectedProjectNamesArray.removeAll()
            selectedProjectNamesArray.append(String(format: "%@ (%@)", selectedOne.name ?? "",selectedOne.phone ?? ""))
            tableView.reloadData()
            self.delegate?.didSelectCommission(commission: selectedOne)
        }
        let project = self.currentProjectsArray[indexPath.row]

        if(shouldShowRadioButton){
            selectedProjectNamesArray.removeAll()
            selectedProjectNamesArray.append(project.name!)
            selectedProjectIds.append(project.id!)
        }
        else{
            if(selectedProjectNamesArray.contains(project.name!)){
                
                selectedProjectNamesArray = selectedProjectNamesArray.filter { $0 != project.name }
                selectedProjectIds = selectedProjectIds.filter { $0 != project.id! }
            }
            else{
                selectedProjectNamesArray.append(project.name!)
                selectedProjectIds.append(project.id!)
            }
        }
        
        self.tableView.reloadData()
    }
    
    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        if(isCommission){
            
            currentCommissionsArray = commissionsDataSource.filter({ commission -> Bool in
                switch searchBar.selectedScopeButtonIndex {
                case 0:
                    if searchText.isEmpty { return true }
//                    String(format: "%@ (%@)", commission.name ?? "",commission.phone ?? "")
                    else{
                        
                        let userName = commission.name
                        let prospectId = commission.phone
                        
                        return  (userName!.lowercased().contains(searchText.lowercased()) || prospectId!.lowercased().contains(searchText.lowercased()))

                    }
                default:
                    return false
                }
            })

        }
        else if(isEnquirySources){
            
//            if(searchText.count > 0){
//                currentSourcesArray = enquiryDataSource.filter({ $0.displayName!.lowercased().contains(searchText.lowercased()) })
//            }
//            else{
//                currentSourcesArray = enquiryDataSource
//            }
//            print(currentSourcesArray)
//            print(currentSourcesArray.co)
//
            currentSourcesArray = enquiryDataSource.filter({ source -> Bool in
                switch searchBar.selectedScopeButtonIndex {
                case 0:
                    if searchText.isEmpty { return true }
                    return source.displayName!.lowercased().contains(searchText.lowercased())
                default:
                    return false
                }
            })

        }
        else{
            currentProjectsArray = projectsArray.filter({ Project -> Bool in
                switch searchBar.selectedScopeButtonIndex {
                case 0:
                    if searchText.isEmpty { return true }
                    return Project.name!.lowercased().contains(searchText.lowercased())
                default:
                    return false
                }
            })

        }
        self.tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(selectedScope)
        if(isCommission){
            currentCommissionsArray = commissionsDataSource
        }
        else if(isEnquirySources){
            currentSourcesArray = enquiryDataSource
        }
        else{
            switch selectedScope {
            case 0:
                currentProjectsArray = projectsArray
            default:
                break
            }
        }
        self.tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
        // Hide the cancel button
        //        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
//        searchBar.isHidden = true
//        titleLabel.isHidden = false
//        searchButton.isHidden = false
        self.hideKeyBoard()
        if(isCommission){
            currentCommissionsArray = commissionsDataSource
        }
        else if(isEnquirySources){
            currentSourcesArray = enquiryDataSource
        }
        self.currentProjectsArray = self.projectsArray
        tableView.reloadData()
    }
    func hideKeyBoard()
    {
        self.view.endEditing(true)
//        self.searchBar.endEditing(true)
    }
    
    
    
    
    
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func proceed(_ sender: Any) {
       
        self.delegate?.didSelectInterestedProjects(projectNames: selectedProjectNamesArray,projectIds: selectedProjectIds)
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

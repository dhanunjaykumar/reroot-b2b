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
}

class RegistrationSearchViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var closeButton: UIButton!
    var projectsArray : Array<Project> = []
    var currentProjectsArray : Array<Project> = []
    weak var delegate:RegistrationSearchDelegate?

    var selectedProjectNamesArray = [String]()
    var selectedProjectIds  = [String]()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var proceedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.projectsArray = RRUtilities.sharedInstance.model.getAllProjects()
        self.currentProjectsArray = self.projectsArray
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        searchBar.delegate = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.currentProjectsArray.count
        
        if (self.currentProjectsArray.count > 0)
        {
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Prject available"
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
        
        let tempProject = self.currentProjectsArray[indexPath.row]
        cell.titleLabel.text = tempProject.name
        
        if(selectedProjectNamesArray.contains(tempProject.name!)){
            cell.mImageView.image = UIImage.init(named: "Checkbox_on")
        }
        else{
            cell.mImageView.image = UIImage.init(named: "Checkbox_off")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let project = self.currentProjectsArray[indexPath.row]

        if(selectedProjectNamesArray.contains(project.name!)){
            
            selectedProjectNamesArray = selectedProjectNamesArray.filter { $0 != project.name }
            selectedProjectIds = selectedProjectIds.filter { $0 != project.id! }
        }
        else{
            selectedProjectNamesArray.append(project.name!)
            selectedProjectIds.append(project.id!)
        }
        self.tableView.reloadData()
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
        self.tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(selectedScope)
        switch selectedScope {
        case 0:
            currentProjectsArray = projectsArray
        default:
            break
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
        searchBar.isHidden = true
//        titleLabel.isHidden = false
//        searchButton.isHidden = false
        self.hideKeyBoard()
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

//
//  RegistrationsViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 24/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class RegistrationsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    var totalNumebrOfProspects : Int!
    @IBOutlet var searchButton: UIButton!
    var tableViewDataSourceArray : [REGISTRATIONS_RESULT] = []
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleView: UIView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var titleLabel: UILabel!
    var tabID : String!
    var registrationID : String!
    var refreshControl: UIRefreshControl?
    
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let nib = UINib(nibName: "CommonProspectsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "commonProspect")
        
        tableView.tableFooterView = UIView()
        
        searchBar.isHidden = true
        titleLabel.text = String(format: "Registrations (%d)", totalNumebrOfProspects)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getRegistrations), name: NSNotification.Name(rawValue: NOTIFICATIONS.FETCH_REGISTRATIONS), object: nil)
        
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableView.automaticDimension

        tableView.dataSource = self
        tableView.delegate = self

        self.getRegistrations()
        self.addRefreshControl()
    }
    func addRefreshControl() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.black
        refreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        tableView.addSubview(refreshControl!)
    }
    @objc func refreshList() {
        
        self.getRegistrations()
        
    }
    @objc func getRegistrations(){
        
        self.tableViewDataSourceArray.removeAll()
        tableView.reloadData()

        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            self.refreshControl?.endRefreshing()
            return
        }
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        HUD.show(.progress)
        
        var urlString = ""
        
        if(registrationID != nil){
            urlString =  RRAPI.GET_QR_PROSPECT_DATA + tabID + "&id=" + registrationID
        }
        else{
            urlString =  RRAPI.GET_QR_PROSPECT_DATA + tabID + "&id="
        }
        print(urlString)
        
        Alamofire.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                print(response)
                
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                let urlResult = try! JSONDecoder().decode(REGISTRATIONS.self, from: responseData)
                print(urlResult)
                
                
                self.refreshControl?.endRefreshing()
                if(urlResult.result != nil){
                    self.tableViewDataSourceArray = urlResult.result!
                    self.titleLabel.text = String(format: "Registrations (%d)", self.tableViewDataSourceArray.count)
                }
                
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                HUD.hide()

                break
            case .failure(let error):
                print(error)
                HUD.hide()
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                break
            }
        }
    }
    
    //MARK:- TABLEVIEW DELEGATE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.tableViewDataSourceArray.count > 0)
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
        return self.tableViewDataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CommonProspectsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "commonProspect",
            for: indexPath) as! CommonProspectsTableViewCell

        let registrationData = self.tableViewDataSourceArray[indexPath.row]
        
        cell.nameLabel.text = registrationData.userName
        
        cell.emailButton.tag = indexPath.row
        cell.callButton.tag = indexPath.row
        cell.emailButton.addTarget(self, action:#selector(openEmail(_:)), for: .touchUpInside)
        cell.callButton.addTarget(self, action:#selector(openDialer(_:)), for: .touchUpInside)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedRegistration  = self.tableViewDataSourceArray[indexPath.row]
        
        print(selectedRegistration)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailsController = storyboard.instantiateViewController(withIdentifier :"cusDetailsController") as! CustomerDetailsViewController
        detailsController.prospectDetails = selectedRegistration
        detailsController.prospectType = .REGISTRATIONS
        detailsController.isFromRegistrations = true
        
//        let tempNavigator = UINavigationController.init(rootViewController: detailsController)
        self.navigationController?.pushViewController(detailsController, animated: true)
//        self.present(tempNavigator, animated: true, completion: {
//        })

//        self.navigationController?.pushViewController(detailsController, animated: true)

        
    }
    
    @objc func openEmail(_ sender: UIButton){
        
        let selectedRegistration  = self.tableViewDataSourceArray[sender.tag]
        
        if(selectedRegistration.userEmail != nil){
            
            let emailer = String(format: "mailto:%@", selectedRegistration.userEmail!)
            let url = URL(string: emailer)
            
            UIApplication.shared.open(url!)
        }

    }
    @objc func openDialer(_ sender: UIButton){
        let selectedRegistration  = self.tableViewDataSourceArray[sender.tag]
        
        guard let number = URL(string: "tel://" + selectedRegistration.userPhone!) else { return }
        UIApplication.shared.open(number)

    }

    @IBAction func showSearchBar(_ sender: Any) {
        searchBar.isHidden = false
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - SearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
//        currentProjectsArray = projectsArray.filter({ Project -> Bool in
//            switch searchBar.selectedScopeButtonIndex {
//            case 0:
//                if searchText.isEmpty { return true }
//                return Project.name!.lowercased().contains(searchText.lowercased())
//            default:
//                return false
//            }
//        })
//        self.mTableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(selectedScope)
        switch selectedScope {
        case 0:
            break
//            currentProjectsArray = projectsArray
        default:
            break
        }
//        mTableView.reloadData()
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
//        self.currentProjectsArray = self.projectsArray
//        mTableView.reloadData()
    }
    func hideKeyBoard()
    {
        self.view.endEditing(true)
        self.searchBar.endEditing(true)
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

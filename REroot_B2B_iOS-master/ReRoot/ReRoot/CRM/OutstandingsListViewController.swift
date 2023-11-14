//
//  OutstandingsListViewController.swift
//  REroot
//
//  Created by Dhanunjay Kumar Mocharla on 19/11/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit
import CoreData
import PKHUD

class OutstandingsListViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleView: UIView!
    var searchText : String = ""
    
    var fetchedResultsControllerOutstandings : NSFetchedResultsController<CustomerOutstanding> = NSFetchedResultsController.init()

    // MARK: - Contoller Life Cycle
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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureView()
    }
    fileprivate func configureView(){
        
        self.configureTableView()
        self.searchBar.delegate = self
        self.shouldShowSearch(shouldShow: false)
        
    }
    fileprivate func configureTableView(){
        
        let nib = UINib(nibName: "OutstandingTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "outstandingCell")
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.estimatedRowHeight = 300
        self.tableView.rowHeight = UITableView.automaticDimension

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.fetchOutstandings()
    }
    func shouldShowSearch(shouldShow : Bool){
        
        self.searchBar.isHidden = !shouldShow
        self.searchButton.isHidden = shouldShow
        self.titleLabel.isHidden = shouldShow
        
    }
    fileprivate func fetchOutstandings(){
        
        let request: NSFetchRequest<CustomerOutstanding> = CustomerOutstanding.fetchRequest()
        
        let sort = NSSortDescriptor(key: #keyPath(CustomerOutstanding.index), ascending: true)
        request.sortDescriptors = [sort]
        
        if(searchText.count > 0){
            let predicate = NSPredicate(format: "customerName CONTAINS[c] %@ OR customerPhoneNumber CONTAINS[c] %@", searchText,searchText)
            request.predicate = predicate
        }
                
        fetchedResultsControllerOutstandings = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RRUtilities.sharedInstance.model.managedObjectContext, sectionNameKeyPath: nil, cacheName:nil)
        
        do {
            try fetchedResultsControllerOutstandings.performFetch()
            self.tableView.reloadData()
        }
        catch {
            fatalError("Error in fetching records")
        }
    }
    // MARK: - IBActions
    @IBAction func search(_ sender: Any) {
        self.shouldShowSearch(shouldShow: true)
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
extension OutstandingsListViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ((fetchedResultsControllerOutstandings.fetchedObjects?.count ?? 0) > 0)
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
        return (fetchedResultsControllerOutstandings.fetchedObjects?.count ?? 0)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "outstandingCell", for: indexPath) as! OutstandingTableViewCell
        cell.outstandingData = self.fetchedResultsControllerOutstandings.object(at: indexPath)
        self.configureCell(cell: cell, indexPath: indexPath)
        return cell
        
    }
    
    func configureCell(cell : OutstandingTableViewCell , indexPath : IndexPath){
        cell.callButton.addTarget(self, action: #selector(openDialer(_:)), for: .touchUpInside)
        cell.callButton.tag = indexPath.row
        cell.whatsAppButton.addTarget(self, action: #selector(openWhatsApp(_:)), for: .touchUpInside)
        cell.whatsAppButton.tag = indexPath.row
        cell.emailButton.addTarget(self, action: #selector(sendEmail(_:)), for: .touchUpInside)
        cell.emailButton.tag = indexPath.row
        cell.timelineButton.addTarget(self, action: #selector(showTimeline(_:)), for: .touchUpInside)
        cell.timelineButton.tag = indexPath.row
        cell.addFollowUpButton.addTarget(self, action: #selector(AddFollowUp(_:)), for: .touchUpInside)
        cell.addFollowUpButton.tag = indexPath.row
    }
    @objc func showTimeline(_ sender : UIButton){
        
        let quickController = QuickLinksViewController(nibName: "QuickLinksViewController", bundle: nil)
        quickController.isOutstanding = true
        let outstanding = self.fetchedResultsControllerOutstandings.object(at: IndexPath(row: sender.tag, section: 0))
        quickController.selectedOutstanding = self.fetchedResultsControllerOutstandings.object(at: IndexPath(row: sender.tag, section: 0))
        HUD.show(.progress, onView: self.view)
        ServerAPIs.getOutstandingTimeline(unitId: outstanding.unitId!,customerId: outstanding.cosCustomerId!, completion: { [weak self] result in
            HUD.hide()
            switch result {
            case .success(let cof):
                quickController.cosTimelineData = cof.reversed()
                self?.present(quickController, animated: true, completion: nil)
                break
            case .failure(let error):
                HUD.flash(.label(error.localizedDescription), delay: 1.0)
                break
            }
        })
    }
    @objc func AddFollowUp(_ sender : UIButton){
        
        let vc = CosFollowUpViewController(nibName: "CosFollowUpViewController", bundle: nil)
        vc.selectedOutstanding = self.fetchedResultsControllerOutstandings.object(at: IndexPath(row: sender.tag, section: 0))
        vc.preferredContentSize = CGSize(width: 320, height: 365)
        
        let navigationContoller = UINavigationController(rootViewController: vc)
        navigationContoller.navigationBar.isHidden = true
        navigationContoller.modalPresentationStyle = .popover
        vc.modalPresentationStyle = .popover
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popOver =  navigationContoller.popoverPresentationController
        popOver?.delegate = self
        popOver?.permittedArrowDirections = []
        
        popOver?.sourceView = self.view
        popOver?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)

        self.present(navigationContoller, animated: true, completion: nil)

    }
    @objc func openDialer(_ sender : UIButton){
        
        let outstandingData = self.fetchedResultsControllerOutstandings.object(at: IndexPath(row: sender.tag, section: 0))
        if let phoneNumber = outstandingData.customerPhoneNumber{
            guard let url = URL(string: "telprompt://" + phoneNumber) else {
                HUD.flash(.label("No phone number! Update it."), delay: 1.0)
                return }
            UIApplication.shared.open(url)
        }
    }
    @objc @IBAction func sendEmail(_ sender: UIButton) {
        
        let outstandingData = self.fetchedResultsControllerOutstandings.object(at: IndexPath(row: sender.tag, section: 0))

        if let email = outstandingData.customerEmail{
            let emailer = String(format: "mailto:%@", email)
            let url = URL(string: emailer)
            UIApplication.shared.open(url!)
        }
    }
    @objc func openWhatsApp(_ sender : UIButton){
            
        let outstandingData = self.fetchedResultsControllerOutstandings.object(at: IndexPath(row: sender.tag, section: 0))
        if let phoneNumber = outstandingData.customerPhoneNumber{
            guard let number = URL(string: String(format: "https://wa.me/%@%@?text=%@", outstandingData.customerPhoneCode!,phoneNumber,""))else{
                HUD.flash(.label("No phone number! Update it."), delay: 1.0)
                return}
            UIApplication.shared.open(number)
        }
    }
    
}
extension OutstandingsListViewController : UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
extension OutstandingsListViewController : UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.searchText = searchText
        self.fetchOutstandings()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.shouldShowSearch(shouldShow: false)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
        self.searchText = ""
        self.fetchOutstandings()
        self.view.endEditing(true)
        self.searchBar.endEditing(true)
        self.shouldShowSearch(shouldShow: false)
        // Hide the cancel button
        //        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
        
    }

    
}

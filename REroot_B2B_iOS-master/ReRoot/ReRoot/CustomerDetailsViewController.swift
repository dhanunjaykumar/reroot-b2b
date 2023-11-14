//
//  CustomerDetailsViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 25/09/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import FloatingPanel
import AVFoundation
import AVKit

class CustomerDetailsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,FloatingPanelControllerDelegate,MOVE_TO_FULL_DELEGATE,EditRegistration{
    
    var historyLeadsCount = 0
    var historyOppsCount = 0
    var historyRegCount = 0
    var historyReEnqCount = 0
    
    var siteVistActionId : String = ""
    var isFromDatePopUp = false
    var isFromOpportunitites = false
    var isFromDiscountView = false
    @IBOutlet weak var alternateNumberLabel: UILabel!
    @IBOutlet weak var alternatePhoneNumberView: UIView!
    @IBOutlet weak var heightOfAlternatePhoneNumberView: NSLayoutConstraint!
    @IBOutlet weak var heightOfCollectionView: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var isSuperAdminDone : Bool = false
    @IBOutlet weak var bottomConstraintOfTableView: NSLayoutConstraint!
    var leadsSectionsCount = 0
    var opportunitiesSectionsCount = 0
    var registrationsSecionsCount = 0
    let fpc = FloatingPanelController()
    var viewType : VIEW_TYPE!
    var statusChangeView : StatusChangeView! = nil
    @IBOutlet weak var editDetailsButton: UIButton!
    @IBOutlet weak var heightOfUserDetailsView: NSLayoutConstraint!
    @IBOutlet weak var heightOfScrollViewContentView: NSLayoutConstraint!
    @IBOutlet weak var heightOfTableView: NSLayoutConstraint!
    @IBOutlet weak var scrollViewContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightOfHistoryTableView: NSLayoutConstraint!
    var qrHistoryDataSource : QR_HISTORY!
    var isFromLeads : Bool = false
    var statusID : Int?
    var tabId : Int!
    var isFromRegistrations : Bool = false
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    var orderedKeyDetails : NSMutableOrderedSet = []
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var heightConstraintOfEmailView: NSLayoutConstraint!
    @IBOutlet weak var emailInfoLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var prospectType : PROSPECTS_TYPES!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var currentStatusLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var prospectDetails : REGISTRATIONS_RESULT!
    var isFromNotification = false
    @IBOutlet weak var heightOfLeadClassfication: NSLayoutConstraint!
    @IBOutlet weak var historyTableView: UITableView!
    var isFromNotInterested : Bool = false
    
    var prospectsDataSourceDict: Dictionary<String,String> = [:]
    
    @IBOutlet weak var leadClassificationView: UIView!
    @IBOutlet weak var leadClassificationLabel: UILabel!
    var isFromSummaryView : Bool = false
    var isFromUserTab = false
    var widthOfView : CGFloat = 0.0
    
    override func viewDidLayoutSubviews() {
        
//        constTableViewHeight.constant = tableView.contentSize.height
        self.heightOfHistoryTableView.constant = historyTableView.contentSize.height
        self.heightOfCollectionView.constant = collectionView.contentSize.height
//        widthOfView = (self.view.frame.size.width - 50 / 2.0)
    }
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
        self.navigationController?.navigationBar.isHidden = true
//        self.tableView.reloadData()
    }
    @objc func injected() {
        configureView()
    }
    func configureView(){
        
        self.historyTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        editDetailsButton.titleLabel?.font = UIFont(name:"Montserrat-Medium", size: 14)
        
        let nib1 = UINib(nibName: "QRHistoryTableViewCell", bundle: nil)
        historyTableView.register(nib1, forCellReuseIdentifier: "qrHistoryCell")

        historyTableView.rowHeight = UITableView.automaticDimension
        historyTableView.estimatedRowHeight = UITableView.automaticDimension // standard tableViewCell height
        leadClassificationLabel.layer.masksToBounds = true
        leadClassificationLabel.layer.cornerRadius = 4
        
        
        collectionView.register(UINib(nibName: "ProspectDetailsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "prospectDetails")

        let tempLayout = UICollectionViewFlowLayout.init()
        tempLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tempLayout.estimatedItemSize = CGSize(width: (self.collectionView.frame.size.width - 50)/2, height: 60)
        tempLayout.minimumInteritemSpacing = 0
        tempLayout.minimumLineSpacing = 0
        tempLayout.scrollDirection = .vertical
        collectionView.collectionViewLayout = tempLayout
        
//        print(self.prospectDetails)

//        historyTableView.estimatedRowHeight = 0
//        historyTableView.estimatedSectionHeaderHeight = 0
//        historyTableView.estimatedSectionFooterHeight = 0

        
//        print(prospectDetails)
//        print(prospectDetails.userEmail)
        
        if(prospectDetails.userEmail == nil || prospectDetails.userEmail?.count == 0 || RRUtilities.sharedInstance.isValidEmail(emailID: prospectDetails.userEmail!) == false)
        {
            emailView.isHidden = true
            heightConstraintOfEmailView.constant = 0
            heightOfUserDetailsView.constant = heightOfUserDetailsView.constant - 62
        }
        else{
            emailLabel.text = prospectDetails.userEmail
            emailView.isHidden = false
            heightConstraintOfEmailView.constant = 53
        }
        if((prospectDetails.alternatePhone == nil || prospectDetails.alternatePhone?.count ?? 0 == 0)){
            heightOfAlternatePhoneNumberView.constant = 0
            alternatePhoneNumberView.isHidden = true
        }

        if (prospectDetails.alternatePhone != nil && prospectDetails.alternatePhone?.count ?? 0 > 0 && prospectDetails.alternatePhoneCode != nil && prospectDetails.alternatePhoneCode?.count ?? 0 > 0) {
            alternateNumberLabel.text = String(format: "%@ %@",prospectDetails.alternatePhoneCode != nil ? String(format: "+%@", prospectDetails.alternatePhoneCode!) :  "",prospectDetails.alternatePhone!)
        }
        nameLabel.text = prospectDetails.userName
        phoneNumberLabel.text = String(format: "%@ %@",prospectDetails.userPhoneCode != nil ? String(format: "+%@", prospectDetails.userPhoneCode!) :  "",prospectDetails.userPhone!)
        
        if(prospectDetails.salesPerson?.userInfo?.name != nil)
        {
            prospectsDataSourceDict["Sales Person"] = prospectDetails.salesPerson?.userInfo?.name
            orderedKeyDetails.add("Sales Person")
        }
        else{
            prospectsDataSourceDict["Sales Person"] = "Super Admin"
            orderedKeyDetails.add("Sales Person")
        }
        if(prospectDetails.alternatePhone != nil && prospectDetails.alternatePhone?.count ?? 0 > 0){
            prospectsDataSourceDict["Alternate Phone Number"] = String(format: "+ %@ %@",prospectDetails.alternatePhoneCode ?? "", prospectDetails.alternatePhone ?? "")
            orderedKeyDetails.add("Alternate Phone Number")
        }
        if(prospectDetails.enquirySource != nil)
        {
            prospectsDataSourceDict["Enquiry Source"] = prospectDetails.enquirySource
            orderedKeyDetails.add("Enquiry Source")
        }
        if(prospectDetails.project?.name != nil){
            prospectsDataSourceDict["Interested In"] = prospectDetails.project?.name
            orderedKeyDetails.add("Interested In")
        }
        if(prospectDetails.dob != nil && prospectDetails.dob?.count ?? 1 > 1)
        {
            var dateStr = RRUtilities.sharedInstance.getRedableDayDateFromString(dateStr: prospectDetails.dob ??
            "")
            if(dateStr == nil && !(prospectDetails.dob?.contains("000Z") ?? false)){
            if let tempInt = Int64(prospectDetails.dob!){
                    let tempDate = Date.init(milliseconds: tempInt)
                    dateStr = RRUtilities.sharedInstance.getDateFromDate(date: tempDate)
                }
            }
            if(dateStr != nil){
                prospectsDataSourceDict["Date Of Birth"] = dateStr
                orderedKeyDetails.add("Date Of Birth")
            }
        }
        if(prospectDetails.gender != nil && prospectDetails.gender?.count ?? 0 > 0)
        {
            prospectsDataSourceDict["Gender"] = prospectDetails.gender
            orderedKeyDetails.add("Gender")
        }
       
        if(prospectDetails.clientDetails != nil){
            
            if(prospectDetails.clientDetails?.companyName != nil && prospectDetails.clientDetails?.companyName?.count ?? 0 > 0){
                prospectsDataSourceDict["Company Name"] = prospectDetails.clientDetails?.companyName
                orderedKeyDetails.add("Company Name")
            }
            if(prospectDetails.clientDetails?.designation != nil && prospectDetails.clientDetails?.designation?.count ?? 0 > 0){
                prospectsDataSourceDict["Designation"] = prospectDetails.clientDetails?.designation
                orderedKeyDetails.add("Designation")
            }
            if(prospectDetails.clientDetails?.industry != nil && prospectDetails.clientDetails?.industry?.count ?? 0 > 0){
                prospectsDataSourceDict["Industry"] = prospectDetails.clientDetails?.industry
                orderedKeyDetails.add("Industry")
            }
            if(prospectDetails.clientDetails?.locationOfWork != nil && prospectDetails.clientDetails?.locationOfWork?.count ?? 0 > 0){
                prospectsDataSourceDict["Location"] = prospectDetails.clientDetails?.locationOfWork
                orderedKeyDetails.add("Location")
            }
        }
        
        if (prospectDetails.minBudget != nil && prospectDetails.maxBudget != nil){
            prospectsDataSourceDict["Budget"] = String(format: "Min: %d - Max: %d", prospectDetails.minBudget!,prospectDetails.maxBudget!)
            orderedKeyDetails.add("Budget")
        }

        if prospectDetails.unitType != nil{
            prospectsDataSourceDict["Unit Type"] = prospectDetails.unitType ?? "-"
            orderedKeyDetails.add("Unit Type")
        }
            
        if(prospectDetails.comment != nil)
        {
            prospectsDataSourceDict["Comments"] = prospectDetails.comment ?? "-"
            orderedKeyDetails.add("Comments")
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self

        
//        if(prospectDetails.action?.label != nil){
//            prospectsDataSourceDict["ACTION"] = prospectDetails.action?.label
//            orderedKeyDetails.add("ACTION")
//        }
//        else{
//            prospectsDataSourceDict["ACTION"] = "None"
//            orderedKeyDetails.add("ACTION")
//        }
        
//        print(prospectDetails)
        
//        if(prospectDetails.action != nil){
//            currentStatusLabel.text = self.getTimelineLabel(label: prospectDetails.action?.label ?? "")
//        }
//        else{
//            currentStatusLabel.text = "None"
//        }
        
//        changeButton.layer.cornerRadius = 8
        
//        if(isFromNotInterested){
//            changeButton.isHidden = true
//        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(popControllers), name: NSNotification.Name(rawValue: NOTIFICATIONS.POP_CONTROLLERS), object: nil)
        
        self.getHistoryOfQuickRegistration()
        
        scrollView.delegate = self

        self.showStatusChangeView()
//        self.perform(#selector(relaodCollectionView), with: nil, afterDelay: 0.5)
        
        historyTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        self.collectionView.reloadData()
        
        let headerNib = UINib.init(nibName: "FiltersSectionHeaderView", bundle: Bundle.main)
        self.historyTableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "FiltersSectionHeaderView")
        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? UITableView {
            if obj == self.historyTableView && keyPath == "contentSize" {
                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    //do stuff here
                    self.heightOfHistoryTableView.constant = newSize.height + 20
//                    print(newSize.height)
                }
            }
        }
    }
    @objc func relaodCollectionView(){
        DispatchQueue.main.async {
            self.historyTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
//            self.scrollView.scrollRectToVisible(self.collectionView.frame, animated: true)
            self.collectionView.reloadItems(at: [IndexPath.init(row: self.orderedKeyDetails.count-1, section: 0)])
            self.collectionView.scrollToItem(at: IndexPath.init(row: self.orderedKeyDetails.count-1, section: 0), at: .bottom, animated: true)
            self.collectionView.reloadData()
        }
    }
    @objc func popControllers(){
        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: NSNotification.Name("popFromProspects"), object: nil)

            self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
            self.navigationController?.popViewController(animated: false)
            self.close(UIButton())
//            self.navigationController?.popViewController(animated: true)
        }
    }
    // MARK: - Tableview delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if(tableView == historyTableView){
            return 1 + (self.qrHistoryDataSource.leads?.count)! + (self.qrHistoryDataSource.opportunities?.count)! + self.historyReEnqCount
        }
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView == historyTableView){
            
            let registrations = self.qrHistoryDataSource.quickregistrations!
//            let leads : [QR_HISTORY_OPPORTUNITIES_OR_LEADS] = self.qrHistoryDataSource.leads!
//            let opportunities : [QR_HISTORY_OPPORTUNITIES_OR_LEADS] = self.qrHistoryDataSource.opportunities!
            
            var registrationRowsCount = 1
//            var leadsRowsCount = 0
//            var opportunitiesRowsCount = 0
            
            let leadsAndRegCount = (1 + self.qrHistoryDataSource.leads!.count)
            let allSectionsCount = (1 + self.qrHistoryDataSource.leads!.count + self.qrHistoryDataSource.opportunities!.count)
            
            if(section == 0){
                if((registrations.updateBy?.count)! > 0){
                    
                    let updateBysArray : [UpdatedByForProspects] = registrations.updateBy!
                    
                    for updateBy in updateBysArray{
                        
                        if(updateBy.oldSalesPerson != nil)
                        {
                            registrationRowsCount = registrationRowsCount + 1
                        }
                    }
                }
                return registrationRowsCount
            }
            else if(section > 0 && section < leadsAndRegCount){
                var leadsRowsCount = 1
                let rowLead = self.qrHistoryDataSource.leads![section-1]
                
                    if((rowLead.updateBy?.count)! > 0){
                        let leadUpdates : [UpdatedByForProspects] = rowLead.updateBy!
                        for leadUpdate in leadUpdates{
                            if(leadUpdate.oldSalesPerson != nil){
                                leadsRowsCount = leadsRowsCount + 1
                            }
                        }
                        return leadsRowsCount
                    }
                    else{
                        return 1
                    }
            }
            else if(section >= leadsAndRegCount && section < allSectionsCount)
            {
                var opportunitiesRowsCount = 1
                let opportunity = self.qrHistoryDataSource.opportunities![(section - leadsAndRegCount)]
                if((opportunity.updateBy?.count)! > 0){
                    let oppUpdates : [UpdatedByForProspects] = opportunity.updateBy!
                    for oppUpdate in oppUpdates{
                        if(oppUpdate.oldSalesPerson != nil){
                            opportunitiesRowsCount = opportunitiesRowsCount + 1
                        }
                    }
                    return opportunitiesRowsCount
                }
                else{
                    return opportunitiesRowsCount
                }
            }
            else if(section >= allSectionsCount){
                    
                return 1
            }
            
//            if(self.qrHistoryDataSource == nil)
//            {
//                return 0
//            }
//            if(self.qrHistoryDataSource != nil && section == 0){
//                return 1
//            }
//            else if(section == 1){
//                if(self.qrHistoryDataSource != nil && self.qrHistoryDataSource.leads != nil && self.qrHistoryDataSource.leads!.count > 0){
//                    return self.qrHistoryDataSource.leads!.count
//                }
//                return 0
//            }
//            else if(section == 2){
//                if(self.qrHistoryDataSource != nil && self.qrHistoryDataSource.opportunities != nil && self.qrHistoryDataSource.opportunities!.count > 0){
//                    return self.qrHistoryDataSource.opportunities!.count
//                }
//                return 0
//            }
        }
        
        return prospectsDataSourceDict.keys.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == historyTableView)
        {
            let cell : QRHistoryTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: "qrHistoryCell",
                for: indexPath) as! QRHistoryTableViewCell
            cell.delegate = self
            cell.heightOfApprovalButton.constant = 0
            cell.checkApprovalButton.isHidden = true
            
            cell.heightOfEditCompletionDate.constant = 0
            cell.editCompletionDate.isHidden = true
            cell.widthOfViewOfferButton.constant = 0
            
            cell.widthOfViewOfferButton.constant = 0
            cell.heightOfViewOfferButton.constant = 0
            cell.viewOfferButton.isHidden = true
            
            cell.idleSubView.isHidden = true
            cell.heightOfIdleSubView.constant = 0
            cell.idleHeadLabel.text = ""
            cell.idleSubHeadLabel.text = ""
            
            cell.checkApprovalButton.addTarget(self, action: #selector(showApprovalsView(_:)), for: .touchUpInside)
//            cell.qrTypeInfoLabel.layer.cornerRadius = 4
//            cell.qrTypeInfoLabel.layer.masksToBounds = true
            cell.discountRequestTimeLineData = []
            
            var commonString = String()
            
//            print(indexPath.section,indexPath.row)
            
            if(indexPath.section == 0){
                
                if(indexPath.row > 0){
                    let registration : QR_REGISTRATIONS = self.qrHistoryDataSource.quickregistrations!
                    

                    var commonString = String()
                    
                    let updates : [UpdatedByForProspects] = registration.updateBy!
                    
                    var tempArray : [UpdatedByForProspects] = []
                    
                    for salesPerson in updates{
                        if(salesPerson.oldSalesPerson != nil){
                            tempArray.append(salesPerson)
                        }
                    }
                    
                    let rowCount = indexPath.row-1
                    
                    cell.qrTypeNameLabel.text = "Change Of Sales Person"
                    cell.qrTypeInfoLabel.text = "S"
                    cell.qrTypeInfoLabel.backgroundColor = UIColor.black
                    
                    if(indexPath.row == 1){ //(tempArray.count == indexPath.row){
                        
                        if(tempArray.count > 1){
                            let changedSalesPerson = tempArray[rowCount+1]
                            commonString.append(String(format: "Re-Assigned from Super Admin to %@",(changedSalesPerson.oldSalesPerson?.userInfo?.name ?? "")!))
                            let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                            commonString = commonString + "\n" + date 
                        }
                        else{
                            let changedSalesPerson = tempArray[rowCount]
                            if(registration.salesPerson?.userInfo != nil){
                                commonString.append(String(format: "Re-Assigned from Super Admin to %@",(registration.salesPerson?.userInfo?.name ?? "")!))
                            }
                            else{
                                commonString.append(String(format: "Re-Assigned from Super Admin to Super Admin"))
                            }
                            let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                            commonString = commonString + "\n" + date

                        }
                        isSuperAdminDone = true
                    }
                    else{
                        if(indexPath.row <= tempArray.count){
                            
                            let changedSalesPerson = tempArray[indexPath.row-1]
                            
                            if(indexPath.row == tempArray.count){
                                
                                let salesPersonName =  RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (changedSalesPerson.oldSalesPerson?.userInfo?._id ?? "")) ?? "Super Admin"
                                let chanedPerson = registration.salesPerson?.userInfo?.name
                                if(chanedPerson == nil){
                                    commonString.append(String(format: "Re-Assigned from %@ to %@",salesPersonName,"Super Admin"))
                                }
                                else{
                                    commonString.append(String(format: "Re-Assigned from %@ to %@",salesPersonName,chanedPerson!))
                                }
                                let date = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: changedSalesPerson.date!)
                                commonString = commonString + "\n" + date
                            }
                            else{
                                
                                let salesPerson = tempArray[indexPath.row]
                                
                                let changedSaleGUyNmae =  RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (changedSalesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                let salesPersonName = RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (salesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                
                                commonString.append(String(format: "Re-Assigned from %@ to %@",changedSaleGUyNmae,salesPersonName))
                                
                                
                                let date = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: changedSalesPerson.date!)
                                commonString = commonString + "\n" + date
                            }
                        }
                    }
                    cell.qrDetailsLabel.text = commonString
                    return cell
                }
                else{
                    //registrations
                    let registration : QR_REGISTRATIONS = self.qrHistoryDataSource.quickregistrations!
                    //
                    //                print(registration)
                    //
                    cell.qrTypeInfoLabel.text = "R"
                    let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: registration.registrationDate!)
                    cell.qrTypeNameLabel.text = String(format: "%@ - %@", "Registration",date)
                    cell.heightOfStateLabelView.constant = 45
                    
                    if let callHisotry = registration.callHistory{
                        cell.callHisotryTimeLineData = callHisotry
                    }
                    if let projectName = registration.project?.name{
                        commonString.append(String(format: "Project : %@", projectName))
//                        cell.qrDetailsLabel.text = String(format: "Project : %@", projectName)
                    }
                    if(registration.idleDate != nil){
                        
                        cell.idleSubView.isHidden = false
                        cell.heightOfIdleSubView.constant = 50
                        cell.topConstraintOfIdleView.constant = 8
                        cell.bottomConstraintOfIdleSubView.constant = 8
                        cell.idleHeadLabel.text = "Idle due to inaction"
                        if let idleDate = registration.idleDate{
                            let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: idleDate)
                            cell.idleSubHeadLabel.text = date
                        }
                        else{
                            cell.idleSubHeadLabel.text = ""
                        }
                    }
                    else{
                        cell.idleSubView.isHidden = true
                        cell.heightOfIdleSubView.constant = 0
                        cell.idleHeadLabel.text = ""
                        cell.idleSubHeadLabel.text = ""
                        cell.topConstraintOfIdleView.constant = 8
                        cell.bottomConstraintOfIdleSubView.constant = 0
                    }

                    cell.subContentView.layoutIfNeeded()
//                    cell.heightOfQRDetailsLabel.constant = 0
                }
                cell.qrDetailsLabel.text = commonString

                return cell
            }
            if(indexPath.section > 0 && indexPath.section < (1+self.qrHistoryDataSource.leads!.count)){

                
                let lead = self.qrHistoryDataSource.leads![indexPath.section - 1]
                
//                let title = self.getTimelineLabel(label: lead.action?.label ?? "")
                
//                if(lead.externalUrlInfos?.count ?? 0 > 0){
//                    cell.urlInfos = lead.externalUrlInfos ?? []
//                    cell.urlTableView.isHidden = false
//                    cell.urlTableView.reloadData()
//                }
//                else{
//                    cell.urlInfos = []
//                    cell.urlTableView.isHidden = true
//                    cell.urlTableView.reloadData()
//                }

                
                if(indexPath.row > 0 && (lead.updateBy?.count)! > 1){
                    var commonString = String()
                    
                    let updates : [UpdatedByForProspects] = lead.updateBy!
                    
                    var tempArray : [UpdatedByForProspects] = []
                    
                    for salesPerson in updates{
                        if(salesPerson.oldSalesPerson != nil){
                            tempArray.append(salesPerson)
                        }
                    }
                    
                    let rowCount = indexPath.row-1
                    
                    cell.qrTypeNameLabel.text = "Change Of Sales Person"
                    cell.qrTypeInfoLabel.text = "S"
                    cell.qrTypeInfoLabel.backgroundColor = UIColor.black
                    
                    if(indexPath.row == 1){ //(tempArray.count == indexPath.row){
                        
                        if(tempArray.count > 1){
                            let changedSalesPerson = tempArray[rowCount+1]
                            let firstSalesPerson = tempArray[rowCount]
                            if(firstSalesPerson.oldSalesPerson?.userInfo != nil){
                                commonString.append(String(format: "Re-Assigned from %@ to %@",(firstSalesPerson.oldSalesPerson?.userInfo?.name)!,changedSalesPerson.oldSalesPerson!.userInfo!.name!))
                            }else{
                                commonString.append(String(format: "Re-Assigned from Super Admin to %@",changedSalesPerson.oldSalesPerson!.userInfo!.name!))
                            }
                            let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: firstSalesPerson.date!)
                            commonString = commonString + "\n" + date
                        }
                        else{
                            if(isSuperAdminDone){
                                let changedSalesPerson = tempArray[rowCount]
                                if(changedSalesPerson.oldSalesPerson?.userInfo != nil){
                                    commonString.append(String(format: "Re-Assigned from %@ to %@",(changedSalesPerson.oldSalesPerson?.userInfo?.name ?? "Super Admin")!,(lead.salesPerson?.userInfo?.name ?? "Super Admin")!))
                                }
                                else{
                                    commonString.append(String(format: "Re-Assigned from Super Admin to %@",(lead.salesPerson?.userInfo!.name!)!))
                                }
                                let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                                commonString = commonString + "\n" + date
                            }else{
                                let changedSalesPerson = tempArray[rowCount]
                                commonString.append(String(format: "Re-Assigned from Super Admin to %@",(lead.salesPerson?.userInfo?.name ?? "Super Admin")))
                                let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                                commonString = commonString + "\n" + date
                            }
                        }
                    }
                        else{
                            if(indexPath.row <= tempArray.count){
        
                                let changedSalesPerson = tempArray[indexPath.row-1]
                                
                                if(indexPath.row == tempArray.count){
                                    
                                    let salesPersonName =  RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (changedSalesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                    let chanedPerson = lead.salesPerson?.userInfo?.name
                                    
                                    commonString.append(String(format: "Re-Assigned from %@ to %@",salesPersonName,chanedPerson ?? "Super Admin"))
                                    
                                }
                                else{
                                    
                                    let salesPerson = tempArray[indexPath.row]
                                    
                                    let changedSaleGUyNmae =  RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (changedSalesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                    let salesPersonName = RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (salesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                    
                                    commonString.append(String(format: "Re-Assigned from %@ to %@",changedSaleGUyNmae,salesPersonName))
                                    
                                }
                                let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                                commonString = commonString + "\n" + date
                            }
                        }
//                    let updateedBy = lead.updateBy?.last
//                    let date = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updateedBy!.date!)
//                    commonString = commonString + "\n" + date
                    cell.qrDetailsLabel.text = commonString
                    if let callHisotry = lead.callHistory{
                        cell.callHisotryTimeLineData = callHisotry
                    }
                    
                    if(tempArray.count == indexPath.row){
                     
                        if(lead.idleDate != nil){
                            
                            cell.idleSubView.isHidden = false
                            cell.heightOfIdleSubView.constant = 50
                            cell.topConstraintOfIdleView.constant = 8
                            cell.bottomConstraintOfIdleSubView.constant = 8
                            cell.idleHeadLabel.text = "Idle due to inaction"
                            if let idleDate = lead.idleDate{
                                let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: idleDate)
                                cell.idleSubHeadLabel.text = date
                            }
                            else{
                                cell.idleSubHeadLabel.text = ""
                            }
                        }
                        else{
                            cell.idleSubView.isHidden = true
                            cell.topConstraintOfIdleView.constant = 8
                            cell.heightOfIdleSubView.constant = 0
                            cell.idleHeadLabel.text = ""
                            cell.idleSubHeadLabel.text = ""
                            cell.bottomConstraintOfIdleSubView.constant = 0
                        }

                    }

                    return cell
                }
                else{
                    
                    let lead : QR_HISTORY_OPPORTUNITIES_OR_LEADS = self.qrHistoryDataSource.leads![indexPath.section - 1] //self.qrHistoryDataSource.leads![indexPath.row]
                    

                    cell.qrTypeInfoLabel.text = "L"
                    cell.qrTypeInfoLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "f67823")
                    
                    let title = RRUtilities.sharedInstance.getTimelineLabel(label: lead.action?.label ?? "")
                    
                    //// *** COMMMON TO leads n oppps
                    if(lead.actionInfo?.date != nil){
                        
                        let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: lead.actionInfo!.date!)

                        cell.qrTypeNameLabel.text =  String(format: "%@ - %@", title,date)
                    }
                    else{
                        cell.qrTypeNameLabel.text =  title
                    }
                    //// *** COMMMON
                    
                    let updateedBy = lead.updateBy?.last

                    let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: updateedBy!.date!)
                    
                    if(lead.actionInfo!.units != nil && (lead.actionInfo!.units!.count > 0))
                    {
                        let unitsInfo = (lead.actionInfo?.units?[0])
                        
                        
                        /*
                         let floor : Floor?
                         let unitNo : Floor?
                         let _id : String?
                         let project : PROJECT?
                         let tower : QR_TOWER?
                         */
                        
                        if(unitsInfo != nil){
                            commonString.append(unitsInfo?.project?.name ?? "")
                            commonString.append(" | ")
                            
                            commonString.append(unitsInfo?.block?.name ?? "")
                            commonString.append(" | ")
                            
                            commonString.append(unitsInfo?.tower?.name ?? "")
                            commonString.append(" | ")
                            
                            commonString.append(String(format: "%d", unitsInfo?.floor?.index ?? 0))
                            commonString.append(" | ")
                            
                            if(unitsInfo?.type != nil){
                                commonString.append(unitsInfo?.type?.name ?? "")
                                commonString.append(" | ")
                            }
                            
                            commonString.append(String(format: "%d(%@)", unitsInfo?.unitNo?.index ?? 0,unitsInfo?.description ?? 0))
                            
                            if(lead.actionInfo?.scheme != nil){
                                let schemeName = RRUtilities.sharedInstance.model.getSchemeByID(schemeID: (lead.actionInfo!.scheme!))
                                commonString.append(String(format: "\nScheme Applied: %@", schemeName))
                            }
                            
                        }
                    }
                    
                    var labelText = String()
                    
                    if(title == "Not Interested"){
                        
                        if(lead.actionInfo?.comment != nil){
                            if(lead.actionInfo!.comment!.count > 0){
                                if(labelText.count > 0){
                                    labelText.append("\n")
                                }
                                labelText.append(String(format: "Comments : %@", lead.actionInfo!.comment!))
                            }
                        }
                        if(lead.action?.label?.count ?? 0 > 0){
                            labelText = String(format: "%@\n", lead.action?.label ?? "")
                        }
                        
                        if((lead.updateBy?.count)! > 0){
                            let updatedBy = lead.updateBy![0]
                            let updatedDate = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updatedBy.date!)
                            labelText.append(contentsOf: updatedDate)
                        }
                        else{
                            let updateedBy = lead.updateBy?.last
                            let date = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updateedBy!.date!)
                            labelText.append(contentsOf: date)
                        }
                        cell.qrDetailsLabel.text = labelText
                        if let callHisotry = lead.callHistory{
                            cell.callHisotryTimeLineData = callHisotry
                        }
                        return cell
                        
                    }
                    else if(title == "Site Visit"){
                        let actionInfo = lead.actionInfo
                        
                        if(actionInfo != nil && actionInfo?.completionDate != nil){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Completed on: %@", RRUtilities.sharedInstance.getNotificationViewDate(dateStr: actionInfo?.completionDate ?? "")))
                        }
                        
                        if(actionInfo != nil && actionInfo?.comment != nil){
                            if(lead.actionInfo!.comment!.count > 0){
                                if(commonString.count > 0){
                                    commonString.append("\n")
                                }
                                commonString.append(String(format: "Comments : %@", lead.actionInfo!.comment!))
                            }
                        }

                        var driverName = ""
                        var vehicleName = ""
                        var projectName = ""
                        
                        if let projectId = actionInfo?.projects?.first{
                            if let projDetails = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: projectId){
                                projectName = String(format: "%@", projDetails.name ?? "")
                            }
                        }
                        
                        if(actionInfo?.driver != nil){
                            if(commonString.count > 0){
                                driverName = String(format: "\nDriver : %@\n", RRUtilities.sharedInstance.model.getDriveNameUsingID(driverID: actionInfo!.driver!))
                            }
                            else{
                                driverName = String(format: "Driver : %@\n", RRUtilities.sharedInstance.model.getDriveNameUsingID(driverID: actionInfo!.driver!))
                            }
                        }
                        if(actionInfo?.vehicle != nil)
                        {
                            vehicleName = String(format: "Vehicle : %@", RRUtilities.sharedInstance.model.getVehicleNameUsingId(vehicleID: actionInfo?.vehicle ?? "") ?? "")
                        }
                        
                        cell.heightOfApprovalButton.constant = 0
                        cell.widthOfCheckApprovalButton.constant = 0
                        cell.checkApprovalButton.isHidden = true

                        cell.widthOfViewOfferButton.constant = 0
                        cell.heightOfViewOfferButton.constant = 0
                        cell.viewOfferButton.isHidden = true
                        cell.leadingOfViewOfferButton.constant = 0

                        cell.heightOfEditCompletionDate.constant = 20
                        cell.editCompletionDate.isHidden = false
                        cell.widthOfEditCompletionDate.constant = 200
                        cell.editCompletionDate.tag = 0
                        cell.editCompletionDate.removeTarget(nil, action: nil, for: .allEvents)
                        cell.editCompletionDate.addAction(for: .touchUpInside) { [unowned self] in
                            self.siteVistActionId = lead._id ?? ""
                            self.isFromOpportunitites = false
                            self.showSiteVisitDatePopUp(cell.editCompletionDate)
                        }
                        
                        
//                        commonString.append(projectName)
                        commonString.append(driverName)
                        commonString.append(vehicleName)
                        
                    }
                    else if(title == "Discount Request"){
                        var shouldHideApprovalButton = false
                        if(lead.discountAppliedStatus == DISCOUNT_REQUEST_STATES.DISCOUNT_APPLIED.rawValue){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Discount Request Status : %@", "Applied"))
                            shouldHideApprovalButton = true
                        }
                        else if(lead.discountAppliedStatus == DISCOUNT_REQUEST_STATES.DISCOUNT_PENDING.rawValue){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Discount Request Status : %@", "Pending"))
                        }
                        else if(lead.discountAppliedStatus == DISCOUNT_REQUEST_STATES.DISCOUNT_REJECTED.rawValue){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Discount Request Status : %@", "Applied"))
                            shouldHideApprovalButton = true
                        }
                        if(lead.actionInfo != nil && lead.actionInfo?.comment != nil && lead.actionInfo!.comment!.count > 0){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Comments : %@", lead.actionInfo!.comment!))
                        }
                        
                        if(lead.updateBy?.count ?? 0 > 1){
                            if(shouldHideApprovalButton){
                                cell.heightOfApprovalButton.constant = 18
                                cell.widthOfCheckApprovalButton.constant = 120
                                cell.checkApprovalButton.isHidden = false
                                let arraySlice = lead.updateBy?.suffix(from: 1)
                                cell.discountRequestTimeLineData = Array(arraySlice!)
                            }
                            else{
                                cell.heightOfApprovalButton.constant = 0
                                cell.widthOfCheckApprovalButton.constant = 0
                                cell.checkApprovalButton.isHidden = true
                            }

//                            cell.heightOfQRDetailsLabel.constant = cell.qrDetailsLabel.intrinsicContentSize.height
//                            cell.heightOfTimeLineTableView.constant = cell.timeLineTableView.contentSize.height
                            
                            if(lead.actionInfo?.fileUrl != nil){
                                cell.viewOfferButton.isHidden = false
                                cell.widthOfViewOfferButton.constant = 90
                                cell.heightOfViewOfferButton.constant = 18
                                cell.leadingOfViewOfferButton.constant = 12
                                if(shouldHideApprovalButton){
                                    cell.leadingOfViewOfferButton.constant = 0
                                }
                                cell.viewOfferButton.addAction { [unowned self] in
                                    self.showOffer(offerUrl: (lead.actionInfo?.fileUrl)!)
                                }
                            }
                            else{
                                cell.viewOfferButton.isHidden = true
                                cell.widthOfViewOfferButton.constant = 0
                                cell.heightOfViewOfferButton.constant = 0
                            }
                        }
                        else{
                            cell.discountRequestTimeLineData = []
                            cell.heightOfApprovalButton.constant = 0
                            cell.widthOfCheckApprovalButton.constant = 0
                            cell.checkApprovalButton.isHidden = true
                            
                            if(lead.actionInfo?.fileUrl != nil){
                                cell.viewOfferButton.isHidden = false
                                cell.widthOfViewOfferButton.constant = 90
                                cell.heightOfViewOfferButton.constant = 18
                                cell.leadingOfViewOfferButton.constant = 0
                                cell.viewOfferButton.addAction { [unowned self] in
                                    self.showOffer(offerUrl: (lead.actionInfo?.fileUrl)!)
                                }
                            }
                            else{
                                cell.viewOfferButton.isHidden = true
                                cell.widthOfViewOfferButton.constant = 0
                                cell.heightOfViewOfferButton.constant = 0
                            }

                        }
                        
                        
                    }
                    else if(title == "Other Task"){
                        //name //status
                        
                        var taskName = ""
                        var taskStatus = ""
                        var taskDescription = ""
                        
                        if(lead.actionInfo?.taskName != nil){
                            taskName = lead.actionInfo!.taskName!
                        }
                        if(lead.actionInfo?.taskStatus != nil){
                            
                            if(lead.actionInfo!.taskStatus == 0){
                                taskStatus = "Open"
                            }
                            else if(lead.actionInfo!.taskStatus == 1){
                                taskStatus = "On Hold"
                            }
                            else if(lead.actionInfo!.taskStatus == 2){
                                taskStatus = "Task Assigned"
                            }
                        }
                        
                        if(lead.actionInfo?.taskDescription != nil)
                        {
                            taskDescription = lead.actionInfo!.taskDescription!
                        }
                        
                        commonString.append(contentsOf: String(format: "Task Name: %@", taskName))
                        commonString.append("\n")
                        if(taskDescription.count > 0){
                            commonString.append(contentsOf: String(format: "Description: %@", taskDescription))
//                            commonString.append("\n")
                        }
                        commonString.append(contentsOf: String(format: "Task Status: %@", taskStatus))
                        if(lead.actionInfo != nil && lead.actionInfo?.comment != nil && lead.actionInfo!.comment!.count > 0){
                            commonString.append(String(format: "Comments : %@", lead.actionInfo!.comment!))
                        }
                        if(lead.actionInfo != nil && lead.actionInfo?.comment != nil && lead.actionInfo!.comment!.count > 0){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Comments : %@", lead.actionInfo!.comment!))
                        }
                    }
                    else if(title == "Offer")
                    {
                        if(lead.actionInfo?.scheme != nil){
                            let schemeName = RRUtilities.sharedInstance.model.getSchemeByID(schemeID: (lead.actionInfo!.scheme!))
                            commonString.append(String(format: "\nScheme Applied: %@", schemeName))
                        }

                        if(lead.actionInfo != nil && lead.actionInfo?.comment != nil && lead.actionInfo!.comment!.count > 0){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Comments : %@", lead.actionInfo!.comment!))
                        }
                        
                        if (lead.actionInfo?.fileUrl) != nil{
                            
                            cell.widthOfCheckApprovalButton.constant = 0
                            cell.heightOfApprovalButton.constant = 0
                            cell.checkApprovalButton.isHidden = true
//                            cell.checkApprovalButton.setTitle("View Offer", for: .normal)
                            
                            cell.viewOfferButton.isHidden = false
                            cell.heightOfViewOfferButton.constant = 18
                            cell.heightOfViewOfferButton.isActive = true
                            cell.widthOfViewOfferButton.constant = 90
                            cell.heightOfViewOfferButton.constant = 18
                            cell.leadingOfViewOfferButton.constant = 0

                            cell.viewOfferButton.addAction(for: .touchUpInside) { [unowned self] in
                                self.showOffer(offerUrl: (lead.actionInfo?.fileUrl)!)
                            }
//                            cell.checkApprovalButton.tag = 1
                            
                        }
                        else{
                            cell.heightOfApprovalButton.constant = 0
                            cell.checkApprovalButton.isHidden = true
                            cell.checkApprovalButton.setTitle("Check Approval", for: .normal)
                            cell.checkApprovalButton.tag = 0
                            
                            cell.widthOfViewOfferButton.constant = 0
                            cell.heightOfViewOfferButton.constant = 0
                            cell.viewOfferButton.isHidden = true
                        }
                    }
                    else if(title == "Call"){
                        if(lead.actionInfo != nil && lead.actionInfo?.comment != nil && lead.actionInfo!.comment!.count > 0){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Comments : %@", lead.actionInfo!.comment!))
                        }
                    }
                    
                    var dateStr = ""
                    if(commonString.count > 0){
                        dateStr = String(format: "\n%@", date)
                    }
                    else{
                        dateStr = date
                    }
                    commonString.append(contentsOf: dateStr)
                    
                    cell.qrDetailsLabel.invalidateIntrinsicContentSize()
                    cell.qrDetailsLabel.text = commonString
                    cell.qrDetailsLabel.superview?.layoutIfNeeded()
//                    cell.heightOfQRDetailsLabel.constant = cell.qrDetailsLabel.intrinsicContentSize.height

                    if(lead.actionInfo?.date != nil){  // *** DATE IS COMMON TO ALL
                        cell.dateLabel.text = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr:lead.actionInfo!.date!)
                    }
                    else{
                        cell.dateLabel.text = ""
                    }
                    if let callHisotry = lead.callHistory{
                        cell.callHisotryTimeLineData = callHisotry
                    }
                    
                    
                    if(lead.externalUrlInfos?.count ?? 0 > 0){
                        cell.urlInfos = lead.externalUrlInfos ?? []
                        cell.urlTableView.isHidden = false
//                        cell.urlTableView.reloadData()
                    }
                    else{
                        cell.urlInfos = []
                        cell.urlTableView.isHidden = true
//                        cell.urlTableView.reloadData()
                    }
                    
                    if(lead.idleDate != nil && (lead.updateBy?.count) == 0){
                        
                        cell.idleSubView.isHidden = false
                        cell.heightOfIdleSubView.constant = 50
                        cell.topConstraintOfIdleView.constant = 8
                        cell.bottomConstraintOfIdleSubView.constant = 8
                        cell.idleHeadLabel.text = "Idle due to inaction"
                        if let idleDate = lead.idleDate{
                            let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: idleDate)
                            cell.idleSubHeadLabel.text = date
                        }
                        else{
                            cell.idleSubHeadLabel.text = ""
                        }
                    }
                    else{
                        cell.idleSubView.isHidden = true
                        cell.topConstraintOfIdleView.constant = 8
                        cell.heightOfIdleSubView.constant = 0
                        cell.idleHeadLabel.text = ""
                        cell.idleSubHeadLabel.text = ""
                        cell.bottomConstraintOfIdleSubView.constant = 0
                    }

                    return cell

                }
                
                
            }
            if(indexPath.section >= (1+self.qrHistoryDataSource.leads!.count) && indexPath.section < (1+self.qrHistoryDataSource.leads!.count + self.qrHistoryDataSource.opportunities!.count)){
//                print((1+self.qrHistoryDataSource.leads!.count + self.qrHistoryDataSource.opportunities!.count))
                cell.qrTypeInfoLabel.text = "O"
                
                let opportunity = self.qrHistoryDataSource.opportunities![indexPath.section - (1+self.qrHistoryDataSource.leads!.count)]
                
//                let title = self.getTimelineLabel(label: opportunity.action?.label ?? "")

                if(indexPath.row > 0 && (opportunity.updateBy?.count)! > 1){
                    var commonString = String()

                    let updates : [UpdatedByForProspects] = opportunity.updateBy!
                    
                    var tempArray : [UpdatedByForProspects] = []
                    
                    for salesPerson in updates{
                        if(salesPerson.oldSalesPerson != nil){
                            tempArray.append(salesPerson)
                        }
                    }
                    
                    let rowCount = indexPath.row-1
                    
                    cell.qrTypeNameLabel.text = "Change Of Sales Person"
                    cell.qrTypeInfoLabel.text = "S"
                    cell.qrTypeInfoLabel.backgroundColor = UIColor.black
                    
                        if(indexPath.row == 1){ //(tempArray.count == indexPath.row){
                            
                            if(tempArray.count > 1){
                                let changedSalesPerson = tempArray[rowCount+1]
                                let firstSalesPerson = tempArray[rowCount]
                                if(firstSalesPerson.oldSalesPerson?.userInfo != nil && changedSalesPerson.oldSalesPerson != nil){
                                    commonString.append(String(format: "Re-Assigned from %@ to %@",(firstSalesPerson.oldSalesPerson?.userInfo?.name)!,changedSalesPerson.oldSalesPerson!.userInfo!.name!))
                                }else{
                                    commonString.append(String(format: "Re-Assigned from Super Admin to %@",changedSalesPerson.oldSalesPerson!.userInfo!.name!))
                                }
                                let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: firstSalesPerson.date!)
                                commonString = commonString + "\n" + date
                            }
                            else{
                                if(isSuperAdminDone){
                                    let changedSalesPerson = tempArray[rowCount]
                                    commonString.append(String(format: "Re-Assigned from %@ to %@",(changedSalesPerson.oldSalesPerson?.userInfo?.name)!,(opportunity.salesPerson?.userInfo!.name!)!))
                                    let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                                    commonString = commonString + "\n" + date
                                }else{
                                    let changedSalesPerson = tempArray[rowCount]
                                    commonString.append(String(format: "Re-Assigned from Super Admin to %@",(opportunity.salesPerson?.userInfo!.name!)!))
                                    let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                                    commonString = commonString + "\n" + date
                                }
                            }
                        }
                        else{
                            if(indexPath.row <= tempArray.count){
                                
                                let changedSalesPerson = tempArray[indexPath.row-1]
                                
                                if(indexPath.row == tempArray.count){
                                    
                                    let salesPersonName =  RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (changedSalesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                    let chanedPerson = opportunity.salesPerson?.userInfo?.name
                                    
                                    //                                cell.qrDetailsLabel.text = String(format: "Re-Assigned from %@ to %@",salesPersonName,chanedPerson!)
                                    commonString.append(String(format: "Re-Assigned from %@ to %@",salesPersonName,chanedPerson!))
                                    let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                                    commonString = commonString + "\n" + date

                                }
                                else{
                                    
                                    let salesPerson = tempArray[indexPath.row]
                                    
                                    let changedSaleGUyNmae =  RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (changedSalesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                    let salesPersonName = RRUtilities.sharedInstance.model.getEmployeeNameUsingId(employeId: (salesPerson.oldSalesPerson?.userInfo?._id)!) ?? ""
                                    
                                    //                                cell.qrDetailsLabel.text = String(format: "Re-Assigned from %@ to %@",salesPersonName,changedSaleGUyNmae)
                                    commonString.append(String(format: "Re-Assigned from %@ to %@",changedSaleGUyNmae,salesPersonName))
                                    let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: changedSalesPerson.date!)
                                    commonString = commonString + "\n" + date

                                    //                                cell.dateLabel.text = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr:salesPerson.date!)
                                    
                                }
                            }
                        }
//                    let updateedBy = opportunity.updateBy?.last
                    cell.qrDetailsLabel.text = commonString
                    if let callHisotry = opportunity.callHistory{
                        cell.callHisotryTimeLineData = callHisotry
                    }
                    
                    if(tempArray.count == indexPath.row){
                     
                        if(opportunity.idleDate != nil){
                            
                            cell.idleSubView.isHidden = false
                            cell.heightOfIdleSubView.constant = 50
                            cell.topConstraintOfIdleView.constant = 8
                            cell.bottomConstraintOfIdleSubView.constant = 8
                            cell.idleHeadLabel.text = "Idle due to inaction"
                            if let idleDate = opportunity.idleDate{
                                let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: idleDate)
                                cell.idleSubHeadLabel.text = date
                            }
                            else{
                                cell.idleSubHeadLabel.text = ""
                            }
                        }
                        else{
                            cell.idleSubView.isHidden = true
                            cell.topConstraintOfIdleView.constant = 8
                            cell.heightOfIdleSubView.constant = 0
                            cell.idleHeadLabel.text = ""
                            cell.idleSubHeadLabel.text = ""
                            cell.bottomConstraintOfIdleSubView.constant = 0
                        }

                    }
                    return cell
                }
                else{
                    
                    cell.qrTypeInfoLabel.text = "O"
                    cell.qrTypeInfoLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "3aa81e")
                    
                    let opportunity : QR_HISTORY_OPPORTUNITIES_OR_LEADS = self.qrHistoryDataSource.opportunities![indexPath.section - (1+self.qrHistoryDataSource.leads!.count)] //self.qrHistoryDataSource.opportunities![indexPath.row]
                    
                    if(opportunity.idleDate != nil && (opportunity.updateBy?.count) == 0){
                        
                        cell.idleSubView.isHidden = false
                        cell.heightOfIdleSubView.constant = 50
                        cell.topConstraintOfIdleView.constant = 8
                        cell.bottomConstraintOfIdleSubView.constant = 8
                        cell.idleHeadLabel.text = "Idle due to inaction"
                        if let idleDate = opportunity.idleDate{
                            let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: idleDate)
                            cell.idleSubHeadLabel.text = date
                        }
                        else{
                            cell.idleSubHeadLabel.text = ""
                        }
                    }
                    else{
                        cell.idleSubView.isHidden = true
                        cell.topConstraintOfIdleView.constant = 8
                        cell.heightOfIdleSubView.constant = 0
                        cell.idleHeadLabel.text = ""
                        cell.idleSubHeadLabel.text = ""
                        cell.bottomConstraintOfIdleSubView.constant = 0

                    }

                    let title = RRUtilities.sharedInstance.getTimelineLabel(label: opportunity.action?.label ?? "")
                    
                    
                    //// *** COMMMON TO leads n oppps
                    if(opportunity.actionInfo?.date != nil){
                        
                        let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: opportunity.actionInfo!.date!)
                        
                        cell.qrTypeNameLabel.text = String(format: "%@ - %@", title,date)

                    }
                    else{
                        cell.qrTypeNameLabel.text = title
                    }
                    //// *** COMMMON
                    let updateedBy = opportunity.updateBy?.last
                    var date = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updateedBy!.date!)
                    
                    if(opportunity.actionInfo!.units != nil && (opportunity.actionInfo!.units!.count > 0))
                    {
                        let unitInfo = (opportunity.actionInfo?.units?[0])
                        
                        /*
                         let floor : Floor?
                         let unitNo : Floor?
                         let _id : String?
                         let project : PROJECT?
                         let tower : QR_TOWER?
                         */
                        if(unitInfo != nil){
                            
                            commonString.append(unitInfo?.project?.name ?? "")
                            commonString.append(" | ")
                            
                            commonString.append(unitInfo?.block?.name ?? "")
                            commonString.append(" | ")
                            
                            commonString.append(unitInfo?.tower?.name ?? "")
                            commonString.append(" | ")
                            
                            commonString.append(String(format: "%d", unitInfo?.floor!.index ?? 0))
                            commonString.append(" | ")
                            
                            if(unitInfo?.type != nil){
                                commonString.append(unitInfo?.type!.name ?? "")
                                commonString.append(" | ")
                            }
                            
                            commonString.append(String(format: "%d(%@)", unitInfo?.unitNo!.index ?? "",unitInfo?.description ?? ""))
                        }
                    }
                    
                    var labelText = String()
                    
                    if(title == "Not Interested"){
                        
                        if(opportunity.actionInfo?.comment != nil){
                            if(opportunity.actionInfo!.comment!.count > 0){
                                if(labelText.count > 0){
                                    labelText.append("\n")
                                }
                                labelText.append(String(format: "Comments : %@", opportunity.actionInfo!.comment!))
                            }
                        }
                        labelText = String(format: "%@\n", opportunity.action!.label!)
                        
                        if((opportunity.updateBy?.count)! > 0){
                            let updatedBy = opportunity.updateBy![0]
                            let updatedDate = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updatedBy.date!)
                            labelText.append(contentsOf: updatedDate)
                        }
                        else{
                            let updateedBy = opportunity.updateBy?.last
                            let date = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updateedBy!.date!)
                            labelText.append(contentsOf: date)
                        }
                        cell.qrDetailsLabel.text = labelText
                        if let callHisotry = opportunity.callHistory{
                            cell.callHisotryTimeLineData = callHisotry
                        }
                        return cell
                        
                    }
                    else if(title == "Site Visit"){
                        
                        var driverName = ""
                        var vehicleName = ""
                        var projectName = ""
                        
                        let actionInfo = opportunity.actionInfo

                        if(actionInfo != nil && actionInfo?.completionDate != nil){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Completed on: %@", RRUtilities.sharedInstance.getNotificationViewDate(dateStr: actionInfo?.completionDate ?? "")))
                        }

                        if let projectId = actionInfo?.projects?.first{
                            if let projDetails = RRUtilities.sharedInstance.model.getProjectDetailsById(projectId: projectId){
                                projectName = String(format: "%@", projDetails.name ?? "")
                            }
                        }

                        if(actionInfo != nil && actionInfo?.comment != nil){
                            if(actionInfo!.comment!.count > 0){
                                if(commonString.count > 0){
                                    commonString.append("\n")
                                }
                                commonString.append(String(format: "Comments : %@", actionInfo!.comment!))
                            }
                        }
                        
                        if(actionInfo?.driver != nil){
                            if(commonString.count > 0){
                                driverName = String(format: "\nDriver : %@\n", RRUtilities.sharedInstance.model.getDriveNameUsingID(driverID: actionInfo!.driver!))
                            }
                            else{
                                driverName = String(format: "Driver : %@\n", RRUtilities.sharedInstance.model.getDriveNameUsingID(driverID: actionInfo!.driver!))
                            }
                        }
                        if(actionInfo?.vehicle != nil)
                        {
                            vehicleName = String(format: "Vehicle : %@", RRUtilities.sharedInstance.model.getVehicleNameUsingId(vehicleID: actionInfo!.vehicle!) ?? "")
                        }

                        cell.heightOfApprovalButton.constant = 0
                        cell.widthOfCheckApprovalButton.constant = 0
                        cell.checkApprovalButton.isHidden = true

                        cell.widthOfViewOfferButton.constant = 0
                        cell.heightOfViewOfferButton.constant = 0
                        cell.viewOfferButton.isHidden = true
                        cell.leadingOfViewOfferButton.constant = 0

                        cell.heightOfEditCompletionDate.constant = 20
                        cell.editCompletionDate.isHidden = false
                        cell.widthOfEditCompletionDate.constant = 200
                        cell.editCompletionDate.tag = 1
                        cell.editCompletionDate.removeTarget(nil, action: nil, for: .allEvents)
                        cell.editCompletionDate.addAction(for: .touchUpInside) { [unowned self] in
                            self.siteVistActionId = opportunity._id ?? ""
                            self.isFromOpportunitites = true
                            self.showSiteVisitDatePopUp(cell.editCompletionDate)
                        }

//                        commonString.append(projectName)
                        commonString.append(driverName)
                        commonString.append(vehicleName)
                        
                    }
                    else if(title == "Discount Request"){
                        let actionInfo = opportunity.actionInfo
                        var shouldHideApprovalButton = false

                        if(opportunity.discountAppliedStatus == DISCOUNT_REQUEST_STATES.DISCOUNT_APPLIED.rawValue){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Discount Request Status : %@", "Applied"))
                            shouldHideApprovalButton = true
                        }
                        else if(opportunity.discountAppliedStatus == DISCOUNT_REQUEST_STATES.DISCOUNT_PENDING.rawValue){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Discount Request Status : %@", "Pending"))
                        }
                        else if(opportunity.discountAppliedStatus == DISCOUNT_REQUEST_STATES.DISCOUNT_REJECTED.rawValue){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            commonString.append(String(format: "Discount Request Status : %@", "Applied"))
                            shouldHideApprovalButton = true
                        }

                        if(opportunity.actionInfo?.scheme != nil){
                            if(commonString.count > 0){
                                commonString.append("\n")
                            }
                            let schemeName = RRUtilities.sharedInstance.model.getSchemeByID(schemeID: (opportunity.actionInfo!.scheme!))
                            commonString.append(String(format: "\nScheme Applied: %@", schemeName))
                        }

                        if(actionInfo != nil && actionInfo?.comment != nil){
                            if(actionInfo!.comment!.count > 0){
                                if(commonString.count > 0){
                                    commonString.append("\n")
                                }
                                commonString.append(String(format: "Comments : %@", actionInfo!.comment!))
                            }
                        }
                        if(opportunity.updateBy?.count ?? 0 > 1){
                            if(!shouldHideApprovalButton){
                                cell.heightOfApprovalButton.constant = 18
                                cell.widthOfCheckApprovalButton.constant = 120
                                cell.leadingOfViewOfferButton.constant = 12
                                cell.checkApprovalButton.isHidden = false
                            }
                            else{
                                cell.heightOfApprovalButton.constant = 0
                                cell.widthOfCheckApprovalButton.constant = 0
                                cell.checkApprovalButton.isHidden = true
                            }
                            let arraySlice = opportunity.updateBy?.suffix(from: 1)
                            cell.discountRequestTimeLineData = Array(arraySlice!)
//                            cell.heightOfQRDetailsLabel.constant = cell.qrDetailsLabel.intrinsicContentSize.height
//                            cell.heightOfTimeLineTableView.constant = cell.timeLineTableView.contentSize.height
                            if(opportunity.actionInfo?.fileUrl != nil){
                                cell.viewOfferButton.isHidden = false
                                cell.widthOfViewOfferButton.constant = 90
                                cell.heightOfViewOfferButton.constant = 18
                                cell.leadingOfViewOfferButton.constant = 12
                                if(shouldHideApprovalButton){
                                    cell.leadingOfViewOfferButton.constant = 0
                                }
                                cell.viewOfferButton.addAction { [unowned self] in
                                    self.showOffer(offerUrl: (opportunity.actionInfo?.fileUrl)!)
                                }
                            }
                            else{
                                cell.viewOfferButton.isHidden = true
                                cell.widthOfViewOfferButton.constant = 0
                                cell.heightOfViewOfferButton.constant = 0
                            }
                        }
                        else{
                            cell.discountRequestTimeLineData = []
                            cell.heightOfApprovalButton.constant = 0
                            cell.widthOfCheckApprovalButton.constant = 0
                            cell.checkApprovalButton.isHidden = true
                            
                            if(opportunity.actionInfo?.fileUrl != nil){
                                cell.viewOfferButton.isHidden = false
                                cell.widthOfViewOfferButton.constant = 90
                                cell.heightOfViewOfferButton.constant = 18
                                cell.leadingOfViewOfferButton.constant = 0
                                cell.viewOfferButton.addAction { [unowned self] in
                                    self.showOffer(offerUrl: (opportunity.actionInfo?.fileUrl)!)
                                }
                            }
                            else{
                                cell.viewOfferButton.isHidden = true
                                cell.widthOfViewOfferButton.constant = 0
                                cell.heightOfViewOfferButton.constant = 0
                            }
                        }
                    }
                    else if(title == "Other Task"){
                        //name //status
//                        print(opportunity)
                        var taskName = ""
                        var taskStatus = ""
                        var taskDescription = ""
                        
                        let actionInfo = opportunity.actionInfo
                        
                        if(actionInfo != nil && actionInfo?.comment != nil){
                            if(actionInfo!.comment!.count > 0){
                                commonString.append(String(format: "Comments : %@", actionInfo!.comment!))
                            }
                        }
                        
                        if(opportunity.actionInfo?.taskName != nil){
                            taskName = opportunity.actionInfo!.taskName!
                        }
                        if(opportunity.actionInfo?.taskStatus != nil){
                            
                            if(opportunity.actionInfo!.taskStatus == 0){
                                taskStatus = "Open"
                            }
                            else if(opportunity.actionInfo!.taskStatus == 1){
                                taskStatus = "On Hold"
                            }
                            else if(opportunity.actionInfo!.taskStatus == 2){
                                taskStatus = "Task Assigned"
                            }
                        }
                        
                        if(opportunity.actionInfo?.taskDescription != nil)
                        {
                            taskDescription = opportunity.actionInfo!.taskDescription!
                        }
                        
                        commonString.append(contentsOf: String(format: "\nTask Name: %@", taskName))
                        commonString.append("\n")
                        if(taskDescription.count > 0){
                            commonString.append(contentsOf: String(format: "Description: %@", taskDescription))
//                            commonString.append("\n")
                        }
                        commonString.append(contentsOf: String(format: "Task Status: %@", taskStatus))
                    }
                    else if(title == "Offer")
                    {
                        let actionInfo = opportunity.actionInfo
                        
                        if(opportunity.actionInfo?.scheme != nil){
                            let schemeName = RRUtilities.sharedInstance.model.getSchemeByID(schemeID: (opportunity.actionInfo!.scheme!))
                            commonString.append(String(format: "\nScheme Applied: %@", schemeName))
                        }
                        if(actionInfo != nil && actionInfo?.comment != nil){
                            if(actionInfo!.comment!.count > 0){
                                if(commonString.count > 0){
                                    commonString.append("\n")
                                }
                                commonString.append(String(format: "Comments : %@", actionInfo!.comment!))
                            }
                        }
                        if (opportunity.actionInfo?.fileUrl) != nil{
                            
                            cell.widthOfCheckApprovalButton.constant = 0
                            cell.heightOfApprovalButton.constant = 0
                            cell.checkApprovalButton.isHidden = true
                            //                            cell.checkApprovalButton.setTitle("View Offer", for: .normal)
                            
                            cell.widthOfViewOfferButton.constant = 90
                            cell.heightOfViewOfferButton.constant = 18
                            cell.viewOfferButton.isHidden = false
                            cell.leadingOfViewOfferButton.constant = 0
                            cell.viewOfferButton.addAction(for: .touchUpInside) { [unowned self] in
                                self.showOffer(offerUrl: (opportunity.actionInfo?.fileUrl)!)
                            }
//                            cell.checkApprovalButton.tag = 1
                        }
                        else{
                            cell.heightOfApprovalButton.constant = 0
                            cell.checkApprovalButton.isHidden = true
                            cell.checkApprovalButton.setTitle("Check Approval", for: .normal)
                            cell.checkApprovalButton.tag = 0
                            
                            cell.widthOfViewOfferButton.constant = 0
                            cell.heightOfViewOfferButton.constant = 0
                            cell.viewOfferButton.isHidden = true

                        }
                    }
                    else if(title == "Call"){
                        let actionInfo = opportunity.actionInfo
                        
                        if(actionInfo != nil && actionInfo?.comment != nil){
//                            commonString.append("\n")
                            if(actionInfo!.comment!.count > 0){
                                commonString.append(String(format: "Comments : %@", actionInfo!.comment!))
                            }
                        }
                    }
                    
                    if((opportunity.updateBy?.count)! > 0){
                        let updatedBy = opportunity.updateBy![0]
                        let updatedDate = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updatedBy.date!)
                        date = updatedDate
                    }
                    else{
                        let updateedBy = opportunity.updateBy?.last
                        let date1 = RRUtilities.sharedInstance.getDateAndTimeFromDateStr(dateStr: updateedBy!.date!)
                        date = date1
                    }
                    
                    var dateStr = ""
                    if(commonString.count > 0){
                        dateStr = String(format: "\n%@", date)
                    }
                    else{
                        dateStr = date
                    }
                    commonString.append(contentsOf: dateStr)
                    
                    cell.qrDetailsLabel.text = commonString

                    if(indexPath.row == self.qrHistoryDataSource.opportunities?.count ?? 0 - 1){
                        cell.verticalLineView.isHidden = true
                    }
                    else{
                        cell.verticalLineView.isHidden = false
                    }
                    if let callHisotry = opportunity.callHistory{
                        cell.callHisotryTimeLineData = callHisotry
                    }
                    return cell
                    
                }
//                return cell
            }
            
            if(indexPath.section >= (1+self.qrHistoryDataSource.leads!.count + self.qrHistoryDataSource.opportunities!.count) && indexPath.section < (1+self.qrHistoryDataSource.leads!.count + self.qrHistoryDataSource.opportunities!.count + self.historyReEnqCount)){

                cell.qrTypeNameLabel.text = "Re-Enquiry"
                cell.qrTypeInfoLabel.text = "R"
                cell.qrTypeInfoLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "E96460")

                
                let reEnqDaata = self.qrHistoryDataSource.externalfailures![indexPath.section - (1+self.qrHistoryDataSource.leads!.count + self.qrHistoryDataSource.opportunities!.count)]

                var commonString = ""

                if let kind = reEnqDaata.reference?.kind {
                    commonString.append("Re-Enquiry from \(kind)")
                    if(reEnqDaata.efsCount ?? 0 > 0){
                        commonString.append(" (\(reEnqDaata.efsCount!))")
                    }
                    commonString.append("\n")
                }
                if let createdDate = reEnqDaata.createdAt{
                    let date = RRUtilities.sharedInstance.getHistoryCellDate(dateStr: createdDate)
                    commonString.append(date)
                }
                else{
                    cell.qrDetailsLabel.text = commonString
                }

                cell.qrDetailsLabel.text = commonString


                return cell

            }
//            if(indexPath.section > 0 && indexPath.section <= (self.qrHistoryDataSource.leads!.count + 1))
//            {
//
//                cell.qrTypeInfoLabel.text = "L"
//
//                return cell
//
//            }
//            if(indexPath.section > (1+self.qrHistoryDataSource.leads!.count) && indexPath.section < (1+self.qrHistoryDataSource.leads!.count + self.qrHistoryDataSource.opportunities!.count)){
//
//                cell.qrTypeInfoLabel.text = "O"
//
//                return cell
//
//            }
            
            
            return cell
            
        }
        
        let cell : CustomerDetailsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "cusDetailsCell",
            for: indexPath) as! CustomerDetailsTableViewCell
        
//        let prospect = self.tableViewDataSourceArray[indexPath.row]
//        cell.nameLabel.text = "prospect.userName"
        
        let key = orderedKeyDetails[indexPath.row] as! String
        cell.headingLabel.text = key
        cell.contentLabel.text = prospectsDataSourceDict[key]
        return cell
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if(tableView == self.tableView){
            if(section == 0){
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FiltersSectionHeaderView") as! FiltersSectionHeaderView

                headerView.headerTitleLabel.text = "Timeline"
                        
                headerView.indicatorImageView.isHidden = true
                
                headerView.headerTitleLabel.font = UIFont.init(name: "Montserrat-Bold", size: 15)
                headerView.headerTitleLabel.textAlignment = .left
                headerView.headerTitleLabel.textColor = UIColor.hexStringToUIColor(hex: "9B9B9B")
                headerView.subContentView.backgroundColor = UIColor.hexStringToUIColor(hex: "ffffff")
//                headerView.subContentView.tag = section
                return headerView
            }
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(tableView == self.tableView){
            if(section == 0){
                return 50
            }
        }
        return 0
    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//
//        if(tableView == self.tableView){
//            return 0
//        }
//
//        if(tableView == self.historyTableView){
//
////            let prospect =
//
//            print(section)
//
//            if(section == 0){
//
//                let registration : QR_REGISTRATIONS = self.qrHistoryDataSource.quickregistrations!
//                if(registration.idleDate != nil){
//                    return 50
//                }
//                else{
//                    return 0
//                }
//
//            }
//            if(section > 0 && section < (1+self.qrHistoryDataSource.leads!.count)){
//
//                let lead = self.qrHistoryDataSource.leads![section - 1]
//
//                if(lead.idleDate != nil){
//                    return 50
//                }
//                else{
//                    return 0
//                }
//            }
//
//            if(section >= (1+self.qrHistoryDataSource.leads!.count) && section < (1+self.qrHistoryDataSource.leads!.count + self.qrHistoryDataSource.opportunities!.count)){
//
//                let opportunity = self.qrHistoryDataSource.opportunities![section - (1+self.qrHistoryDataSource.leads!.count)]
//
//                if(opportunity.idleDate != nil){
//                    return 50
//                }
//                else{
//                    return 0
//                }
//
//            }
//
//            return 0
//        }
//
//        return 0
//    }
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//
//        if(tableView == self.tableView){
//            return nil
//        }
//
//        if(tableView == self.historyTableView){
//
////            let prospect =
//
//            print(section)
//
//            if(section == 0){
//
//                let registration : QR_REGISTRATIONS = self.qrHistoryDataSource.quickregistrations!
//                if(registration.idleDate != nil){
//                    let tempView = UIView()
//                    tempView.backgroundColor = .lightGray
//                    return tempView
//                }
//                else{
//                    return nil
//                }
//
//            }
//            if(section > 0 && section < (1+self.qrHistoryDataSource.leads!.count)){
//
//            }
//
//            let tempView = UIView()
//            tempView.backgroundColor = .lightGray
//            return tempView
//        }
//
//        return nil
//    }

//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if(section == 0){
//            return "Timeline"
//        }
//        else{
//            return ""
//        }
//    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func showSiteVisitDatePopUp(_ sender : UIButton){
        
//        print("showSiteVisitDatePopUp")
        if(isFromDatePopUp){
            return
        }
        isFromDatePopUp = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "datePicker") as! DatePickerViewController
        
        vc.shouldSetDateLimit = false
        vc.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 300)
        vc.delegate = self
        vc.selectedFieldTag = sender.tag

        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false
        fpc.surfaceView.grabberHandleHeight = 0.0
        fpc.delegate = self
        
        fpc.set(contentViewController: vc)
        
        fpc.isRemovalInteractionEnabled = false // Optional: Let it removable by a swipe-down
            
        vc.datePickerInfoView?.backgroundColor = .white
        vc.datePickerInfoLabel.text = "Select Completion Date and Time"
        vc.datePicker.datePickerMode = .date
        vc.buttonsView.backgroundColor = .white
        vc.shouldShowTime = true
        vc.cancelButton.setTitle("CANCEL", for: .normal)
        vc.doneButton.setTitle("OK", for: .normal)

        self.present(fpc, animated: true, completion: nil)

    }
    @objc func showDatePicker(){
        //Formate Date
        
    }
    func showOffer(offerUrl : String){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let offerPreview = storyboard.instantiateViewController(withIdentifier :"webView") as! WebViewController
        offerPreview.isPreViewOffer = true
//        offerPreview.delegate = self
        offerPreview.selectedProspect = self.prospectDetails
        
        if(offerUrl.contains("?")){
//            previewOfferUrl.index
            
            if let index = offerUrl.firstIndex(of: "?"){
                
//                print(index)
                let subStr = offerUrl.prefix(upTo: index)
                
                let tempStr = String(subStr)
                
                    let locSignedUrl = ServerAPIs.getSingleSingedUrl(url: tempStr)
                        
                offerPreview.previewOfferUrlString = locSignedUrl

                DispatchQueue.main.async {
                    let navController = UINavigationController(rootViewController: offerPreview)
                    navController.modalPresentationStyle = .fullScreen
                    navController.navigationBar.isHidden = true
                    self.present(navController, animated: true, completion: nil)
                }
            }
        }
        else{
            
            DispatchQueue.global().async {
                
                let signedUrl = ServerAPIs.getSingleSingedUrl(url: offerUrl)
                
                offerPreview.previewOfferUrlString = signedUrl
        //        offerPreview.selectedProspect = self.selectedProspect

                DispatchQueue.main.async {
                    let navController = UINavigationController(rootViewController: offerPreview)
                    navController.modalPresentationStyle = .fullScreen
                    navController.navigationBar.isHidden = true
                    self.present(navController, animated: true, completion: nil)
                }
            }

        }

        
        
    }
    @objc func showApprovalsView(_ sender: UIButton){
        
        let discountApprovalsController = DiscountApprovalsViewController(nibName: "DiscountApprovalsViewController", bundle: nil)
        discountApprovalsController.approvalType = APPROVAL_TYPES.DISCOUNT_APPROVAL
        discountApprovalsController.isFromProspects = true
        discountApprovalsController.prospectUserName = self.prospectDetails.userName
        self.navigationController?.pushViewController(discountApprovalsController, animated: true)
    }

    // MARK: - ACTIONS
    func didFinishEdit(prospect: REGISTRATIONS_RESULT) {
        
        self.prospectDetails.userEmail = prospect.userEmail
        self.prospectDetails.userName = prospect.userName
        self.prospectDetails.userPhone = prospect.userPhone
        self.prospectDetails.userPhoneCode = prospect.userPhoneCode
        self.prospectDetails.leadStatus = prospect.leadStatus
        self.prospectDetails.enquirySource = prospect.enquirySource
        self.prospectDetails.enquirySourceId = prospect.enquirySourceId
        self.prospectDetails.comment = prospect.comment
        self.prospectDetails.alternatePhone = prospect.alternatePhone
        self.prospectDetails.alternatePhoneCode = prospect.alternatePhoneCode
        self.prospectDetails.isCommissionApplicable = prospect.isCommissionApplicable
        self.prospectDetails.commissionEntity = prospect.commissionEntity
        
        nameLabel.text = prospectDetails.userName
        phoneNumberLabel.text = String(format: "%@ %@",prospectDetails.userPhoneCode != nil ? String(format: "+%@", prospectDetails.userPhoneCode!) :  "",prospectDetails.userPhone!)
        emailLabel.text = prospectDetails.userEmail
        
        if((prospectDetails.alternatePhone == nil || prospectDetails.alternatePhone?.count ?? 0 == 0)){
            heightOfAlternatePhoneNumberView.constant = 0
            alternatePhoneNumberView.isHidden = true
        }
        else{
            heightOfAlternatePhoneNumberView.constant = 53
            alternatePhoneNumberView.isHidden = false
            
            self.alternateNumberLabel.text = String(format: "%@ %@",prospectDetails.alternatePhoneCode != nil ? String(format: "+%@", prospectDetails.alternatePhoneCode!) :  "",prospectDetails.alternatePhone!)
        }
        
        leadClassificationLabel.text = prospectDetails.leadStatus?.uppercased()
        prospectsDataSourceDict["Enquiry Source"] = prospectDetails.enquirySource
        prospectsDataSourceDict["Comments"] = prospectDetails.comment
    }
    @IBAction func editRegistration(_ sender: Any) {
        
//        let editRegController = EditRegistrationViewController(nibName: "EditRegistrationViewController", bundle: nil)
//        editRegController.prospectDetails = prospectDetails
        
        if(!PermissionsManager.shared.isEmployeePermitted(moduleName: Permission_Names.PROSPECTS.rawValue, permissionType: UserRolePermissions.EDIT.rawValue, employeeID: self.prospectDetails.salesPerson?._id ?? "")){
            HUD.flash(.label(STRINGS.Access_Forbidden), delay: 1.0)
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerController = storyboard.instantiateViewController(withIdentifier :"registration") as! RegistrationViewController
        registerController.prospectDetails = prospectDetails
        registerController.viewType = self.viewType
        registerController.isEditingRegistration = true
        registerController.delegate = self
        self.navigationController?.pushViewController(registerController, animated: true)
        return
    }
    
    @IBAction func showStatusHandler(_ sender: Any) {
        
//        print(prospectDetails)
        
        if(statusID == 4)  ///discount view
        {
            //discountRequest
            if(isFromLeads){
                if(prospectDetails.discountApplied == 1 || prospectDetails.discountApplied == 2){ //Discount applied & pending
                    
                    // Show prospect as radio Button
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
                    statusController.tabID = self.tabId
                    statusController.viewType = self.viewType
                    statusController.prospectDetails = prospectDetails
                    statusController.isFromRegistrations = self.isFromRegistrations
                    statusController.isFromDiscountView = self.isFromDiscountView
                    statusController.isFromNotification = self.isFromNotification
                    statusController.statusID = self.statusID
                    statusController.viewType = self.viewType
                    //        self.navigationController?.pushViewController(statusController, animated: true)
                    //            let tempNavigator = UINavigationController.init(rootViewController: statusController)
                    
                    //                if(isLeads){
                    //                    statusController.viewType = VIEW_TYPE.LEADS
                    //                }
                    //                else{
                    //                    statusController.viewType = VIEW_TYPE.OPPORTUNITIES
                    //                }
                    
                    self.present(statusController, animated: true, completion: nil)
                    return
                    // show send offer
                    // SendOfferPopUpViewController
                }
                else{ //not applied
                    self.getHistoryOfQuickRegistration()
                    self.getDiscountDetailsOfUnit()
                    return
                }
            }
            else{
                
                if(prospectDetails.discountApplied == 3){ //Rejected state
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
                    
                    //        leadsPopUpController.prevSelectedStatus = selectedStatus
                    //        leadsPopUpController.selectedReasonIndex = selectedIndexPath.row
                    //        leadsPopUpController.selctedScheduleCallOption = selectedIndexPath.row
                    leadsPopUpController.isFromRegistrations = self.isFromRegistrations
                    leadsPopUpController.isFromDiscountView = self.isFromDiscountView
                    leadsPopUpController.tabId = self.tabId
                    leadsPopUpController.statusID = self.statusID
                    leadsPopUpController.prospectDetails = self.prospectDetails
                    leadsPopUpController.viewType = self.viewType
                    leadsPopUpController.isFromNotification = self.isFromNotification
                    self.present(leadsPopUpController, animated: true, completion: nil)
                }
                else{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
                    statusController.tabID = self.tabId
                    statusController.isFromDiscountView = self.isFromDiscountView
                    statusController.viewType = self.viewType
                    statusController.isFromNotification = self.isFromNotification
                    statusController.prospectDetails = prospectDetails
                    statusController.isFromRegistrations = self.isFromRegistrations
                    statusController.statusID = self.statusID
                    statusController.viewType = self.viewType
                }
            }
        }
        if(statusID == 6){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
            
            //        leadsPopUpController.prevSelectedStatus = selectedStatus
            //        leadsPopUpController.selectedReasonIndex = selectedIndexPath.row
            //        leadsPopUpController.selctedScheduleCallOption = selectedIndexPath.row
            leadsPopUpController.isFromRegistrations = false
            leadsPopUpController.tabId = self.tabId
            leadsPopUpController.isFromDiscountView = self.isFromDiscountView
            leadsPopUpController.statusID = self.statusID
            leadsPopUpController.prospectDetails = self.prospectDetails
            leadsPopUpController.isFromNotification = self.isFromNotification
            leadsPopUpController.viewType = self.viewType
            self.present(leadsPopUpController, animated: true, completion: nil)
            return

        }
        if(prospectDetails.action?.id != nil){  // launch new navigation controller?
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
            statusController.tabID = self.tabId
            statusController.viewType = self.viewType
            statusController.isFromDiscountView = self.isFromDiscountView
            statusController.prospectDetails = prospectDetails
            statusController.isFromRegistrations = self.isFromRegistrations
            statusController.statusID = self.statusID
            statusController.isFromNotification = self.isFromNotification
            //        self.navigationController?.pushViewController(statusController, animated: true)
            statusController.viewType = self.viewType
            self.present(statusController, animated: true, completion: nil)
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let statusController = storyboard.instantiateViewController(withIdentifier :"prospectStatusController") as! ProspectsStatusViewController
            statusController.tabID = self.tabId
            statusController.viewType = self.viewType
            statusController.isFromDiscountView = isFromDiscountView
            statusController.prospectDetails = prospectDetails
            statusController.isFromNotification = self.isFromNotification
            statusController.isFromRegistrations = self.isFromRegistrations
            statusController.statusID = self.statusID
            statusController.viewType = self.viewType
            //        self.navigationController?.pushViewController(statusController, animated: true)
            
//            let tempNavigator = UINavigationController.init(rootViewController: statusController)

            self.present(statusController, animated: true, completion: nil)
        }
    }
    // MARK: -

    @IBAction func close(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        
        if(prospectDetails.userEmail != nil){
            
            let emailer = String(format: "mailto:%@", prospectDetails.userEmail!)
            let url = URL(string: emailer)
            UIApplication.shared.open(url!)
        }
    }
    
    @IBAction func openWhatsapp(_ sender: Any) {
        
        var tempCode = ""
        if let phoneCode = prospectDetails.userPhoneCode{
            if(phoneCode.count > 0){
                tempCode = phoneCode
            }
            else
            {
                tempCode = "91"
            }
        }
        else{
            tempCode = "91"
        }
                
        let selectedRegistration  = (prospectDetails.userPhone!.count > 10) ? prospectDetails.userPhone! : tempCode + prospectDetails.userPhone!

        guard let number = URL(string: String(format: "https://wa.me/%@", selectedRegistration))else{return}
        UIApplication.shared.open(number)

    }
    @IBAction func openWhatsappForAlternateNumber(_ sender: Any) {
        
        var tempCode = ""
        if let phoneCode = prospectDetails.userPhoneCode{
            if(phoneCode.count > 0){
                tempCode = phoneCode
            }
            else
            {
                tempCode = "91"
            }
        }
        else{
            tempCode = "91"
        }
        let selectedRegistration  = (prospectDetails.userPhone!.count > 10) ? prospectDetails.userPhone! : tempCode + prospectDetails.userPhone!
        guard let number = URL(string: String(format: "https://wa.me/%@?text=%@", selectedRegistration,""))else{return}
        UIApplication.shared.open(number)
    }
    
    @IBAction func callAlternateNumber(_ sender: Any) {
            
            guard let number = prospectDetails.alternatePhone else { return }
    //        UIApplication.shared.open(number)
            
            if(isFromRegistrations){
                ServerAPIs.prospectCall(viewType:VIEW_TYPE.REGISTRATIONS.rawValue , prospectId: prospectDetails._id!, custNumber: number, exeNumber: prospectDetails?.salesPerson?.phone ?? "",completion: { result in
                    switch result {
                    case .success(let result):
                            HUD.flash(.label(result.msg), delay: 2.0)
                    case .failure( _):
                        guard let url = URL(string: "telprompt://" + number) else { return }
                        UIApplication.shared.open(url)
                    }
                })
            }
            else if(isFromLeads){
                ServerAPIs.prospectCall(viewType:VIEW_TYPE.LEADS.rawValue , prospectId: prospectDetails._id!, custNumber: number, exeNumber: prospectDetails?.salesPerson?.phone ?? "",completion: { result in
                    switch result {
                    case .success(let result):
                        HUD.flash(.label(result.msg), delay: 2.0)
                    case .failure( _):
                        guard let url = URL(string: "telprompt://" + number) else { return }
                        UIApplication.shared.open(url)
                    }
                })
            }
            else{
                ServerAPIs.prospectCall(viewType:VIEW_TYPE.OPPORTUNITIES.rawValue , prospectId: prospectDetails._id! , custNumber: number, exeNumber: prospectDetails?.salesPerson?.phone ?? "",completion: { result in
                    switch result {
                    case .success(let result):
                        HUD.flash(.label(result.msg), delay: 2.0)
                    case .failure( _):
                        guard let url = URL(string: "telprompt://" + number) else { return }
                        if(UIApplication.shared.canOpenURL(url)){
                            UIApplication.shared.open(url)
                        }
                    }
                })
            }

        }
    @IBAction func call(_ sender: Any) {
        
        guard let number = prospectDetails.userPhone else { return }
//        UIApplication.shared.open(number)
        
        if(isFromRegistrations){
            ServerAPIs.prospectCall(viewType:VIEW_TYPE.REGISTRATIONS.rawValue , prospectId: prospectDetails._id!, custNumber: number, exeNumber: prospectDetails?.salesPerson?.phone ?? "",completion: { result in
                switch result {
                case .success(let result):
                        HUD.flash(.label(result.msg), delay: 2.0)
                case .failure( _):
                    guard let url = URL(string: "telprompt://" + number) else { return }
                    UIApplication.shared.open(url)
                }
            })
        }
        else if(isFromLeads){
            ServerAPIs.prospectCall(viewType:VIEW_TYPE.LEADS.rawValue , prospectId: prospectDetails._id!, custNumber: number, exeNumber: prospectDetails?.salesPerson?.phone ?? "",completion: { result in
                switch result {
                case .success(let result):
                    HUD.flash(.label(result.msg), delay: 2.0)
                case .failure( _):
                    guard let url = URL(string: "telprompt://" + number) else { return }
                    UIApplication.shared.open(url)
                }
            })
        }
        else{
            ServerAPIs.prospectCall(viewType:VIEW_TYPE.OPPORTUNITIES.rawValue , prospectId: prospectDetails._id! , custNumber: number, exeNumber: prospectDetails?.salesPerson?.phone ?? "",completion: { result in
                switch result {
                case .success(let result):
                    HUD.flash(.label(result.msg), delay: 2.0)
                case .failure( _):
                    guard let url = URL(string: "telprompt://" + number) else { return }
                    if(UIApplication.shared.canOpenURL(url)){
                        UIApplication.shared.open(url)
                    }
                }
            })
        }

    }
    
    func getHistoryOfQuickRegistration(){
//        String(format:RRAPI.PROJECT_DETAILS, projecct.id!)
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            //** if fetched data is there show that **
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        HUD.show(.progress)
        
        var id = ""
        
        if(prospectDetails.regInfo != nil)
        {
            id = prospectDetails.regInfo ?? ""
        }
        else{
            id = prospectDetails._id ?? ""
        }
        
        let urlString = String(format: RRAPI.API_GET_QR_HISTORY, id,self.prospectDetails.userPhone ?? "")
        
        print(urlString)
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
//                let str = String(data: response.data!, encoding: .utf8)
//                print(str!)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                //SEARCH_RESULT
                HUD.hide()
                
                do{
                    
                    let urlResult = try JSONDecoder().decode(QR_HISTORY_OUTPUT.self, from: responseData)
                    
                    if(urlResult.status == 1){ // success
                        self.qrHistoryDataSource = urlResult.data
                        
//                        let callhist = self.qrHistoryDataSource.quickregistrations?.callHistory
                        
                        //                    self.makeHistoryTableViewDataSource()
                        
                        self.historyReEnqCount = self.qrHistoryDataSource.externalfailures?.count ?? 0
                        self.historyTableView.delegate = self
                        self.historyTableView.dataSource = self
                        //                    let totalRows = self.qrHistoryDataSource.opportunities!.count + self.qrHistoryDataSource.leads!.count + 1
                        self.historyTableView.reloadData()
                        //                    self.historyTableView.sizeToFit()
                        
                        //                    self.historyTableView.reloadData()
                        //                    self.historyTableView.layoutIfNeeded()
                        
                        //                    self.historyTableView.updateConstraintsIfNeeded()
                        
                        //                    self.tableView.reloadData()
                        self.historyTableView.reloadData()
                        
                        //                    self.tableView.layoutIfNeeded()
                        //                    print(self.historyTableView.contentSize.height)
                        //
                        //                    self.perform(#selector(self.reloadHistoryTableView), with: nil, afterDelay: 0.6)
                        //
                        if(self.qrHistoryDataSource.quickregistrations?.leadStatus != nil && (self.qrHistoryDataSource.quickregistrations?.leadStatus!.count)! > 0){
                            self.leadClassificationLabel.text = self.qrHistoryDataSource.quickregistrations?.leadStatus?.uppercased()
                        }
                        else{
                            self.heightOfUserDetailsView.constant = self.heightOfUserDetailsView.constant - 53
                            self.heightOfLeadClassfication.constant = 0
                            self.leadClassificationView.isHidden = true
                        }
                        self.heightOfHistoryTableView.constant = self.historyTableView.contentSize.height
                        //                    self.heightOfTableView.constant = self.tableView.contentSize.height
                        
//                        DispatchQueue.main.async {
//                            let allSectionsCount = (1 + self.qrHistoryDataSource.leads!.count + self.qrHistoryDataSource.opportunities!.count)
//                            self.historyTableView.scrollToRow(at: IndexPath.init(row: 0, section: allSectionsCount-1), at: .top, animated: true)
//                            sleep(UInt32(0.5))
//                            self.historyTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
//                            self.scrollViewDidScroll(UIScrollView())
//                        }
//                        self.scrollViewDidScroll(UIScrollView())
                        
                        //                    self.historyTableView.scrollToRow(at: <#T##IndexPath#>, at: <#T##UITableView.ScrollPosition#>, animated: <#T##Bool#>)
                        
                        //                    self.historyTableView.layoutIfNeeded()
                        //                    self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.historyTableView.contentSize.height + self.tableView.contentSize.height + 140)
                        //                    self.scrollViewContentView.layoutSubviews()
                        ////                    self.heightOfScrollViewContentView.constant = self.scrollView.contentSize.height
                        //                    self.scrollView.layoutSubviews()
                        //                    self.scrollViewContentView.layoutIfNeeded()
                        //                    self.view.layoutIfNeeded()
                        //                    self.scrollViewContentView.setNeedsDisplay()
                        //                    self.scrollView.reloadInputViews()
                        //                    self.historyTableView.setNeedsLayout()
                    }
                    else if(urlResult.status == -1){
                        
                    }
                    else if(urlResult.status == 0){
                        //                    HUD.flash(.label(urlResult.err), delay: 1.0)
                    }
                    
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                // make tableview data
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    @objc func reloadHistoryTableView(){
        return
        let tempInexPath = IndexPath.init(row: 0, section: 0)
//        self.historyTableView.scrollToRow(at: tempInexPath, at: .bottom, animated: true)
        //scroll to first index path
        if(self.qrHistoryDataSource.leads != nil &&  self.qrHistoryDataSource.leads!.count > 0){
            let lastIndexPath = IndexPath.init(row: self.qrHistoryDataSource.leads!.count-1, section: 1)
            self.historyTableView.reloadRows(at: [lastIndexPath], with: .automatic)
        }
        if(self.qrHistoryDataSource.opportunities != nil &&  self.qrHistoryDataSource.opportunities!.count > 0){
            let lastIndexPath = IndexPath.init(row: self.qrHistoryDataSource.opportunities!.count-1, section: 2)
            self.historyTableView.reloadRows(at: [lastIndexPath], with: .automatic)
        }
        self.heightOfHistoryTableView.constant = self.historyTableView.contentSize.height
        
        let tempInexPath1 = IndexPath.init(row: 0, section: 0)
//        self.historyTableView.scrollToRow(at: tempInexPath1, at: .top, animated: true)
    }
    func getDiscountDetailsOfUnit(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            //** if fetched data is there show that **
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        let tempUnits = prospectDetails.actionInfo?.units
        let counter = tempUnits?.count
        
        var unitDetails : UNITS!
        
        if(counter! > 0){
             unitDetails = (prospectDetails.actionInfo?.units![0])!
        }
        
        if(unitDetails == nil){
            HUD.flash(.label("No Unit ID to get billing info"), delay: 1.0)
            return
        }
        
        HUD.show(.progress)
        
        let urlString = String(format: RRAPI.API_GET_UNIT_PRICE, unitDetails._id ?? "")
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                //SEARCH_RESULT
                HUD.hide()
                
                do{
                    let urlResult = try JSONDecoder().decode(UNIT_PRICE_API_RESULT.self, from: responseData)
                    
                    if(urlResult.status == 1){ // success
                        //                    HUD.flash(.label("Success"), delay: 1.0)
                        //                    self.dismiss(animated: true, completion: nil)
                        
                        let discountRequestController = DiscountViewController(nibName: "DiscountViewController", bundle: nil)
                        discountRequestController.prospectDetails = self.prospectDetails
                        discountRequestController.viewType = self.viewType
                        discountRequestController.isFromRegistrations = self.isFromRegistrations
                        discountRequestController.statusID = self.statusID
                        discountRequestController.unitBillingInfo = urlResult.result
                        discountRequestController.delegate = self
                        self.showDiscountView(controller: discountRequestController)
                    }
                    else
                    {
                        HUD.flash(.label(urlResult.err), delay: 1.0)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                // make tableview data
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    //MARK: - FLOAT PANEL BEGIN
    @objc func moveFpcViewToFull() {
        fpc.move(to: .full, animated: true)
    }
    func showDiscountView(controller : DiscountViewController){
        isFromDatePopUp = false
        fpc.surfaceView.cornerRadius = 6.0
        fpc.surfaceView.shadowHidden = false
        
        fpc.delegate = self
        
        fpc.set(contentViewController: controller)
        
        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        
        fpc.track(scrollView: controller.scrollView)
        
        self.present(fpc, animated: true, completion: nil)
    }
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        if(isFromDatePopUp){
            return HalfFloatingPanelLayout(parent: self)
        }
        return  CustomPanelLayout(parent: self)
    }
    //MARK: - FLOAT PANEL END
    func shouldShowStatusChangeView()->Bool{
        
        if(PermissionsManager.shared.isPresalesEditPermitted()){//(self.prospectDetails.salesPerson != nil && PermissionsManager.shared.isEmployePermittedForPresales(employeeID: (self.prospectDetails.salesPerson?._id ?? ""))){
            return true
        }
        else{
            return false
        }
    }
    @objc func showStatusChangeView(){
        
        if(!self.shouldShowStatusChangeView()){
            return
        }
        statusChangeView = (StatusChangeView.instanceFromNib() as! StatusChangeView)
        
        let attributedString = NSAttributedString(
            string:"Change",
            attributes:[
                NSAttributedString.Key.font :UIFont.init(name: "Montserrat-Medium", size: 14) as Any,
                NSAttributedString.Key.foregroundColor : UIColor.hexStringToUIColor(hex: "358ED7"),
                NSAttributedString.Key.underlineStyle:1.0
            ])

        statusChangeView.statusChangeButton.setAttributedTitle(attributedString, for: .normal)
        statusChangeView.salesPersonChangeButton.setAttributedTitle(attributedString, for: .normal)

        let prospectDetails  = self.prospectDetails //self.currentTableViewDataSourceArray[tag!]
        self.view.addSubview(self.statusChangeView)
        self.statusChangeView.alpha = 0.0
        
        if(tabId != 2 || (isFromSummaryView && !isFromUserTab)){
            statusChangeView.HLineView.isHidden = true
            statusChangeView.salesPersonView.isHidden = true
            statusChangeView.salesPersonViewHeight.constant = 0
            statusChangeView.frame = CGRect(x: 0, y: self.view.frame.height - 70, width: self.view.frame.size.width, height: 50)
//            bottomConstraintOfTableView.constant = 70
        }
        else{ //Sales person wise
            statusChangeView.frame = CGRect(x: 0, y: self.view.frame.height - 120, width: self.view.frame.size.width, height: 101)
//            bottomConstraintOfTableView.constant = 140

            statusChangeView.salesPersonChangeButton.addTarget(self, action:#selector(showSalePersonChangeView), for: .touchUpInside)
//            statusChangeView.salesPersonChangeButton.tag = tag!
            
            if(prospectDetails!.salesPerson?.userInfo?.name != nil){
                statusChangeView.salesPersonNameLabel.text = prospectDetails!.salesPerson?.userInfo?.name
            }
            else{
                statusChangeView.salesPersonNameLabel.text = "Super Admin"
            }
        }
        statusChangeView.subContentView.layer.cornerRadius = 8
        
        UIView.animate(withDuration: 1.0, animations: {
            self.statusChangeView.alpha = 1.0
        })
        
        if(prospectDetails!.action != nil){
            statusChangeView.currentStatusLabel.text = RRUtilities.sharedInstance.getTimelineLabel(label: prospectDetails!.action?.label ?? "")
        }
        else{
            statusChangeView.currentStatusLabel.text = "None"
        }
        
        statusChangeView.statusChangeButton.addTarget(self, action:#selector(showStatusHandler(_:)), for: .touchUpInside)
        statusChangeView.statusChangeButton.titleLabel!.font = UIFont(name: "Montserrat-Regular", size: 18)
        statusChangeView.salesPersonChangeButton.titleLabel!.font = UIFont(name: "Montserrat-Regular", size: 18)
//        statusChangeView.statusChangeButton.tag = tag!
//        statusChangeView.salesPersonChangeButton.tag = tag!
        let tapStatusGuesture = UITapGestureRecognizer.init(target: self, action: #selector(showStatusHandler))
        let tapSalesGuesture = UITapGestureRecognizer.init(target: self, action: #selector(showSalePersonChangeView))
        statusChangeView.statusChangeView.addGestureRecognizer(tapStatusGuesture)
        statusChangeView.salesPersonView.addGestureRecognizer(tapSalesGuesture)

    }
    @objc func showSalePersonChangeView(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let salesPersonChangeController = storyboard.instantiateViewController(withIdentifier :"salesPersonChange") as! SalesPersonChangeViewController
        
        salesPersonChangeController.viewType = self.viewType
        
//        if(isFromRegistrations){
//            salesPersonChangeController.viewType = VIEW_TYPE.REGISTRATIONS
//        }
//        else{
        
//            if(isFromLeads){
//                salesPersonChangeController.viewType = VIEW_TYPE.LEADS
//            }
//            else{
//                salesPersonChangeController.viewType = VIEW_TYPE.OPPORTUNITIES
//            }
//        }
        
        
        salesPersonChangeController.selectedProspect = self.prospectDetails
        
        //self.currentTableViewDataSourceArray[statusChangeView.salesPersonChangeButton.tag]
        
        self.present(salesPersonChangeController, animated: true, completion: nil)
        
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.historyTableView.reloadData()
        self.collectionView.reloadData()

//        self.collectionView.reloadData()
//        self.heightOfHistoryTableView.constant = self.historyTableView.contentSize.height
//        self.heightOfCollectionView.constant = self.collectionView.contentSize.height
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        self.collectionView.layoutIfNeeded()
        self.heightOfHistoryTableView.constant = self.historyTableView.contentSize.height
        self.heightOfCollectionView.constant = self.collectionView.contentSize.height
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.collectionView.layoutIfNeeded()
        self.heightOfHistoryTableView.constant = self.historyTableView.contentSize.height
        self.heightOfCollectionView.constant = self.collectionView.contentSize.height
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.historyTableView.reloadData()
        self.collectionView.reloadData()
    }
//
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CustomerDetailsViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    //UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderedKeyDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : ProspectDetailsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "prospectDetails", for: indexPath) as! ProspectDetailsCollectionViewCell
        
        let key = orderedKeyDetails[indexPath.row] as! String
        cell.headingLabel.text = key
        cell.contentLabel.text = prospectsDataSourceDict[key]
        
        cell.widthOfSubContentView.constant = (self.collectionView.frame.size.width - 50 ) / 2.0
//        cell.widthOfStackView.constant = cell.widthOfSubContentView.constant
    
        cell.contentView.layoutIfNeeded()
        
//        cell.contentLabel.backgroundColor = .red
        return cell
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let itemWidth = (collectionView.bounds.size.width - 40) / 2
//        return CGSize(width: itemWidth, height: 100)
//    }
}
extension CustomerDetailsViewController : AudioPlayDelegate{
    
    func didSelectAudioButtoin(selectedUrl: String) {

        do {
            HUD.show(.progress)
            _ = try Data(contentsOf: URL(string: selectedUrl)!)
            
            let videoURL = URL(string: selectedUrl)
            let player = AVPlayer(url: videoURL!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            HUD.hide()
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }

        } catch {
            print("Unable to load data: \(error)")
            HUD.flash(.label("Audio file expired"), delay: 1.0)
        }
    }
}
extension CustomerDetailsViewController : DateSelectedFromPicker{
    func didSelectDate(optionType: Date, optionIndex: Int) {
        
        if(optionIndex == -1){
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        /*
         requestBody.put("id", mItem._id)
         requestBody.put("section", if (mItem.actionType == ActionHistory.ACTION_HISTORY_LEADS) "L" else "O")
         requestBody.put("date", DateTimeSelection.dateMillis)
         */
        
        let dateStr = RRUtilities.sharedInstance.getServerDateTimeFromDate(date: optionType)
        isFromDatePopUp = false
        var parameters : Dictionary<String,Any> = [:]
        parameters["id"] = self.siteVistActionId
        parameters["date"] = dateStr
        
        
        
        if(self.isFromOpportunitites){
            parameters["section"] = "O"
        }
        else{
            parameters["section"] = "L"
        }
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        self.dismiss(animated: true, completion: nil)

        HUD.show(.progress, onView: self.view)
        ServerAPIs.updateSiteVisitedDate(parameters: parameters, completion: { [unowned self] result in
            HUD.hide()
            switch result {
            case .success(let result):
                self.getHistoryOfQuickRegistration()
                let resultStr = result ? "Completion Date edited succesfully" : "Faild to add Completion Date"
                HUD.flash(.label(resultStr), delay: 1.5)
                break
            case .failure(let error):
                HUD.flash(.label(error.localizedDescription), delay: 1.0)
                break
            }
        })
        
    }
}

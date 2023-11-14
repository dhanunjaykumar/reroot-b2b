//
//  QRHistoryTableViewCell.swift
//  ReRoot
//
//  Created by Dhanunjay on 26/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit


protocol AudioPlayDelegate : class {
    func didSelectAudioButtoin(selectedUrl : String)
}
extension AudioPlayDelegate{
    func didSelectAudioButtoin(selectedUrl : String)
    {
    }
}
class QRHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var heightOfUrlTableView: NSLayoutConstraint!
    @IBOutlet weak var urlTableView: UITableView!
    @IBOutlet weak var bottomConstraintOfIdleSubView: NSLayoutConstraint!
    @IBOutlet weak var topConstraintOfIdleView: NSLayoutConstraint!
    @IBOutlet weak var idleTypeLabel: UILabel!
    @IBOutlet weak var idleSubHeadLabel: UILabel!
    @IBOutlet weak var idleHeadLabel: UILabel!
    @IBOutlet weak var heightOfIdleSubView: NSLayoutConstraint!
    @IBOutlet weak var idleSubView: UIView!
    @IBOutlet weak var subContentView: UIView!
    @IBOutlet weak var heightOfStateLabelView: NSLayoutConstraint!
    @IBOutlet weak var heightOfEditCompletionDate: NSLayoutConstraint!
    @IBOutlet weak var widthOfEditCompletionDate: NSLayoutConstraint!
    @IBOutlet weak var editCompletionDate: UIButton!
    @IBOutlet weak var leadingOfViewOfferButton: NSLayoutConstraint!
    @IBOutlet weak var heightOfViewOfferButton: NSLayoutConstraint!
    @IBOutlet weak var widthOfViewOfferButton: NSLayoutConstraint!
    @IBOutlet weak var viewOfferButton: UIButton!
    @IBOutlet weak var widthOfCheckApprovalButton: NSLayoutConstraint!
    @IBOutlet weak var heightOfApprovalButton: NSLayoutConstraint!
    @IBOutlet weak var checkApprovalButton: UIButton!
    weak var delegate : AudioPlayDelegate!
    @IBOutlet weak var heightOfQRDetailsLabel: NSLayoutConstraint!
    @IBOutlet weak var qrTypeInfoLabel: UILabel!
    @IBOutlet weak var qrDetailsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var qrTypeNameLabel: UILabel!
    @IBOutlet weak var timeLineTableView: UITableView!
    @IBOutlet weak var heightOfTimeLineTableView: NSLayoutConstraint!
    @IBOutlet weak var verticalLineView: UIView!
    let yourAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Montserrat-Medium", size: 14)!,
        .underlineStyle: NSUnderlineStyle.single.rawValue]

    var callHisotryTimeLineData : [CALL_HISTORY] = []{
        didSet{
            timeLineTableView.dataSource = self
            timeLineTableView.delegate = self
            timeLineTableView.reloadData()
        }
    }
    var discountRequestTimeLineData : [UpdatedByForProspects] = []{
        didSet{
            timeLineTableView.dataSource = self
            timeLineTableView.delegate = self
            self.perform(#selector(reloadTableView), with: nil, afterDelay: 1.0)
            urlTableView.reloadData()
        }
    }
    var urlInfos : [ExternalURLInfo] = []{
        didSet{
            urlTableView.dataSource = self
            urlTableView.delegate = self
            self.perform(#selector(reloadUrlTableView), with: nil, afterDelay: 1.0)
            addHeaderView()
        }
    }

    @objc func reloadUrlTableView(){
        DispatchQueue.main.async { [weak self] in
            self?.urlTableView.reloadData()
        }
    }

    @objc func reloadTableView(){
        DispatchQueue.main.async { [weak self] in
            self?.timeLineTableView.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        qrTypeInfoLabel.layer.masksToBounds = true
        qrTypeInfoLabel.layer.cornerRadius = 3
        idleTypeLabel.layer.masksToBounds = true
        idleTypeLabel.layer.cornerRadius = 3
        
        let nib = UINib(nibName: "ApprovalHistoryTableViewCell", bundle: nil)
        timeLineTableView.register(nib, forCellReuseIdentifier: "approvalHistoryCell")
        
        let nib1 = UINib(nibName: "URLTableViewCell", bundle: nil)
        urlTableView.register(nib1, forCellReuseIdentifier: "urlCell")

        
        urlTableView.rowHeight = UITableView.automaticDimension
        urlTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        urlTableView.estimatedRowHeight = UITableView.automaticDimension
        

//        timeLineTableView.estimatedRowHeight = UITableView.automaticDimension
        timeLineTableView.rowHeight = UITableView.automaticDimension
        timeLineTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
//        timeLineTableView.backgroundColor = .orange
        self.setStringToButton(title: "Check Approval",button: checkApprovalButton)
        self.setStringToButton(title: "View Offer",button: viewOfferButton)
        self.setStringToButton(title: "Edit Completion Date",button: editCompletionDate)
        timeLineTableView.reloadData()
        
    }
    func addHeaderView(){
        
        if(self.urlInfos.count > 0){
            
            let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.urlTableView.frame.size.width, height: 40))
            label.textAlignment = .left
            label.font = UIFont.init(name: "Montserrat-Medium", size: 15)
            label.textColor = .red
            label.text = "External URL Information"

            let tempView = UIView.init(frame: CGRect(x: 0, y: 0, width: urlTableView.frame.size.width, height: 50))
            tempView.addSubview(label)

            urlTableView.tableHeaderView = tempView

        }
        else{
            
            urlTableView.tableHeaderView = UIView()
        }

        
    }
    func setStringToButton(title : String,button : UIButton){
        let attributeString = NSMutableAttributedString(string: title,
                                                        attributes: yourAttributes)
        button.setAttributedTitle(attributeString, for: .normal)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? UITableView {
            if obj == self.timeLineTableView && keyPath == "contentSize" {
                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    //do stuff here
//                    if(!timeLineTableView.isHidden){
                    heightOfTimeLineTableView.constant = newSize.height
//                        print(newSize.height)
//                    }
                }
            }
            else if(obj == self.urlTableView && keyPath == "contentSize" )
            {
                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    heightOfUrlTableView.constant = newSize.height
                }
            }
        }
    }

    deinit {
        self.timeLineTableView.removeObserver(self, forKeyPath: "contentSize")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @objc func playAudio(_ sender : UITapGestureRecognizer){

        let touch = sender.location(in: timeLineTableView)
        if let indexPath = timeLineTableView.indexPathForRow(at: touch) {
            // Access the image or the cell at this index path

            let callHistory = self.callHisotryTimeLineData[indexPath.row]
//            print(callHistory)
            // Show Audio player in popUp
            if let auidoUrl = callHistory.audio{
                self.delegate?.didSelectAudioButtoin(selectedUrl: auidoUrl)
            }

        }
    }
}
extension QRHistoryTableViewCell : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(tableView == urlTableView){
            return 1
        }
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView == urlTableView){
            return self.urlInfos.count
        }
        
        if(section == 0){
            return callHisotryTimeLineData.count
        }
        return discountRequestTimeLineData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if(tableView == urlTableView){
            
            let cell : URLTableViewCell = tableView.dequeueReusableCell(withIdentifier: "urlCell", for: indexPath) as! URLTableViewCell
            
            let tapGuesture = UITapGestureRecognizer.init(target: self, action: #selector(openUrl(_:)))
            cell.urlLabel.addGestureRecognizer(tapGuesture)
            
            if(urlInfos.count > 0){
                
                let urlInfo = self.urlInfos[indexPath.row]
                
                cell.urlTypeLabel.text = "\(urlInfo.urlType ?? "") :"
                
    //            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]

                let attr1 = [NSAttributedString.Key.font : UIFont.init(name: "Montserrat-Regular", size: 15) as Any, NSAttributedString.Key.foregroundColor : UIColor.blue,NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue] as [NSAttributedString.Key : Any]
                
                let attributedString1 = NSMutableAttributedString(string:(urlInfo.url ?? ""), attributes:attr1 as [NSAttributedString.Key : Any])
                
                cell.urlLabel.attributedText = attributedString1

                if let tempDate = urlInfo.date{
                    cell.dateLabel.text = "Added on: \(RRUtilities.sharedInstance.getHistoryCellDate(dateStr: tempDate))"
                }
                else{
                    cell.dateLabel.text = ""
                }

            }
            
            
            return cell
        }
        
        let cell : ApprovalHistoryTableViewCell = timeLineTableView.dequeueReusableCell(
            withIdentifier: "approvalHistoryCell",
            for: indexPath) as! ApprovalHistoryTableViewCell
//        cell.backgroundColor = .red

        if(indexPath.section == 0){ //Call Hisotry
            
            let callDetails = callHisotryTimeLineData[indexPath.row]
            
            if(callDetails.callType == "Inbound"){
                cell.approvalStatusLabel.text = String(format: "Call from Customer(%@) to the Executive(%@)", callDetails.custNo ?? "",callDetails.exeNo ?? "")
                //"Called  \(callDetails.custNo ?? "")"

            }
            else{
                cell.approvalStatusLabel.text = String(format: "Call from Executive(%@) to the Customer(%@)", callDetails.exeNo ?? "",callDetails.custNo ?? "")
            }
            cell.approvalDetailsLabel.text = ""
            cell.verticalLineView.isHidden = true
            
            var callDetailsString : String = ""
            cell.statusTypeImageView.image = UIImage.init(named: "call_black")

            callDetailsString.append(contentsOf: String(format: "Type: %@\n", callDetails.callType ?? "-"))
            callDetailsString.append(contentsOf: String(format: "Status: %@\n", callDetails.callStatus ?? "-"))
            
            if let tempFromDate = callDetails.starttime{
                let fromDate = RRUtilities.sharedInstance.getDateFromServerDateString(dateStr: tempFromDate)
                if let tempEndDate = callDetails.endTime{
                    let endDate = RRUtilities.sharedInstance.getDateFromServerDateString(dateStr: tempEndDate)
                    let difference = Calendar.current.dateComponents([.second], from: fromDate!, to: endDate!)
                    if let duration = difference.second {
                        callDetailsString.append(contentsOf: String(format: "Total Duration: %d Secs\n", duration))
                    }
                }
            }
            
//            guard let fromDate = RRUtilities.sharedInstance.getDateFromServerDateString(dateStr: callDetails.starttime ?? "") else { return cell }
//            guard let endDate = RRUtilities.sharedInstance.getDateFromServerDateString(dateStr: callDetails.endTime ?? "") else { return cell }
//
//            let difference = Calendar.current.dateComponents([.second], from: fromDate, to: endDate)
//            if let duration = difference.second {
//                callDetailsString.append(contentsOf: String(format: "Total Duration: %d Secs\n", duration))
//            }
            
            if let endTime = callDetails.endTime {
                callDetailsString.append(contentsOf:RRUtilities.sharedInstance.getNotificationViewDate(dateStr:endTime))
            }
            else if let startTime = callDetails.starttime {
                callDetailsString.append(contentsOf:RRUtilities.sharedInstance.getNotificationViewDate(dateStr:startTime))
            }
            cell.approvalDetailsLabel.text = callDetailsString
            cell.widthOfAudioImageView.constant = 24
            cell.audioImageView.image = UIImage(named: "audio")
            let tapGuesture = UITapGestureRecognizer.init(target: self, action:#selector(playAudio(_:)))
            cell.audioImageView.addGestureRecognizer(tapGuesture)
            return cell

        }
        else if(indexPath.section == 1){ //Discount requests
            
            let timeLine = discountRequestTimeLineData[indexPath.row]
            
            cell.approvalStatusLabel.text = timeLine.descp
            
            var infoText = String(format: "User: %@", timeLine.user?.userInfo?.name ?? "Super Admin")
            infoText.append("\n")
            infoText.append(String(format: "Date: %@",RRUtilities.sharedInstance.getNotificationViewDate(dateStr: timeLine.date ?? "")))
            cell.approvalDetailsLabel.text = infoText

            if(timeLine.descp == "Unit Discount Request Submitted for Approvals") {
                cell.statusTypeImageView.image = UIImage.init(named: "pending")
            }
            else if(timeLine.descp == "Discount Approved"){
                cell.statusTypeImageView.image = UIImage.init(named: "otp_success_icon")
                
            }
            else if(timeLine.descp == "Discount Rejected") {
                cell.statusTypeImageView.image = UIImage.init(named: "reject")
            }
            
            if(indexPath.row == discountRequestTimeLineData.count - 1){
                cell.verticalLineView.isHidden = true
            }
            else{
                cell.verticalLineView.isHidden = false
            }

        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        if(tableView == self.urlTableView){
//
//            if(self.urlInfos.count > 0){
//                let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.urlTableView.frame.size.width, height: 40))
//                label.textAlignment = .left
//                label.font = UIFont.init(name: "Montserrat-Medium", size: 15)
//                label.textColor = .red
//                label.text = "External URL Information"
//                return label
//            }
//            else{
//                return nil
//            }
//        }
//        else{
//            return nil
//        }
//
//        return nil
//    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
    
    @objc func openUrl(_ gesture : UITapGestureRecognizer){
        
//        print(gesture)
        
        guard let indexPath = self.urlTableView.indexPathForRow(at: gesture.location(in: self.urlTableView)) else {
            print("Error: indexPath)")
            return
        }

//        print(indexPath.row)
        let urlINfo = self.urlInfos[indexPath.row]
        
        if let url = URL(string: urlINfo.url ?? "") {
            UIApplication.shared.open(url)
        }
        
    }
}
extension QRHistoryTableViewCell : UIScrollViewDelegate{
    
    
}

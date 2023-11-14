//
//  NewProspectsTableViewswift
//  REroot
//
//  Created by Dhanunjay Kumar Mocharla on 09/02/20.
//  Copyright © 2020 ReRoot. All rights reserved.
//

import UIKit

protocol ClickDelegate : class {
    func didSelectProspectType(indexPath : IndexPath,titleName : String,count : Int,statusID : Int)
}
extension ClickDelegate{
    func didSelectProspectType(indexPath : IndexPath,titleName : String,count : Int,statusID : Int){}
}

class NewProspectsTableViewCell: UITableViewCell {

    var selectedIndexPath : IndexPath!
    weak var delegate : ClickDelegate!
    @IBOutlet weak var leadsView: UIView!
    @IBOutlet weak var registrationsView: UIView!
    
    @IBOutlet weak var opportunitiesCountLabel: UILabel!
    @IBOutlet weak var leadsCountLabel: UILabel!
    @IBOutlet weak var registrationsCountLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var totalProspectsCountLabel: UILabel!
    @IBOutlet weak var expiredProspectsCountLabel: UILabel!
    @IBOutlet weak var schduledProspectsCountLabel: UILabel!

    @IBOutlet weak var projectIconImageView: UIImageView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var opportunitiesView: UIView!
    @IBOutlet weak var roundView2: UIView!
    @IBOutlet weak var roundView1: UIView!
    @IBOutlet weak var subView: UIView!
    
    @IBOutlet weak var temp1: UIView!
    @IBOutlet weak var heightOfSubContentView: NSLayoutConstraint!
    
    var expiredPropsectDetails : PROSPECT_DETAILS! = nil
    var prospectDetails : PROSPECT_DETAILS! = nil{
        didSet{
            self.collectionView.reloadData()
        }
    }
    
    var collectionImageViewDataSource : [String] = ["Calls","Offers","Site Visits","Discount Requests","Other Tasks","Not Interested"]
    var collectionCellImageColors : [String] = ["DD8B3D","5C38F5","348dd6","00b50f","6E7277","CD372E"]
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let nib = UINib(nibName: "ProspectCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "prospectInfoCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self

        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        collectionView.collectionViewLayout = layout
        
        subView.layer.masksToBounds = false
        subView.layer.shadowColor = UIColor.lightGray.cgColor
        subView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        subView.layer.shadowOpacity = 0.4
        subView.layer.shadowRadius = 3.0
//        subView.layer.shouldRasterize = true
        subView.layer.borderColor = UIColor.lightGray.cgColor
        subView.layer.shouldRasterize = true
        subView.layer.rasterizationScale = UIScreen.main.scale

        if #available(iOS 11.0, *) {
            roundView1.layer.cornerRadius = 8
            roundView1.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        temp1.layer.cornerRadius = 8

//        if #available(iOS 11.0, *) {
//            temp1.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
//        } else {
//            // Fallback on earlier versions
//        }

        if #available(iOS 11.0, *) {
            roundView2.layer.cornerRadius = 8
            roundView2.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }

        //opportunitiesView
        
        if #available(iOS 11.0, *) {
            opportunitiesView.layer.cornerRadius = 8
            opportunitiesView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            
        } else {
            // Fallback on earlier versions
        }

        
        self.subView.layer.cornerRadius = 8
        
            
    }
    func redrawButton(button : UIButton){
        
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension NewProspectsTableViewCell : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionImageViewDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : ProspectCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "prospectInfoCell", for: indexPath) as! ProspectCollectionViewCell
        cell.prospectInfoButton.setImage(UIImage.init(named: collectionImageViewDataSource[indexPath.row]), for: .normal)
        cell.prospectInfoButton.layer.borderColor = UIColor.hexStringToUIColor(hex: collectionCellImageColors[indexPath.row]).cgColor
        
        
        if(indexPath.row == 0){
            cell.prospectInfoButton.setTitle(String(format: "%d", (prospectDetails.leads?.callCount ?? 0) + (prospectDetails.opportunities?.callCount ?? 0)), for: .normal)
            let count = (expiredPropsectDetails?.leads?.callCount ?? 0) + (expiredPropsectDetails?.opportunities?.callCount ?? 0)
            if(count  > 0){
                cell.expiredCountView.isHidden = false
                cell.expiredCountLabel.text = String(format: "%d", count)
            }
            else{
                cell.expiredCountView.isHidden = true
                cell.expiredCountLabel.text = "0"
            }
        }
        else if(indexPath.row == 1){
            cell.prospectInfoButton.setTitle(String(format: "%d", prospectDetails.leads!.offerCount! + prospectDetails.opportunities!.offerCount!), for: .normal)
            let count = (expiredPropsectDetails?.leads?.offerCount ?? 0) + (expiredPropsectDetails?.opportunities?.offerCount ?? 0)
            if(count > 0){
                cell.expiredCountView.isHidden = false
                cell.expiredCountLabel.text = String(format: "%d", count)
            }
            else{
                cell.expiredCountView.isHidden = true
                cell.expiredCountLabel.text = "0"
            }
        }
        else if(indexPath.row == 2){
            cell.prospectInfoButton.setTitle(String(format: "%d", prospectDetails.leads!.siteVisitCount! + prospectDetails.opportunities!.siteVisitCount!), for: .normal)
            let count = (expiredPropsectDetails?.leads?.siteVisitCount ?? 0) + (expiredPropsectDetails?.opportunities?.siteVisitCount ?? 0)
            if(count > 0){
                cell.expiredCountView.isHidden = false
                cell.expiredCountLabel.text = String(format: "%d", count)
            }
            else{
                cell.expiredCountView.isHidden = true
                cell.expiredCountLabel.text = "0"
            }

        }
        else if(indexPath.row == 3){
            cell.prospectInfoButton.setTitle(String(format: "%d", prospectDetails.leads!.discountRequestCount! + prospectDetails.opportunities!.discountRequestCount!), for: .normal)
            let count = (expiredPropsectDetails?.leads?.discountRequestCount ?? 0) + (expiredPropsectDetails?.opportunities?.discountRequestCount ?? 0)
            if(count > 0){
                cell.expiredCountView.isHidden = false
                cell.expiredCountLabel.text = String(format: "%d", count)
            }
            else{
                cell.expiredCountView.isHidden = true
                cell.expiredCountLabel.text = "0"
            }
        }
        else if(indexPath.row == 4){
            cell.prospectInfoButton.setTitle(String(format: "%d", prospectDetails.leads!.otherCount! + prospectDetails.opportunities!.otherCount!), for: .normal)
            let count = (expiredPropsectDetails?.leads?.otherCount ?? 0) + (expiredPropsectDetails?.opportunities?.otherCount ?? 0)

            if(count > 0){
                cell.expiredCountView.isHidden = false
                cell.expiredCountLabel.text = String(format: "%d", count)
            }
            else{
                cell.expiredCountView.isHidden = true
                cell.expiredCountLabel.text = "0"
            }
        }
        else if(indexPath.row == 5){
            cell.prospectInfoButton.setTitle(String(format: "%d", prospectDetails.leads!.notInterestedCount! + prospectDetails.opportunities!.notInterestedCount!), for: .normal)
            let count = (expiredPropsectDetails?.leads?.notInterestedCount ?? 0) + (expiredPropsectDetails?.opportunities?.notInterestedCount ?? 0)

            if(count > 0){
                cell.expiredCountView.isHidden = false
                cell.expiredCountLabel.text = String(format: "%d", count)
            }
            else{
                cell.expiredCountView.isHidden = true
                cell.expiredCountLabel.text = "0"
            }
        }
        cell.prospectInfoButton.tag = indexPath.row
        cell.prospectInfoButton.addTarget(self, action: #selector(prospectButtonClicked(_:)), for: .touchUpInside)
        
        cell.subContentView.bringSubviewToFront(cell.expiredCountView)

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let count = self.getCount(indexPath: indexPath)
        self.delegate?.didSelectProspectType(indexPath: self.selectedIndexPath, titleName: collectionImageViewDataSource[indexPath.row],count: count, statusID: indexPath.row + 1)
    }
    func getCount(indexPath : IndexPath)->Int{
        
        var count = 0
        if(indexPath.row == 0){
            count = (prospectDetails?.leads?.callCount ?? 0) + (prospectDetails?.opportunities?.callCount ?? 0)
        }
        else if(indexPath.row == 1){
            count = (prospectDetails?.leads?.offerCount ?? 0) + (prospectDetails?.opportunities?.offerCount ?? 0)
        }
        else if(indexPath.row == 2){
            count = (prospectDetails?.leads?.siteVisitCount ?? 0) + (prospectDetails?.opportunities?.siteVisitCount ?? 0)

        }
        else if(indexPath.row == 3){
            count = (prospectDetails?.leads?.discountRequestCount ?? 0) + (prospectDetails?.opportunities?.discountRequestCount ?? 0)
        }
        else if(indexPath.row == 4){
            count = (prospectDetails?.leads?.otherCount ?? 0) + (prospectDetails?.opportunities?.otherCount ?? 0)
          
        }
        else if(indexPath.row == 5){
            count = (prospectDetails?.leads?.notInterestedCount ?? 0) + (prospectDetails?.opportunities?.notInterestedCount ?? 0)
        }
        return count
    }
    
    @objc func prospectButtonClicked(_ sender : UIButton){
        let indexPath = IndexPath.init(row: sender.tag, section: self.leadsView.tag)
        let count = self.getCount(indexPath: indexPath)
        self.delegate?.didSelectProspectType(indexPath: selectedIndexPath, titleName: collectionImageViewDataSource[sender.tag], count: count, statusID: sender.tag+1)

    }
}

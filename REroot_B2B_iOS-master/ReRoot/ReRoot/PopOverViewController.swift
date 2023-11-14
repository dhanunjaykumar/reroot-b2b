//
//  PopOverViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 16/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

protocol HidePopUp: class {
    func didSelectProject(optionType : String,optionIndex: Int)
    func didFinishTask(optionType : String,optionIndex: Int)
    func didSelectOptionForUnitsView(selectedIndex : Int)
    func shouldShowUnitsWithSelectedStatus(selectedStatus : Int)
    func showSelectedTowerFromFloatButton(selectedTower : TOWERDETAILS,selectedBlock : String)
}
enum DATA_SOURCE_TYPE {
    case PROJECTS
    case ALL_BLOCKS
    case SUMMARY_OR_UNITS
    case STATUS
    case SHOW_STATUS_WISE
    case BLOCKS_FLOAT_BUTTON
    case SOURCES
    case URLS
}
class PopOverViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var oderedSectionTitlesForFloatButton = [String]()
    var selectedIndexForUnitsView : Int!
    @IBOutlet var heightOfTitlesView: NSLayoutConstraint!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var mTableView: UITableView!
    var tableViewDataSource2 : Dictionary<String,Array<TOWERDETAILS>> = [:]
    var tableViewDataSource : Array<Project> =  []
    weak var delegate:HidePopUp?
    var tableViewDataSourceOne : Array<String> = []
    var dataSourceType : DATA_SOURCE_TYPE!
    var titleString : String!
    var subTitleString : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mTableView.delegate = self
        mTableView.dataSource = self
        mTableView.tableFooterView = UIView()
        
        if((dataSourceType == DATA_SOURCE_TYPE.SOURCES) || (dataSourceType == DATA_SOURCE_TYPE.PROJECTS) || dataSourceType == DATA_SOURCE_TYPE.SUMMARY_OR_UNITS || dataSourceType == DATA_SOURCE_TYPE.SHOW_STATUS_WISE || dataSourceType == DATA_SOURCE_TYPE.BLOCKS_FLOAT_BUTTON || dataSourceType == DATA_SOURCE_TYPE.URLS){
            heightOfTitlesView.constant = 0
        }
        
        if(dataSourceType == DATA_SOURCE_TYPE.STATUS){
            titleLabel.text = "Change Status"
            subTitleLabel.text = String(format: "Selected Unit : %u", selectedIndexForUnitsView)
        }

        let headerNib = UINib.init(nibName: "PopUpHeaderView", bundle: Bundle.main)
        mTableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "PopUpHeaderView")

        
//        mTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)

    }
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        mTableView.removeObserver(self, forKeyPath: "contentSize")
//    }
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        self.preferredContentSize = mTableView.contentSize
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        if(dataSourceType == DATA_SOURCE_TYPE.BLOCKS_FLOAT_BUTTON){
            return tableViewDataSource2.keys.count
        }

        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if(dataSourceType == DATA_SOURCE_TYPE.PROJECTS){
            return tableViewDataSource.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SUMMARY_OR_UNITS)
        {
            return tableViewDataSourceOne.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.STATUS || dataSourceType == DATA_SOURCE_TYPE.URLS)
        {
            return tableViewDataSourceOne.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SHOW_STATUS_WISE || dataSourceType == DATA_SOURCE_TYPE.SOURCES)
        {
            return tableViewDataSourceOne.count
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.BLOCKS_FLOAT_BUTTON){
            let key = oderedSectionTitlesForFloatButton[section]
            let towersArray = tableViewDataSource2[key]!
            return towersArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "popUpCell", for:indexPath) as! PopOverTableViewCell
        
        // Configure the cell...
        if(dataSourceType == DATA_SOURCE_TYPE.PROJECTS){
            let project = tableViewDataSource[indexPath.row]
            cell.mTitleLabel.text = String(format: "%@ - %@", project.name! , project.city!)
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SUMMARY_OR_UNITS){
            let project = tableViewDataSourceOne[indexPath.row]
            cell.mTitleLabel.text = String(format: "%@", project)
            cell.mImageView.isHidden = true
            
//            cell.widthOfImageView.constant = 40
            if(selectedIndexForUnitsView  == indexPath.row){
                cell.roundedView.backgroundColor = UIColor.green
            }
            else{
                cell.roundedView.backgroundColor = UIColor.clear
            }
//            cell.mImageView.layer.cornerRadius = cell.mImageView.frame.size.width/2
//            cell.mImageView.clipsToBounds = true
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.URLS){
            
            let project = tableViewDataSourceOne[indexPath.row]
            cell.mTitleLabel.text = String(format: "%@", project)
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 0
//            let colorsDict = RRUtilities.sharedInstance.getColorAccordingToUnitStatus(status: indexPath.row)
//            cell.roundedView.backgroundColor = colorsDict["color"] as? UIColor
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.STATUS){
            
            let project = tableViewDataSourceOne[indexPath.row]
            cell.mTitleLabel.text = String(format: "%@", project)
            cell.roundedView.isHidden = false
            cell.leadingOfTitleLabel.constant = 6
            let colorsDict = RRUtilities.sharedInstance.getColorAccordingToUnitStatus(status: indexPath.row)
            cell.roundedView.backgroundColor = colorsDict["color"] as? UIColor
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SHOW_STATUS_WISE){
            let title = tableViewDataSourceOne[indexPath.row]
            cell.mTitleLabel.text = String(format: "%@", title)
            cell.roundedView.isHidden = false
            cell.leadingOfTitleLabel.constant = 6
            if(indexPath.row != 0){
                let colorsDict = RRUtilities.sharedInstance.getColorAccordingToUnitStatus(status: indexPath.row-1)
                cell.roundedView.backgroundColor = colorsDict["color"] as? UIColor
            }
            else{
                cell.roundedView.backgroundColor = UIColor.clear
            }

        }
        else if(dataSourceType == DATA_SOURCE_TYPE.BLOCKS_FLOAT_BUTTON){
            
            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 10

            let key = oderedSectionTitlesForFloatButton[indexPath.section]
            let towersArray = tableViewDataSource2[key]!
           
            let tempTower = towersArray[indexPath.row]
            
            cell.mTitleLabel.text = tempTower.name
            cell.mTitleLabel.textAlignment = .center
            
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SOURCES){
            
            let project = tableViewDataSourceOne[indexPath.row]
            cell.mTitleLabel.text = String(format: "%@", project)

            cell.widthOfImageHolderView.constant = 0
            cell.roundedView.isHidden = true
            cell.leadingOfTitleLabel.constant = 8
        }
//        cell.optionLabel.text = tableViewDataSource[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(dataSourceType == DATA_SOURCE_TYPE.PROJECTS){
            let selectedProject = tableViewDataSource[indexPath.row]
            self.delegate?.didSelectProject(optionType:selectedProject.id!  ,optionIndex: indexPath.row)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SUMMARY_OR_UNITS){
//            let selectedString = tableViewDataSourceOne[indexPath.row]
//            self.delegate?.didFinishTask(optionType:selectedString  ,optionIndex: indexPath.row)
            self.delegate?.didSelectOptionForUnitsView(selectedIndex: indexPath.row)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.STATUS || dataSourceType == DATA_SOURCE_TYPE.URLS){
            let selectedString = tableViewDataSourceOne[indexPath.row]
            self.delegate?.didFinishTask(optionType:selectedString  ,optionIndex: indexPath.row)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SHOW_STATUS_WISE){
            if(indexPath.row == 0){
                self.delegate?.shouldShowUnitsWithSelectedStatus(selectedStatus: -1)
            }
            else{
                self.delegate?.shouldShowUnitsWithSelectedStatus(selectedStatus: indexPath.row-1)
            }
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.BLOCKS_FLOAT_BUTTON){
            
            let key = oderedSectionTitlesForFloatButton[indexPath.section]
            let towersArray = tableViewDataSource2[key]!
            
            let tempTower = towersArray[indexPath.row]

            self.delegate?.showSelectedTowerFromFloatButton(selectedTower: tempTower, selectedBlock: key)
        }
        else if(dataSourceType == DATA_SOURCE_TYPE.SOURCES){
            
            self.delegate?.didFinishTask(optionType: tableViewDataSourceOne[indexPath.row], optionIndex: indexPath.row)

        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if(dataSourceType == DATA_SOURCE_TYPE.BLOCKS_FLOAT_BUTTON){
            
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PopUpHeaderView") as! PopUpHeaderView
            
            let key = oderedSectionTitlesForFloatButton[section]
            headerView.headerTitleLabel.text = key
            
            return headerView
        }
        else{
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if(dataSourceType == DATA_SOURCE_TYPE.BLOCKS_FLOAT_BUTTON){
            
            return 44
        }
        else{
            return 0
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

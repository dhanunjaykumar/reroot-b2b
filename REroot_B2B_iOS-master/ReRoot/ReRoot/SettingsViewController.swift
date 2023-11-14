//
//  SettingsViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 29/08/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController , UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var titlesArray : [String]!
    var subTitlesArray : [String]!
    
    @IBOutlet var titleView: UIView!
    
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
        
        titlesArray = ["Unit Name","Filter by Action Date"]
        subTitlesArray = ["Unit Description Enabled","Filter by Action Date"]
        
//        if(UserDefaults.standard.bool(forKey: "Unit Description Enabled") == nil){
//            UserDefaults.standard.set(false, forKey: "Unit Description Enabled")
//            UserDefaults.standard.synchronize()
//        }
        
        let temper = UserDefaults.standard.bool(forKey: subTitlesArray[0])
        print(temper)
        
        
//        var shouldEnable = UserDefaults.standard.bool(forKey: subTitlesArray[0])
//        shouldEnable = !shouldEnable

        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
    }
    @objc func enableSettings(_ sender: UISwitch){
        
//        if(sender.tag == 0)  // remove this to make it work for any row ****
//        {
            var shouldEnable = UserDefaults.standard.bool(forKey: subTitlesArray[sender.tag])
            shouldEnable = !shouldEnable
            UserDefaults.standard.set(shouldEnable, forKey: subTitlesArray[sender.tag])
            UserDefaults.standard.synchronize()
            tableView.reloadData()
//        }
//        else{
//
//        }
    }
    //MARK: - Tableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titlesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : SettingsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "settingsCell",
            for: indexPath) as! SettingsTableViewCell

        cell.titleLabel.text = titlesArray[indexPath.row]
        
        if(indexPath.row+1 <= subTitlesArray.count){
            cell.subTitleLbel.text = subTitlesArray[indexPath.row]
        }
        
        if(titlesArray[indexPath.row] == "Filter by Action Date"){
            cell.subTitleLbel.text = (UserDefaults.standard.bool(forKey: "Filter by Action Date")) ? "Yes" : "No"
        }
        let shouldEnable = UserDefaults.standard.bool(forKey: subTitlesArray[indexPath.row])

        cell.enableSwitch.setOn(shouldEnable, animated: true)
        cell.enableSwitch.addTarget(self, action: #selector(enableSettings), for: .touchUpInside)
        cell.enableSwitch.tag = indexPath.row
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var shouldEnable = UserDefaults.standard.bool(forKey: subTitlesArray[indexPath.row])
        shouldEnable = !shouldEnable
        
        UserDefaults.standard.set(shouldEnable, forKey: subTitlesArray[indexPath.row])
        UserDefaults.standard.synchronize()

        tableView.reloadData()
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

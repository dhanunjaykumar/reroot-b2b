//
//  ManageUnitsViewController.swift
//  REroot
//
//  Created by Dhanunjay on 17/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class ManageUnitsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    
    @IBOutlet var titleView: UIView!
    @IBOutlet var tableView: UITableView!
    var tableViewDataSourceArray : Array<String> = []
    
    // MARK: - View LIfe cycle
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

    // MARK: - ACTIONS
    func configureView(){
        
        tableViewDataSourceArray = ["Block/Release Units","Reserve Units"]
        
        let nib = UINib(nibName: "ProspectsTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "prospectCell")
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - Tableview Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProspectsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "prospectCell",
            for: indexPath) as! ProspectsTableViewCell
        
        cell.widthOfRightImage.constant = 0
        cell.rightImageView.isHidden = true
        cell.heightOfSubContentView.constant = 50
        cell.heightOfLeftImageView.constant = 50
        
        cell.titleLabel.text = tableViewDataSourceArray[indexPath.row]
        cell.leftImageView.image = UIImage.init(named: tableViewDataSourceArray[indexPath.row])
        
        cell.subContentView.layer.cornerRadius = 4
        cell.subContentView.layer.borderWidth = 2
        cell.subContentView.layer.borderColor = UIColor.clear.cgColor
        cell.subContentView.layer.shadowRadius = 4
        cell.subContentView.layer.masksToBounds = false
        cell.subContentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.subContentView.layer.shadowRadius = 2
        cell.subContentView.layer.shadowOpacity = 0.3
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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

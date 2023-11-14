//
//  HomeViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 03/07/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import SideMenu
import PKHUD

class HomeViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {

    @IBOutlet var menuButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var titleView: UIView!
    
    var menuTitlesArray : [String]!
    var menuSubTitlesArray : [String]!
    var menuImagesArray : [String]!
    
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
        
//        titleView.layer.shadowPath = UIBezierPath(roundedRect: titleView.bounds, cornerRadius: 10).cgPath
        titleView.layer.shouldRasterize = true
        titleView.layer.rasterizationScale = UIScreen.main.scale
        self.view.bringSubviewToFront(titleView)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if((tableView.delegate) == nil)
        {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            
            tableView.estimatedRowHeight = 132.0
            tableView.rowHeight = UITableView.automaticDimension
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(showLoginScreen), name: NSNotification.Name(rawValue: NOTIFICATIONS.SHOWLOGINSCREEN), object: nil)
        
        menuTitlesArray = ["Presales","Pricing","Sales","CRM"]
        menuSubTitlesArray = ["Manage new leads \n& opportinites","Manage discounts \nand price revision","Track and manage inventory","Manage collections and customer engagement"]
        menuImagesArray = ["presalesImage","pricingImage","salesImage","crmImage"]
        
        setupSideMenu()

        
        if UserDefaults.standard.value(forKey: "Cookie") == nil
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginController = storyboard.instantiateViewController(withIdentifier :"LoginView") as! LoginViewController
            let tempNavigator = UINavigationController.init(rootViewController: loginController)
            self.present(tempNavigator, animated: true, completion: {
                //perhaps we'll do something here later
            })
            return
        }

    }
    
    fileprivate func setupSideMenu() {
        // Define the menus
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        SideMenuManager.default.menuPresentMode = .menuSlideIn

        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.default.menuAddPanGestureToPresent(toView:self.view)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
        SideMenuManager.default.menuFadeStatusBar = false
    }
    @objc func showLoginScreen() {
        
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginController = storyboard.instantiateViewController(withIdentifier :"LoginView") as! LoginViewController
            let tempNavigator = UINavigationController.init(rootViewController: loginController)
            self.present(tempNavigator, animated: true, completion: {
            })
        }
    }
    
    @IBAction func showLeftMenu(_ sender: Any) {
        
        self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: {
        })
    }
    
    //MARK: - Tableview Delegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.estimatedRowHeight = 132.0 // standard tableViewCell height
        tableView.rowHeight = UITableView.automaticDimension

        return menuTitlesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : HomeMenuTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "HomeMenuCell",
            for: indexPath) as! HomeMenuTableViewCell
        
        cell.menuTitleLabel.text = menuTitlesArray[indexPath.row]
        cell.menuImageView.image = UIImage.init(named: menuImagesArray[indexPath.row])
        cell.menuSubTitleLabel.text = menuSubTitlesArray[indexPath.row]
        
        cell.layoutIfNeeded()
        
        cell.subContentView.layer.cornerRadius = 4
        cell.subContentView.layer.borderWidth = 2
        cell.subContentView.layer.borderColor = UIColor.clear.cgColor
        cell.subContentView.layer.shadowRadius = 4
        cell.subContentView.layer.masksToBounds = false
        cell.subContentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.subContentView.layer.shadowRadius = 2
        cell.subContentView.layer.shadowOpacity = 0.3
        
        cell.contentView.bringSubviewToFront(cell.subContentView)

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let preSalesController = storyboard.instantiateViewController(withIdentifier :"webView") as! WebViewController
//        self.navigationController?.pushViewController(preSalesController, animated: true)
//        return
        
        if(indexPath.row == 0){
            
            if !RRUtilities.sharedInstance.getNetworkStatus()
            {
                HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let preSalesController = storyboard.instantiateViewController(withIdentifier :"preSales") as! PreSalesViewController
            self.navigationController?.pushViewController(preSalesController, animated: true)

        }
        else if(indexPath.row == 1){
            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let detailsController = storyboard.instantiateViewController(withIdentifier :"bookUnit") as! BookUnitViewController
//            self.navigationController?.pushViewController(detailsController, animated: true)

          
        }
        else if(indexPath.row == 2){ //Sales
            
            if !RRUtilities.sharedInstance.getNetworkStatus()
            {
                HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginController = storyboard.instantiateViewController(withIdentifier :"Projects") as! ProjectsViewController
            self.navigationController?.pushViewController(loginController, animated: true)
        }
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

extension HomeViewController: UISideMenuNavigationControllerDelegate {
    
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Appearing! (animated: \(animated))")
    }
    
    func sideMenuDidAppear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Appeared! (animated: \(animated))")
    }
    
    func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappearing! (animated: \(animated))")
    }
    
    func sideMenuDidDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappeared! (animated: \(animated))")
    }
    
}


//
//  ProjectInfoViewController.swift
//  REroot
//
//  Created by Dhanunjay on 19/02/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class ProjectInfoViewController: UIViewController {

    @IBOutlet var titleInfoView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var projectInfoLabel: UILabel!
    @IBOutlet var projectTitleLabel: UILabel!
    var selectedProject : Project!
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        titleInfoView.clipsToBounds = true
        
        titleInfoView.layer.masksToBounds = false
        titleInfoView.layer.shadowColor = UIColor.lightGray.cgColor
        titleInfoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        titleInfoView.layer.shadowOpacity = 0.4
        titleInfoView.layer.shadowRadius = 1.0
        titleInfoView.layer.shouldRasterize = true
        titleInfoView.layer.borderColor = UIColor.lightGray.cgColor
        
        titleInfoView.layer.shouldRasterize = true
        titleInfoView.layer.rasterizationScale = UIScreen.main.scale
        self.view.bringSubviewToFront(titleInfoView)
            
    }
    override func viewDidLoad() {
        super.viewDidLoad()

//        setNeedsStatusBarAppearanceUpdate()

//        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: projectInfoLabel.bottomAnchor).isActive = true

        projectTitleLabel.text = selectedProject.name?.uppercased()
        if(selectedProject.info != nil){
            projectInfoLabel.text = selectedProject.info
        }
        else{
            projectInfoLabel.text = "No Information Provided."
            projectInfoLabel.textAlignment = .center
            projectInfoLabel.textColor = UIColor.lightGray
        }
        // Do any additional setup after loading the view.
    }
//
//    override var prefersStatusBarHidden: Bool{
//        return true
//    }

    @IBAction func back(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
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

//
//  ReceiptEntryViewController.swift
//  REroot
//
//  Created by Dhanunjay on 17/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class ReceiptEntryViewController: UIViewController {
    
    @IBOutlet var titleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureView()
    }
    // MARK: - METHODS
    func configureView(){
        
    }
    // MARK: - ACTIONS
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func search(_ sender: Any) {
        
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

//
//  WebViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 09/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    let url = "http://52.66.34.235:3000/business/prestige/reports"
        let tempUrl : URLRequest = URLRequest.init(url: URL.init(string: url)!)
        self.webView.loadRequest(tempUrl)
        
        /*
 
         NSURL *websiteUrl = [NSURL URLWithString:@"http://websites.inresto.com/demo1/online-order.html"];// [NSURL URLWithString:@"http://52.74.85.56:3000/public/widgets/onlineOrdering/menu/55df1f000eccee1858ef974f"];
         NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
         [self.webView loadRequest:urlRequest];

         
         */
        
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

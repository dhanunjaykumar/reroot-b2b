//
//  SendOfferPopUpViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 11/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import PKHUD
import Alamofire

class SendOfferPopUpViewController: UIViewController {

    var pdfURL: URL!
    var selectedLabel : String!
    var selctedLabelIndex : Int!
    var prevSelectedStatus : Int!
    var isFromRegistrations : Bool = false
    var isFromDiscountView = false
    var selectedProspect : REGISTRATIONS_RESULT!
    var statusID : Int?
    var tabId : Int!
    var viewType : VIEW_TYPE!
    @IBOutlet var emailTextField: UITextField!
    var emailID = String()
    @IBOutlet weak var previewOfferButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        emailTextField.text = selectedProspect.userEmail
        previewOfferButton.layer.cornerRadius = 8
        previewOfferButton.layer.borderColor = UIColor.lightGray.cgColor
        previewOfferButton.layer.borderWidth = 0.5
        //IQPreviousNextView
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func previewOffer(_ sender: Any) {
        //API_VIEW_OFFER
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        
        let urlString = String(format:RRAPI.API_VIEW_OFFER,self.viewType.rawValue,selectedProspect._id!)
        HUD.show(.progress, onView: self.view)
        ServerAPIs.getPreviewOfferUrl(urlString:urlString ,completionHandler: {(response , error) in
            HUD.hide()
            if(response?.status == 1){
                DispatchQueue.main.async {
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let offerPreview = storyboard.instantiateViewController(withIdentifier :"webView") as! WebViewController
                    offerPreview.isPreViewOffer = true
                    offerPreview.delegate = self
                    DispatchQueue.global().async {
                        let signedUrl = ServerAPIs.getSingleSingedUrl(url: response?.url ?? "")
                        
                        offerPreview.previewOfferUrlString = signedUrl //response?.url
                        offerPreview.selectedProspect = self.selectedProspect
                        
                        DispatchQueue.main.async {
                            let navController = UINavigationController(rootViewController: offerPreview)
                            navController.navigationBar.isHidden = true
                            self.present(navController, animated: true, completion: nil)
                        }

                    }
                }
            }
            else{
                HUD.flash(.label(response?.msg), delay: 1.0)
            }
        })
    }
    @IBAction func okAction(_ sender: Any) {
        //show schedule states ***
        
        if(emailTextField.text?.count == 0 ||  emailTextField.text?.count != 0 && (RRUtilities.sharedInstance.isValidEmail(emailID: emailTextField.text!) == false)){
            HUD.flash(.label("Enter Valid Email ID"), delay: 1.0)
            return
        }
        
        if(selectedProspect.discountApplied == 2){ // 2 Means PENDING
            HUD.flash(.label("Discount request is pending for approval"), delay: 1.0)
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let leadsPopUpController = storyboard.instantiateViewController(withIdentifier :"leadsPopUp") as! LeadsPopUpViewController
        leadsPopUpController.prospectDetails = selectedProspect
        leadsPopUpController.emailId = emailTextField.text!
        leadsPopUpController.tabId = self.tabId
        leadsPopUpController.viewType = self.viewType
        leadsPopUpController.selctedScheduleCallOption = prevSelectedStatus + 1
        leadsPopUpController.isFromRegistrations = self.isFromRegistrations
        leadsPopUpController.statusID = self.statusID
        leadsPopUpController.isFromDiscountView = self.isFromDiscountView
        self.present(leadsPopUpController, animated: true, completion: nil)

        
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
extension SendOfferPopUpViewController : DownloadPDFDelegate{
    func downloadUrl(urlString : String){
        
        guard let url = URL(string: urlString) else { return }
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
        
    }
}

extension SendOfferPopUpViewController:  URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadLocation:", location)
        
        guard let url = downloadTask.originalRequest?.url else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        // delete original copy
        
//        let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        print("doc url " + docUrl.description)
//        var dataPath = docUrl.appendingPathComponent("Reroot")
//        let fileExist = FileManager.default.fileExists(atPath: dataPath.path)
//        print(fileExist)
//        if(!fileExist){
//            try! FileManager.default.createDirectory(at: dataPath, withIntermediateDirectories: true, attributes: nil)
//        }
//        dataPath = dataPath.appendingPathComponent(url.lastPathComponent)

        try? FileManager.default.removeItem(at: destinationURL)
        // copy from temp to Document
        do {
            
            try FileManager.default.copyItem(at: location, to: destinationURL)
            self.pdfURL = destinationURL
            print(self.pdfURL!)
            DispatchQueue.main.async {
                
//                let str = "File save at \("Reroot/\(destinationURL.lastPathComponent)")"
//
//                let ac = UIAlertController(title: "PDF Downloaded", message: str, preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(ac, animated: true)
                
                var infoDict : Dictionary<String,String> = [:]
                infoDict["fileName"] = location.lastPathComponent ?? ""

//
                NotificationCenter.default.post(name: NSNotification.Name("DOWNLOAD_ALERT"), object: infoDict)
                
//                let path = self.getDocumentsDirectory().absoluteString.replacingOccurrences(of: "file://", with: "Reroot://")
//                let url = URL(string: path)!
//
//                UIApplication.shared.open(url)
//
                
            }
        } catch let error {
            print("Copy Error: \(error.localizedDescription)")
        }
    }
    func getDocumentsDirectory() -> URL { // returns your application folder
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

}

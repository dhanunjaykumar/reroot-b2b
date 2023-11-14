//
//  WebViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 09/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import WebKit
import PKHUD
import PDFKit

protocol DownloadPDFDelegate : class{
    func downloadUrl(urlString : String)
}
extension DownloadPDFDelegate{
    func downloadUrl(urlString : String){}
}

extension UIDevice {

    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
           return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 > 0
        }
        return false
   }
}

class WebViewController: UIViewController , WKNavigationDelegate,WKUIDelegate {

    @IBOutlet weak var topOfWebHolderView: NSLayoutConstraint!
    var isFromReports = false
    var customerPhone : String!
    var phoneCode : String!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleInfoView: UIView!
    @IBOutlet var infoView: UIView!
    weak var delegate : DownloadPDFDelegate?
    @IBOutlet var webView: WKWebView!
    @IBOutlet weak var tempView: UIView!
    var cookie_rr : HTTPCookie!
    var isPreViewOffer : Bool = false
    var isRecieptView : Bool = false
    var previewOfferUrlString : String!
    var receiptEntryUrlString : String!
    var bookingFormPdfViewURL : String!
    var pdfURL : URL!
    var selectedProspect : REGISTRATIONS_RESULT!
    var isBookingFormApprovalPdfView : Bool = false
//    @IBOutlet var webView: UIWebView!
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
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if(isFromReports)
        {
            if(UIDevice.current.hasNotch){
                topOfWebHolderView.constant = -50
            }
            else{
                topOfWebHolderView.constant = -40
            }
        }
//        return
            
//        webView.translatesAutoresizingMaskIntoConstraints = false
//
//        if let newView = webView{
//
//            newView.centerXAnchor.constraint(equalTo: tempView.centerXAnchor).isActive = true
//            newView.centerYAnchor.constraint(equalTo: tempView.centerYAnchor).isActive = true
//
//            let topConstraint = NSLayoutConstraint(item: newView, attribute: .top, relatedBy: .equal, toItem: self.tempView, attribute: .top, multiplier: 1, constant: 0)
//            let bottomConstraint = NSLayoutConstraint(item: newView, attribute: .bottom, relatedBy: .equal, toItem: self.tempView, attribute: .bottom, multiplier: 1, constant: 0)
//            let leadingConstraint = NSLayoutConstraint(item: newView, attribute: .leading, relatedBy: .equal, toItem: self.tempView, attribute: .leading, multiplier: 1, constant: 0)
//            let trailingConstraint = NSLayoutConstraint(item: newView, attribute: .trailing, relatedBy: .equal, toItem: self.tempView, attribute: .trailing, multiplier: 1, constant: 0)
//
//            self.tempView.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
//
//        }

    }

    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        if(isPreViewOffer){
            return
        }
        webView.frame = tempView.frame
        
//        print(webView.frame)
//
//        print(tempView.frame)

    }
    @IBAction func downloadPDF(_ sender: Any) {

        
//           let temper = PDFViewController(nibName: "PDFViewController", bundle: nil)
//            temper.downloadButtonPressed(UIButton())
//
//        return
        
        if(isPreViewOffer){
            if(self.delegate != nil){
                self.delegate?.downloadUrl(urlString: previewOfferUrlString)
            }
            else{
                self.delegate?.downloadUrl(urlString: previewOfferUrlString)
            }
            
//            guard let url = URL(string: previewOfferUrlString) else { return }
//            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
//            var urlRequst = URLRequest.init(url: url)
//            urlRequst.addValue(RRUtilities.sharedInstance.keychain["Cookie"]!, forHTTPHeaderField: "Cookie")
//            urlRequst.addValue("RErootMobile", forHTTPHeaderField: "User-Agent")
//            let downloadTask = urlSession.downloadTask(with: urlRequst)
//            downloadTask.resume()
        }
        else if(isRecieptView){
            guard let url = URL(string: receiptEntryUrlString) else { return }
            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
            let downloadTask = urlSession.downloadTask(with: url)
            downloadTask.resume()
        }
    }
    //    func downLoadPdf(urlString : String){
//    }
    @IBAction func sharePDF(_ sender: Any) {
        var urlString = ""
        if(isPreViewOffer){
            urlString = previewOfferUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            self.sharePdfWhatsApp(pdfUrl: previewOfferUrlString)
        }
        if(isRecieptView){
            if(customerPhone == nil || phoneCode == nil){
                HUD.flash(.label("Customer details are unavailable to share"), delay: 1.0)
                return
            }
            urlString = receiptEntryUrlString!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            self.sharePdfWhatsApp(pdfUrl: self.receiptEntryUrlString)
        }
    }
    func sharePdfWhatsApp(pdfUrl : String){
        //"%@?text=%@"
//        let tempSTr = String(format: "https://wa.me/%@%@?text=%@", selectedProspect.userPhoneCode ?? "",selectedProspect.userPhone!,pdfUrl)
        var urlToOpenWhatsapp = ""
        if(isPreViewOffer){
           urlToOpenWhatsapp = String(format: "whatsapp://send?phone=%@%@&text=%@", selectedProspect.userPhoneCode ?? "91",selectedProspect.userPhone!,pdfUrl)
        }
        else if(isRecieptView){
            urlToOpenWhatsapp = String(format: "whatsapp://send?phone=%@%@&text=%@",phoneCode ?? "91",customerPhone,pdfUrl)
        }
//        let wtsAppUrl = String(format: "whatsapp://send?phone=%@%@&text=%@", selectedProspect.userPhoneCode ?? "",selectedProspect.userPhone!,pdfUrl)
        if let urlString = urlToOpenWhatsapp.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL) {
                    UIApplication.shared.open(whatsappURL)
                } else {
                    let ac = UIAlertController(title: "", message: "Please install whatsapp to contiue", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(ac, animated: true)
                }
            }
        }
    }

    func shouldShowButtons(shouldShow : Bool){
        self.downloadButton.isHidden = !shouldShow
        self.shareButton.isHidden = !shouldShow
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: NSNotification.Name("DOWNLOAD_ALERT"), object: nil)

        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                        isDirectory: true)
        print(temporaryDirectoryURL)
        
        self.shouldShowButtons(shouldShow: false)
        
        if(isRecieptView){
            topConstraint.constant = -25
            self.loadReceiptEntryPreView()
            return
        }
        else if(isPreViewOffer){
            topConstraint.constant = 0
            self.loadPreViewOffer(previewOfferUrl: previewOfferUrlString)
            return
        }
        else if(isBookingFormApprovalPdfView){
            topConstraint.constant = 0
            self.loadBookingFormUrlView()
            return
        }
        else{
            self.loadWebView()
        }
        self.view.bringSubviewToFront(titleInfoView)
        
    }
    @objc func showAlert(_ notification: NSNotification){
        
        if let dict = notification.userInfo as Dictionary? {

            let fileName = dict["fileName"] as! String
            
            let ac = UIAlertController(title: "PDF Downloaded", message: "\(fileName) has been saved at Downloads.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                
                let path = self.getDocumentsDirectory().absoluteString.replacingOccurrences(of: "file://", with: "REroot://")
                let url = URL(string: path)!
                

    //            print(path)
    //            print(url)
                
                UIApplication.shared.open(url)

            }))
            self.present(ac, animated: true)
        }

        
        
    }
    func getDocumentsDirectory() -> URL { // returns your application folder
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    func loadBookingFormUrlView(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        self.titleLabel.text = "BOOKING FORM"
        
        var string = bookingFormPdfViewURL
        
        string = string!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        var request = URLRequest.init(url: URL.init(string: string!)!)
        
        request.addValue("RErootMobile", forHTTPHeaderField: "User-Agent")
        request.setValue(RRUtilities.sharedInstance.keychain["Cookie"]!, forHTTPHeaderField: "Cookie")
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.dataDetectorTypes = [.all]
        configuration.preferences = preferences
        
        webView = WKCookieWebView.init(frame: tempView.frame, configuration: configuration)
        webView.navigationDelegate = self
        print(webView.frame.origin.y)
        
        tempView.addSubview(webView)
        
        HUD.show(.labeledProgress(title: "", subtitle: ""), onView: webView)
        
        webView.load(request)

    }
    func loadReceiptEntryPreView(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        self.titleLabel.text = "RECEIPT PREVIEW"

        var string = receiptEntryUrlString
        
        string = string!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        var request = URLRequest.init(url: URL.init(string: string!)!)
        
        request.addValue("RErootMobile", forHTTPHeaderField: "User-Agent")
        request.setValue(RRUtilities.sharedInstance.keychain["Cookie"]!, forHTTPHeaderField: "Cookie")
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.dataDetectorTypes = [.all]
        configuration.preferences = preferences
        
        webView = WKCookieWebView.init(frame: tempView.frame, configuration: configuration)
        webView.navigationDelegate = self
        print(webView.frame.origin.y)
        
        tempView.addSubview(webView)
        
        HUD.show(.labeledProgress(title: "", subtitle: ""), onView: webView)
        
        webView.load(request)

    }
    func loadPreViewOffer(previewOfferUrl : String){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        self.titleLabel.text = "OFFER PREVIEW"
        
//        if #available(iOS 11.0, *) {
//            let pdfView = PDFView.init()
//            if let pdfDocument = PDFDocument(url: URL.init(string: previewOfferUrl)!) {
//                pdfView.displayMode = .singlePageContinuous
//                pdfView.autoScales = true
//                // pdfView.displayDirection = .horizontal
//                pdfView.document = pdfDocument
//            }
//            pdfView.frame = tempView.frame
//            tempView.addSubview(pdfView)
//            return
//        } else {
//            // Fallback on earlier versions
//        }
        
                
        let string = previewOfferUrl //String(format:RRAPI.DASHBOARD_URL, UserDefaults.standard.value(forKey: "groupId") as! String)
        
//        string = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL.init(string: string) else{
            HUD.flash(.label("Couldn't load url"), delay: 2.0)
            self.back(UIButton())
            return
        }
        
        var request = URLRequest.init(url: url)
        
        request.addValue("RErootMobile", forHTTPHeaderField: "User-Agent")
        request.setValue(RRUtilities.sharedInstance.keychain["Cookie"]!, forHTTPHeaderField: "Cookie")
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.dataDetectorTypes = [.all]
        configuration.preferences = preferences
        
        webView = WKCookieWebView.init(frame: tempView.frame, configuration: configuration)
        webView.navigationDelegate = self
        print(webView.frame.origin.y)
        
        tempView.addSubview(webView)
        HUD.show(.labeledProgress(title: "", subtitle: nil), onView: webView)

        webView.load(request)
        
    }
    func loadWebView(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        
        var string = String(format:RRAPI.DASHBOARD_URL, UserDefaults.standard.value(forKey: "groupId") as! String)
//        print(string)
        string = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        var request = URLRequest.init(url: URL.init(string: string)!)
        
        request.addValue("RErootMobile", forHTTPHeaderField: "User-Agent")
        request.setValue(RRUtilities.sharedInstance.keychain["Cookie"]!, forHTTPHeaderField: "Cookie")
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.dataDetectorTypes = [.all]
        configuration.preferences = preferences
        
        if(isFromReports){
            let source = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=650'); document.getElementsByTagName('head')[0].appendChild(meta);"
            let userScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            configuration.userContentController.addUserScript(userScript)
        }

        webView = WKCookieWebView.init(frame: tempView.frame, configuration: configuration)
        webView.navigationDelegate = self
        print(webView.frame.origin.y)
        
        tempView.addSubview(webView)
        
        webView.load(request)
        
        HUD.show(.labeledProgress(title: "", subtitle: nil), onView: webView)
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!){
        print("loaded")
        HUD.hide(animated: true)
        
        if(isRecieptView || isPreViewOffer){
            self.shouldShowButtons(shouldShow: true)
        }
        
    
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
extension WebViewController : URLSessionDelegate{
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print(challenge)
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        print(error)
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        print("downloadLocation:", location)
        
        // create destination URL with the original pdf name
        guard let url = downloadTask.originalRequest?.url else { return }
        let documentsPath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        // delete original copy
        try? FileManager.default.removeItem(at: destinationURL)
        // copy from temp to Document
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
            self.pdfURL = destinationURL
            //Show Alert Downloaded
            print(self.pdfURL)
            

//            self.web
        } catch let error {
            print("Copy Error: \(error.localizedDescription)")
        }
        
    }
}
extension String
{
    func encodeUrl() -> String?
    {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    }
    func decodeUrl() -> String?
    {
        return self.removingPercentEncoding
    }
}

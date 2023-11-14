//
//  WebViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 09/10/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
import WebKit


@available(iOS 11.0, *)
class WebViewController: UIViewController , WKNavigationDelegate,WKUIDelegate {

    
    @IBOutlet var webView: WKWebView!
    @IBOutlet var tempWebView: UIWebView!
    @IBOutlet var tempView: UIView!
    var cookie : HTTPCookie!
//    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        let cookie = HTTPCookie(properties: [.domain : "",.path : "/",.secure: true,.name : "Cookie",.value : RRUtilities.sharedInstance.keychain["Cookie"]!])  //HTTPCookiePropertyKey : Any

        let websiteDataStore = WKWebsiteDataStore.nonPersistent()
        
            websiteDataStore.httpCookieStore.setCookie(cookie!, completionHandler: {
                let configuration = WKWebViewConfiguration()
                configuration.websiteDataStore = websiteDataStore
                
//                let userConroller = WKUserContentController.init()
//                let stringer = String(format: "document.cookie = '%@';", RRUtilities.sharedInstance.keychain["Cookie"]!)
//                //"document.cookie = 'TeskCookieKey1=TeskCookieValue1';document.cookie = 'TeskCookieKey2=TeskCookieValue2';"
//                print(stringer)
//                let cookieScript = WKUserScript.init(source: stringer, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
//                userConroller.addUserScript(cookieScript)
//
//                configuration.userContentController = userConroller
                
                let webView = WKCookieWebView.init(frame: self.tempView.frame, configuration: configuration)
                self.tempView.addSubview(webView)

                var string = String(format:RRAPI.DASHBOARD_URL, UserDefaults.standard.value(forKey: "groupId") as! String)
                print(string)
                string = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let url : URL = URL.init(string: string )!
                
                var requext = URLRequest.init(url: url)
                requext.httpShouldHandleCookies = true
                requext.mainDocumentURL = url
                requext.addValue("RErootMobile", forHTTPHeaderField: "User-Agent")
                print(RRUtilities.sharedInstance.keychain["Cookie"]!)
                requext.addValue(RRUtilities.sharedInstance.keychain["Cookie"]!, forHTTPHeaderField: "Cookie")

//                self.webView = WKWebView(frame: self.tempView.frame, configuration: configuration)
                
                let cookies = HTTPCookieStorage.shared.cookies ?? []
                for (cookie) in cookies {
                    webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
                }
 
                webView.navigationDelegate = self
                webView.uiDelegate = self
                /*
 
                 WKUserContentController* userContentController = WKUserContentController.new;
                 WKUserScript * cookieScript = [[WKUserScript alloc]
                 initWithSource: @"document.cookie = 'TeskCookieKey1=TeskCookieValue1';document.cookie = 'TeskCookieKey2=TeskCookieValue2';"
                 injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
                 // again, use stringWithFormat: in the above line to inject your values programmatically
                 [userContentController addUserScript:cookieScript];
                 WKWebViewConfiguration* webViewConfig = WKWebViewConfiguration.new;
                 webViewConfig.userContentController = userContentController;

                 */
                
                //@"document.cookie = 'TeskCookieKey1=TeskCookieValue1';document.cookie = 'TeskCookieKey2=TeskCookieValue2';"
                
                  //
                
                
//                webView.load(requext)
                
                
                if #available(iOS 11.0, *) {
                    var cookiestore = webView.configuration.websiteDataStore.httpCookieStore;
                    var cookieDict = [String : AnyObject]()
                    cookiestore.setCookie(cookie, completionHandler: ({
                        cookiestore.getAllCookies{ (cookies) in
                            for cookie in cookies {
                                cookieDict[cookie.name] = cookie.properties as AnyObject?
                            }
                            DispatchQueue.main.async {
                                webView.load(requext)
                            }
                        }
                    }))
                    
                } else {
                    // Fallback on earlier versions
                }

                
                
//                self.webView.load(URLRequest: requext)
                
            })
        
        
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void){
        var requext = navigationAction.request
        requext.setValue("RErootMobile", forHTTPHeaderField: "User-Agent")
        print(RRUtilities.sharedInstance.keychain["Cookie"]!)
        requext.setValue(RRUtilities.sharedInstance.keychain["Cookie"]!, forHTTPHeaderField: "Cookie")
        print("data decidePolicyFor navigationAction")
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        print("data decidePolicyFor URLAuthenticationChallenge")
        completionHandler(.useCredential,URLCredential.init(user: "admin@prestige.com", password: "siso@123", persistence: .forSession))
    }
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void){
        print("data decidePolicyFor navigationResponse")
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        print("data didStartProvisionalNavigation")
        
        let userConroller = WKUserContentController.init()
        let stringer = String(format: "document.cookie = '%@';", RRUtilities.sharedInstance.keychain["Cookie"]!)
        //"document.cookie = 'TeskCookieKey1=TeskCookieValue1';document.cookie = 'TeskCookieKey2=TeskCookieValue2';"
        print(stringer)
        let cookieScript = WKUserScript.init(source: stringer, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userConroller.addUserScript(cookieScript)
        
        webView.configuration.userContentController = userConroller

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

/*
 //    let url = "http://52.66.34.235:3000/business/prestige/reports"
 //        let tempUrl : URLRequest = URLRequest.init(url: URL.init(string: url)!)
 //        self.webView.loadRequest(tempUrl)
 
 /*
 
 NSURL *websiteUrl = [NSURL URLWithString:@"http://websites.inresto.com/demo1/online-order.html"];// [NSURL URLWithString:@"http://52.74.85.56:3000/public/widgets/onlineOrdering/menu/55df1f000eccee1858ef974f"];
 NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
 [self.webView loadRequest:urlRequest];
 
 
 */
 
 
 let preferences = WKPreferences()
 preferences.javaScriptEnabled = true
 
 let configuration = WKWebViewConfiguration()
 configuration.dataDetectorTypes = [.all]
 configuration.preferences = preferences
 //        webView.navigationDelegate = self
 //        tempWebView.customUserAgent = "RErootMobile"
 
 cookie = HTTPCookie(properties: [
 .domain: "reroot.com",
 .path: "/",
 .name: "Cookie",
 .value: RRUtilities.sharedInstance.keychain["Cookie"]!,
 .secure: "TRUE"
 //            .expires: NSDate(timeIntervalSinceNow: 31556926)
 ])!
 
 
 
 //        let cookie1 = HTTPCookie.self
 //        let cookieJar = HTTPCookieStorage.shared
 //
 //        for cookie in cookieJar.cookies! {
 //            cookieJar.deleteCookie(cookie)
 //        }
 
 
 
 /*
 
 WKUserScript * cookieScript = [[WKUserScript alloc]
 initWithSource: @"document.cookie = 'TeskCookieKey1=TeskCookieValue1';document.cookie = 'TeskCookieKey2=TeskCookieValue2';"
 injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
 // again, use stringWithFormat: in the above line to inject your values programmatically
 [userContentController addUserScript:cookieScript];
 WKWebViewConfiguration* webViewConfig = WKWebViewConfiguration.new;
 webViewConfig.userContentController = userContentController;
 
 */
 //"document.cookie = 'TeskCookieKey1=TeskCookieValue1';document.cookie = 'TeskCookieKey2=TeskCookieValue2';"
 
 //WKUserContentController* userContentController = WKUserContentController.new;
 
 let userContentController = WKUserContentController.init()
 let cookieScript = WKUserScript.init(source: String(format: "document.cookie =  %@", RRUtilities.sharedInstance.keychain["Cookie"]!), injectionTime: .atDocumentStart, forMainFrameOnly: false)
 userContentController.addUserScript(cookieScript)
 configuration.userContentController = userContentController
 
 let webView = WKCookieWebView.init(frame: tempView.frame, configuration: configuration)
 //        webView.navigationDelegate = self;
 //        webView.uiDelegate = self as! WKUIDelegate;
 
 //
 //
 var string = String(format:RRAPI.DASHBOARD_URL, UserDefaults.standard.value(forKey: "groupId") as! String)
 print(string)
 string = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
 let url : URL = URL.init(string: string )!
 
 var requext = URLRequest.init(url: url)
 requext.httpShouldHandleCookies = true
 requext.mainDocumentURL = url
 requext.addValue("RErootMobile", forHTTPHeaderField: "User-Agent")
 print(RRUtilities.sharedInstance.keychain["Cookie"]!)
 requext.addValue(RRUtilities.sharedInstance.keychain["Cookie"]!, forHTTPHeaderField: "Cookie")
 
 //        let cookies = HTTPCookieStorage.shared.cookies ?? []
 //        for (cookie) in cookies {
 //            if #available(iOS 11.0, *) {
 //                webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
 //            } else {
 //                // Fallback on earlier versions
 //            }
 //        }
 webView.configuration.applicationNameForUserAgent = "RErootMobile"
 if #available(iOS 11.0, *) {
 //            webView.configuration.websiteDataStore.httpCookieStore.setValue(RRUtilities.sharedInstance.keychain["Cookie"]!, forKey: "Cookie")
 webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
 
 } else {
 // Fallback on earlier versions
 }
 let cookies = HTTPCookieStorage.shared.cookies ?? []
 for (cookie) in cookies {
 if #available(iOS 11.0, *) {
 webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
 } else {
 // Fallback on earlier versions
 }
 }
 
 
 if #available(iOS 11.0, *) {
 var cookiestore = webView.configuration.websiteDataStore.httpCookieStore;
 var cookieDict = [String : AnyObject]()
 cookiestore.setCookie(cookie, completionHandler: ({
 cookiestore.getAllCookies{ (cookies) in
 for cookie in cookies {
 cookieDict[cookie.name] = cookie.properties as AnyObject?
 }
 DispatchQueue.main.async {
 webView.load(requext)
 }
 }
 }))
 
 } else {
 // Fallback on earlier versions
 }
 
 tempView.addSubview(webView)
 //        tempWebView.loadRequest(requext)
 tempWebView.isHidden = true
 
 return
 //        let myURL = URL(string: "http://mdhanunjay023@gmail.com:RR123@http://172.16.20.53:3000/business/Reroot%20Group/reports?fp=1/")
 //
 //
 //        var string = String(format:RRAPI.DASHBOARD_URL, UserDefaults.standard.value(forKey: "groupId") as! String)
 //        print(string)
 //        string = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
 //        //"http://172.16.20.53:3000/business/Reroot%20Group/reports?fp=1"
 //
 //
 ////        let tempStr = "https://developers.google.com/chart/interactive/docs/gallery/piechart" //"https://www.amcharts.com/demos/simple-column-chart/"
 //        let url : URL = URL.init(string: string )!
 //         requext = URLRequest.init(url: url)
 //
 //        requext.httpShouldHandleCookies = false
 //        requext.addValue("RErootMobile", forHTTPHeaderField: "User-Agent")
 //        print(RRUtilities.sharedInstance.keychain["Cookie"]!)
 //        requext.addValue(RRUtilities.sharedInstance.keychain["Cookie"]!, forHTTPHeaderField: "Cookie")
 //        webView.load(requext as URLRequest)
 //
 //        tempView.addSubview(webView)
 print("")

 */

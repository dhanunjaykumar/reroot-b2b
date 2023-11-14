//
//  ServerAPI.swift
//  REroot
//
//  Created by Dhanunjay on 21/03/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import Foundation
import Alamofire
import PKHUD
import CoreData
import AWSS3

enum Errors: Error {
    case noMcube
}


let S3BucketName = "demo_bucketName"

class AWSService {
    var preSignedURLString = ""

    
    let s3Config = RRUtilities.sharedInstance.model.getS3Config()
    
//    if(s3Config == nil || s3Config?.accessKeyId == nil)
//    {
//        return
//    }
//    let accessKey = s3Config!.bucket!
//    let secretKey = s3Config!.secretAccessKey!

    func getPreSignedURL( S3DownloadKeyName: String)->String{
        let getPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
        getPreSignedURLRequest.httpMethod = AWSHTTPMethod.GET
//        print(S3DownloadKeyName)
        getPreSignedURLRequest.key = S3DownloadKeyName
        getPreSignedURLRequest.bucket = "buildez"
        getPreSignedURLRequest.expires = Date(timeIntervalSinceNow: 900)
        
        AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPreSignedURLRequest).continueWith { (task:AWSTask<NSURL>) -> Any? in
            if let error = task.error as NSError? {
                print("Error: \(error)")
                return nil
            }
            self.preSignedURLString = (task.result?.absoluteString)!
            
//            let image =
            
            return nil
        }
        return self.preSignedURLString
    }
    
}



class ServerAPIs:NSObject{
    
        
    static func generateOTP(phoneNumber : String,completion: @escaping (Result<otpResult, Error>) -> ()){
        
        let headers: HTTPHeaders = [
                   "User-Agent" : "RErootMobile",
                   "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
               ]
        var parameters : Dictionary<String,Any> = [:]
        parameters["phone"] = phoneNumber
        parameters["module"] = 2
        
        AF.request(RRAPI.CREATE_OTP_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:headers).responseJSON{ response in
            switch response.result {
            case .success :
//                print(response.description)
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    let str = String(decoding: response.data ?? Data(), as: UTF8.self)
                    print(str)
                    
                    let urlResult = try JSONDecoder().decode(otpResult.self, from: responseData)
                    if urlResult.status == 1{
                        completion(.success(urlResult))
                    }
                    else if(urlResult.status == 0){
                        HUD.hide()
                        HUD.flash(.label(urlResult.msg ?? ""), delay: 1.0)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription), delay: 1.0)
                    completion(.failure(error))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completion(.failure(error))
            }
        }
            
    }
    static func resendOTP(phoneNumber : String,completion: @escaping (Result<otpResult, Error>) -> ()){
        
        let headers: HTTPHeaders = [
                   "User-Agent" : "RErootMobile",
                   "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
               ]
        var parameters : Dictionary<String,Any> = [:]
        parameters["phone"] = phoneNumber
        parameters["module"] = 2
        
        AF.request(RRAPI.RESEND_OTP_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:headers).responseJSON{ response in
            switch response.result {
            case .success :
//                print(response.description)
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    let str = String(decoding: response.data ?? Data(), as: UTF8.self)
                    print(str)
                    
                    let urlResult = try JSONDecoder().decode(otpResult.self, from: responseData)
                    if urlResult.status == 1{
                        completion(.success(urlResult))
                    }
                    else if(urlResult.status == 0){
                        HUD.hide()
                        HUD.flash(.label(urlResult.msg ?? ""), delay: 1.0)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription), delay: 1.0)
                    completion(.failure(error))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completion(.failure(error))
            }
        }
    }
    static func verifyOTP(phoneNumber : String,otpStr : String,completion: @escaping (Result<otpResult, Error>) -> ()){
        
        let headers: HTTPHeaders = [
                   "User-Agent" : "RErootMobile",
                   "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
               ]
        var parameters : Dictionary<String,Any> = [:]
        parameters["phone"] = phoneNumber
        parameters["module"] = 2
        parameters["otp"] = otpStr
        
        AF.request(RRAPI.VERIFY_OTP_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:headers).responseJSON{ response in
            switch response.result {
            case .success :
//                print(response.description)
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    let str = String(decoding: response.data ?? Data(), as: UTF8.self)
                    print(str)
                    
                    let urlResult = try JSONDecoder().decode(otpResult.self, from: responseData)
                    if urlResult.status == 1{
                        completion(.success(urlResult))
                    }
                    else if(urlResult.status == 0){
                        HUD.hide()
                        HUD.flash(.label(urlResult.msg ?? ""), delay: 1.0)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription), delay: 1.0)
                    completion(.failure(error))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    static func getSingleSingedUrl(url : String)->String{
     
//        var signedUrls : String = ""
        
//        let accessKey = "AKIAJT34SDWYDXXDLD4Q"
//        let secretKey = "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"

//        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)

        let key = url.replacingOccurrences(of: "https://s3-ap-south-1.amazonaws.com/buildez/", with: "").replacingOccurrences(of: "https://s3.ap-south-1.amazonaws.com/buildez/", with: "").replacingOccurrences(of: "https://buildez.s3.ap-south-1.amazonaws.com/", with: "").replacingOccurrences(of: "+", with: " ").replacingOccurrences(of: "%20", with: " ")
        
        
//        objectId.replace("https://s3-ap-south-1.amazonaws.com/buildez/", "")
//                                .replace("https://s3.ap-south-1.amazonaws.com/buildez/", "")
//                                .replace("https://buildez.s3.ap-south-1.amazonaws.com/", "")
//                                .replace("%20", " ")
//                                .replace("+", " ")
        
        let signedUrl = AWSService().getPreSignedURL(S3DownloadKeyName: key)
        
        return signedUrl

    }
    static func getSignedUrls(urls : [String])->[String]{
        
        var signedUrls : [String] = []
        
//        let accessKey = "AKIAJT34SDWYDXXDLD4Q"
//        let secretKey = "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"
//
//        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
//        let configuration = AWSServiceConfiguration(region: .APSouth1, credentialsProvider: credentialsProvider)
//
//        AWSS3PreSignedURLBuilder.register(with:configuration!, forKey: accessKey)
//        AWSServiceManager.default().defaultServiceConfiguration = configuration

        for eachUrl in urls{

//            let signedUrl = AWSService().getPreSignedURL(S3DownloadKeyName: "5f807c80ac27900f119f6d8c/button/GeFvQkBbSLaMdpKXF1Zv_bigstock-Aerial-View-Of-Blue-Lakes-And--227291596imagejpeg.jpg")
            
//            let key = eachUrl.replacingOccurrences(of: "https://s3-ap-south-1.amazonaws.com/buildez/", with: "")
            
            let key = eachUrl.replacingOccurrences(of: "https://s3-ap-south-1.amazonaws.com/buildez/", with: "").replacingOccurrences(of: "https://s3.ap-south-1.amazonaws.com/buildez/", with: "").replacingOccurrences(of: "https://buildez.s3.ap-south-1.amazonaws.com/", with: "").replacingOccurrences(of: "+", with: " ").replacingOccurrences(of: "%20", with: " ")

            
            let signedUrl = AWSService().getPreSignedURL(S3DownloadKeyName: key)

            if(signedUrl.count > 0){
                signedUrls.append(signedUrl)
            }
        }
        
        return signedUrls
        
    }

    static func getApprovalById(approvalId : String,completion: @escaping (Result<APPROVAL, Error>) -> ()){
     
        let headers: HTTPHeaders = [
                   "User-Agent" : "RErootMobile",
                   "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
               ]
        var parameters1 : Dictionary<String,Any> = [:]
        parameters1["src"] = 3
        parameters1["_id"] = approvalId
        
        AF.request(RRAPI.API_GET_APPROVAL_BY_ID, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers:headers).responseJSON{ response in
                    switch response.result {
                    case .success :
//                        print(response.description)
                        do{
                            guard let responseData = response.data else {
                                print("Error: did not receive data")
                                return
                            }
//                            let str = String(decoding: response.data ?? Data(), as: UTF8.self)
//                            print(str)
                            
                            let urlResult = try JSONDecoder().decode(Approval_By_Id_Result.self, from: responseData)
//                            print(urlResult)
                            if urlResult.status == 1{
                                if(urlResult.approval != nil){
                                    completion(.success(urlResult.approval!))
                                }
                                else{
                                    HUD.flash(.label("Something Went wrong in getApproval"), delay: 1.0)
                                }
                            }
                            else if(urlResult.status == 0){
                                HUD.hide()
                                HUD.flash(.label(urlResult.msg ?? ""), delay: 1.0)
        //                        HUD.flash(.label(urlResult,msg ?? ""), delay:1.0)
                            }
                        }
                        catch let error{
                            HUD.flash(.label(error.localizedDescription), delay: 1.0)
                            completion(.failure(error))
                        }
                        break;
                    case .failure(let error):
                        HUD.hide()
                        print(error)
                        completion(.failure(error))
                    }
        }
            
    }
        
    static func getProspectById(pid : String,completion: @escaping (Result<REGISTRATIONS_RESULT, Error>) -> ()){
        
        let headers: HTTPHeaders = [
                   "User-Agent" : "RErootMobile",
                   "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
               ]
        var parameters1 : Dictionary<String,Any> = [:]
        parameters1["src"] = 3
        parameters1["pid"] = pid
//        print(RRAPI.API_GET_PROSPECT_BY_ID)
        AF.request(RRAPI.API_GET_PROSPECT_BY_ID, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers:headers).responseJSON{ response in
            switch response.result {
            case .success :
//                print(response.description)
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
//                    let str = String(decoding: response.data ?? Data(), as: UTF8.self)
//                    print(str)
                    
                    let urlResult = try JSONDecoder().decode(ProspectByIdOutput.self, from: responseData)
                    if urlResult.status == 1{
                        if(urlResult.result?.count ?? 0 > 0){
                            completion(.success(urlResult.result![0]))
                        }
                    }
                    else if(urlResult.status == 0){
                        HUD.hide()
                        HUD.flash(.label(urlResult.msg ?? ""), delay: 1.0)
//                        HUD.flash(.label(urlResult,msg ?? ""), delay:1.0)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription), delay: 1.0)
                    completion(.failure(error))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completion(.failure(error))
            }
        }
        
    }
    static func updateSiteVisitedDate(parameters : Dictionary<String,Any>,completion: @escaping (Result<Bool, Error>) -> ()){
            
        let headers: HTTPHeaders = [
                   "User-Agent" : "RErootMobile",
                   "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
               ]
        var parameters1 = parameters
        parameters1["src"] = 3
        AF.request(RRAPI.API_EDIT_SV_COMPLETION_DATE, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers:headers).responseJSON{ response in
            switch response.result {
            case .success :
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(COMMON_OUTPUT.self, from: responseData)
                    if urlResult.status == 1{
                        completion(.success(true))
                    }
                    else{
                        completion(.success(false))
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription), delay: 1.0)
                    completion(.failure(error))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    static func addCosFollowUp(parameters : Dictionary<String,Any>,completion: @escaping (Result<Bool, Error>) -> ()){

        let headers: HTTPHeaders = [
                   "User-Agent" : "RErootMobile",
                   "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
               ]
        var parameters1 = parameters
        parameters1["src"] = 3

        AF.request(RRAPI.API_OUTSTANDING_FOLLOWUP, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers:headers).responseJSON{ response in
            switch response.result {
            case .success :
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(COMMON_OUTPUT.self, from: responseData)
                    if urlResult.status == 1{
                        completion(.success(true))
                    }
                    else{
                        completion(.success(false))
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription), delay: 1.0)
                    completion(.failure(error))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completion(.failure(error))
            }
        }
        
    }
    static func getOutstandingTimeline(unitId : String,customerId : String,completion: @escaping (Result<[Cof], Error>) -> ()){
        
        let headers: HTTPHeaders = [
                   "User-Agent" : "RErootMobile",
                   "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
               ]
        
        let urlString = String(format: RRAPI.API_OUTSTANDING_FOLLOWUP_TIMELINE, unitId,customerId)
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{ response in
            switch response.result {
            case .success :
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(OutstandingTimelineResult.self, from: responseData)
                    if let cofs = urlResult.cofs{
                        completion(.success(cofs))
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription), delay: 1.0)
                    completion(.failure(error))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completion(.failure(error))
            }
        }

    }
    static func getOutstandingsForSelectedProject(outStandingParameters : OutStanding,completion: @escaping (Result<Bool, Error>) -> ()){
        
        let headers: HTTPHeaders = [
                   "User-Agent" : "RErootMobile",
                   "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
               ]
        var urlString = String(format: RRAPI.API_GET_OUTSTANDINGS,outStandingParameters.prId)
        urlString.append("&range=-1")
        if(!outStandingParameters.blId.isEmpty){
            urlString.append(String(format: "&block=%@", outStandingParameters.blId))
        }
        if(!outStandingParameters.twId.isEmpty){
            urlString.append(String(format: "&tower=%@", outStandingParameters.twId))
        }
        if(!outStandingParameters.uId.isEmpty){
            urlString.append(String(format: "&unit=%@", outStandingParameters.uId))
        }
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{ response in
            switch response.result {
            case .success :
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(OutstandingsResult.self, from: responseData)
                    if let cos = urlResult.cos{
                        RRUtilities.sharedInstance.model.writeOutstandings(cos: cos, completionHandler: { (response, error) in
                            completion(.success(true))
                        })
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription), delay: 1.0)
                    completion(.failure(error))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    static func getGenerals(completion: @escaping (Result<Bool, Error>) -> ()){

        let headers: HTTPHeaders = [
                   "User-Agent" : "RErootMobile",
                   "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
               ]
        
        AF.request(RRAPI.API_GET_GENERALS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{
            response in
            switch response.result {
            case .success :
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(Generals.self, from: responseData)
                    if let generals = urlResult.generals{
                        RRUtilities.sharedInstance.model.writeGeneralsToDB(generals: generals)
                    }
                    completion(.success(true))
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completion(.failure(error))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completion(.failure(error))
            }
        }
    }
    static func prospectCall(viewType : Int, prospectId : String,custNumber: String,exeNumber : String,completion: @escaping (Result<ProspectCallOutput, Error>) -> ()){
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]

        var parametersDict : Dictionary<String,Any> = [:]
        parametersDict["viewType"] = viewType
        parametersDict["pid"] = prospectId
        parametersDict["custNumber"] = custNumber
        if Int(exeNumber) != nil{
            parametersDict["exeNumber"] = exeNumber
        }
        else{
            parametersDict["exeNumber"] = "9916840035"
        }

//        print(parametersDict)
        parametersDict["src"] = 3

        
        AF.request(RRAPI.API_PROSPECT_CALL, method: .post, parameters: parametersDict, encoding: JSONEncoding.default, headers:headers).responseJSON{
            response in
//            print(response)
            switch response.result {
            case .success :
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(ProspectCallOutput.self, from: responseData)
                    if(urlResult.status == 0){
                        throw Errors.noMcube
                    }
                    else{
                        completion(.success(urlResult))
                    }
                }
                catch let error{
//                    HUD.flash(.label(error.localizedDescription))
                    completion(.failure(error))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completion(.failure(error))
            }
        }

    }
    
    static func getOldCustomers(completion: @escaping (Result<[CommissionUser], Error>) -> ()){
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        AF.request(RRAPI.API_GET_OLD_CUSTOMERS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{
            response in
            switch response.result {
            case .success :
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(COMMISSION_USERS_OUTPUT.self, from: responseData)
                    completion(.success(urlResult.users ?? []))
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completion(.failure(error))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completion(.failure(error))
            }
        }
    }

    static func getCustomers(completion: @escaping (Result<[CommissionUser], Error>) -> ()){
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        AF.request(RRAPI.API_GET_CUSTOMERS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{
            response in
            switch response.result {
            case .success :
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(COMMISSION_USERS_OUTPUT.self, from: responseData)
                    completion(.success(urlResult.customers ?? []))
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completion(.failure(error))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completion(.failure(error))
            }
        }
    }

    static func getEmployeesForCommissions(completion: @escaping (Result<[CommissionUser], Error>) -> ()){
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        AF.request(RRAPI.GET_COMMISSION_EMPLOYEES, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{
            response in
            switch response.result {
            case .success :
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(COMMISSION_USERS_OUTPUT.self, from: responseData)
                    completion(.success(urlResult.users ?? []))
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completion(.failure(error))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completion(.failure(error))

            }
        }
    }
    
    static func getCommisionsInfo(){
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        AF.request(RRAPI.GET_COMMISSIONS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{
            response in
            switch response.result {
            case .success :
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(COMMISSOIN_API_RESULT.self, from: responseData)
                    
                    if(urlResult.status == 1){
                        RRUtilities.sharedInstance.model.writeCommissionsToDB(commissions: urlResult.commissionconfigs ?? [])
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
            }
        }
    }
    static func getSchemes(){
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        AF.request(RRAPI.GET_SCHEMES, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{
            response in
            switch response.result {
            case .success :
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    let urlResult = try JSONDecoder().decode(SCHEMES_API_RESULT.self, from: responseData)
                    
                    if(urlResult.status == 1){
                        RRUtilities.sharedInstance.model.writeSchemesToDB(schmes: urlResult.schemes ?? [])
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
            }
        }
        
    }
    static func getUnitPreviewPrice(regInfo : String?,unitID :String,scheme : String?,completionHandler: @escaping (BOOKING_FORM_RESULT?, Error?) -> ()){
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        let urlString = String(format:RRAPI.API_PREVIEW_PRICE, unitID,regInfo ?? "",scheme ?? "")
//        print(urlString)
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{
            response in
            switch response.result {
            case .success :
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(BOOKING_FORM_RESULT.self, from: responseData)

                    if(urlResult.status == 1){
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == -1){
                        completionHandler(nil,nil)
                    }
                }
                catch let parseError as NSError {
                    print("JSON Error \(parseError.localizedDescription)")
                    completionHandler(nil,nil)
                }
                break;
            case .failure(let error):
                HUD.hide()
                completionHandler(nil,nil)
                print(error)
            }
        }

    }
    
    static func getPreviewOfferUrl(urlString : String,completionHandler: @escaping (PREVIEW_OFFER_RESULT?, Error?) -> ()){
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{
            response in
            switch response.result {
            case .success :
//                print(response)
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(PREVIEW_OFFER_RESULT.self, from: responseData)
                    
                    if(urlResult.status == 1){
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == 0){
                        let tempResult = PREVIEW_OFFER_RESULT(status: 0, url: "",msg: urlResult.msg ?? "")
                        completionHandler(tempResult,nil)
                    }
                    else if(urlResult.status == -1){
                        let tempResult = PREVIEW_OFFER_RESULT(status: -1, url: "",msg: urlResult.msg ?? "")
                        completionHandler(tempResult,nil)
                    }
                }
                catch let parseError as NSError {
                    print("JSON Error \(parseError.localizedDescription)")
                    let tempResult = PREVIEW_OFFER_RESULT(status: -1, url: "",msg: "")
                    completionHandler(tempResult,nil)
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
            }
        }
    }
    static func getProjectList(completionHandler: @escaping (Bool?, Error?) -> ()){
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        AF.request(RRAPI.PROJECTS_URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON{
            response in
            switch response.result {
            case .success :
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    
                    let urlResult = try JSONDecoder().decode(projectsResult.self, from: responseData)
                    
                    if(urlResult.status == 1){
                        let isWritten = RRUtilities.sharedInstance.model.writeAllProjectsToDB(projectsArray: urlResult.projects ?? [])
                        if(isWritten){
                            completionHandler(true,nil)
                        }
                        else{
                            completionHandler(false,nil)
                        }
                    }
                    else if(urlResult.status == -1){
                        //                        self.showLoginScreenOnAuthFailure()
                        //                        HUD.hide()
                        completionHandler(false,nil)
                        return
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
            }
        }
    }
    
    // MARK: - PROJECT SET UP CALLS
    static func getCustomSetUpDetails()
    {
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
//        HUD.show(.labeledProgress(title: "", subtitle: nil))
        
//        let anotherURl = RRAPI.API_GET_CUSTOM_BOOKING_SETUP
        
//        print(anotherURl)
        
        AF.request(RRAPI.API_GET_CUSTOM_BOOKING_SETUP, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success :
                //                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                do{
                    let urlResult = try JSONDecoder().decode(BOOKING_FORM_SET_UP.self, from: responseData)
                    
                    if(urlResult.status == 1){
                        RRUtilities.sharedInstance.customBookingFormSetUp = urlResult.BookingFormSetup
                        if(urlResult.BookingFormSetup?.paymentTowards?.count ?? 0 > 0){
                            RRUtilities.sharedInstance.model.writePaymentToWards(paymentToWards: RRUtilities.sharedInstance.customBookingFormSetUp!.paymentTowards!)
                        }
                        //                    print(RRUtilities.sharedInstance.customBookingFormSetUp)
                        if(urlResult.BookingFormSetup?.currency?.count ?? 0 > 0){
                            RRUtilities.sharedInstance.model.writeCurrencies(currencies: (RRUtilities.sharedInstance.customBookingFormSetUp.currency)!)
                        }
                    }
                    else if(urlResult.status == -1){
                        
                    }
                    else{
                        
                    }
                    
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                
                HUD.hide()
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
            }
        }
    }
    static func getDefaultSetup(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
//        HUD.show(.progress)
        
//        let urlString = String(format: RRAPI.API_GET_DEFAULT_BOOKING_SETUP)
        
//        print(urlString)
        
        AF.request(RRAPI.API_GET_DEFAULT_BOOKING_SETUP, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(BOOKING_FORM_SET_UP.self, from: responseData)
//                    print(urlResult)
                    
                    if(urlResult.status == 1){
                        RRUtilities.sharedInstance.defaultBookingFormSetUp = urlResult.defaults
//                        print(RRUtilities.sharedInstance.defaultBookingFormSetUp)
                        if(urlResult.BookingFormSetup?.paymentTowards?.count ?? 0 > 0){
                            RRUtilities.sharedInstance.model.writePaymentToWards(paymentToWards: RRUtilities.sharedInstance.defaultBookingFormSetUp!.paymentTowards!)
                        }
                        if(urlResult.BookingFormSetup?.currency?.count ?? 0 > 0){
                            RRUtilities.sharedInstance.model.writeCurrencies(currencies: (RRUtilities.sharedInstance.defaultBookingFormSetUp?.currency)!)
                        }
                    }
                    else if(urlResult.status == -1){
                    }
                    else if(urlResult.status == 0){ ///fail status
                    }
                    
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    
    // MARK: - AGREEMENTS
    static func updateAgreemenetStatus(forUnit : String,type:Int,modifiedAST : [AST],forId : String?,completionHandler: @escaping (AST_UPDATE_OUTPUT?, Error?) -> ()){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        var parameters : Dictionary<String,Any> = [:]
        parameters["_id"] = forId
        parameters["unit"] = forUnit
        parameters["type"] = type
//        print(modifiedAST.description)
        
        var tempAsts : [Dictionary<String,Any>] = []
        
        for eachDict in modifiedAST{
            var tempDict : Dictionary<String,Any> = [:]
            tempDict["_id"] = eachDict.id
            tempDict["dates"] = eachDict.dates
            tempDict["name"] = eachDict.name
            
            tempAsts.append(tempDict)
        }
        
        parameters["trackingDetails"] = tempAsts
        parameters["src"] = 3
        
//        print(parameters)
//        print(RRAPI.API_UPDATE_TRACKER_DETAILS)
        AF.request(RRAPI.API_UPDATE_TRACKER_DETAILS, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success :
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                do{
                    let urlResult = try JSONDecoder().decode(AST_UPDATE_OUTPUT.self, from: responseData)
                    
                    if(urlResult.status == 1){
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == 0 || urlResult.status == -1){
                        completionHandler(urlResult,nil)
                    }
                    else{
                        completionHandler(nil,nil)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }

                break;
            case .failure(let error):
                print(error)
                completionHandler(nil,error)
            }
        }
        
        
    }
    static func getAggreementDatesByType(forUnit : String,type : Int,completionHandler: @escaping (AST_DETAILS?, Error?) -> ()){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        let urlString = String(format: RRAPI.API_GET_TRACKER_DETAILS, forUnit,type) //passing

        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success :
                //                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                do{
                    
                    let urlResult = try JSONDecoder().decode(AST_DETAILS.self, from: responseData)

                    if(urlResult.status == 1){
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == -1){
                        completionHandler(nil,nil)
                    }
                    else{
                        completionHandler(nil,nil)
                    }

                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }
                
                //                HUD.hide()
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completionHandler(nil,nil)
            }
        }
        
    }
    
    
    // MARK: - RECEIPT ENTRY
    static func converCurrency(fromCurrencyCode : String,toCurrencyCode : String,completionHandler: @escaping (Bool,Double,Error?) -> ()){
        
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]

        let currencyConvertCode = String(format: "%@_%@", fromCurrencyCode,toCurrencyCode)
        
        let urlSting =  String(format:RRAPI.API_CONVERT_CURRENCY,currencyConvertCode)
        
//        print(urlSting)
        
        AF.request(urlSting, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                do{
                    guard let urlResult : Dictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                    }
                    let valueDict : Dictionary<String,Double> = urlResult[currencyConvertCode] as! Dictionary<String, Double>
                    let value = valueDict["val"]
//                    print(valueDict)
                    
                    completionHandler(true,value!,nil)
                    return
                }
                catch{
                    completionHandler(false,0.0,nil)

                }
            break
            case .failure(let error):
                print(error)
                HUD.hide()
                HUD.flash(.label(error.localizedDescription))
                completionHandler(false,0.0,nil)
                break
            }
        }
    }
    static func getReceiptEntrisCount(urlString : String,tab: Int,completionHandler: @escaping (Bool, Error?) -> ()){
        
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]

        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                //                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                do{
                                    let urlResult = try JSONDecoder().decode(RECEIPT_ENTRIES_COUNT_OUTPUT.self, from: responseData)
                    //                print(tab)
                                    if(urlResult.status == 1){
                                        RRUtilities.sharedInstance.model.writeReceitEntriesCount(entriesCount: urlResult.result ?? [], tab: tab, completionHandler: {responseObject, error in
                                            completionHandler(responseObject!,error)
                                        })
                                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(false,error)
                }
                HUD.hide()
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                HUD.flash(.label(error.localizedDescription))
                completionHandler(false,error)
                break
            }
        }
    }
    static func getReceiptEntries(projectId : String,tab : Int,completionHandler: @escaping (Bool, Error?) -> ()){
        
        let headers : HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        let urlSting =  String(format:RRAPI.API_GET_RECEIPT_ENTRIES,tab,projectId)
        
        AF.request(urlSting, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                //                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                do{
                                    let urlResult = try JSONDecoder().decode(RECEIPT_ENTRIES_OUTPUT.self, from: responseData)
                                    
                                    if(urlResult.status == -1){
                    //                    RRUtilities.sharedInstance.showLoginScreenOnAuthFailure(navigationController: self.navigationController!)
                                        completionHandler(false,nil)
                                        return
                                    }
                                    if(urlResult.status == 1){
                                        
                                        RRUtilities.sharedInstance.model.writeReceiptEntries(receiptEntries: urlResult.receiptEntries!,tab: 1,completionHandler: {responseObject, error in
                                            if(responseObject != nil && responseObject!){
                                                completionHandler(true,nil)
                    //                            DispatchQueue.main.async {
                    //                                print("ENTERED INTO ENTRIES VIEW **")
                    //                                let receiptsController = ReceiptEntriesViewController(nibName: "ReceiptEntriesViewController", bundle: nil)
                    //                                receiptsController.isProjectWise = true
                    //                                receiptsController.selectedEntry = self.receiptEntriesFetchedResultsController.object(at: self.selectedIndexPath)
                    //                                receiptsController.tab = 1
                    //                                self.navigationController?.pushViewController(receiptsController, animated: true)
                    //                                return
                    //                            }
                                            }
                                            else{
                                                HUD.flash(.label("Something went wrong please try again"), delay: 1.0)
                                                completionHandler(false,nil)
                                            }
                                        })
                                    }

                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                HUD.flash(.label(error.localizedDescription))
                completionHandler(false,nil)
                break
            }
        }
        
    }
    static func editOrCreateReceiptEntry(urlString : String,parameters : Dictionary<String,Any>,isEditing : Bool,completionHandler: @escaping (RECEIPT_CREATE_ENTRY_OUTPUT?, Error?) -> ()){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
//
//        if(isEditing){
//
//        }
//        else{
//
//        }
        
        var parameters1 = parameters
        parameters1["src"] = 3
        
        AF.request(urlString, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success :
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                do{
                    let urlResult = try JSONDecoder().decode(RECEIPT_CREATE_ENTRY_OUTPUT.self, from: responseData)
                    
                    if(urlResult.status == 1){
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == -1){
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == 0){
                        completionHandler(urlResult,nil)
                    }

                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }
//                HUD.hide()
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completionHandler(nil,nil)
            }
        }
    }

    static func addReceiptEntry(paramters : Dictionary<String,Any>,urlString : String){
        
        if(!RRUtilities.sharedInstance.getNetworkStatus())
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        var parameters1 = paramters
        parameters1["src"] = 3

        HUD.show(.progress)

        AF.request(urlString, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(COMMON_OUTPUT.self, from: responseData)
                    //                    print(urlResult)
                    if(urlResult.status == 1){
                        
//                        completionHandler(true,nil)
                        
                    }
                    else if(urlResult.status == -1){
//                        completionHandler(false,nil)
                    }
                    else if(urlResult.status == 0){ ///fail status
//                        completionHandler(false,nil)
                    }
                }
                
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    static func getBookedOrSoldUnitClients(selectedUnitId : String,completionHandler: @escaping (BOOKED_UNIS_CLIENTS_API_RESULT?, Error?) -> ()){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.progress)
        
        let urlString = String(format: RRAPI.API_GET_BOOKED_CLIENTS, selectedUnitId)
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                                print(response)
                do{
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(BOOKED_UNIS_CLIENTS_API_RESULT.self, from: responseData)
                    //                    print(urlResult)
                    if(urlResult.status == 1){
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == -1){
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == 0){ ///fail status
                        completionHandler(urlResult,nil)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    static func getUnitTransactions(unitID : String,completionHandler: @escaping (UNIT_TRANSACTIONS_OUTPUT?, Error?) -> ())->()
    {
        if(!RRUtilities.sharedInstance.getNetworkStatus())
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.progress)
        print(String(format: RRAPI.API_GET_UNIT_TRANSACTIONS, unitID))
//        let urlString = String(format: RRAPI.API_GET_UNIT_TRANSACTIONS, unitID)
        AF.request(String(format: RRAPI.API_GET_UNIT_TRANSACTIONS, unitID), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(UNIT_TRANSACTIONS_OUTPUT.self, from: responseData)
                    completionHandler(urlResult,nil)
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                completionHandler(nil,nil)
                break
            }
        }
    }
    
    static func searchForIfscCode(ifscCode : String,completionHandler: @escaping (IFSC_CODE_OUTPUT?, Error?) -> ())->()
    {
        
        if(!RRUtilities.sharedInstance.getNetworkStatus())
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        print(ifscCode.uppercased())
        print(String(format: RRAPI.API_SEARCH_IFSC, ifscCode.uppercased()))
        
        HUD.show(.progress)
        
        AF.request(String(format: RRAPI.API_SEARCH_IFSC, ifscCode.uppercased()), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    if(response.description != "SUCCESS: Not Found"){
                        let urlResult = try JSONDecoder().decode(IFSC_CODE_OUTPUT.self, from: responseData)
                        completionHandler(urlResult,nil)
                    }
                    else{
                        completionHandler(nil,nil)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    
    static func getProjectBank(projectID : String,completionHandler: @escaping (PROJECT_BANK_OUTPUT?, Error?) -> ())->()
    {
        if(!RRUtilities.sharedInstance.getNetworkStatus())
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.progress)
        
        let urlString = String(format: RRAPI.API_GET_PROJECT_BANK, projectID)
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(PROJECT_BANK_OUTPUT.self, from: responseData)
                    //                    print(urlResult)
                    if(urlResult.status == 1){
                        
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == -1){
                        completionHandler(nil,nil)
                    }
                    else if(urlResult.status == 0){
                        completionHandler(nil,nil)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    // MARK: - APPROVALS
    static func rejectIncomingApproval(parameteres : Dictionary<String,String>,completionHandler: @escaping (Bool, Error?) -> ())->(){
    
    //{"id":"5c8f5f6cacb9fb3684bfd1ed","approval_type":1,"reference":"5c8f5f6cacb9fb3684bfd1e9"}
        
        if(!RRUtilities.sharedInstance.getNetworkStatus())
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        var parameters1 = parameteres
        parameters1["src"] = "3"

        HUD.show(.progress)
        
        AF.request(RRAPI.API_REJECT_INCOMING_APPROVAL, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(COMMON_OUTPUT.self, from: responseData)
                    //                    print(urlResult)
                    if(urlResult.status == 1){
                        
                        completionHandler(true,nil)

                    }
                    else if(urlResult.status == -1){
                        completionHandler(false,nil)
                    }
                    else if(urlResult.status == 0){ ///fail status
                        completionHandler(false,nil)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(false,nil)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    
    static func approveIncomingApproval(parameteres : Dictionary<String,String>,completionHandler: @escaping (Bool, Error?) -> ())->()
    {
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        var parameters1 = parameteres
        parameters1["src"] = "3"

        HUD.show(.progress)
        
        AF.request(RRAPI.API_APPROVE_INCOMING_APPROVAL, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(COMMON_OUTPUT.self, from: responseData)
                    //                    print(urlResult)
                    if(urlResult.status == 1){
                        
                        //Delete after accept or reject
                        
//                        RRUtilities.sharedInstance.model.writeApprovals(approvals: urlResult.approvals!,isIncoming:true, completionHandler: { (response, error) in
//                            if(response!){
//                                print("written")
//                                print("approval coutn \(RRUtilities.sharedInstance.model.getAllApprovalCount())")
//                            }
//                            else{
//                                print("not written")
//                            }
//                        })
                        completionHandler(true,nil)
                        
                    }
                    else if(urlResult.status == -1){
                        completionHandler(false,nil)
                    }
                    else if(urlResult.status == 0){ ///fail status
                        completionHandler(false,nil)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription), delay: 1.0)
                    completionHandler(false,nil)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
        
    }
    
    static func getIncomingApprovals(completionHandler: @escaping (Bool, Error?) -> ())->()
    {
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.progress)
        print(RRAPI.API_GET_INCOMING_DISCOUNT_APPROVALS)
        AF.request(RRAPI.API_GET_INCOMING_DISCOUNT_APPROVALS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(DISCOUNT_APPROVAL_OUTPUT.self, from: responseData)
                    //                    print(urlResult)
                    if(urlResult.status == 1){
                        RRUtilities.sharedInstance.model.writeApprovals(approvals: urlResult.approvals!,isIncoming:true, completionHandler: { (response, error) in
                            if(response!){
                                print("written")
                                print("approval coutn \(RRUtilities.sharedInstance.model.getAllApprovalCount())")
                            }
                            else{
                                print("not written")
                            }
                        })
                        completionHandler(true,nil)
                    }
                    else if(urlResult.status == -1){
                        completionHandler(false,nil)
                    }
                    else if(urlResult.status == 0){ ///fail status
                        completionHandler(false,nil)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(false,nil)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                completionHandler(false,nil)
                break
            }
        }
    }
    static func getOutGoingDiscountApprovals(completionHandler: @escaping (Bool?, Error?) -> ())->(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.progress)
        print(RRAPI.API_GET_OUTGOING_DISCOUNT_APPROVALS)
        AF.request(RRAPI.API_GET_OUTGOING_DISCOUNT_APPROVALS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(DISCOUNT_APPROVAL_OUTPUT.self, from: responseData)
                    //                    print(urlResult)
                    if(urlResult.status == 1){
                        
                        RRUtilities.sharedInstance.model.writeApprovals(approvals: urlResult.approvals!,isIncoming:false, completionHandler: { (response, error) in
                            if(response!){
                                print("written")
                                print("approval outgoing cunt \(RRUtilities.sharedInstance.model.getAllApprovalCount())")
                                completionHandler(true,nil)
                            }
                            else{
                                print("not written")
                                completionHandler(false,nil)
                            }
                        })
                        
                    }
                    else if(urlResult.status == -1){
                        completionHandler(false,nil)
                    }
                    else if(urlResult.status == 0){ ///fail status
                        completionHandler(false,nil)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(false,nil)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
        
    }
    // MARK: - PRESALES PROSPECTs CALLS
    static func getProspectsCount(completionHandler: @escaping (PROSPECT_COUNT_OUTPUT?, Error?) -> ())->(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.progress)
        var urlString = String(format: RRAPI.API_PROSPECT_COUNT, RRUtilities.sharedInstance.prospectsStartDate,RRUtilities.sharedInstance.prospectsEndDate)
        
        if(UserDefaults.standard.bool(forKey: "Filter by Action Date")){
            urlString.append("&filterByActionDate=1")
        }

        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(PROSPECT_COUNT_OUTPUT.self, from: responseData)
                    //                    print(urlResult)
                    if(urlResult.status == 1){
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == -1){
                        
                    }
                    else if(urlResult.status == 0){ ///fail status
                        completionHandler(nil,nil)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                completionHandler(nil,nil)
                break
            }
        }
        
    }
    
    static func getProspectAccordingToStatus(status : Int,tabId: Int?,projectID: String? , completionHandler: @escaping (REGISTRATIONS?, Error?) -> ())->(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.progress)
        
        var urlString = String(format: RRAPI.API_COMBINED_PROSPECTS, status,RRUtilities.sharedInstance.prospectsStartDate,RRUtilities.sharedInstance.prospectsEndDate)
        
        if(UserDefaults.standard.bool(forKey: "Filter by Action Date")){
            urlString.append("&filterByActionDate=1")
        }
        if let proId = projectID {
            urlString.append("&id=\(proId)")
        }
        if let id = tabId{
            urlString.append("&tab=\(id)")
        }
        
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(REGISTRATIONS.self, from: responseData)
//                    print(urlResult)
                    if(urlResult.status == 1){
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == -1){
                        
                    }
                    else if(urlResult.status == 0){ ///fail status
                        completionHandler(nil,nil)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                completionHandler(nil,nil)
                break
            }
        }
    }
    // MARK : - UNIT RESERVATIONS
    static func getProspectsForReservation(completionHandler: @escaping (ALL_PROSPECTS?, Error?) -> ())->(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        AF.request(RRAPI.API_GET_PROSPECTS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success :
                
                //                print(response)
                
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                
                
                HUD.hide()
                do{
                    let urlResult = try JSONDecoder().decode(ALL_PROSPECTS.self, from: responseData)
                    
                    //                print(urlResult)
                    
                    if(urlResult.status == 1){
                        completionHandler (urlResult,nil)
                    }
                    else{
                        completionHandler (nil,nil)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }
                break;
            case .failure(let error):
                HUD.hide()
                print(error)
                completionHandler (nil,nil)
            }
        }
        
    }
    static func getReservationsQueue(selectedUnitId : String,completionHandler: @escaping (RESERVATIONS_API_RESULT?, Error?) -> ())->(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        HUD.show(.progress)
        
        let urlString = String(format: RRAPI.API_GET_RESERVATIONS_OF_UNIT, selectedUnitId)
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(RESERVATIONS_API_RESULT.self, from: responseData)
//                    print(urlResult)
                    if(urlResult.status == 1){
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == -1){
                        
                    }
                    else if(urlResult.status == 0){ ///fail status
                        completionHandler(nil,nil)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    
    static func blockOrReleaseSelectedUnit(parameters : Dictionary<String,Any>,tag : Int,completionHandler: @escaping (COMMON_OUTPUT?, Error?) -> ()){
        
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        var parameters1 = parameters
        parameters1["src"] = 3

        HUD.show(.progress)
        
        AF.request(RRAPI.API_BLOCK_RELEASE_UNIT, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    HUD.hide()
                    let urlResult = try JSONDecoder().decode(COMMON_OUTPUT.self, from: responseData)
//                    print(urlResult)
                    completionHandler(urlResult,nil)

//                    if(urlResult.status == 1){
//                        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATIONS.FETCH_UNIT_DETAILS), object: nil)
//                        if(tag == 1){
////                            HUD.flash(.label("UNIT BLOCKED SUCCESSFULLY"), delay: 1.0)
////                            self.delegate?.didFinishUnitStatusChange(selectedUnit: self.selectedUnit, selectedIndexPath: self.selectedUnitIndexPath, unitStatus: UNIT_STATUS.BLOCKED.rawValue)
//
//                        }
//                        else{
////                            HUD.flash(.label("UNIT RELEASED SUCCESSFULLY"), delay: 1.0)
////                            self.delegate?.didFinishUnitStatusChange(selectedUnit: self.selectedUnit, selectedIndexPath: self.selectedUnitIndexPath, unitStatus: UNIT_STATUS.VACANT.rawValue)
//
//                        }
////                        self.navigationController?.popViewController(animated: true)
//                    }
//                    else if(urlResult.status == -1){
//
//                    }
//                    else if(urlResult.status == 0){ ///fail status
//                        completionHandler(urlResult,nil)
//                    }
                    
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,error)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                completionHandler(nil,error)
                break
            }
        }
    }
    static func getS3Config(){
        
        if !RRUtilities.sharedInstance.getNetworkStatus()
        {
            HUD.flash(.label("Couldn't connect to internet"), delay: 1.0)
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
     
        AF.request(RRAPI.API_GET_AWS_S3CONFIG, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    let urlResult = try JSONDecoder().decode(AWS_S3.self, from: responseData)
                    if(urlResult.s3 != nil){
                        RRUtilities.sharedInstance.model.writeS3Config(s3Config: urlResult.s3!)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    static func updateProspect(clientDetails : Client,completionHandler: @escaping (COMMON_OUTPUT?, Error?) -> ()){
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        var parametersDict : Dictionary<String,Any> = [:]
        parametersDict["_id"] = clientDetails._id
        parametersDict["name"] = clientDetails.name
        parametersDict["phone"] = clientDetails.phone
        parametersDict["email"] = clientDetails.email
        parametersDict["bookingId"] = clientDetails.bookingId
        parametersDict["company_group"] = clientDetails.company_group
        parametersDict["customer"] = clientDetails.customer
        parametersDict["phoneCode"] = clientDetails.phoneCode
        parametersDict["photo"] = clientDetails.photo
        parametersDict["panCard"] = clientDetails.panCard
        parametersDict["panUrl"] = clientDetails.panUrl
        parametersDict["aadhar"] = clientDetails.aadhar
        parametersDict["aadharUrl"] = clientDetails.aadharUrl
        
        parametersDict["src"] = 3

        
        AF.request(RRAPI.API_UPDATE_CUSTOMER, method: .post, parameters: parametersDict, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                do{
                    guard let responseData = response.data else {
                        print("Error: did not receive data")
                        return
                    }
                    let urlResult = try JSONDecoder().decode(COMMON_OUTPUT.self, from: responseData)
                    completionHandler(urlResult,nil)
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                completionHandler(nil,nil)
                break
            }
        }
    }
    static func getProspectActionHistory(prospectRegID : String,completionHandler: @escaping (QR_HISTORY_OUTPUT?, Error?) -> ()){
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        let urlString = String(format: RRAPI.API_GET_QR_HISTORY, prospectRegID)
        
        AF.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                //                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                //SEARCH_RESULT
                HUD.hide()
                
                do{
                    let urlResult = try JSONDecoder().decode(QR_HISTORY_OUTPUT.self, from: responseData)
                    
                    if(urlResult.status == 1){ // success
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == -1){
                        completionHandler(nil,nil)
                    }
                    else if(urlResult.status == 0){
                        //                    HUD.flash(.label(urlResult.err), delay: 1.0)
                        completionHandler(nil,nil)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }
                // make tableview data
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    
    // MARK: - UNIT HAND OVER BEGIN **
    
    static func getSoldUnitsForCompanyGroup(completionHandler: @escaping (SOLD_UNITS_OUTPUT?, Error?) -> ()){
        
        if( RRUtilities.sharedInstance.keychain["Cookie"] == nil){
            return
        }
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]

//        let urlString = RRAPI.API_GET_SOLD_UNITS
    
        AF.request(RRAPI.API_GET_SOLD_UNITS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                //                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                //SEARCH_RESULT
                HUD.hide()
                
                do{
                    let urlResult = try JSONDecoder().decode(SOLD_UNITS_OUTPUT.self, from: responseData)
                    
                    if(urlResult.status == 1){ // success
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == -1){
                        completionHandler(nil,nil)
                    }
                    else if(urlResult.status == 0){
                        //                    HUD.flash(.label(urlResult.err), delay: 1.0)
                        completionHandler(nil,nil)
                    }
                }
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }
                    // make tableview data
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                completionHandler(nil,nil)
                break
            }
        }
    }
    static func updateUHUnitStatus(selectedUnit : SoldUnits, unitName : String,projectName : String,unitDescription : String,unitId : String,unitStatus : Int,historyItems : [UnitHandOverHistory],completionHandler: @escaping (COMMON_OUTPUT?, Error?) -> ()){
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]
        
        let eachUnit = selectedUnit
        
        var unitParametersDict : Dictionary<String,Any> = [:]
        unitParametersDict["_id"] = unitId
        
        var blockDict : Dictionary<String,String> = [:]
        blockDict["_id"] = eachUnit.blockId
        blockDict["name"] = eachUnit.blockName
        unitParametersDict["block"] = blockDict
        
        var towerDict : Dictionary<String,Any> = [:]
        towerDict["_id"] = eachUnit.towerId
        towerDict["name"] = eachUnit.towerName
        
        let towerHandOverItems = eachUnit.towerHandOverUnits?.allObjects as! [TowerHandOverItems]
        var towerHandOverItemsArray : Array<Any> = []
        
        for eachItem in towerHandOverItems{
            
            var itemDict : Dictionary<String,Any> = [:]
            itemDict["_id"] = eachItem.id
            itemDict["unit"]  = eachItem.unit
            itemDict["tower"] = eachItem.tower
            itemDict["company"] = eachItem.company
            itemDict["company_group"] = eachItem.company_group
            itemDict["groupdId"] = eachItem.groupdId
            itemDict["ItemId"] = eachItem.itemId
            itemDict["groupdName"] = eachItem.groupdName
            itemDict["name"] = eachItem.name
            itemDict["itemHistory"] = self.convertToJSONArray(moArray: eachItem.itemHistory?.allObjects as! [UnitHandOverItemHistory])
            itemDict["updatedOn"] = eachItem.updatedOn
            itemDict["isNewItem"] = eachItem.isNewItem
            itemDict["ireviewLevels"] = eachItem.ireviewLevels
            itemDict["creviewLevels"] = eachItem.creviewLevels
            itemDict["mandatory"] = eachItem.mandatory
            itemDict["enabled"] = eachItem.enabled
            itemDict["handOverStatus"] = eachItem.handOverStatus
            
            //                let tempInternal = eachItem.internalReviews?.allObjects.sorted(by: { $0.index <= $1.index })
            
            var tempItems =  eachItem.internalReviews?.allObjects as! [Reviews]
            tempItems.sort(by: {$0.index < $1.index})
            
            itemDict["internalreviews"] = self.convertToJSONArray(moArray: tempItems )
            
            var tempCustReviews = eachItem.customerReviews?.allObjects as! [Reviews]
            tempCustReviews.sort(by: {$0.index < $1.index})
            
            itemDict["customerreviews"] = self.convertToJSONArray(moArray: tempCustReviews )
            
            itemDict["complaintDesc"] = eachItem.complaintDesc
            itemDict["complaintDate"] = eachItem.complaintDate
            itemDict["complaintlocation"] = eachItem.complaintlocation
            itemDict["complaintimgUrls"] = eachItem.complaintimgUrls
            
            towerHandOverItemsArray.append(itemDict)
            
        }
        
        towerDict["handoverItems"] = towerHandOverItemsArray
        unitParametersDict["tower"] = towerDict
        
        var projectDict : Dictionary<String,String> = [:]
        projectDict["_id"] = eachUnit.projectId
        projectDict["name"] = eachUnit.projectName
        unitParametersDict["project"] = projectDict
        
        var typeDict : Dictionary<String,String> = [:]
        typeDict["_id"] = eachUnit.unitTypeID
        typeDict["name"] = eachUnit.unitTypeName
        unitParametersDict["type"] = typeDict
        
        unitParametersDict["company_group"] = eachUnit.company_group
        unitParametersDict["description"] = eachUnit.unitDescription
        unitParametersDict["handOverStatus"] = unitStatus
        //            unitParametersDict["unitName"] = eachUnit.unitDisplayName
        //            unitParametersDict["unitDescription"] = eachUnit.unitDescription
        //            unitParametersDict["projectName"] = eachUnit.projectName
        unitParametersDict["manageUnitStatus"] = eachUnit.manageUnitStatus
        unitParametersDict["otherPremiums"] = eachUnit.otherPremiums
        unitParametersDict["status"] = eachUnit.status
        
        var unitNoDict : Dictionary<String,Any> = [:]
        unitNoDict["index"] = eachUnit.unitIndex
        unitNoDict["displayName"] = eachUnit.unitDisplayName
        unitParametersDict["unitNo"] = unitNoDict
        
        var floorDict : Dictionary<String,Any> = [:]
        floorDict["index"] = eachUnit.floorIndex
        floorDict["displayName"] = eachUnit.floorDisplayName
        unitParametersDict["floor"] = floorDict
        
        
        unitParametersDict["updateBy"] = self.convertToJSONArray(moArray: eachUnit.updateBy?.allObjects as! [UpdateBy])
        
        let tempHandOverItems = eachUnit.handOverUnits?.allObjects as! [TowerHandOverItems]
        var handOverItemsArray : Array<Any> = []
        
        for eachItem in tempHandOverItems{
            
            var itemDict : Dictionary<String,Any> = [:]
            itemDict["_id"] = eachItem.id
            itemDict["unit"]  = eachItem.unit
            itemDict["tower"] = eachItem.tower
            itemDict["company"] = eachItem.company
            itemDict["company_group"] = eachItem.company_group
            itemDict["groupdId"] = eachItem.groupdId
            itemDict["ItemId"] = eachItem.itemId
            itemDict["groupdName"] = eachItem.groupdName
            itemDict["name"] = eachItem.name
            itemDict["itemHistory"] = self.convertToJSONArray(moArray: eachItem.itemHistory?.allObjects as! [UnitHandOverItemHistory])
            itemDict["updatedOn"] = eachItem.updatedOn
            itemDict["isNewItem"] = eachItem.isNewItem
            itemDict["ireviewLevels"] = eachItem.ireviewLevels
            itemDict["creviewLevels"] = eachItem.creviewLevels
            itemDict["mandatory"] = eachItem.mandatory
            itemDict["enabled"] = eachItem.enabled
            itemDict["handOverStatus"] = eachItem.handOverStatus
            
            
            //                let tempInternal = eachItem.internalReviews?.allObjects.sorted(by: { $0.index <= $1.index })
            
            var tempItems =  eachItem.internalReviews?.allObjects as! [Reviews]
            tempItems.sort(by: {$0.index < $1.index})
            
            itemDict["internalreviews"] = self.convertToJSONArray(moArray: tempItems )
            
            var tempCustReviews = eachItem.customerReviews?.allObjects as! [Reviews]
            tempCustReviews.sort(by: {$0.index < $1.index})
            
            itemDict["customerreviews"] = self.convertToJSONArray(moArray: tempCustReviews )
            
            itemDict["complaintDesc"] = eachItem.complaintDesc
            itemDict["complaintDate"] = eachItem.complaintDate
            itemDict["complaintlocation"] = eachItem.complaintlocation
            itemDict["complaintimgUrls"] = eachItem.complaintimgUrls
            
            handOverItemsArray.append(itemDict)
            
        }
        
        unitParametersDict["handoverItems"] = handOverItemsArray
        
        var handOverHistory = eachUnit.handOverHistory?.allObjects as! [UnitHandOverHistory]
        handOverHistory.sort(by: {$0.index < $1.index})
        
        unitParametersDict["handoverHistory"] = self.convertToJSONArray(moArray: handOverHistory)
        
        var parameters : Dictionary<String,Any> = [:]
        
//        var subParameters : Dictionary<String,Any> = [:]
//        subParameters["_id"] = unitId
//        subParameters["handOverStatus"] = unitStatus
        
        //        var history =  self.convertToJSONArray(moArray: historyItems)
        //        history.sort{ ($0["index"] as! Int) <= ($1["index"] as! Int) }
        //
        //        subParameters["handoverHistory"] = history
        
        parameters["units"] = [unitParametersDict]
        parameters["src"] = 3

//        print(parameters)
        
        AF.request(RRAPI.API_POST_UPDATE_HANDOVER_UNIT_STATUS, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
                //                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                //SEARCH_RESULT
                HUD.hide()
                
                do{
                    let urlResult = try JSONDecoder().decode(COMMON_OUTPUT.self, from: responseData)
                    
                    if(urlResult.status == 1){ // success
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == -1){
                        completionHandler(nil,nil)
                    }
                    else if(urlResult.status == 0){
                        //                    HUD.flash(.label(urlResult.err), delay: 1.0)
                        completionHandler(nil,nil)
                    }
                }
                    // make tableview data
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }
                
                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    static func syncOfflineHandoverUnits(units : [SoldUnits],completionHandler: @escaping (COMMON_OUTPUT?, Error?) -> ()){
        
        var unitsArray : [Any] = []
        
        for eachUnit in units{
            
            var unitParametersDict : Dictionary<String,Any> = [:]
            unitParametersDict["_id"] = eachUnit.id
            
            var blockDict : Dictionary<String,String> = [:]
            blockDict["_id"] = eachUnit.blockId
            blockDict["name"] = eachUnit.blockName
            unitParametersDict["block"] = blockDict
            
            var towerDict : Dictionary<String,Any> = [:]
            towerDict["_id"] = eachUnit.towerId
            towerDict["name"] = eachUnit.towerName
            
            let towerHandOverItems = eachUnit.towerHandOverUnits?.allObjects as! [TowerHandOverItems]
            var towerHandOverItemsArray : Array<Any> = []
            
            for eachItem in towerHandOverItems{
                
                var itemDict : Dictionary<String,Any> = [:]
                itemDict["_id"] = eachItem.id
                itemDict["unit"]  = eachItem.unit
                itemDict["tower"] = eachItem.tower
                itemDict["company"] = eachItem.company
                itemDict["company_group"] = eachItem.company_group
                itemDict["groupdId"] = eachItem.groupdId
                itemDict["ItemId"] = eachItem.itemId
                itemDict["groupdName"] = eachItem.groupdName
                itemDict["name"] = eachItem.name
                itemDict["itemHistory"] = self.convertToJSONArray(moArray: eachItem.itemHistory?.allObjects as! [UnitHandOverItemHistory])
                itemDict["updatedOn"] = eachItem.updatedOn
                itemDict["isNewItem"] = eachItem.isNewItem
                itemDict["ireviewLevels"] = eachItem.ireviewLevels
                itemDict["creviewLevels"] = eachItem.creviewLevels
                itemDict["mandatory"] = eachItem.mandatory
                itemDict["enabled"] = eachItem.enabled
                itemDict["handOverStatus"] = eachItem.handOverStatus
                
                //                let tempInternal = eachItem.internalReviews?.allObjects.sorted(by: { $0.index <= $1.index })
                
                var tempItems =  eachItem.internalReviews?.allObjects as! [Reviews]
                tempItems.sort(by: {$0.index < $1.index})
                
                itemDict["internalreviews"] = self.convertToJSONArray(moArray: tempItems )
                
                var tempCustReviews = eachItem.customerReviews?.allObjects as! [Reviews]
                tempCustReviews.sort(by: {$0.index < $1.index})
                
                itemDict["customerreviews"] = self.convertToJSONArray(moArray: tempCustReviews )
                
                itemDict["complaintDesc"] = eachItem.complaintDesc
                itemDict["complaintDate"] = eachItem.complaintDate
                itemDict["complaintlocation"] = eachItem.complaintlocation
                itemDict["complaintimgUrls"] = eachItem.complaintimgUrls
                
                towerHandOverItemsArray.append(itemDict)
                
            }
            
            towerDict["handoverItems"] = towerHandOverItemsArray
            unitParametersDict["tower"] = towerDict
            
            var projectDict : Dictionary<String,String> = [:]
            projectDict["_id"] = eachUnit.projectId
            projectDict["name"] = eachUnit.projectName
            unitParametersDict["project"] = projectDict
            
            var typeDict : Dictionary<String,String> = [:]
            typeDict["_id"] = eachUnit.unitTypeID
            typeDict["name"] = eachUnit.unitTypeName
            unitParametersDict["type"] = typeDict
            
            unitParametersDict["company_group"] = eachUnit.company_group
            unitParametersDict["description"] = eachUnit.unitDescription
            unitParametersDict["handOverStatus"] = eachUnit.handOverStatus
//            unitParametersDict["unitName"] = eachUnit.unitDisplayName
//            unitParametersDict["unitDescription"] = eachUnit.unitDescription
//            unitParametersDict["projectName"] = eachUnit.projectName
            unitParametersDict["manageUnitStatus"] = eachUnit.manageUnitStatus
            unitParametersDict["otherPremiums"] = eachUnit.otherPremiums
            unitParametersDict["status"] = eachUnit.status
            
            var unitNoDict : Dictionary<String,Any> = [:]
            unitNoDict["index"] = eachUnit.unitIndex
            unitNoDict["displayName"] = eachUnit.unitDisplayName
            unitParametersDict["unitNo"] = unitNoDict

            var floorDict : Dictionary<String,Any> = [:]
            floorDict["index"] = eachUnit.floorIndex
            floorDict["displayName"] = eachUnit.floorDisplayName
            unitParametersDict["floor"] = floorDict

            
            unitParametersDict["updateBy"] = self.convertToJSONArray(moArray: eachUnit.updateBy?.allObjects as! [UpdateBy])
            
            let tempHandOverItems = eachUnit.handOverUnits?.allObjects as! [TowerHandOverItems]
            var handOverItemsArray : Array<Any> = []
            
            for eachItem in tempHandOverItems{
                
                var itemDict : Dictionary<String,Any> = [:]
                itemDict["_id"] = eachItem.id
                itemDict["unit"]  = eachItem.unit
                itemDict["tower"] = eachItem.tower
                itemDict["company"] = eachItem.company
                itemDict["company_group"] = eachItem.company_group
                itemDict["groupdId"] = eachItem.groupdId
                itemDict["ItemId"] = eachItem.itemId
                itemDict["groupdName"] = eachItem.groupdName
                itemDict["name"] = eachItem.name
                itemDict["itemHistory"] = self.convertToJSONArray(moArray: eachItem.itemHistory?.allObjects as! [UnitHandOverItemHistory])
                itemDict["updatedOn"] = eachItem.updatedOn
                itemDict["isNewItem"] = eachItem.isNewItem
                itemDict["ireviewLevels"] = eachItem.ireviewLevels
                itemDict["creviewLevels"] = eachItem.creviewLevels
                itemDict["mandatory"] = eachItem.mandatory
                itemDict["enabled"] = eachItem.enabled
                itemDict["handOverStatus"] = eachItem.handOverStatus


//                let tempInternal = eachItem.internalReviews?.allObjects.sorted(by: { $0.index <= $1.index })
                
               var tempItems =  eachItem.internalReviews?.allObjects as! [Reviews]
                tempItems.sort(by: {$0.index < $1.index})
                
                itemDict["internalreviews"] = self.convertToJSONArray(moArray: tempItems )
                
                var tempCustReviews = eachItem.customerReviews?.allObjects as! [Reviews]
                tempCustReviews.sort(by: {$0.index < $1.index})

                itemDict["customerreviews"] = self.convertToJSONArray(moArray: tempCustReviews )
                
                itemDict["complaintDesc"] = eachItem.complaintDesc
                itemDict["complaintDate"] = eachItem.complaintDate
                itemDict["complaintlocation"] = eachItem.complaintlocation
                itemDict["complaintimgUrls"] = eachItem.complaintimgUrls
                
                handOverItemsArray.append(itemDict)
                
            }
            
            unitParametersDict["handoverItems"] = handOverItemsArray
            
            var handOverHistory = eachUnit.handOverHistory?.allObjects as! [UnitHandOverHistory]
            handOverHistory.sort(by: {$0.index < $1.index})

            unitParametersDict["handoverHistory"] = self.convertToJSONArray(moArray: handOverHistory)
            
            unitsArray.append(unitParametersDict)
        }
        
        var parameters : Dictionary<String,Any> = [:]
        parameters["units"] = unitsArray
        parameters["src"] = 3
        
        let headers: HTTPHeaders = [
            "User-Agent" : "RErootMobile",
            "Cookie" : RRUtilities.sharedInstance.keychain["Cookie"]!
        ]

        AF.request(RRAPI.API_POST_UPDATE_UNIT_HANDOVER_ITEMS, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            switch response.result {
            case .success( _):
//                print(response)
                guard let responseData = response.data else {
                    print("Error: did not receive data")
                    return
                }
                //SEARCH_RESULT
                HUD.hide()
                
                do{
                    let urlResult = try JSONDecoder().decode(COMMON_OUTPUT.self, from: responseData)

                    if(urlResult.status == 1){ // success
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == -1){
                        completionHandler(urlResult,nil)
                    }
                    else if(urlResult.status == 0){
                        //                    HUD.flash(.label(urlResult.err), delay: 1.0)
                        completionHandler(urlResult,nil)
                    }
                }                // make tableview data
                catch let error{
                    HUD.flash(.label(error.localizedDescription))
                    completionHandler(nil,nil)
                }

                break
            case .failure(let error):
                print(error)
                HUD.hide()
                break
            }
        }
    }
    static func convertToJSONArray(moArray: [NSManagedObject]) -> [[String: Any]] {
        var jsonArray: [[String: Any]] = []
        for item in moArray {
            var dict: [String: Any] = [:]
            for attribute in item.entity.attributesByName {
                //check if value is present, then add key to dictionary so as to avoid the nil value crash
                if let value = item.value(forKey: attribute.key) {
                    if(attribute.key == "checked"){
                        if(value as! Int == 1){
                            dict["checked"] = true
                        }
                        else{
                            dict["checked"] = false
                        }
                    }
                    else if(attribute.key == "id"){
                        dict["_id"] = value
                    }
                    else{
                        dict[attribute.key] = value
                    }
                }
            }
            jsonArray.append(dict)
        }
        return jsonArray
    }

    // MARK: - UNIT HAND OVER END **
    
    
    
}

//
//  AlamoFire.swift
//  Fleet Driver
//
//  Created by Zeeshan Ashraf on 08/02/2020.
//  Copyright © 2020 SigiTechnologies. All rights reserved.
//

import Foundation
import Alamofire
import NVActivityIndicatorView

protocol serverResponse {
    func onResponse(json:[String: Any],val:String)
}

class ServerRequests: UIViewController,NVActivityIndicatorViewable {
    var delegate:serverResponse!
    
    func RequestOnly(url:String,method:HTTPMethod,type:String) {
        print("url=",url)
        Alamofire.request(url, method:method).responseJSON{
            
            response in
            if response.result.isSuccess{
                let json = response.result.value as? [String: Any]
                self.delegate.onResponse(json: json!,val: type)
            }else{
                self.stopAnimating()
                print(response.error?.localizedDescription as Any)
            }
        }
    }
    
    
    func foamData(url:String,params:[String:String]!,image:UIImage?, imageKey: String, imageName: String,type:String){
        print("Url==",url)
        Alamofire.upload(multipartFormData: { multipartFormData in
            if image != nil {
                let imgData = image!.jpegData(compressionQuality: 0.2)!
                multipartFormData.append(imgData, withName: imageKey,fileName: imageName, mimeType: "image/jpg")
            }
            for (key, value) in params {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
        },
                         to:url,method: .post)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseString { response in
                    print("responseString is ",response)

                }
                
                upload.responseJSON { response in
                    if response.result.isSuccess{
                        let json = response.result.value as? [String: Any]
                        self.delegate.onResponse(json: json!,val: type)
                    }else{
                        self.stopAnimating()
                        print(response.error!.localizedDescription)
                    }
                    
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    func foamDataWithHeader(url:String, params:[String:Any]!, image:UIImage?, type:String){
        let headers: HTTPHeaders = [
        "Content-type": "multipart/form-data",
        "Accept": "application/json"
        ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        Alamofire.upload(multipartFormData: { multiPart in
            for (key, value) in params {
                if let temp = value as? String {
                    multiPart.append(temp.data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Int {
                    multiPart.append("\(temp)".data(using: .utf8)!, withName: key)
                }
                if let temp = value as? NSArray {
                    temp.forEach({ element in
                        let keyObj = key + "[]"
                        if let string = element as? String {
                            multiPart.append(string.data(using: .utf8)!, withName: keyObj)
                        } else
                            if let num = element as? Int {
                                let value = "\(num)"
                                multiPart.append(value.data(using: .utf8)!, withName: keyObj)
                        }
                    })
                }
            }
            if image != nil {
                let imgData = image!.jpegData(compressionQuality: 0.2)!
                multiPart.append(imgData, withName: "upload",fileName: "image.jpg", mimeType: "image/jpg")
            }
        },
            to: url,
            method: .post,
        headers: headers, encodingCompletion: { result in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
//                upload.responseString { response in
//                    print("responseString is ",response)
//
//                }
                
                upload.responseJSON { response in
                    if response.result.isSuccess{
                        let json = response.result.value as? [String: Any]
                        self.delegate.onResponse(json: json!,val: type)
                    }else{
                        self.stopAnimating()
                        print(response.error!.localizedDescription)
                    }
                    
                }
                
            case .failure(let encodingError):
                self.stopAnimating()
                print(encodingError)
            }
        })
    }
    
    func postRequestWithRawData(url:String, header: HTTPHeaders, params : Parameters, type:String){
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header)
            .responseJSON { response in
                
                if response.result.isSuccess{
                    let json = response.result.value as? [String: Any]
                    self.delegate.onResponse(json: json!,val: type)
                }else{
                    self.stopAnimating()
                    print(response.error?.localizedDescription as Any)
                }
            }
        
//            .responseString { response in
//                print("responseString is ",response)
//
//            }
    }
    
    func postRequestWithStringInBody(url:String, header: HTTPHeaders, params : Parameters, encoding: ParameterEncoding, type:String){
        Alamofire.request(url, method: .post, parameters: params, encoding: encoding, headers: header)
            .responseJSON { response in
            
            if response.result.isSuccess{
                let json = response.result.value as? [String: Any]
                self.delegate.onResponse(json: json!,val: type)
            }else{
                self.stopAnimating()
                print(response.error?.localizedDescription as Any)
            }
        }
    }
}

extension String: ParameterEncoding {

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }

}

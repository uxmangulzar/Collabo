//
//  ForgotPasswordVC.swift
//  ErrandApp
//
//  Created by Tabish on 10/12/20.
//

import UIKit
import SwiftyJSON

class ForgotPasswordVC: UIViewController, serverResponse {
   
    @IBOutlet weak var emailVu: UIView!
    @IBOutlet weak var emailTF: UITextField!
    
    var fourDigitNum: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTF.delegate = self
        
        setPlaceholderColor()
    }
    
    @IBAction func tappedNextBtn(_ sender: Any) {
        if emailTF.text != ""{
            if CheckInternet.Connection(){
                Utils.sharedInstance.startIndicator()

                let url = BaseUrls.baseUrl + "FORGOT_PASSWORD.php"

                let params : [String: Any] = ["user_email": emailTF.text!]

                print("params are: \(params)")

                serverRequest.delegate = self
                serverRequest.postRequestWithRawData(url: url, header: [:], params: params, type: "")
            }else{
                Alert.showInternetFailureAlert(on: self)
            }
        }else{
            Alert.showAlert(on: self, with: "Email Required!", message: "Email is required to proceed.")
        }
    }
    
    @IBAction func tappedResendBtn(_ sender: Any) {
        if emailTF.text != ""{
            if CheckInternet.Connection(){
                Utils.sharedInstance.startIndicator()

                let url = BaseUrls.baseUrl + "FORGOT_PASSWORD.php"

                let params : [String: Any] = ["user_email": emailTF.text!]

                print("params are: \(params)")

                serverRequest.delegate = self
                serverRequest.postRequestWithRawData(url: url, header: [:], params: params, type: "")
            }else{
                Alert.showInternetFailureAlert(on: self)
            }
        }else{
            Alert.showAlert(on: self, with: "Email Required!", message: "Email is required to proceed.")
        }
    }
    
    func onResponse(json: [String: Any], val: String) {
        let status = json["status"] as? String
        if status == "200"{
            let result = json["result"] as? String ?? ""
            Alert.showAlert(on: self, with: "Success!", message: result)
        }else{
            let message = json["message"] as? String ?? ""
            Alert.showAlert(on: self, with: "Response Failed!", message: message)
        }
        Utils.sharedInstance.stopIndicator()
    }
}

extension ForgotPasswordVC: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        emailVu.layer.borderWidth = 3
        emailVu.layer.borderColor = UIColor.white.cgColor
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.defaultStyle()
        return true
    }
    
    func defaultStyle(){
        emailVu.layer.borderWidth = 0
        emailVu.layer.borderColor = UIColor.clear.cgColor
    }
}


extension ForgotPasswordVC{
    func setPlaceholderColor(){
        emailTF.attributedPlaceholder = NSAttributedString(string: "Email",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}

//
//  NewPasswordVC.swift
//  ErrandApp
//
//  Created by Tabish on 10/12/20.
//

import UIKit
import SwiftyJSON

class NewPasswordVC: UIViewController, serverResponse {
    
    @IBOutlet weak var passwordVu: UIView!
    @IBOutlet weak var confirmPasswordVu: UIView!
    
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    var userId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTF.delegate = self
        confirmPasswordTF.delegate = self
        
        setPlaceholderColor()
    }
    
    @IBAction func tappedSaveBtn(_ sender: Any) {
//        if passwordTF.text != ""{
//            if passwordTF.text == confirmPasswordTF.text{
//                if CheckInternet.Connection(){
//                    Utils.sharedInstance.startIndicator()
//
//                    let url = BaseUrls.baseUrl + "UPDATE_USER_PASSWORD.php"
//
//                    let params : [String: Any] = [  "user_id":userId!,
//                                                    "new_password":passwordTF.text!]
//
//                    print("params are: \(params)")
//
//                    serverRequest.delegate = self
//                    serverRequest.postRequestWithRawData(url: url, header: [:], params: params, type: "")
//                }else{
//                    Alert.showInternetFailureAlert(on: self)
//                }
//            }else{
//                Alert.showAlert(on: self, with: "Password Mismatch!", message: "Please confirm your password.")
//            }
//        }else{
//            Alert.showAlert(on: self, with: "Password Required!", message: "Password is required.")
//        }
    }
    
    func onResponse(json: [String: Any], val: String) {
        let status = json["status"] as? Int
        if status == 200{
            let result = json["result"] as? String
            let alert = UIAlertController(title: "Password Changed!", message: result, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Okay", style: .default) { (alert) in
                let vc:LoginViewController = UIStoryboard.controller()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc,animated: true)
            }
            alert.addAction(alertAction)
            self.present(alert , animated: true, completion: nil)
        }else{
            let message = json["message"] as? String
            Alert.showAlert(on: self, with: "Failed!", message: message ?? "")
        }
        Utils.sharedInstance.stopIndicator()
    }
}

extension NewPasswordVC: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.passwordTF {
            
            passwordVu.layer.borderWidth = 2.5
            passwordVu.layer.borderColor = UIColor.white.cgColor
        }else{
            confirmPasswordVu.layer.borderWidth = 2.5
            confirmPasswordVu.layer.borderColor = UIColor.white.cgColor
       }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.defaultStyle()
        return true
    }
    
    func defaultStyle(){
        passwordVu.layer.borderWidth = 0
        passwordVu.layer.borderColor = UIColor.clear.cgColor
        
        confirmPasswordVu.layer.borderWidth = 0
        confirmPasswordVu.layer.borderColor = UIColor.clear.cgColor
    }
}

extension NewPasswordVC{
    func setPlaceholderColor(){
        passwordTF.attributedPlaceholder = NSAttributedString(string: "Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        confirmPasswordTF.attributedPlaceholder = NSAttributedString(string: "Re-enter password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}

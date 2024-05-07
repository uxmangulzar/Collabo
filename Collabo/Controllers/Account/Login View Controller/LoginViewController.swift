//
//  LoginViewController.swift
//  Collabo
//
//  Created by Tabish on 11/30/20.
//

import UIKit
import SwiftyJSON

class LoginViewController: UIViewController, serverResponse {

    @IBOutlet weak var emailBackVu: UIView!
    @IBOutlet weak var passBackVu: UIView!
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTF.delegate = self
        passTF.delegate = self
        
        setPlaceholderColor()
    }
    
    @IBAction func tappedLoginBtn(_ sender: Any) {
        if emailTF.text != "" && passTF.text != ""{
            if CheckInternet.Connection(){
                Utils.sharedInstance.startIndicator()
                let url = BaseUrls.baseUrl + "user_login1.php"
                let params : [String: Any] = ["user_email": emailTF.text!,
                                                "password": passTF.text!,
                                                "fcm_token": "23332"]
                
                print("params are: \(params)")
                
                serverRequest.delegate = self
                serverRequest.postRequestWithRawData(url: url, header: [:], params: params, type: "")
            }else{
                Alert.showInternetFailureAlert(on: self)
            }
        }else{
            Alert.showAlert(on: self, with: "Fields Required!", message: "All Fields are required.")
        }
    }
    
    func onResponse(json: [String: Any], val: String) {
        let status = json["status"] as? Int
        let message = json["message"] as? String ?? ""
        if status == 200{
            let userId = json["USER_ID"] as? String
            let userImage = json["USER_IMAGE"] as? String
            let userName = json["USER_NAME"] as? String
            let userEmail = json["USER_EMAIL"] as? String
            let jwt = json["JWT"] as? String
            
            UserDefaults.standard.set(userId, forKey: UserDefaultKey.userId)
            UserDefaults.standard.set(userImage, forKey: UserDefaultKey.userImg)
            UserDefaults.standard.set(userName, forKey: UserDefaultKey.userName)
            UserDefaults.standard.set(userEmail, forKey: UserDefaultKey.userEmail)
            UserDefaults.standard.set(jwt, forKey: UserDefaultKey.jwt)
            
            moveToHome()
        }else{
            Alert.showAlert(on: self, with: "Login Failed!", message: message)
        }
        Utils.sharedInstance.stopIndicator()
    }
    
    func moveToHome(){
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc,animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.emailTF {
           
            emailBackVu.layer.borderWidth = 2.5
            emailBackVu.layer.borderColor = UIColor.white.cgColor
       }else{
           
            passBackVu.layer.borderWidth = 2.5
            passBackVu.layer.borderColor = UIColor.white.cgColor
       }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.defaultStyle()
        return true
    }
    
    func defaultStyle(){
        emailBackVu.layer.borderWidth = 0
        emailBackVu.layer.borderColor = UIColor.clear.cgColor
        
        passBackVu.layer.borderWidth = 0
        passBackVu.layer.borderColor = UIColor.clear.cgColor
    }
}

extension LoginViewController{
    func setPlaceholderColor(){
        emailTF.attributedPlaceholder = NSAttributedString(string: "Enter Email",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        passTF.attributedPlaceholder = NSAttributedString(string: "Enter Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}

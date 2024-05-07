//
//  CollaborateChatVC.swift
//  Collabo
//
//  Created by Tabish on 12/1/20.
//

import UIKit
import SwiftyJSON

class CollaborateChatVC: UIViewController, serverResponse {
    
    @IBOutlet weak var crossBarBtn: UIBarButtonItem!
    @IBOutlet weak var tickBarBtn: UIBarButtonItem!

    @IBOutlet weak var messageTF: UITextField!
    
    var receiverId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        crossBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        tickBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        
        messageTF.attributedPlaceholder = NSAttributedString(string: "Required",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    @IBAction func tappedCrossBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedTickBtn(_ sender: Any) {
        if messageTF.text != ""{
            if CheckInternet.Connection(){
                Utils.sharedInstance.startIndicator()
                let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
                let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
                
                let url = BaseUrls.baseUrl + "ADD_NEW_MESSAGE.php"
                let headers: [String:String] = [
                "Authorization": jwt
                ]
                
                guard let receiverId = receiverId else {
                    return
                }
                
                let params : [String: Any] = [ "user_id":userId,
                                                "receiver_id": receiverId,
                                                "message":messageTF.text!]
                
                print("params are: \(params)")
                
                serverRequest.delegate = self
                serverRequest.postRequestWithRawData(url: url, header: headers, params: params, type: "")
            }else{
                Alert.showInternetFailureAlert(on: self)
            }
        }else{
            Alert.showAlert(on: self, with: "Message Required!", message: "Please Type a message.")
        }
    }
    
    func onResponse(json: [String: Any], val: String) {
        let status = json["status"] as? String
        print(status)
        if status == "200"{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadNewMessages"), object: nil, userInfo: nil)
            let result = json["result"] as? String
            let alertView = UIAlertController(title: title, message: result, preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Ok", style: .cancel) { (alert) in
                self.navigationController?.popViewController(animated: true)
            }
            alertView.addAction(alertAction)
            self.present(alertView, animated: true, completion: nil)
        }else{
            let message = json["message"] as? String ?? ""
            Alert.showAlert(on: self, with: "Failed!", message: message)
        }
        Utils.sharedInstance.stopIndicator()
    }
}

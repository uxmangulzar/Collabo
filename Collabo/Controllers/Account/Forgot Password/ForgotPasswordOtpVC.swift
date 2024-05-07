//
//  ForgotPasswordOtpVC.swift
//  ErrandApp
//
//  Created by Tabish on 10/12/20.
//

import UIKit

class ForgotPasswordOtpVC: UIViewController {
    
    @IBOutlet weak var firstVuOtp: UIView!
    @IBOutlet weak var secondVuOtp: UIView!
    @IBOutlet weak var thirdVuOtp: UIView!
    @IBOutlet weak var forthVuOtp: UIView!
    
    @IBOutlet weak var firstOtpTF: UITextField!
    @IBOutlet weak var secondOtpTF: UITextField!
    @IBOutlet weak var thirdOtpTF: UITextField!
    @IBOutlet weak var forthOtpTF: UITextField!
    
    var userId: String?
    var fourDigitNum: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBorderForOtpVu()
        
        firstOtpTF.delegate = self
        secondOtpTF.delegate = self
        thirdOtpTF.delegate = self
        forthOtpTF.delegate = self
        
        firstOtpTF.keyboardType = .numberPad
        secondOtpTF.keyboardType = .numberPad
        thirdOtpTF.keyboardType = .numberPad
        forthOtpTF.keyboardType = .numberPad
        
        firstOtpTF.addTarget(self, action: #selector(ForgotPasswordOtpVC.textFieldDidChange(textField:)), for: .editingChanged)
        secondOtpTF.addTarget(self, action: #selector(ForgotPasswordOtpVC.textFieldDidChange(textField:)), for: .editingChanged)
        thirdOtpTF.addTarget(self, action: #selector(ForgotPasswordOtpVC.textFieldDidChange(textField:)), for: .editingChanged)
        forthOtpTF.addTarget(self, action: #selector(ForgotPasswordOtpVC.textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(textField: UITextField){

        let text = textField.text

        // If the textfield character count is 1
        if (text?.utf16.count)! >= 1{
            switch textField{
            case firstOtpTF:
                secondOtpTF.becomeFirstResponder()
            case secondOtpTF:
                thirdOtpTF.becomeFirstResponder()
            case thirdOtpTF:
                forthOtpTF.becomeFirstResponder()
            case forthOtpTF:
                forthOtpTF.resignFirstResponder()
            default:
                break
            }
        // If the textfield character count is 0
        }else if (text?.utf16.count)! == 0{
            switch textField{
            case forthOtpTF:
                thirdOtpTF.becomeFirstResponder()
            case thirdOtpTF:
                secondOtpTF.becomeFirstResponder()
            case secondOtpTF:
                firstOtpTF.becomeFirstResponder()
            case firstOtpTF:
                firstOtpTF.becomeFirstResponder()
            default:
                break
            }
        }
    }
    
    @IBAction func tappedNextBtn(_ sender: Any) {
        let vc: NewPasswordVC = UIStoryboard.controller()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}

extension ForgotPasswordOtpVC: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = textField.text

        // If the textfield character count is 1
        if (text?.utf16.count)! >= 1{
            switch textField{
            case firstOtpTF:
                if secondOtpTF.text != ""{
                    view.endEditing(true)
                }
            case secondOtpTF:
                if thirdOtpTF.text != ""{
                    view.endEditing(true)
                }
            case thirdOtpTF:
                if forthOtpTF.text != ""{
                    view.endEditing(true)
                }
            default:
                break
            }
        }
        
        // If the textfield character count is 0
        if (text?.utf16.count)! == 0{
            switch textField{
            case secondOtpTF:
                if firstOtpTF.text == ""{
                    view.endEditing(true)
                }
            case thirdOtpTF:
                if secondOtpTF.text == ""{
                    view.endEditing(true)
                }
            case forthOtpTF:
                if thirdOtpTF.text == ""{
                    view.endEditing(true)
                }
            default:
                break
            }
        }
    }
}

extension ForgotPasswordOtpVC{
    func setBorderForOtpVu(){
        firstVuOtp.layer.borderWidth = 1
        firstVuOtp.layer.borderColor = UIColor.lightGray.cgColor
        
        secondVuOtp.layer.borderWidth = 1
        secondVuOtp.layer.borderColor = UIColor.lightGray.cgColor
        
        thirdVuOtp.layer.borderWidth = 1
        thirdVuOtp.layer.borderColor = UIColor.lightGray.cgColor
        
        forthVuOtp.layer.borderWidth = 1
        forthVuOtp.layer.borderColor = UIColor.lightGray.cgColor
    }
}

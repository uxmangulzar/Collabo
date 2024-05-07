//
//  RegisterViewController.swift
//  Collabo
//
//  Created by Tabish on 11/30/20.
//

import UIKit
import SwiftyJSON
import ActionSheetPicker_3_0

class RegisterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, serverResponse {
    
    @IBOutlet weak var genreBtn: UIButton!
    
    var genreArr = [String]()
    
    //For storing action sheet picker option
    var genreSelection: String!
    
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    
    var genderSelection = "male"
    
    @IBOutlet weak var profileImg: UIImageView!
    
    var imageName: String?

    @IBOutlet weak var firstNameBackVu: UIView!
    @IBOutlet weak var lastNameBackVu: UIView!
    @IBOutlet weak var emailBackVu: UIView!
    @IBOutlet weak var passBackVu: UIView!
    @IBOutlet weak var confirmBackVu: UIView!
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var confirmPassTF: UITextField!
    
    var genreModel = [GenreModel]()
    
    var selectedGenreId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImg.round()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedSelectProfileImage))
        profileImg.isUserInteractionEnabled = true
        profileImg.addGestureRecognizer(tapGesture)
        
        firstNameTF.delegate = self
        lastNameTF.delegate = self
        emailTF.delegate = self
        passTF.delegate = self
        confirmPassTF.delegate = self
        
        setPlaceholderColor()
        
        getAllGenre()
    }
    
    func getAllGenre(){
        if CheckInternet.Connection(){
            Utils.sharedInstance.startIndicator()
            
            let url = BaseUrls.baseUrl + "GET_ALL_GENRE.php"
            
            let params : [String: Any] = [ "limit": "100",
                                            "page": "1"]
            
            print("params are: \(params)")
            
            serverRequest.delegate = self
            serverRequest.postRequestWithRawData(url: url, header: [:], params: params, type: "get_genres")
        }else{
            Alert.showInternetFailureAlert(on: self)
        }
    }
    
    @objc func tappedSelectProfileImage() {
        let imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imageController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let profileImage = info[.originalImage] as? UIImage else { return }
        
        guard let fileUrl = info[.imageURL] as? URL else { return }
        imageName = fileUrl.lastPathComponent
        
        self.profileImg.image = profileImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedMaleBtn(_ sender: Any) {
        maleBtn.setImage(UIImage(named: "filled-circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        femaleBtn.setImage(UIImage(named: "unfilled-circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        genderSelection = "male"
    }
    
    @IBAction func tappedFemaleBtn(_ sender: Any) {
        femaleBtn.setImage(UIImage(named: "filled-circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        maleBtn.setImage(UIImage(named: "unfilled-circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        genderSelection = "female"
    }
    
    @IBAction func tapGenreBtn(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "", rows: genreArr, initialSelection: 0, doneBlock: { [self]
                       picker, indexe, value in

                       print("value = \(value)")
                       print("indexe = \(indexe)")
                       print("picker = \(picker)")
            
            selectedGenreId = genreModel[indexe].genreId
            genreSelection = value as? String
            
            genreBtn.setTitle(genreSelection, for: .normal)
            genreBtn.setTitleColor(UIColor.white, for: .normal)
                       return
               }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    @IBAction func tappedSignUpBtn(_ sender: Any) {
        if emailTF.text != "" && passTF.text != "" && firstNameTF.text != "" && lastNameTF.text != "" && genderSelection != nil && imageName != nil && selectedGenreId != nil{
            if passTF.text == confirmPassTF.text{
                if CheckInternet.Connection(){
                    Utils.sharedInstance.startIndicator()
                    
                    let imgUrl = BaseUrls.baseUrl + "UPLOAD_FILE.php"
                    let imgParams: [String: String] = ["type":"user_profile",
                                                       "file":imageName!]
                    serverRequest.foamData(url: imgUrl, params: imgParams, image: profileImg.image, imageKey: "file", imageName: imageName!, type: "upload_profile_image")
                    
                    let url = BaseUrls.baseUrl + "user_registration.php"
                    let params : [String: Any] = ["user_email":emailTF.text!,
                                                  "password":passTF.text!,
                                                  "first_name":firstNameTF.text!,
                                                  "last_name":lastNameTF.text!,
                                                  "genre":selectedGenreId!,
                                                  "gender":genderSelection,
                                                  "file":["file":imageName!]]
                    
                    print("params are: \(params)")
                    
                    serverRequest.delegate = self
                    serverRequest.postRequestWithRawData(url: url, header: [:], params: params, type: "")
                }else{
                    Alert.showInternetFailureAlert(on: self)
                }
            }else{
                Alert.showAlert(on: self, with: "Confirm Password!", message: "Both passwords should match.")
            }
        }else{
            Alert.showAlert(on: self, with: "Fields Required!", message: "All Fields are required.")
        }
    }
    
    func onResponse(json: [String: Any], val: String) {
        if val == ""{
            let status = json["status"] as? String
            if status == "200"{
                let result = json["result"] as? String
                let alertView = UIAlertController(title: "Success!", message: result, preferredStyle: .alert)
                
                let alertAction = UIAlertAction(title: "Okay", style: .cancel) { (alert) in
                    self.dismiss(animated: true, completion: nil)
                }
                alertView.addAction(alertAction)
                self.present(alertView, animated: true, completion: nil)
            }else{
                let message = json["message"] as? String
                Alert.showAlert(on: self, with: "Response Failed!", message: message ?? "")
            }
        }else if val == "upload_profile_image"{
            let status = json["status"] as? String
            if status == "200"{
                print("Profile Image Uploaded Successfully.")
            }
        }else if val == "get_genres"{
            let error = json["error"] as? Bool
            if error == false{
                genreModel.removeAll()
                let allGenre = json["genre_result"] as! [[String: Any]]
                for singleGenre in allGenre {
                    genreModel.append(GenreModel(json: singleGenre))
                    genreArr.append(singleGenre["genre_name"] as? String ?? "")
                }
            }else{
                Alert.showAlert(on: self, with: "Error!", message: "Something went wrong try later.")
            }
        }
        Utils.sharedInstance.stopIndicator()
    }
}

extension RegisterViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.firstNameTF {
           
            firstNameBackVu.layer.borderWidth = 2.5
            firstNameBackVu.layer.borderColor = UIColor.white.cgColor
       }else if textField == self.lastNameTF {
           
            lastNameBackVu.layer.borderWidth = 2.5
            lastNameBackVu.layer.borderColor = UIColor.white.cgColor
       }else if textField == self.emailTF {
           
            emailBackVu.layer.borderWidth = 2.5
            emailBackVu.layer.borderColor = UIColor.white.cgColor
       }else if textField == self.passTF {
           
            passBackVu.layer.borderWidth = 2.5
            passBackVu.layer.borderColor = UIColor.white.cgColor
       }else{
           
            confirmBackVu.layer.borderWidth = 2.5
            confirmBackVu.layer.borderColor = UIColor.white.cgColor
       }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.defaultStyle()
        return true
    }
    
    func defaultStyle(){
        firstNameBackVu.layer.borderWidth = 0
        firstNameBackVu.layer.borderColor = UIColor.clear.cgColor
        
        lastNameBackVu.layer.borderWidth = 0
        lastNameBackVu.layer.borderColor = UIColor.clear.cgColor
        
        emailBackVu.layer.borderWidth = 0
        emailBackVu.layer.borderColor = UIColor.clear.cgColor
        
        passBackVu.layer.borderWidth = 0
        passBackVu.layer.borderColor = UIColor.clear.cgColor
        
        confirmBackVu.layer.borderWidth = 0
        confirmBackVu.layer.borderColor = UIColor.clear.cgColor
    }
}

extension RegisterViewController{
    func setPlaceholderColor(){
        firstNameTF.attributedPlaceholder = NSAttributedString(string: "First Name",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        lastNameTF.attributedPlaceholder = NSAttributedString(string: "Last Name",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        emailTF.attributedPlaceholder = NSAttributedString(string: "Email",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        passTF.attributedPlaceholder = NSAttributedString(string: "Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        confirmPassTF.attributedPlaceholder = NSAttributedString(string: "Confirm Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}

//
//  EditProfileVC.swift
//  Collabo
//
//  Created by Tabish on 12/1/20.
//

import UIKit
import ActionSheetPicker_3_0

class EditProfileVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, serverResponse {
    
    @IBOutlet weak var crossBarBtn: UIBarButtonItem!
    @IBOutlet weak var tickBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var profileImg: UIImageView!
    
    var imageName: String?
    
    @IBOutlet weak var nameBackVu: UIView!
    @IBOutlet weak var genreBackVu: UIView!
    @IBOutlet weak var bioBackVu: UIView!
    @IBOutlet weak var fbBackVu: UIView!
    @IBOutlet weak var igBackVu: UIView!
    @IBOutlet weak var youtubeBackVu: UIView!
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var bioTF: UITextField!
    @IBOutlet weak var fbTF: UITextField!
    @IBOutlet weak var igTF: UITextField!
    @IBOutlet weak var youtubeTF: UITextField!
    
    @IBOutlet weak var genreBtn: UIButton!
    
    var genreArr = [String]()
    
    //For storing action sheet picker option
    var genreSelection: String!
    
    var genreModel = [GenreModel]()
    
    var genderSelection: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        crossBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        tickBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        
        setPlaceholderColor()
        setBorderColor()
        
        getAllGenre()
        getUserProfile()
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
    
    func getUserProfile(){
        if CheckInternet.Connection(){
            Utils.sharedInstance.startIndicator()
            let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
            let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
            
            let url = BaseUrls.baseUrl + "GET_USER_PROFILE_DATA.php"
            let headers: [String:String] = [
            "Authorization": jwt
            ]
            let params : [String: Any] = ["user_id":userId]
            
            print("params are: \(params)")
            
            serverRequest.delegate = self
            serverRequest.postRequestWithRawData(url: url, header: headers, params: params, type: "")
        }else{
            Alert.showInternetFailureAlert(on: self)
        }
    }
    
    func onResponse(json: [String : Any], val: String) {
        if val == ""{
            let error = json["error"] as? Bool
            if error == false{
                let userProfileArr = json["user_profile"] as! [[String: Any]]
                let img = userProfileArr[0]["user_image"] as? String
                let profileImg = BaseUrls.baseUrlImages + img!
                let completeName = userProfileArr[0]["user_name"] as? String
                genderSelection = userProfileArr[0]["user_gender"] as? String
                genreSelection = userProfileArr[0]["user_genre"] as? String
                let bio = userProfileArr[0]["user_bio"] as? String
                let fb = userProfileArr[0]["user_fb"] as? String
                let insta = userProfileArr[0]["user_ig"] as? String
                let youtube = userProfileArr[0]["user_youtube"] as? String
                
                DispatchQueue.main.async { [self] in
                    print("profileImg is: \(profileImg)")
                    self.profileImg.downloadImage(imageUrl: profileImg)
                    nameTF.text = completeName
                    genreBtn.setTitle(genreSelection, for: .normal)
                    bioTF.text = bio
                    fbTF.text = fb
                    igTF.text = insta
                    youtubeTF.text = youtube
                }
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
        }else if val == "update_profile"{
            let status = json["status"] as? String
            if status == "200"{
                guard let imageName = imageName else {
                    return
                }
                
                guard let userName = nameTF.text else {
                    return
                }
                
                UserDefaults.standard.set("Profiles/" + imageName, forKey: UserDefaultKey.userImg)
                UserDefaults.standard.set(userName, forKey: UserDefaultKey.userName)
                
                let result = json["result"] as? String
                let alertView = UIAlertController(title: "Success!", message: result, preferredStyle: .alert)
                
                let alertAction = UIAlertAction(title: "Okay", style: .cancel) { (alert) in
                    self.navigationController?.popViewController(animated: true)
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
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadUserProfile"), object: nil, userInfo: nil)
            }
        }
        Utils.sharedInstance.stopIndicator()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func uploadProfilePic(_ sender: Any) {
        let imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imageController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let profileImage = info[.originalImage] as? UIImage else { return }
        
        self.profileImg.image = profileImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedCrossBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedTickBtn(_ sender: Any) {
        imageName = NSUUID().uuidString + ".jpg"
        if nameTF.text != "" && bioTF.text != "" && fbTF.text != "" && igTF.text != "" && youtubeTF.text != "" && profileImg != nil && genderSelection != nil && genreSelection != nil{
            if CheckInternet.Connection(){
                Utils.sharedInstance.startIndicator()
                
                let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
                let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
                
                let headers: [String:String] = [
                "Authorization": jwt
                ]
                
                let imgUrl = BaseUrls.baseUrl + "UPLOAD_FILE.php"
                let imgParams: [String: String] = ["type":"user_profile",
                                                   "file":imageName!]
                serverRequest.foamData(url: imgUrl, params: imgParams, image: profileImg.image, imageKey: "file", imageName: imageName!, type: "upload_profile_image")
                
                let url = BaseUrls.baseUrl + "UPDATE_USER_PROFILE.php"
                let params : [String: Any] = ["user_id":userId,
                                              "full_name":nameTF.text!,
                                              "genre":genreSelection!,
                                              "gender":genderSelection!,
                                              "bio":bioTF.text!,
                                              "fb":fbTF.text!,
                                              "ig":igTF.text!,
                                              "youtube":youtubeTF.text!,
                                              "file":["file":imageName]]
                
                print("params are: \(params)")
                
                serverRequest.delegate = self
                serverRequest.postRequestWithRawData(url: url, header: headers, params: params, type: "update_profile")
            }else{
                Alert.showInternetFailureAlert(on: self)
            }
        }else{
            Alert.showAlert(on: self, with: "Fields Required!", message: "All Fields are required.")
        }
    }
    
    @IBAction func tappedSelectGenre(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "", rows: genreArr, initialSelection: 0, doneBlock: { [self]
                       picker, indexe, value in

                       print("value = \(value)")
                       print("indexe = \(indexe)")
                       print("picker = \(picker)")
            
            genreSelection = value as? String
            
            genreBtn.setTitle(genreSelection, for: .normal)
            genreBtn.setTitleColor(UIColor.black, for: .normal)
                       return
               }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
}

extension EditProfileVC{
    func setPlaceholderColor(){
        nameTF.attributedPlaceholder = NSAttributedString(string: "Full Name",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        bioTF.attributedPlaceholder = NSAttributedString(string: "Bio",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        fbTF.attributedPlaceholder = NSAttributedString(string: "FB",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        igTF.attributedPlaceholder = NSAttributedString(string: "IG",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        youtubeTF.attributedPlaceholder = NSAttributedString(string: "YouTube",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
    }
    
    func setBorderColor(){
        nameBackVu.layer.borderWidth = 2.5
        nameBackVu.layer.borderColor = UIColor.white.cgColor
        
        genreBackVu.layer.borderWidth = 2.5
        genreBackVu.layer.borderColor = UIColor.white.cgColor
        
        bioBackVu.layer.borderWidth = 2.5
        bioBackVu.layer.borderColor = UIColor.white.cgColor
        
        igBackVu.layer.borderWidth = 2.5
        igBackVu.layer.borderColor = UIColor.white.cgColor
        
        fbBackVu.layer.borderWidth = 2.5
        fbBackVu.layer.borderColor = UIColor.white.cgColor
        
        youtubeBackVu.layer.borderWidth = 2.5
        youtubeBackVu.layer.borderColor = UIColor.white.cgColor
    }
}

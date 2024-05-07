//
//  ProfileViewController.swift
//  Collabo
//
//  Created by Tabish on 12/1/20.
//

import UIKit
import SwiftyJSON

class ProfileViewController: UIViewController, serverResponse {
    
    @IBOutlet weak var editPencilBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var tableVu: UITableView!
    
    var profileModel: UserProfileModel?
    var workModel: WorkModel?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editPencilBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        
        createObservers()
        getUserProfile()
    }
    
    func createObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.updateData), name: Notification.Name(rawValue: "ReloadUserProfile"), object: nil)
    }
    
    @objc func updateData(){
        getUserProfile()
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
            serverRequest.postRequestWithRawData(url: url, header: headers, params: params, type: "get_profile")
        }else{
            Alert.showInternetFailureAlert(on: self)
        }
    }
    
    func onResponse(json: [String: Any], val: String) {
        if val == "get_profile"{
            let error = json["error"] as? Bool
            if error == false{
                profileModel = nil
                let userProfiles = json["user_profile"] as? [[String: Any]]
                let userProfile = userProfiles?[0]
                profileModel = UserProfileModel(json: userProfile!)
                
                DispatchQueue.main.async { [self] in
                    tableVu.reloadData()
                }
            }else{
                Alert.showAlert(on: self, with: "Error!", message: "Something went wrong try later.")
            }
        }
        Utils.sharedInstance.stopIndicator()
    }
    
    @IBAction func tappedEditBtn(_ sender: Any) {
        let vc:EditProfileVC = UIStoryboard.controller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: Table View
extension ProfileViewController: UITableViewDelegate,UITableViewDataSource{
    
    // MARK: Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    // MARK: Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if profileModel != nil{
            switch section {
            case 0:
                return 1
            case 1:
                return 1
            case 2:
                return profileModel?.workModel.count ?? 0
            case 3:
                return 1
            case 4:
                return profileModel?.collaborationRequests.count ?? 0
            
            default:
                return 0
            }
        }else{
            return 0
        }
    }
    
    // MARK: Cell for row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddSongTableCell", for: indexPath) as! AddSongTableCell
            cell.addSongBtn.addTarget(self, action: #selector(tappedAddSongBtn(_:)), for: .touchUpInside)
            let imageUrl = BaseUrls.baseUrlImages + (profileModel?.userImage)!
            cell.profileImg.downloadImage(imageUrl: imageUrl)
            cell.nameLbl.text = profileModel?.userName
            cell.genreLbl.text = profileModel?.userGenre
            cell.bioLbl.text = profileModel?.userBio
            if cell.bioLbl.text == ""{
                cell.bioLbl.text = "Not Available"
            }
            cell.fbLinkLbl.text = profileModel?.userFB
            if cell.fbLinkLbl.text == ""{
                cell.fbLinkLbl.text = "Not Available"
            }
            cell.youTubeLinkLbl.text = profileModel?.userYoutube
            if cell.youTubeLinkLbl.text == ""{
                cell.youTubeLinkLbl.text = "Not Available"
            }
            cell.instaLinkLbl.text = profileModel?.userInsta
            if cell.instaLinkLbl.text == ""{
                cell.instaLinkLbl.text = "Not Available"
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "WorkHeaderTableCell", for: indexPath) as! WorkHeaderTableCell
            cell.headingLbl.text = "My Work"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableCell", for: indexPath) as! SongTableCell
            cell.workModel = profileModel?.workModel[indexPath.row]
            if indexPath.row == 0 || indexPath.row == 1{
                cell.arrowImage.alpha = 1
                cell.arrowTrailingConstraint.constant = 0
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "WorkHeaderTableCell", for: indexPath) as! WorkHeaderTableCell
            cell.headingLbl.text = "Collaboration Requests"
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CollaborationRequestTableCell", for: indexPath) as! CollaborationRequestTableCell
            cell.collaborationRequest = profileModel?.collaborationRequests[indexPath.row]
            if indexPath.row == 0 || indexPath.row == 1{
                cell.arrowImage.alpha = 1
                cell.arrowTrailingConstraint.constant = 0
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    @objc func tappedAddSongBtn(_ sender:UIButton){
        let vc: AddNewSongVC = UIStoryboard.controller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2{
            let vc: SongDetailVC = UIStoryboard.controller()
            print("profileModel?.workModel[indexPath.row].songId is: \(profileModel?.workModel[indexPath.row].songId)")
            vc.songId = profileModel?.workModel[indexPath.row].songId
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.section == 4{
            let vc: CollaborationDetailVC = UIStoryboard.controller()
            vc.collaborationId = String((profileModel?.collaborationRequests[indexPath.row].collaborationId)!)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: Height for row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 800
        case 1:
            if profileModel?.workModel.count != 0{
                return 100
            }else{
                return 0
            }
        case 2:
            return 110
        case 3:
            if profileModel?.collaborationRequests.count != 0{
                return 100
            }else{
                return 0
            }
        case 4:
            return 120
        default:
            return 0
        }
    }
    
}

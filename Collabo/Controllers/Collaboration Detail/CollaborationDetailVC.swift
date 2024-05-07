//
//  CollaborationDetailVC.swift
//  Collabo
//
//  Created by Tabish on 12/1/20.
//

import UIKit

class CollaborationDetailVC: UIViewController, UIGestureRecognizerDelegate, serverResponse  {
    
    @IBOutlet weak var brandImage: UIImageView!
    @IBOutlet weak var brandlbl: UILabel!
    @IBOutlet weak var genreLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    @IBOutlet weak var brandNameBackVu: UIView!
    
    @IBOutlet weak var backBarBtn: UIBarButtonItem!
    @IBOutlet weak var nameBarBtn: UIBarButtonItem!
    
    var collaborationId: String?
    
    var artistId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        backBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        
        if collaborationId != nil{
            getCollaborationDetail()
        }
    }
    
    func getCollaborationDetail(){
        if CheckInternet.Connection(){
            Utils.sharedInstance.startIndicator()
            let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
            let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
            
            let url = BaseUrls.baseUrl + "GET_COLLABORATION_BY_COLLABORATION_ID.php"
            let headers: [String:String] = [
            "Authorization": jwt
            ]
            let params : [String: Any] = [ "user_id":userId,
                                            "collaboration_id":collaborationId!]
            
            print("params are: \(params)")
            
            serverRequest.delegate = self
            serverRequest.postRequestWithRawData(url: url, header: headers, params: params, type: "")
        }else{
            Alert.showInternetFailureAlert(on: self)
        }
    }
    
    func onResponse(json: [String : Any], val: String) {
        print(json)
        let error = json["error"] as? Bool
        if error == false{
            let allCollaborations = json["collaboration_data"] as! [[String: Any]]
            let singleCollaboration = allCollaborations[0]
            
            let userName = singleCollaboration["user_name"] as? String
            let img = singleCollaboration["project_image"] as? String
            let brandName = singleCollaboration["project_title"] as? String
            let genre = singleCollaboration["genre"] as? String
            let description = singleCollaboration["project_description"] as? String
            
            self.artistId = singleCollaboration["user_id"] as? Int
            
            nameBarBtn.title = userName
            let imageUrl = BaseUrls.baseUrlImages + img!
            brandImage.downloadImage(imageUrl: imageUrl)
            brandlbl.text = brandName
            genreLbl.text = genre
            descLbl.text = description
            
        }else{
            Alert.showAlert(on: self, with: "Response Failed!", message: "Something went wrong.")
        }
        Utils.sharedInstance.stopIndicator()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        brandNameBackVu.roundCorners([.bottomLeft, .bottomRight], radius: 16)
    }
    
    @IBAction func tappedBackBarBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedChatWithArtist(_ sender: Any) {
        let vc: CollaborateChatVC = UIStoryboard.controller()
        vc.receiverId = String(self.artistId!)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

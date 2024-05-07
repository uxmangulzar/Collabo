//
//  SongDetailVC.swift
//  Collabo
//
//  Created by Tabish on 12/1/20.
//

import UIKit
import Alamofire
import AVFoundation

class SongDetailVC: UIViewController, UIGestureRecognizerDelegate, serverResponse {
    
    var audioPlayer: AVPlayer?
    
    @IBOutlet weak var backBarBtn: UIBarButtonItem!
    @IBOutlet weak var songNameBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var addedByLbl: UILabel!
    
    @IBOutlet weak var songImg: UIImageView!
    @IBOutlet weak var songDescLbl: UILabel!
    
    @IBOutlet weak var commentBackVu: UIView!
    @IBOutlet weak var commentTF: UITextField!
    
    @IBOutlet weak var heartBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var commentCountLbl: UILabel!
    
    var songId: Int?
    
    var songModel: SongsModel?
    
    var commentsModel = [CommmentModel]()
    
    var songURL: URL?
    
    @IBOutlet weak var tableVu: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTF.delegate = self
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        backBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        
        setProperties()
        
        if songId != nil{
            getSongDetail(songId: String(songId!))
        }
        
        if songModel != nil{
            songNameBarBtn.title = songModel?.songTitle
            let imageUrl = BaseUrls.baseUrlImages + (songModel?.songImage)!
            addedByLbl.text = songModel?.songTitle
            self.songImg.downloadImage(imageUrl: imageUrl)
            songDescLbl.text = songModel?.songDescription
            
            if songModel?.fovouriteSong == true{
                heartBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
            }else{
                heartBtn.tintColor = UIColor.white
            }
            
            getAllSongsComment()
            let songLocation = BaseUrls.baseUrlImages + (songModel?.songFile)!
            let encodedString = songLocation.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            guard let songUrl = URL(string: encodedString!) else {
                return
            }
            downloadSong(url: songUrl)
        }
    }
    
    func getSongDetail(songId: String){
        if CheckInternet.Connection(){
            Utils.sharedInstance.startIndicator()
            let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
            let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
            
            let url = BaseUrls.baseUrl + "GET_SONG_BY_SONG_ID.php"
            let headers: [String:String] = [
            "Authorization": jwt
            ]
            let params : [String: Any] = ["user_id":userId,
                                          "song_id":songId,
                                         "limit":"1",
                                         "page":"1"]
            
            print("params are: \(params)")
            
            serverRequest.delegate = self
            serverRequest.postRequestWithRawData(url: url, header: headers, params: params, type: "get_song_by_songId")
        }else{
            Alert.showInternetFailureAlert(on: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        audioPlayer?.pause()
    }
    
    func downloadSong(url: URL){
        let playerItem: AVPlayerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: audioPlayer)

        playerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
        self.view.layer.addSublayer(playerLayer)
    }
    
    func getAllSongsComment(){
        if CheckInternet.Connection(){
            Utils.sharedInstance.startIndicator()
            let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
            let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
            
            let url = BaseUrls.baseUrl + "GET_ALL_SONG_COMMENTS.php"
            let headers: [String:String] = [
            "Authorization": jwt
            ]
            let params : [String: Any] = ["user_id":userId,
                                          "song_id": songModel!.songId!,
                                         "limit":"100",
                                         "page":"1"]
            
            print("params are: \(params)")
            
            serverRequest.delegate = self
            serverRequest.postRequestWithRawData(url: url, header: headers, params: params, type: "get_comments")
        }else{
            Alert.showInternetFailureAlert(on: self)
        }
    }
    
    func onResponse(json: [String: Any], val: String) {
        if val == "get_comments"{
            print(json)
            let error = json["error"] as? Bool
            if error == false{
                commentsModel.removeAll()
                let commentsList = json["song_comments"] as! [[String: Any]]
                for singleComment in commentsList {
                    commentsModel.append(CommmentModel(json: singleComment))
                }
                
                DispatchQueue.main.async { [self] in
                    commentCountLbl.text = String(commentsModel.count) + " Comments"
                    tableVu.reloadData()
                }
            }
        }else if val == "add_comment"{
            let status = json["status"] as? String
            if status == "200"{
                commentTF.text = ""
                getAllSongsComment()
            }else{
                let message = json["message"] as? String ?? ""
                Alert.showAlert(on: self, with: "Failed!", message: message)
            }
        }else if val == "get_song_by_songId" {
            let error = json["error"] as? Bool
            if error == false{
                let allSongsArr = json["song_result"] as! [[String: Any]]
                let singleSong = allSongsArr[0]
                songModel = SongsModel(json: singleSong)
                songModel?.songId = String((singleSong["song_id"] as? Int)!)
                songModel?.userId = String((singleSong["user_id"] as? Int)!)
                
                songNameBarBtn.title = songModel?.songTitle
                let imageUrl = BaseUrls.baseUrlImages + (songModel?.songImage)!
                addedByLbl.text = songModel?.songTitle
                self.songImg.downloadImage(imageUrl: imageUrl)
                songDescLbl.text = songModel?.songDescription
                
                if songModel?.fovouriteSong == true{
                    heartBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
                }else{
                    heartBtn.tintColor = UIColor.white
                }
                
                getAllSongsComment()
                let songLocation = BaseUrls.baseUrlImages + (songModel?.songFile)!
                let encodedString = songLocation.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                guard let songUrl = URL(string: encodedString!) else {
                    return
                }
                downloadSong(url: songUrl)
                
            }else{
                Alert.showAlert(on: self, with: "Response Failed!", message: "Something went wrong.")
            }
        }
        Utils.sharedInstance.stopIndicator()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func tappedHeartBtn(_ sender: Any) {
        if CheckInternet.Connection(){
            Utils.sharedInstance.startIndicator()
            let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
            let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
            
            let url = BaseUrls.baseUrl + "ADD_REMOVE_FAVOURITE.php"
            let headers: [String:String] = [
            "Authorization": jwt
            ]
            
            guard let songId = songModel?.songId else {
                return
            }
            
            let params : [String: Any] = ["user_id":userId,
                                          "song_id":songId]
            
            print("params are: \(params)")
            
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                .responseJSON { [self] response in
                    
                    if response.result.isSuccess{
                        let json = response.result.value as? [String: Any]
                        let status = json?["status"] as? String
                        
                        if status == "200"{
                            let favourite = json?["favourite_song"] as? Bool
                            if favourite == true{
                                heartBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
                            }else{
                                heartBtn.tintColor = UIColor.white
                            }
                            songModel?.fovouriteSong = favourite
                            
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadAllSongs"), object: nil, userInfo: nil)
                        }else{
                            let message = json?["message"] as? String
                            Alert.showAlert(on: self, with: "Failed!", message: message ?? "")
                        }
                        Utils.sharedInstance.stopIndicator()
                    }else{
                        Utils.sharedInstance.stopIndicator()
                        print(response.error?.localizedDescription as Any)
                    }
                }
        }else{
            Alert.showInternetFailureAlert(on: self)
        }
    }
    
    @IBAction func tappedPlayBtn(_ sender: Any) {
        if songModel?.isPlaying == false{
            audioPlayer?.play()
            playBtn.setTitle("Pause", for: .normal)
        }else{
            audioPlayer?.pause()
            playBtn.setTitle("Play", for: .normal)
        }
        
        songModel!.isPlaying = !songModel!.isPlaying
    }
    
    @IBAction func tappedBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SongDetailVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if commentTF.text != ""{
            if CheckInternet.Connection(){
                Utils.sharedInstance.startIndicator()
                let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
                let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
                
                let url = BaseUrls.baseUrl + "ADD_COMMENT.php"
                let headers: [String:String] = [
                "Authorization": jwt
                ]
                
                guard let songId = songModel?.songId else {
                    return true
                }
                
                let params : [String: Any] = ["user_id":userId,
                                              "song_id":songId,
                                              "comment_message":commentTF.text!]
                
                print("params are: \(params)")
                
                serverRequest.delegate = self
                serverRequest.postRequestWithRawData(url: url, header: headers, params: params, type: "add_comment")
            }else{
                Alert.showInternetFailureAlert(on: self)
            }
        }else{
            Alert.showAlert(on: self, with: "Comment Required!", message: "Please type a comment.")
        }
        return true
    }
}

extension SongDetailVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCommentTableCell", for: indexPath) as! SongCommentTableCell
        cell.singleComment = commentsModel[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
}

extension SongDetailVC{
    func setProperties(){
        commentBackVu.layer.borderWidth = 2.5
        commentBackVu.layer.borderColor = UIColor.white.cgColor
        
        commentTF.attributedPlaceholder = NSAttributedString(string: "Add comments...",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}

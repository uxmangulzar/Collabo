//
//  SongsViewController.swift
//  Collabo
//
//  Created by Tabish on 11/30/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation

class SongsViewController: UIViewController, serverResponse{
    
    var audioPlayer: AVPlayer?
    
    var previousController: String?
    
    @IBOutlet weak var searchBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var stackVuTopConstraint: NSLayoutConstraint!
    
    let verticalCollectionWidth = UIScreen.main.bounds.width - 24

    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var favouriteBtn: UIButton!
    
    lazy   var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
    
    var menuBtn: UIButton?
    var artistBtn: UIButton?
    
    var searchVisibilityStatus = false
    
    @IBOutlet weak var collectionVu: UICollectionView!
    
    var songsModel = [SongsModel]()
    
    var realData  = [SongsModel]()
    
    var previousIndex: Int?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        searchBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        
        menuBtn = UIButton(type: .system)
        menuBtn?.addTarget(self, action: #selector(tappedMenuBtn(_:)), for: .touchUpInside)
        menuBtn?.setImage(UIImage(named: "menu-icon"), for: .normal)
        menuBtn?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        artistBtn = UIButton(type: .system)
        artistBtn?.setTitle("Songs", for: .normal)
        artistBtn?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: menuBtn!), UIBarButtonItem(customView: artistBtn!)]
        
        if previousController == "HomeViewController"{
            stackVuTopConstraint.constant = -55
            getAllSongs(listType: "favourite")
        }else{
            getAllSongs(listType: "")
        }
        
        createObservers()
    }
    
    func createObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(SongsViewController.updateData), name: Notification.Name(rawValue: "ReloadAllSongs"), object: nil)
    }
    
    @objc func updateData(){
        allBtn.setTitleColor(UIColor.black, for: .normal)
        favouriteBtn.setTitleColor(UIColor.white, for: .normal)
        getAllSongs(listType: "")
    }
    
    func getAllSongs(listType: String){
        if CheckInternet.Connection(){
            Utils.sharedInstance.startIndicator()
            let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
            let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
            
            let url = BaseUrls.baseUrl + "GET_SONGS_BY_ALL_FAVOURITE.php"
            let headers: [String:String] = [
            "Authorization": jwt
            ]
            let params : [String: Any] = ["user_id":userId,
                                        "favourite":listType,
                                           "limit":"100",
                                           "page":"1"]
            
            print("params are: \(params)")
            
            serverRequest.delegate = self
            serverRequest.postRequestWithRawData(url: url, header: headers, params: params, type: "get_songs")
        }else{
            Alert.showInternetFailureAlert(on: self)
        }
    }
    
    func onResponse(json: [String: Any], val: String) {
        if val == "get_songs"{
            let error = json["error"] as? Bool
            if error == false{
                songsModel.removeAll()
                let songsList = json["songs_list"] as! [[String: Any]]
                for singleSong in songsList {
                    songsModel.append(SongsModel(json: singleSong))
                }
                
                self.realData = songsModel

                DispatchQueue.main.async { [self] in
                    collectionVu.reloadData()
                }
            }
        }
        Utils.sharedInstance.stopIndicator()
    }
    
    @objc func tappedMenuBtn(_ sender:UIButton){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeftMenuNavigationController")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func tappedSearchBarBtn(_ sender: Any) {
        if searchVisibilityStatus == false{
            searchBarBtn.image = UIImage(named: "cross-icon")
            
            self.navigationItem.leftBarButtonItems = []
            
            searchBar.placeholder = "Search"
            let leftNavBarButton = UIBarButtonItem(customView:searchBar)
            self.navigationItem.leftBarButtonItem = leftNavBarButton
        }else{
            searchBarBtn.image = UIImage(named: "search-icon")
            
            searchBar.text = ""
            
            self.navigationItem.leftBarButtonItem = nil

            self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: menuBtn!), UIBarButtonItem(customView: artistBtn!)]
            
            self.songsModel = realData
            
            DispatchQueue.main.async { [self] in
                collectionVu.reloadData()
            }
        }
        
        searchVisibilityStatus = !searchVisibilityStatus
    }
    
    @IBAction func tappedAllBtn(_ sender: Any) {
        allBtn.setTitleColor(.black, for: .normal)
        favouriteBtn.setTitleColor(.white, for: .normal)
        
        getAllSongs(listType: "")
    }
    
    @IBAction func tappedFavouriteBtn(_ sender: Any) {
        favouriteBtn.setTitleColor(.black, for: .normal)
        allBtn.setTitleColor(.white, for: .normal)
        
        getAllSongs(listType: "favourite")
    }
}

extension SongsViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        songsModel.removeAll()
        
        for item in realData{
            if item.songTitle.lowercased().contains((searchBar.text?.lowercased())!){
                self.songsModel.append(item)
            }
        }
        
        if (searchBar.text!.isEmpty) {
            songsModel = realData
        }
        
        DispatchQueue.main.async { [self] in
            collectionVu.reloadData()
        }
    }
}

extension SongsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songsModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SongCollectionCell", for: indexPath) as! SongCollectionCell
        if songsModel[indexPath.row].fovouriteSong == true{
            cell.heartBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        }else{
            cell.heartBtn.tintColor = UIColor.white
        }
        
        if songsModel[indexPath.row].isPlaying == true{
            cell.playBtn.setImage(UIImage(named: "pause-button"), for: .normal)
        }else{
            cell.playBtn.setImage(UIImage(named: "play-button"), for: .normal)
        }
        
        cell.singleSong = songsModel[indexPath.row]
        cell.heartBtn.tag = indexPath.row
        cell.heartBtn?.addTarget(self, action: #selector(tappedheartBtn(_:)), for: .touchUpInside)
        
        cell.playBtn.tag = indexPath.row
        cell.playBtn?.addTarget(self, action: #selector(tappedPlayBtn(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func tappedheartBtn(_ sender:UIButton){
        if CheckInternet.Connection(){
            Utils.sharedInstance.startIndicator()
            let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
            let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
            
            let url = BaseUrls.baseUrl + "ADD_REMOVE_FAVOURITE.php"
            let headers: [String:String] = [
            "Authorization": jwt
            ]
            let params : [String: Any] = ["user_id":userId,
                                          "song_id":songsModel[sender.tag].songId!]
            
            print("params are: \(params)")
            
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                .responseJSON { [self] response in
                    
                    if response.result.isSuccess{
                        let json = response.result.value as? [String: Any]
                        let status = json?["status"] as? String
                        
                        if status == "200"{
                            let favourite = json?["favourite_song"] as? Bool
                            let indexPath = IndexPath(item: sender.tag, section: 0)
                            guard let cell = self.collectionVu.cellForItem(at: indexPath) as? SongCollectionCell else { return }
                            if favourite == true{
                                cell.heartBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
                            }else{
                                cell.heartBtn.tintColor = UIColor.white
                            }
                            songsModel[sender.tag].fovouriteSong = favourite
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
    
    @objc func tappedPlayBtn(_ sender:UIButton){
        
        if previousIndex != nil && sender.tag != previousIndex{
            let indexPath = IndexPath(item: previousIndex!, section: 0)
            let cell = self.collectionVu.cellForItem(at: indexPath) as? SongCollectionCell
            cell?.playBtn.setImage(UIImage(named: "play-button"), for: .normal)
            if previousIndex! < songsModel.count{
                songsModel[previousIndex!].isPlaying = false
            }
            audioPlayer?.pause()
        }
        
        if songsModel[sender.tag].isPlaying == false {
            let songLocation = BaseUrls.baseUrlImages + songsModel[sender.tag].songFile
            let encodedString = songLocation.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            guard let songUrl = URL(string: encodedString!) else {
                return
            }
            let indexPath = IndexPath(item: sender.tag, section: 0)
            guard let cell = self.collectionVu.cellForItem(at: indexPath) as? SongCollectionCell else { return }
            cell.playBtn.setImage(UIImage(named: "pause-button"), for: .normal)
            //play the song
            downloadFileFromURL(url: songUrl)
        }else{
            let indexPath = IndexPath(item: sender.tag, section: 0)
            guard let cell = self.collectionVu.cellForItem(at: indexPath) as? SongCollectionCell else { return }
            cell.playBtn.setImage(UIImage(named: "play-button"), for: .normal)
            //pause the song
            audioPlayer?.pause()
        }
        
        songsModel[sender.tag].isPlaying = !songsModel[sender.tag].isPlaying
        
        //save previous song index
        previousIndex = sender.tag
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc:SongDetailVC = UIStoryboard.controller()
        vc.songModel = songsModel[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = verticalCollectionWidth/2 - 12
        return CGSize(width: cellWidth, height: (cellWidth * 1.58))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    
    func downloadFileFromURL(url: URL){

//        URLSession.shared.downloadTask(with: url, completionHandler: { [weak self] (location, response, error) -> Void in
//            guard let location = location, error == nil else { return }
//            do {
//                self?.audioPlayer = try AVAudioPlayer(contentsOf: location)
//                self?.audioPlayer.play()
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//        }).resume()
        
        let playerItem: AVPlayerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: audioPlayer)

        playerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
        self.view.layer.addSublayer(playerLayer)
        audioPlayer?.play()
    }
    
    
}

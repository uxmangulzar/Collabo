//
//  ArtistsViewController.swift
//  Collabo
//
//  Created by Tabish on 11/30/20.
//

import UIKit
import SwiftyJSON

class ArtistsViewController: UIViewController, serverResponse {
    
    @IBOutlet weak var searchBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var genreCollectionVu: UICollectionView!
    @IBOutlet weak var artistCollectionVu: UICollectionView!
    
    let verticalCollectionWidth = UIScreen.main.bounds.width - 24
    
    @IBOutlet weak var titleBarBtn: UIBarButtonItem!
    
    lazy   var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
    
    var menuBtn: UIButton?
    var artistBtn: UIButton?
    
    var searchVisibilityStatus = false
    
    var artistBarButton: UIBarButtonItem?
    
    var genreModel = [GenreModel]()
    
    var artistsModel = [ArtistsModel]()
    
    var realData = [ArtistsModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        searchBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        
        menuBtn = UIButton(type: .system)
        menuBtn?.addTarget(self, action: #selector(tappedMenuBtn(_:)), for: .touchUpInside)
        menuBtn?.setImage(UIImage(named: "menu-icon"), for: .normal)
        menuBtn?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        artistBtn = UIButton(type: .system)
        artistBtn?.setTitle("Artist", for: .normal)
        artistBtn?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: menuBtn!), UIBarButtonItem(customView: artistBtn!)]
        
        getAllGenre()
        getAllArtists(sortBy: "")
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
    
    func getAllArtists(sortBy: String){
        if CheckInternet.Connection(){
            Utils.sharedInstance.startIndicator()
            let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
            let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
            
            let url = BaseUrls.baseUrl + "GET_ALL_USERS_LIST.php"
            let headers: [String:String] = [
            "Authorization": jwt
            ]
            let params : [String: Any] = [  "user_id": userId,
                                            "sort_by":sortBy,
                                            "limit": "100",
                                            "page": "1"]
            
            print("params are: \(params)")
            
            serverRequest.delegate = self
            serverRequest.postRequestWithRawData(url: url, header: headers, params: params, type: "get_artists")
        }else{
            Alert.showInternetFailureAlert(on: self)
        }
    }
    
    func onResponse(json: [String: Any], val: String) {
        if val == "get_genres"{
            let error = json["error"] as? Bool
            if error == false{
                genreModel.removeAll()
                let allGenre = json["genre_result"] as! [[String: Any]]
                for singleGenre in allGenre {
                    genreModel.append(GenreModel(json: singleGenre))
                }
                
                DispatchQueue.main.async { [self] in
                    genreCollectionVu.reloadData()
                }
            }else{
                Alert.showAlert(on: self, with: "Error!", message: "Something went wrong try later.")
            }
        }else if val == "get_artists"{
            let error = json["error"] as? Bool
            if error == false{
                artistsModel.removeAll()
                let userList = json["users_list"] as! [[String: Any]]
                for singleUser in userList {
                    artistsModel.append(ArtistsModel(json: singleUser))
                }
                
                self.realData = artistsModel
                
                DispatchQueue.main.async { [self] in
                    artistCollectionVu.reloadData()
                }
            }else{
                Alert.showAlert(on: self, with: "Error!", message: "Something went wrong try later.")
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
            
            self.artistsModel = realData
            
            DispatchQueue.main.async { [self] in
                artistCollectionVu.reloadData()
            }
        }
        
        searchVisibilityStatus = !searchVisibilityStatus
    }
}

extension ArtistsViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        artistsModel.removeAll()
        
        for item in realData{
            if item.userName.lowercased().contains((searchBar.text?.lowercased())!){
                self.artistsModel.append(item)
            }
        }
        
        if (searchBar.text!.isEmpty) {
            artistsModel = realData
        }
        
        DispatchQueue.main.async { [self] in
            artistCollectionVu.reloadData()
        }
    }
}

extension ArtistsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == genreCollectionVu{
            return (1 + genreModel.count)
        }else{
            return artistsModel.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == genreCollectionVu{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCollectionCell", for: indexPath) as! GenreCollectionCell
            if indexPath.row == 0{
                cell.genreNameLbl.text = "All"
            }else{
                let modelIndex = indexPath.row - 1
                cell.singleGenreModel = genreModel[modelIndex]
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCollectionCell", for: indexPath) as! ArtistCollectionCell
            cell.singleArtistModel = artistsModel[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == artistCollectionVu{
            let vc:ArtistDetailVC = UIStoryboard.controller()
            vc.artistModel = artistsModel[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }else if collectionView == genreCollectionVu{
            if indexPath.row == 0{
                getAllArtists(sortBy: "")
            }else{
                let modelIndex = indexPath.row - 1
                getAllArtists(sortBy: genreModel[modelIndex].genreName.lowercased())
            }
        }
    }
    
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == genreCollectionVu{
            return CGSize(width: 155, height: 70)
        }else{
            let cellWidth = verticalCollectionWidth/2 - 12
            return CGSize(width: cellWidth, height: (cellWidth * 1.52))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == genreCollectionVu{
            return 0
        }else{
            return 12
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == genreCollectionVu{
            return 0
        }else{
            return 12
        }
    }
    
}

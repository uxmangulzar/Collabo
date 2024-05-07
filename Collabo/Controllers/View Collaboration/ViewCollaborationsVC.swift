//
//  ViewCollaborationsVC.swift
//  Collabo
//
//  Created by Tabish on 12/1/20.
//

import UIKit

class ViewCollaborationsVC: UIViewController, UIGestureRecognizerDelegate, serverResponse {
    
    lazy   var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 250, height: 20))
    
    var backBtn: UIButton?
    var collaborationBtn: UIButton?
    
    var searchVisibilityStatus = false
    
    @IBOutlet weak var searchBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var filterBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var collectionVu: UICollectionView!
    
    var collaborationsModel = [CollaborationModel]()
    
    var realData  = [CollaborationModel]()
    
    let verticalCollectionWidth = UIScreen.main.bounds.width - 24

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        searchBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        
        backBtn = UIButton(type: .system)
        backBtn?.addTarget(self, action: #selector(tappedBackBtn(_:)), for: .touchUpInside)
        backBtn?.setImage(UIImage(named: "back-arrow"), for: .normal)
        backBtn?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        collaborationBtn = UIButton(type: .system)
        collaborationBtn?.setTitle("Collaborations", for: .normal)
        collaborationBtn?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backBtn!), UIBarButtonItem(customView: collaborationBtn!)]
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        backBtn!.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        filterBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        
        getAllCollaborations()
    }
    
    @objc func tappedBackBtn(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func getAllCollaborations(){
        if CheckInternet.Connection(){
            Utils.sharedInstance.startIndicator()
            let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
            let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
            
            let url = BaseUrls.baseUrl + "GET_ALL_COLLABORATIONS.php"
            let headers: [String:String] = [
            "Authorization": jwt
            ]
            let params : [String: Any] = ["user_id":userId,
                                          "limit":"100",
                                         "page":"1"]
            
            print("params are: \(params)")
            
            serverRequest.delegate = self
            serverRequest.postRequestWithRawData(url: url, header: headers, params: params, type: "get_collaborations")
        }else{
            Alert.showInternetFailureAlert(on: self)
        }
    }
    
    func onResponse(json: [String : Any], val: String) {
        if val == "get_collaborations"{
            let error = json["error"] as? Bool
            if error == false{
                collaborationsModel.removeAll()
                let collaborationList = json["collaborations_list"] as! [[String: Any]]
                for singleCollaboration in collaborationList {
                    collaborationsModel.append(CollaborationModel(json: singleCollaboration))
                }
                
                self.realData = collaborationsModel

                DispatchQueue.main.async { [self] in
                    collectionVu.reloadData()
                }
            }else{
                Alert.showAlert(on: self, with: "Error!", message: "Something went wrong try later.")
            }
        }
        Utils.sharedInstance.stopIndicator()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func tappedFilterBtn(_ sender: Any) {
        let vc: FilterVC = UIStoryboard.controller()
        self.navigationController?.pushViewController(vc, animated: true)
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

            self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backBtn!), UIBarButtonItem(customView: collaborationBtn!)]
            
            self.collaborationsModel = realData
            
            DispatchQueue.main.async { [self] in
                collectionVu.reloadData()
            }
        }
        
        searchVisibilityStatus = !searchVisibilityStatus
    }
}

extension ViewCollaborationsVC: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        collaborationsModel.removeAll()
        
        for item in realData{
            if item.projectTitle.lowercased().contains((searchBar.text?.lowercased())!){
                self.collaborationsModel.append(item)
            }
        }
        
        if (searchBar.text!.isEmpty) {
            collaborationsModel = realData
        }
        
        DispatchQueue.main.async { [self] in
            collectionVu.reloadData()
        }
    }
}

extension ViewCollaborationsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collaborationsModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollaborationCollectionCell", for: indexPath) as! CollaborationCollectionCell
        cell.collaborationModel = collaborationsModel[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc:CollaborationDetailVC = UIStoryboard.controller()
        vc.collaborationId = collaborationsModel[indexPath.row].collaborationId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = verticalCollectionWidth/2 - 8
    return CGSize(width: cellWidth, height: (cellWidth * 1.25))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}

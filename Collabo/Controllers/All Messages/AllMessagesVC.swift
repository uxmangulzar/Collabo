//
//  AllMessagesVC.swift
//  Collabo
//
//  Created by Tabish on 12/1/20.
//

import UIKit
import SwiftyJSON

class AllMessagesVC: UIViewController, serverResponse {
    
    @IBOutlet weak var searchBarBtn: UIBarButtonItem!
    
    lazy   var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
    
    var menuBtn: UIButton?
    var artistBtn: UIButton?
    
    var searchVisibilityStatus = false
    
    @IBOutlet weak var tableVu: UITableView!
    var chatModel = [ChatModel]()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        
        menuBtn = UIButton(type: .system)
        menuBtn?.addTarget(self, action: #selector(tappedMenuBtn(_:)), for: .touchUpInside)
        menuBtn?.setImage(UIImage(named: "menu-icon"), for: .normal)
        menuBtn?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        artistBtn = UIButton(type: .system)
        artistBtn?.setTitle("Chat", for: .normal)
        artistBtn?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: menuBtn!), UIBarButtonItem(customView: artistBtn!)]
        
        createObservers()
        getAllChats()
    }
    
    func createObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(AllMessagesVC.updateData), name: Notification.Name(rawValue: "ReloadNewMessages"), object: nil)
    }
    
    @objc func updateData(){
        getAllChats()
    }
    
    func getAllChats(){
        if CheckInternet.Connection(){
            Utils.sharedInstance.startIndicator()
            let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
            let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
            
            let url = BaseUrls.baseUrl + "GET_USER_CHATS.php"
            let headers: [String:String] = [
            "Authorization": jwt
            ]
            let params : [String: Any] = ["user_id":userId,
                                           "limit":"100",
                                           "page":"1"]
            
            print("params are: \(params)")
            
            serverRequest.delegate = self
            serverRequest.postRequestWithRawData(url: url, header: headers, params: params, type: "get_chat")
        }else{
            Alert.showInternetFailureAlert(on: self)
        }
    }
    
    func onResponse(json: [String: Any], val: String) {
        if val == "get_chat"{
            print(json)
            let error = json["error"] as? Bool
            if error == false{
                chatModel.removeAll()
                let allChats = json["user_chats"] as! [[String: Any]]
                for singleChat in allChats {
                    chatModel.append(ChatModel(json: singleChat))
                }

                DispatchQueue.main.async { [self] in
                    tableVu.reloadData()
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
            
            self.navigationItem.leftBarButtonItem = nil

            self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: menuBtn!), UIBarButtonItem(customView: artistBtn!)]
        }
        
        searchVisibilityStatus = !searchVisibilityStatus
    }
}

extension AllMessagesVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableCell", for: indexPath) as! MessageTableCell
        cell.chatModel = chatModel[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
        let vc: ChatViewController = UIStoryboard.controller()
        vc.chatId = String(chatModel[indexPath.row].chatId)
        let receiverId = String(chatModel[indexPath.row].receiverId)
        if receiverId == userId{
            vc.receaverId = String(chatModel[indexPath.row].senderId)
        }else{
            vc.receaverId = receiverId
        }
        vc.receaverName = chatModel[indexPath.row].userName
        vc.receaverImage = chatModel[indexPath.row].userImage
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

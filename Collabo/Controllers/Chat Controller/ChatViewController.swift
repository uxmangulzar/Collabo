//
//  ChatViewController.swift
//  Collabo
//
//  Created by Tabish on 12/2/20.
//

import UIKit

class ChatViewController: UIViewController, serverResponse {
    
    @IBOutlet weak var planeBackVu: UIView!
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var messageTF: UITextField!
    
    var chatId: String?
    var receaverId: String?
    
    var receaverName: String?
    var receaverImage: String?
    
    @IBOutlet weak var tableVu: UITableView!
    var messagesModel = [MessagesModel]()
    
    let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
    
    var webSocketTask: URLSessionWebSocketTask?{
        didSet{
            ping()
            
            let params : [String: Any] = [  "userid": Int(userId)!,
                                            "type": "login"]
            
            var formatedString: String?
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
                if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
                    print("jsonString is: ", jsonString)
                    formatedString = jsonString
                }
            } catch {
                print(error)
            }
            sendUserId(jsonMessage: formatedString!)
            
            receive()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTF.attributedPlaceholder = NSAttributedString(string: "Type your message here",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        planeBackVu.round()
        
        profileImg.round()
        
        if receaverId != nil{
            let imageUrl = BaseUrls.baseUrlImages + receaverImage!
            profileImg.urlSessiondownloadImage(imageUrl, placeHolder: nil)
            nameLbl.text = receaverName
            getAllMessages()
        }
        
        let webSocketDelegate = ChatViewController()
        let session = URLSession(configuration: .default, delegate: webSocketDelegate, delegateQueue: OperationQueue())
        let url = URL(string: "ws://collabozone.com:8282")!
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        close()
    }
    
    func getAllMessages(){
        if CheckInternet.Connection(){
            
            let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
            
            let url = BaseUrls.baseUrl + "GET_ALL_MESSAGES_BY_USERID.php"
            let headers: [String:String] = [
            "Authorization": jwt
            ]
            let params : [String: Any] = [ "user_id":userId,
                                           "sender_id":receaverId!,
                                           "limit":"1000",
                                           "page":"1" ]
            
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
            messagesModel.removeAll()
            let allMessages = json["user_messages"] as! [[String: Any]]
            for index in 0...(allMessages.count - 1) {
                messagesModel.append(MessagesModel(json: allMessages[(allMessages.count - 1) - index]))
            }

            DispatchQueue.main.async { [self] in
                tableVu.reloadData()
                
                let tableIndex = IndexPath(row: 0, section: messagesModel.count - 1)
                self.tableVu.scrollToRow(at: tableIndex, at: .top, animated: true)
            }
        }
    }
    
    @IBAction func tappedSendBtn(_ sender: Any) {
        if messageTF.text != ""{
            let params : [String: Any] = [  "userid": Int(userId)!,
                                            "recid": Int(receaverId!)!,
                                            "msg": messageTF.text!,
                                            "imgname": "",
                                            "chatid": Int(chatId!)!,
                                            "type": "message"]
            
            var formatedString: String?
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
                if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
                    print("jsonString is: ", jsonString)
                    formatedString = jsonString
                }
            } catch {
                print(error)
            }
            sendMessage(jsonMessage: formatedString!)
        }
    }
    
    @IBAction func tappedBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ChatViewController: URLSessionWebSocketDelegate{
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Web Socket did connect")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Web Socket did disconnect")
    }
}

extension ChatViewController{
    
    func ping() {
        webSocketTask?.sendPing { error in
        if let error = error {
          print("Error when sending PING \(error)")
        } else {
            print("Web Socket connection is alive")
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                self.ping()
            }
        }
      }
    }

    func close() {
        let reason = "Closing connection".data(using: .utf8)
        webSocketTask?.cancel(with: .goingAway, reason: reason)
    }

    func sendMessage(jsonMessage: String) {
        self.webSocketTask?.send(.string(jsonMessage)) { error in
          if let error = error {
            print("Error when sending a message \(error)")
          }else if error == nil{
            print("no error!")
            let userName:String = UserDefaults.standard.string(forKey: UserDefaultKey.userName)!
            let userImage:String = UserDefaults.standard.string(forKey: UserDefaultKey.userImg)!
            self.insertNewMessage(receaverId: Int(self.receaverId ?? "0")!, senderId: Int(self.userId) ?? 0, receaverName: "", receaverImage: "", senderName: userName, senderImage: userImage, message: self.messageTF.text ?? "", creationDate: "1 second ago")
          }
        }
    }
    
    func sendUserId(jsonMessage: String){
        self.webSocketTask?.send(.string(jsonMessage)) { error in
          if let error = error {
            print("Error when sending a message \(error)")
          }else if error == nil{
            print("no error!")
          }
        }
    }

    func receive() {
        webSocketTask?.receive { result in
            print(result)
        switch result {
        case .success(let message):
          switch message {
          case .data(let data):
            print("Data received \(data)")
          case .string(let text):
            print("Text received \(text)")
            let data = text.data(using: .utf8)!
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                let dataReceaved = json as? [String: Any]
                let currentUserId = dataReceaved?["recid"] as? Int
                let receaverId = dataReceaved?["userid"] as? Int
                let receaverName = dataReceaved?["from"] as? String
                let message = dataReceaved?["msg"] as? String

                self.insertNewMessage(receaverId: currentUserId ?? 0, senderId: receaverId ?? 0, receaverName: "", receaverImage: "", senderName: receaverName ?? "", senderImage: self.receaverImage ?? "", message: message ?? "", creationDate: "1 second ago")
            } catch let error as NSError {
                print(error)
            }
            
          @unknown default:
            print("Default Case")
          }
        case .failure(let error):
          print("Error when receiving \(error)")
        }
        
            self.receive()
      }
    }
}

extension ChatViewController{
    
    func insertNewMessage(receaverId: Int, senderId: Int, receaverName: String, receaverImage: String, senderName: String, senderImage: String, message: String, creationDate: String){
        
        DispatchQueue.main.async { [self] in
            let messageModel = MessagesModel()
            messageModel.receiverId = receaverId
            messageModel.senderId = senderId
            messageModel.receaverName = receaverName
            messageModel.receaverImage = receaverImage
            messageModel.senderName = senderName
            messageModel.senderImage = senderImage
            messageModel.message = message
            messageModel.creationDate = creationDate
            self.messagesModel.append(messageModel)

            let indexSet = IndexSet(integer: self.messagesModel.count - 1)
            self.tableVu.performBatchUpdates({
                self.tableVu.insertSections(indexSet, with: .none)
                    }) { (update) in
                        print("Update SUccess")
                    }
            self.messageTF.text = ""

            let tableIndex = IndexPath(row: 0, section: self.messagesModel.count - 1)
            self.tableVu.scrollToRow(at: tableIndex, at: .top, animated: true)
        }
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messagesModel.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if userId == String(messagesModel[indexPath.section].senderId){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SenderTableCell", for: indexPath) as! SenderTableCell
            cell.singleMessage = messagesModel[indexPath.section]
            
            let messageWidth = cell.messageLbl.intrinsicContentSize.width
            cell.messageLblWidth.constant = messageWidth
            cell.messageBackVuWidth.constant = messageWidth + 32

            if messageWidth > 248{
                cell.messageLblWidth.constant = 248
                cell.messageBackVuWidth.constant = 280
            }
            cell.layoutIfNeeded()
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverTableCell", for: indexPath) as! ReceiverTableCell
            cell.singleMessage = messagesModel[indexPath.section]
            
            let messageWidth = cell.messageLbl.intrinsicContentSize.width
            cell.messageLblWidth.constant = messageWidth
            cell.messageBackVuWidth.constant = messageWidth + 32

            if messageWidth > 248{
                cell.messageLblWidth.constant = 248
                cell.messageBackVuWidth.constant = 280
            }
            cell.layoutIfNeeded()
            
            return cell
        }
    }
}

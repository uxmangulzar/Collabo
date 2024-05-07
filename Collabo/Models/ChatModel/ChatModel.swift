//
//  ChatModel.swift
//  Collabo
//
//  Created by Tabish on 12/4/20.
//

import Foundation

class ChatModel {
    
    var chatId: Int!
    var receiverId: Int!
    var senderId: Int!
    var userName: String!
    var userImage: String!
    var message: String!
    var date: String!
    var creationDate: String!
    
    init(json: [String: Any]) {
        if json.isEmpty{
            return
        }
        
        chatId = json["chat_id"] as? Int
        receiverId = json["receiver_id"] as? Int
        senderId = json["sender_id"] as? Int
        userName = json["user_name"] as? String
        userImage = json["user_profile"] as? String
        message = json["message"] as? String
        date = json["updated_at"] as? String
        creationDate = json["created_at"] as? String
    }
}

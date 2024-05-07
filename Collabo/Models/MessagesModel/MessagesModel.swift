//
//  MessagesModel.swift
//  Collabo
//
//  Created by Tabish on 12/8/20.
//

import Foundation

class MessagesModel {
    
    var receiverId: Int!
    var senderId: Int!
    var receaverName: String!
    var receaverImage: String!
    var senderName: String!
    var senderImage: String!
    var message: String!
    var creationDate: String!
    
    init(json: [String: Any]) {
        if json.isEmpty{
            return
        }
        
        receiverId = json["receiver_id"] as? Int
        senderId = json["sender_id"] as? Int
        receaverName = json["receiver_name"] as? String
        receaverImage = json["receiver_image"] as? String
        senderName = json["sender_name"] as? String
        senderImage = json["sender_image"] as? String
        message = json["messages"] as? String
        creationDate = json["created_at"] as? String
    }
    
    init() {
    }
}

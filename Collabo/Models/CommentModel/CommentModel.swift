//
//  CommentModel.swift
//  Collabo
//
//  Created by Tabish on 12/4/20.
//

import Foundation

class CommmentModel {
    
    var commentId: String!
    var userName: String!
    var userImage: String!
    var commentMessage: String!
    var creationDate: String!
    
    init(json: [String: Any]) {
        if json.isEmpty{
            return
        }
        
        commentId = json["comments_id"] as? String
        userName = json["user_name"] as? String
        userImage = json["user_image"] as? String
        commentMessage = json["comment_message"] as? String
        creationDate = json["created_at"] as? String
    }
}

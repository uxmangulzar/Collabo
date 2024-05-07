//
//  CollaborationModel.swift
//  Collabo
//
//  Created by Tabish on 12/7/20.
//

import Foundation

class CollaborationModel {
    
    var userId: String!
    var userImage: String!
    var userName: String!
    var genre: String!
    var collaborationId: String!
    var projectTitle: String!
    var projectImage: String!
    var projectDesc: String!
    var creationDate: String!
    
    init(json: [String: Any]) {
        if json.isEmpty{
            return
        }
        
        userId = json["user_id"] as? String
        userImage = json["user_image"] as? String
        userName = json["user_name"] as? String
        genre = json["genre"] as? String
        collaborationId = json["collaboration_id"] as? String
        creationDate = json["created_at"] as? String
        projectTitle = json["project_title"] as? String
        projectImage = json["project_image"] as? String
        projectDesc = json["project_description"] as? String
        creationDate = json["created_at"] as? String
    }
}

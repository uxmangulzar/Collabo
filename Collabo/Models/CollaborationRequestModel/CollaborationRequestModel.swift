//
//  CollaborationRequestModel.swift
//  Collabo
//
//  Created by Tabish on 12/4/20.
//

import Foundation

class CollaborationRequestModel {
    
    var collaborationId: Int!
    var userName: String!
    var userImage: String!
    var projectTitle: String!
    var projectImage: String!
    var projectDesc: String!
    var creationDate: String!
    
    init(json: [String: Any]) {
        if json.isEmpty{
            return
        }
        
        collaborationId = json["collaboration_id"] as? Int
        userName = json["user_name"] as? String
        userImage = json["user_image"] as? String
        projectTitle = json["project_title"] as? String
        projectImage = json["project_image"] as? String
        projectDesc = json["project_description"] as? String
        creationDate = json["created_at"] as? String
    }
}

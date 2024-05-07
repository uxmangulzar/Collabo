//
//  UserProfileModel.swift
//  Collabo
//
//  Created by Tabish on 12/4/20.
//

import Foundation

class UserProfileModel {
    
    var userId: String!
    var userName: String!
    var userImage: String!
    var userEmail: String!
    var userGenre: String!
    var userBio: String!
    var userFB: String!
    var userInsta: String!
    var userYoutube: String!
    var creationDate: String!
    
    var workModel = [WorkModel]()
    var collaborationRequests = [CollaborationRequestModel]()
    
    init(json: [String: Any]) {
        if json.isEmpty{
            return
        }
        
        userId = json["user_id"] as? String
        userName = json["user_name"] as? String
        userImage = json["user_image"] as? String
        userGenre = json["user_genre"] as? String
        userBio = json["user_bio"] as? String
        userFB = json["user_fb"] as? String
        userInsta = json["user_ig"] as? String
        userYoutube = json["user_youtube"] as? String
        creationDate = json["created_at"] as? String
        
        let allSongs = json["songs_list"] as! [[String: Any]]
        for singleSong in allSongs {
            workModel.append(WorkModel(json: singleSong))
        }
        
        let allRequests = json["collaboration_requests"] as! [[String: Any]]
        for singleRequest in allRequests {
            collaborationRequests.append(CollaborationRequestModel(json: singleRequest))
        }
    }
}

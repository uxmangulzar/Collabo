//
//  AllArtistsModel.swift
//  Collabo
//
//  Created by Tabish on 12/3/20.
//

import Foundation

class ArtistsModel {
    
    var userId: String!
    var userImage: String!
    var userName: String!
    var userEmail: String!
    var userGenre: String!
    var creationDate: String!
    var userBio: String!
    var userFB: String!
    var userInsta: String!
    var userYoutube: String!
    
    init(json: [String: Any]) {
        if json.isEmpty{
            return
        }
        
        userId = json["user_id"] as? String
        userImage = json["user_image"] as? String
        userName = json["user_name"] as? String
        userEmail = json["user_email"] as? String
        userGenre = json["user_genre"] as? String
        creationDate = json["created_at"] as? String
        userBio = json["user_bio"] as? String
        userFB = json["user_fb"] as? String
        userInsta = json["user_ig"] as? String
        userYoutube = json["user_youtube"] as? String
    }
}

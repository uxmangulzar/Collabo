//
//  WorkModel.swift
//  Collabo
//
//  Created by Tabish on 12/4/20.
//

import Foundation

class WorkModel {
    
    var songId: Int!
    var songImage: String!
    var songDesc: String!
    var songTitle: String!
    var creationDate: String!
    
    init(json: [String: Any]) {
        if json.isEmpty{
            return
        }
        
        songId = json["song_id"] as? Int
        songImage = json["song_image"] as? String
        songDesc = json["song_description"] as? String
        songTitle = json["song_title"] as? String
        creationDate = json["created_at"] as? String
    }
}

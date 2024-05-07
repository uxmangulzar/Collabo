//
//  SongsModel.swift
//  Collabo
//
//  Created by Tabish on 12/3/20.
//

import Foundation

class SongsModel {
    
    var songId: String!
    var songImage: String!
    var songTitle: String!
    var songFile: String!
    var songLink: String!
    var songDescription: String!
    var userId: String!
    var creationDate: String!
    
    var fovouriteSong: Bool!
    
    var isPlaying = false
    
    init(json: [String: Any]) {
        if json.isEmpty{
            return
        }
        
        songId = json["song_id"] as? String
        songImage = json["song_image"] as? String
        songTitle = json["song_title"] as? String
        songFile = json["song_file"] as? String
        songLink = json["song_link"] as? String
        songDescription = json["song_description"] as? String
        userId = json["user_id"] as? String
        creationDate = json["created_at"] as? String
        
        fovouriteSong = json["favourite_song"] as? Bool
    }
}

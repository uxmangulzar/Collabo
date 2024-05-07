//
//  GenreModel.swift
//  Collabo
//
//  Created by Tabish on 12/3/20.
//

import Foundation

class GenreModel {
    
    var genreId: String!
    var genreName: String!
    
    init(json: [String: Any]) {
        if json.isEmpty{
            return
        }
        
        genreId = json["genre_id"] as? String
        genreName = json["genre_name"] as? String
    }
}

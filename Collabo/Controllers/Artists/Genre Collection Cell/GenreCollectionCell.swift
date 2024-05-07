//
//  GenreCollectionCell.swift
//  Collabo
//
//  Created by Tabish on 11/30/20.
//

import UIKit

class GenreCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var genreNameLbl: UILabel!
    
    var singleGenreModel: GenreModel?{
        didSet{
            genreNameLbl.text = singleGenreModel?.genreName
        }
    }
    
}

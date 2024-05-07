//
//  ArtistCollectionCell.swift
//  Collabo
//
//  Created by Tabish on 11/30/20.
//

import UIKit

class ArtistCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var artistImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var genreDateLbl: UILabel!
    
    var singleArtistModel: ArtistsModel?{
        didSet{
            let imageUrl = BaseUrls.baseUrlImages + (singleArtistModel?.userImage)!
            self.artistImg.downloadImage(imageUrl: imageUrl)
            nameLbl.text = singleArtistModel?.userName
            genreDateLbl.text = (singleArtistModel?.userGenre)! + " | " + (singleArtistModel?.creationDate)!
        }
    }
}

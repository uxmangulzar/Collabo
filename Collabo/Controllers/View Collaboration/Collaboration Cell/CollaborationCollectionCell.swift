//
//  CollaborationCollectionCell.swift
//  Collabo
//
//  Created by Tabish on 12/1/20.
//

import UIKit

class CollaborationCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var genreLbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var namelbl: UILabel!
    @IBOutlet weak var nameDateLbl: UILabel!
    
    var collaborationModel: CollaborationModel?{
        didSet{
            genreLbl.text = collaborationModel?.genre
            let imageUrl = BaseUrls.baseUrlImages + (collaborationModel?.userImage)!
            profileImg.downloadImage(imageUrl: imageUrl)
            namelbl.text = collaborationModel?.projectTitle
            nameDateLbl.text = (collaborationModel?.userName)! + " | " + (collaborationModel?.creationDate)!
        }
    }
}

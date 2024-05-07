//
//  SongTableCell.swift
//  Collabo
//
//  Created by Tabish on 12/1/20.
//

import UIKit

class SongTableCell: UITableViewCell {

    @IBOutlet weak var songImg: UIImageView!
    @IBOutlet weak var songNameLbl: UILabel!
    @IBOutlet weak var songDescLbl: UILabel!
    
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var arrowTrailingConstraint: NSLayoutConstraint!
    
    var workModel: WorkModel?{
        didSet{
            let imageUrl = BaseUrls.baseUrlImages + (workModel?.songImage)!
            songImg.downloadImage(imageUrl: imageUrl)
            songNameLbl.text = workModel?.songTitle
            songDescLbl.text = workModel?.songDesc
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        arrowImage.alpha = 0
        arrowTrailingConstraint.constant = -38
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        songImg.round()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

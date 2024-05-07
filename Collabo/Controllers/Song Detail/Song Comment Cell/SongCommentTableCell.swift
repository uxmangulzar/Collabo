//
//  SongCommentTableCell.swift
//  Collabo
//
//  Created by Tabish on 12/1/20.
//

import UIKit

class SongCommentTableCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    
    var singleComment: CommmentModel?{
        didSet{
            let imageUrl = BaseUrls.baseUrlImages + (singleComment?.userImage)!
            self.profileImg.downloadImage(imageUrl: imageUrl)
            nameLbl.text = singleComment?.userName
            commentLbl.text = singleComment?.commentMessage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImg.round()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

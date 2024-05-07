//
//  CollaborationRequestTableCell.swift
//  Collabo
//
//  Created by Tabish on 12/1/20.
//

import UIKit

class CollaborationRequestTableCell: UITableViewCell {
    
    @IBOutlet weak var projectImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var arrowTrailingConstraint: NSLayoutConstraint!
    
    var collaborationRequest: CollaborationRequestModel?{
        didSet{
            let imageUrl = BaseUrls.baseUrlImages + (collaborationRequest?.userImage)!
            projectImage.downloadImage(imageUrl: imageUrl)
            nameLbl.text = collaborationRequest?.projectTitle
            descLbl.text = collaborationRequest?.projectDesc
            userNameLbl.text = collaborationRequest?.userName
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        arrowImage.alpha = 0
        arrowTrailingConstraint.constant = -38
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

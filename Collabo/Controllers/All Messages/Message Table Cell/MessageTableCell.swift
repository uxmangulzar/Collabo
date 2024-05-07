//
//  MessageTableCell.swift
//  Collabo
//
//  Created by Tabish on 12/1/20.
//

import UIKit

class MessageTableCell: UITableViewCell {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var dateTimeLbl: UILabel!
    
    var chatModel: ChatModel?{
        didSet{
            let imageUrl = BaseUrls.baseUrlImages + (chatModel?.userImage)!
            userImg.downloadImage(imageUrl: imageUrl)
            nameLbl.text = chatModel?.userName
            descLbl.text = chatModel?.message
            dateTimeLbl.text = chatModel?.date
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImg.round()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

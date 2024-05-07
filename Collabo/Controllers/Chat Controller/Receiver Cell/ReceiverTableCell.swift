//
//  ReceiverTableCell.swift
//  Collabo
//
//  Created by Tabish on 12/2/20.
//

import UIKit

class ReceiverTableCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var messageBackVu: UIView!
    @IBOutlet weak var messageBackVuWidth: NSLayoutConstraint!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var messageLblWidth: NSLayoutConstraint!
    @IBOutlet weak var timeLbl: UILabel!
    
    var singleMessage: MessagesModel?{
        didSet{
            let imageUrl = BaseUrls.baseUrlImages + (singleMessage?.senderImage)!
            self.userImage.urlSessiondownloadImage(imageUrl, placeHolder: nil)
            userNameLbl.text = singleMessage?.senderName
            messageLbl.text = singleMessage?.message
            timeLbl.text = singleMessage?.creationDate
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        let messageWidth = messageLbl.intrinsicContentSize.width
        messageLblWidth.constant = messageWidth
       messageBackVuWidth.constant = messageWidth + 32

        if messageWidth > 248{
            messageLblWidth.constant = 248
            messageBackVuWidth.constant = 280
        }
        self.layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  AddSongTableCell.swift
//  Collabo
//
//  Created by Tabish on 12/1/20.
//

import UIKit

class AddSongTableCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var genreLbl: UILabel!
    @IBOutlet weak var bioLbl: UILabel!
    @IBOutlet weak var youTubeLinkLbl: UILabel!
    @IBOutlet weak var fbLinkLbl: UILabel!
    @IBOutlet weak var instaLinkLbl: UILabel!
    
    @IBOutlet weak var youtubeIconBackVu: UIView!
    @IBOutlet weak var fbIconBackVu: UIView!
    @IBOutlet weak var instaIconBackVu: UIView!

    @IBOutlet weak var addSongBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        youtubeIconBackVu.round()
        fbIconBackVu.round()
        instaIconBackVu.round()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  FilterTableCell.swift
//  Collabo
//
//  Created by Tabish on 12/2/20.
//

import UIKit

class FilterTableCell: UITableViewCell {

    @IBOutlet weak var tickImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tickImg.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

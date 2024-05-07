//
//  SongCollectionCell.swift
//  Collabo
//
//  Created by Tabish on 11/30/20.
//

import UIKit

class SongCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var songDescLbl: UILabel!
    
    @IBOutlet weak var heartBtn: UIButton!
    
    @IBOutlet weak var playBtn: UIButton!
    
    
    var singleSong: SongsModel?{
        didSet{
            let imageUrl = BaseUrls.baseUrlImages + (singleSong?.songImage)!
            self.songImage.downloadImage(imageUrl: imageUrl)
            songTitleLbl.text = singleSong?.songTitle
            songDescLbl.text = singleSong?.songDescription
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

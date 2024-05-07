//
//  ArtistDetailVC.swift
//  Collabo
//
//  Created by Tabish on 11/30/20.
//

import UIKit

class ArtistDetailVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var backBarBtn: UIBarButtonItem!
    @IBOutlet weak var nameBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var emailVu: UIView!
    @IBOutlet weak var fbVu: UIView!
    @IBOutlet weak var instaVu: UIView!
    
    @IBOutlet weak var artistImg: UIImageView!
    @IBOutlet weak var genreLbl: UILabel!
    @IBOutlet weak var bioLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var fbLinkLbl: UILabel!
    @IBOutlet weak var instaLinkLbl: UILabel!
    
    var artistModel: ArtistsModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if artistModel != nil{
            nameBarBtn.title = artistModel?.userName
            let imageUrl = BaseUrls.baseUrlImages + (artistModel?.userImage)!
            self.artistImg.downloadImage(imageUrl: imageUrl)
            genreLbl.text = artistModel?.userGenre
            bioLbl.text = artistModel?.userBio
            emailLbl.text = artistModel?.userEmail
            fbLinkLbl.text = artistModel?.userFB
            if fbLinkLbl.text == ""{
                fbLinkLbl.text = "Not Available"
            }
            instaLinkLbl.text = artistModel?.userInsta
            if instaLinkLbl.text == ""{
                instaLinkLbl.text = "Not Available"
            }
        }
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        backBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        
        emailVu.round()
        fbVu.round()
        instaVu.round()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func tappedLetsCollaborate(_ sender: Any) {
        let vc: CollaborateChatVC = UIStoryboard.controller()
        vc.receiverId = artistModel?.userId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tappedBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

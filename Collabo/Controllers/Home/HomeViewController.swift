//
//  HomeViewController.swift
//  Collabo
//
//  Created by Tabish on 11/30/20.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var favouritiesBtn: UIButton!
    @IBOutlet weak var newCollaborationBtn: UIButton!
    @IBOutlet weak var newArtistBtn: UIButton!
    @IBOutlet weak var browseCollaborationBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBorderColor()
    }
    
    @IBAction func tappedFavouritiesBtn(_ sender: Any) {
        let vc: SongsViewController = UIStoryboard.controller()
        vc.previousController = "HomeViewController"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tappedNewCollaboration(_ sender: Any) {
        let vc: AddNewCollaborationVC = UIStoryboard.controller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tapppedNewArtist(_ sender: Any) {
        let vc: ArtistsViewController = UIStoryboard.controller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tappedBrowseCollaboration(_ sender: Any) {
        let vc: ViewCollaborationsVC = UIStoryboard.controller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setBorderColor(){
        favouritiesBtn.layer.borderWidth = 2.5
        favouritiesBtn.layer.borderColor = UIColor.white.cgColor
        
        newCollaborationBtn.layer.borderWidth = 2.5
        newCollaborationBtn.layer.borderColor = UIColor.white.cgColor
        
        newArtistBtn.layer.borderWidth = 2.5
        newArtistBtn.layer.borderColor = UIColor.white.cgColor
        
        browseCollaborationBtn.layer.borderWidth = 2.5
        browseCollaborationBtn.layer.borderColor = UIColor.white.cgColor
    }
}

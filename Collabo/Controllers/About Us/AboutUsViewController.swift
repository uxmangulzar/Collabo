//
//  AboutUsViewController.swift
//  Collabo
//
//  Created by Tabish on 12/2/20.
//

import UIKit

class AboutUsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "About Us"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func tappedBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

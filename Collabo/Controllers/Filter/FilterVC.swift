//
//  FilterVC.swift
//  Collabo
//
//  Created by Tabish on 12/2/20.
//

import UIKit

class FilterVC: UIViewController {

    @IBOutlet weak var crossBarBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        crossBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
    }
    
    @IBAction func tappedCrossBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension FilterVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableCell", for: indexPath) as! FilterTableCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FilterTableCell
        cell.tickImg.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FilterTableCell
        cell.tickImg.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}

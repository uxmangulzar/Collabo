//
//  Alert.swift
//  FleetApp
//
//  Created by Bilal Mahmood on 2/17/20.
//  Copyright © 2020 Sigi Technologies. All rights reserved.
//

import Foundation
import UIKit

struct Alert {
    
    // MARK: - Show Only Alert
    static func showAlert(on vc:UIViewController,with title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Show Common Alert like internet failure
    static func showInternetFailureAlert(on vc:UIViewController){
        showAlert(on: vc, with: "Alert", message: "Something went wrong with the internet connection")
    }
    
    
    // MARK: - Show Alert & Move to HOME
    static func showAlertHome(vc : UIViewController, title : String , message: String) ->()
    {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .cancel) { (alert) in
            //            Utils.app.movetoHome()
        }
        alertView.addAction(alertAction)
        vc.present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - Show Pop Alert
    static func showAlertPop(vc : UIViewController,navigation:UINavigationController , title : String , message: String) ->()
    {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .cancel) { (alert) in
            navigation.popViewController(animated: true)
        }
        alertView.addAction(alertAction)
        vc.present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - Ask Alert
      static func AskAlert(vc:UIViewController,title:String,message:String,trueTitle:String,falseTitle:String,completion:@escaping(_ result:Bool) -> Void) {
          let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
          vc.present(alert, animated: true, completion: nil)
          alert.addAction(UIAlertAction(title: falseTitle, style: UIAlertAction.Style.default, handler: { _ in
              completion(false)
          }))
          alert.addAction(UIAlertAction(title:trueTitle ,
                                        style: UIAlertAction.Style.destructive,
                                        handler: {(_: UIAlertAction!) in
                                          
                                          completion(true)
                                          
          }))
      }
}


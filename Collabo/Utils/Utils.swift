//
//  Utils.swift
//  deliveriance
//
//  Created by Zeeshan Ashraf on 28/02/2020.
//  Copyright © 2020 SigiTechnologies. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import SDWebImage
import CoreLocation

class Utils: UIViewController,NVActivityIndicatorViewable{
    static let sharedInstance = Utils()
    private let type = 33
    static let app = (UIApplication.shared.delegate as! AppDelegate )
    //    static let headers: HTTPHeaders = [
    //           "Authorization": UserDefaults.standard.value(forKey: "header") as! String,
    //           "Accept": "application/json"]
    
    
    
    // MARK: NV Indicator
    func indicatorsTypes(i:Int) -> NVActivityIndicatorType {
        return NVActivityIndicatorType.allCases[i]
    }
    
    func startIndicator() {
        let indicatorType = indicatorsTypes(i: type)
        let size = CGSize(width: 50, height: 50)
        self.startAnimating(size, message: "Please wait...", type: indicatorType, fadeInAnimation: nil)
    }
    
    func loginIndicator() {
        let indicatorType = indicatorsTypes(i: type)
        let size = CGSize(width: 50, height: 50)
        self.startAnimating(size, message: "Hold On...", type: .blank, fadeInAnimation: nil)
    }
    
    func stopIndicator(){
        self.stopAnimating()
    }
    
    // MARK: Conert to short date
    // from 2020-03-12 10:12:00 to 2020-03-12
    class func convertDateFormater(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return  dateFormatter.string(from: date ?? Date())
        
    }
    
    // MARK: Conert to short date
    // from 2020-03-12 10:12:00 to 9:30 PM
    class func timeAMPM(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "h:mm a"
        return  dateFormatter.string(from: date ?? Date())
        
    }
    
    // MARK: Conert to short date
    // from 2020-03-12 10:12:00 to Sep 12, 2:11 PM
    class func dateTimeCharcter(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MMM d"
        return  dateFormatter.string(from: date ?? Date())
        
    }
    
    class func invoiceDate(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        return  dateFormatter.string(from: date ?? Date())
        
    }
    
}


// MARK: StoryBoard
extension UIStoryboard {
    
    class func controller<T: UIViewController>() -> T {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: T.className) as! T
    }
}
// MARK: NSObject
extension NSObject {
    class var className: String {
        return String(describing: self.self)
    }
}

// MARK: - NSMutable String Functions
extension NSMutableAttributedString {
    
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "AvenirNext-Bold", size: 17)!,NSAttributedString.Key.foregroundColor:UIColor.white]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        return self
    }
}

// MARK: - UIImageView Extension
extension UIImageView {
    // Download Image from URL asynchronous image downloader
    func downloadImage(imageUrl : String!){
        let encodedString = imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//        print("encoded",encodedString!)
        if URL(string: encodedString!) != nil{
            self.sd_imageIndicator?.startAnimatingIndicator()
            self.sd_setImage(with: URL(string:encodedString!),placeholderImage: #imageLiteral(resourceName: "chef-img"), completed: { (image, err, type,url) in
                
//                print("StringURL is: \(imageUrl)")
//                print("URL is: \(URL(string:encodedString!))")
                
                if err != nil {
                    self.sd_imageIndicator?.stopAnimatingIndicator()
                    print("Failed to download image",err?.localizedDescription as Any)
                }
                self.sd_imageIndicator?.stopAnimatingIndicator()
            })
        }
        
    }
}

let imageCache = NSCache<NSString, UIImage>()
extension UIImageView {

    func urlSessiondownloadImage(_ URLString: String, placeHolder: UIImage?) {

        self.image = nil
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            self.image = cachedImage
            return
        }

        if let url = URL(string: URLString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in

                //print("RESPONSE FROM API: \(response)")
                if error != nil {
                    print("ERROR LOADING IMAGES FROM URL: \(String(describing: error))")
                    DispatchQueue.main.async { [weak self] in
                        self?.image = placeHolder
                    }
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode != 403{
                            DispatchQueue.main.async {
                                if let downloadedImage = UIImage(data: data!) {
                                    imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                                    self?.image = downloadedImage
                                }
                            }
                        }else{
                            print("ErrorUrl StatusCode is: \(httpResponse.statusCode)")
                            return
                        }
                    }
                }
            }).resume()
        }
    }
}

extension String{
    func convertDoubleToCurrency() -> String{
        let amount1 = Double(self)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "en_US")
        return numberFormatter.string(from: NSNumber(value: amount1!))!
    }
    
    func convertDateFormater(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return  dateFormatter.string(from: date!)
        
    }
}

extension Date{
    func convertDateFormater() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return  dateFormatter.string(from: self)
        
    }
}

extension UserDefaults {
    static func contains(_ key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension String {
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

@available(iOS 13.0, *)
var statusBar = UIView(frame: UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
extension Utils{
    func setStatusBarColor(offset: Float){
        if offset == 1{
            if #available(iOS 13.0, *) {
                if UITraitCollection.current.userInterfaceStyle == .light {
                    UIApplication.shared.setStatusBarStyle(.darkContent, animated: true)
                } else {
                    UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
                }
            } else {
                // Fallback on earlier versions
            }
        }else{
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        }
        
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .light {
                statusBar.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: CGFloat(offset))
            } else {
                statusBar.backgroundColor = UIColor(red: 00.0/255.0, green: 00.0/255.0, blue: 00.0/255.0, alpha: CGFloat(offset))
            }
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        }else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: CGFloat(offset))
        }
    }
}

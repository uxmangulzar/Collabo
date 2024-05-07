//
//  AddNewSongVC.swift
//  Collabo
//
//  Created by Tabish on 12/2/20.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import MediaPlayer

class AddNewSongVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MPMediaPickerControllerDelegate, UIGestureRecognizerDelegate, NVActivityIndicatorViewable, serverResponse {
    
    @IBOutlet weak var fileUploadStatusVu: UIView!
    
    @IBOutlet weak var uploadProgressLbl: UILabel!
    
    var image: UIImage?
    
    var imageName: String?
    
    @IBOutlet weak var crossBarBtn: UIBarButtonItem!
    @IBOutlet weak var tickBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var songNameTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var linkTF: UITextField!
    
    @IBOutlet weak var imageUploadBtn: UIButton!
    @IBOutlet weak var fileUploadBtn: UIButton!
    
    var songData: Data?
    
    let songFileName: String = NSUUID().uuidString + ".mp3"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        crossBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        tickBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        
        setPlaceholderColor()
        
        testFileToUploadToServer()
    }
    
    func testFileToUploadToServer(){
        let resourceUrl = URL(fileURLWithPath: Bundle.main.resourcePath!)
        
        do
        {
            let directories = try FileManager.default.contentsOfDirectory(
                at: resourceUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)   //contentsOfDirectory() returns [URL]
            for directory in directories
            {
                var address = directory.absoluteString
                
                if address.contains(".mp3")
                {
                    print("address is: \(address)\n")
                    
                    do {
                        self.songData = try Data(contentsOf: directory as URL)
                        print("songData is: \n\(songData)")
                    } catch {
                        print("Unable to load data: \(error)")
                    }
                }
            }
        }
        catch let err
        {
            print(err.localizedDescription)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func tappedCrossBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedTickBtn(_ sender: Any) {
        if songNameTF.text != "" && descriptionTF.text != "" && linkTF.text != "" && imageName != nil && songFileName != nil{
            if CheckInternet.Connection(){
                Utils.sharedInstance.startIndicator()
                
                let imgUrl = BaseUrls.baseUrl + "UPLOAD_FILE.php"
                let imgParams: [String: String] = ["type":"song_image",
                                                   "file":imageName!]
                serverRequest.foamData(url: imgUrl, params: imgParams, image: image, imageKey: "file", imageName: imageName!, type: "upload_profile_image")
                
                let songFileParams: [String: String] = ["type":"song_file",
                                                        "file":songFileName]
                
                Alamofire.upload(multipartFormData: { multipartFormData in
                    if self.songData != nil {
                        multipartFormData.append(self.songData!, withName: "file",fileName: self.songFileName, mimeType: "audio/m4a")
                    }
                    for (key, value) in songFileParams {
                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                    } //Optional for extra parameters
                },
                                 to:imgUrl,method: .post)
                { (result) in
                    switch result {
                    case .success(let upload, _, _):
                        
                        upload.uploadProgress(closure: { (progress) in
                            print("Upload Progress: \(progress.fractionCompleted)")
                            DispatchQueue.main.async { [self] in
                                fileUploadStatusVu.isHidden = false
                                view.isUserInteractionEnabled = false
                                let roundFigure = round((progress.fractionCompleted * 100)/1.0)
                                uploadProgressLbl.text = String(Int(roundFigure)) + "%"
                            }
                        })
                        
                        upload.responseJSON { [self] response in
                            if response.result.isSuccess{
                                view.isUserInteractionEnabled = true
                                let json = response.result.value as? [String: Any]
                                let status = json?["status"] as? String
                                if status == "200"{
                                    fileUploadStatusVu.isHidden = true
                                    let alertView = UIAlertController(title: "Song Added!", message: "Song Uploaded Successfully.", preferredStyle: .alert)
                                    
                                    let alertAction = UIAlertAction(title: "Okay", style: .cancel) { (alert) in
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                    alertView.addAction(alertAction)
                                    self.present(alertView, animated: true, completion: nil)
                                }else{
                                    let message = json?["message"] as? String
                                    Alert.showAlert(on: self, with: "Upload Failed!", message: message ?? "")
                                }
                            }else{
                                view.isUserInteractionEnabled = true
                                Utils.sharedInstance.stopIndicator()
                                print(response.error!.localizedDescription)
                            }
                            
                        }
                        
                    case .failure(let encodingError):
                        Utils.sharedInstance.stopIndicator()
                        print(encodingError)
                    }
                }
                
                let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
                let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
                
                let url = BaseUrls.baseUrl + "ADD_SONG.php"
                let headers: [String:String] = [
                "Authorization": jwt
                ]
                
                let params : [String: Any] = [ "user_id":userId,
                                               "song_title":songNameTF.text!,
                                               "song_description":descriptionTF.text!,
                                               "song_link":linkTF.text!,
                                               "file":["file":imageName!],
                                               "attachment":["file": songFileName]]
                
                print("params are: \(params)")
                
                serverRequest.delegate = self
                serverRequest.postRequestWithRawData(url: url, header: headers, params: params, type: "")
            }else{
                Alert.showInternetFailureAlert(on: self)
            }
        }else{
            Alert.showAlert(on: self, with: "Fields Required!", message: "All Fields are required.")
        }
    }
    
    func onResponse(json: [String : Any], val: String) {
        if val == ""{
            let status = json["status"] as? String
            if status == "200"{
            }else{
                let message = json["message"] as? String
                Alert.showAlert(on: self, with: "Failed!", message: message ?? "")
            }
        }else if val == "upload_profile_image"{
            let status = json["status"] as? String
            if status == "200"{
                print("Profile Image Uploaded Successfully.")
            }
        }
        Utils.sharedInstance.stopIndicator()
    }
    
    @IBAction func tappedUploadImage(_ sender: Any) {
        let imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imageController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let profileImage = info[.originalImage] as? UIImage else { return }
        
        guard let fileUrl = info[.imageURL] as? URL else { return }
        imageName = fileUrl.lastPathComponent
        imageUploadBtn.setTitle(imageName, for: .normal)
        
        self.image = profileImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedUploadFile(_ sender: Any) {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        present(mediaPicker, animated: true, completion: nil)
    }
    
    //When the user has finished picking media from library.
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {

       //User selected a/an item(s).
       for mpMediaItem in mediaItemCollection.items {
         print("Add \(mpMediaItem) to a playlist, prep the player, etc.")
        
            if let assetURL = mpMediaItem.assetURL {
                export(assetURL) { [self] fileURL, error in
                    guard let fileURL = fileURL, error == nil else {
                        print("export failed: \(error)")
                        return
                    }

                    // use fileURL of temporary file here
                    print("\(fileURL)")
                    do {
                        self.songData = try Data(contentsOf: fileURL as URL)
                        print("songData is: \n\(songData)")
                    } catch {
                        print("Unable to load data: \(error)")
                    }
                }
            }
       }
    }

    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
       print("User selected Cancel tell me what to do")
    }
}

extension AddNewSongVC{
    
    func export(_ assetURL: URL, completionHandler: @escaping (_ fileURL: URL?, _ error: Error?) -> ()) {
        let asset = AVURLAsset(url: assetURL)
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            completionHandler(nil, ExportError.unableToCreateExporter)
            return
        }

        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(NSUUID().uuidString)
            .appendingPathExtension("m4a")

        exporter.outputURL = fileURL
        exporter.outputFileType = AVFileType(rawValue: "com.apple.m4a-audio")

        exporter.exportAsynchronously {
            if exporter.status == .completed {
                completionHandler(fileURL, nil)
            } else {
                completionHandler(nil, exporter.error)
            }
        }
    }
    
    enum ExportError: Error {
        case unableToCreateExporter
    }
}

extension AddNewSongVC{
    func setPlaceholderColor(){
        songNameTF.attributedPlaceholder = NSAttributedString(string: "Add Name of the New Song",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        descriptionTF.attributedPlaceholder = NSAttributedString(string: "Description",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        linkTF.attributedPlaceholder = NSAttributedString(string: "link",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}

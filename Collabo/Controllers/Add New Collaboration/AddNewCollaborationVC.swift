//
//  AddNewCollaborationVC.swift
//  Collabo
//
//  Created by Tabish on 12/2/20.
//

import UIKit
import Alamofire
import MediaPlayer
import ActionSheetPicker_3_0
import MobileCoreServices

class AddNewCollaborationVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MPMediaPickerControllerDelegate,UIDocumentPickerDelegate, serverResponse
{
    
    @IBOutlet weak var fileUploadStatusVu: UIView!
    
    @IBOutlet weak var uploadProgressLbl: UILabel!
    
    @IBOutlet weak var crossBarBtn: UIBarButtonItem!
    @IBOutlet weak var tickBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var collaborationImg: UIImageView!
    
    var imageName: String?
    
    @IBOutlet weak var titleBackVu: UIView!
    @IBOutlet weak var descBackVu: UIView!
    @IBOutlet weak var genreBackVu: UIView!
    @IBOutlet weak var availabilityBackVu: UIView!
    @IBOutlet weak var artistName1BackVu: UIView!
    @IBOutlet weak var artistName2BackVu: UIView!
    @IBOutlet weak var artistName3BackVu: UIView!
    
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descTF: UITextField!
    @IBOutlet weak var availabilityTF: UITextField!
    
    @IBOutlet weak var genreBtn: UIButton!
    @IBOutlet weak var artist1Btn: UIButton!
    @IBOutlet weak var artist2Btn: UIButton!
    @IBOutlet weak var artist3Btn: UIButton!
    
    var genreArr = [String]()
    
    //For storing action sheet picker option
    var genreSelection: String!
    var selectedGenreId: String?
    
    var genreModel = [GenreModel]()
    
    var artistsModel = [ArtistsModel]()
    var artistArr = [String]()
    var artist1Id: String?
    var artist2Id: String?
    var artist3Id: String?
    
    var songData: Data?
    
    let songFileName: String = NSUUID().uuidString + ".mp3"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        crossBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        tickBarBtn.tintColor = UIColor(red: 237.0/255.0, green: 87.0/255.0, blue: 88.0/255.0, alpha: 1)
        
        setPlaceholderColor()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedSelectCollaborationImage))
        collaborationImg.isUserInteractionEnabled = true
        collaborationImg.addGestureRecognizer(tapGesture)
        
        testFileToUploadToServer()
        getAllGenre()
        getAllArtists(sortBy: "")
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
    
    func getAllGenre(){
        if CheckInternet.Connection(){
            Utils.sharedInstance.startIndicator()
            
            let url = BaseUrls.baseUrl + "GET_ALL_GENRE.php"
            
            let params : [String: Any] = [ "limit": "100",
                                            "page": "1"]
            
            print("params are: \(params)")
            
            serverRequest.delegate = self
            serverRequest.postRequestWithRawData(url: url, header: [:], params: params, type: "get_genres")
        }else{
            Alert.showInternetFailureAlert(on: self)
        }
    }
    
    func getAllArtists(sortBy: String){
        if CheckInternet.Connection(){
            Utils.sharedInstance.startIndicator()
            let userId:String = UserDefaults.standard.string(forKey: UserDefaultKey.userId)!
            let jwt:String = UserDefaults.standard.string(forKey: UserDefaultKey.jwt)!
            
            let url = BaseUrls.baseUrl + "GET_ALL_USERS_LIST.php"
            let headers: [String:String] = [
            "Authorization": jwt
            ]
            let params : [String: Any] = [  "user_id": userId,
                                            "sort_by":sortBy,
                                            "limit": "100",
                                            "page": "1"]
            
            print("params are: \(params)")
            
            serverRequest.delegate = self
            serverRequest.postRequestWithRawData(url: url, header: headers, params: params, type: "get_artists")
        }else{
            Alert.showInternetFailureAlert(on: self)
        }
    }
    
    func onResponse(json: [String : Any], val: String) {
        if val == "get_genres"{
            let error = json["error"] as? Bool
            if error == false{
                genreModel.removeAll()
                let allGenre = json["genre_result"] as! [[String: Any]]
                for singleGenre in allGenre {
                    genreModel.append(GenreModel(json: singleGenre))
                    genreArr.append(singleGenre["genre_name"] as? String ?? "")
                }
            }else{
                Alert.showAlert(on: self, with: "Error!", message: "Something went wrong try later.")
            }
        }else if val == "get_artists"{
            let error = json["error"] as? Bool
            if error == false{
                artistsModel.removeAll()
                let userList = json["users_list"] as! [[String: Any]]
                for singleUser in userList {
                    artistsModel.append(ArtistsModel(json: singleUser))
                    artistArr.append(singleUser["user_name"] as? String ?? "")
                }
            }else{
                Alert.showAlert(on: self, with: "Error!", message: "Something went wrong try later.")
            }
        }else if val == "add_collaboration"{
            let status = json["status"] as? String
            if status == "200"{
                print("Collaboration Added Successfully.")
            }else{
                let message = json["message"] as? String
                Alert.showAlert(on: self, with: "Failed!", message: message ?? "")
            }
        }else if val == "upload_collaboration_image"{
            let status = json["status"] as? String
            if status == "200"{
                print("Collaboration Image Uploaded Successfully.")
            }
        }
        Utils.sharedInstance.stopIndicator()
    }
    
    @IBAction func tapGenreBtn(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "", rows: genreArr, initialSelection: 0, doneBlock: { [self]
                       picker, indexe, value in

                       print("value = \(value)")
                       print("indexe = \(indexe)")
                       print("picker = \(picker)")
            
            selectedGenreId = genreModel[indexe].genreId
            genreSelection = value as? String
            
            genreBtn.setTitle(genreSelection, for: .normal)
            genreBtn.setTitleColor(UIColor.black, for: .normal)
                       return
               }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    @IBAction func tapArtist1Btn(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "", rows: artistArr, initialSelection: 0, doneBlock: { [self]
                       picker, indexe, value in

                       print("value = \(value)")
                       print("indexe = \(indexe)")
                       print("picker = \(picker)")
            
            artist1Id = artistsModel[indexe].userId
            let artistName = value as? String
            
            artist1Btn.setTitle(artistName, for: .normal)
            artist1Btn.setTitleColor(UIColor.black, for: .normal)
                       return
               }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    @IBAction func tapArtist2Btn(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "", rows: artistArr, initialSelection: 0, doneBlock: { [self]
                       picker, indexe, value in

                       print("value = \(value)")
                       print("indexe = \(indexe)")
                       print("picker = \(picker)")
            
            artist2Id = artistsModel[indexe].userId
            let artistName = value as? String
            
            artist2Btn.setTitle(artistName, for: .normal)
            artist2Btn.setTitleColor(UIColor.black, for: .normal)
                       return
               }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    @IBAction func tapArtist3Btn(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "", rows: artistArr, initialSelection: 0, doneBlock: { [self]
                       picker, indexe, value in

                       print("value = \(value)")
                       print("indexe = \(indexe)")
                       print("picker = \(picker)")
            
            artist3Id = artistsModel[indexe].userId
            let artistName = value as? String
            
            artist3Btn.setTitle(artistName, for: .normal)
            artist3Btn.setTitleColor(UIColor.black, for: .normal)
                       return
               }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    @objc func tappedSelectCollaborationImage() {
        let imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imageController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let profileImage = info[.originalImage] as? UIImage else { return }
        
        guard let fileUrl = info[.imageURL] as? URL else { return }
        imageName = fileUrl.lastPathComponent
        
        self.collaborationImg.image = profileImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedBrowseBtn(_ sender: Any) {
//        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
//        importMenu.delegate = self
//        importMenu.modalPresentationStyle = .formSheet
//        self.present(importMenu, animated: true, completion: nil)
        
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
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        print("import result : \(myURL)")
    }
    
    @IBAction func tappedCrossBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedTickBtn(_ sender: Any) {
        if titleTF.text != "" && descTF.text != "" && availabilityTF.text != "" && imageName != nil && songFileName != nil && genreSelection != nil && artist1Id != nil && artist2Id != nil && artist3Id != nil{
            if CheckInternet.Connection(){
                Utils.sharedInstance.startIndicator()
                
                let imgUrl = BaseUrls.baseUrl + "UPLOAD_FILE.php"
                let imgParams: [String: String] = ["type":"song_image",
                                                   "file":imageName!]
                serverRequest.foamData(url: imgUrl, params: imgParams, image: collaborationImg.image, imageKey: "file", imageName: imageName!, type: "upload_collaboration_image")
                
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
                                    let alertView = UIAlertController(title: "Collaboration Added!", message: "Song Uploaded Successfully.", preferredStyle: .alert)
                                    
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
                
                let url = BaseUrls.baseUrl + "ADD_NEW_COLLABORATION.php"
                let headers: [String:String] = [
                "Authorization": jwt
                ]
                
                let params : [String: Any] = [ "user_id":userId,
                                               "project_title":titleTF.text!,
                                               "project_description":descTF.text!,
                                               "genre":selectedGenreId!,
                                               "artist_name_1":artist1Id!,
                                               "artist_name_2":artist2Id!,
                                               "artist_name_3":artist3Id!,
                                               "file":["file":imageName!],
                                               "attachment":["file":songFileName]]
                
                print("params are: \(params)")
                
                serverRequest.delegate = self
                serverRequest.postRequestWithRawData(url: url, header: headers, params: params, type: "add_collaboration")
            }else{
                Alert.showInternetFailureAlert(on: self)
            }
        }else{
            Alert.showAlert(on: self, with: "Fields Required!", message: "All Fields are required.")
        }
    }
}

extension AddNewCollaborationVC{
    
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

extension AddNewCollaborationVC{
    func setPlaceholderColor(){
        titleTF.attributedPlaceholder = NSAttributedString(string: "Title",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        descTF.attributedPlaceholder = NSAttributedString(string: "Description",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        availabilityTF.attributedPlaceholder = NSAttributedString(string: "Availability",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
}


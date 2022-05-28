//
//  Addnewplacevc.swift
//  Tourist
//
//  Created by Mohit on 27/05/22.
//

import UIKit
import AVKit
import CoreData

class Addnewplacevc: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SelectMapCoordinates {
    @IBOutlet weak var txtFldName: UITextField!
    @IBOutlet weak var imagVw1: UIImageView!
    @IBOutlet weak var imagVw2: UIImageView!
    @IBOutlet weak var imagVw3: UIImageView!
    @IBOutlet weak var btnLatLng: UIButton!
    
    @IBOutlet weak var imagVwVdo: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var videoUrl: NSURL?
    
    var selectedLat: Double?
    var selectedLng: Double?
    var selectedImageVw: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnImg1Action(_ sender: Any) {
        selectedImageVw = imagVw1
        showImagePicker()
    }
    
    @IBAction func btnImg2Action(_ sender: Any) {
        selectedImageVw = imagVw2
        showImagePicker()
    }
    @IBAction func btnImg3Action(_ sender: Any) {
        selectedImageVw = imagVw3
        showImagePicker()
    }
    
    @IBAction func btnVdoAction(_ sender: Any) {
        selectedImageVw = imagVwVdo
        showVideoPicker()
    }
    
    @IBAction func btnSelectCoordinates(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Mapvc") as! Mapvc
        vc.delelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func selectedCoordinates(lat: Double, lng: Double) {
        self.selectedLat = lat
        self.selectedLng = lng
        let latLng = "\(lat), \(lng)"
        btnLatLng.setTitle(latLng, for: .normal)
    }
    
    @IBAction func btnSubmitaction(_ sender: Any) {
        if txtFldName.text?.count == 0 {
            self.showAlertWithMessage(msg: "Enter name of place")
        } else if imagVw1.image == UIImage(named: "plus") {
            self.showAlertWithMessage(msg: "Select first image")
        } else if imagVw2.image == UIImage(named: "plus") {
            self.showAlertWithMessage(msg: "Select second image")
        } else if imagVw3.image == UIImage(named: "plus") {
            self.showAlertWithMessage(msg: "Select third image")
        } else if imagVwVdo.image == UIImage(named: "plus") {
            self.showAlertWithMessage(msg: "Select video")
        } else if btnLatLng.titleLabel?.text == "Select" {
            self.showAlertWithMessage(msg: "Select map coordinates")
        } else {
            saveDataToLocalDB()
        }
    }
    
    func saveDataToLocalDB() {
        
        let placeID = UUID().uuidString
        let placeName = txtFldName.text!
        let img1 = imagVw1.image!
        let img2 = imagVw2.image!
        let img3 = imagVw3.image!
        let videoThumb = imagVwVdo.image!
        
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
            
        }
        saveVideoFile(withUrl: self.videoUrl!) { pathh in
            self.saveImgToDB(placeID: placeID, placeName: placeName, img1: img1, img2: img2, img3: img3, videoThumb: videoThumb, videoUrl: pathh.absoluteString, lat: self.selectedLat!, lng: self.selectedLng!)
        }
        
    }
    
    func saveImgToDB(placeID: String, placeName: String, img1: UIImage, img2: UIImage, img3: UIImage, videoThumb: UIImage, videoUrl: String, lat: Double, lng: Double) {
      
      guard let imgData1 = img1.jpegData(compressionQuality: 1.0) else { return  }
        guard let imgData2 = img2.jpegData(compressionQuality: 1.0) else { return  }
        guard let imgData3 = img3.jpegData(compressionQuality: 1.0) else { return  }
        guard let videoThumbData = videoThumb.jpegData(compressionQuality: 1.0) else { return  }
        
      
      let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let entity = NSEntityDescription.entity(forEntityName: "PlacesData", in: context)
      let newImgRecord = NSManagedObject(entity: entity!, insertInto: context)
        
        newImgRecord.setValue(placeID, forKey: "placeID")
        newImgRecord.setValue(placeName, forKey: "placeName")
        newImgRecord.setValue(imgData1, forKey: "img1Data")
        newImgRecord.setValue(imgData2, forKey: "img2Data")
        newImgRecord.setValue(imgData3, forKey: "img3Data")
        newImgRecord.setValue(videoThumbData, forKey: "videoThumb")
        newImgRecord.setValue(videoUrl, forKey: "videoPath")
        
        newImgRecord.setValue(lat, forKey: "lat")
        newImgRecord.setValue(lng, forKey: "lng")
        newImgRecord.setValue(false, forKey: "isArchived")
        
      
      do{
        print("Saving")
        try context.save()
        print("Saved")
          activityIndicator.stopAnimating()
          activityIndicator.isHidden = true
          DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
              self.navigationController?.popViewController(animated: true)
          }
      }catch{
        print("saving Failed")
      }
      
      
    }
   
    func showImagePicker() {
        DispatchQueue.main.async {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = false
            picker.mediaTypes = ["public.image"]
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func showVideoPicker() {
        DispatchQueue.main.async {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if selectedImageVw == imagVwVdo {
            let videoURL = info[UIImagePickerController.InfoKey.mediaURL]as? NSURL
                print(videoURL!)
            self.videoUrl = videoURL
                do {
                    let asset = AVURLAsset(url: videoURL! as URL , options: nil)
                    let imgGenerator = AVAssetImageGenerator(asset: asset)
                    imgGenerator.appliesPreferredTrackTransform = true
                    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    imagVwVdo.image = thumbnail
                } catch let error {
                    print("*** Error generating thumbnail: \(error.localizedDescription)")
                }
        } else {
            let img = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            if selectedImageVw == imagVw1 {
                imagVw1.image = img
            } else if selectedImageVw == imagVw2 {
                imagVw2.image = img
            } else if selectedImageVw == imagVw3 {
                imagVw3.image = img
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    
    // download file form local Path
    func saveVideoFile(withUrl videoURL: NSURL, completion: @escaping ((_ filePath: URL)->Void)){
        
        let videoData = NSData(contentsOf: videoURL as URL)
        let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        
        let uniqueName = UUID().uuidString + "video.mp4"
        let newPath = path.appendingPathComponent(uniqueName)
        do {
            try videoData?.write(to: newPath)
            DispatchQueue.main.async {
                completion(newPath)
            }
        } catch {
            print(error)
        }
    }
    
    func showAlertWithMessage(msg: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok", style: .default) { okPressed in
            
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

//
//  ViewPlaceVc.swift
//  Tourist
//
//  Created by Mohit on 27/05/22.
//

import UIKit
import CoreData
import AVKit
import AVFoundation

class ViewPlaceVc: UIViewController {

    @IBOutlet weak var lblPlaceName: UILabel!
    @IBOutlet weak var imagVw1: UIImageView!
    @IBOutlet weak var imagVw2: UIImageView!
    @IBOutlet weak var imagVw3: UIImageView!
    
    @IBOutlet weak var btnLatLng: UIButton!
    
    @IBOutlet weak var imagVwVdo: UIImageView!
    
    var placeData = NSManagedObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        // Do any additional setup after loading the view.
    }
    
    

    func setupData() {
        
        lblPlaceName.text = placeData.value(forKey: "placeName") as? String ?? ""
        
        if let imgData = placeData.value(forKey: "img1Data") as? Data, let img = UIImage(data: imgData) {
            imagVw1.image = img
        }
        if let imgData = placeData.value(forKey: "img2Data") as? Data, let img = UIImage(data: imgData) {
            imagVw2.image = img
        }
        if let imgData = placeData.value(forKey: "img3Data") as? Data, let img = UIImage(data: imgData) {
            imagVw3.image = img
        }
        if let imgData = placeData.value(forKey: "videoThumb") as? Data, let img = UIImage(data: imgData) {
            imagVwVdo.image = img
        }
        if let lat = placeData.value(forKey: "lat") as? Double, let lng = placeData.value(forKey: "lng") as? Double {
            let latLng = "\(lat), \(lng)"
            btnLatLng.setTitle(latLng, for: .normal)
        }
        
    }

    
    @IBAction func btnVdoAction(_ sender: Any) {
        if let videoPath = placeData.value(forKey: "videoPath") as? String {
            playVideo(path: videoPath)
        }
    }
    
    @IBAction func btnImg1Action(_ sender: Any) {
        showImage(img: imagVw1.image!)
    }
    
    @IBAction func btnImg2Action(_ sender: Any) {
        showImage(img: imagVw2.image!)
    }
    
    @IBAction func btnImg3Action(_ sender: Any) {
        showImage(img: imagVw3.image!)
    }
    
    func showImage(img: UIImage) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewImagevc") as! ViewImagevc
        vc.img = img
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func playVideo(path: String) {
        
        var videoPath = ""
         let url = URL(fileURLWithPath: path)
           videoPath = url.lastPathComponent
         
        let newUrl = createNewPath(lastPath: videoPath)
        let player = AVPlayer(url: newUrl)  // video path coming from above function
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func createNewPath(lastPath: String) -> URL {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!

        let destination = URL(fileURLWithPath: String(format: "%@/%@", documentsDirectory,lastPath))
        return destination
      }
    
    @IBAction func btnSelectCoordinates(_ sender: Any) {
        if let lat = placeData.value(forKey: "lat") as? Double, let lng = placeData.value(forKey: "lng") as? Double {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Mapvc") as! Mapvc
            vc.selectedLat = lat
            vc.selectedLng = lng
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    
}

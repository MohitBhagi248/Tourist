//
//  Mapvc.swift
//  Tourist
//
//  Created by Mohit on 27/05/22.
//

import UIKit
import MapKit


protocol SelectMapCoordinates {
    func selectedCoordinates(lat: Double, lng: Double)
}

class Mapvc: UIViewController {
    @IBOutlet weak var mapVw: MKMapView!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    var selectedLat: Double?
    var selectedLng: Double?
    var delelegate: SelectMapCoordinates?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let lat = selectedLat, let lng = selectedLng {
            btnSubmit.isHidden = true
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            mapVw.setCenter(coordinate, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapVw.addAnnotation(annotation)
        } else {
            let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            //gestureRecognizer.delegate = self
            mapVw.addGestureRecognizer(gestureRecognizer)
        }
        
    }
    

    @objc func handleTap(_ gestureReconizer: UILongPressGestureRecognizer) {
        let allAnnotations = self.mapVw.annotations
        self.mapVw.removeAnnotations(allAnnotations)
        
        let location = gestureReconizer.location(in: mapVw)
        let coordinate = mapVw.convert(location,toCoordinateFrom: mapVw)
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        selectedLat = coordinate.latitude
        selectedLng = coordinate.longitude
        mapVw.addAnnotation(annotation)
        
    }
    
    
    @IBAction func btnSubmit(_ sender: Any) {
        if let lat  = selectedLat, let lng = selectedLng, (self.delelegate != nil) {
            self.delelegate!.selectedCoordinates(lat: lat, lng: lng)
            self.navigationController?.popViewController(animated: true)
        }
    }
    

}

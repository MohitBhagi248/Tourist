//
//  ViewImagevc.swift
//  Tourist
//
//  Created by Mohit on 28/05/22.
//

import UIKit

class ViewImagevc: UIViewController {

    @IBOutlet weak var imageVw: UIImageView!
    
    var img = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageVw.image = img
        // Do any additional setup after loading the view.
    }
    

    

}

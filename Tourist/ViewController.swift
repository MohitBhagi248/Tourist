//
//  ViewController.swift
//  Tourist
//
//  Created by Mohit on 27/05/22.
//

import UIKit
import CoreData


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var collectionvw: UICollectionView!
    @IBOutlet weak var lblNoData: UILabel!
    
    
    var listItems = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listItems.removeAll()
        getDataFromDb()
    }

    @IBAction func btnAddAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Addnewplacevc") as! Addnewplacevc
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func segmentValueChange(_ sender: Any) {
        listItems.removeAll()
        self.collectionvw.reloadData()
        getDataFromDb()
    }
    
    func getDataFromDb() {
        var isArchive = false
        if segmentControl.selectedSegmentIndex == 1 {
            isArchive = true
        }
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PlacesData")
      
      do {
        let result = try context.fetch(fetchRequest)
          for item in result {
              let obj = item as! NSManagedObject
              if obj.value(forKey: "isArchived") as? Bool == isArchive {
                  listItems.append(obj)
              }
          }
      } catch {
        print("Fetch failed")
      }
        DispatchQueue.main.async {
            
            self.collectionvw.reloadData()
        }
        if listItems.count == 0 {
            lblNoData.isHidden = false
        } else {
            lblNoData.isHidden = true
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let item = listItems[indexPath.row]
        
        if let imgData = item.value(forKey: "img1Data") as? Data, let placeName = item.value(forKey: "placeName") as? String {
          if let img = UIImage(data: imgData ) {
              let imgVw = cell.viewWithTag(111) as? UIImageView
              let lbl = cell.viewWithTag(112) as? UILabel
              let btnOption = cell.viewWithTag(113) as? UIButton
              btnOption?.addTarget(self, action: #selector(btnOptionAction(_:)), for: .touchUpInside)
              btnOption?.tag = indexPath.item
              imgVw?.image = img
              lbl?.text = placeName
          }
          
        }
        
        return cell
    }
    
    @objc func btnOptionAction(_ sender: UIButton) {
        
        if let index = collectionvw.indexPathForView(view: sender)?.row, index < listItems.count {
            
            let item = listItems[index]
            let placeName = item.value(forKey: "placeName") as? String
            
            let alert = UIAlertController(title: nil, message: "choose option", preferredStyle: .actionSheet)
            var option = "Archive"
            if segmentControl.selectedSegmentIndex == 1 {
                option = "Unarchive"
            }
            let okAction = UIAlertAction(title: option, style: .default) { okPressed in
                if self.segmentControl.selectedSegmentIndex == 1 {
                    self.archiveUnAcrchiveAction(isArchive: false, item: item)
                } else {
                    self.archiveUnAcrchiveAction(isArchive: true, item: item)
                }
                self.listItems.remove(at: index)
                self.collectionvw.reloadData()
                if self.listItems.count == 0 {
                    self.lblNoData.isHidden = false
                } else {
                    self.lblNoData.isHidden = true
                }
            }
            let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func archiveUnAcrchiveAction(isArchive: Bool, item: NSManagedObject) {
        if let placeID = item.value(forKey: "placeID") as? String {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PlacesData")
            let predicate = NSPredicate(format: "placeID = %@", "placeID")
            //fetchRequest.predicate = predicate
            
            do {
                let result = try context.fetch(fetchRequest)
                for person in result {
                    var obj = person as! NSManagedObject
                    if obj.value(forKey: "placeID") as? String == placeID {
                        
                        obj.setValue(isArchive, forKey: "isArchived")
                        try? context.save()
                    }
                    
                }
                debugPrint(result.count)
            } catch {
                print("Fetch failed")
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width / 3) - 10
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = listItems[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewPlaceVc") as! ViewPlaceVc
        vc.placeData = item
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension UICollectionView {
    func indexPathForView(view: AnyObject) -> IndexPath? {
        let originInCollectioView = self.convert(CGPoint.zero, from: (view as! UIView))
        return self.indexPathForItem(at: originInCollectioView) as IndexPath?
      }
}

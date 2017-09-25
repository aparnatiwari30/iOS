//
//  ShopViewController.swift
//  ShoppingApp
//
//  Created by MRV Computers on 9/25/17.
//  Copyright © 2017 AT. All rights reserved.
//

import UIKit
import SDWebImage

class ShopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var productArray = Array<Any>.init()
    @IBOutlet var collectionView:UICollectionView!
    @IBOutlet var loader:UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getProductData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - API
    
    func getProductData() {
        if !APPDELEGATE.isInternetAvailable {
            UIAlertView.init(title: nil, message: "No internet connection.", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        loader.startAnimating()
        APPDELEGATE.performGet(requestStr: Constants.API_GET_DATA,  query: "") { (data) in
            self.loader.stopAnimating()
            if let dataDict = data as? Dictionary<String, Array<Any>> {
                
                print("Data => \(dataDict)")
                self.productArray = dataDict["products"]!
                if self.productArray.count > 0 {
                    self.collectionView.reloadData()
                } else {
                    UIAlertView.init(title: nil, message: "No Item in this list.", delegate: self, cancelButtonTitle: "OK").show()
                }
                
            } else {
                UIAlertView.init(title: nil, message: "Oops! Something went wrong.", delegate: self, cancelButtonTitle: "OK").show()
            }
        }
        
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - collection view delegate and datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "product_cell", for: indexPath) as! ProductCVCell
        let productDetail = productArray[indexPath.row] as! Dictionary<String, Any>
        cell.nameLb.text = productDetail["productname"] as? String
        cell.priceLb.text = "Price: \(productDetail["price"] as! String)"
        cell.vendorNameLb.text = productDetail["vendorname"] as? String
        cell.vendorAddressLb.text = productDetail["vendoraddress"] as? String
        
        let imgURL = productDetail["productImg"] as? String
        cell.productImgView.sd_setImage(with: URL.init(string: imgURL!), placeholderImage: UIImage.init(named: "default"))
        cell.AddToCartBtn.tag = indexPath.row
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (self.view.frame.width/2) - 15
        let h:CGFloat = 250.0
        return CGSize(width: w, height: h)
    }
    
}

extension CALayer {
    var borderUIColor : UIColor {
        get {
            return UIColor.init(cgColor: self.borderColor!)
        }
        set {
            self.borderColor = newValue.cgColor
        }
    }
    
    var shadowUIColor : UIColor {
        get {
            return UIColor.init(cgColor: self.shadowColor!)
        }
        set {
            self.shadowColor = newValue.cgColor
        }
    }
    
}

class ProductCVCell: UICollectionViewCell {
    @IBOutlet var nameLb:UILabel!
    @IBOutlet var productImgView:UIImageView!
    @IBOutlet var priceLb:UILabel!
    @IBOutlet var vendorNameLb:UILabel!
    @IBOutlet var vendorAddressLb:UILabel!
    @IBOutlet var AddToCartBtn:UIButton!
    
}

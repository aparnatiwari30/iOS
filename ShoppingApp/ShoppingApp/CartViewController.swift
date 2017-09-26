//
//  CartViewController.swift
//  ShoppingApp
//
//  Created by Aparna Tiwari on 9/25/17.
//  Copyright © 2017 AT. All rights reserved.
//

import UIKit

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var productArray = Array<Any>.init()
    @IBOutlet var tableView:UITableView!
    var totalPrice = ""
    @IBOutlet var emptyCartLb:UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getProductForCartFromDB()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getProductForCartFromDB() {
        let (productList, total) = DBHelperClass.getAllProductInCart()
        productArray = productList
        if productArray.count > 0 {
            emptyCartLb.isHidden = true
            tableView.isHidden = false
            totalPrice = "Total price : \(total)"
            tableView.reloadData()
        } else {
            tableView.isHidden = true
            emptyCartLb.isHidden = false
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
    
    // MARK: - TableView DataSource and delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return productArray.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Rider
        let cell = tableView.dequeueReusableCell(withIdentifier: "product_cell", for: indexPath) as! CartProductTVCell
        let productDetail = productArray[indexPath.row] as! Dictionary<String, Any>
        if let productname = productDetail["productname"] as? String {
            cell.nameLb.text = productname
        }
        if let price = productDetail["price"] as? String {
            cell.priceLb.text = "Price: \(price)"
        }
        if let vendorname = productDetail["vendorname"] as? String {
            cell.vendorNameLb.text = vendorname
        }
        
        if let vendoraddress = productDetail["vendoraddress"] as? String {
            cell.vendorAddressLb.text = vendoraddress
        }
        
        if let imgURL = productDetail["productImg"] as? String {
            cell.productImgView.sd_setImage(with: URL.init(string: imgURL), placeholderImage: UIImage.init(named: "default"))
        }
        cell.removeFromCartBtn.tag = indexPath.row
        cell.callVender.tag = indexPath.row
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.width, height: 40))
        let totalPriceLb = UILabel.init(frame: CGRect.init(x: 0, y: 10, width: self.tableView.frame.width, height: 40))
        totalPriceLb.backgroundColor = GeneralMethodsClass.colorFromHex("FFFFCF")
        totalPriceLb.text = totalPrice
        totalPriceLb.textAlignment = .center
        view.addSubview(totalPriceLb)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    //MARK: - Actions
    
    @IBAction func removeFromCart(_ sender: Any) {
        
        let alertController = UIAlertController(title: nil, message: "Are you sure, you want to remove this item ?", preferredStyle: UIAlertControllerStyle.alert)
        let DestructiveAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default)
        let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            let btn = sender as! UIButton
            let productDetail = self.productArray[(btn.tag)]  as! Dictionary<String, Any>
            let name = productDetail["productname"] as! String
            
            let msgStr = DBHelperClass.removeFromCart(productName: name)
            print(msgStr)
            self.getProductForCartFromDB()
        }
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
        
        
    }
    
    @IBAction func callVender(_ sender: Any) {
        let btn = sender as! UIButton
        let productDetail = productArray[(btn.tag)]  as! Dictionary<String, Any>
        let phoneNumber = productDetail["phoneNumber"] as! String
        callOnNumber(phoneNumber)
    }
    
    func callOnNumber(_ number:String) {
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }


}

class CartProductTVCell: UITableViewCell {
    @IBOutlet var nameLb:UILabel!
    @IBOutlet var productImgView:UIImageView!
    @IBOutlet var priceLb:UILabel!
    @IBOutlet var vendorNameLb:UILabel!
    @IBOutlet var vendorAddressLb:UILabel!
    @IBOutlet var removeFromCartBtn:UIButton!
    @IBOutlet var callVender:UIButton!
    
}

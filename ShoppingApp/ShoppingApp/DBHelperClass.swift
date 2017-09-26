//
//  DBHelperClass.swift
//  ShoppingApp
//
//  Created by Aparna Tiwari on 9/26/17.
//  Copyright © 2017 AT. All rights reserved.
//

import UIKit
import FMDB

class DBHelperClass: NSObject {
    
    static func Check_null_values(value:Any!) -> Bool {
        if value is NSNull {
            return true
        }
        if value == nil {
            return true
        }
        if (value as! String) == "(null)" || (value as! String) == "<null>"  || (value as! String) == "" {
            return true
        }
        return false
    }
    
    static func getDBPath() -> FMDatabaseQueue {
        let pathForDB = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = pathForDB [0]
        let finalPath = documentsDirectory.appending("/ShoppingApp.sqlite")
        print("Database Path : \(finalPath)")
        let DBHandleQueue: FMDatabaseQueue = FMDatabaseQueue(path: finalPath)
        return DBHandleQueue
    }
    
    static func copyDataBaseFile() {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths [0]
        let writableDBPath = documentsDirectory.appending("/ShoppingApp.sqlite")
        let success = fileManager.fileExists(atPath: writableDBPath)
        if success {return}
        // The writable database does not exist, so copy the default to the appropriate location.
        let defaultDBPath = Bundle.main.resourcePath?.appending("/ShoppingApp.sqlite")
        do {
            try fileManager.copyItem(atPath: defaultDBPath!, toPath: writableDBPath)
        } catch {
            assert(false, "Failed to create writable database file.")
        }
        
    }
    
    /*
     CREATE TABLE `tbl_product_mst` (
     `product_id`	INTEGER PRIMARY KEY AUTOINCREMENT,
     `name`	TEXT,
     `image_url`	TEXT,
     `price`	TEXT,
     `vendor_name`	TEXT,
     `vendor_address`	TEXT,
     `phone_number`	TEXT
     );
     */
    static func insertRecords2ProductTable(productDetail:Dictionary<String, Any>) -> String {
        let DBHandleQueue = getDBPath()
        var returnMsg = ""
        DBHandleQueue.inDatabase { (db) in
            db.open()
            var flag = false
            //Considering product name unique
            let ExistingProduct = getAllExistingProductName()
            
            db.beginTransaction()
            let query = "Insert into tbl_product_mst (name,image_url,price,vendor_name,vendor_address,phone_number) VALUES(:name,:image_url,:price,:vendor_name,:vendor_address,:phone_number)"
            
            if ExistingProduct.count > 0 {
                let name = productDetail["name"]
                if !ExistingProduct.contains(name!) {
                    flag = (db.executeUpdate(query, withParameterDictionary: productDetail))
                } else {
                    flag = true
                    returnMsg = "This item already in your cart."
                }
            } else {
                flag = (db.executeUpdate(query, withParameterDictionary: productDetail))
            }
            
            if(flag) {
                print("SuccessFully inserted in tbl_product_mst");
                if returnMsg == "" {
                    returnMsg = "This item added in your cart."
                }
            } else {
                print("fail to insert in tbl_product_mst");
                print("[db lastErrorMessage], [db lastError] : \(String(describing: db.lastErrorMessage())) \n  \(String(describing: db.lastError()))" );
                returnMsg = "Oops! Something went wrong."
            }
            db.commit()
            db.close()
        }
        return returnMsg
    }
    
    static func getAllExistingProductName() -> NSArray {
        let returnArr:NSMutableArray = NSMutableArray.init()
        let DBHandleQueue = getDBPath()
        DBHandleQueue.inDatabase { (db) in
            db.open()
            db.beginTransaction()
            let query = "select name from tbl_product_mst"
            
            do {
                let results = try (db.executeQuery(query, values: nil)) as FMResultSet
                while (results.next()) {
                    let name = results.string(forColumn: "name")
                    returnArr.add(name!)
                }
            }
            catch {
                print(error.localizedDescription)
            }
            
            db.commit()
            db.close()
        }
        return returnArr
    }
    
    static func getAllProductInCart() -> (Array<Any>, String) {
        
        var returnArray = Array<Any>.init()
        var totalPrice = 0
        let DBHandleQueue = getDBPath()
        DBHandleQueue.inDatabase { (db) in
            db.open()
            db.beginTransaction()
            let query = "select * from tbl_product_mst"
            
            do {
                let results = try (db.executeQuery(query, values: nil)) as FMResultSet
                while (results.next()) {
                    
                    var name = ""
                    if !Check_null_values(value: results.string(forColumn: "name")) {
                        name = results.string(forColumn: "name")!
                    }
                    var price = ""
                    if !Check_null_values(value: results.string(forColumn: "price")) {
                        price = results.string(forColumn: "price")!
                    }
                    var image_url = ""
                    if !Check_null_values(value: results.string(forColumn: "image_url")) {
                        image_url = results.string(forColumn: "image_url")!
                    }
                    
                    var vendor_name = ""
                    if !Check_null_values(value: results.string(forColumn: "vendor_name")) {
                        vendor_name = results.string(forColumn: "vendor_name")!
                    }
                    
                    var vendor_address = ""
                    if !Check_null_values(value: results.string(forColumn: "vendor_address")) {
                        vendor_address = results.string(forColumn: "vendor_address")!
                    }
                    
                    var phone_number = ""
                    if !Check_null_values(value: results.string(forColumn: "phone_number")) {
                        phone_number = results.string(forColumn: "phone_number")!
                    }
                    
                    let dict = ["productname":name, "price":price, "productImg":image_url, "vendorname":vendor_name, "vendoraddress":vendor_address, "phoneNumber":phone_number]
                    returnArray.append(dict)
                    totalPrice += Int(price)!
                }
            }
            catch {
                print(error.localizedDescription)
            }
            
            db.commit()
            db.close()
        }
        return (returnArray, String(totalPrice))
    }
    
    static func removeFromCart(productName: String) -> String {
        let DBHandleQueue = getDBPath()
        var returnMsg = ""
        DBHandleQueue.inDatabase { (db) in
            db.open()
            var flag = false
            db.beginTransaction()
            let query = "delete from tbl_product_mst where name='\(productName)'"
            
            flag = db.executeStatements(query)
            
            if(flag) {
                returnMsg = "This item removed from your cart."
            } else {
                print("[db lastErrorMessage], [db lastError] : \(String(describing: db.lastErrorMessage())) \n  \(String(describing: db.lastError()))" );
                returnMsg = "Oops! Something went wrong."
            }
            db.commit()
            db.close()
        }
        return returnMsg
    }


}

//
//  AppDelegate.swift
//  ShoppingApp
//
//  Created by Aparna Tiwari on 9/25/17.
//  Copyright © 2017 AT. All rights reserved.
//

import UIKit
import ReachabilitySwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var session:URLSession!
    let internetReachability:Reachability = Reachability.init(hostname: "www.google.com")!
    var isInternetAvailable = false


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        //Reachability
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: internetReachability)
        do{
            try internetReachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        // Network session
        let sessionConfiguration = URLSessionConfiguration.default
        session = URLSession(configuration: sessionConfiguration)
        

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - reachability
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                isInternetAvailable = true
                print("Reachable via WiFi")
            } else {
                isInternetAvailable = true
                print("Reachable via Cellular")
            }
        } else {
            isInternetAvailable = false
            print("Network not reachable")
        }
    }

    // MARK: - API call
    func performGet(requestStr: String, query:String, completion: @escaping (_ data: Any?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            var urlStr = ""
            if query != "" {
                urlStr = "\(Constants.API_HOST)\(requestStr)?\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            } else {
                urlStr = "\(Constants.API_HOST)\(requestStr)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            }
            let targetURL = URL.init(string: urlStr)
            let request = NSMutableURLRequest(url: targetURL! as URL)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = self.session.dataTask(with: request as URLRequest) { (data, resp, error) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    if (data != nil) {
                        let json = self.convertDataToJsonObject(data!)
                        completion(json)
                    } else {
                        print(error ?? "error")
                        completion(nil)
                    }
                })
                return()
            }
            
            task.resume()
        }
    }
    
    func convertDataToJsonObject(_ data:Data) -> Any! {
        do {
            let data = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            return data
        } catch let error {
            print(error)
            return nil
        }
    }


}

let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate




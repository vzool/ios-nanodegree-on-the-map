//
//  UdacityAPI.swift
//  ParseStarterProject
//
//  Created by Abdelaziz Elrashed on 7/24/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import UIKit

class UdacityAPI{
    
    static internal var AccountKey:String!
    static internal var SessionID:String!
    static internal var FirstName:String!
    static internal var LastName:String!
    static internal var Location:String!
    
    static internal func Login(userName:String, password:String, view:UIViewController){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            // Parse JSON
            var parsingError: NSError? = nil
            let json = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            if let account = json["account"] as? [String: AnyObject]{
                if let key = account["key"] as? String{
                    UdacityAPI.AccountKey = "\(key)"
                    println(key)
                    
                    UdacityAPI.GetUserData(key)
                }
            }
            
            if let session = json["session"] as? [String: AnyObject]{
                if let id = session["id"] as? String{
                    UdacityAPI.SessionID = "\(id)"
                    println(id)
                }
            }
            
            if UdacityAPI.AccountKey == nil || UdacityAPI.SessionID == nil{
                
                if UdacityAPI.AccountKey == nil{
                    dispatch_async(dispatch_get_main_queue()) {
                        (view as? LoginViewController)!.messageLabel.text  = "Login Failed (Account Key)."
                        (view as? LoginViewController)!.showIndicator(false)
                    }
                }
                
                if UdacityAPI.SessionID == nil{
                    dispatch_async(dispatch_get_main_queue()) {
                        (view as? LoginViewController)!.messageLabel.text  = "Login Failed (Session ID)."
                        (view as? LoginViewController)!.showIndicator(false)
                    }
                }
                
            }else{
                
                dispatch_async(dispatch_get_main_queue()) {
                    (view as? LoginViewController)!.showWelcomeMessage()
                }
                
                 NSThread.sleepForTimeInterval(3)
                
                dispatch_async(dispatch_get_main_queue()) {
                    (view as? LoginViewController)!.loginSuccess()
                }
            }
        }
        task.resume()
    }
    
    static internal func GetUserData(userID:String){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(userID)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
//            println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            // Parse JSON
            var parsingError: NSError? = nil
            let json = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            if let user = json["user"] as? [String: AnyObject]{
                
                if let first_name = user["first_name"] as? String{
                    UdacityAPI.FirstName = first_name
                    println(first_name)
                }
                
                if let last_name = user["last_name"] as? String{
                    UdacityAPI.LastName = last_name
                    println(last_name)
                }
                
                if let location = user["location"] as? [String: AnyObject]{
                    if let coordinates = location["coordinates"] as? String{
                        UdacityAPI.Location = coordinates
                        print(coordinates)
                    }
                }
            }
            
        }
        task.resume()
    }
    
    static internal func Logout(view:UIViewController){
        
        dispatch_async(dispatch_get_main_queue()) {
            (view as? MapViewController)!.startNetworkPoint()
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                
                dispatch_async(dispatch_get_main_queue()) {
                    (view as? MapViewController)!.notifyUser(error.description)
                }
                
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            dispatch_async(dispatch_get_main_queue()) {
                (view as? MapViewController)!.LogoutSuccessNetworkPoint()
            }
        }
        task.resume()
    }
    
}

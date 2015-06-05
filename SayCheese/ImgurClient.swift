//
//  ImgurClient.swift
//  SayCheese
//
//  Created by Arasthel on 16/06/14.
//  Copyright (c) 2014 Jorge Martín Espinosa. All rights reserved.
//

import Foundation

class ImgurClient: NSObject, IMGSessionDelegate, NSUserNotificationCenterDelegate {
    
    var doIfAuthenticated: (() -> Void!)?
    
    var isLoggedIn = false
    
    let imgurClientId = "b15bb6d7d24579c"
    let imgurClientSecret = "e7d9190b1230488ec63051117b412779f1fd6dcc"
    
    var authenticationDoneDelegate: ReceivedImgurAuthenticationDelegate?
    
    var uploadDelegate: UploadDelegate?
    
    var imgurSession: IMGSession?
    
    var deleteParam: String?
    var wasScreenshotUploadedWithAccount: Bool?
    
    override init() {
        super.init()
        imgurSession = IMGSession.authenticatedSessionWithClientID(imgurClientId, secret: imgurClientSecret, authType: IMGAuthType.PinAuth, withDelegate: self)
    }
    
    init(uploadDelegate: UploadDelegate) {
        super.init()
        imgurSession = IMGSession.authenticatedSessionWithClientID(imgurClientId, secret: imgurClientSecret, authType: IMGAuthType.PinAuth, withDelegate: self)
        self.uploadDelegate = uploadDelegate
    }

    func hasAccount() -> Bool! {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("imgur_token") != nil {
            return true
        } else {
            return false
        }
    }
    
    func authenticate(withToken: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("imgur_token") != nil {
            let code = defaults.objectForKey("imgur_token") as! String
            NSLog("Requests: \(imgurSession!.creditsClientRemaining)")
            imgurSession!.authenticateWithRefreshToken(code)
            NSLog("Autenticando con token: \(code)")
        } else {
            imgurSession!.authenticate()
        }
    }
    
    func imgurSessionNeedsExternalWebview(url: NSURL, completion: () -> Void) {
        NSWorkspace.sharedWorkspace().openURL(url)
        if (authenticationDoneDelegate != nil) {
            authenticationDoneDelegate!.activatePinButton()
        }
    }
    
    func imgurRequestFailed(error: NSError?) {
        NSLog("Error")
    }
    
    func imgurSessionAuthStateChanged(state: IMGAuthState) {
        NSLog("State: \(state.rawValue)")
        let defaults = NSUserDefaults.standardUserDefaults()

        if state == IMGAuthState.Authenticated {
            defaults.setObject(imgurSession!.refreshToken as NSString, forKey: "imgur_token")
            defaults.synchronize()
            if (authenticationDoneDelegate != nil) {
                authenticationDoneDelegate!.authenticationInImgurSuccessful()
            }
            isLoggedIn = true
        } else if state == IMGAuthState.Expired {
            defaults.removeObjectForKey("imgur_token")
            defaults.synchronize()
        }
    }
    
    func imgurSessionTokenRefreshed() {
        // If we need to upload anything, do it
        if (doIfAuthenticated != nil) {
            doIfAuthenticated!()
            doIfAuthenticated = nil
        }
        isLoggedIn = true
    }
    
    func isAccessTokenValid() -> Bool! {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
        
        if imgurSession != nil {
            if imgurSession!.accessTokenExpiry != nil {
                if imgurSession!.accessTokenExpiry!.compare(NSDate()) == NSComparisonResult.OrderedDescending {
                    // Token valid
                    isLoggedIn = true
                    
                    println("LoggedIn")
                    
                    return true
                } else {
                    // Token expired
                    isLoggedIn = false
                    
                    println("Not logged in")
                    
                    return false
                }

            } else {
                println("AccesTokenExpiry was nil")
            }
        } else {
            println("imgursession was nil")
        }
        return false
    }
    
    func uploadImage(let image: NSImage) {
        
        let imageUploadedCallback = { (uploadedImage: IMGImage?) -> Void in
            self.notifyImageUploaded(uploadedImage!.url.absoluteString!, param: uploadedImage!.deletehash)
            self.wasScreenshotUploadedWithAccount = self.hasAccount()
        }
        
        var uploadIfOk = { () -> Void in
            self.uploadDelegate?.uploadStarted()
            let date = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
            var imageData = image.TIFFRepresentation;
            let imageRepresentation = NSBitmapImageRep(data: imageData!);
            let imageProps = [ NSImageCompressionFactor: 1.0 ];
            imageData = imageRepresentation!.representationUsingType(NSBitmapImageFileType.NSJPEGFileType, properties: imageProps);
            IMGImageRequest.uploadImageWithData(imageData, title: "Screenshot - \(formatter.stringFromDate(date))", success: imageUploadedCallback, progress: nil, failure: nil)
        }
        
        if !hasAccount() {
            wasScreenshotUploadedWithAccount = false
            anonymouslyUploadImage(image)
        } else {
            wasScreenshotUploadedWithAccount = true
            if isAccessTokenValid() == true {
                uploadIfOk()
            } else {
                doIfAuthenticated = { (uploadIfOk)($0) }
                imgurSession!.authenticate()
            }
            
        }
    }
    
    func notifyImageUploaded(url: String, param: String) {
        // Save url in pasteboard
        let pasteboard = NSPasteboard.generalPasteboard()
        let types = [NSStringPboardType]
        pasteboard.declareTypes(types, owner: nil)
        pasteboard.setString(url, forType: NSStringPboardType)
        
        self.deleteParam = param
        uploadDelegate?.uploadFinished()
        
        // Send notification
        dispatch_async(dispatch_get_main_queue(), {
            let notification = NSUserNotification()
            notification.title = "Image uploaded to imgur!"
            notification.userInfo = ["url": url]
            notification.informativeText = "The url is on your clipboard. Click to open it in a web browser."
            notification.soundName = NSUserNotificationDefaultSoundName
            let center = NSUserNotificationCenter.defaultUserNotificationCenter()
            center.delegate = self
            center.deliverNotification(notification)
        })
    }
    
    func notifyImageNotUploaded(errorCode: Int){
        dispatch_async(dispatch_get_main_queue(), {
            let notification = NSUserNotification()
            notification.title = "Error while uploading image"
            notification.informativeText = "Error code: \(errorCode)"
            let center = NSUserNotificationCenter.defaultUserNotificationCenter()
            center.deliverNotification(notification)
        })
    }
    
    func deleteLastImage(){
        
        if deleteParam != nil {
           
            let operationManager = AFHTTPRequestOperationManager()
            
            var authHeader: String
            
            if wasScreenshotUploadedWithAccount! {
                authHeader = "Client-Bearer \(imgurSession!.accessToken)"
            } else {
                authHeader = "Client-ID \(imgurClientId)"
            }
            
            println("AuthHeader: \(authHeader)")
            
            operationManager.requestSerializer.setValue(authHeader, forHTTPHeaderField: "Authorization")
            
            
            operationManager.DELETE("https://api.imgur.com/3/image/\(deleteParam!)", parameters: nil,
                
                success: {(operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                    
                    self.notifyImageDeleted((response as! NSDictionary).valueForKey("success") as! Bool)
                    
                }, failure: {(operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    
                    NSLog(error.description)
                    
            })

            
        }
    }
    
    func notifyImageDeleted(success: Bool){
        
        var title: String
        
        if success {
            title = "Image deleted successfully!"
        } else {
            title = "Could not delete image"
        }
        
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = ""
        notification.soundName = NSUserNotificationDefaultSoundName
        let center = NSUserNotificationCenter.defaultUserNotificationCenter()
        center.delegate = self
        center.deliverNotification(notification)
        
        if uploadDelegate != nil {
            uploadDelegate!.imageDeleted()
        }
        

    }
    
    
    func anonymouslyUploadImage(let image: NSImage) {
        self.uploadDelegate?.uploadStarted()
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
        let representation = NSBitmapImageRep(data: image.TIFFRepresentation!)
        
        var temp = [NSObject: AnyObject]()
        
        let data = representation!.representationUsingType(NSBitmapImageFileType.NSJPEGFileType, properties: temp)
        let title = "Screenshot - \(formatter.stringFromDate(date))"
        
        let operationManager = AFHTTPRequestOperationManager()
        operationManager.requestSerializer.setValue("Client-ID \(imgurClientId)", forHTTPHeaderField: "Authorization")
        var parameters = ["type": "file", "title": title]
        operationManager.POST("https://api.imgur.com/3/upload", parameters: parameters,
        constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
        
            formData.appendPartWithFileData(data, name: "image", fileName: title, mimeType: "image/jpeg")
        
        }, success: {(operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
        
            let dictionary = (response as! NSDictionary).valueForKey("data") as! NSDictionary
            let deleteParam: String? = dictionary.valueForKey("deletehash") as! String?
            
            println("DELETEPARAM: \(deleteParam!)")
            
            self.notifyImageUploaded(dictionary.valueForKey("link") as! String, param: deleteParam!)
    
        }, failure: {(operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            self.uploadDelegate?.uploadFinished()
            
            var httpCode = error.code
            
            self.notifyImageNotUploaded(httpCode)

            NSLog(error.description)
        
        })
    }

    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        //let url = NSURL.URLWithString(notification.userInfo.indexForKey("url") as String))
        
        let url = NSURL(string: (notification.valueForKey("url") as! String))
        
        let urlTemp = notification.valueForKey("url") as! String

        println("URL: \(urlTemp)")
        
        NSWorkspace.sharedWorkspace().openURL(url!)
    }
    
    func signOut(){
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.removeObjectForKey("imgur_token")
        
        self.isLoggedIn = false
        
    }


}

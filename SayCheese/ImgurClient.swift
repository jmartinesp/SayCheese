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
    
    var imgurSession: IMGSession?
    
    init() {
        super.init()
        imgurSession = IMGSession.authenticatedSessionWithClientID(imgurClientId, secret: imgurClientSecret, authType: IMGAuthType.PinAuth, withDelegate: self)
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
            let code = defaults.objectForKey("imgur_token") as String
            NSLog("Requests: \(imgurSession!.creditsClientRemaining)")
            imgurSession!.authenticateWithRefreshToken(code)
            NSLog("Autenticando con token: \(code)")
        } else {
            imgurSession!.authenticate()
        }
    }
    
    func imgurSessionNeedsExternalWebview(url: NSURL, completion: () -> Void) {
        NSWorkspace.sharedWorkspace().openURL(url)
        if authenticationDoneDelegate? {
            authenticationDoneDelegate!.activatePinButton()
        }
    }
    
    func imgurRequestFailed(error: NSError?) {
        NSLog("Error")
    }
    
    func imgurSessionAuthStateChanged(state: IMGAuthState) {
        NSLog("State: \(state.toRaw())")
        let defaults = NSUserDefaults.standardUserDefaults()

        if state == IMGAuthState.Authenticated {
            defaults.setObject(imgurSession!.refreshToken as NSString, forKey: "imgur_token")
            defaults.synchronize()
            if authenticationDoneDelegate? {
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
        if doIfAuthenticated? {
            doIfAuthenticated!()
            doIfAuthenticated = nil
        }
        isLoggedIn = true
    }
    
    func isAccessTokenValid() -> Bool! {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
        if imgurSession!.accessTokenExpiry.compare(NSDate()) == NSComparisonResult.OrderedDescending {
            // Token valid
            isLoggedIn = true
            return true
        } else {
            // Token expired
            isLoggedIn = false
            return false
        }
    }
    
    func uploadImage(let image: NSImage) {
        
        let imageUploadedCallback = { (uploadedImage: IMGImage?) -> Void in
            self.notifyImageUploaded(uploadedImage!.url.absoluteString)
        }
        
        var uploadIfOk = { () -> Void in
            let date = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
            var imageData = image.TIFFRepresentation;
            let imageRepresentation = NSBitmapImageRep(data: imageData);
            let imageProps = [ NSImageCompressionFactor: 1.0 ];
            imageData = imageRepresentation.representationUsingType(NSBitmapImageFileType.NSJPEGFileType, properties: imageProps);
            IMGImageRequest.uploadImageWithData(imageData, title: "Screenshot - \(formatter.stringFromDate(date))", success: imageUploadedCallback, progress: nil, failure: nil)
        }
        
        if hasAccount() == false {
            anonymouslyUploadImage(image)
        } else {
            if isAccessTokenValid() == true {
                uploadIfOk()
            } else {
                doIfAuthenticated = uploadIfOk
                imgurSession!.authenticate()
            }
            
        }
    }
    
    func notifyImageUploaded(url: String) {
        // Save url in pasteboard
        let pasteboard = NSPasteboard.generalPasteboard()
        let types = [NSStringPboardType]
        pasteboard.declareTypes(types, owner: nil)
        pasteboard.setString(url, forType: NSStringPboardType)
        
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
    
    
    func anonymouslyUploadImage(let image: NSImage) {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
        let representation = NSBitmapImageRep(data: image.TIFFRepresentation)
        let data = representation.representationUsingType(NSBitmapImageFileType.NSJPEGFileType, properties: nil)
        let title = "Screenshot - \(formatter.stringFromDate(date))"
        
        let operationManager = AFHTTPRequestOperationManager()
        operationManager.requestSerializer.setValue("Client-ID \(imgurClientId)", forHTTPHeaderField: "Authorization")
        var parameters = ["type": "file", "title": title]
        operationManager.POST("https://api.imgur.com/3/upload", parameters: parameters,
        constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
        
            formData.appendPartWithFileData(data, name: "image", fileName: title, mimeType: "image/jpeg")
        
        }, success: {(operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
        
            let dictionary = (response as NSDictionary).valueForKey("data") as NSDictionary
            self.notifyImageUploaded(dictionary.valueForKey("link") as String)
    
        }, failure: {(operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        
            NSLog(error.description)
        
        })
    }

    func userNotificationCenter(center: NSUserNotificationCenter!, shouldPresentNotification notification: NSUserNotification!) -> Bool {
        return true
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter!, didActivateNotification notification: NSUserNotification!) {
        let url = NSURL.URLWithString(notification.userInfo.valueForKey("url") as String)
        NSWorkspace.sharedWorkspace().openURL(url)
    }


}

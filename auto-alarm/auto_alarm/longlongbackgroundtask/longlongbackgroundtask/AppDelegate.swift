//
//  AppDelegate.swift
//  Auto Alarm
//
//  Created by  deemo on 16/8/12.
//  Copyright (c) 2016  deemo. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    var audioPlayer: AVAudioPlayer!
    var audioEngine = AVAudioEngine()
    
    let app = UIApplication.sharedApplication()
    
    var window: UIWindow?
    var emailnum=0;
    var bgTask: UIBackgroundTaskIdentifier!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        print("application Will Enter Background")
        
        
        
        self.bgTask = app.beginBackgroundTaskWithExpirationHandler() {
            self.app.endBackgroundTask(self.bgTask)
            self.bgTask = UIBackgroundTaskInvalid
        }
        
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "applyForMoreTime", userInfo: nil, repeats: true)
        // now, do what you want to do
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "doSomething", userInfo: nil, repeats: true)
    }
    
    func doSomething() {
        print("doing something, \(app.backgroundTimeRemaining)")

    }
    
    func applyForMoreTime() {
        
        if app.backgroundTimeRemaining < 170 {
            
            let filePathUrl = NSURL(string: NSBundle.mainBundle().pathForResource("1", ofType: "wav")!)!
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.MixWithOthers)
                globalVar.volume = AVAudioSession.sharedInstance().outputVolume
                print("output volume: \(globalVar.volume)")
                var smtpSession = MCOSMTPSession()
                //smtpSession.hostname = "smtp.gmail.com"
                //smtpSession.username = "zyxiaooo@gmail.com"
                //smtpSession.password = "19941213xiao"
                smtpSession.hostname = "smtp.126.com"
                smtpSession.username = "zyxiaooo@126.com"
                smtpSession.password = "19941213zhang"
                smtpSession.port = 465
                smtpSession.authType = MCOAuthType.SASLPlain
                smtpSession.connectionType = MCOConnectionType.TLS
                smtpSession.connectionLogger = {(connectionID, type, data) in
                    if data != nil {
                        if let string = NSString(data: data, encoding: NSUTF8StringEncoding){
                            NSLog("Connectionlogger: \(string)")
                        }
                    }
                }
                if(globalVar.volume>0.9998){
                    if(emailnum==0){globallocation.locationManager.startUpdatingLocation()}
                    emailnum+=1
                    for item in globalVar.globalstrlist{
                    var builder = MCOMessageBuilder()
                    //builder.header.to = [MCOAddress(displayName: "deemo", mailbox: "1377478547@qq.com")]
                    builder.header.to = [MCOAddress(displayName: "deemo", mailbox: item)]                //builder.header.from = MCOAddress(displayName: "yuxiao zhang", mailbox: "zyxiaooo@gmail.com")
                    builder.header.from = MCOAddress(displayName: "Han Gao", mailbox: "zyxiaooo@126.com")
                    builder.header.subject = "I'm probably in danger! -- SOS Message \(String(emailnum)) "
                    builder.htmlBody = "I'm here!!! latitude:\(String(globalVar.lati)) longitude:\(String(globalVar.longi))"
                
                    let rfc822Data = builder.data()
                    let sendOperation = smtpSession.sendOperationWithData(rfc822Data)
                    sendOperation.start { (error) -> Void in
                        if (error != nil) {
                            NSLog("Error sending email: \(error)")
                        } else {
                            NSLog("Successfully sent email!")
                        }
                    }
                    }
                }
            } catch _ {
            }
            if(app.backgroundTimeRemaining < 17){
            self.audioPlayer = try? AVAudioPlayer(contentsOfURL: filePathUrl)
            
            self.audioEngine.reset()
            self.audioPlayer.play()
            
            self.app.endBackgroundTask(self.bgTask)
            self.bgTask = app.beginBackgroundTaskWithExpirationHandler() {
                self.app.endBackgroundTask(self.bgTask)
                self.bgTask = UIBackgroundTaskInvalid
            }
            }
        }
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("application Will Enter Foreground")
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        let location = locations.last! as CLLocation
        NSLog("onetime")
        globalVar.lati = location.coordinate.latitude
        globalVar.longi = location.coordinate.longitude
    }
    

}


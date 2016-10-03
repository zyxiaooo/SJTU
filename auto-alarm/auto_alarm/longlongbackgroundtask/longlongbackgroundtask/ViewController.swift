//
//  ViewController.swift
//  longlongbackgroundtask
//
//  Created by  deemo on 16/8/12.
//  Copyright (c) 2016 deemo. All rights reserved.
//

import UIKit
import CoreLocation

struct globallocation {
    static var locationManager: CLLocationManager!
}
struct globalVar {
    static var globalstrlist = [String]()
    static var lati = 0.0
    static var longi = 0.0
    static var volume = Float(0.0)
    
}
extension String {
    func appendLineToURL(fileURL: NSURL) throws {
        try self.stringByAppendingString("\n").appendToURL(fileURL)
    }
    
    func appendToURL(fileURL: NSURL) throws {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        try data.appendToURL(fileURL)
    }
}

extension NSData {
    func appendToURL(fileURL: NSURL) throws {
        if let fileHandle = try? NSFileHandle(forWritingToURL: fileURL) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.writeData(self)
        }
        else {
            try writeToURL(fileURL, options: .DataWritingAtomic)
        }
    }
}
class ViewController: UIViewController, CLLocationManagerDelegate,UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var contactView: UITableView!
    @IBOutlet weak var emailtext: UITextField!
    
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileDestinationUrl = documentDirectoryURL.URLByAppendingPathComponent("contact.txt")
        do {
            let mytext = try String(contentsOfURL: fileDestinationUrl, encoding: NSUTF8StringEncoding)
            let tmplist = mytext.componentsSeparatedByString("\n") as [NSString]
            for  tmpstr in tmplist{
                if(tmpstr != ""){
                globalVar.globalstrlist.append(tmpstr as String)
                    NSLog("aaaaaaaa:"+String(tmpstr))}
            }
        } catch let error as NSError {
            do{
            globalVar.globalstrlist.append("1377478547@qq.com")
            try "1377478547@qq.com".appendLineToURL(fileDestinationUrl)
            }catch let error as NSError{}
        }
        self.contactView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        contactView.delegate = self
        contactView.dataSource = self
        globallocation.locationManager = CLLocationManager()
        globallocation.locationManager.delegate = self
        globallocation.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        globallocation.locationManager.requestAlwaysAuthorization()
        
        
        // create the destination url for the text file to be saved
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func emailset(sender: AnyObject) {
        //globalVar.globalstr = emailtext.text!
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        
        // create the destination url for the text file to be saved
        let fileDestinationUrl = documentDirectoryURL.URLByAppendingPathComponent("contact.txt")
    
        var text = emailtext.text!
        if (text != ""){
            do{
            // writing to disk
                
                globalVar.globalstrlist.append(text)
                let IndexPathOfLastRow = NSIndexPath(forRow: globalVar.globalstrlist.count - 1, inSection: 0)
                self.contactView.insertRowsAtIndexPaths([IndexPathOfLastRow], withRowAnimation: UITableViewRowAnimation.Left)
                try text.appendLineToURL(fileDestinationUrl)
                for tmpstr in globalVar.globalstrlist{
                    NSLog(tmpstr as String)
                }
                // saving was successful. any code posterior code goes here
                
                // reading from disk
                
                } catch let error as NSError {

            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // number of rows in table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalVar.globalstrlist.count
    }
    
    // create a cell for each table view row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.contactView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = globalVar.globalstrlist[indexPath.row]
        
        return cell
    }
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        if(indexPath.row == 0){return "😝"}
        return "Delete"
    }    // method to run when table view cell is tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        
        // create the destination url for the text file to be saved
        let fileDestinationUrl = documentDirectoryURL.URLByAppendingPathComponent("contact.txt")
        if editingStyle == .Delete {
            if(indexPath.row != 0){
            // remove the item from the data model
            globalVar.globalstrlist.removeAtIndex(indexPath.row)
            do{
            try "".writeToURL(fileDestinationUrl, atomically: true, encoding: NSUTF8StringEncoding)
                for item in globalVar.globalstrlist{
                    do{
                    try String(item).appendLineToURL(fileDestinationUrl)
                    }catch{}
                }
            }catch {}
            // delete the table view row
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
        } else if editingStyle == .Insert {
            
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        let location = locations.last! as CLLocation
        NSLog("onetime")
        globalVar.lati = location.coordinate.latitude
        globalVar.longi = location.coordinate.longitude
    }
}
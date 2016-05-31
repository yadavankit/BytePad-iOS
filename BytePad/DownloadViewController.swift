//
//  DownloadViewController.swift
//  BytePad
//
//  Created by Utkarsh Bansal on 17/04/16.
//  Copyright © 2016 Software Incubator. All rights reserved.
//

import UIKit
import QuickLook

class DownloadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, QLPreviewControllerDataSource {
    
    var items = [(name:String, url:String)]()

    @IBOutlet weak var downloadsTable: UITableView!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print(items[indexPath.row].url)
        
//        performSegueWithIdentifier("DocumentViewSegue", sender: items[indexPath.row].url)
        
        let previewQL = QLPreviewController() // 4
        previewQL.dataSource = self // 5
        previewQL.currentPreviewItemIndex = indexPath.row // 6
        showViewController(previewQL, sender: nil) // 7
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = self.downloadsTable.dequeueReusableCellWithIdentifier("Download Cell") as? DownloadsTableCell {
            
            cell.initCell(items[indexPath.row].name, detail: "", fileURL: items[indexPath.row].url)

            return cell
        }
        
        return DownloadsTableCell()
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        
        let deleteButton = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            
            
        }
        
        //        downloadButton.backgroundColor = UIColor(red:1.00, green:0.34, blue:0.30, alpha:1.0)
        
        
        UIButton.appearance().setTitleColor(UIColor(red:0.00, green:0.0, blue:0.0, alpha:0.45), forState: UIControlState.Normal)
        
        return [deleteButton]
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        let titleLabel = UILabel()
        let colour = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.6)
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: colour, NSKernAttributeName : 3.5]
        titleLabel.attributedText = NSAttributedString(string: "BYTEPAD", attributes: attributes)
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        
        items.removeAll()
        
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        
        // now lets get the directory contents (including folders)
        do {
            let directoryContents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
//            print(directoryContents)
            
            for var file in directoryContents {
                print(file.lastPathComponent)
                print(file.absoluteURL)
                print(file.baseURL)
                print(file.filePathURL)
                
                // Save the data in the list as a tuple
                self.items.append((file.lastPathComponent!, file.absoluteString))
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        downloadsTable.reloadData()
    }
    
    // MARK: Preview
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return items.count
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        return NSURL(string: items[index].url)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

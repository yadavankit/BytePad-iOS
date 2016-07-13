//
//  ViewController.swift
//  Bytepad
//
//  Created by Utkarsh Bansal on 17/04/16.
//  Copyright © 2016 Software Incubator. All rights reserved.
//

import UIKit
import SwiftyJSON
import Onboard
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate{
    
    //MARK: Variables
    
    var papers = [Paper]()
    var filteredPapers = [Paper]()
    let searchController = UISearchController(searchResultsController: nil)
    
    
    let firstPage = OnboardingContentViewController(title: nil, body: "Swipe to download", image: UIImage(named: "ss1"), buttonText: nil) { () -> Void in
        // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
        print(1+1)
    }
    
    
    
    let secondPage = OnboardingContentViewController(title: "Page Title", body: "Page body goes here.", image: nil, buttonText: "Skip") { () -> Void in
        // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
        
    }
    
    let thirdPage = OnboardingContentViewController(title: "Page Title", body: "Page body goes here.", image: nil, buttonText: "Skip") { () -> Void in
        // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
        
    }
    
    
    // MARK: Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var table: UITableView!
    @IBOutlet weak var loadingMessageLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    //MARK: Actions
    @IBAction func retryButton(sender: UIButton) {
        self.loadingMessageLabel.hidden = false
        self.loadingMessageLabel.text = "While the satellite moves into position..."
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        self.retryButton.hidden = true
        self.getPapersData()
        
    }
    
    // MARK: Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If in searching mode, then return the number of results else return the total number
        if searchController.active && searchController.searchBar.text != "" {
            return filteredPapers.count
        }
        return papers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let paper: Paper
        
        if searchController.active && searchController.searchBar.text != "" {
            paper = filteredPapers[indexPath.row]
        } else {
            paper = papers[indexPath.row]
        }
        
        if let cell = self.table.dequeueReusableCellWithIdentifier("Cell") as? PapersTableCell {
            
            cell.initCell(paper.name, detail: paper.detail)
            print(cell)
            return cell
        }
        
        return PapersTableCell()
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        
        let downloadButton = UITableViewRowAction(style: .Normal, title: "Download") { action, index in
            
            var url: String
            
            if self.searchController.active {
                url = String(self.filteredPapers[indexPath.row].url)
            } else {
                url = String(self.papers[indexPath.row].url)
            }
            
            url = url.stringByReplacingOccurrencesOfString(" ", withString: "%20")
            print(url)
            let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
            
            self.table.editing = false
            
            Alamofire.download(.GET, url, destination: destination).response { _, _, _, error in
                if let error = error {
                    print("Failed with error: \(error)")
                } else {
                    print("Downloaded file successfully")
                }
            }

        }
        
        
        
        UIButton.appearance().setTitleColor(Constants.Color.grey, forState: UIControlState.Normal)
        
        return [downloadButton]

    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    
    // MARK: Search
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredPapers = papers.filter { paper in
            let categoryMatch = (scope == "All") || (paper.exam == scope)
            return  categoryMatch && paper.name.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        table.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    // MARK: Defaults
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let onboardingVC = OnboardingViewController(backgroundImage: nil, contents: [firstPage,secondPage,thirdPage])
        onboardingVC.allowSkipping = true;
        onboardingVC.skipHandler = {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        UIButton.appearance().setTitleColor(Constants.Color.grey, forState: UIControlState.Normal)
        
        onboardingVC.skipButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        onboardingVC.pageControl.pageIndicatorTintColor = UIColor.blackColor()
        onboardingVC.pageControl.currentPageIndicatorTintColor = UIColor.redColor()
// onboardingVC.pageControl.backgroundColor = UIColor.lightGrayColor()
        onboardingVC.shouldMaskBackground = false
        
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        firstPage.iconHeight = CGFloat(screenHeight+44)
        firstPage.iconWidth = CGFloat(screenWidth)
        firstPage.underIconPadding = CGFloat(0)

        
        //Present Walkthrough only if User launches BytePad for first time
        if(NSUserDefaults.standardUserDefaults().boolForKey("hasLaunchedOnce") == false)
        {
            self.presentViewController(onboardingVC, animated: true, completion: nil)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        self.getPapersData()
        
        searchController.searchBar.tintColor = UIColor(red:0.45, green:0.45, blue:0.45, alpha:1.0)
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        table.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = ["All", "ST1", "ST2", "PUT", "UT"]
        searchController.searchBar.delegate = self
        activityIndicator.startAnimating()
        
        
        let titleLabel = UILabel()
        let colour = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.6)
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: colour, NSKernAttributeName : 3.5]
        titleLabel.attributedText = NSAttributedString(string: "BYTEPAD", attributes: attributes)
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: API call
    
    func getPapersData(){
        Alamofire.request(.GET, "http://silive.in/bytepad/rest/api/paper/getallpapers?query=")
            .responseJSON { response in
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                
                // If the network works fine
                if response.result.isFailure != true {
                    
                    self.loadingMessageLabel.hidden = true
                    self.table.hidden = false
                    //print(response.result)   // result of response serialization
                    
                    let json = JSON(response.result.value!)
                    
                    for item in json {
                        // Split the title on the . to remove the extention
                        let title = item.1["Title"].string!.characters.split(".").map(String.init)[0]
                        let category = item.1["ExamCategory"].string
                        let url = item.1["URL"].string
                        let detail = item.1["PaperCategory"].string
                        
                        let paper = Paper(name: title, exam: category!, url: url!, detail: detail!)
                        self.papers.append(paper)
                        
                    }
                    self.table.reloadData()
                    
                }
                    // If the network fails
                else {
                    self.retryButton.hidden = false
                    self.loadingMessageLabel.text = "Check your internet connectivity"
                }
                
        }
    }
    

}


//
//  VoorpaginaTableViewController.swift
//  MW4Mobile
//
//  Created by Margreet Wijers on 07-09-18.
//  Copyright © 2018 Margreet Wijers. All rights reserved.
//

import UIKit
    
    class VoorpaginaTableViewController: UITableViewController, XMLParserDelegate {
        
        
        
        var myFeed : NSArray = []
        var feedImgs: [AnyObject] = []
        var url: URL!
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 140
         
            self.tableView.dataSource = self
            self.tableView.delegate = self
            
            loadData()
        }
        
        @IBAction func refreshFeed(_ sender: Any) {
            
            loadData()
        }
      
        
        func loadData() {
         
            if  let controller = tabBarController,
                let tabBar = tabBarController?.tabBar,
                let items = tabBarController?.tabBar.items
            {
               
                if controller.selectedIndex == 0
                {
                    self.title = "Voorpagina"
                    url = URL(string: "http://www.nu.nl/rss/Algemeen")!
                    
                    loadRss(url);
                } else if controller.selectedIndex == 1
                {
                     self.title = "Sport"
                    url = URL(string: "http://www.nu.nl/rss/Sport")!
                   
                    loadRss(url);
                } else if controller.selectedIndex == 2
                {
                    self.title = "Opmerkelijk"
                    url = URL(string: "http://www.nu.nl/rss/Opmerkelijk")!
                    
                    loadRss(url);
                }
            }
           
        }
        
        func loadRss(_ data: URL) {
            
            // XmlParserManager instance/object/variable
            let myParser : XmlParserManager = XmlParserManager().initWithURL(data) as! XmlParserManager
            // Put feed in array
            feedImgs = myParser.img as [AnyObject]
            myFeed = myParser.feeds
            tableView.reloadData()
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "openPage" {
                let backItem = UIBarButtonItem()
                backItem.title = self.title
                navigationItem.backBarButtonItem = backItem
                let indexPath: IndexPath = self.tableView.indexPathForSelectedRow!
                let selectedFURL: String = (myFeed[indexPath.row] as AnyObject).object(forKey: "link") as! String
                // Instance of our feedpageviewcontrolelr
                let fivc: FeedItemViewController = segue.destination as! FeedItemViewController
                fivc.selectedFeedURL = selectedFURL as String
            }
        }
        
        // MARK: - Table view data source
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return myFeed.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.backgroundColor = UIColor.clear
            cell.detailTextLabel?.backgroundColor = UIColor.clear
            
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = UIColor(white: 1, alpha: 0.1)
            } else {
                cell.backgroundColor = UIColor(white: 1, alpha: 0.2)
            }
            
            // Load feed iamge.
            let url = NSURL(string:feedImgs[indexPath.row] as! String)
            let data = NSData(contentsOf:url! as URL)
            var image = UIImage(data:data! as Data)
            image = resizeImage(image: image!, toTheSize: CGSize(width: 70, height: 70))
            let cellImageLayer: CALayer?  = cell.imageView?.layer
            cellImageLayer!.cornerRadius = 35
            cellImageLayer!.masksToBounds = true
            cell.imageView?.image = image
            cell.textLabel?.text = (myFeed.object(at: indexPath.row) as AnyObject).object(forKey: "title") as? String
            cell.textLabel?.textColor = UIColor.gray
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            
            cell.detailTextLabel?.text = (myFeed.object(at: indexPath.row) as AnyObject).object(forKey: "pubDate") as? String
            cell.detailTextLabel?.textColor = UIColor.white
            
            return cell
        }
        
        func UIColorFromRGB(rgbValue: UInt) -> UIColor {
            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        }
        
        func resizeImage(image:UIImage, toTheSize size:CGSize)->UIImage{
            
            
            let scale = CGFloat(max(size.width/image.size.width,
                                    size.height/image.size.height))
            let width:CGFloat  = image.size.width * scale
            let height:CGFloat = image.size.height * scale;
            
            let rr:CGRect = CGRect(x: 0, y: 0, width: width, height: height)
            
            UIGraphicsBeginImageContextWithOptions(size, false, 0);
            image.draw(in: rr)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            return newImage!
        }
}

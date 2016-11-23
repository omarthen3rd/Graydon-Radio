//
//  MasterViewController.swift
//  Radio Graydon
//
//  Created by Omar Abbasi on 2016-10-10.
//  Copyright © 2016 Omar Abbasi. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import Alamofire
import UserNotifications

extension MasterViewController : UIViewControllerPreviewingDelegate {
    
    //peek
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else {
                return nil
        }
        
        guard let DetailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return nil }
        
        let titleDetail = tableTitle[indexPath.row]
        let bodyDetail = tableBody[indexPath.row]
        let annDetail = announcements[indexPath.row]
        let dateDetail = detailDate[indexPath.row]
        
        DetailVC.detailItemTwo = dateDetail
        DetailVC.detailItem = titleDetail
        DetailVC.detailItemThree = bodyDetail
        //DetailVC.annDetailItem = annDetail
        
        previewingContext.sourceRect = cell.frame
        
        return DetailVC
    }
    
    //pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        let detailPop = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as?  DetailViewController
        
        //self.navigationController?.pushViewController(detailPop!, animated: true)
        //present(detailPop!, animated: true, completion: nil)
        
        present(viewControllerToCommit, animated: true, completion: nil)
        
    }
    
}

extension JSON {
    
    public var date: NSDate? {
        get {
            switch self.type {
            case .string:
                return Formatter.jsonDateFormatter.date(from: self.object as! String) as NSDate?
            default:
                return nil
            }
        }
    }
    
    public var dateTime: NSDate? {
        get {
            switch self.type {
            case .string:
                return Formatter.jsonDateTimeFormatter.date(from: self.object as! String) as NSDate?
            default:
                return nil
            }
        }
    }
    
}

class Formatter {
    
    private static var internalJsonDateFormatter: DateFormatter?
    private static var internalJsonDateTimeFormatter: DateFormatter?
    
    static var jsonDateFormatter: DateFormatter {
        if (internalJsonDateFormatter == nil) {
            internalJsonDateFormatter = DateFormatter()
            internalJsonDateFormatter!.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'" //old one: "yyyy-MM-dd'T'HH:mm:ss-hh:mm"
        }
        return internalJsonDateFormatter!
    }
    
    static var jsonDateTimeFormatter: DateFormatter {
        if (internalJsonDateTimeFormatter == nil) {
            internalJsonDateTimeFormatter = DateFormatter()
            internalJsonDateTimeFormatter!.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ" //"'yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'" //old one: "yyyy-MM-dd'T'HH:mm:ss-hh:mm"
        }
        return internalJsonDateTimeFormatter!
    }
    
}

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
            
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var cellView = self.accessoryView?.frame
        cellView?.origin.y = 13.5
        self.accessoryView?.frame = cellView!
        
    }

}

class MasterViewController: UITableViewController, UISearchBarDelegate {

    var detailViewController: DetailViewController? = nil
    
    var tableTitle = [String]()
    var tableBody = [String]()
    var tableDate = [String]()
    var detailDate = [String]()
    
    var annTitle = String()
    var annBody = String()
    
    var announcements = [Announcement]()
    var filteredAnnouncements = [Announcement]()
    
    var resultSearchController = UISearchController(searchResultsController: nil)
    
    /* TODO */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
  
        //3D touch
        if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: tableView)
        }
        
        //pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white //UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        refreshControl?.tintColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0) //UIColor.white
        refreshControl?.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.addSubview(refreshControl!)
        
        //navigation bar customization
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        UINavigationBar.appearance().tintColor = UIColor.white //UIColor(red:1.00, green:0.93, blue:0.10, alpha:1.0) 
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        //hide searchbar by default
        let searchOffset = CGPoint(x: 0, y: 44)
        tableView.setContentOffset(searchOffset, animated: false)
        
        //ggmss logo on nav bar
        let logo = UIImage(named: "graydonGlyph2")
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
        
        //tableview delegates and stuff
        tableView.dataSource = self
        tableView.delegate = self
        
        //search results controller
        self.resultSearchController = ({
        
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.barTintColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
            controller.searchBar.searchBarStyle = UISearchBarStyle.default
            controller.searchBar.backgroundColor = UIColor.clear
            controller.searchBar.tintColor = UIColor.white
            UIApplication.shared.statusBarStyle = .lightContent
            self.tableView.tableHeaderView = controller.searchBar
            return controller
            
        })()
        self.tableView.reloadData()
        
        //self-explanatory
        tableView.backgroundColor = UIColor.white
        
        //some splitview stuff
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            
        }
        
        //hide search after selecting cell
        definesPresentationContext = true
        
        getAnnouncements()
        
    }
    
    //proper cell deselection
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.indexPathsForSelectedRows?.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }
        
    }
    
    //refresh tableView
    func refreshTableView() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            
            self.announcements.removeAll()
            self.tableDate.removeAll()
            self.getAnnouncements()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            
        })
    }
    
    //get announcements from server
    func getAnnouncements() {
        
        Alamofire.request("https://radiograydon.aubble.com/announcements").responseJSON { (Response) in
            
            if let value = Response.result.value {
                
                let json = JSON(value)
                
                for annItem in json.array! {
                    
                    let newAnn : Announcement = Announcement(annTitle: annItem["title"].stringValue, annBody: annItem["body"].stringValue)
                    let title: String = annItem["title"].stringValue
                    let body: String = annItem["body"].stringValue
                    self.tableTitle.append(title)
                    self.tableBody.append(body)
                    self.announcements.append(newAnn)
                    
                    let dateFormatter = DateFormatter()
                    let enCAPosixLocale = NSLocale(localeIdentifier: "en-CA")
                    dateFormatter.locale = enCAPosixLocale as Locale!
                    dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
                    dateFormatter.setLocalizedDateFormatFromTemplate("MMMM d, yyyy")
                    let displayString = dateFormatter.string(from: annItem["date"].dateTime! as Date)
                    self.detailDate.append(displayString)
                    
                    let dateFormatterCell = DateFormatter()
                    let enCAlocale = NSLocale(localeIdentifier: "en_CA")
                    dateFormatterCell.locale = enCAlocale as Locale!
                    dateFormatterCell.setLocalizedDateFormatFromTemplate("MMM d")
                    let displayStringCell = dateFormatterCell.string(from: annItem["date"].dateTime! as Date)
                    self.tableDate.append(displayStringCell)
                    
                }
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                    
                }
                
            }
            
        }
        
    }
    
    func filterContentForSearchText(searchText: String) {
        
        filteredAnnouncements = announcements.filter({ (announcement) -> Bool in
            return announcement.annTitle.lowercased().contains(searchText.lowercased())
        })
        self.tableView.reloadData()
        
    }

    func sendNotification() {
        
        var dateComp = DateComponents()
        dateComp.hour = 8
        dateComp.minute = 00
        dateComp.second = 00
        dateComp.timeZone = TimeZone.current
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = calendar.date(from: dateComp)
        
        let localNotification: UILocalNotification = UILocalNotification()
        localNotification.alertTitle = "New Radio Graydon Announcements"
        localNotification.alertBody = "New announcements have been posted!"
        localNotification.alertAction = "view"
        localNotification.fireDate = date
        localNotification.repeatInterval = NSCalendar.Unit.day
        UIApplication.shared.scheduleLocalNotification(localNotification)
        
    }

    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let annDetail : Announcement
                let objectThree = detailDate[indexPath.row] as String
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                if resultSearchController.isActive {
                    
                    annDetail = filteredAnnouncements[indexPath.row]
                    
                } else {
                    
                    annDetail = announcements[indexPath.row]
                    
                }
                
                //controller.detailItem = object
                controller.detailItemTwo = objectThree
                //controller.detailItemThree = objectTwo
                controller.annDetailItem = annDetail
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if let cell = sender as? CustomTableViewCell, segue.identifier == "showDetailPeek" {
            
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.detailItem = cell.titleLabel.text
            controller.detailItemTwo = cell.dateLabel.text
            controller.detailItemThree = cell.detailLabel.text
            controller.navigationController?.navigationBar.isHidden = true
            //controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            //controller.navigationItem.leftItemsSupplementBackButton = true
            
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.resultSearchController.isActive {
            
            return self.filteredAnnouncements.count

        } else {
            
            return announcements.count
            
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        var announcement : Announcement
        
        let objectThree = tableDate[indexPath.row]
        
        let imageView = UIImage(named: "dIndicator")
        cell.accessoryView = UIImageView(image: imageView)
        
        if self.resultSearchController.isActive && resultSearchController.searchBar.text != "" {
            
            announcement = filteredAnnouncements[indexPath.row]
            
        } else {
            
            announcement = announcements[indexPath.row]
            
        }
        
        let today = Date()
        let dateFormatter2 = DateFormatter()
        dateFormatter2.setLocalizedDateFormatFromTemplate("MMM d")
        let todayDate = dateFormatter2.string(from: today)
    
        let oneDayAgo = today.addingTimeInterval(-1*60*60*24)
        let yesterDateFormatter = DateFormatter()
        yesterDateFormatter.setLocalizedDateFormatFromTemplate("MMM d")
        let yesterDate = yesterDateFormatter.string(from: oneDayAgo)
        
        cell.titleLabel.text = announcement.annTitle
        cell.detailLabel.text = announcement.annBody
        cell.dateLabel.text = objectThree
        
        if cell.dateLabel.text == todayDate {
            cell.dateLabel.text = "Today"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}

extension MasterViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}

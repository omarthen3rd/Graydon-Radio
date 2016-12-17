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

extension MasterViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}

extension MasterViewController : UIViewControllerPreviewingDelegate, UISplitViewControllerDelegate {
    
    //peek
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else {
                return nil
        }
        
        guard let DetailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return nil }

        let annDetail = announcements[indexPath.row]
        DetailVC.annDetailItem = annDetail
        previewingContext.sourceRect = cell.frame
        
        return DetailVC
    }
    
    //pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        let detailPop = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as?  DetailViewController
        
        //self.navigationController?.pushViewController(detailPop!, animated: true)
        //present(detailPop!, animated: true, completion: nil)
        
        //viewControllerToCommit.navigationController?.navigationBar.isHidden = false
        
        //present(viewControllerToCommit, animated: true, completion: nil)
        
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
        
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
            internalJsonDateFormatter!.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        }
        return internalJsonDateFormatter!
    }
    
    static var jsonDateTimeFormatter: DateFormatter {
        if (internalJsonDateTimeFormatter == nil) {
            internalJsonDateTimeFormatter = DateFormatter()
            internalJsonDateTimeFormatter!.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"
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
    
    var tableDate = [String]()
    var detailDate = [String]()
    var currentPageNumber = 1
    
    var announcements = [Announcement]()
    var filteredAnnouncements = [Announcement]()
    
    var resultSearchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Default Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
  
        if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: tableView)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        setupTheme()
        getAnnouncements(currentPageNumber)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.indexPathsForSelectedRows?.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }
        
    }
    
    // MARK: - Functions
    
    func refreshTableView() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            
            self.announcements.removeAll()
            self.getAnnouncements(self.currentPageNumber)
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            
        })
    }
    
    func getAnnouncements(_ pageNumber: Int) {
        
        Alamofire.request("https://radiograydon.aubble.com/announcements?page=\(pageNumber)").responseJSON { (Response) in
            
            if let value = Response.result.value {
                
                let json = JSON(value)
                
                for annItem in json.array! {
                    
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
                    
                    let newAnn: Announcement = Announcement(annTitle: annItem["title"].stringValue, annBody: annItem["body"].stringValue, annDate: displayString, altAnnDate: displayStringCell)
                    self.announcements.append(newAnn)
                    
                }
                
                DispatchQueue.main.async { 
                    
                    self.tableView.reloadData()
                    
                }
            }
        }
    }
    
    func setupTheme() {
        
        self.resultSearchController = ({
            
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.searchBarStyle = UISearchBarStyle.prominent
            controller.searchBar.backgroundColor = UIColor.white
            controller.searchBar.tintColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
            UIApplication.shared.statusBarStyle = .default
            self.tableView.tableHeaderView = controller.searchBar
            return controller
            
        })()
        self.tableView.reloadData()
        
        definesPresentationContext = true
        
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        refreshControl?.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.addSubview(refreshControl!)
        
        UINavigationBar.appearance().tintColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        UIApplication.shared.statusBarStyle = .default
        
        let searchOffset = CGPoint(x: 0, y: 44)
        tableView.setContentOffset(searchOffset, animated: false)
        
        let logo = UIImage(named: "graydonGlyph2")
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
        
        tableView.backgroundColor = UIColor.white
        
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
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                if resultSearchController.isActive {
                    
                    annDetail = filteredAnnouncements[indexPath.row]
                    
                } else {
                    
                    annDetail = announcements[indexPath.row]
                    
                }

                controller.annDetailItem = annDetail
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if let cell = sender as? CustomTableViewCell, segue.identifier == "showDetailPeek" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            
                let annDetail : Announcement
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                if resultSearchController.isActive {
                    
                    annDetail = filteredAnnouncements[indexPath.row]
                    
                } else {
                    
                    annDetail = announcements[indexPath.row]
                    
                }
                
                controller.annDetailItem = annDetail
                //controller.navigationController?.navigationBar.isHidden = false
                
            }
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
        
        cell.titleLabel.text = announcement.annTitle
        cell.detailLabel.text = announcement.annBody
        cell.dateLabel.text = announcement.altAnnDate
        
        if cell.dateLabel.text == todayDate {
            cell.dateLabel.text = "Today"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
}

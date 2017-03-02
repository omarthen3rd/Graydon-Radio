//
//  MasterViewController.swift
//  Radio Graydon
//
//  Created by Omar Abbasi on 2016-10-10.
//  Copyright © 2016 Omar Abbasi. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Spring

extension MasterViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

extension MasterViewController : UIViewControllerPreviewingDelegate, UISplitViewControllerDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else {
                return nil
        }
        
        guard let DetailVC = storyboard?.instantiateViewController(withIdentifier: "DetailTableViewController") as? DetailTableViewController else { return nil }

        let annDetail = announcements[indexPath.row]
        DetailVC.annDetailItem = annDetail
        previewingContext.sourceRect = cell.frame
        
        return DetailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
        
    }
    
}

extension JSON {
    
    public var date: Date? {
        get {
            switch self.type {
            case.string:
                return Formatter.jsonDateFormatter.date(from: self.object as! String)
            default:
                return nil
            }
        }
    }
    
}

class Formatter {
    
    private static var internalJsonDateFormatter: DateFormatter?
    
    static var jsonDateFormatter: DateFormatter {
        if (internalJsonDateFormatter == nil) {
            internalJsonDateFormatter = DateFormatter()
            internalJsonDateFormatter!.dateFormat = "yyyy-MM-dd"
            // "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        }
        return internalJsonDateFormatter!
    }
    
}

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var springBGView: SpringView!
    @IBOutlet weak var titleView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgView.layer.cornerRadius = 10.0
        bgView.layer.masksToBounds = true
        bgView.layer.shadowColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.60).cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: 4)
        bgView.layer.shadowRadius = 4.0
        
        titleView.backgroundColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        
        // var cellView = self.accessoryView?.frame
        // cellView?.origin.y = 14.5
        // self.accessoryView?.frame = cellView!
    }

}

class MasterViewController: UITableViewController, UISearchBarDelegate {

    var detailViewController: DetailTableViewController? = nil
    
    var idToUse = 0
    
    var tableDate = [String]()
    var detailDate = [String]()
    
    var announcements = [Announcement]()
    var filteredAnnouncements = [Announcement]()
    
    var resultSearchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Default Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: tableView)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if let split = self.splitViewController {
           let controllers = split.viewControllers
           self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailTableViewController
        }
        
        setupTheme()
        getAnns(25, idToUse)
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if (self.view.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact) {
            // self.navigationItem.titleView?.frame = CGRect(x: (self.navigationItem.titleView?.frame.origin.x)!, y: (self.navigationItem.titleView?.frame.origin.y)!, width: 15, height: 15)
        } else if (self.view.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.regular) {
            // self.navigationItem.titleView?.frame = CGRect(x: (self.navigationItem.titleView?.frame.origin.x)!, y: (self.navigationItem.titleView?.frame.origin.y)!, width: 25, height: 25)
        }
    }
    
    // MARK: - Functions
    
    func refreshTableView() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            
            self.announcements.removeAll()
            // self.getAnnouncements()
            self.getAnns(25, 0)
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            
        })
    }
    
    func getAnns(_ annCount: Int, _ before: Int) {
        
        if before == 0 {
            
            Alamofire.request("https://radiograydon.me/api/v1/anns?count=\(annCount)").responseJSON { (Response) in
                
                if let value = Response.result.value {
                    
                    let json = JSON(value)
                    
                    for ann in json.arrayValue {
                        
                        let dateFormatter = DateFormatter()
                        let enCAPosixLocale = NSLocale(localeIdentifier: "en-CA")
                        dateFormatter.locale = enCAPosixLocale as Locale!
                        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
                        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM d, yyyy")
                        let displayString = dateFormatter.string(from: ann["date"].date!)
                        // let dateThingy = dateFormatter.date(from: ann["date"].stringValue)
                        self.detailDate.append(displayString)
                        
                        let dateFormatterCell = DateFormatter()
                        let enCAlocale = NSLocale(localeIdentifier: "en_CA")
                        dateFormatterCell.locale = enCAlocale as Locale!
                        dateFormatterCell.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
                        // dateFormatterCell.setLocalizedDateFormatFromTemplate("MMM d")
                        dateFormatterCell.setLocalizedDateFormatFromTemplate("MMM d")
                        let displayStringCell = dateFormatterCell.string(from: ann["date"].date!)
                        self.tableDate.append(displayStringCell)
                        
                        let newAnn: Announcement = Announcement(id: ann["id"].intValue, annTitle: ann["title"].stringValue, annBody: ann["body"].stringValue, annDate: displayString, altAnnDate: displayStringCell)
                        self.announcements.append(newAnn)
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.tableView.reloadData()
                        
                    }
                    
                }
                
            }
            
        } else {
            
            Alamofire.request("https://radiograydon.me/api/v1/anns?count=\(annCount)&before=\(before)").responseJSON { (Response) in
                
                if let value = Response.result.value {
                    
                    let json = JSON(value)
                    
                    for ann in json.arrayValue {
                        
                        let dateFormatter = DateFormatter()
                        let enCAPosixLocale = NSLocale(localeIdentifier: "en-CA")
                        dateFormatter.locale = enCAPosixLocale as Locale!
                        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
                        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM d, yyyy")
                        let displayString = dateFormatter.string(from: ann["date"].date!)
                        self.detailDate.append(displayString)
                        
                        let dateFormatterCell = DateFormatter()
                        let enCAlocale = NSLocale(localeIdentifier: "en_CA")
                        dateFormatterCell.locale = enCAlocale as Locale!
                        dateFormatterCell.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
                        dateFormatterCell.setLocalizedDateFormatFromTemplate("MMM d")
                        let displayStringCell = dateFormatterCell.string(from: ann["date"].date!)
                        self.tableDate.append(displayStringCell)
                        
                        let newAnn: Announcement = Announcement(id: ann["id"].intValue, annTitle: ann["title"].stringValue, annBody: ann["body"].stringValue, annDate: displayString, altAnnDate: displayStringCell)
                        self.announcements.append(newAnn)
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.tableView.reloadData()
                        
                    }
                    
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
            controller.searchBar.searchBarStyle = UISearchBarStyle.minimal
            controller.searchBar.barTintColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            controller.searchBar.isTranslucent = true
            controller.searchBar.tintColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
            let textFieldInsideSearchBar = controller.searchBar.value(forKey: "searchField") as? UITextField
            textFieldInsideSearchBar?.textColor = UIColor.white
            
            for subview in controller.searchBar.subviews {
                for secondLevel in subview.subviews {
                    if secondLevel.isKind(of: UITextField.self) {
                        if let searchBarTextField: UITextField = secondLevel as? UITextField {
                            searchBarTextField.textColor = UIColor.white
                            break
                        }
                    }
                }
            }
            
            self.tableView.tableHeaderView = controller.searchBar
            return controller
            
        })()
        self.tableView.reloadData()
        
        definesPresentationContext = true
        
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.clear
        refreshControl?.tintColor = UIColor.white // UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        refreshControl?.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.addSubview(refreshControl!)
        
        UINavigationBar.appearance().tintColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        navigationController?.navigationBar.barStyle = .default
        UIApplication.shared.statusBarStyle = .default
        
        let searchOffset = CGPoint(x: 0, y: 44)
        tableView.setContentOffset(searchOffset, animated: false)
        
        let logo = UIImage(named: "graydonGlyph2")
        let imageView = UIImageView(image: logo)
        self.title = "Graydon Radio"
        // self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red:1.00, green:0.93, blue:0.10, alpha:1.0)]
        // self.navigationItem.titleView = imageView
        
        let bgImage = UIImage(named: "wall")
        let bgView = UIImageView(image: bgImage)
        bgView.image = bgImage?.applyBlurWithRadius(8, tintColor: UIColor(white:0.0, alpha:0.5), saturationDeltaFactor: 3)
        bgView.contentMode = .scaleAspectFill
        self.tableView.backgroundView = bgView
        // self.tableView.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0)
        
    }
    
    func loadingCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = cell.center
        cell.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        cell.tag = 1337
        return cell
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
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailTableViewController
                
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
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailTableViewController
                
                if resultSearchController.isActive {
                    
                    annDetail = filteredAnnouncements[indexPath.row]
                    
                } else {
                    
                    annDetail = announcements[indexPath.row]
                    
                }
                
                controller.annDetailItem = annDetail
                
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.resultSearchController.isActive {
            
            return self.filteredAnnouncements.count + 1

        } else {
            
            return announcements.count + 1
            
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        
        if cell.tag == 1337 {
            if !(announcements.isEmpty) {
                let ann = announcements.last!
                self.idToUse = ann.id
                getAnns(25, self.idToUse)
            } else {
                print("ran else")
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < self.announcements.count {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            
            var announcement : Announcement
            
            // let imageView = UIImage(named: "dIndicator")
            // cell.accessoryView = UIImageView(image: imageView)
            
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
            
            cell.springBGView.animation = "fadeIn"
            cell.springBGView.animate()
            
            return cell
            
        } else {
            return loadingCell()
        }
        
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.resultSearchController.isActive {
            self.resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.default
        }
        if !(self.resultSearchController.isActive) {
            self.resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        }
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 103
    }
    
    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
}

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

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
}


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
        bgView.layer.shadowPath = UIBezierPath(rect: bgView.bounds).cgPath
        
        titleView.backgroundColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        
        // let blurEffect = UIBlurEffect(style: .dark)
        // let newSelectedView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        // newSelectedView.frame = self.bounds
        
        selectedBackgroundView = UIVisualEffectView(frame: self.bounds)
        
        // var cellView = self.accessoryView?.frame
        // cellView?.origin.y = 14.5
        // self.accessoryView?.frame = cellView!
    }

}

class MasterViewController: UITableViewController, UISearchBarDelegate {

    var detailViewController: DetailTableViewController? = nil
    
    var idToUse = 0
    var didLoadAllAnnouncements = false
    
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
        
        var dataToPass: Announcement!
        
        setupTheme()
        getAnns(25, idToUse) { (success) in
            
            if success {
                
                dataToPass = self.announcements.first!
                
                if let split = self.splitViewController {
                    let controllers = split.viewControllers
                    self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailTableViewController
                    
                    self.detailViewController?.annDetailItem = dataToPass
                    print("ran this2: " + "\(dataToPass)")
                }
                
            }
            
        }
        
    }
    
    // MARK: - Functions
    
    func refreshTableView() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            
            self.announcements.removeAll()
            self.getAnns(26, 0, completionHandler: { (success) in
                
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                
            })
            
        })
    }
    
    func getAnns(_ annCount: Int, _ before: Int, completionHandler: @escaping (Bool) -> Void) {
        
        var urlToUse = ""
        
        switch before {
        case 0:
            urlToUse = "https://radiograydon.me/api/v1/anns?count=\(annCount)"
        default:
            urlToUse = "https://radiograydon.me/api/v1/anns?count=\(annCount)&before=\(before)"
        }
        
        if !self.didLoadAllAnnouncements {
            
            Alamofire.request(urlToUse).responseJSON { (Response) in
                
                if let value = Response.result.value {
                    
                    let json = JSON(value)
                    
                    let prevAnns = self.announcements.count
                    
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
                    
                    if prevAnns == self.announcements.count {
                        
                        self.didLoadAllAnnouncements = true
                        
                    }
                    
                    completionHandler(true)
                    
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
            let textSearchBar = controller.searchBar.value(forKey: "searchField") as? UITextField
            textSearchBar?.textColor = UIColor.black
            let placeholderTextSearchBar = textSearchBar!.value(forKey: "placeholderLabel") as? UILabel
            placeholderTextSearchBar?.textColor = UIColor.lightGray
            let glassIconView = textSearchBar?.leftView as! UIImageView
            glassIconView.tintColor = UIColor.lightGray
            
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
        
        self.title = "Graydon Radio"
        
        let bgImage = UIImage(named: "wall")
        let bgView = UIImageView(image: bgImage)
        bgView.image = bgImage?.applyBlurWithRadius(20, tintColor: UIColor(white:0.0, alpha:0.5), saturationDeltaFactor: 3)
        bgView.contentMode = .scaleAspectFill
        self.tableView.backgroundView = bgView
        
    }
    
    func filterContentForSearchText(searchText: String) {
        
        filteredAnnouncements = announcements.filter({ (announcement) -> Bool in
            return announcement.annTitle.lowercased().contains(searchText.lowercased())
        })
        self.tableView.reloadData()
        
    }
    
    func loadingCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.frame = CGRect(x: 0, y: 30, width: tableView.bounds.width, height: 40)
        let label = UILabel(frame: cell.frame)
        label.text = "Wow you must be really bored..."
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
        label.textColor = UIColor.white
        label.textAlignment = .center
        if self.didLoadAllAnnouncements {
            cell.addSubview(label)
        }
        cell.tag = 1337
        return cell
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
        } else if let _ = sender as? CustomTableViewCell, segue.identifier == "showDetailPeek" {
            
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
            
            return self.filteredAnnouncements.count

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
                getAnns(25, self.idToUse, completionHandler: { (success) in })
                if self.didLoadAllAnnouncements {
                    cell.tag = 1234
                }
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < self.announcements.count {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            
            var announcement : Announcement
            
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
            let textSearchBar = resultSearchController.searchBar.value(forKey: "searchField") as? UITextField
            textSearchBar?.textColor = UIColor.black
            let placeholderTextSearchBar = textSearchBar!.value(forKey: "placeholderLabel") as? UILabel
            placeholderTextSearchBar?.textColor = UIColor.white
            let glassIconView = textSearchBar?.leftView as! UIImageView
            glassIconView.tintColor = UIColor.white
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

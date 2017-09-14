//
//  DetailTableViewController2.swift
//  Radio Graydon
//
//  Created by Omar Abbasi on 2017-09-14.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit
import MessageUI
import UserNotifications
import UserNotificationsUI

class DetailTableViewController2: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var reportAnIssue: UIButton!
    
    var remindBtn = UIBarButtonItem()
    
    var announcement: Announcement? {
        
        didSet {
            configureView()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        configureView()
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        
        self.reportAnIssue.backgroundColor = UIColor.graydonColor
        self.reportAnIssue.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.reportAnIssue.addTarget(self, action: #selector(self.showMailAppActionSheet), for: UIControlEvents.touchUpInside)
        
        remindBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "remind"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.actionSheet))
        
        self.navigationItem.rightBarButtonItem = remindBtn
        
    }
    
    func configureView() {
       
        if let annTitle = self.titleLabel {
            annTitle.text = announcement?.title
        }
        if let annDate = self.dateLabel {
            annDate.text = announcement?.date
        }
        if let annBody = self.bodyLabel {
            annBody.text = announcement?.body
        }
        
    }
    
    var timeToRemind = 0
    @objc fileprivate func actionSheet() {
        
        let alertCtrl = UIAlertController(title: "", message: "Radio Graydon will remind you about this announcement: ", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // create button action
        let lunch = UIAlertAction(title: "At Lunch", style: UIAlertActionStyle.default) { (action) in
            
            let start = Date()
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateStyle = DateFormatter.Style.medium
            let convertedDate = dateFormatter2.string(from: start)
            let enddt = "\(convertedDate), 10:45" //add day with the time you wish (could be possible to have a UIDatePicker here..)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy, HH:mm"
            let dateObj = dateFormatter.date(from: enddt)
            let calendar = Calendar.current
            let unitFlags = Set<Calendar.Component>([.second])
            let dateComponents = calendar.dateComponents(unitFlags, from: start, to: dateObj!)
            let seconds = dateComponents.second
            if seconds! < 0 {
                
                let newCal = Calendar.current
                var dateComponent = DateComponents()
                dateComponent.day = 1
                let newDate = newCal.date(byAdding: dateComponent, to: start)
                let convertedDate = dateFormatter2.string(from: newDate!)
                
                let enddt = "\(convertedDate), 10:45" //add day with the time you wish (could be possible to have a UIDatePicker here..)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, yyyy, HH:mm"
                let dateObj = dateFormatter.date(from: enddt)
                let calendar = Calendar.current
                let unitFlags = Set<Calendar.Component>([.second])
                let dateComponents = calendar.dateComponents(unitFlags, from: start, to: dateObj!)
                let seconds = dateComponents.second
                self.timeToRemind = seconds!
                self.remindLater()
                let alert = UIAlertController(title: "Radio Graydon Will Remind You", message: "Radio Graydon will remind you about \(self.titleLabel.text!) at 10:45 AM tomorrow", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                self.timeToRemind = seconds!
                self.remindLater()
                let alert = UIAlertController(title: "Radio Graydon Will Remind You", message: "Radio Graydon will remind you about \(self.titleLabel.text!) at 10:45 AM today", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        let endDay = UIAlertAction(title: "Near The End Of The Day", style: UIAlertActionStyle.default) { (action) in
            
            let start = Date()
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateStyle = DateFormatter.Style.medium
            let convertedDate = dateFormatter2.string(from: start)
            let enddt = "\(convertedDate), 14:30" //add day with the time you wish (could be possible to have a UIDatePicker here..)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy, HH:mm"
            let dateObj = dateFormatter.date(from: enddt)
            let calendar = Calendar.current
            let unitFlags = Set<Calendar.Component>([.second])
            let dateComponents = calendar.dateComponents(unitFlags, from: start, to: dateObj!)
            let seconds = dateComponents.second
            if seconds! < 0 {
                
                let newCal = Calendar.current
                var dateComponent = DateComponents()
                dateComponent.day = 1
                let newDate = newCal.date(byAdding: dateComponent, to: start)
                let convertedDate = dateFormatter2.string(from: newDate!)
                
                let enddt = "\(convertedDate), 14:30" //add day with the time you wish (could be possible to have a UIDatePicker here..)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, yyyy, HH:mm"
                let dateObj = dateFormatter.date(from: enddt)
                let calendar = Calendar.current
                let unitFlags = Set<Calendar.Component>([.second])
                let dateComponents = calendar.dateComponents(unitFlags, from: start, to: dateObj!)
                let seconds = dateComponents.second
                self.timeToRemind = seconds!
                self.remindLater()
                let alert = UIAlertController(title: "Radio Graydon Will Remind You", message: "Radio Graydon will remind you about \(self.titleLabel.text!) at 2:30 PM tomorrow", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                
                
            } else {
                
                self.timeToRemind = seconds!
                self.remindLater()
                let alert = UIAlertController(title: "Radio Graydon Will Remind You", message: "Radio Graydon will remind you about \(self.titleLabel.text!) at 2:30 PM today", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                
                
            }
            
        }
        
        let tomorrowMorning = UIAlertAction(title: "Tomorrow Morning", style: UIAlertActionStyle.default) { (action) in
            
            let start = Date()
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateStyle = DateFormatter.Style.medium
            
            //adding a day to the date
            let newCal = Calendar.current
            var dateComponent = DateComponents()
            dateComponent.day = 1
            let newDate = newCal.date(byAdding: dateComponent, to: start)
            let convertedDate = dateFormatter2.string(from: newDate!)
            
            let enddt = "\(convertedDate), 8:05" //add day with the time you wish (could be possible to have a UIDatePicker here..)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy, HH:mm"
            let dateObj = dateFormatter.date(from: enddt)
            let calendar = Calendar.current
            let unitFlags = Set<Calendar.Component>([.second])
            let dateComponents = calendar.dateComponents(unitFlags, from: start, to: dateObj!)
            let seconds = dateComponents.second
            self.timeToRemind = seconds!
            self.remindLater()
            let alert = UIAlertController(title: "Radio Graydon Will Remind You", message: "Radio Graydon will remind you about \(self.titleLabel.text!) at 8:00 AM tomorrow", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // add action to controller
        alertCtrl.view.tintColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        alertCtrl.addAction(lunch)
        alertCtrl.addAction(endDay)
        alertCtrl.addAction(tomorrowMorning)
        alertCtrl.addAction(cancelAction)
        
        alertCtrl.popoverPresentationController?.barButtonItem = remindBtn
        alertCtrl.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width / 2.0, y: self.view.bounds.height / 2.0, width: 1.0, height: 1.0)
        
        // show action sheet
        self.present(alertCtrl, animated: true, completion: nil)
        
    }
    
    func showMailAppActionSheet() {
        
        let alertCtrl = UIAlertController(title: "Choose Mail App", message: "Which mail app would you like to use?", preferredStyle: .actionSheet)
        
        let defaultMailApp = UIAlertAction(title: "Mail", style: .default) { (action) in
            
            self.openMailApp("Apple Mail")
            
        }
        defaultMailApp.setValue(UIImage(named: "appleMail")?.withRenderingMode(.alwaysOriginal), forKey: "image")
        
        let gmailApp = UIAlertAction(title: "Gmail", style: .default) { (action) in
            
            self.openMailApp("Gmail")
            
        }
        gmailApp.setValue(UIImage(named: "gmail")?.withRenderingMode(.alwaysOriginal), forKey: "image")
        
        let sparkApp = UIAlertAction(title: "Spark", style: .default) { (action) in
            
            self.openMailApp("Spark")
            
        }
        sparkApp.setValue(UIImage(named: "spark")?.withRenderingMode(.alwaysOriginal), forKey: "image")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertCtrl.view.tintColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        alertCtrl.addAction(defaultMailApp)
        alertCtrl.addAction(gmailApp)
        alertCtrl.addAction(sparkApp)
        alertCtrl.addAction(cancelAction)
        
        alertCtrl.popoverPresentationController?.sourceView = reportAnIssue
        alertCtrl.popoverPresentationController?.sourceRect = reportAnIssue.bounds
        
        self.present(alertCtrl, animated: true, completion: nil)
        
    }
    
    func openMailApp(_ mailAppToUse: String) {
        
        switch mailAppToUse {
        case "Apple Mail":
            
            let mailComposeViewController = sendMail()
            if MFMailComposeViewController.canSendMail() {
                present(mailComposeViewController, animated: true, completion: nil)
            }
            
        case "Gmail":
            let string = self.announcement?.title
            let body = "There is an issue with this announcement: "
            let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            let encodedString = string?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            if let url = URL(string: "googlegmail:///co?to=gordongraydonradio@gmail.com&subject=\(encodedString!)&body=\(encodedBody!)\(encodedString!)") {
                if #available(iOS 10.0, *) {
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        
                        // apparently gmail doesn't know what a successful completion handler it
                        
                    })
                } else {
                    // Fallback on previous versions
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    } else {
                        self.createAlert(title: "Failed To Open Gmail", message: "Make sure you have Gmail installed on your device.")
                    }
                    
                }
            } else {
                self.createAlert(title: "There's Been A Slight Complication", message: "Please report this issue to the developer.")
            }
            
        case "Spark":
            
            let string = self.announcement?.title
            let body = "There is an issue with this announcement: "
            let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            let encodedString = string?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            if let url = URL(string: "readdle-spark://compose?subject=\(encodedString!)&body=\(encodedBody!)\(encodedString!)&recipient=gordongraydonradio@gmail.com") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        
                        if !success {
                            self.createAlert(title: "Failed To Open Spark", message: "Make sure you have Spark installed on your device.")
                        }
                        
                    })
                } else {
                    // Fallback on previous versions
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    } else {
                        self.createAlert(title: "Failed To Open Spark", message: "Make sure you have Spark installed on your device.")
                    }
                    
                }
            } else {
                self.createAlert(title: "There's Been A Slight Complication", message: "Please report this issue to the developer.")
            }
            
        default:
            
            let mailComposeViewController = sendMail()
            if MFMailComposeViewController.canSendMail() {
                present(mailComposeViewController, animated: true, completion: nil)
            }
            
        }
        
        if mailAppToUse == "Gmail" {
            
            if let url = URL(string: "googlegmail:///co?subject=&body=&to=touser") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        
                        if !success {
                            self.createAlert(title: "Failed To Open Gmail", message: "Make sure you have Gmail installed on your device.")
                        }
                        
                    })
                } else {
                    // Fallback on previous versions
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    } else {
                        self.createAlert(title: "Failed To Open Gmail", message: "Make sure you have Gmail installed on your device.")
                    }
                    
                }
            }
            
        }
        
    }

    func createAlert(title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
        
    }
    
    var isGrantedNotificationAccess:Bool = false
    func remindLater() {
        
        if #available(iOS 10.0, *) {
            
            if isGrantedNotificationAccess{
                
                let content = UNMutableNotificationContent()
                content.title = "Radio Graydon Reminder:"
                content.body = "\(bodyLabel.text!)"
                
                let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: TimeInterval(self.timeToRemind),
                    repeats: false)
                
                let request = UNNotificationRequest(
                    identifier: "announcementRemind",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(
                    request, withCompletionHandler: nil)
                
            }
            
        } else {
            
            sendNotification()
            
        }
        
    }
    
    func sendNotification() {
        
        let localNotification: UILocalNotification = UILocalNotification()
        localNotification.alertTitle = "Radio Graydon Reminder:"
        localNotification.alertBody = "\(titleLabel.text!)"
        localNotification.alertAction = "view"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: TimeInterval(timeToRemind)) as Date
        UIApplication.shared.scheduleLocalNotification(localNotification)
        
    }
    
    func sendMail() -> MFMailComposeViewController {
        
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        
        mc.navigationBar.tintColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        mc.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        
        let emailTitle = "Issue With Announcement"
        let message = "There is an issue with this announcement: \(titleLabel.text!)"
        mc.setMessageBody(message, isHTML: false)
        let toRecipents = ["gordongraydonradio@gmail.com"]
        mc.setSubject(emailTitle)
        mc.setToRecipients(toRecipents)
        
        return mc
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResult.failed.rawValue:
            print("Failed")
        case MFMailComposeResult.saved.rawValue:
            print("Saved")
        case MFMailComposeResult.sent.rawValue:
            print("Sent")
        default:
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

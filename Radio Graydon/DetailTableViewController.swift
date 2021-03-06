//
//  DetailTableViewController.swift
//  Radio Graydon
//
//  Created by Omar Abbasi on 2016-12-23.
//  Copyright © 2016 Omar Abbasi. All rights reserved.
//

import UIKit
import Foundation
import MessageUI
import UserNotifications
import UserNotificationsUI
import Spring

class DetailTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var annTitle: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet var date: UILabel!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet var body: UILabel!
    @IBOutlet weak var bodyView: UIView!
    @IBOutlet var remindBtn: UIBarButtonItem!
    @IBAction func remindBtn(_ sender: Any) {
        actionSheet()
    }
    @IBOutlet var reportIssueButton: UIButton!
    @IBAction func reportIssueBtn(_ sender: Any) {
        
        showMailAppActionSheet()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert,.sound,.badge],
                completionHandler: { (granted,error) in
                    self.isGrantedNotificationAccess = granted
            })
        } else {
            // Fallback on earlier versions
        }
        
        setupTheme()
        self.configureAnnView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.estimatedRowHeight = 400
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
    }

    // MARK: - Functions
    
    var annDetailItem: Announcement? {
        
        didSet {
            self.configureAnnView()
        }
        
    }
    
    func configureAnnView() {
        
        if self.annDetailItem != nil {
            if let labelFour = self.annTitle {
                labelFour.text = annDetailItem?.title
                body.text = annDetailItem?.body
                body.numberOfLines = 0
                date.text = "Announced on: " + (annDetailItem?.date)!
                
            }
        }
    }
    
    func setupTheme() {
        
        let bgImage = UIImage(named: "wall")
        let bgView = UIImageView(image: bgImage)
        bgView.image = bgImage?.applyBlurWithRadius(20, tintColor: UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.45), saturationDeltaFactor: 2)
        bgView.contentMode = .scaleAspectFill
        self.tableView.backgroundView = bgView
        
        reportIssueButton.backgroundColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        reportIssueButton.layer.cornerRadius = 10.0
        reportIssueButton.layer.masksToBounds = true
        
        annTitle.textColor = UIColor.white
        titleView.backgroundColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        titleView.layer.cornerRadius = 10.0
        titleView.layer.masksToBounds = true
        
        bodyView.layer.cornerRadius = 10.0
        bodyView.layer.masksToBounds = true
        
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
        
        alertCtrl.popoverPresentationController?.sourceView = reportIssueButton
        alertCtrl.popoverPresentationController?.sourceRect = reportIssueButton.bounds
        
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
            let string = self.annDetailItem?.title
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
            
            let string = self.annDetailItem?.title
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
    
    var timeToRemind = 0
    fileprivate func actionSheet() {
        
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
                let alert = UIAlertController(title: "Radio Graydon Will Remind You", message: "Radio Graydon will remind you about \(self.annTitle.text!) at 10:45 AM tomorrow", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                self.timeToRemind = seconds!
                self.remindLater()
                let alert = UIAlertController(title: "Radio Graydon Will Remind You", message: "Radio Graydon will remind you about \(self.annTitle.text!) at 10:45 AM today", preferredStyle: .alert)
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
                let alert = UIAlertController(title: "Radio Graydon Will Remind You", message: "Radio Graydon will remind you about \(self.annTitle.text!) at 2:30 PM tomorrow", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                
                
            } else {
                
                self.timeToRemind = seconds!
                self.remindLater()
                let alert = UIAlertController(title: "Radio Graydon Will Remind You", message: "Radio Graydon will remind you about \(self.annTitle.text!) at 2:30 PM today", preferredStyle: .alert)
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
            let alert = UIAlertController(title: "Radio Graydon Will Remind You", message: "Radio Graydon will remind you about \(self.annTitle.text!) at 8:00 AM tomorrow", preferredStyle: .alert)
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
    
    func sendNotification() {
        
        let localNotification: UILocalNotification = UILocalNotification()
        localNotification.alertTitle = "Radio Graydon Reminder:"
        localNotification.alertBody = "\(annTitle.text!)"
        localNotification.alertAction = "view"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: TimeInterval(timeToRemind)) as Date
        UIApplication.shared.scheduleLocalNotification(localNotification)
        
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
                content.body = "\(body.text!)"
                
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
    
    func sendMail() -> MFMailComposeViewController {
        
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        
        mc.navigationBar.tintColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        mc.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        
        let emailTitle = "Issue With Announcement"
        let message = "There is an issue with this announcement: \(annTitle.text!)"
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
        return 400
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
}

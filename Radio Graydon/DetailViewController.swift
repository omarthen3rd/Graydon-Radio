//
//  DetailViewController.swift
//  Radio Graydon
//
//  Created by Omar Abbasi on 2016-10-10.
//  Copyright © 2016 Omar Abbasi. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import UserNotifications
import UserNotificationsUI

class DetailViewController: UIViewController, MFMailComposeViewControllerDelegate  {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel! //this is title
    @IBOutlet weak var detailDateLabel: UILabel!
    @IBOutlet weak var detailTitleLabel: UITextView! //this is description
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var remindBtn: UIBarButtonItem!
    @IBAction func remindButton(_ sender: Any) {
        
        actionSheet()
        
    }
    
    @IBAction func reportButtonPressed(_ sender: AnyObject) {
        
        let mailComposeViewController = sendMail()
        if MFMailComposeViewController.canSendMail() {
            present(mailComposeViewController, animated: true, completion: nil)
        } else {
            print(":(")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //view stuff
        reportButton.backgroundColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        
        //navigation bar customization
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        UINavigationBar.appearance().tintColor = UIColor.white //UIColor(red:1.00, green:0.93, blue:0.10, alpha:1.0)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent

        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert,.sound,.badge],
                completionHandler: { (granted,error) in
                    self.isGrantedNotificationAccess = granted
            })
        } else {
            // Fallback on earlier versions
        }

        navigationController?.navigationBar.isHidden = false
        self.configureAnnView()
        detailTitleLabel.sizeToFit()
    }
    
    var annDetailItem: Announcement? {
        didSet {
            self.configureAnnView()
        }
    }
    
    func configureAnnView() {
        
        if let detailFour = self.annDetailItem {
            if let labelFour = self.detailDescriptionLabel {
                labelFour.text = annDetailItem?.annTitle
                detailTitleLabel.text = annDetailItem?.annBody
                detailDateLabel.text = "Announced on: " + (annDetailItem?.annDate)!
                
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
                print(self.timeToRemind)
                self.remindLater()
                let alert = UIAlertController(title: "Radio Graydon Will Remind You", message: "Radio Graydon will remind you about \(self.detailDescriptionLabel.text!) at 10:45 AM tomorrow", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                self.timeToRemind = seconds!
                self.remindLater()
                let alert = UIAlertController(title: "Radio Graydon Will Remind You", message: "Radio Graydon will remind you about \(self.detailDescriptionLabel.text!) at 10:45 AM today", preferredStyle: .alert)
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
                print(self.timeToRemind)
                self.remindLater()
                let alert = UIAlertController(title: "Radio Graydon Will Remind You", message: "Radio Graydon will remind you about \(self.detailDescriptionLabel.text!) at 2:30 PM tomorrow", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)

                
            } else {
                
                self.timeToRemind = seconds!
                print(self.timeToRemind)
                self.remindLater()
                let alert = UIAlertController(title: "Radio Graydon Will Remind You", message: "Radio Graydon will remind you about \(self.detailDescriptionLabel.text!) at 2:30 PM today", preferredStyle: .alert)
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
            print(self.timeToRemind)
            self.remindLater()
            let alert = UIAlertController(title: "Radio Graydon Will Remind You", message: "Radio Graydon will remind you about \(self.detailDescriptionLabel.text!) at 8:00 AM tomorrow", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)

            
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            
            print("tapped cancel")
            
        }

        
        // add action to controller
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
        localNotification.alertBody = "\(detailTitleLabel.text!)"
        localNotification.alertAction = "view"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: TimeInterval(timeToRemind)) as Date
        UIApplication.shared.scheduleLocalNotification(localNotification)
        
    }
    
    var isGrantedNotificationAccess:Bool = false
    func remindLater() {

        if #available(iOS 10.0, *) {
         
        if isGrantedNotificationAccess{
        //add notification code here
        
        //Set the content of the notification
        let content = UNMutableNotificationContent()
        content.title = "Radio Graydon Reminder:"
        content.body = "\(detailTitleLabel.text!)"
        //content.categoryIdentifier = "com.carol.radiograydon.Extension"
         
        //Set the trigger of the notification -- here a timer.
        let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: TimeInterval(self.timeToRemind),
        repeats: false)
         
        //Set the request for the notification from the above
        let request = UNNotificationRequest(
        identifier: "announcementRemind",
        content: content,
        trigger: trigger
        )
        
        //Add the notification to the currnet notification center
        UNUserNotificationCenter.current().add(
        request, withCompletionHandler: nil)
         
        }
        
        } else {
        
        // Fallback on earlier versions
        
        sendNotification()
        
        }
        
    }
    
    func sendMail() -> MFMailComposeViewController {
        
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        
        mc.navigationBar.tintColor = UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0)
        mc.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        
        let emailTitle = "Issue With Announcement"
        let message = "There is an issue with this announcement: \(detailDescriptionLabel.text!)"
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
}

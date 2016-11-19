//
//  NotificationViewController.swift
//  Extension
//
//  Created by Omar Abbasi on 2016-10-30.
//  Copyright © 2016 Omar Abbasi. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    @IBOutlet weak var labelThree: UILabel!
    @IBOutlet weak var labelTwo: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
        
    }
    
    func didReceive(_ notification: UNNotification) {
        
        let content = notification.request.content
        
        label?.text = content.title
        labelThree.text = content.subtitle
        labelTwo.text = content.body
        
        label?.lineBreakMode = NSLineBreakMode.byWordWrapping
        label?.numberOfLines = 0
        label?.sizeToFit()

    }

}

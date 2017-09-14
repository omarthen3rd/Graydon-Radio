//
//  DetailViewController.swift
//  Alamofire
//
//  Created by Omar Abbasi on 2017-09-13.
//

import UIKit
import Foundation

class DetailViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    
    
    var announcement: Announcement? {
        
        didSet {
            
            self.titleLabel.text = announcement?.title
            self.dateLabel.text = "Announced on: " + (announcement?.date)!
            self.bodyLabel.text = announcement?.body
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

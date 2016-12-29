//
//  ViewController.swift
//  MyDo
//
//  Created by Mohan on 25/12/16.
//  Copyright © 2016 eventfy. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MGSwipeTableCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let _ = CoredataStack.init()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Add new item
    @IBAction func addNewItem(_ sender: Any) {
        let alertController = UIAlertController.init(title: "Add", message: "Add new item", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            let itemName = alertController.textFields!.first?.text
            self.addNewItemWithName(name: itemName!)
        }
        alertController.addAction(addAction)
        present(alertController,animated: true)
    }
    
    func addNewItemWithName(name: String) -> Void {
        print(name)
    }
    
    // Send feedback mail
    @IBAction func sendFeedback(_ sender: Any) {
        let mailComposerVc = configureMailComposerViewController()
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposerVc, animated: true)
        }
    }
    
    func configureMailComposerViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["support@idodaily.in"])
        mailComposerVC.setMessageBody("Feedback", isHTML: false)
        
        return mailComposerVC
    }
    
    // TableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCellId", for: indexPath) as! ItemsListTableViewCell
        cell.delegate = self
        cell.itemNameLabel?.text = "Title"
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = UIColor.red
        } else {
            cell.contentView.backgroundColor = UIColor.blue
        }
        return cell
    }
    
    
    // Tableview Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MGSwipeTableCellDelegate
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        return true
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        
        swipeSettings.transition = MGSwipeTransition.border;
        expansionSettings.buttonIndex = 0;
        
        expansionSettings.fillOnTrigger = false
        expansionSettings.threshold = 2
        
        if direction == MGSwipeDirection.leftToRight {
            // Done
            let color = UIColor.init(red:0.0, green:1.0, blue:0.0, alpha:1.0);
            return [
                MGSwipeButton(title: "Done", backgroundColor: color, callback: { (cell) -> Bool in
                    cell.refreshContentView();
                    (cell.leftButtons[0] as! UIButton).setTitle("Done", for: UIControlState());
                    return true
                })
            ]
            
        } else {
            // Not done
            let color = UIColor.init(red:1.0, green:0.0, blue:0.0, alpha:1.0);
            return [
                MGSwipeButton(title: "Skip", backgroundColor: color, callback: { (cell) -> Bool in
                    cell.refreshContentView();
                    (cell.leftButtons[0] as! UIButton).setTitle("Skip", for: UIControlState());
                    return true
                })
            ]
        }
    }
}


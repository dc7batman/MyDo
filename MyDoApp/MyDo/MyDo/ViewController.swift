//
//  ViewController.swift
//  MyDo
//
//  Created by Mohan on 25/12/16.
//  Copyright © 2016 eventfy. All rights reserved.
//

import UIKit
import MessageUI
import Crashlytics

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MGSwipeTableCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let doneColor = UIColor.init(red:2.0/255, green:178.0/255, blue:31.0/255, alpha:1.0)
    let skipColor = UIColor.init(red:1.0, green:2.0/255, blue:31.0/255, alpha:1.0)
    let grayColor = UIColor.init(red: 142.0/255, green: 142.0/255, blue: 147.0/255, alpha: 1.0)
    let blueColor = UIColor.init(red: 28.0/255, green: 211.0/255, blue: 1.0, alpha: 1.0)
    
    var todayEvents : [Event] = []
    let navBarTitleView = NavBarTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 45))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let _ = CoredataStack.init()
        
        todayEvents = DataModelManager.sharedInstance.fetchTodayEvents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didDeleteHabit), name: Notification.Name(rawValue: "mydo.deleteHabit"), object: nil)
        
        navBarTitleView.translatesAutoresizingMaskIntoConstraints = true
        self.navigationController?.navigationBar.topItem?.titleView = navBarTitleView
        navBarTitleView.titleLabel?.text = "MyDo"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didDeleteHabit() {
        todayEvents = DataModelManager.sharedInstance.fetchTodayEvents()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: false)
        }
    }
    
    // Add new item
    @IBAction func addNewItem(_ sender: Any) {
        let alertController = UIAlertController.init(title: "Add a habit", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            let itemName = alertController.textFields!.first?.text?.capitalized
            self.addNewItemWithName(name: itemName!)
        }
        alertController.addAction(addAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        present(alertController,animated: true)
    }
    
    func addNewItemWithName(name: String) -> Void {
        if name.characters.count > 0 {
            let event: Event = DataModelManager.sharedInstance.createEventWithName(name: name)
            todayEvents.insert(event, at: 0)
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
            tableView.endUpdates()
            
            Answers.logCustomEvent(withName: "Create Event",
                                           customAttributes: [
                                            "Event Name": name])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.tableView.reloadData()
            })
        }
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
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller .dismiss(animated: true, completion: nil)
    }
    
    // TableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todayEvents.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCellId", for: indexPath) as! ItemsListTableViewCell
        cell.delegate = self
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = grayColor
        } else {
            cell.contentView.backgroundColor = blueColor
        }
        
        let event : Event = todayEvents[indexPath.row]
        cell.itemNameLabel?.text = event.name
        
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
        
        expansionSettings.fillOnTrigger = true
        expansionSettings.threshold = 2
        
        if direction == MGSwipeDirection.leftToRight {
            // Done
            return [
                MGSwipeButton(title: "Done", backgroundColor: doneColor, callback: { (cell) -> Bool in
                    cell.refreshContentView();
                    (cell.leftButtons[0] as! UIButton).setTitle("Done", for: UIControlState());
                    
                    let indexPath = self.tableView.indexPath(for: cell)
                    
                    // Add activity
                    let event: Event = self.todayEvents[(indexPath?.row)!]
                    DataModelManager.sharedInstance.addActivity(eventId: Int(event.eventId), isDone: true)
                    
                    // Remove item
                    self.todayEvents.remove(at: (indexPath?.row)!)
                    
                    // Remove cell
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath!], with: .automatic)
                    self.tableView.endUpdates()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.tableView.reloadData()
                    })
                    
                    Answers.logCustomEvent(withName: "Create Activity",
                                           customAttributes: [
                                            "Activity type" : "Done",
                                            "Source" : "Event List"])
                    
                    return true
                })
            ]
            
        } else {
            // Not done
            return [
                MGSwipeButton(title: "Skip", backgroundColor: skipColor, callback: { (cell) -> Bool in
                    cell.refreshContentView();
                    (cell.leftButtons[0] as! UIButton).setTitle("Skip", for: UIControlState());
                    
                    let indexPath = self.tableView.indexPath(for: cell)
                    
                    // Add activity
                    let event: Event = self.todayEvents[(indexPath?.row)!]
                    DataModelManager.sharedInstance.addActivity(eventId: Int(event.eventId), isDone: false)
                    
                    // Remove item
                    self.todayEvents.remove(at: (indexPath?.row)!)
                    
                    // Remove cell
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath!], with: .automatic)
                    self.tableView.endUpdates()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.tableView.reloadData()
                    })
                    
                    Answers.logCustomEvent(withName: "Create Activity",
                                           customAttributes: [
                                            "Activity type" : "Skip",
                                            "Source" : "Event List"])
                    
                    return true
                })
            ]
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showEventDetails" {
            let indexPath = tableView.indexPathForSelectedRow
            let event = todayEvents[(indexPath?.row)!]
            let eventDetailsVC = segue.destination as! EventDetailsViewController
            eventDetailsVC.title = event.name
            eventDetailsVC.eventId = Int(event.eventId)
            
            Answers.logCustomEvent(withName: "Check Details",
                                   customAttributes: [
                                    "Event Name": event.name!])
        }
    }
}


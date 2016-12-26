//
//  ViewController.swift
//  MyDo
//
//  Created by Mohan on 25/12/16.
//  Copyright © 2016 eventfy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    // TableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCellId", for: indexPath)
        cell.textLabel?.text = "Title"
        return cell
    }
    
    
    // Tableview Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


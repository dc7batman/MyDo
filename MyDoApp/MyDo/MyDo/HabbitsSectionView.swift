//
//  HabbitsSectionView.swift
//  MyDo
//
//  Created by Mohan on 05/01/17.
//  Copyright © 2017 eventfy. All rights reserved.
//

import UIKit

enum HabitsSectionType {
    case all
    case today
}

protocol HabitsSectionViewDelegate {
    func didSelectHabbitCategory(type: HabitsSectionType)
}

class HabbitsSectionView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: HabitsSectionViewDelegate?
    

    required override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubViews()
    }

    func addSubViews() {
        self.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.7)
        let tableView = UITableView.init()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView.init()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "habitSectionCell")
        self.addSubview(tableView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: .init(rawValue: 0), metrics: nil, views: ["tableView":tableView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(64)-[tableView(100)]", options: .init(rawValue: 0), metrics: nil, views: ["tableView":tableView]))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "habitSectionCell", for: indexPath)
        cell.textLabel?.textAlignment = .center
        if indexPath.row == 0 {
            cell.textLabel?.text = "Today"
        } else {
            cell.textLabel?.text = "All"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            delegate?.didSelectHabbitCategory(type: .today)
        } else if indexPath.row == 1 {
            delegate?.didSelectHabbitCategory(type: .all)
        }
    }
}

//
//  NavBarTitleView.swift
//  MyDo
//
//  Created by Mohan on 04/01/17.
//  Copyright © 2017 eventfy. All rights reserved.
//

import UIKit

class NavBarTitleView: UIView {
    
    var titleLabel: UILabel?
    private var arrowImageView: UIImageView?

    required override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubViews()
    }
    
    func addSubViews() {
        
        titleLabel = UILabel()
        titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.textAlignment = .center
        self.addSubview(titleLabel!)
        
        self.addConstraint(NSLayoutConstraint.init(item: titleLabel!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: -16.0))
        self.addConstraint(NSLayoutConstraint.init(item: titleLabel!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
        
        arrowImageView = UIImageView.init(image: UIImage.init(named: "Triangle"))
        arrowImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(arrowImageView!)
        
        self.addConstraint(NSLayoutConstraint.init(item: arrowImageView!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: arrowImageView!, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: titleLabel!, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 4.0))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view(==width)]", options: .init(rawValue: 0), metrics: ["width": 16], views: ["view": arrowImageView!]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view(==height)]", options: .init(rawValue: 0), metrics: ["height": 16], views: ["view": arrowImageView!]))
    }

}

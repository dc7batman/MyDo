//
//  NavBarTitleView.swift
//  MyDo
//
//  Created by Mohan on 04/01/17.
//  Copyright © 2017 eventfy. All rights reserved.
//

import UIKit

protocol NavBarTitleViewDelegate {
    func didTapOnNavBarTitleView(show: Bool)
}

class NavBarTitleView: UIView {
    
    var titleLabel: UILabel?
    private var arrowImageView: UIImageView?
    var isMenuShown = false
    var delegate: NavBarTitleViewDelegate?
    

    required override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
        addTapGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubViews()
        addTapGesture()
    }
    
    func addSubViews() {
        
        titleLabel = UILabel()
        titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.textAlignment = .center
        self.addSubview(titleLabel!)
        
        self.addConstraint(NSLayoutConstraint.init(item: titleLabel!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: -16.0))
        self.addConstraint(NSLayoutConstraint.init(item: titleLabel!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
        
        arrowImageView = UIImageView.init(image: UIImage.init(named: "triangle"))
        arrowImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(arrowImageView!)
        
        self.addConstraint(NSLayoutConstraint.init(item: arrowImageView!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: arrowImageView!, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: titleLabel!, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 4.0))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view(==width)]", options: .init(rawValue: 0), metrics: ["width": 12], views: ["view": arrowImageView!]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view(==height)]", options: .init(rawValue: 0), metrics: ["height": 12], views: ["view": arrowImageView!]))
    }

    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tapGesture)
    }
    
    func tapAction() {
        rotateArrowIndicator()
        delegate?.didTapOnNavBarTitleView(show: isMenuShown)
    }
    
    func rotateArrowIndicator() {
        var fromValue: CGFloat = 0.0
        var toValue = CGFloat(M_PI)
        
        if isMenuShown {
            let temp: CGFloat = fromValue
            fromValue = toValue;
            toValue = temp
        }
        isMenuShown = !isMenuShown
        
        let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = fromValue
        rotationAnimation.toValue = toValue
        rotationAnimation.duration = 0.3
        rotationAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = kCAFillModeForwards
        arrowImageView?.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
}

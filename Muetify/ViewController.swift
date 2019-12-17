//
//  ViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/6/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}


@IBDesignable
class CustomView: UIView {

    @IBInspectable var borderWidth: CGFloat = 0.0 {

        didSet {
            self.layer.borderWidth = borderWidth
        }
    }


    @IBInspectable var borderColor: UIColor = UIColor.clear {

        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
        
    }
    
    @IBInspectable var borderRadius: CGFloat = 0.0 {

        didSet {
            self.layer.cornerRadius = borderRadius
        }
        
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

}


@IBDesignable
class CustomButton: UIButton {

    @IBInspectable var borderWidth: CGFloat = 0.0 {

        didSet {
            self.layer.borderWidth = borderWidth
        }
    }


    @IBInspectable var borderColor: UIColor = UIColor.clear {

        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
        
    }
    
    @IBInspectable var borderRadius: CGFloat = 0.0 {

        didSet {
            self.layer.cornerRadius = borderRadius
        }
        
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

}


@IBDesignable
class CircularImageView: UIImageView {
    
    func sharedInit() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        sharedInit()
    }

}

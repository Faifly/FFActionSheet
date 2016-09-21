//
//  FFActionSheet.swift
//  FFActionSheet
//
//  Created by Ihor Embaievskyi on 9/21/16.
//  Copyright © 2016 Faifly. All rights reserved.
//

import UIKit

public class FFActionSheet: UIViewController
{
    // MARK: FFActionSheetItem struct
    
    public struct FFActionSheetItem
    {
        var text : String!
        var image : UIImage?
        var backgroundColor : UIColor?
        var font : UIFont?
        var fontSize : CGFloat?
        var fontColor : UIColor?
        
        public init(text: String, image: UIImage? = nil, backgroundColor: UIColor? = .white, font: UIFont? = .systemFont(ofSize: 14.0), fontSize: CGFloat? = 14.0, fontColor: UIColor? = .black, selectAction: ((_ actionSheet: FFActionSheet) -> Void)? = nil)
        {
            self.text = text
            self.image = image
            self.backgroundColor = backgroundColor
            self.font = font
            self.fontSize = fontSize
            self.fontColor = fontColor
        }
    }
    
    // MARK: Properties
    
    open var backgroundColor : UIColor = .white
    open var itemHeight : CGFloat = 45.0
    open var highlitedColor : UIColor = .lightGray
    open var handler: ((_ index: Int) -> ())?
    
    var dimView = UIView()
    
    // MARK: Init
    
    public init(titles: [String])
    {
        super.init(nibName: nil, bundle: nil)

        let items = titles.map({FFActionSheetItem.init(text: $0, image: nil)})
        
        self.setupViews(views: self.createViews(items: items))
    }
    
    public init(items: [FFActionSheetItem])
    {
        super.init(nibName: nil, bundle: nil)
        
        self.setupViews(views: self.createViews(items: items))
    }
    
    public init(views : [UIView])
    {
        super.init(nibName: nil, bundle: nil)
        
        self.setupViews(views: views)
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Create Views
    
    func createViews(items: [FFActionSheetItem]) -> [UIView]
    {
        var views = [UIView]()
        
        var count = 0;
        
        for item in items
        {
            let view = UIView()
            view.layer.cornerRadius = 10.0
            view.backgroundColor = item.backgroundColor
            
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.clipsToBounds = true
            button.layer.cornerRadius = 10.0
            button.setTitle(item.text, for: .normal)
            button.setTitleColor(item.fontColor, for: .normal)
            button.setBackgroundImage(self.getImageWithColor(color: self.highlitedColor, size: self.view.bounds.size), for: .highlighted)
            button.backgroundColor = .clear
            button.tag = count
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            
            view.addSubview(button)
            
            if item.image != nil
            {
                button.setImage(item.image, for: .normal)
                button.setImage(item.image, for: .highlighted)
                
                button.imageEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 15.0)
                button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 15.0, 0.0, 10.0)
            }
            
            self.setupConstraints(item: button, toItem: view, horizontalConstant: 0.0, topConstant: 0.0, bottomConstant: 0.0)
            
            count = count + 1
            
            views.append(view)
        }
        return views
    }
    
    // MARK: Setup views
    
    func setupViews(views : [UIView])
    {
        var count = 0;
        
        for view in views.reversed()
        {
            view.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(view)
            
            self.setupConstraints(item: view, toItem: self.view, horizontalConstant: 10.0, bottomConstant: -(self.itemHeight * CGFloat(count) * 1.15 + 5), heightConstant: self.itemHeight)
            
            count = count + 1
        }
    }
    
    // MARK: Setup constraints
    
    func setupConstraints(item: AnyObject, toItem: AnyObject, horizontalConstant: CGFloat, topConstant: CGFloat? = nil, bottomConstant: CGFloat, heightConstant: CGFloat? = nil)
    {
        let rightConstraint = NSLayoutConstraint(item: item, attribute: .right, relatedBy: .equal, toItem: toItem, attribute: .right, multiplier: 1, constant: -(horizontalConstant))
        toItem.addConstraint(rightConstraint)
        
        let leftConstraint = NSLayoutConstraint(item: item, attribute: .left, relatedBy: .equal, toItem: toItem, attribute: .left, multiplier: 1, constant: horizontalConstant)
        toItem.addConstraint(leftConstraint)
        
        if topConstant != nil
        {
            let topConstraint = NSLayoutConstraint(item: item, attribute: .top, relatedBy: .equal, toItem: toItem, attribute: .top, multiplier: 1, constant: topConstant!)
            toItem.addConstraint(topConstraint)
        }
        
        let bottomConstraint = NSLayoutConstraint(item: item, attribute: .bottom, relatedBy: .equal, toItem: toItem, attribute: .bottom, multiplier: 1, constant: bottomConstant)
        toItem.addConstraint(bottomConstraint)
        
        if heightConstant != nil
        {
            let heightConstraint = NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: heightConstant!)
            toItem.addConstraint(heightConstraint)
        }
    }
    
    // MARK: Button action
    
    func buttonAction(sender: UIButton!)
    {
        if let buttonHandler = self.handler
        {
            buttonHandler(sender.tag)
        }
        
        UIView.animate(withDuration: 0.25, animations: { 
            self.dimView.alpha = 0.0
            }) { (complete) in
                self.dimView.removeFromSuperview()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Create button image
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage
    {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: Show Action Sheet
    
    public func showActionSheet(from viewController: UIViewController)
    {
        self.dimView = UIView(frame: view.frame)
        self.dimView.backgroundColor = .black
        self.dimView.alpha = 0.0
        viewController.view.addSubview(dimView)
        
        self.dimView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[dimView]|", options: [], metrics: nil, views: ["dimView": self.dimView]))
        viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimView]|", options: [], metrics: nil, views: ["dimView": self.dimView]))
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.dimView.alpha = 0.5
        })
        
        viewController.present(self, animated: true, completion: nil)
    }
}

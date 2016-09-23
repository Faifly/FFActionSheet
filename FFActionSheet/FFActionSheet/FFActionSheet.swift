//
//  FFActionSheet.swift
//  FFActionSheet
//
//  Created by Ihor Embaievskyi on 9/21/16.
//  Copyright © 2016 Faifly. All rights reserved.
//

import UIKit

public class FFActionSheetItem: NSObject
{
    open var text : String!
    open var image : UIImage? = nil
    open var backgroundColor : UIColor? = .white
    open var font : UIFont? = .systemFont(ofSize: 14.0)
    open var fontColor : UIColor? = .black
    open var tag : Int = 0
    open var buttonImageEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 15.0)
    open var buttonTitleEdgeInsets = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 10.0)
}

public class FFActionSheet: UIViewController
{
    // MARK: Properties
    
    open var backgroundColor : UIColor = .white
    open var itemHeight : CGFloat = 45.0
    open var highlitedColor : UIColor = .lightGray
    open var handler: ((_ index: Int) -> ())?
    open var dimViewAlpha = 0.5
    
    private var dimView = UIView()
    private var dimWindow: UIWindow?
    
    // MARK: Init
    
    public init(titles: [String])
    {
        super.init(nibName: nil, bundle: nil)
        
        let items = titles.map { (title) -> FFActionSheetItem in
            let item = FFActionSheetItem()
            item.text = title
            return item
        }
        
        setupViewsPosition(views: self.createViews(items: items))
    }
    
    public init(items: [FFActionSheetItem])
    {
        super.init(nibName: nil, bundle: nil)
        
        setupViewsPosition(views: self.createViews(items: items))
    }
    
    public init(views : [UIView])
    {
        super.init(nibName: nil, bundle: nil)
        
        setupViewsPosition(views: views)
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
            button.titleLabel?.font = item.font
            button.setTitle(item.text, for: .normal)
            button.setTitleColor(item.fontColor, for: .normal)
            button.setBackgroundImage(self.createImage(color: self.highlitedColor, size: self.view.bounds.size), for: .highlighted)
            button.backgroundColor = .clear
            button.tag = item.tag
            button.addTarget(self, action: #selector(onButtonTap), for: .touchUpInside)
            
            view.addSubview(button)
            
            if item.image != nil
            {
                var buttonImage = UIImage()
                
                buttonImage = item.image!
                
                button.imageView?.contentMode = .scaleAspectFit
                
                button.setImage(buttonImage, for: .normal)
                button.setImage(buttonImage, for: .highlighted)
                
                button.imageEdgeInsets = item.buttonImageEdgeInsets
                button.titleEdgeInsets = item.buttonTitleEdgeInsets
            }
            
            self.setupConstraints(item: button, toItem: view, horizontalConstant: 0.0, topConstant: 0.0, bottomConstant: 0.0)
            
            count = count + 1
            
            views.append(view)
        }
        return views
    }
    
    // MARK: Setup views
    
    func setupViewsPosition(views : [UIView])
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
    
    func onButtonTap(sender: UIButton!)
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
        
        self.dimWindow = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Create Image
    
    func createImage(color: UIColor, size: CGSize) -> UIImage
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
        self.dimWindow = UIWindow(frame: UIScreen.main.bounds)
        self.dimWindow?.rootViewController = UIViewController()
        
        let topWindow = UIApplication.shared.windows.last
        self.dimWindow?.windowLevel = topWindow!.windowLevel + 1
        
        self.dimView = UIView(frame: (dimWindow?.frame)!)
        
        self.dimView.backgroundColor = .black
        self.dimView.alpha = 0.0
        
        dimWindow?.addSubview(self.dimView)
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.dimView.alpha = CGFloat(self.dimViewAlpha)
        })
        
        self.dimWindow?.makeKeyAndVisible()
        self.dimWindow?.rootViewController?.present(self, animated: true, completion: nil)
    }
}

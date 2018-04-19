//
//  MenuViewController.swift
//  SideMenuSwift
//
//  Created by PGMY on 2018/04/19.
//  Copyright © 2018年 PGMY. All rights reserved.
//

import UIKit

public let OpenSideMenuNotification = NSNotification.Name(rawValue: "OpenSideMenuNotification")
public let CloseSideMenuNotification = NSNotification.Name(rawValue: "CloseSideMenuNotification")

public class MenuItem: NSObject {
    fileprivate var aClass: UIViewController.Type?
    fileprivate var tag = ""
    
    fileprivate var icon: UIImage?
    fileprivate var title = ""
    
    static func createMenuItem(aClass: UIViewController.Type, title: String, icon: UIImage? = nil) -> MenuItem? {
        let menuItem = MenuItem()
        menuItem.aClass = aClass
        menuItem.title = title
        menuItem.icon = icon
        return menuItem
    }
}

public class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    public var isOpen = false
    public var panGestureEnabled = true
    
    private var menuWidth = UIScreen.main.bounds.width * 0.872
    
    private var panGestureRecognizer = UIPanGestureRecognizer()
    private var gestureStartX: CGFloat = 0
    private var enablePanOfLocationX = false
    
    private var menuItems = Array<MenuItem>()
    
    private let contentView = UIView()
    private let tableView = UITableView()
    private let mainView = UIView()
    private let closeButton = UIButton()
    private var currentViewController: UIViewController?
    
    
    init(menuItems: Array<MenuItem>) {
        super.init(nibName: nil, bundle: nil)
        self.menuItems = menuItems
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        panGestureRecognizer.addTarget(self, action: #selector(panGesture(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        contentView.frame = CGRect(x: -menuWidth, y: view.frame.origin.x, width: view.frame.width+menuWidth, height: view.frame.height)
        view.addSubview(contentView)
        
        tableView.frame = CGRect(x: 0, y: 0, width: menuWidth, height: view.frame.height)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        contentView.addSubview(tableView)
        
        mainView.frame = CGRect(x: menuWidth, y: 0, width: view.frame.width, height: view.frame.height)
        contentView.addSubview(mainView)
        
        closeButton.frame = CGRect(x: menuWidth, y: 0, width: view.frame.width, height: view.frame.height)
        closeButton.isHidden = true
        closeButton.backgroundColor = .black
        closeButton.alpha = 0
        closeButton.addTarget(self, action: #selector(tapCloseButton(_:)), for: .touchUpInside)
        contentView.addSubview(closeButton)
        
        if menuItems.count > 0 { setContainerItemWithIndex(index: 0) }
    
        NotificationCenter.default.addObserver(self, selector: #selector(menuNotification(_:)), name: OpenSideMenuNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(menuNotification(_:)), name: CloseSideMenuNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChangeNotification(_:)), name: .UIApplicationUserDidTakeScreenshot, object: nil)
    }
    

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func panGesture(_ sender: UIPanGestureRecognizer) {
        if !panGestureEnabled { return }
        
        switch sender.state {
        case .began:
            let locationX = sender.location(in: view).x
            if isOpen || locationX < 50 {
                enablePanOfLocationX = true
            } else {
                enablePanOfLocationX = false
                break
            }
            gestureStartX = contentView.frame.origin.x
            closeButton.isHidden = false
            closeButton.isEnabled = false
            break
        case .changed:
            if !enablePanOfLocationX { break }
            let delay: CGFloat = 5.0
            var distanceX: CGFloat = sender.translation(in: view).x
            if fabs(distanceX) < delay { break }
            distanceX = distanceX < 0 ? distanceX + delay : distanceX - delay
            var sx = gestureStartX + distanceX
            if sx > 0 {
                sx = 0
            } else if sx < -menuWidth {
                sx = -menuWidth
            }
            contentView.frame = CGRect(x: sx, y: 0, width: view.frame.size.width+menuWidth, height: view.frame.size.height)
            closeButton.alpha = ( 1.0 - fabs(sx) / menuWidth ) * 0.4
            break
        case .cancelled, .ended:
            if !enablePanOfLocationX { break }
            closeButton.isEnabled = true
            if isOpen {
                if contentView.frame.origin.x < -menuWidth/5.0 { close () }
                else { open() }
            } else {
                if contentView.frame.origin.x < -menuWidth + menuWidth/5.0 { close () }
                else { open() }
            }
            break
        default: break
        }
    }
    
    @objc func tapCloseButton(_ sender: UIButton) {
        close()
    }
    
    @objc func menuNotification(_ sender: NSNotification) {
        if sender.name == OpenSideMenuNotification {
            open()
        } else if sender.name == CloseSideMenuNotification {
            close()
        }
    }
    
    @objc func orientationChangeNotification(_ sender: NSNotification) {
        if sender.name == .UIApplicationUserDidTakeScreenshot {
            contentView.frame = CGRect(x: -menuWidth, y: view.frame.origin.x, width: view.frame.width+menuWidth, height: view.frame.height)
            mainView.frame = CGRect(x: menuWidth, y: 0, width: view.frame.width, height: view.frame.height)
            closeButton.frame = CGRect(x: menuWidth, y: 0, width: view.frame.width, height: view.frame.height)
        }
    }
    
    func open() {
        panGestureRecognizer.isEnabled = false
        closeButton.isHidden = false
        UIView.animate(withDuration: 0.17, animations: {
            self.contentView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width+self.menuWidth, height: self.view.frame.height)
            self.closeButton.alpha = 0.4
        }, completion: {(finish: Bool) in
            self.isOpen = true
            self.panGestureRecognizer.isEnabled = true
        })
    }
    
    func close() {
        panGestureRecognizer.isEnabled = false
        UIView.animate(withDuration: 0.17, animations: {
            self.contentView.frame = CGRect(x: -self.menuWidth, y: 0, width: self.view.frame.width+self.menuWidth, height: self.view.frame.height)
            self.closeButton.alpha = 0
        }, completion: {(finish: Bool) in
            self.isOpen = false
            self.panGestureRecognizer.isEnabled = true
            self.closeButton.isHidden = true
        })
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        cell?.textLabel?.text = String(describing: type(of: menuItems[indexPath.row].title))
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setContainerItemWithIndex(index: indexPath.row)
    }
    
    func setContainerItemWithIndex(index: Int) {
        currentViewController = nil
        currentViewController = menuItems[index].aClass!.init()
        
        if childViewControllers.count > 0 {
            let beforeVC = childViewControllers.first
            beforeVC?.willMove(toParentViewController: nil)
            beforeVC?.view.removeFromSuperview()
            beforeVC?.removeFromParentViewController()
        }
        if currentViewController != nil {
            addChildViewController(currentViewController!)
            mainView.addSubview((currentViewController?.view)!)
            currentViewController?.didMove(toParentViewController: self)
        }
        
        close()
    }
}


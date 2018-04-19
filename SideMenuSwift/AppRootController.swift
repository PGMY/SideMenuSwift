//
//  AppRootController.swift
//  SideMenuSwift
//
//  Created by PGMY on 2018/04/19.
//  Copyright © 2018年 PGMY. All rights reserved.
//

import UIKit

class AppRootController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tes = MenuItem.createMenuItem(aClass: ViewController.self, title: "てすてす")
        let vc = MenuViewController(menuItems: [tes!])
        view.addSubview(vc.view)
        addChildViewController(vc)
        vc.didMove(toParentViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resomnurces that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

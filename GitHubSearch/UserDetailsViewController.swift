//
//  UserDetailsViewController.swift
//  GitHubSearch
//
//  Created by grzesiek on 09/12/2016.
//  Copyright © 2016 Mateusz Mirkowski. All rights reserved.
//

import UIKit

class UserDetailsViewController: UIViewController {
  
  var userName: String!
  
  init(userName: String) {
    super.init(nibName: nil, bundle: nil)
    self.userName = userName
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

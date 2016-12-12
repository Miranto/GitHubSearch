//
//  UserDetailsViewController.swift
//  GitHubSearch
//
//  Created by grzesiek on 09/12/2016.
//  Copyright © 2016 Mateusz Mirkowski. All rights reserved.
//

import UIKit
import Moya
import RxSwift

class UserDetailsViewController: UIViewController {
  
  var user: GitHubUser!
  let provider = RxMoyaProvider<GitHubApi>()
  let disposeBag = DisposeBag()
  
  init(user: GitHubUser) {
    super.init(nibName: nil, bundle: nil)
    self.user = user
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  override func viewWillAppear(_ animated: Bool) {
    
  }

  
}

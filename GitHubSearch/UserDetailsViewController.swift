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
  
  var user: GitHubUser! {
    didSet {
      print("stars: \(user.numberOfStars)")
      print("followers: \(user.followers)")
      
    }
  }
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
    self.downloadUser(name: user.login)
    self.downloadStarredUser(name: user.login)
  }
  
  func downloadUser(name: String) {
    self.provider.request(.singleUser(username: name))
      .mapObject(GitHubUser.self)
      .subscribe { event -> Void in
        switch event {
        case .next(let response):
          print("success user")
          
          self.user.followers = response.followers
        case .error(let error):
          print(error)
          print("error user")
        default:
          break
        }
      }.addDisposableTo(self.disposeBag)
  }
  
  func downloadStarredUser(name: String) {
    self.provider.request(.starredUser(username: name))
      .subscribe { event -> Void in
        switch event {
        case .next(let response):
          print("success starred")
          let responseDict = try? response.mapJSON() as! [[String: AnyObject]]
          
          self.user.numberOfStars = responseDict?.count ?? 0
        case .error(let error):
          print(error)
          print("error starred")
        default:
          break
        }
    }
    .addDisposableTo(self.disposeBag)
  }
  
}

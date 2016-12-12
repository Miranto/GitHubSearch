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
  
  // MARK: Properties
  @IBOutlet weak var avatar: UIImageView!
  @IBOutlet weak var stars: UILabel!
  @IBOutlet weak var followers: UILabel!
  
  var user: GitHubUser!
  let provider = RxMoyaProvider<GitHubApi>()
  let disposeBag = DisposeBag()
  
  // MARK: Init Methods
  init(user: GitHubUser) {
    super.init(nibName: nil, bundle: nil)
    self.user = user
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Lifecycles Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.setupView()
    self.downloadUserData()
  }
  
  // MARK: View Methods
  func setupView() {
    self.title = self.user.login
    self.followers.text = "Number of followers:"
    self.stars.text = "Number of stars:"
  }
  
  // MARK: Networking Methods
  func downloadUserData() {
    self.downloadFollowingUser(name: user.login)
    self.downloadStarredUser(name: user.login)
    self.downloadUserAvatar(avatarURL: user.avatarUrl)
  }
  
  func downloadFollowingUser(name: String) {
    self.provider.request(.singleUser(username: name))
      .mapObject(GitHubUser.self)
      .subscribe { event -> Void in
        switch event {
        case .next(let response):
          print("success user")

          self.user.followers = response.followers
          self.followers.text  = "Number of followers: \n\(self.user.followers!)"
          self.followers.sizeToFit()
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
          self.stars.text  = "Number of stars: \n\(self.user.numberOfStars!)"
          self.stars.sizeToFit()
        case .error(let error):
          print(error)
          print("error starred")
        default:
          break
        }
    }.addDisposableTo(self.disposeBag)
  }
  
  func downloadUserAvatar(avatarURL: String) {
    self.avatar.setImageFromURl(stringImageUrl: avatarURL)
  }
  
  
}

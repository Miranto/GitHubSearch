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
  
//  var userDetailsViewModel: UserDetailsViewModel
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
//    self.downloadUserData()
    
    let userDetailsViewModel = UserDetailsViewModel(provider: provider, name: user.login!)
    
    userDetailsViewModel.downloadFollowingUser(name: user.login)
      .map{String(describing: "Number of followers:\n\($0.followers!)")}
      .bindTo(self.followers.rx.text)
      .addDisposableTo(self.disposeBag)
    
    userDetailsViewModel.downloadStarredUser(name: user.login)
      .map{String(describing: "Number of stars:\n\($0)")}
      .bindTo(self.stars.rx.text)
      .addDisposableTo(self.disposeBag)
    
    userDetailsViewModel.downloadUserAvatar(avatarURL: user.avatarUrl, completion: {(image) in
      self.avatar.image = image
    })
  }
  
  // MARK: View Methods
  func setupView() {
    self.title = self.user.login
    self.followers.text = "Number of followers:"
    self.stars.text = "Number of stars:"
  }
  
  
}

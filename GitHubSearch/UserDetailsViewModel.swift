//
//  UserDetailsViewModel.swift
//  GitHubSearch
//
//  Created by grzesiek on 13/12/2016.
//  Copyright © 2016 Mateusz Mirkowski. All rights reserved.
//

import Foundation
import Moya
import RxOptional
import RxSwift

struct UserDetailsViewModel {
  
  // MARK: Properties
  let provider: RxMoyaProvider<GitHubApi>
  let disposeBag = DisposeBag()
  let name: String
  
  
  // MARK: Networking Methods
  func downloadFollowingUser(name: String) -> Observable<GitHubUser>{
    return self.provider.request(.singleUser(username: name))
      .mapObject(GitHubUser.self)
  }
  
  func downloadStarredUser(name: String) -> Observable<String> {
    return self.provider.request(.starredUser(username: name))
      .map { event -> String in
        let responseDict = try? event.mapJSON() as! [[String: AnyObject]]
        return String(responseDict?.count ?? 0)
    }
  }

  func downloadUserAvatar(avatarURL: String, completion: @escaping (UIImage) -> Void) {
    completion(self.setImageFromURl(stringImageUrl: avatarURL))
  }

  func setImageFromURl(stringImageUrl url: String) -> UIImage {
    var image: UIImage?
    if let url = URL(string: url) {
      if let data = try? Data(contentsOf: url) {
        image = UIImage(data: data as Data)!
      }
    }
    return image ?? UIImage(named: "placeholder.png")!
  }
  
}

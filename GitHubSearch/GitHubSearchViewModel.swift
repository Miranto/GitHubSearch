//
//  SearchViewModel.swift
//  GitHubSearch
//
//  Created by grzesiek on 13/12/2016.
//  Copyright © 2016 Mateusz Mirkowski. All rights reserved.
//

import Foundation
import Moya
import RxOptional
import RxSwift

class GitHubSearchViewModel {
  
  // MARK: Properties
  let provider: RxMoyaProvider<GitHubApi>
  let disposeBag = DisposeBag()
  
  init(provider: RxMoyaProvider<GitHubApi>) {
    self.provider = provider
  }
  
  // MARK: Networking
  internal func findUsersAndRepos(_ name: String, completion: @escaping ([Any]) -> Void) {
    let group = DispatchGroup()
    var data: [Any] = [Any]()
//    data.removeAll()
    group.enter()
    
    self.provider.request(.users(username: name))
      .map { response -> Response in
        
        guard let responseDict = try? response.mapJSON() as! [String:AnyObject],
          let owner: AnyObject = responseDict["items"],
          let newData = try? JSONSerialization.data(withJSONObject: owner, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return response
        }
        
        let newResponse = Response(statusCode: response.statusCode, data: newData, response: response.response)
        return newResponse
      }
      .mapArray(GitHubUser.self)
      .subscribe { event -> Void in
        switch event {
        case .next(let response):
          print("success user")
          
          response.map{data.append($0)}
          
          group.leave()
          
        case .error(let error):
          print(error)
          print("error user")
        default:
          break
        }
      }.addDisposableTo(self.disposeBag)
    
    group.enter()
    
    self.provider.request(.repos(username: name))
      .map { response -> Response in
        
        guard let responseDict = try? response.mapJSON() as! [String:AnyObject],
          let owner: AnyObject = responseDict["items"],
          let newData = try? JSONSerialization.data(withJSONObject: owner, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return response
        }
        
        let newResponse = Response(statusCode: response.statusCode, data: newData, response: response.response)
        return newResponse
      }
      .mapArray(GitHubRepo.self)
      .subscribe { event -> Void in
        switch event {
        case .next(let response):
          print("success repo")
          
          response.map{data.append($0)}
          
          group.leave()
          
        case .error(let error):
          print(error)
          print("error repo")
        default:
          break
        }
      }.addDisposableTo(self.disposeBag)
    
    group.notify(queue: DispatchQueue.main) {
      completion(data.sorted(by: self.sortResultsAscending))
    }
    
  }
  
  // MARK: Helpers Methods
  func sortResultsAscending(first: Any, next: Any) -> Bool{
    var firstId = 0
    
    if let firstUser = first as? GitHubUser {
      firstId = firstUser.id
    } else if let firstRepo = first as? GitHubRepo {
      firstId = firstRepo.id
    }
    
    var nextId = 0
    if let nextUser = next as? GitHubUser {
      nextId = nextUser.id
    } else if let nextRepo = next as? GitHubRepo {
      nextId = nextRepo.id
    }
    
    return firstId < nextId
  }
  
}

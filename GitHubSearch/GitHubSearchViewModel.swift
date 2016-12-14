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
  func findUsersAndRepos(_ name: String, completion: @escaping ([Any], _ failure: Bool) -> Void) {
    let group = DispatchGroup()
    var data: [Any] = [Any]()
    var limitAPI: Bool = false

    group.enter()
    
    self.findUsers(name: name)
      .subscribe { event -> Void in
        switch event {
        case .next(let response):
          print("success user")
          
          data = [data, response].reduce([],+)
          
          group.leave()
          
        case .error(let error):
          print(error)
          print("error user")
          limitAPI = true
          group.leave()
        default:
          break
        }
      }.addDisposableTo(self.disposeBag)
    
    group.enter()
    
    self.findRepos(name: name)
      .subscribe { event -> Void in
        switch event {
        case .next(let response):
          print("success repo")
          
          data = [data, response].reduce([],+)
          
          group.leave()
          
        case .error(let error):
          print(error)
          print("error repo")
          limitAPI = true
          group.leave()
        default:
          break
        }
      }.addDisposableTo(self.disposeBag)
    
    group.notify(queue: DispatchQueue.main) {
      completion(data.sorted(by: self.sortResultsAscending), limitAPI)
    }
    
  }
  
  func findUsers(name: String) -> Observable<[GitHubUser]> {
    return self.provider.request(.users(username: name))
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
  }
  
  func findRepos(name: String) -> Observable<[GitHubRepo]> {
    return self.provider.request(.repos(username: name))
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

  }
  
  // MARK: Helpers Methods
  func sortResultsAscending(first: Any, next: Any) -> Bool {
    var firstId = 0
    
    switch first {
    case is GitHubUser:
      firstId = (first as! GitHubUser).id
    case is GitHubRepo:
      firstId = (first as! GitHubRepo).id
    default:
      break
    }

    var nextId = 0
    
    switch next {
    case is GitHubUser:
      nextId = (next as! GitHubUser).id
    case is GitHubRepo:
      nextId = (next as! GitHubRepo).id
    default:
      break
    }
    
    return firstId < nextId
  }
  
}

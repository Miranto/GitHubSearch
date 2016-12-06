//
//  ViewController.swift
//  GitHubSearch
//
//  Created by grzesiek on 05/12/2016.
//  Copyright © 2016 Mateusz Mirkowski. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import Moya
import Moya_ObjectMapper

class GitHubSearchViewController: UIViewController {
  
  // MARK: Properties
  @IBOutlet weak var searchTableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  let provider = RxMoyaProvider<GitHubApi>()
  let disposeBag = DisposeBag()
  
  
  // MARK: Lifecycles Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.setupRx()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  func setupRx() {
//    let usersSearchResults = searchBar.rx.text
//      .throttle(0.3, scheduler: MainScheduler.instance)
//      .distinctUntilChanged()
//      .flatMapLatest { query -> Observable<[GitHubUser]> in
//        if (query?.isEmpty)! {
//          return .just([])
//        }
//        
//        return self.findUser(query!)
//          .catchErrorJustReturn([])
//      }
//      .observeOn(MainScheduler.instance)
    
//    usersSearchResults
//      .bindTo(searchTableView.rx.items(cellIdentifier: "userCell")) {
//        (index, user: GitHubUser, cell) in
//        cell.textLabel?.text = user.login
//        //        cell.detailTextLabel?.text = repository.url
//      }
//      .addDisposableTo(disposeBag)
    
    let reposSearchResults = searchBar.rx.text
      .throttle(0.3, scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .flatMapLatest { query -> Observable<[GitHubRepo]> in
        if (query?.isEmpty)! {
          return .just([])
        }
        
        return self.findRepository(query!)
          .catchErrorJustReturn([])
      }
      .observeOn(MainScheduler.instance)
    
//    let merge = Observable.combineLatest(usersSearchResults, reposSearchResults){
//      return $0 + $1
//    }
    
//    let mimi = Observable.merge([usersSearchResults, reposSearchResults])
    
    reposSearchResults
      .bindTo(searchTableView.rx.items(cellIdentifier: "repoCell")) {
        (index, repo: GitHubRepo, cell) in
        cell.textLabel?.text = repo.name
        //        cell.detailTextLabel?.text = repository.url
      }
      .addDisposableTo(disposeBag)
    
//    reposSearchResults
//    .bindTo(searchTableView.rx.item
  }
  
  
  internal func findUser(_ name: String) -> Observable<[GitHubUser]> {
    return self.provider
      .request(.users(username: name))
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
      .asObservable()
  }
  
  internal func findRepository(_ name: String) -> Observable<[GitHubRepo]> {
    return self.provider
      .request(.repos(username: name))
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
      .asObservable()
  }

}


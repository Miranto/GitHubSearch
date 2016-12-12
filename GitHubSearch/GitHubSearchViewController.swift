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
  var data: [Any] = [Any]() {
    didSet {
      print("data count: \(data.count)")
    }
  }
  
  
  // MARK: Lifecycles Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.setupRx()
    self.searchTableView.delegate = self
    self.searchTableView.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.removeSearchTableViewOffset()
  }
  
  func setupRx() {
    searchBar
      .rx.text
      .filterNil()
      .debounce(0.5, scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .filter { $0.characters.count > 0 }
      .subscribe { [unowned self] (query) in
        print(query)
        self.findUsersAndRepos(query.element!)
      }
      .addDisposableTo(disposeBag)
    
    searchBar
      .rx.text
      .filterNil()
      .filter { $0.characters.count == 0 }
      .subscribe {_ in
        self.data.removeAll()
        self.searchTableView.reloadData()
      }
      .addDisposableTo(disposeBag)
  }
  
  
  internal func findUsersAndRepos(_ name: String) {
    let group = DispatchGroup()
    data.removeAll()
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
          
          response.map{self.data.append($0)}

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
          
          response.map{self.data.append($0)}
          
          group.leave()

        case .error(let error):
          print(error)
          print("error repo")
        default:
          break
        }
      }.addDisposableTo(self.disposeBag)
  

    group.notify(queue: DispatchQueue.main) {
      print("group main")
      self.data.sort(by: self.sortResultsAscending)
      self.searchTableView.reloadData()
    }

  }
  
  func removeSearchTableViewOffset() {
    self.searchTableView.contentOffset = CGPoint(x: 0.0, y: 0.0)
    self.searchTableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
  }

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

extension GitHubSearchViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.data.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell: UITableViewCell!
    let cellData = data[indexPath.row]
    
    switch cellData {
    case is GitHubUser:
      cell = tableView.dequeueReusableCell(withIdentifier: "userCell")!
      cell.textLabel?.text = (cellData as! GitHubUser).login
    case is GitHubRepo:
      cell = tableView.dequeueReusableCell(withIdentifier: "repoCell")!
      cell.textLabel?.text = (cellData as! GitHubRepo).name
    default:
      break
    }
    
    return cell
  }
}

extension GitHubSearchViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let cellData = data[indexPath.row]
    
    switch cellData {
    case is GitHubUser:
      print("user cell")
    
      let userDetailsViewController = UserDetailsViewController(user: cellData as! GitHubUser)
      
      self.navigationController?.pushViewController(userDetailsViewController, animated: true)
    default:
      break
    }
    
  }
}

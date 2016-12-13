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
  var searchViewModel: GitHubSearchViewModel!
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
  
  //MARK: Setup RX
  func setupRx() {
    
    searchViewModel = GitHubSearchViewModel(provider: provider)
    
    searchBar
      .rx.text
      .filterNil()
      .debounce(0.5, scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .filter { $0.characters.count > 0 }
      .subscribe { [unowned self] (query) in
        print(query)
        self.searchViewModel.findUsersAndRepos(query.element!, completion: { (data) in
          self.data = data
          self.searchTableView.reloadData()
        })
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
  
  // MARK: Helpers Merhods
  func removeSearchTableViewOffset() {
    self.searchTableView.contentOffset = CGPoint(x: 0.0, y: 0.0)
    self.searchTableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
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

//
//  ViewController.swift
//  GitHubSearch
//
//  Created by grzesiek on 05/12/2016.
//  Copyright © 2016 Mateusz Mirkowski. All rights reserved.
//

import UIKit
import Moya
import Moya_ObjectMapper
import RxSwift
import RxCocoa

class GitHubSearchViewController: UIViewController {
  
  // MARK: Properties
  @IBOutlet weak var searchTableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    let provider = RxMoyaProvider<GitHubApi>()
    
    provider.request(.users(username: "miranto"))
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
          print("success")
          print(response)
          
        //          self.repos = repos
        case .error(let error):
          print(error)
        default:
          break
        }
      }.addDisposableTo(disposeBag)
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}


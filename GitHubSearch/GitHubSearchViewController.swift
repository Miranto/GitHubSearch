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
import Alamofire

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
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}


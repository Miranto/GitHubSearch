//
//  GitHubApi.swift
//  GitHubSearch
//
//  Created by grzesiek on 05/12/2016.
//  Copyright © 2016 Mateusz Mirkowski. All rights reserved.
//

import Foundation
import Moya

let endpointClosure = { (target: GitHubApi) -> Endpoint<GitHubApi> in
  let url = URL(string: target.baseURL.absoluteString + target.path)?.absoluteString
  return Endpoint(url: url!, sampleResponseClosure: { .networkResponse(200, target.sampleData) }, method: target.method, parameters: target.parameters)
}

enum GitHubApi {
  case repos(username: String)
  case users(username: String)
  case singleUser(username: String)
  case starredUser(username: String)
}

extension GitHubApi: TargetType {
  var baseURL: URL { return URL(string: "https://api.github.com")! }
  var path: String {
    switch self {
    case .repos(let name):
      return "/search/repositories?q=\(name)"
    case .users(let name):
      return "/search/users?q=\(name)"
    case .singleUser(let name):
      return "/users/\(name)"
    case .starredUser(let name):
      return "/users/\(name)/starred"
    }
  }
  var method: Moya.Method {
    return .get
  }
  var parameters: [String: Any]? {
    return nil
  }
  var sampleData: Data {
    switch self {
    case .repos(_):
      return "Test data".utf8EncodedData
    case .users(_):
      return "Test data".utf8EncodedData
    case .singleUser(_):
      return "Test data".utf8EncodedData
    case .starredUser(_):
      return "Test data".utf8EncodedData
    }
  }
  var task: Task {
    switch self {
    case .users, .repos, .singleUser, .starredUser:
      return .request
    }
  }
}


// MARK: - Helpers
private extension String {
  var urlEscapedString: String {
    return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
  }
  
  var utf8EncodedData: Data {
    return self.data(using: .utf8)!
  }
}

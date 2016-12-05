//
//  GitHubApi.swift
//  GitHubSearch
//
//  Created by grzesiek on 05/12/2016.
//  Copyright © 2016 Mateusz Mirkowski. All rights reserved.
//

import Foundation
import Moya

enum GitHubApi {
  case repos(username: String)
  case users(username: String)
}

extension GitHubApi: TargetType {
  var baseURL: URL { return URL(string: "https://api.github.com")! }
  var path: String {
    switch self {
    case .repos(let name):
      return "/search/repositories?q=\(name.utf8EncodedData)"
    case .users(let name):
      return "/search/users?q=\(name.utf8EncodedData)"
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
    }
  }
  var task: Task {
    switch self {
    case .users, .repos:
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

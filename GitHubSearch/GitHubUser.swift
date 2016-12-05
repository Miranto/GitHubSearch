//
//  GitHubUser.swift
//  GitHubSearch
//
//  Created by grzesiek on 05/12/2016.
//  Copyright © 2016 Mateusz Mirkowski. All rights reserved.
//

import Foundation
import ObjectMapper

class GitHubUser: Mappable {
  
  var login: String!
  var followers: String?
  var avatarUrl: String!
  
  required init?(map: Map) { }
  
  func mapping(map: Map) {
    print("map user")
    login <- map["login"]
    followers <- map["followers"]
    avatarUrl <- map["avatar_url"]
  }
  
}


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
  
  var id: Int!
  var login: String!
  var followers: Int?
  var avatarUrl: String!
  var numberOfStars: Int?
  
  required init?(map: Map) { }
  
  func mapping(map: Map) {
    id <- map["id"]
    login <- map["login"]
    followers <- map["followers"]
    avatarUrl <- map["avatar_url"]
  }
  
}


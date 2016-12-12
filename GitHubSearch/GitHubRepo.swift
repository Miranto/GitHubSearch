//
//  GitHubSearchUser.swift
//  GitHubSearch
//
//  Created by grzesiek on 05/12/2016.
//  Copyright © 2016 Mateusz Mirkowski. All rights reserved.
//

import Foundation
import ObjectMapper

class GitHubRepo: Mappable {
  
  var id: Int!
  var name: String?
  
  required init?(map: Map) { }
  
  func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
  }
  
}

//
//  UIImageView+ImageFromUrl.swift
//  GitHubSearch
//
//  Created by grzesiek on 12/12/2016.
//  Copyright © 2016 Mateusz Mirkowski. All rights reserved.
//
import UIKit

extension UIImageView{
  
  func setImageFromURl(stringImageUrl url: String){
    
    if let url = URL(string: url) {
      if let data = try? Data(contentsOf: url) {
        self.image = UIImage(data: data as Data)
      }
    }
  }
}

//
//  DataKit.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import AlamofireObjectMapper

private let kConsumerKey = "7B86VYOjohPpneSrQ0lyAsyD02D0mYM0D2f5UNcl"
private let kAPIurl = "https://api.500px.com/v1/"

struct DataKit {
    
    static func get(endPoint: EndPoint, completion: (photos: [Photo], currentPage: Int) -> ()) {
        
        let numberOfItems = 40
        var sizeIds: [Int] = []
        var pageNumber: Int = 0
        
        switch endPoint {
        case .photos(let parameters):
            sizeIds.appendContentsOf(parameters.sizeIds)
            pageNumber = parameters.pageNumber
        }
        
        Alamofire.request(.GET, "\(kAPIurl)\(endPoint.parameter())", parameters:
            [
                EndPointParameters.consumerKey.rawValue: kConsumerKey,
                EndPointParameters.imageSize.rawValue : sizeIds,
                EndPointParameters.numberOfItems.rawValue : numberOfItems,
                EndPointParameters.pageNumber.rawValue : pageNumber
            ]).responseObject { (response: Response<PhotoResponse, NSError>) in
                if let currentPage = response.result.value?.currentPage, photos = response.result.value?.photos {
                    completion(photos: photos, currentPage: currentPage)
                } else {
                    completion(photos: [], currentPage: 1)
                }
        }
    }
}

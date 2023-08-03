//
//  NFTCardViewModelProtocol.swift
//  FakeNFT
//
//  Created by Евгений on 02.08.2023.
//

import Foundation

protocol NFTCardViewModelProtocol: AnyObject {
    var mockNFTImages: [String] { get }
    var mockNFTNames: [String] { get }
    var mockNFTPrices: [String] { get }
}

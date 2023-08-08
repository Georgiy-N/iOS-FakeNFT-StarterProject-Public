//
//  CatalogViewModel.swift
//  FakeNFT
//
//  Created by Евгений on 31.07.2023.
//

import UIKit

final class CatalogViewModel: CatalogViewModelProtocol {
    
    // MARK: - Private Dependencies:
    private var dataProvider: DataProviderProtocol?
    
    // MARK: - Observable Values:
    var nftCollectionsObservable: Observable<NFTCollections?> {
        $nftCollections
    }

    @Observable
    private(set) var nftCollections: NFTCollections?
        
    // MARK: - Lifecycle:
    init(dataProvider: DataProviderProtocol?) {
        self.dataProvider = dataProvider
        fetchCollections()
    }
    
    // MARK: Public Methods:
    func sortNFTCollection(option: SortingOption) {
        guard let nftCollections = nftCollections else { return }
                
        var collection = NFTCollections()
        
        switch option {
        case .byName:
            collection = nftCollections.sorted(by: { $0.name < $1.name })
        case .byQuantity:
            collection = nftCollections.sorted(by: { $0.nfts.count > $1.nfts.count })
        default:
            break
        }
        
        self.nftCollections = collection
    }
    
    func fetchCollections() {
        dataProvider?.fetchNFTCollection(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let collections):
                self.nftCollections = collections
            case .failure(let error):
                print(error)
            }
        })
    }
}

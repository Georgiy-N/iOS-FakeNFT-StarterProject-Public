//
//  RefreshStubLabel.swift
//  FakeNFT
//
//  Created by Евгений on 15.08.2023.
//

import UIKit

final class RefreshStubLabel: UILabel {
    
    // MARK: - Lifecycle:
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods:
    private func setupLabel() {
        textAlignment = .center
        numberOfLines = 2
        text = L10n.General.refreshStub
        textColor = .gray
        font = .captionSmallRegular
    }
}

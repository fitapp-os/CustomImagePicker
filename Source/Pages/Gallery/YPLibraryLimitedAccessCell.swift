//
//  YPLibraryLimitedAccessCell.swift
//  YPImagePicker
//
//  Created by OpenAI Codex on 02/06/2026.
//

import UIKit

final class YPLibraryLimitedAccessCell: UICollectionViewCell {
    private let stackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .center
        v.spacing = 2
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let v = UILabel()
        v.font = .rubikFont(ofSize: 14)
        v.textColor = YPConfig.colors.labelColorPrimary
        v.textAlignment = .center
        v.numberOfLines = 2
        v.adjustsFontSizeToFitWidth = true
        v.minimumScaleFactor = 0.2
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let plusIconView: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "photo.badge.plus"))
        v.tintColor = YPConfig.colors.tintColor
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .ypSecondarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.ypSystemBackground.cgColor
        contentView.clipsToBounds = true

        contentView.subviews(stackView)

        stackView.addArrangedSubview(plusIconView)
        stackView.addArrangedSubview(titleLabel)

        NSLayoutConstraint.activate([
            plusIconView.widthAnchor.constraint(equalToConstant: 35),
            plusIconView.heightAnchor.constraint(equalToConstant: 30),

            stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}

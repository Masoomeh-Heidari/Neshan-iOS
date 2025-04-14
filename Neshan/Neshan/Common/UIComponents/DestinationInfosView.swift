//
//  DestinationInfosView.swift
//  CustomMap
//
//  Created by Bahar on 1/17/1404 AP.
//

import UIKit

class DestinationInfosView: UIView {
    
    var dismissAction: (() -> Void)?
    var onMakeRouteTap: (() -> Void)?
    
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.surfaceColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        return view
    }()
    
    private lazy var destinationNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textColor
        label.textAlignment = .right
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.iranSansMobile(size: 16).font
        return label
    }()
    
    private lazy var destinationIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "mapMarker")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var destinationStreetNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textColor
        label.textAlignment = .right
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.iranSansMobile(size: 16).font
        return label
    }()
    
    
    private lazy var fullDestinationAddressLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.iranSansMobile(size: 16).font
        return label
    }()
    
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textColor
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.iranSansMobile(size: 16).font
        return label
    }()
    
    private lazy var durationIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "mapMarker2")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.lineColor
        return view
    }()
    
    private lazy var addressStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var timeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "close"), for: .normal)
        button.setTitleColor(Colors.actionColor, for: .normal)
        button.addTarget(self, action: #selector(handleDismissButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var makeRouteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("مشاهده مسیرها", for: .normal)
        button.setTitleColor(Colors.backgroundColor, for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = Colors.actionColor
        button.titleLabel?.font = Fonts.iranSansMobile(size: 16).font
        button.addTarget(self, action: #selector(handleMakeRouteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(dismissButton)
        containerView.addSubview(addressStackView)
        containerView.addSubview(makeRouteButton)
        
        addressStackView.addArrangedSubview(destinationNameLabel)
        addressStackView.addArrangedSubview(destinationIconImageView)
        
        containerView.addSubview(destinationStreetNameLabel)
        containerView.addSubview(separatorLine)
        containerView.addSubview(timeStackView)
        
        timeStackView.addArrangedSubview(durationLabel)
        timeStackView.addArrangedSubview(durationIconImageView)
        
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10 ),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            containerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            addressStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            addressStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            addressStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            destinationIconImageView.trailingAnchor.constraint(equalTo: addressStackView.trailingAnchor, constant: -10),
            destinationIconImageView.heightAnchor.constraint(equalToConstant: 32),
            destinationIconImageView.widthAnchor.constraint(equalToConstant: 32),
            
            destinationStreetNameLabel.topAnchor.constraint(equalTo: addressStackView.bottomAnchor, constant: 10),
            destinationStreetNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -55),
            destinationStreetNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            separatorLine.topAnchor.constraint(equalTo: destinationStreetNameLabel.bottomAnchor, constant: 20),
            separatorLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            separatorLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            timeStackView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 20),
            timeStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            timeStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            timeStackView.bottomAnchor.constraint(equalTo: makeRouteButton.topAnchor, constant: -20),
            
            durationIconImageView.trailingAnchor.constraint(equalTo: timeStackView.trailingAnchor, constant: -10),
            durationIconImageView.heightAnchor.constraint(equalToConstant: 24),
            durationIconImageView.widthAnchor.constraint(equalToConstant: 24),
            
            
            dismissButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            dismissButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dismissButton.heightAnchor.constraint(equalToConstant: 18),
            dismissButton.widthAnchor.constraint(equalToConstant: 18),
            
            makeRouteButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            makeRouteButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            makeRouteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            makeRouteButton.heightAnchor.constraint(equalToConstant: 42)
            
        ])
    }
    
    @objc private func handleDismissButtonTapped() {
        dismissAction?()
    }
    
    @objc private func handleMakeRouteButtonTapped() {
        onMakeRouteTap?()
    }
    
    func setDestinationName(_ text: String) {
        destinationNameLabel.text = text
    }
    
    func setDestinationFullAddress(_ text: String) {
        destinationStreetNameLabel.text = "آدرس کامل :  \(text)"
    }
    
    func setDuration(duration: String?, distance: String?) {
        durationLabel.text = "\(distance ?? "") | \(duration ?? "")"
    }
}

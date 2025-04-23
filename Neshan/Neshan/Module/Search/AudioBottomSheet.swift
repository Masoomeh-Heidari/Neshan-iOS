//
//  AudioBottomSheet.swift
//  Neshan
//
//  Created by Spring on 4/22/25.
//
import Combine
import UIKit

class AudioBottomSheet: UIViewController {
    
    let playButton = UIButton()
    let stopButton = UIButton()
    let uploadButton = UIButton()
    let timerLabel = UILabel()

    var playTappedPublisher = PassthroughSubject<Void, Never>()
    var stopTappedPublisher = PassthroughSubject<Void, Never>()
    var uploadTappedPublisher = PassthroughSubject<Void, Never>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        setupViews()
    }

    private func setupViews() {
        playButton.setTitle("Play", for: .normal)
        playButton.setTitleColor(.systemBlue, for: .normal)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)

        stopButton.setTitle("Stop", for: .normal)
        stopButton.setTitleColor(.systemRed, for: .normal)
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)

        uploadButton.setTitle("upload Voice", for: .normal)
        uploadButton.setTitleColor(.systemRed, for: .normal)
        uploadButton.addTarget(self, action: #selector(uploadTapped), for: .touchUpInside)
        
        timerLabel.text = "00:00"
        timerLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [timerLabel, playButton, stopButton, uploadButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func playTapped() {
        playTappedPublisher.send()
    }

    @objc func stopTapped() {
        stopTappedPublisher.send()
    }

    @objc func uploadTapped() {
        uploadTappedPublisher.send()
    }
    
    func updateTimerLabel(with text: String) {
        timerLabel.text = text
    }
}

//
//  ViewController.swift
//  Swann Video Streaming
//
//  Created by Raj Patel on 20/02/20.
//  Copyright © 2020 Raj Patel. All rights reserved.
//

import UIKit
import AVKit

class StreamsViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadScreenLinks()
        setSwipeGestures()
        setTapGesture()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            for view in self.views {
                view.layer.sublayers?[0].frame = self.playerView.bounds
            }
        }
    }
    
    private func setSwipeGestures() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        leftSwipe.direction = .left
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        rightSwipe.direction = .right
        playerView.addGestureRecognizer(leftSwipe)
        playerView.addGestureRecognizer(rightSwipe)
    }
    
    private func setTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        playerView.addGestureRecognizer(tap)
    }
    
    @objc func swipeLeft() {
        if segmentedControl.selectedSegmentIndex < 2 {
            segmentedControl.selectedSegmentIndex = segmentedControl.selectedSegmentIndex + 1
            segmentChanged(segmentedControl)
        }
    }
    
    @objc func swipeRight() {
        if segmentedControl.selectedSegmentIndex > 0 {
            segmentedControl.selectedSegmentIndex = segmentedControl.selectedSegmentIndex - 1
            segmentChanged(segmentedControl)
        }
    }
    
    @objc func tapped() {
        segmentedControl.isHidden = !segmentedControl.isHidden
    }
    private func players(with screens: Screens?) {
        DispatchQueue.main.async {
            self.setupAVPlayer(URL(string: screens?.screen1 ?? ""))
            self.setupAVPlayer(URL(string: screens?.screen2 ?? ""))
            self.setupAVPlayer(URL(string: screens?.screen3 ?? ""))
            self.streamChanged(to: 0)
        }
    }
    private func downloadScreenLinks() {
        Service().getScreenLinks {[weak self] (screens) in
            self?.players(with: screens)
        }
    }
    
    private func setupAVPlayer(_ url: URL?) {
        guard let url = url else { return }
        let player = AVPlayer(url: url)
        layer = AVPlayerLayer(player: player)
        layer?.frame = self.playerView.bounds
        let view = UIView()
        guard let layer = layer else { return }
        view.layer.addSublayer(layer)
        views.append(view)
        playerView.addSubview(view)
    }
    
    private func playCurrentStream(at screenView: UIView) {
        for view in views {
            guard let avLayer =  view.layer.sublayers?[0] as? AVPlayerLayer else { return }
            if view == screenView {
                avLayer.player?.play()
            } else {
                avLayer.player?.pause()
            }
        }
    }
    
    private func streamChanged(to screen: Int) {
        if screen == 0 {
            playerView.bringSubviewToFront(views[0])
            playCurrentStream(at: views[0])
        }
        if screen == 1 {
            playerView.bringSubviewToFront(views[1])
            playCurrentStream(at: views[1])
        }
        if screen == 2 {
            playerView.bringSubviewToFront(views[2])
            playCurrentStream(at: views[2])

        }
    }


    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var playerView: UIView!
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        streamChanged(to: sender.selectedSegmentIndex)
    }
    @IBAction func buttonTapped(_ sender: UIButton) {
    }
    
    private var links: Screens?
    private var views = [UIView]()
    private var layer: AVPlayerLayer?
}

import UIKit
import AVKit


enum ScreenNum: Int {
    case Screen1 = 0
    case Screen2 = 1
    case Screen3 = 2
}

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
        settingsButton.isHidden = !settingsButton.isHidden
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
        switch(screen) {
        case ScreenNum.Screen1.rawValue:
            playerView.bringSubviewToFront(views[ScreenNum.Screen1.rawValue])
            playCurrentStream(at: views[ScreenNum.Screen1.rawValue])
        case ScreenNum.Screen2.rawValue:
            playerView.bringSubviewToFront(views[ScreenNum.Screen2.rawValue])
            playCurrentStream(at: views[ScreenNum.Screen2.rawValue])
        case ScreenNum.Screen3.rawValue:
            playerView.bringSubviewToFront(views[ScreenNum.Screen3.rawValue])
            playCurrentStream(at: views[ScreenNum.Screen3.rawValue])
        default:
            break
        }
    }

    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        streamChanged(to: sender.selectedSegmentIndex)
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        let controller = SettingsViewController()
        self.present(controller, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var playerView: UIView!
    
    private var links: Screens?
    private var views = [UIView]()
    private var layer: AVPlayerLayer?
}

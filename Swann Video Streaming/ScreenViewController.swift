import UIKit
import AVKit

class ScreenViewController: UIViewController {
    
    //to ensure every screenviewcontroller is initialised with a screen object
    init(with screen: Screen) {
        self.screen = screen
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var index: Int?
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        setupAVPlayer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.view.layer.sublayers?.first?.frame = self.view.bounds
        }
    }
    
    private func setupAVPlayer() {
        guard let url = URL(string: self.screen.url) else { return }
        let avPlayer = AVPlayer(url: url)
        let layer = AVPlayerLayer(player: avPlayer)
        layer.frame = self.view.bounds
        let childView = UIView()
        player = avPlayer
        view.layer.addSublayer(layer)
        self.view.addSubview(childView)
    }
    
    private let screen: Screen
}

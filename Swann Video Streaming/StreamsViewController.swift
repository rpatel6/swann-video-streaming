import UIKit
import AVKit

//Caveat: Dark mode handling is done naively, simply by setting the background colors

class StreamsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        downloadScreenLinks()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    private func downloadScreenLinks() {
        Service().getScreenLinks {[weak self] (screens) in
            guard let screens = screens else { return }
            DispatchQueue.main.async {
                self?.setupPageViewController(with: screens)
                self?.setupPageControl()
                self?.setupSettingsButton()
            }
        }
    }
    
    private func setupPageControl() {
        self.pageControl.numberOfPages = videoStreams.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.darkGray
        self.pageControl.pageIndicatorTintColor = UIColor.darkGray
        self.pageControl.currentPageIndicatorTintColor = UIColor.white
        //Scaled up the control ui for better visibility
        self.pageControl.transform = CGAffineTransform(scaleX: 2, y: 2)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(pageControl)
        guard let content = self.view else { return }
        self.view.addConstraint(NSLayoutConstraint(item: content, attribute: .bottom, relatedBy: .equal, toItem: pageControl, attribute: .bottom, multiplier: 1.0, constant: 42))
        self.view.addConstraint(NSLayoutConstraint(item: content, attribute: .trailing, relatedBy: .equal, toItem: pageControl, attribute: .trailing, multiplier: 1.0, constant: 8))
        self.view.addConstraint(NSLayoutConstraint(item: content, attribute: .leading, relatedBy: .equal, toItem: pageControl, attribute: .leading, multiplier: 1.0, constant: 8))
    }
    
    private func setupSettingsButton() {
        settingsButton.setBackgroundImage(#imageLiteral(resourceName: "settings"), for: .normal)
        settingsButton.tintColor = .white
        settingsButton.addTarget(self, action: #selector(buttonTapped), for: .touchDown)
        
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        settingsButton.widthAnchor.constraint(equalToConstant: 50).isActive = true

        self.view.addSubview(settingsButton)
        guard let content = self.view else { return }
        self.view.addConstraint(NSLayoutConstraint(item: content, attribute: .trailingMargin, relatedBy: .equal, toItem: settingsButton, attribute: .trailing, multiplier: 1.0, constant: 16))
        self.view.addConstraint(NSLayoutConstraint(item: content, attribute: .topMargin, relatedBy: .equal, toItem: settingsButton, attribute: .top, multiplier: 1.0, constant: -16))
    }
    
    private func setupPageViewController(with screens: [Screen]) {
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        controller.delegate = self
        controller.dataSource = self
        addChild(controller)
        self.view.addSubview(controller.view)
        
        videoStreams = screens.compactMap {
            let controller = ScreenViewController(with: $0)
            return controller
        }
        guard let firstScreen = videoStreams.first else { return }
        firstScreen.index = currentIndex
        controller.setViewControllers([firstScreen], direction: .forward, animated: true) { completed in
            if completed {
                firstScreen.player?.play()
            }
        }
    }
    
    //Handles logic to show and hide the controls and settings button
    @objc func screenTapped() {
        settingsButton.isHidden = !settingsButton.isHidden
        pageControl.isHidden = !pageControl.isHidden
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        let controller = SettingsViewController()
        self.present(controller, animated: true, completion: nil)
    }
    
    var pageControl: UIPageControl = UIPageControl()
    var settingsButton: UIButton = UIButton()
    private var currentIndex = 0
    private var videoStreams: [ScreenViewController] = []
    
}

extension StreamsViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard viewController is ScreenViewController,
            let currentController = viewController as? ScreenViewController,
            let index = currentController.index else {
                return nil
        }
                
        let previousIndex = index - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        currentIndex = previousIndex
        let controller = videoStreams[previousIndex]
        controller.index = previousIndex
        return controller
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard viewController is ScreenViewController,
            let currentController = viewController as? ScreenViewController,
            let index = currentController.index else {
                return nil
        }
        
        let nextIndex = index + 1
        
        guard nextIndex < videoStreams.count  else {
            return nil
        }
        currentIndex = nextIndex
        let controller = videoStreams[nextIndex]
        controller.index = nextIndex
        return controller
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        //Pause the previous screen's video if animation was completed and play the next screen's video
        guard completed == true else {
            return
        }
        guard let screenView =  previousViewControllers.first as? ScreenViewController,
            let currentScreen = pageViewController.viewControllers?.first as? ScreenViewController else {
            return
        }
        pageControl.currentPage = currentScreen.index ?? 0
        screenView.player?.pause()
        currentScreen.player?.play()
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        //One of the views' orientation needs to be fixed using `pageViewController` bounds (There maybe a better way of doing this)
        guard let screen = pendingViewControllers.first else {
            return
        }
        screen.view.layer.sublayers?.first?.frame = pageViewController.view.bounds
    }
}

import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private var splashOverlay: UIImageView?

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    showSplashOverlay()
  }

  override func sceneWillResignActive(_ scene: UIScene) {
    showSplashOverlay()
    super.sceneWillResignActive(scene)
  }

  override func sceneDidEnterBackground(_ scene: UIScene) {
    showSplashOverlay()
    super.sceneDidEnterBackground(scene)
  }

  override func sceneWillEnterForeground(_ scene: UIScene) {
    super.sceneWillEnterForeground(scene)
    showSplashOverlay()
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)

    // iOS'un eski login karesini göstermesine fırsat vermeden Flutter'ın
    // ilk splash karesinin hazırlanmasını bekle.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
      self?.hideSplashOverlay()
    }
  }

  private func showSplashOverlay() {
    guard splashOverlay == nil,
          let window,
          let image = UIImage(named: "SplashBackground") else {
      return
    }

    let imageView = UIImageView(frame: window.bounds)
    imageView.image = image
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.backgroundColor = UIColor(
      red: 91.0 / 255.0,
      green: 92.0 / 255.0,
      blue: 226.0 / 255.0,
      alpha: 1.0
    )
    imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    window.addSubview(imageView)
    splashOverlay = imageView
  }

  private func hideSplashOverlay() {
    splashOverlay?.removeFromSuperview()
    splashOverlay = nil
  }

}

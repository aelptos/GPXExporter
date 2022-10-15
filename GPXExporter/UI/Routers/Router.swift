//
//  Copyright © Aelptos. All rights reserved.
//

import UIKit
import HealthKit

protocol RouterProtocol {
    func showDetail(for workout: HKWorkout, healtKitHelper: HealthKitHelperProtocol)
    func showError(_ message: String)
    func showShare(for path: URL)
    func showInfo()
    func hideInfo()
}

final class Router {
    private let navigationController: UINavigationController
    private var isShowingProgres = false

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

extension Router: RouterProtocol {
    func showDetail(for workout: HKWorkout, healtKitHelper: HealthKitHelperProtocol) {
        let presenter = DetailPresenter(
            router: self,
            healthKitHelper: healtKitHelper,
            workout: workout
        )
        let controller = DetailViewControllerMapBox(
            presenter: presenter
        )
        presenter.view = controller
        navigationController.pushViewController(
            controller,
            animated: true
        )
    }

    func showError(_ message: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: "error".localized, message: message, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "ok".localized, style: .default))
            self.navigationController.present(controller, animated: true)
        }
    }

    func showShare(for path: URL) {
        let controller = UIActivityViewController(activityItems: [path], applicationActivities: [])
        navigationController.present(controller, animated: true)
    }

    func showInfo() {
        let presenter = InfoPresenter(
            router: self
        )
        let controller = InfoViewController(
            presenter: presenter
        )
        presenter.view = controller
        let nav = UINavigationController(rootViewController: controller)
        navigationController.present(nav, animated: true)
    }

    func hideInfo() {
        navigationController.dismiss(animated: true)
    }
}

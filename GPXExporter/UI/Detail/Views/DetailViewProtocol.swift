//
//  Copyright © Aelptos. All rights reserved.
//

import Foundation
import HealthKit
import CoreLocation

protocol DetailViewProtocol: AnyObject {
    func prepareView(with workout: HKWorkout)
    func update(with locations: [CLLocation])
    func showExportButton()
}

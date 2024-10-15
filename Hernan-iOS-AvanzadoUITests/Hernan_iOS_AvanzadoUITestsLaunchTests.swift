//
//  Hernan_iOS_AvanzadoUITestsLaunchTests.swift
//  Hernan-iOS-AvanzadoUITests
//
//  Created by Hernán Rodríguez on 11/10/24.
//

import XCTest

final class Hernan_iOS_AvanzadoUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

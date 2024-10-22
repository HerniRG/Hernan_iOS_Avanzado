//
//  MapViewModelTests.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 22/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado
import MapKit

final class MapViewModelTests: XCTestCase {
    
    var sut: MapViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MapViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func test_InitialState() {
        // Verificar que el estado inicial es loading
        XCTAssertEqual(sut.status.value, .loading)
        XCTAssertTrue(sut.annotations.isEmpty, "Las anotaciones deberían estar vacías al inicio.")
    }
    
    func test_LoadAnnotations_UpdatesStatus() {
        // Dado unas anotaciones de prueba
        let annotation1 = HeroAnnotation(coordinate: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917), title: "Tokyo", subtitle: "Japan")
        let annotation2 = HeroAnnotation(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), title: "Los Angeles", subtitle: "USA")
        
        // Crear una expectativa
        let expectation = self.expectation(description: "Load annotations should update status")

        // Cuando se cargan las anotaciones
        sut.loadAnnotations([annotation1, annotation2])
        
        // Usamos DispatchQueue para asegurarnos de que la comprobación ocurre en el hilo principal
        DispatchQueue.main.async {
            // Entonces: El estado debe ser success y las anotaciones deben estar actualizadas
            XCTAssertEqual(self.sut.status.value, .success, "El estado debería ser success después de cargar las anotaciones.")
            XCTAssertEqual(self.sut.annotationCount, 2, "El conteo de anotaciones debería ser 2.")
            XCTAssertEqual(self.sut.firstAnnotation?.title, annotation1.title, "La primera anotación debería ser 'Tokyo'.")
            
            // Cumplir la expectativa
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1) // Espera a que se cumpla la expectativa
    }

    
    // Test para cambiar el tipo de mapa
    func test_ToggleMapType_ChangesMapType() {
        let expectation = self.expectation(description: "Toggle map type changes map type")

        // Cuando se cambia el tipo de mapa
        let initialType = sut.toggleMapType()
        XCTAssertEqual(initialType, MKMapType.satellite)

        let nextType = sut.toggleMapType()
        XCTAssertEqual(nextType, MKMapType.hybrid)

        let finalType = sut.toggleMapType()
        XCTAssertEqual(finalType, MKMapType.standard)

        let resetType = sut.toggleMapType()
        XCTAssertEqual(resetType, MKMapType.satellite)

        expectation.fulfill() // Marca la expectativa como cumplida
        wait(for: [expectation], timeout: 1) // Espera a que se cumpla la expectativa
    }

    // Test para obtener la siguiente anotación
    func test_NextAnnotation_ReturnsCorrectAnnotation() {
        // Dado unas anotaciones de prueba
        let annotation1 = HeroAnnotation(coordinate: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917), title: "Tokyo", subtitle: "Japan")
        let annotation2 = HeroAnnotation(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), title: "Los Angeles", subtitle: "USA")
        
        sut.loadAnnotations([annotation1, annotation2])

        // Cuando se obtiene la siguiente anotación
        let expectation = self.expectation(description: "Next annotation returns correct annotation")

        let nextAnnotation = sut.nextAnnotation()

        // Entonces: Verificar que se obtiene la primera anotación
        XCTAssertEqual(nextAnnotation?.title, annotation2.title)

        // Obtener la siguiente anotación
        let nextAnnotationAgain = sut.nextAnnotation()

        // Entonces: Verificar que se obtiene la segunda anotación
        XCTAssertEqual(nextAnnotationAgain?.title, annotation1.title)

        expectation.fulfill() // Marca la expectativa como cumplida
        wait(for: [expectation], timeout: 1) // Espera a que se cumpla la expectativa
    }

    // Test para el contador de anotaciones
    func test_AnnotationCount_ReturnsCorrectCount() {
        // Dado unas anotaciones de prueba
        let annotation1 = HeroAnnotation(coordinate: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917), title: "Tokyo", subtitle: "Japan")
        let annotation2 = HeroAnnotation(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), title: "Los Angeles", subtitle: "USA")
        
        sut.loadAnnotations([annotation1, annotation2])

        // Entonces: Verificar que el contador de anotaciones es correcto
        XCTAssertEqual(sut.annotationCount, 2)
    }
}

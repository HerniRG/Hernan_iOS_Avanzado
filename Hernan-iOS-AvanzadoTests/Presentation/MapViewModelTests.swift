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
        // Configuración inicial del ViewModel para los tests
        try super.setUpWithError()
        sut = MapViewModel()
    }
    
    override func tearDownWithError() throws {
        // Limpieza de las instancias después de cada test
        sut = nil
        try super.tearDownWithError()
    }
    
    /// Test que verifica que el estado inicial es correcto
    func test_InitialState() {
        // Verificamos que el estado inicial sea loading y que no haya anotaciones cargadas
        XCTAssertEqual(sut.status.value, .loading)
        XCTAssertTrue(sut.annotations.isEmpty, "Las anotaciones deberían estar vacías al inicio.")
    }
    
    /// Test que verifica que el estado y las anotaciones se actualizan correctamente
    func test_LoadAnnotations_UpdatesStatus() {
        // Given: Se crean anotaciones de prueba
        let annotation1 = HeroAnnotation(coordinate: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917), title: "Tokyo", subtitle: "Japan")
        let annotation2 = HeroAnnotation(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), title: "Los Angeles", subtitle: "USA")
        
        // Creamos una expectativa para esperar que el estado y las anotaciones se actualicen
        let expectation = self.expectation(description: "Load annotations should update status")
        
        // When: Se cargan las anotaciones en el ViewModel
        sut.loadAnnotations([annotation1, annotation2])
        
        // Usamos DispatchQueue para asegurar que se realice en el hilo principal
        DispatchQueue.main.async {
            // Then: Verificamos que el estado es success y las anotaciones se han actualizado correctamente
            XCTAssertEqual(self.sut.status.value, .success, "El estado debería ser success después de cargar las anotaciones.")
            XCTAssertEqual(self.sut.annotationCount, 2, "El conteo de anotaciones debería ser 2.")
            XCTAssertEqual(self.sut.firstAnnotation?.title, annotation1.title, "La primera anotación debería ser 'Tokyo'.")
            
            expectation.fulfill() // Indicamos que la operación ha terminado
        }
        
        // Esperamos a que se cumpla la expectativa
        wait(for: [expectation], timeout: 1)
    }
    
    /// Test que verifica que el tipo de mapa cambia correctamente
    func test_ToggleMapType_ChangesMapType() {
        // Creamos una expectativa para la transición del tipo de mapa
        let expectation = self.expectation(description: "Toggle map type changes map type")
        
        // When: Se cambia el tipo de mapa
        let initialType = sut.toggleMapType()
        XCTAssertEqual(initialType, MKMapType.satellite)
        
        let nextType = sut.toggleMapType()
        XCTAssertEqual(nextType, MKMapType.hybrid)
        
        let finalType = sut.toggleMapType()
        XCTAssertEqual(finalType, MKMapType.standard)
        
        let resetType = sut.toggleMapType()
        XCTAssertEqual(resetType, MKMapType.satellite)
        
        expectation.fulfill() // Indicamos que la operación ha terminado
        wait(for: [expectation], timeout: 1)
    }
    
    /// Test que verifica que se obtiene la anotación correcta con nextAnnotation
    func test_NextAnnotation_ReturnsCorrectAnnotation() {
        // Given: Se crean anotaciones de prueba
        let annotation1 = HeroAnnotation(coordinate: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917), title: "Tokyo", subtitle: "Japan")
        let annotation2 = HeroAnnotation(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), title: "Los Angeles", subtitle: "USA")
        
        sut.loadAnnotations([annotation1, annotation2])
        
        // Creamos una expectativa para esperar el cambio de anotación
        let expectation = self.expectation(description: "Next annotation returns correct annotation")
        
        // When: Se obtiene la siguiente anotación
        let nextAnnotation = sut.nextAnnotation()
        
        // Then: Verificamos que se obtiene la anotación correcta
        XCTAssertEqual(nextAnnotation?.title, annotation2.title)
        
        // Cuando se obtiene la siguiente anotación nuevamente
        let nextAnnotationAgain = sut.nextAnnotation()
        
        // Verificamos que vuelve a la primera anotación
        XCTAssertEqual(nextAnnotationAgain?.title, annotation1.title)
        
        expectation.fulfill() // Indicamos que la operación ha terminado
        wait(for: [expectation], timeout: 1)
    }
    
    /// Test que verifica que el contador de anotaciones es correcto
    func test_AnnotationCount_ReturnsCorrectCount() {
        // Given: Se crean anotaciones de prueba
        let annotation1 = HeroAnnotation(coordinate: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917), title: "Tokyo", subtitle: "Japan")
        let annotation2 = HeroAnnotation(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), title: "Los Angeles", subtitle: "USA")
        
        sut.loadAnnotations([annotation1, annotation2])
        
        // Then: Verificamos que el contador de anotaciones es el esperado
        XCTAssertEqual(sut.annotationCount, 2)
    }
}

//
//  Hernan_iOS_AvanzadoTests.swift
//  Hernan-iOS-AvanzadoTests
//
//  Created by Hernán Rodríguez on 11/10/24.
//

import XCTest
@testable import Hernan_iOS_Avanzado

/// Tests para el Store de Core Data y su extensión
final class StoreProviderTests: XCTestCase {
    
    var sut: StoreDataProvider!
    
    /// Inicializamos `sut` en cada test
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Usamos persistencia en memoria para los tests
        sut = StoreDataProvider(persistency: .inMemory)
    }
    
    /// Eliminamos `sut` al finalizar cada test
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    /// Test que verifica que se añaden héroes correctamente y se pueden recuperar
    func test_addHeroes_shouldReturnTheItemsInserted() throws {
        // Given: Se almacena el número inicial de héroes y se crea un `ApiHero`
        let initialCount = sut.fetchHeroes(filter: nil).count
        let apiHero = ApiHero(id: "123", name: "name", description: "description", photo: "photo", favorite: false)
        
        // When: Se añade el héroe al store
        sut.add(heroes: [apiHero])
        let heroes = sut.fetchHeroes(filter: nil)
        let finalCount = heroes.count
        
        // Then: Verificamos que el número de héroes ha aumentado y que los datos del héroe son correctos
        XCTAssertEqual(finalCount, initialCount + 1)
        let hero = try XCTUnwrap(heroes.first)  // Verificamos que no sea nil
        XCTAssertEqual(hero.id, apiHero.id)
        XCTAssertEqual(hero.name, apiHero.name)
        XCTAssertEqual(hero.info, apiHero.description)
        XCTAssertEqual(hero.photo, apiHero.photo)
        XCTAssertEqual(hero.favorite, apiHero.favorite)
    }
    
    /// Test que verifica que los héroes se recuperan en orden ascendente por nombre
    func test_fetchHeroes_ShouldBeSortedAsc() throws {
        // Given: Se crean dos héroes con nombres en diferente orden alfabético
        let initialCount = sut.fetchHeroes(filter: nil).count
        let apiHero = ApiHero(id: "123", name: "Luis", description: "description", photo: "photo", favorite: true)
        let apiHero2 = ApiHero(id: "1234", name: "Alberto", description: "description", photo: "photo", favorite: false)
        
        // When: Se añaden los héroes y se recuperan
        sut.add(heroes: [apiHero, apiHero2])
        let heroes = sut.fetchHeroes(filter: nil)
        
        // Then: Verificamos que el número inicial de héroes era 0, y que los héroes se ordenan alfabéticamente
        XCTAssertEqual(initialCount, 0)
        let hero = try XCTUnwrap(heroes.first)
        XCTAssertEqual(hero.id, apiHero2.id)
        XCTAssertEqual(hero.name, apiHero2.name)
        XCTAssertEqual(hero.info, apiHero2.description)
        XCTAssertEqual(hero.photo, apiHero2.photo)
        XCTAssertEqual(hero.favorite, apiHero2.favorite)
    }
    
    /// Test que verifica que se añaden ubicaciones y se asocian correctamente con un héroe
    func test_addLocations_ShouldInsertLocationAndAssociateHero() throws {
        // Given: Se crea un héroe y una ubicación asociada a ese héroe
        let apiHero = ApiHero(id: "123", name: "Luis", description: "description", photo: "photo", favorite: true)
        let apiLocation = ApiLocation(id: "id", date: "date", latitude: "0000", longitude: "11111", hero: apiHero)
        
        // When: Se añaden el héroe y la ubicación al store
        sut.add(heroes: [apiHero])
        sut.add(locations: [apiLocation])
        let heroes = sut.fetchHeroes(filter: nil)
        let hero = try XCTUnwrap(heroes.first)
        
        // Then: Verificamos que la ubicación está correctamente asociada al héroe
        XCTAssertEqual(hero.locations?.count, 1)
        let location = try XCTUnwrap(hero.locations?.first)
        XCTAssertEqual(location.id, apiLocation.id)
        XCTAssertEqual(location.date, apiLocation.date)
        XCTAssertEqual(location.latitude, apiLocation.latitude)
        XCTAssertEqual(location.longitude, apiLocation.longitude)
        XCTAssertEqual(location.hero?.id, hero.id)
    }
}

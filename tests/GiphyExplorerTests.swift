//
//  GiphyExplorerTests.swift
//  GiphyExplorerTests
//
//  Created by RqwerKnot on 07/06/2022.
//

import XCTest

// In order to get access to our code, without having to make all
// of our types and functions public, we can use the @testable
// keyword to also import all internal symbols from our app target.
@testable import GiphyExplorer

class SearchTests: XCTestCase {
    
    private var contentViewModel: ContentView.ContentViewModel!

    @MainActor override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        contentViewModel = ContentView.ContentViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor func testTrendingLaunch() {
        // Given: Here we assert that our initial state is correct
        XCTAssertEqual(contentViewModel.userSearchText, "")
        XCTAssertEqual(contentViewModel.gridViewModel.selectedGif, nil)
        XCTAssertEqual(contentViewModel.gridViewModel.endpoint.query, "")
    }
    
    @MainActor func testNewUserSearchIsDifferent() {
        // Given
        let oldSearch = ""
        let newSearch = "abc"

        // When
        let query = contentViewModel.newQuery(using: oldSearch, and: newSearch)

        // Then
        XCTAssertEqual(query, "abc")
    }
    
    @MainActor func testNewUserSearchIsSimilar() {
        // Given
        let oldSearch = "abc"
        let newSearch = "abc     "

        // When
        let newQuery = contentViewModel.newQuery(using: oldSearch, and: newSearch)

        // Then
        XCTAssertEqual(newQuery, nil)
    }
    
    @MainActor func testNewSearch() async throws {
        // Given: Here we assert that our initial state is correct
        XCTAssertEqual(contentViewModel.userSearchText, "")
        XCTAssertEqual(contentViewModel.gridViewModel.endpoint.query, "")
        
        // When
        contentViewModel.userSearchText = "abc"
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Then
        XCTAssertEqual(contentViewModel.gridViewModel.endpoint.query, "abc")
    }
    
    @MainActor func testSearchBouncing() async throws {
        // Given: Here we assert that our initial state is correct
        XCTAssertEqual(contentViewModel.userSearchText, "")
        XCTAssertEqual(contentViewModel.gridViewModel.endpoint.query, "")
        
        // When
        contentViewModel.userSearchText = "a"
        try await Task.sleep(nanoseconds: 200_000_000)
        contentViewModel.userSearchText = "ab"
        try await Task.sleep(nanoseconds: 200_000_000)
        contentViewModel.userSearchText = "abc"
        try await Task.sleep(nanoseconds: 200_000_000)
        contentViewModel.userSearchText = "abcd"
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        XCTAssertEqual(contentViewModel.gridViewModel.endpoint.query, "")
        try await Task.sleep(nanoseconds: 2_000_000_000)
        XCTAssertEqual(contentViewModel.gridViewModel.endpoint.query, "abcd")
    }

//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}

class GridTests: XCTestCase {
    
    private var gridViewModel: GridViewModel!

    @MainActor override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        gridViewModel = GridViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor func testUpdatingQueryUpdatesEndpointQuery() async {
        // Given: Here we assert that our initial state is correct
        XCTAssertEqual(gridViewModel.endpoint.query, "")

        // When
        gridViewModel.updateWith("abc")

        // Then
        XCTAssertEqual(gridViewModel.endpoint.query, "abc")
    }
    
    @MainActor func testForcingMoreContentWhenTaskIsFreeWorks() async throws {
        // Given: Here we assert that our initial state is correct
        XCTAssertEqual(gridViewModel.endpoint.query, "")
        try await Task.sleep(nanoseconds: 5_000_000_000)
        
        // When
        gridViewModel.loadMoreContentIfNeeded()

        // Then
        XCTAssertTrue(gridViewModel.isLoading)
    }
    
}

class GifLoaderTest: XCTestCase {
    
    private var loader : GifDataLoader!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        loader = GifDataLoader()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNilUrlReturnsNil() async {
        // Given: Here we assert that our initial state is correct
        let images = GifObject.ImagesObject(fixedWidthSmall: GifObject.RenditionObject(url: "invalidUrl", width: "50", height: "50", mp4: nil, webp: nil), downsized: GifObject.RenditionObject(url: "invalidUrl", width: "50", height: "50", mp4: nil, webp: nil))
        let gifObject = GifObject(type: "gif", id: "lihvefopah", username: "John Doe", images: images)

        // When
        let gifData = await loader.loadGifData(for: gifObject)

        // Then
        XCTAssertEqual(gifData, nil)
    }
    
    func testUrlIsInvalidReturnsNil() async {
        // Given: Here we assert that our initial state is correct
        let images = GifObject.ImagesObject(fixedWidthSmall: GifObject.RenditionObject(url: "invalidUrl", width: "50", height: "50", mp4: nil, webp: "https://invalidurl.com"), downsized: GifObject.RenditionObject(url: "invalidUrl", width: "50", height: "50", mp4: nil, webp: nil))
        let gifObject = GifObject(type: "gif", id: "lihvefopah", username: "John Doe", images: images)

        // When
        let gifData = await loader.loadGifData(for: gifObject)

        // Then
        XCTAssertEqual(gifData, nil)
    }
}

class ImageLoaderTest: XCTestCase {
    
    private var loader : ImageLoader!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        loader = ImageLoader()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testURLRequestIsInvalid() async throws {
        // Given: Here we assert that our initial state is correct
        let url = URL(string: "https://invalidurl.com")!
        var imageData: ImageLoader.ImageData?
        
        // When
        do {
            imageData = try await loader.fetch(url)
        } catch {
            
        }
        
        // Then
        XCTAssertNil(imageData)
    }
}

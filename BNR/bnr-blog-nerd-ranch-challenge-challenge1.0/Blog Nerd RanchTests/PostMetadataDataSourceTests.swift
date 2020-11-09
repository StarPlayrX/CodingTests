//
//  PostMetadataDataSourceTests.swift
//  Blog Nerd RanchTests
//
//  Created by Chris Downie on 8/28/18.
//  Copyright © 2018 Chris Downie. All rights reserved.
//

@testable import Blog_Nerd_Ranch
import XCTest

class PostMetadataDataSourceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOrderWithNoPosts() {
        let ordering = DisplayOrdering(grouping: .none, sorting: .byPublishDate(recentFirst: false))
        
        let dataSource = PostMetadataDataSource(ordering: ordering)
        
        XCTAssertEqual(dataSource.numberOfSections(), 1)
        XCTAssertNil(dataSource.titleForSection(0))
        XCTAssertEqual(dataSource.numberOfPostsInSection(0), 0)
    }
}

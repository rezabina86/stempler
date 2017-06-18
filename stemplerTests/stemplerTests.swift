
import XCTest
//@testable import stempler

class stemplerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUttypeFromFileName() {
        XCTAssert(uttypeFromFileName("a.jpg")! == kUTTypeJPEG)
        XCTAssert(uttypeFromFileName("/tmp/x.jpg")! == kUTTypeJPEG)
        XCTAssert(uttypeFromFileName("a.JPEG")! == kUTTypeJPEG)
        XCTAssert(uttypeFromFileName("a.PNG")! == kUTTypePNG)
        XCTAssert(uttypeFromFileName("a.pnG")! == kUTTypePNG)
        XCTAssert(uttypeFromFileName("/this/ should / work too.BmP")! == kUTTypeBMP)
        XCTAssert(uttypeFromFileName("a.") == nil)
        XCTAssert(uttypeFromFileName("a.doc") == nil)
        XCTAssert(uttypeFromFileName("a.PNGG") == nil)
        XCTAssert(uttypeFromFileName("a.jpg.doc") == nil)
    }
    
    func testCalc() {
        let sets = [// simple upper left, gap
                    (200, 200, 100, 100, 100*100, 25.0, 0.0, IconPosition.topLeft,
                     100, 100, 50, 50, 0, 50, false),
                    // same, but on right side
                    (200, 200, 100, 100, 100*100, 25.0, 0.0, IconPosition.topRight,
                     100, 100, 50, 50, 100-50, 50, false),
                    // with gap and non-trivial icon resize
                    (400, 300, 100, 50, 200*150, 10.0, 100.0, IconPosition.bottomRight,
                     200, 150, 77, 38, 200-77-38, 38, false),
                    // check upscale prevention and icon upscale warning
                    (1000, 2000, 10, 20, 4000*8000, 25.0, 50.0, IconPosition.bottomLeft,
                     1000, 2000, 500, 1000, 250, 250, true)
                    ]
        for set in sets {
            print(set)
            var w: Int = -1
            var h: Int = -1
            var iw: Int = -1
            var ih: Int = -1
            var x: Int = -1
            var y: Int = -1
            var iconUpscale: Bool = false
            calc(set.0, imgHeight: set.1, iconWidth: set.2, iconHeight: set.3,
                 pixels: set.4, iconPct: set.5, margin: set.6, position: set.7,
                 w: &w, h: &h, x: &x, y: &y, iw: &iw, ih: &ih, iconUpscale: &iconUpscale)
            XCTAssertEqual(set.8, w)
            XCTAssertEqual(set.9, h)
            XCTAssertEqual(set.10, iw)
            XCTAssertEqual(set.11, ih)
            XCTAssertEqual(set.12, x)
            XCTAssertEqual(set.13, y)
            XCTAssertEqual(set.14, iconUpscale)
        }
    }
    
    func testRender() {
        self.measure {
            //TODO
        }
    }
}

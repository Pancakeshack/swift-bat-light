@main
struct Main {
    static func main() {
        stdio_init_all()
        if cyw43_arch_init() != 0 { return }

        print("Starting CUTIE Ghost Matrix...")
        sleep_ms(2000)

        glue_launch_core1(launchMatrixRunner)

        while true {
            sleep_ms(2000)
        }
    }
}

func launchMatrixRunner() {
    let runner = MatrixRunner()
    runner.run()
}

struct MatrixRunner {
    static let frame0: InlineArray = [
        "................................",
        ".PPPPPPPP.......................",
        "PPPPPPPPPP......................",
        "PPPPPPPPPPPP....................",
        "PPP..PP..PPP....................",  
        "PPP..PP..PPP....................", 
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",  
        "PP..PPPP..PP....................",
        "................................",
        "................................",
        "................................",
    ]

    static let frame1: InlineArray = [
        "................................",
        ".PPPPPPPP.......................",
        "PPPPPPPPPP...RR..RR.............",
        "PPPPPPPPPPPPRRRRRRRR............",
        "PPP..PP..PPPRRRRRRRR............",
        "PPP..PP..PPP.RRRRRR.............",
        "PPPPPPPPPPPP..RRRR..............",
        "PPPPPPPPPPPP...RR...............",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP..CCC.C.C.CCC.C.CCC.", 
        "PP..PPPP..PP..C...C.C..C..C.C...",  
        "..............C...C.C..C..C.CCC.", 
        "..............C...C.C..C..C.C...",  
        "..............CCC.CCC..C..C.CCC.", 
    ]

    static let frame2: InlineArray = [
        "................................",
        ".PPPPPPPP.......................",
        "PPPPPPPPPP.....RR..RR...........",
        "PPPPPPPPPPPP..RRRRRRRR..........",
        "PPP..PP..PPP..RRRRRRRR..........",
        "PPP..PP..PPP...RRRRRR...........",
        "PPPPPPPPPPPP....RRRR............",
        "PPPPPPPPPPPP.....RR.............",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP..CCC.C.C.CCC.C.CCC.",
        "PP..PPPP..PP..C...C.C..C..C.C...",
        "..............C...C.C..C..C.CCC.",
        "..............C...C.C..C..C.C...",
        "..............CCC.CCC..C..C.CCC.",
    ]

    static let frame3: InlineArray = [
        "................................",
        ".PPPPPPPP.......................",
        "PPPPPPPPPP.......RR..RR.........",
        "PPPPPPPPPPPP....RRRRRRRR........",
        "PPP..PP..PPP....RRRRRRRR........",
        "PPP..PP..PPP.....RRRRRR.........",
        "PPPPPPPPPPPP......RRRR..........",
        "PPPPPPPPPPPP.......RR...........",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP..CCC.C.C.CCC.C.CCC.",
        "PP..PPPP..PP..C...C.C..C..C.C...",
        "..............C...C.C..C..C.CCC.",
        "..............C...C.C..C..C.C...",
        "..............CCC.CCC..C..C.CCC.",
    ]

    static let frame4: InlineArray = [
        "................................",
        ".PPPPPPPP.......................",
        "PPPPPPPPPP.........RR..RR.......",
        "PPPPPPPPPPPP......RRRRRRRR......",
        "PPP..PP..PPP......RRRRRRRR......",
        "PPP..PP..PPP.......RRRRRR.......",
        "PPPPPPPPPPPP........RRRR........",
        "PPPPPPPPPPPP.........RR.........",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP..CCC.C.C.CCC.C.CCC.",
        "PP..PPPP..PP..C...C.C..C..C.C...",
        "..............C...C.C..C..C.CCC.",
        "..............C...C.C..C..C.C...",
        "..............CCC.CCC..C..C.CCC.",
    ]

    static let frame5: InlineArray = [
        "................................",
        ".PPPPPPPP.......................",
        "PPPPPPPPPP...........RR..RR.....",
        "PPPPPPPPPPPP........RRRRRRRR....",
        "PPP..PP..PPP........RRRRRRRR....",
        "PPP..PP..PPP.........RRRRRR.....",
        "PPPPPPPPPPPP..........RRRR......",
        "PPPPPPPPPPPP...........RR.......",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP..CCC.C.C.CCC.C.CCC.",
        "PP..PPPP..PP..C...C.C..C..C.C...",
        "..............C...C.C..C..C.CCC.",
        "..............C...C.C..C..C.C...",
        "..............CCC.CCC..C..C.CCC.",
    ]

    static let frame6: InlineArray = [
        "................................",
        ".PPPPPPPP.......................",
        "PPPPPPPPPP.............RR..RR...",
        "PPPPPPPPPPPP..........RRRRRRRR..",
        "PPP..PP..PPP..........RRRRRRRR..",
        "PPP..PP..PPP...........RRRRRR...",
        "PPPPPPPPPPPP............RRRR....",
        "PPPPPPPPPPPP.............RR.....",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP..CCC.C.C.CCC.C.CCC.",
        "PP..PPPP..PP..C...C.C..C..C.C...",
        "..............C...C.C..C..C.CCC.",
        "..............C...C.C..C..C.C...",
        "..............CCC.CCC..C..C.CCC.",
    ]

    static let frame7: InlineArray = [
        "................................",
        ".PPPPPPPP.......................",
        "PPPPPPPPPP...............RR..RR.",
        "PPPPPPPPPPPP............RRRRRRRR",
        "PPP..PP..PPP............RRRRRRRR",
        "PPP..PP..PPP.............RRRRRR.",
        "PPPPPPPPPPPP..............RRRR..",
        "PPPPPPPPPPPP...............RR...",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP..CCC.C.C.CCC.C.CCC.",
        "PP..PPPP..PP..C...C.C..C..C.C...",
        "..............C...C.C..C..C.CCC.",
        "..............C...C.C..C..C.C...",
        "..............CCC.CCC..C..C.CCC.",
    ]

    static let frame8: InlineArray = [
        "................................",
        ".PPPPPPPP.......................",
        "PPPPPPPPPP...................RR.",
        "PPPPPPPPPPPP................RRRR",
        "PPP..PP..PPP................RRRR",
        "PPP..PP..PPP.................RRR",
        "PPPPPPPPPPPP..................RR",
        "PPPPPPPPPPPP...................R",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP..CCC.C.C.CCC.C.CCC.",
        "PP..PPPP..PP..C...C.C..C..C.C...",
        "..............C...C.C..C..C.CCC.",
        "..............C...C.C..C..C.C...",
        "..............CCC.CCC..C..C.CCC.",
    ]

    static let frame9: InlineArray = [
        "................................",
        ".PPPPPPPP.......................",
        "PPPPPPPPPP......................",
        "PPPPPPPPPPPP...................R",
        "PPP..PP..PPP...................R",
        "PPP..PP..PPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP....................",
        "PPPPPPPPPPPP..CCC.C.C.CCC.C.CCC.",
        "PP..PPPP..PP..C...C.C..C..C.C...",
        "..............C...C.C..C..C.CCC.",
        "..............C...C.C..C..C.C...",
        "..............CCC.CCC..C..C.CCC.",
    ]

    static let sequence: InlineArray = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

    static func ghostShape(at index: Int) -> InlineArray<16, String> {
        switch sequence[index] {
        case 0: return Self.frame0
        case 1: return Self.frame1
        case 2: return Self.frame2
        case 3: return Self.frame3
        case 4: return Self.frame4
        case 5: return Self.frame5
        case 6: return Self.frame6
        case 7: return Self.frame7
        case 8: return Self.frame8
        case 9: return Self.frame9
        default: return Self.frame0
        }
    }

    static func nextShapeIndex(current: Int) -> Int {
        let nextIndex = current + 1
        return nextIndex < sequence.count ? nextIndex : 0
    }

    func run() {
        let config = MatrixConfig(
            width: 32, height: 16, bitDepth: 4,
            rgbPins: (5, 3, 4, 9, 10, 11),
            addrPins: (6, 8, 7),
            clockPin: 1, latchPin: 2, oePin: 0
        )

        let matrix = Matrix(config: config)
        let red = Matrix.color565(r: 255, g: 0, b: 0)
        let purple = Matrix.color565(r: 160, g: 32, b: 240)
        let cyan = Matrix.color565(r: 0, g: 180, b: 255)

        print("Looping...")

        var loopCounter = 0
        var currentGhostShape = 0

        while true {
            loopCounter += 1

            if loopCounter >= 20 {
                loopCounter = 0
                currentGhostShape = Self.nextShapeIndex(current: currentGhostShape)
            }

            matrix.clear(color: 0)

            let shape = Self.ghostShape(at: currentGhostShape)

            for y in shape.indices {
                let row = shape[y]
                for (x, char) in row.utf8.enumerated() {
                    if char == UInt8(ascii: "P") {
                        matrix.drawPixel(x: x, y: y, color: purple)
                    } else if char == UInt8(ascii: "R") {
                        matrix.drawPixel(x: x, y: y, color: red)
                    } else if char == UInt8(ascii: "C") {
                        matrix.drawPixel(x: x, y: y, color: cyan)
                    }
                }
            }

            matrix.show()
            sleep_ms(20)
        }
    }
}

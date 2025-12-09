@main
struct Main {
    // The neutral frame you modified (kept exactly as you provided)
    static let batNeutral: InlineArray = [
        "................................",  // Row 0
        "................................",  // Row 1
        "................................",  // Row 2
        ".............P....P.............",  // Row 3  (Ears)
        "............PRPPPPRP............",  // Row 4  (Eyes - Modified Pattern)
        ".........P..PPPPPPPP..P.........",  // Row 5
        "........PPPPPPPPPPPPPPPP........",  // Row 6
        ".......PPPPPPPPPPPPPPPPPP.......",  // Row 7
        "......PPPPPPPPPPPPPPPPPPPP......",  // Row 8
        ".......P...PPPPPPPPPP...P.......",  // Row 9
        "...........PPPPPPPPPP...........",  // Row 10
        "............P.PPPP.P............",  // Row 11
        "..............P..P..............",  // Row 12
        "................................",  // Row 13
        "................................",  // Row 14
        "................................",  // Row 15
    ]

    // Wings raised: Thickened considerably to look like a full membrane, not a wire
    static let batUp: InlineArray = [
        "P..............................P",  // Row 0  (Tips extend to very top)
        "PP............................PP",  // Row 1  (Tips are now blocky/thick)
        "PPP..........P....P..........PPP",  // Row 2  (Connecting mass)
        "PPPP........PRPPPPRP........PPPP",  // Row 3  (Wings merge into head row)
        ".PPPP......PPPPPPPPPP......PPPP.",  // Row 4  (Shoulders are heavy)
        "..PPPPPPPPPPPPPPPPPPPPPPPPPPPP..",  // Row 5  (Wide wingspan)
        "...PPPPPPPPPPPPPPPPPPPPPPPPPP...",  // Row 6
        ".....PPPPPPPPPPPPPPPPPPPPPP.....",  // Row 7  (Tapering body)
        ".......PPPPPPPPPPPPPPPPPP.......",  // Row 8
        ".........PPPPPPPPPPPPPP.........",  // Row 9
        "...........PPPPPPPPPP...........",  // Row 10
        ".............PPPPPP.............",  // Row 11 (Tail tucks in)
        "................................",  // Row 12
        "................................",  // Row 13
        "................................",  // Row 14
        "................................",  // Row 15
    ]

    // Wings down: A heavy 'cape' look, maintaining volume
    static let batDown: InlineArray = [
        "................................",  // Row 0
        "................................",  // Row 1
        "................................",  // Row 2
        ".............P....P.............",  // Row 3  (Ears)
        "............PRPPPPRP............",  // Row 4  (Eyes)
        "..........PPPPPPPPPPPP..........",  // Row 5  (Shoulders hunch)
        ".......PPPPPPPPPPPPPPPPPP.......",  // Row 6  (Wings start heavy)
        ".....PPPPPPPPPPPPPPPPPPPPPP.....",  // Row 7
        "....PPPPPPPPPPPPPPPPPPPPPPPP....",  // Row 8  (Full width)
        "...PPPP...PPPPPPPPPPPP...PPPP...",  // Row 9  (Wings extend down)
        "..PPP.......PPPPPPPP.......PPP..",  // Row 10 (Thick tips)
        ".PP..........PPPPPP..........PP.",  // Row 11
        "P..............PP..............P",  // Row 12 (Lowest point)
        "................................",  // Row 13
        "................................",  // Row 14
        "................................",  // Row 15
    ]

    static let sequence: InlineArray = [0, 1, 0, 2]

    static func batShape(at index: Int) -> InlineArray<16, String> {
        switch sequence[index] {
        case 0:
            return Main.batNeutral
        case 1:
            return Main.batUp
        case 2:
            return Main.batDown
        default:
            return Main.batNeutral
        }
    }

    static func nextShapeIndex(current: Int) -> Int {
        let nextIndex = current + 1
        if nextIndex < sequence.count {
            return nextIndex
        } else {
            return 0
        }
    }

    static func main() {
        stdio_init_all()
        if cyw43_arch_init() != 0 { return }

        print("Starting Clean Matrix...")
        sleep_ms(2000)

        let config = MatrixConfig(
            width: 32,
            height: 16,
            bitDepth: 4,
            rgbPins: (5, 3, 4, 9, 10, 11),
            addrPins: (6, 8, 7),
            clockPin: 1,
            latchPin: 2,
            oePin: 0
        )

        let matrix = Matrix(config: config)

        let purple = Matrix.color565(r: 180, g: 0, b: 255)
        let red = Matrix.color565(r: 255, g: 0, b: 0)

        print("Looping...")

        var loopCounter = 0
        var currentBatShape = 0

        while true {
            loopCounter += 1

            if loopCounter == 50 {
                loopCounter = 0
                currentBatShape = Self.nextShapeIndex(current: currentBatShape)
            }

            matrix.clear(color: 0)

            let batShape = Self.batShape(at: currentBatShape)
            for y in batShape.indices {
                let row = batShape[y]
                for (x, char) in row.utf8.enumerated() {
                    if char == UInt8(ascii: "P") {
                        matrix.drawPixel(x: x, y: y, color: purple)
                    } else if char == UInt8(ascii: "R") {
                        matrix.drawPixel(x: x, y: y, color: red)
                    }
                }
            }

            matrix.show()
            sleep_ms(20)  // 50fps refresh logic
        }
    }
}

struct MatrixConfig {
    let width: UInt16
    let height: UInt16
    let bitDepth: UInt8
    let rgbPins: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    let addrPins: (UInt8, UInt8, UInt8)
    let clockPin: UInt8
    let latchPin: UInt8
    let oePin: UInt8
}

class Matrix {
    let width: UInt16
    let height: UInt16
    private var core: UnsafeMutablePointer<Protomatter_core>
    private var buffer: UnsafeMutablePointer<UInt16>

    init(config: MatrixConfig) {
        self.width = config.width
        self.height = config.height

        self.core = UnsafeMutablePointer<Protomatter_core>.allocate(capacity: 1)
        self.core.initialize(to: Protomatter_core())

        let bufferSize = Int(config.width * config.height)
        self.buffer = UnsafeMutablePointer<UInt16>.allocate(capacity: bufferSize)

        PM_SetCorePointer(self.core)

        // Initialize buffer to black
        for i in 0..<bufferSize { self.buffer[i] = 0 }

        var rgbPins = config.rgbPins
        var addrPins = config.addrPins

        let timerSlice = UnsafeMutableRawPointer(bitPattern: 6)

        let status = withUnsafeMutablePointer(to: &rgbPins) { rgbPtr in
            return withUnsafeMutablePointer(to: &addrPins) { addrPtr in
                let rawRgb = UnsafeMutableRawPointer(rgbPtr).assumingMemoryBound(to: UInt8.self)
                let rawAddr = UnsafeMutableRawPointer(addrPtr).assumingMemoryBound(to: UInt8.self)

                return _PM_init(
                    self.core,  
                    config.width,
                    config.bitDepth,
                    1,
                    rawRgb,
                    3,
                    rawAddr,
                    config.clockPin,
                    config.latchPin,
                    config.oePin,
                    true,
                    1,
                    timerSlice
                )
            }
        }

        if status.rawValue != 0 {
            fatalError("Matrix Init Failed: \(status.rawValue)")
        }

        let beginStatus = _PM_begin(self.core)
        if beginStatus.rawValue != 0 {
            fatalError("Matrix Begin Failed")
        }
    }

    func clear(color: UInt16) {
        for i in 0..<Int(width * height) {
            buffer[i] = color
        }
    }

    func drawPixel(x: Int, y: Int, color: UInt16) {
        if x >= 0 && x < Int(width) && y >= 0 && y < Int(height) {
            let index = y * Int(width) + x
            buffer[index] = color
        }
    }

    func show() {
        _PM_convert_565(core, buffer, width)
        _PM_swapbuffer_maybe(core)
    }

    static func color565(r: UInt8, g: UInt8, b: UInt8) -> UInt16 {
        let r16 = UInt16(r)
        let g16 = UInt16(g)
        let b16 = UInt16(b)
        return ((r16 & 0xF8) << 8) | ((g16 & 0xFC) << 3) | (b16 >> 3)
    }

    deinit {
        core.deallocate()
        buffer.deallocate()
    }
}

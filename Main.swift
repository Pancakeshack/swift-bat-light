@main
struct Main {
    // --- UPDATED PIN MAPPING ---
    // OE moved to GP15 (Physical Pin 20) to avoid boot noise
    static let PIN_OE: UInt32 = 15

    // Standard HUB75 Pins
    static let PIN_CLK: UInt32 = 1  // GP1
    static let PIN_LAT: UInt32 = 2  // GP2

    static let PIN_G1: UInt32 = 3
    static let PIN_B1: UInt32 = 4
    static let PIN_R1: UInt32 = 5

    // Your Wiring (A=GP6, C=GP7, B=GP8)
    // Note: If rows look scrambled, swap B and C variables here.
    static let PIN_A: UInt32 = 6
    static let PIN_C: UInt32 = 7
    static let PIN_B: UInt32 = 8

    static let PIN_R2: UInt32 = 9
    static let PIN_G2: UInt32 = 10
    static let PIN_B2: UInt32 = 11

    static let ONBOARD_LED: UInt32 = UInt32(CYW43_WL_GPIO_LED_PIN)

    static func main() {
        if cyw43_arch_init() != 0 { return }

        // 1. Initialize ALL Pins
        let allPins = [
            PIN_OE, PIN_CLK, PIN_LAT, PIN_G1, PIN_B1, PIN_R1, PIN_A, PIN_C, PIN_B, PIN_R2, PIN_G2,
            PIN_B2,
        ]
        for pin in allPins {
            gpio_init(pin)
            gpio_set_dir(pin, true)
            gpio_put(pin, false)
        }

        // Start with OE HIGH (Screen OFF) - Active Low Logic
        gpio_put(PIN_OE, true)

        // 2. THE UNLOCK (Repeated 3 times to be safe)
        // This wakes up FM6126A chips
        unlockFM6126A()
        sleep_ms(10)
        unlockFM6126A()
        sleep_ms(10)
        unlockFM6126A()

        var colorStep = 0

        // 3. Main Loop
        while true {
            // Heartbeat: Blink LED so you know Pico is alive
            colorStep += 1
            if colorStep % 200 == 0 {
                cyw43_arch_gpio_put(ONBOARD_LED, true)
            } else if colorStep % 200 == 100 {
                cyw43_arch_gpio_put(ONBOARD_LED, false)
            }

            // Cycle Colors: 0=Red, 1=Green, 2=Blue
            let frameColor = (colorStep / 500) % 3

            // Scan 8 Rows
            for row in 0..<8 {
                driveRow(row: row, colorIdx: frameColor)
            }
        }
    }

    static func driveRow(row: Int, colorIdx: Int) {
        // A. Screen OFF (Active Low: True = OFF)
        gpio_put(PIN_OE, true)

        // B. Address Select
        gpio_put(PIN_A, (row & 1) != 0)
        gpio_put(PIN_B, (row & 2) != 0)
        gpio_put(PIN_C, (row & 4) != 0)

        // C. Shift Data (32 Pixels)
        for _ in 0..<32 {
            let r = (colorIdx == 0)
            let g = (colorIdx == 1)
            let b = (colorIdx == 2)

            // Top Half
            gpio_put(PIN_R1, r)
            gpio_put(PIN_G1, g)
            gpio_put(PIN_B1, b)
            // Bottom Half
            gpio_put(PIN_R2, r)
            gpio_put(PIN_G2, g)
            gpio_put(PIN_B2, b)

            // Clock Pulse
            gpio_put(PIN_CLK, true)
            // No sleep needed here for Swift on Pico, it's slow enough
            gpio_put(PIN_CLK, false)
        }

        // D. Latch Data
        gpio_put(PIN_LAT, true)
        gpio_put(PIN_LAT, false)

        // E. Screen ON (Active Low: False = ON)
        gpio_put(PIN_OE, false)

        // F. Hold Image (Adjust brightness here)
        sleep_us(100)
    }

    // --- FM6126A UNLOCK SEQUENCE ---
    static func unlockFM6126A() {
        // Send unlock pattern to Reg 12 and Reg 13
        sendPattern(reg: 12, data: 0b01111111_11111111)  // 0x7FFF
        sendPattern(reg: 13, data: 0b00000000_01000000)  // 0x0040
    }

    static func sendPattern(reg: Int, data: UInt16) {
        // FM6126A expects the pattern across the WHOLE width
        for i in 0..<32 {
            let idx = i & 15
            let bitPos = 15 - idx
            let bitSet = (data >> bitPos) & 1 == 1

            // Set all data pins
            gpio_put(PIN_R1, bitSet)
            gpio_put(PIN_G1, bitSet)
            gpio_put(PIN_B1, bitSet)
            gpio_put(PIN_R2, bitSet)
            gpio_put(PIN_G2, bitSet)
            gpio_put(PIN_B2, bitSet)

            // Clock Low
            gpio_put(PIN_CLK, false)

            // Special Latch Logic for Unlock
            // Latch must be HIGH *during* the last few clock cycles
            if i > (32 - 1 - reg) { gpio_put(PIN_LAT, true) } else { gpio_put(PIN_LAT, false) }

            // Clock High -> Low
            gpio_put(PIN_CLK, true)
            gpio_put(PIN_CLK, false)
        }
        // Final Latch Toggle
        gpio_put(PIN_LAT, false)
        gpio_put(PIN_LAT, true)
        gpio_put(PIN_LAT, false)
    }
}

@main
struct Main {
    static func main() {
        let led = UInt32(CYW43_WL_GPIO_LED_PIN)
        if cyw43_arch_init() != 0 {
            print("Wi-Fi init failed")
            return
        }
        let dot = {
            cyw43_arch_gpio_put(led, true)
            sleep_ms(250)
            cyw43_arch_gpio_put(led, false)
            sleep_ms(250)
        }
        let dash = {
            cyw43_arch_gpio_put(led, true)
            sleep_ms(500)
            cyw43_arch_gpio_put(led, false)
            sleep_ms(250)
        }
        while true {
            dot()
            dot()
            dot()

            dash()
            dash()
            dash()

            dot()
            dot()
            dot()
        }
    }
}

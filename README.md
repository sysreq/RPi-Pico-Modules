# Raspberry-Pi-Pico-Modules

Usage Examples:

# Simple module 
add_simple_pico_module(i2c_module my_module.cppm pico_stdlib hardware_i2c)

# More complex module with multiple files and custom settings
add_pico_module(spi_module
      MODULE_FILES 
          spi_config.cppm
          spi_utils.cppm
      PICO_LIBS 
          pico_stdlib 
          hardware_spi 
          hardware_gpio
      INCLUDE_DIRS 
          ${CMAKE_CURRENT_LIST_DIR}/spi
          ${CMAKE_CURRENT_LIST_DIR}/common
      COMPILE_DEFINITIONS
          SPI_DEBUG=1
  )

# UART module example
add_simple_pico_module(uart_module uart.cppm pico_stdlib hardware_uart)

# PWM module example  
add_simple_pico_module(pwm_module pwm.cppm pico_stdlib hardware_pwm hardware_gpio)

To add the modules into your build just use the alias 'pico_modules'.

target_link_libraries(my_project PRIVATE
        pico_modules
        pico_stdlib
)

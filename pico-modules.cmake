# ====================================================================================
# Usage
#
# Simple module
# add_simple_pico_module(i2c_module my_module.cppm pico_stdlib hardware_i2c)
#
# More complex module with multiple files and custom settings
# add_pico_module(spi_module
#     MODULE_FILES 
#         spi_config.cppm
#         spi_utils.cppm
#     PICO_LIBS 
#         pico_stdlib 
#         hardware_spi 
#         hardware_gpio
#     INCLUDE_DIRS 
#         ${CMAKE_CURRENT_LIST_DIR}/spi
#         ${CMAKE_CURRENT_LIST_DIR}/common
#     COMPILE_DEFINITIONS
#         SPI_DEBUG=1
# )
#
# UART module example
# add_simple_pico_module(uart_module uart.cppm pico_stdlib hardware_uart)
#
# PWM module example  
# add_simple_pico_module(pwm_module pwm.cppm pico_stdlib hardware_pwm hardware_gpio)
# ====================================================================================

# Initialize global property to track all modules
set_property(GLOBAL PROPERTY PICO_MODULES_LIST "")

# Generic function to create Pico SDK modules
function(add_pico_module MODULE_NAME)
    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs MODULE_FILES PICO_LIBS INCLUDE_DIRS COMPILE_DEFINITIONS)
    
    cmake_parse_arguments(PICO_MODULE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    # Default Pico libraries if none specified
    if(NOT PICO_MODULE_PICO_LIBS)
        set(PICO_MODULE_PICO_LIBS pico_stdlib)
    endif()
    
    # Default include directory
    if(NOT PICO_MODULE_INCLUDE_DIRS)
        set(PICO_MODULE_INCLUDE_DIRS ${CMAKE_CURRENT_LIST_DIR})
    endif()
    
    # Create the module library
    add_library(${MODULE_NAME})
    
    # Add module sources
    target_sources(${MODULE_NAME} 
        PUBLIC
            FILE_SET CXX_MODULES FILES
                ${PICO_MODULE_MODULE_FILES}
    )
    
    # Link to Pico SDK libraries
    target_link_libraries(${MODULE_NAME} 
        PUBLIC 
            ${PICO_MODULE_PICO_LIBS}
    )
    
    # Set include directories
    target_include_directories(${MODULE_NAME} 
        PUBLIC
            ${PICO_MODULE_INCLUDE_DIRS}
    )
    
    # Propagate compile definitions from Pico SDK libraries
    foreach(PICO_LIB ${PICO_MODULE_PICO_LIBS})
        target_compile_definitions(${MODULE_NAME} 
            PUBLIC
                $<TARGET_PROPERTY:${PICO_LIB},INTERFACE_COMPILE_DEFINITIONS>
        )
    endforeach()
    
    # Add any custom compile definitions
    if(PICO_MODULE_COMPILE_DEFINITIONS)
        target_compile_definitions(${MODULE_NAME} 
            PUBLIC
                ${PICO_MODULE_COMPILE_DEFINITIONS}
        )
    endif()
    
    # Add this module to the global list
    get_property(current_modules GLOBAL PROPERTY PICO_MODULES_LIST)
    list(APPEND current_modules ${MODULE_NAME})
    set_property(GLOBAL PROPERTY PICO_MODULES_LIST "${current_modules}")
    
    # Automatically create/update the pico_modules target
    if(NOT TARGET pico_modules)
        add_library(pico_modules INTERFACE)
        message(STATUS "Created automatic pico_modules interface target")
    endif()
    
    # Add this module to the pico_modules target
    target_link_libraries(pico_modules INTERFACE ${MODULE_NAME})
    
    message(STATUS "Created Pico module: ${MODULE_NAME} (added to pico_modules)")
endfunction()

# Convenience function for simple single-file modules
function(add_simple_pico_module MODULE_NAME MODULE_FILE)
    add_pico_module(${MODULE_NAME}
        MODULE_FILES ${MODULE_FILE}
        PICO_LIBS ${ARGN}  # Pass remaining arguments as Pico libraries
    )
endfunction()

# Helper function to simplify linkage under dynamic naming
function(create_all_modules_target TARGET_NAME)
    get_property(all_modules GLOBAL PROPERTY PICO_MODULES_LIST)
    
    if(all_modules)
        add_library(${TARGET_NAME} INTERFACE)
        target_link_libraries(${TARGET_NAME} INTERFACE ${all_modules})
        message(STATUS "Created ${TARGET_NAME} interface linking to: ${all_modules}")
    else()
        message(WARNING "No Pico modules found - ${TARGET_NAME} target not created")
    endif()
endfunction()

# Helper function to retrieve list of modules
function(get_all_modules_list OUTPUT_VAR)
    get_property(modules_list GLOBAL PROPERTY PICO_MODULES_LIST)
    set(${OUTPUT_VAR} "${modules_list}" PARENT_SCOPE)
endfunction()

FetchContent_Declare(
    nuget
    PREFIX nuget
    URL "https://dist.nuget.org/win-x86-commandline/v5.3.0/nuget.exe"
    DOWNLOAD_NO_EXTRACT 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    UPDATE_COMMAND ""
    INSTALL_COMMAND ""
)

if(NOT nuget_POPULATED)
    FetchContent_Populate(nuget)
endif()

set(directml_PACKAGE_ID Microsoft.AI.DirectML)
set(directml_PACKAGE_VERSION 1.5.1 CACHE STRING "Version of the DML redistributable")
set(directml_PACKAGE_DIR ${nuget_SOURCE_DIR}/packages/${directml_PACKAGE_ID}.${directml_PACKAGE_VERSION})

execute_process(
    COMMAND 
        ${nuget_SOURCE_DIR}/nuget.exe
        install 
        ${directml_PACKAGE_ID} 
        -Version ${directml_PACKAGE_VERSION} 
        -OutputDirectory ${nuget_SOURCE_DIR}/packages
)

add_library(directml SHARED IMPORTED)
add_library(Microsoft::DirectML ALIAS directml)

target_include_directories(directml INTERFACE ${directml_PACKAGE_DIR}/include)

if(${CMAKE_SYSTEM_NAME} MATCHES Windows)
    set(directml_PLATFORM ${CMAKE_GENERATOR_PLATFORM})
    if(NOT directml_PLATFORM)
        set(directml_PLATFORM ${CMAKE_VS_PLATFORM_NAME})
    endif()
    if(NOT directml_PLATFORM)
        set(directml_PLATFORM Win32)
    endif()
    
    if (${directml_PLATFORM} MATCHES Win32)
        set(directml_BIN_PATH ${directml_PACKAGE_DIR}/bin/x86-win)
    elseif (${directml_PLATFORM} MATCHES x64)
        set(directml_BIN_PATH ${directml_PACKAGE_DIR}/bin/x64-win)
    elseif (${directml_PLATFORM} MATCHES ARM)
        set(directml_BIN_PATH ${directml_PACKAGE_DIR}/bin/arm-win)
    elseif (${directml_PLATFORM} MATCHES ARM64)
        set(directml_BIN_PATH ${directml_PACKAGE_DIR}/bin/arm64-win)
    endif()

    set_property(TARGET directml PROPERTY IMPORTED_LOCATION ${directml_BIN_PATH}/DirectML.dll)
    set_property(TARGET directml PROPERTY IMPORTED_IMPLIB ${directml_BIN_PATH}/DirectML.lib)
    set_property(TARGET directml PROPERTY DEBUG_DLL_PATH ${directml_BIN_PATH}/DirectML.Debug.dll)

    install(
        FILES 
            ${directml_BIN_PATH}/DirectML.dll
            ${directml_BIN_PATH}/DirectML.Debug.dll
        DESTINATION bin
    )
endif()
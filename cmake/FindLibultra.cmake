###################
## Find libultra ##
###################

include(FindPackageHandleStandardArgs)

find_path(Libultra_INCLUDE_DIR ultra64.h
    PATH_SUFFIXES
        "n64"
)

find_library(Libultra_LIBRARY ultra_rom
    PATH_SUFFIXES
        "n64"
)

find_package_handle_standard_args(Libultra
    Libultra_INCLUDE_DIR
    Libultra_LIBRARY
)

if(Libultra_FOUND AND NOT TARGET libultra::libultra)
    add_library(libultra::libultra STATIC IMPORTED)
    set_target_properties(libultra::libultra PROPERTIES
        IMPORTED_LOCATION ${Libultra_LIBRARY}
    )
    target_include_directories(libultra::libultra INTERFACE
        "${Libultra_INCLUDE_DIR}"
        "${Libultra_INCLUDE_DIR}/PR"
    )
endif()

# TODO: Boot, RSP, GSP, and ASP code

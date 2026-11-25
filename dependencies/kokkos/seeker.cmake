DependencyResolver_Resolve(Kokkos
                           VERSION          "4.1.0...<6.0.0"
                           COMPONENTS       Kokkos::kokkos
                           # Look at the system or if the dependency is already
                           # resolved by someone else. Else fallback to
                           # downloading the product.
                           PROVIDERS        SYSTEM
                                            ARCHIVE
                           PROVIDERS_SOURCE "https://github.com/kokkos/kokkos/releases/download/5.2.2/kokkos-5.2.2.tar.gz"
                           )

DependencyResolver_Resolve(KokkosKernels
                           VERSION          "4.1.0...<6.0.0"
                           COMPONENTS       Kokkos::kokkoskernels
                           # Look at the system or if the dependency is already
                           # resolved by someone else. Else fallback to
                           # downloading the product.
                           PROVIDERS        SYSTEM
                                            ARCHIVE
                           PROVIDERS_SOURCE "https://github.com/kokkos/kokkos-kernels/releases/download/5.2.2/kokkos-kernels-5.2.2.tar.gz"
                           )

# DependencyResolver_Resolve calls find_package in a function scope, so the
# variables defined by the Kokkos package configuration are not visible here.
if(TARGET Kokkos::kokkos AND NOT DEFINED Kokkos_COMPILE_LANGUAGE)
    find_package(Kokkos QUIET)
endif()

# When Kokkos is built with Kokkos_ENABLE_COMPILE_AS_CMAKE_LANGUAGE, sources
# that include Kokkos are compiled with the CUDA or HIP language instead of CXX.
if(Kokkos_COMPILE_LANGUAGE AND NOT Kokkos_COMPILE_LANGUAGE STREQUAL "CXX")
    enable_language(${Kokkos_COMPILE_LANGUAGE})
endif()

function(${PROJECT_NAME}_target_add_kokkos target_name)
    target_link_libraries("${target_name}"
                          PUBLIC Kokkos::kokkos)

    if(Kokkos_COMPILE_LANGUAGE AND NOT Kokkos_COMPILE_LANGUAGE STREQUAL "CXX")
        get_target_property(target_sources "${target_name}" SOURCES)
        list(FILTER target_sources INCLUDE REGEX "\\.cc$")
        set_source_files_properties(${target_sources}
                                    PROPERTIES LANGUAGE "${Kokkos_COMPILE_LANGUAGE}")
        set_target_properties("${target_name}"
                              PROPERTIES "${Kokkos_COMPILE_LANGUAGE}_ARCHITECTURES" "${Kokkos_${Kokkos_COMPILE_LANGUAGE}_ARCHITECTURES}")
    endif()
endfunction()

function(${PROJECT_NAME}_target_add_kokkos_kernels target_name)
    target_link_libraries("${target_name}"
                          PUBLIC Kokkos::kokkoskernels)
endfunction()

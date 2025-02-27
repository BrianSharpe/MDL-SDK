#*****************************************************************************
# Copyright (c) 2018-2022, NVIDIA CORPORATION. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  * Neither the name of NVIDIA CORPORATION nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
# OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#*****************************************************************************

# -------------------------------------------------------------------------------------------------
# script expects the following variables:
# - __TARGET_ADD_DEPENDENCY_TARGET
# - __TARGET_ADD_DEPENDENCY_DEPENDS
# - __TARGET_ADD_DEPENDENCY_COMPONENTS
# - __TARGET_ADD_DEPENDENCY_NO_RUNTIME_COPY
# - __TARGET_ADD_DEPENDENCY_NO_LINKING
# -------------------------------------------------------------------------------------------------

# add include directories, wo do not link in general as the shared libraries are loaded manually
target_include_directories(${__TARGET_ADD_DEPENDENCY_TARGET} 
    PRIVATE
        $<TARGET_PROPERTY:mdl::mdl_sdk,INTERFACE_INCLUDE_DIRECTORIES>
    )

# add build dependency
add_dependencies(${__TARGET_ADD_DEPENDENCY_TARGET} mdl::mdl_sdk)

# runtime dependencies
if(NOT __TARGET_ADD_DEPENDENCY_NO_RUNTIME_COPY)
    if(WINDOWS)
        # instead of copying, we add the library paths the debugger environment
        target_add_vs_debugger_env_path(TARGET ${__TARGET_ADD_DEPENDENCY_TARGET}
            PATHS 
                ${CMAKE_BINARY_DIR}/src/prod/lib/mdl_sdk/$(Configuration)
                ${CMAKE_BINARY_DIR}/src/shaders/plugin/dds/$(Configuration)
                ${CMAKE_BINARY_DIR}/src/shaders/plugin/freeimage/$(Configuration)
            )
    else()
        # for unix systems we can set the rpath to guide the library resolution
        target_add_rpath(TARGET ${__TARGET_ADD_DEPENDENCY_TARGET}
            RPATHS
                ${CMAKE_BINARY_DIR}/prod/lib/mdl_sdk/${CMAKE_BUILD_TYPE}
                ${CMAKE_BINARY_DIR}/shaders/plugin/dds/${CMAKE_BUILD_TYPE}
                ${CMAKE_BINARY_DIR}/shaders/plugin/freeimage/${CMAKE_BUILD_TYPE}
            )

        # add the shared lib path as RPATH
        foreach(_SHARED ${MDL_DEPENDENCY_FREEIMAGE_SHARED})
        get_filename_component(_SHARED_DIR ${_SHARED} DIRECTORY)
        target_add_rpath(TARGET ${__TARGET_ADD_DEPENDENCY_TARGET}
                RPATHS ${_SHARED_DIR}
            )
        endforeach()
    endif()

    # on linux, the user has to setup the LD_LIBRARY_PATH when running examples
    # on mac, DYLD_LIBRARY_PATH, respectively.
endif()

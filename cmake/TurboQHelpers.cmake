include(CMakeParseArguments)

function(TurboQRemoveMatchesFromList)
  set(options)
  set(oneValueArgs)
  set(multiValueArgs MATCHES)
  cmake_parse_arguments(TQ_PARSED "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  foreach (TQ_LIST ${TQ_PARSED_UNPARSED_ARGUMENTS})
    foreach (TQ_ENTRY ${${TQ_LIST}})
      foreach (TQ_MATCH ${TQ_PARSED_MATCHES})
        if (${TQ_ENTRY} MATCHES ${TQ_MATCH})
          list(REMOVE_ITEM ${TQ_LIST} ${TQ_ENTRY})
        endif()
      endforeach()
    endforeach()
    set(${TQ_LIST} ${${TQ_LIST}} PARENT_SCOPE)
  endforeach()
endfunction()

function(TurboQAddTestsFromSourceList)
  set(options)
  set(oneValueArgs PREFIX)
  set(multiValueArgs LIBS OPTIONS DEFINITIONS)

  cmake_parse_arguments(TQ_PARSED "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  foreach (TQ_LIST ${TQ_PARSED_UNPARSED_ARGUMENTS})
    foreach (TQ_ENTRY ${${TQ_LIST}})
      if (${TQ_ENTRY} MATCHES ".*_test.cpp")
        string(REGEX REPLACE "^.*\/(.*)_test\.cpp$" "\\1" testName "${TQ_ENTRY}")
        set(testName "${TQ_PARSED_PREFIX}-${testName}-test")

        add_executable(${testName} ${TQ_ENTRY})
        target_compile_options(${testName} PRIVATE ${TQ_PARSED_OPTIONS})
        target_compile_definitions(${testName} PRIVATE ${TQ_PARSED_DEFINITIONS})
        target_link_libraries(${testName} PRIVATE ${TQ_PARSED_LIBS})

        add_test(${testName} ${testName})
      endif()
    endforeach()
  endforeach()
endfunction()

function(TurboQAddBenchmarksFromSourceList)
  set(options)
  set(oneValueArgs PREFIX)
  set(multiValueArgs LIBS COMPILE_OPTIONS LINK_OPTIONS DEFINITIONS)

  cmake_parse_arguments(TQ_PARSED "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  foreach (TQ_LIST ${TQ_PARSED_UNPARSED_ARGUMENTS})
    foreach (TQ_ENTRY ${${TQ_LIST}})
      if (${TQ_ENTRY} MATCHES ".*_bm.cpp")
        string(REGEX REPLACE "^.*\/(.*)_bm\.cpp$" "\\1" benchmarkName "${TQ_ENTRY}")
        set(benchmarkName "${TQ_PARSED_PREFIX}-${benchmarkName}-bm")

        add_executable(${benchmarkName} ${TQ_ENTRY})
        target_compile_options(${benchmarkName} PRIVATE ${TQ_PARSED_COMPILE_OPTIONS})
        target_compile_definitions(${benchmarkName} PRIVATE ${TQ_PARSED_DEFINITIONS})
        target_link_options(${benchmarkName} PRIVATE ${TQ_PARSED_LINK_OPTIONS})
        target_link_libraries(${benchmarkName} PRIVATE ${TQ_PARSED_LIBS})
      endif()
    endforeach()
  endforeach()
endfunction()

function(TurboQExcludeTestsAndBenchmarksFromSourceList TQ_LIST)
  list(FILTER ${TQ_LIST} EXCLUDE REGEX ".*_test.cpp")
  list(FILTER ${TQ_LIST} EXCLUDE REGEX ".*_bm.cpp")
  set(${TQ_LIST} ${${TQ_LIST}} PARENT_SCOPE)
endfunction()

#################################
## Get current project version ##
#################################

# First try getting the version from git
execute_process(
    COMMAND
        ${GIT} describe --tags HEAD
    RESULT_VARIABLE
        GIT_DESCRIBE_RC
    OUTPUT_VARIABLE
        GIT_DESCRIBE_OUTPUT
)

# If not in a git repo, fall back to exported version
if (NOT GIT_DESCRIBE_RC EQUAL 0)
    file(READ version.txt GIT_DESCRIBE_OUTPUT)
endif()

# Extract the version
string(STRIP "${GIT_DESCRIBE_OUTPUT}" GIT_DESCRIBE_OUTPUT)
string(REPLACE "-" ";" GIT_DESCRIBE_COMPONENTS "${GIT_DESCRIBE_OUTPUT}")

list(LENGTH GIT_DESCRIBE_COMPONENTS COMPONENT_COUNT)
if (COMPONENT_COUNT GREATER_EQUAL 3)
    # Not on a git tag, use commit hash (trim the "g" prefix)
    list(GET GIT_DESCRIBE_COMPONENTS 2 GAME_VERSION)
    string(SUBSTRING "${GAME_VERSION}" 1 -1 GAME_VERSION)
else()
    # On a git tag, use it
    list(GET GIT_DESCRIBE_COMPONENTS 0 GAME_VERSION)
endif()

file(CONFIGURE
    OUTPUT ${OUTPUT_FILE}
    CONTENT
"#ifndef __GAME_VERSION_H__
#define __GAME_VERSION_H__

#define GAME_VERSION \"${GAME_VERSION}\"

#endif"
)

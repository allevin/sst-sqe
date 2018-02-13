###################################################
## sst-sqe Build/Test Scenario
###################################################
# This scenario is a testing scenario for testing the build 
# We will put more info here...
###################################################

###################################################
# Identify the dependancies needed for this scenario 
###################################################
SCENARIO_NAME="SCENARIO_3"
echo "DEBUG: INSIDE FILE $SCENARIO_NAME"

# NOTE: Load Methods are generic strings, but the initial set are
#       "deps_build" - Use the old legacy bamboo deps file to load the dependancy
#       "modules" - Use the environmet-modules pre-built module to load the dependancy

## Identify Dependencies
SCENARIO_NUM_DEPENDENCY=3

SCENARIO_DEPENDENCY_NAME[1]="openmpi"
SCENARIO_DEPENDENCY_VER[1]="openmpi-1.8"
SCENARIO_DEPENDENCY_LOADMETHOD[1]="modules"
                        
SCENARIO_DEPENDENCY_NAME[2]="zoltan"
SCENARIO_DEPENDENCY_VER[2]="3.83"
SCENARIO_DEPENDENCY_LOADMETHOD[2]="modules"

SCENARIO_DEPENDENCY_NAME[3]="goblinhmc"
SCENARIO_DEPENDENCY_VER[3]="default"
SCENARIO_DEPENDENCY_LOADMETHOD[3]="deps_build"
                        
SCENARIO_DEPENDENCY_NAME[4]="pin"
SCENARIO_DEPENDENCY_VER[4]="2.14-71313"
SCENARIO_DEPENDENCY_LOADMETHOD[4]="modules"


###################################################
# Identify the SUT's needed for this scenario 
###################################################
## Identify SUTS 
SCENARIO_NUM_SUTS=2

SCENARIO_SUT_NAME[1]="sst-core"
SCENARIO_SUT_SETUP[1]="autogen"
SCENARIO_SUT_CONFIG[1]=""
SCENARIO_SUT_MAKE[1]="make"
SCENARIO_SUT_INSTALL[1]="make install"
            
SCENARIO_SUT_NAME[2]="sst-elements"
SCENARIO_SUT_SETUP[2]=
SCENARIO_SUT_CONFIG[2]=
SCENARIO_SUT_MAKE[2]=
SCENARIO_SUT_INSTALL[2]=
            
SCENARIO_SUT_NAME[3]="sst-macro"
SCENARIO_SUT_SETUP[3]=
SCENARIO_SUT_CONFIG[3]=
SCENARIO_SUT_MAKE[3]=
SCENARIO_SUT_INSTALL[3]=
            
SCENARIO_SUT_NAME[4]="juno"
SCENARIO_SUT_SETUP[4]=
SCENARIO_SUT_CONFIG[4]=
SCENARIO_SUT_MAKE[4]=
SCENARIO_SUT_INSTALL[4]=


# !/bin/bash
# sstDep_macsim_1.2_pre.sh

# Description: 

# A bash script containing functions to process SST's Macsim external
# element.

PARENT_DIR="$( cd -P "$( dirname "$0" )"/.. && pwd )"
. ${PARENT_DIR}/include/depsDefinitions.sh

# Environment variable unique to Macsim
export SST_BUILD_MACSIM=1
# Environment variable uniquely identifying this script
export SST_BUILD_MACSIM_1_2_PRE=1
#===============================================================================
# Macsim
#===============================================================================
#-------------------------------------------------------------------------------
# Function:
#     sstDepsStage_macsim
# Purpose:
#     Prepare Macsim for patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Staged Macsim code that is ready for patching
# Caveats:
#     None
#-------------------------------------------------------------------------------
export SST_DEPS_SRC_STAGED_MACSIM=${SST_ROOT}/sst/elements/macsimComponent
sstDepsStage_macsim ()
{

    tarFile="macsim-1.2_pre.tar.gz"
    knownSha1=1565787d24e60fdcfe365799be36c66e6d836297

    sstDepsAnnounce -h $FUNCNAME -m "Staging ${tarFile}."

    if [ ! -r "${SST_DEPS_SRC_PRISTINE}/${tarFile}" ]
    then
        # Tarfile can't be read, exit.
        echo "ERROR: (${FUNCNAME})  Can't read ${SST_DEPS_SRC_PRISTINE}/${tarFile}. Is it installed?"
        return 1
    fi

    # Validate tar file against known SHA1
    sstDepsCheckSha1 -f ${SST_DEPS_SRC_PRISTINE}/${tarFile} -h ${knownSha1}
    if [ $? -ne 0 ]
    then
        return 1
    fi

    # clear any existing macsim directory
    if [ -d ${SST_DEPS_SRC_STAGED_MACSIM} ]
    then
        rm -rf ${SST_DEPS_SRC_STAGED_MACSIM}
    fi

    mkdir -p ${SST_DEPS_SRC_STAGED_MACSIM}

    # Extract tarfile. The directory created by this operation is
    # captured in the environment variable preceeding this function
    tar xfz ${SST_DEPS_SRC_PRISTINE}/${tarFile} -C ${SST_DEPS_SRC_STAGED_MACSIM} --strip-components=1
    retval=$?
    if [ $retval -ne 0 ]
    then
        # bail out on error
        echo "ERROR: (${FUNCNAME})  ${tarFile} untar failure"
        return $retval
    fi

}


#-------------------------------------------------------------------------------
# Function:
#     sstDepsDeploy_macsim
# Purpose:
#     Build and install SST Macsim dependency, after patching.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Deployed Macsim dependency
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsDeploy_macsim ()
{
    sstDepsAnnounce -h $FUNCNAME -m "Macsim will be built with SST, and not by this operation."
    # Since the build of SST will build Macsim, there is no need to build it here.
    return 0
}

# Installation location as used by SST's "./configure --with-yada-yada=..."
export SST_DEPS_INSTALL_MACSIM=${SST_ROOT}/sst/elements/macsimComponent
#-------------------------------------------------------------------------------
# Function:
#     sstDepsQuery_macsim
# Purpose:
#     Query SST Macsim dependency. Export information about this installation.
# Inputs:
#     None
# Outputs:
#     Pass/fail
# Expected Results
#     Exported Macsim dependency information
# Caveats:
#     None
#-------------------------------------------------------------------------------
sstDepsQuery_macsim ()
{
    # provide version and installation location info
    echo "export SST_DEPS_VERSION_MACSIM=\"1.2_PRE\""
    echo "export SST_DEPS_INSTALL_MACSIM=\"${SST_DEPS_INSTALL_MACSIM}\""
}

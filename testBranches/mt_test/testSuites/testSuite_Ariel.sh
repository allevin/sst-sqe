# !/bin/bash
# testSuite_Ariel.sh

# Description:

# A shell script that defines a shunit2 test suite. This will be
# invoked by the Bamboo script.

# Preconditions:

# 1) The "SUT", sst,  must have built successfully.
# 2) A test success reference file is available.

TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# Load test definitions
. $TEST_SUITE_ROOT/../include/testDefinitions.sh
. $TEST_SUITE_ROOT/../include/testSubroutines.sh

export PATH=$PATH:$SST_TEST_INSTALL_BIN

#===============================================================================
# Variables global to functions in this suite
#===============================================================================
L_SUITENAME="SST_Ariel" # Name of this test suite; will be used to
                                # identify this suite in XML file.  (no spaces)

L_TESTFILE=()  # Empty list, used to hold test file names

#===============================================================================
# Test functions
#   NOTE: These functions are invoked automatically by shunit2 as long
#   as the function name begins with "test...".
#===============================================================================

    echo "INTEL_PIN_DIRECTORY = $INTEL_PIN_DIRECTORY"
    if [ ! -d "$INTEL_PIN_DIRECTORY" ] ; then
        echo "Ariel tests requires PIN DIRECTORY"
        echo "        NOT  FOUND"
        echo " Environment Variable INTEL_PIN_DIRECTORY must be defined"
        preFail "Ariel tests requires PIN DIRECTORY" "skip"
    fi 

    OPWD=`pwd`
    export PKG_CONFIG_PATH=${SST_ROOT}/../../local/lib/pkgconfig

    cd $SST_ROOT/sst/elements/ariel/frontend/simple

    pushd examples/stream

    make 
    retval=$?
    echo "    Make in examples/stream returned \"ok\" "
    if [ $retval -ne 0 ]
    then
        # bail out on error
        pwd
        echo "ERROR: examples/stream: make failure"
        export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS
        preFail "ERROR: examples/stream: make failure"
    fi
#-------------------------------------------------------------------------------
# Test:
#     test_Ariel
# Purpose:
#     Exercise the Ariel
# Inputs:
#     None
# Outputs:
#     test_Ariel.out file
# Expected Results
#     Match of output file against reference file.  Will need to be fuzzy.
# Caveats:
#-------------------------------------------------------------------------------
Ariel_template() {
    Ariel_case=$1
    # Define a common basename for test output and reference
    # files. XML postprocessing requires this.
    testDataFileBase="test_Ariel_${Ariel_case}"
    outFile="${SST_TEST_OUTPUTS}/${testDataFileBase}.out"
    referenceFile="${SST_TEST_REFERENCE}/${testDataFileBase}.out"
    # Add basename to list for XML processing later
    L_TESTFILE+=(${testDataFileBase})
    startSeconds=`date +%s`

 
    echo " starting Directory `pwd`"
    saveDir=`pwd`

    # Define Software Under Test (SUT) and its runtime arguments
    sut="${SST_TEST_INSTALL_BIN}/sst"

    sutArgs="${SST_ROOT}/sst/elements/ariel/frontend/simple/examples/stream/${Ariel_case}.py"
    echo $sutArgs
    if [[ ${USE_GEM5:+isSet} == isSet ]] ; then
        export OMP_EXE=$SST_ROOT/test/testSuites/testopenMP/ompmybarrier/ompmybarrier
        echo $OMP_EXE
        ls -l $OMP_EXE
    fi
    if [[ ${USE_MEMH:+isSet} == isSet ]] ; then
        cd $SST_ROOT/sst/elements/ariel/frontend/simple      ## This is redundent
  
        ln -sf ${SST_ROOT}/sst/elements/memHierarchy/tests/DDR3_micron_32M_8B_x4_sg125.ini .
        ln -sf ${SST_ROOT}/sst/elements/memHierarchy/tests/system.ini .
    fi 

    Tol=1            ##  Set tolerance at 0.1%
    rm -f ${outFile}

    if [ -f ${sut} ] && [ -x ${sut} ]
    then
        # Run SUT
        ${sut} ${sutArgs} > $outFile
        ret=$?
        if [ $ret != 0 ]
        then
             echo ' '; echo WARNING: sst did not finish normally, RetVal= $ret ; echo ' '
             fail "WARNING: sst did not finish normally, RetVal= $ret"
             return
        fi

        RemoveComponentWarning

        wc ${outFile} ${referenceFile} 

        echo " "

        diff ${outFile} ${referenceFile} > /dev/null;
        if [ $? -ne 0 ]
        then
             ref=`wc ${referenceFile} | awk '{print $1, $2}'`; 
             new=`wc ${outFile}       | awk '{print $1, $2}'`;
                 if [ "$ref" == "$new" ]
                 then 
                     echo "    Output passed  LineWordCt match"
                 else
                     echo "    Output Flunked  lineWordCt Count match"
                     fail "Output Flunked  lineWordCt Count match"
                     compare_sorted ${outFile} ${referenceFile}
                     diff  ${outFile} ${referenceFile} 
                 fi
            echo " Next is word count of the diff:"
            diff  ${outFile} ${referenceFile} | wc
            compare_sorted ${outFile} ${referenceFile}
            echo ' '

        else
            echo oufFile is an exact match for Reference File
        fi

#        diff -u ${outFile} ${referenceFile}

    else
        # Problem encountered: can't find or can't run SUT (doesn't
        # really do anything in Phase I)
        ls -l ${sut}
        fail "Problem with SUT: ${sut}"
    fi

    cd $saveDir

    endSeconds=`date +%s`
    echo "     `grep 'Simulation is complete' $outFile`"
    echo "Ref: `grep 'Simulation is complete' $referenceFile`"
    echo " "
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo "Ariel ${Ariel_case}: Wall Clock Time  $elapsedSeconds seconds"
}

#  This is ugly bailing wire because the input files are in two diffently locations
ln -sf $SST_ROOT/examples/ivb-ariel.py $SST_ROOT/sst/elements/ariel/frontend/simple/examples/stream/ariel_ivb.py
ln -sf $SST_ROOT/examples/snb-ariel.py $SST_ROOT/sst/elements/ariel/frontend/simple/examples/stream/ariel_snb.py
#            ------
ls -l ${SST_ROOT}/sst/elements/ariel/frontend/simple/examples/stream

test_Ariel_runstream() {
    USE_GEM5=""
    USE_MEMH=""
    Ariel_template runstream
}
    

test_Ariel_testSt() {
    USE_GEM5=""
    USE_MEMH=""
    Ariel_template runstreamSt
}


test_Ariel_testNB() {
    USE_GEM5=""
    USE_MEMH=""
    Ariel_template runstreamNB
}

test_Ariel_memH_test() {
    USE_GEM5=""
    USE_MEMH="yes"
    Ariel_template memHstream
}

test_Ariel_test_ivb() {
    USE_GEM5="yes"
    USE_MEMH=""
    Ariel_template ariel_ivb
}

test_Ariel_test_snb() {
    USE_GEM5="yes"
    USE_MEMH=""
    Ariel_template ariel_snb
}



export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

cd $OPWD

export SST_TEST_ONE_TEST_TIMEOUT=100

# Invoke shunit2. Any function in this file whose name starts with
# "test"  will be automatically executed.
(. ${SHUNIT2_SRC}/shunit2)

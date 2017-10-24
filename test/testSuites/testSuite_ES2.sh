
TEST_SUITE_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
# Load test definitions
. $TEST_SUITE_ROOT/../include/testDefinitions.sh
. $TEST_SUITE_ROOT/../include/testSubroutines.sh

L_SUITENAME="SST__ES2_suite" # Name of this test suite; will be used to
                             # identify this suite in XML file. This
                             # should be a single string, no spaces
                             # please.

L_TESTFILE=()  # Empty list, used to hold test file names

mkdir -p $SST_TEST_ROOT/testSuites/ES2_folder

cd $SST_TEST_ROOT/testSuites/ES2_folder
cp $SST_ROOT/sst-elements/src/sst/elements/ember/test/emberLoad.py .
cp $SST_ROOT/sst-elements/src/sst/elements/ember/test/loadInfo.py .
cp $SST_ROOT/sst-elements/src/sst/elements/ember/test/networkConfig.py .
cp $SST_ROOT/sst-elements/src/sst/elements/ember/test/defaultParams.py .
pwd ; ls -ltr  | tail -5

ES2_after() {
        grep 'simulated time' outFile
        RetVal=$?
        TIME_FLAG=/tmp/TimeFlag_$$_${__timerChild} 
        if [ -e $TIME_FLAG ] ; then 
             echo " Time Limit detected at `cat $TIME_FLAG` seconds" 
             fail " Time Limit detected at `cat $TIME_FLAG` seconds" 
             rm $TIME_FLAG 
             return 
        fi 
    if [ $RetVal != 0 ] ; then
        fail "test failed"
        cat outFile
    fi
    endSeconds=`date +%s`
    elapsedSeconds=$(($endSeconds -$startSeconds))
    echo ": Wall Clock Time  $elapsedSeconds seconds"
    export startSeconds=$endSeconds
}

    if [ $SST_TEST_HOST_OS_KERNEL = "Darwin" ] ; then
        do_md5="md5 -r"
    else
        do_md5="md5sum"
    fi

ln -s $SST_TEST_ROOT/testInputFiles/ES2_List-of-Tests ./List-of-Tests
rm SHU.in
ind=1
while [ $ind -lt 127 ] 
do
   sed -n ${ind},${ind}p ./List-of-Tests > _tmp_${ind}
    
   if [ $ind -eq 0 ] ; then    ##  NOP -- model for limiting tests
       ind=$(( ind + 1 ))
       continue
   fi
   hash=`$do_md5 _tmp_${ind} | awk '{print $1}'`
##   hash=`md5sum _tmp_${ind} | awk '{print $1}'`
   indx=$(printf "%03d" $ind)
   echo "test_ES2_${indx}_${hash} () {" >> SHU.in
   echo "L_TESTFILE+=testES2_${indx}" >> SHU.in
   echo "cd $SST_TEST_ROOT/testSuites/ES2_folder" >> SHU.in
##   echo "echo \"sut == \$sut \" " >> SHU.in
   sed -i'.x' 's/$/ > outFile/' _tmp_${ind}
   sed -i'.z' 's/sst/${sut}/' _tmp_${ind}
   cat _tmp_${ind} >> SHU.in
   echo ES2_after >> SHU.in
   echo "}"  >> SHU.in

   ind=$(( ind + 1 ))

done


wc SHU.in
echo  SST_MULTI_THREAD_COUNT   = ${SST_MULTI_THREAD_COUNT}
if [[ ${SST_MULTI_THREAD_COUNT:+isSet} == isSet ]] && [ ${SST_MULTI_THREAD_COUNT} -gt 1 ] ; then
   sed -i'.x' '/^${sut}/s/${sut}/${sut} -n ${SST_MULTI_THREAD_COUNT}/' SHU.in
fi
wc SHU.in
echo  SST_MULTI_RANK_COUNT   = ${SST_MULTI_RANK_COUNT}

if [[ ${SST_MULTI_RANK_COUNT:+isSet} == isSet ]] && [ ${SST_MULTI_RANK_COUNT} -gt 1 ] ; then
 sed -i'.y' '/^${sut}/s/${sut}/mpirun -np ${SST_MULTI_RANK_COUNT} ${sut}/' SHU.in
fi    
wc SHU.in

   #   This is the code to run just selected tests from the sweep
   #        using the indices defined by SST_TEST_ES2_LIST
   #   An inclusive sub-list may be specified as "first-last"  (e.g. 7-10)

     if [[ ${SST_TEST_ES2_LIST:+isSet} == isSet ]] ; then
  echo " LIST is $SST_TEST_ES2_LIST"
         mv SHU.in SH_orig.in
         for IND in $SST_TEST_ES2_LIST
         do
  echo " IND is $IND "
             echo $IND | grep -e '-' > /dev/null   
             if [ $? != 0 ] ; then
#                            Single
                indx=$(printf "%03d" $IND)
                grep -A 5 ES2_${indx}_ SH_orig.in >> SHU.in
             else
#                            Inclusive
#     echo IND = $IND
                INDF=`echo $IND | awk -F'-' '{print $1}'`
                INDL=`echo $IND | awk -F'-' '{print $2}'`
#     echo "$INDF to $INDL"
                INDR=$INDF
                while [ $INDR -le $INDL ]
                do
#     echo In the INDR loop INDR = $INDR
                   indx=$(printf "%03d" $INDR)
                   grep -A 5 ES2_${indx}_ SH_orig.in >> SHU.in
                   INDR=$(($INDR+1))
                done    
             fi
          done
     fi

cd $SST_ROOT
export sut=${SST_TEST_INSTALL_BIN}/sst
export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS
export SST_TEST_ONE_TEST_TIMEOUT=200
export startSeconds=`date +%s`

(. ${SHUNIT2_SRC}/shunit2 $SST_TEST_ROOT/testSuites/ES2_folder/SHU.in)

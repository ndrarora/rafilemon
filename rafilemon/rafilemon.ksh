#!/bin/ksh
set -x
####################################################################
#  File Name         : rafilemon.ksh
#  Purpose           : Monitoring Strings in Files
#  Date Created      : Jun 07, 2006
#  Author            : Rajesh Arora 
#  Comments          : 
####################################################################


#### Change variables to implement this script on a new server --- Start ################

##Following Linese have hard values ####################### Start ########
PWORKDIR=/opt/oracle/home/DBA/scripts/rafilemon
ADMINEMAIL=rarora@8x8.com
RAFILMCFG="config/rafilemoncfg"
RAFILMLOGDIR="log"
#RAFILMLOG="${RAFILMLOGDIR}/rafilm.log"
RAFILMLOG="$PWORKDIR/$RAFILMLOGDIR/rafilm.log"
FILEEXT=".rafm"
ARCHFILEEXT=".ArCh"
ARCHFILETHRESH=9999999
TMPDIR=/tmp/
##Following Linese have hard values ####################### End   ########
HN="`hostname`"
#get_tempfile
#EATTACH=$TEMPFILE
#### Change variables to implement this script on a new server --- End   ################

########################## Do not run this program if already running ----  Start #######
#XX=`ps -ef|grep rafilemon.ksh|grep -v grep|grep -v vi|wc -l`
##XX=`ps -ef|grep rafilemon.ksh|grep -v grep|grep -v vi|grep -v $$|wc -l`
#echo "Number of rafilemon are"
#echo $XX
#echo `expr $XX`
#if [ `expr $XX` -gt 3 ]; 
#   then
#    echo "`date +%Y%m%d%H%M%S`  -- Another RAFILMON Already Running - Exiting" >> $RAFILMLOG
#    exit
#fi
########################## Do not run this program if already running ----  End   #######

DD=`date +%d`
MM=`date +%m`
YY=`date +%y`
MIN=`date +%M`
HR=`date +%H`


########################### Email Send Function Start #########################
###### EmailitF  to send email (1-> subj , 2->emailadd ,3->emailbody 4->Attachment File
EmailitF()
{
get_tempfile
EATTACH=$TEMPFILE
echo "$3" > $EATTACH
tail -3 "$4" >> $EATTACH
mailx -s "$1" "$2" < "$EATTACH"
}
########################### Email Send Function Finish ########################


########################### Email Send Function Start #########################
###### emailit  to send email (1-> subj , 2->emailadd ,3->emailbody
Emailit()
{
cat "$3" | mailx -s "$1" "$2" 
}
########################### Email Send Function Finish ########################

# getfilename function --- To create filename from wildcard date variables --- Start ##
getfilename()
{
DD=`date +%d`
MM=`date +%m`
YY=`date +%y`
x=$1
x=$(echo $x|sed 's/%d'/$DD/g)
x=$(echo $x|sed 's/%m'/$MM/g)
x=$(echo $x|sed 's/%y'/$YY/g)
echo $x
}
####### garbrem -- Garbage removal function ######## Start #######
garbrem()
{
  FN=rafilm_*
  rm $TMPDIR$FN
}
####### garbrem -- Garbage removal function ######## End   #######


### Function finish_now -------------------------------------- Start #
finish_now()
{
  garbrem
  #echo "****** RAFILMON Finished `date +%Y%m%d%H%M%S` *" >> $RAFILMLOG
  echo "`date +%Y%m%d%H%M%S`  -- RAFILMON Finished" >> $RAFILMLOG
}
### Function finish_now -------------------------------------- End   #
##### rm_file - Remove File ------------------------ Start #####
rm_file()
{
   (( $# > 1 )) && return 1
   [ -f "$1" -a -n "$1" ] && rm $1
}
##### rm_file - Remove File ------------------------ End   #####

########### Function get_tempfile                    Start #####
get_tempfile()
{
  #DDD=`date +%m%d%H%M%S`
  RND1="$RANDOM"
  RND2="$RANDOM"
  CURRSESS="rafilm_$$"
  #CURRSESS="rafilm_"
  #TEMPFILE="$TMPDIR$CURRSESS$RNDM$DDD"
  TEMPFILE="$TMPDIR$CURRSESS$RND1$RND2"
  rm_file $TEMPFILE
  echo " " > $TEMPFILE
  chmod 777 $TEMPFILE   
}
########### Function get_tempfile                    End   #####

################## Function crtdiffile -> create diff file  Start #######
crtdiffile()
{
set -x
FNCOMPARE=$FILELOC1/$FILENAME1$FILEEXT
ORIGFILE=$FILELOC1/$FILENAME1
ARCHFILE=$FILELOC1/$FILENAME1$ARCHFILEEXT
if [ ! -r $ORIGFILE ] 
   then
       FILEREADABLE="N"
       if [ "$HR$MIN" = "1200" ]; then
          EMAILADD=$ADMINEMAIL
          EMAILSUBJ="$HN:RAFILEMON:$ORIGFILE Not Readable"
          EMAILBODY="$HN:RAFILEMON: The File $ORIGFILE is Not Readable"
          Emailit "$EMAILSUBJ" "$EMAILADD" "$EMAILBODY"
          echo "`date +%Y%m%d%H%M%S` Email Sent Add->$EMAILADD Subj->$EMAILSUBJ Body->$EMAILBODY" >> $RAFILMLOG
        else
          EMAILBODY="$HN:RAFILEMON: The File $ORIGFILE is Not Readable"
          echo "`date +%Y%m%d%H%M%S` $EMAILBODY" >> $RAFILMLOG
       fi
    else 
       FILEREADABLE="Y"
       if [ ! -r $FNCOMPARE ]
          then
          touch $FNCOMPARE
       fi
       get_tempfile
       DIFFFILE=$TEMPFILE
       get_tempfile
       CPORIGFILE=$TEMPFILE
       cp -p $ORIGFILE $CPORIGFILE 
       #diff $FNCOMPARE $ORIGFILE > $DIFFFILE
       diff $FNCOMPARE $CPORIGFILE > $DIFFFILE

       DIFFSIZE=0
       DIFFSIZE=`ls -l $DIFFFILE | awk '{print $5}'`

       #ORIGFILESIZE=`ls -l $ORIGFILE | awk '{print $5}'`

fi
}
################## Function crtdiffile -> create diff file  Finish ######


#### Function cpfilefornextcomp to copy file for next compare --------- Start ###############
cpfilefornextcomp()
{
set -x
cp -p $CPORIGFILE $FNCOMPARE
}
#### Function cpfilefornextcomp to copy file for next compare --------- Finish ##############

#### Function filemon -> to monitor file(main processing) -- Start #####
filemon()
{
set -x
get_tempfile
GREPFILE=$TEMPFILE
grep "$WORD2" "$DIFFFILE" > $GREPFILE
if [ $? = 0 ]
   then
      EMAILSUBJ2="$HN:RAFILEMON:$EMAILSUBJ2"
      EMAILBODY2="$HN:RAFILEMON:$EMAILBODY2"
      EmailitF "$EMAILSUBJ2" "$EMAILADD3" "$EMAILBODY2" "$GREPFILE"
      echo "`date +%Y%m%d%H%M%S` Email Sent Add->$EMAILADD3 Subj->$EMAILSUBJ2 Body->$EMAILBODY2 Word->$WORD2 File->$ORIGFILE" >> $RAFILMLOG
fi
}
#### Function filemon -> to monitor file(main processing) -- Finish ####




############# The Program ############################# Start #########
cd ${PWORKDIR}

#echo "****** RAFILMON Started `date +%Y%m%d%H%M%S` *" >> $RAFILMLOG
echo "`date +%Y%m%d%H%M%S`  -- RAFILMON Started" >> $RAFILMLOG

BEGDATE="`date +%Y%m%d%H%M`"
BEGDAY="`date +%d`"
BEGHR="`date +%H`"
BEGMIN="`date +%M`"
BEGHRMIN="`date +%H%M`"
echo $BEGHRMIN
##### Main Logic Starts here ###########################################################

egrep ^findfile $RAFILMCFG | while read LINE1
do
   RUNFREQ1="`echo ${LINE1} | awk -F: '{print $5}'`"
   RUNIT="NO"
   ############### Decide if needs to be run based on Frequency ### Start #####
   # Frequency could be 2M   -> two minute
   #                    6M   -> five minutes
   #                    10M  -> ten minutes
   #                    60M  -> sixty minutes
   #                     1D  -> one day   

   if [ "$RUNFREQ1" = "" ]; then RUNFREQ1="1D"; fi

   if [ $RUNFREQ1 = "2M" ]; then
      a=`expr $BEGMIN % 2`
      if [ $a = 0 ];
          then
          RUNIT="YES"
      fi
   fi

   if [ "$RUNFREQ1" = "6M" ]; then
      a=`expr $BEGMIN % 6`
      if [ $a = 0 ];
         then
           RUNIT="YES"
      fi
   fi
   if [ "$RUNFREQ1" = "10M" ]; then
      a=`expr $BEGMIN % 10`
      if [ $a = 0 ];
         then
           RUNIT="YES"
      fi
   fi

   if [ "$RUNFREQ1" = "60M" ] && [ "$BEGMIN" = "00" ]; 
      then 
       RUNIT="YES" 
   fi

   if [ "$RUNFREQ1" = "1D" ] && [ "$BEGHRMIN" = "1400" ];
      then 
       RUNIT="YES"
   fi

   if [ $RUNIT = "NO" ]; 
       then 
         skip 
   fi

   ############### Decide if needs to be run based on Frequency ### End   #####

   FILESN1="`echo ${LINE1} | awk -F: '{print $2}'`"
   FILELOC1="`echo ${LINE1} | awk -F: '{print $3}'`"
   FILENAME1="`echo ${LINE1} | awk -F: '{print $4}'`"
   #### getfilename function converts the variables (%d,%m,%y) to current values
   FILENAME1=`getfilename $FILENAME1`
   RUNSTATUS="SUCCESS"
   FILEREADABLE="N"
   DIFFSIZE=0
   crtdiffile
   if [ $FILEREADABLE = "Y" ]; then
      egrep ^findword $RAFILMCFG | while read LINE2
      do
         FILESN2=`echo ${LINE2} | awk -F: '{print $2}'`
         if [ "$FILESN1" = "$FILESN2" ]; then 
            WORD2="`echo ${LINE2} | awk -F: '{print $3}'`"
            EMAILSUBJ2="`echo ${LINE2} | awk -F: '{print $4}'`"
            EMAILBODY2="`echo ${LINE2} | awk -F: '{print $5}'`"
            EMAILADDSN2="`echo ${LINE2} | awk -F: '{print $6}'`"
            EMAILSUBJ2="FILE->$FILENAME1,WORD->$WORD2  $EMAILSUBJ2"
            EMAILBODY2="FILE->$FILELOC1/$FILENAME1,WORD->$WORD2  $EMAILBODY2"
            egrep ^emailadd $RAFILMCFG | while read LINE3
            do
               EMAILADDSN3=`echo ${LINE3} | awk -F: '{print $2}'`
               if [ "$EMAILADDSN3" = "$EMAILADDSN2" ]; then 
                  EMAILADD3="`echo ${LINE3} | awk -F: '{print $3}'`"
                  break
               fi
            done
##### do processing
            filemon
            #break
            #skip
         fi
      done 
      if [ ! `expr $DIFFSIZE` -eq 0 ]; then
           echo "going for copy of $ORIGFILE"
           cpfilefornextcomp
        else
           echo "not going for copy of $ORIGFILE"
      fi
   fi
done
finish_now
exit
############################################ End of Script #################################################################

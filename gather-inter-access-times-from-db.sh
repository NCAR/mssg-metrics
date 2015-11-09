#!/bin/bash
#
# This script is intended to answer the question "When do users go 
# back for their files, if at all?" It provides both the number of 
# files in each category and the total data in each category (in bytes). 
#
# NOTE: Transfer clients and HPSS do the occasional odd thing with various
# fields in DB2. They cannot be relied upon to be infallible. For maximum 
# accuracy, we throw out those table rows that do not conform. We define a 
# conforming recalled file as having been read from the archive when:
#  - it has a non-zero value in the read count column of HPSS.BITFILE
#  - the read time is newer than or equal to the file create time in HPSS.BITFILE
#


# The bins are defined here. Make sure to properly edit the label_range
# if you are changing the seconds_range.
seconds_range=("0" "604800" "2592000" "5184000" "7776000" "31536000")
label_range=("Immediately" "1week" "30days" "60days" "90days" "1year")

# Since our workload has changed over time (e.g., with the advent of Glade),
# we limit the resutls to files that were created within the previous 5
# years
five_years_from_backup_timestamp=1275976800


# Connect to DB2
. /var/hpss/hpssdb/sqllib/db2profile
db2 connect to hsubsys1

#
# Total files and data
#
db2 "select count(1) as TOTAL_FILES,sum(BFATTR_DATA_LEN) as TOTAL_DATA \
  from hpss.bitfile where bfattr_create_time > $five_years_from_backup_timestamp "

#
# Never recalled files and data
#
db2 "select count(1) as FILES_NEVER_RECALLED, \
    sum(BFATTR_DATA_LEN) as DATA_NEVER_RECALLED \
    from hpss.bitfile where bfattr_read_count = 0 and bfattr_create_time > $five_years_from_backup_timestamp"

#
# The ranges of recall times
#
len=${#seconds_range[@]}
last=$((len - 1))
counter=0
for (( i=0; i<${len}; i++ ));
do
  # Our location in the array dictates the SQL to run
  case ${i} in 
    $last)
      # Last element - all recalls greater than this period of time
      db2 "select count(1) as FILE_COUNT, \
      sum(BFATTR_DATA_LEN) as RECALLEDDATA_OVER_${label_range[$i]} \
      from hpss.bitfile \
      where (BFATTR_READ_TIME-BFATTR_CREATE_TIME) >= ${seconds_range[$i]} \
      and bfattr_create_time > $five_years_from_backup_timestamp \
      and bfid in \
        (select bfid from hpss.bitfile where bfattr_read_count!=0 \
        and (bfattr_read_time>=bfattr_create_time) with ur) \
      with ur"
      ;;
    *)
      # First through penultimate element - all recalls between the periods of time
      db2 "select count(1) as FILE_COUNT, \
      sum(BFATTR_DATA_LEN) as RECALLEDDATA_${label_range[$i]}_TO_${label_range[$i+1]} \
      from hpss.bitfile \
      where (bfattr_read_time-bfattr_create_time) >= ${seconds_range[$i]} \
	    and (BFATTR_READ_TIME-BFATTR_CREATE_TIME) < ${seconds_range[$i+1]} \
      and bfattr_create_time > $five_years_from_backup_timestamp \
      and bfid in \
        (select bfid from hpss.bitfile where bfattr_read_count!=0 \
        and (bfattr_read_time>=bfattr_create_time) with ur) \
      with ur"
      ;;
    esac 
done

# cleanup
db2 terminate
exit 

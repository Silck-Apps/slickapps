
file="/srv/resources/scripts/monitoring/data/email.acknowledged"

while getopts "hny" OPTION 
do
  case $OPTION in
    h)
      usage
      return
      ;;
    n)
      echo "no" > $file
      echo "Set to No"
      ;;
    y)
      echo "yes" > $file
      echo "set to yes"
      ;;
    *)
      usage
      echo "Sorry! Try Again!!"
      return
      ;;
     esac
done



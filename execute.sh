FEEDBACK=false
while getopts ri:o:m:d: option
do
    case "${option}" in
  	r) FEEDBACK=true;;
		i) INPUT=${OPTARG};;
		o) OUTPUT=${OPTARG};;
		m) MODEL=${OPTARG};;
		d) NTCIR=${OPTARG};;
	esac
done
 
if $FEEDBACK
then
#echo "yo"
 	ruby PA1.rb -r-i $INPUT -o $OUTPUT -m $MODEL -d $NTCIR
else
#echo "hi"
 	ruby PA1.rb -i $INPUT -o $OUTPUT -m $MODEL -d $NTCIR
fi
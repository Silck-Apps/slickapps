alias md=mkdir

function setsyncserver {
servername="ispcfg"
case $1 in
        "01")
          server=$servername"02"
          ;;
        "02")
          server=$servername"01"
	  #server=$servername"-dev"
          ;;
	"ev")
	  server=$servername"02"
	  ;;
        *)
esac
echo $server
}

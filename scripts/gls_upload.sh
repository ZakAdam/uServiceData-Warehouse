echo 'Spustenie scriptu'
date +"%T"
	for i in {1..10}
do
	echo "$i"
	#curl -X POST -F 'file=@../../AdamZak/Faktury/gls Inv_981394898_Client_980003355.xls' localhost:4001/upload
	#curl -X POST -F 'file=@../../AdamZak/Faktury/gls Inv_981396513_Client_980003355.xls' localhost:4001/upload
	curl -X POST -F 'file=@../../AdamZak/Faktury/gls Inv_981406669_Client_980003355.xls' localhost:4001/upload
	#curl -X POST -F 'file=@../../AdamZak/Faktury/gls Inv_981401555_Client_980003355.xls' localhost:4001/upload
done

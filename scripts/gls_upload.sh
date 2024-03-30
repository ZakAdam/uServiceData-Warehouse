echo 'Spustenie scriptu'
date +"%T.%3N"
	for i in {1..5}
do
	echo "$i"
	#curl -X POST -F 'file=@../files/test_files/DPD/STATUSDATA_BA0274_D20210212T171809' localhost:4001/upload	#DPD
	#curl -X POST -F 'file=@../files/test_files/DHL/BTSR000151427.csv' localhost:4001/upload			#DHL
	#curl -X POST -F 'file=@../files/test_files/GEIS/9443335_InvoiceAtt_20230718_0404-15721130.csv' localhost:4001/upload
	#curl -X POST -F 'file=@../files/test_files/Heureka/product-review-muziker-sk.xml' localhost:4001/upload		#Heureka
	curl -X POST -F 'file=@../files/test_files/GLS/gls Inv_981406669_Client_980003355.xls' localhost:4001/upload	#GLS

	#curl -X POST -F 'file=@../files/test_files/GLS/gls Inv_981406669_Client_980003355.xls' -F 'conditions=keep_location,send_email' localhost:4001/upload
done
echo 'Konec scriptu'
date +"%T.%3N"

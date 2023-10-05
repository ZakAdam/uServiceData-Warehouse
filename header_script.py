# Sample text
text = "\n\n\n\n\n\n\n\n\n\n\n\n\nClient_980003355_Inv_981394898\n\tČíslo balíka\tDoobedňajšie\tVyzdvihnutie\tHUB\tŠtát\tPSČ\tMesto\tHmotnosť\tBalík/Adresa\tDobierka\tOdvolanie sa\tReferencia\tPríjemca\tPreberajúci\tCena\t24H\tTollFee\tDiesel Fee\tParcelType\tSenderID\tServiceList\tInkassoDate\tTransportFee\tOverWeightFee\tExpressFee\tSVFee\tCodFee\tPU-Country\tCreditCardFee\tManualLabelFee\tPostalAddr\tPickUpAddress (P&S)\tInvoiceNo\tInvoiceDate\tDeliverDate\tCurrency\n\t610271905\t\t29.12.2020\t12\tSK\t82109\tBRATISLAVA 2\t0.1\t1\t20.79\t161812774\t160701838\tSenica 1\tPreberajuci 1\t0\t0\t0\t0\t---\t980003355\tFDS|FSS|PCC\t1/7/2021\t0\t0\t0\t0\t0\t\t0.25\t0\tJozko Mrkvicka-     SK-82109 Bratislava, Kockova 3\tJozef Mak     SI-1000 Skalica, Ilkovicova. 43\t981386636\t2021. 01. 05.\t2021. 01. 07.\tEUR\n\t610272065\t\t29.12.2020\t12\tSK\t3854\tKRPELANY\t9.4\t1\t133.89\t161812401\t160701758\tSenica 2\tPreberajuci 2\t0\t0\t0\t0\t---\t980003355\tFDS|FSS|PCC\t1/5/2021\t0\t0\t0\t0\t0\t\t1.61\t0\tJozko Mrkvicka-     SK-82109 Bratislava, Kockova 4\tJozef Mak     SI-1000 Skalica, Ilkovicova. 44\t981386636\t2021. 01. 05.\t2021. 01. 05.\tEUR\n\t91096688435\t\t29.12.2020\t0\tCZ\t76701\t\t3.9\t1\t3950\t161810181\t170709065\tSenica 3\tPreberajuci 3\t0\t0\t0\t0\t---\t980003355\tPCC\t\t0\t0\t0\t0\t0\t\t1.81\t0\tJozko Mrkvicka-     SK-82109 Bratislava, Kockova 5\tJozef Mak     SI-1000 Skalica, Ilkovicova. 45\t981386636\t2021. 01. 05.\t2021. 01. 05.\tEUR\n\t91096688693\t\t30.12.2020\t0\tSI\t2311\t\t2.9\t1\t215.3\t161811640\t360619273\tSenica 4\tPreberajuci 4\t0\t0\t0\t0\t--"

# Split the text into lines
lines = text.split('\n')

# Find the header row (usually the first non-empty line)
header_row = None
for line in lines:
    if line.strip() != "" and line.strip() != "Client_980003355_Inv_981394898":
        header_row = line
        break

# Split the header row into individual headers using tab ('\t') as the delimiter
headers = header_row.split('\t')

# Print the headers
print("Headers:", headers)

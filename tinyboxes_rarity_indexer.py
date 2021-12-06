import json
import pymongo
import numpy as np

client = pymongo.MongoClient("localhost", 27017)
mydb = client["tinybox_attributes"]
myrec = mydb["minted_boxes"]


with open('minted_box_rarity.json') as a:
    dict = json.load(a)

colval1=0
colval2=0
colval3=0
colval4=0
colval5=0
colval6=0
colval7=0
colval8=0
colval9=0
colval10=0
colval11=0
colval12=0
colval13=0
colval14=0
colval15=0
colval16=0
rowval1=0
rowval2=0
rowval3=0
rowval4=0
rowval5=0
rowval6=0
rowval7=0
rowval8=0
rowval9=0
rowval10=0
rowval11=0
rowval12=0
rowval13=0
rowval14=0
rowval15=0
rowval16=0
scheme = np.zeros(shape=16)
mirroringcount = np.zeros(shape=23)
mirroringcount = mirroringcount.astype(int)

for j in range(1,1409):
    colval = (dict[j]["trait_columns"])
    if colval == 1:
        colval1 = colval1 +1
    if colval == 2:
        colval2 = colval2 +1
    if colval == 3:
        colval3 = colval3 +1
    if colval == 4:
        colval4 = colval4 +1
    if colval == 5:
        colval5 = colval5 +1
    if colval == 6:
        colval6 = colval6 +1
    if colval == 7:
        colval7 = colval7 +1
    if colval == 8:
        colval8 = colval8 +1
    if colval == 9:
        colval9 = colval9 +1
    if colval == 10:
        colval10 = colval10 +1
    if colval == 11:
        colval11 = colval11 +1
    if colval == 12:
        colval12 = colval12 +1
    if colval == 13:
        colval13 = colval13 +1
    if colval == 14:
        colval14 = colval14 +1
    if colval == 15:
        colval15 = colval15 +1
    if colval == 16:
        colval16 = colval16 +1
    rowval = (dict[j]["trait_rows"])
    if rowval == 1:
        rowval1 = rowval1 +1
    if rowval == 2:
        rowval2 = rowval2 +1
    if rowval == 3:
        rowval3 = rowval3 +1
    if rowval == 4:
        rowval4 = rowval4 +1
    if rowval == 5:
        rowval5 = rowval5 +1
    if rowval == 6:
        rowval6 = rowval6 +1
    if rowval == 7:
        rowval7 = rowval7 +1
    if rowval == 8:
        rowval8 = rowval8 +1
    if rowval == 9:
        rowval9 = rowval9 +1
    if rowval == 10:
        rowval10 = rowval10 +1
    if rowval == 11:
        rowval11 = rowval11 +1
    if rowval == 12:
        rowval12 = rowval12 +1
    if rowval == 13:
        rowval13 = rowval13 +1
    if rowval == 14:
        rowval14 = rowval14 +1
    if rowval == 15:
        rowval15 = rowval15 +1
    if rowval == 16:
        rowval16 = rowval16 +1
    schemeval = (dict[j]["trait_scheme"])
    if schemeval == 1:
        scheme[1] = scheme[1] +1
    if schemeval == 2:
        scheme[2] = scheme[2] +1
    if schemeval == 3:
        scheme[3] = scheme[3] +1
    if schemeval == 4:
        scheme[4] = scheme[4] +1
    if schemeval == 5:
        scheme[5] = scheme[5] +1
    if schemeval == 6:
        scheme[6] = scheme[6] +1
    if schemeval == 7:
        scheme[7]= scheme[7] +1
    if schemeval == 8:
        scheme[8] = scheme[8] +1
    if schemeval == 9:
        scheme[9] = scheme[9] +1
    if schemeval == 10:
        scheme[10] = scheme[10] +1
    if schemeval == 11:
        scheme[11] = scheme[11] +1
    if schemeval == 12:
        scheme[12] = scheme[12] +1
    if schemeval == 13:
        scheme[13] = scheme[13] +1
    if schemeval == 14:
        scheme[14] = scheme[14] +1
    if schemeval == 15:
        scheme[15] = scheme[15] +1
    if schemeval == 16:
        scheme[16] = scheme[16] +1
    mirroringval = (dict[j]["trait_mirroring"])
    mirroring = np.array([(0,1,2),(0,1,3),(0,2,1),(0,2,3),(0,3,1),(0,3,2),(1,0,2),(1,0,3),(1,2,0),(1,2,3),(1,3,0),(1,3,2),(2,0,1),(2,0,3),(2,1,0),(2,1,3),(2,3,0),(2,3,1),(3,0,1),(3,0,2),(3,1,0),(3,1,2),(3,2,0),(3,2,1)])
    print("mirroring: ")
    print (mirroring[0])
    #print(mirroring[0]).replace(" ",",")
    #print(mirroring[1]).replace(" ",",")
    print("endmirroring")
    if mirroringval == "1,1,1":
        mirroringcount[1] = mirroringcount[1] +1
    if mirroringval == "1,1,2":
        mirroringcount[2] = mirroringcount[2] +1
    if mirroringval == "1,1,3":
        mirroringcount[3] = mirroringcount[3] +1
    if mirroringval == "1,2,1":
        mirroringcount[4] = mirroringcount[4] +1
    if mirroringval == "1,3,1":
        mirroringcount[5] = mirroringcount[5] +1
    if mirroringval == "2,1,1":
        mirroringcount[6] = mirroringcount[6] +1
    if mirroringval == "3,1,1":
        mirroringcount[7]= mirroringcount[7] +1
    if mirroringval == "1,2,1":
        mirroringcount[8] = mirroringcount[8] +1
    if mirroringval == "1,3,1":
        mirroringcount[9] = mirroringcount[9] +1
    if mirroringval == "2,2,1":
        mirroringcount[10] = mirroringcount[10] +1
    if mirroringval == "2,3,1":
        mirroringcount[11] = mirroringcount[11] +1
    if mirroringval == "3,3,1":
        mirroringcount[12] = mirroringcount[12] +1
    if mirroringval == "3,3,2":
        mirroringcount[13] = mirroringcount[13] +1
    if mirroringval == "3,3,3":
        mirroringcount[14] = mirroringcount[14] +1
    if mirroringval == "1,2,2":
        mirroringcount[15] = mirroringcount[15] +1
    if mirroringval == "2,1,2":
        mirroringcount[16] = mirroringcount[16] +1
    if mirroringval == "2,1,3":
        mirroringcount[17] = mirroringcount[17] +1
    if mirroringval == "2,3,2":
        mirroringcount[18] = mirroringcount[18] +1
    if mirroringval == "0,0,0":
        mirroringcount[19] = mirroringcount[19] +1
    if mirroringval == "0,0,1":
        mirroringcount[20] = mirroringcount[20] +1
    if mirroringval == "0,1,0":
        mirroringcount[21] = mirroringcount[21] +1
    if mirroringval == "1,0,0":
        mirroringcount[22] = mirroringcount[22] +1



print( "column:  1 count" )
print( colval1 )        
print( "column:  2 count" )
print( colval2 )        
print( "column:  3 count" )
print( colval3 )
print( "column:  4 count" )
print( colval4 ) 
print( "column:  5 count" )
print( colval5 )
print( "column:  6 count" )
print( colval6 )
print( "column:  7 count" )
print( colval7 )                                       
print( "column:  8 count" )
print( colval8 )                                       
print( "column:  9 count" )
print( colval9 )                                       
print( "column:  10 count" )
print( colval10 )                                       
print( "column:  11 count" )
print( colval11 )                                       
print( "column:  12 count" )
print( colval12 )                                       
print( "column:  13 count" )
print( colval13 )                                       
print( "column:  14 count" )
print( colval14 )                                       
print( "column:  15 count" )
print( colval15 )                                       
print( "column:  16 count" )
print( colval16 )                                       
print( "row:  1 count" )
print( rowval1 )        
print( "scheme:  1 count" )
print( scheme[1] )        
print( "mirroring:  1 count" )
print( mirroringcount[1] )        
print( "mirroring:  2 count" )
print( mirroringcount[2] )        
print( "mirroring:  3 count" )
print( mirroringcount[3] )        
print( "mirroring:  4 count" )
print( mirroringcount[4] )        
print( "mirroring:  5 count" )
print( mirroringcount[5] )        
print( "mirroring:  6 count" )
print( mirroringcount[6] )        




import json
import pymongo
import numpy as np

# dev notesq   

# shades is missing 6 and 7 data for some reason, reworking that
# contrast is fixed. 

# todo: 
# rewrite clunky logic used for initial two traits- cols and rows.. :p
# provide json file to be comsumed by tinyboxbot, format rarity report for each non- LE token 
# -gw



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

mirroring = np.array([(0,1,2),(0,1,3),(0,2,1),(0,2,3),(0,3,1),(0,3,2),(1,0,2),(1,0,3),(1,2,0),(1,2,3),(1,3,0),(1,3,2),(2,0,1),(2,0,3),(2,1,0),(2,1,3),(2,3,0),(2,3,1),(3,0,1),(3,0,2),(3,1,0),(3,1,2),(3,2,0),(3,2,1)])
shapes = np.array([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30])

mirroringcount = np.zeros(shape=24)
mirroringcount = mirroringcount.astype(int)
#shapes = np.zeros(shape=30)
shapescount = np.zeros(shape=30)
shapescount = shapescount.astype(int)
spread = np.linspace(0,100,101)
spread = spread.astype(int)
spreadcount = np.zeros(shape=101)
spreadcount = spreadcount.astype(int)
hues = np.linspace(0,359,360)
huescount = np.zeros(shape=360)
lightness = np.linspace(1,100,100)
lightnesscount = np.zeros(shape=100)
animation = np.array(["Snap Spin 90","Snap Spin 180","Snap Spin 270","Snap Spin Tri","Snap Spin Quad","Snap Spin Tetra","Spin","Slow Mo","Clockwork","Spread","Staggered Spread","Jitter","Jiggle","Jolt","Grow n Shrink","Squash n Stretch","Round","Glide","Wave","Fade","Skew X","Skew Y","Stretch","Jello"])
animationcount = np.zeros(shape=24)
shades = np.linspace(1,7,7)
shadescount = np.zeros(shape=7)
hatching = np.linspace(1,31,31)
hatchingcount = np.zeros(shape=31)
contrast = np.linspace(0,100,101)
contrast=contrast.astype(int)
contrastcount = np.zeros(shape=101)
contrastcount = contrastcount.astype(int)


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
    mirroringval = (dict[j]["trait_mirroring"])
    shapesval = (dict[j]["trait_shapes"])
    spreadval = (dict[j]["trait_spread"])
    spreadval = spreadval.rstrip(spreadval[-1])
    huesval = (dict[j]["trait_hue"])
    lightnessval = (dict[j]["trait_lightness"])
    animationval = (dict[j]["trait_animation"])
    shadesval = (dict[j]["trait_shades"])
    hatchingval = (dict[j]["trait_hatching"])
    contrastval = (dict[j]["trait_contrast"])
#    contrastval = contrastval.rstrip(contrastval[-1])

    for k in range(0,len(mirroring)):   
        flag1 =  "[" + mirroringval.replace(","," ") + "]"
        flag2 = str(mirroring[k])
        if flag1 == flag2:
            mirroringcount[k] = mirroringcount[k] +1

    for k in range(0,len(shapes)):
        flag2 = shapes[k]
        if shapesval == flag2:
            shapescount[k] = shapescount[k] +1

    for k in range(0,len(spread)):
        spreadval=int(spreadval)
        flag2 = int(spread[k])
        if spreadval == flag2:
            spreadcount[k] = spreadcount[k] +1

    for k in range(0,len(hues)):
        huesval=int(huesval)
        flag2 = int(hues[k])
        if huesval == flag2:
            huescount[k] = huescount[k] +1

    for k in range(0,len(lightness)):
        lightnessval=int(lightnessval)
        flag2 = int(lightness[k])
        if lightnessval == flag2:
            lightnesscount[k] = lightnesscount[k] +1

    for k in range(0,len(animation)):
        flag2 = animation[k]
        if animationval == flag2:
            animationcount[k] = animationcount[k] +1

    for k in range(0,len(shades)):
        flag2 = shades[k]
        if shadesval == flag2:
            shadescount[k] = shadescount[k] +1

    for k in range(0,len(hatching)):
        flag2 = hatching[k]
        if hatchingval == flag2:
            hatchingcount[k] = hatchingcount[k] +1

    for k in range(0,len(contrast)):
        print ("contrast")
        print (contrastval)
        print ( contrast[k] )
        flag2 = int(contrast[k])
        if contrastval == flag2:
            contrastcount[k] = contrastcount[k] +1







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
print( "row:  2 count" )
print( rowval2 )        
print( "row:  3 count" )
print( rowval3 )        
print( "row:  4 count" )
print( rowval4 )        
print( "row:  5 count" )
print( rowval5 )        
print( "row:  6 count" )
print( rowval6 )        
print( "row:  7 count" )
print( rowval7 )        
print( "row:  8 count" )
print( rowval8 )        
print( "row:  9 count" )
print( rowval9 )        
print( "row:  10 count" )
print( rowval10 )        
print( "row:  11 count" )
print( rowval11 )        
print( "row:  12 count" )
print( rowval12 )        
print( "row:  13 count" )
print( rowval13 )        
print( "row:  14 count" )
print( rowval14 )        
print( "row:  15 count" )
print( rowval15 )        
print( "row:  16 count" )
print( rowval16 )        

       

for k in range(0,len(mirroring)):
    print ( "mirroring: " )
    print ( mirroring[k] )
    print ( mirroringcount[k] )
  
for k in range(0,len(shapes)):
    print ( "shapes: " )
    print ( shapes[k] )
    print ( shapescount[k] )
  
for k in range(0,len(spread)):
    print ( "spread: " )
    print ( spread[k] )
    print ( spreadcount[k] )
  
for k in range(0,len(hues)):
    print ( "hues: " )
    print ( hues[k].astype(int) )
    print ( huescount[k].astype(int) )
  
for k in range(0,len(lightness)):
    print ( "lightness: " )
    print ( lightness[k].astype(int) )
    print ( lightnesscount[k].astype(int) )
  
for k in range(0,len(animation)):
    print ( "animation: " )
    print ( animation[k] )
    print ( animationcount[k].astype(int) )  

for k in range(0,len(shades)):
    print ( "shades: " )
    print ( shades[k] )
    print ( shadescount[k].astype(int) )  

for k in range(0,len(hatching)):
    print ( "hatching: " )
    print ( hatching[k] )
    print ( hatchingcount[k].astype(int) )  

for k in range(0,len(contrast)):
    print ( "contrast: " )
    print ( contrast[k] )
    print ( contrastcount[k].astype(int) )  

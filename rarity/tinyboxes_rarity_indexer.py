import json
import pymongo
import numpy as np

# dev notes
#
# shades is missing 6 and 7 data for some reason
#
 # -gw

client = pymongo.MongoClient("localhost", 27017)
mydb = client["tinybox_attributes"]
myrec = mydb["minted_boxes"]

with open('minted_box_rarity.json') as a:
    dict = json.load(a)

rows = np.linspace(1,16,16)
rows = rows.astype(int)
rowscount = np.zeros(shape=16)
rowscount = rowscount.astype(int)
cols = np.linspace(1,16,16)
cols = cols.astype(int)
colscount = np.zeros(shape=16)
colscount = colscount.astype(int)
mirroring = np.array([(0,1,2),(0,1,3),(0,2,1),(0,2,3),(0,3,1),(0,3,2),(1,0,2),(1,0,3),(1,2,0),(1,2,3),(1,3,0),(1,3,2),(2,0,1),(2,0,3),(2,1,0),(2,1,3),(2,3,0),(2,3,1),(3,0,1),(3,0,2),(3,1,0),(3,1,2),(3,2,0),(3,2,1)])
mirroringcount = np.zeros(shape=24)
mirroringcount = mirroringcount.astype(int)
shapes = np.linspace(1,30,30)
shapes = shapes.astype(int)
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
shades = shades.astype(int)
shadescount = np.zeros(shape=7)
shadescount = shadescount.astype(int)
hatching = np.linspace(1,31,31)
hatchingcount = np.zeros(shape=31)
contrast = np.linspace(0,100,101)
contrast = contrast.astype(int)
contrastcount = np.zeros(shape=101)
contrastcount = contrastcount.astype(int)

for j in range(1,1409):

    rowsval = (dict[j]["trait_rows"])
    colsval = (dict[j]["trait_columns"])
    mirroringval = (dict[j]["trait_mirroring"])
    shapesval = (dict[j]["trait_shapes"])
    spreadval = (dict[j]["trait_spread"])
    spreadval = spreadval.rstrip(spreadval[-1])
    huesval = (dict[j]["trait_hue"])
    lightnessval = (dict[j]["trait_lightness"])
    animationval = (dict[j]["trait_animation"])
    shadesval = (dict[j]["trait_shades"])
    hatchingval = (dict[j]["trait_hatching"])
    contrastval = str((dict[j]["trait_contrast"]))
    contrastval = contrastval.rstrip(contrastval[-1])

    for k in range(0,len(rows)):
        flag2 = rows[k]
        if rowsval == flag2:
            rowscount[k] = rowscount[k] +1

    for k in range(0,len(cols)):
        flag2 = cols[k]
        if colsval == flag2:
            colscount[k] = colscount[k] +1

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
        flag2 = str(contrast[k])
        if contrastval == flag2:
            contrastcount[k] = contrastcount[k] +1

for k in range(0,len(cols)):
    print ( "cols: " )
    print ( cols[k] )
    print ( colscount[k] )
  
for k in range(0,len(rows)):
    print ( "rows: " )
    print ( rows[k] )
    print ( rowscount[k] )

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

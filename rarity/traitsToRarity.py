import json
#import pymongo
import numpy as np

#client = pymongo.MongoClient("localhost", 27017)
#mydb = client["tinybox_attributes"]
#myrec = mydb["rarity"]

with open('traits.json') as a:
    dict = json.load(a)

rows = np.linspace(1,30,30)
rows = rows.astype(int)
rowscount = np.zeros(shape=30)
rowscount = rowscount.astype(int)
cols = np.linspace(1,30,30)
cols = cols.astype(int)
colscount = np.zeros(shape=30)
colscount = colscount.astype(int)

mirroring = np.array([(0,1,2),(0,1,3),(0,2,1),(0,2,3),(0,3,1),(0,3,2),(1,0,2),(1,0,3),(1,2,0),(1,2,3),(1,3,0),(1,3,2),(2,0,1),(2,0,3),(2,1,0),(2,1,3),(2,3,0),(2,3,1),(3,0,1),(3,0,2),(3,1,0),(3,1,2),(3,2,0),(3,2,1),(0,0,0),(1,3,3),(1,1,3),(3,1,3),(2,1,2),(3,2,3),(3,0,0),(3,3,3),(3,2,2),(1,3,1),(2,3,3),(1,1,1),(2,0,0),(0,3,0),(1,1,2),(3,3,0),(2,2,3),(2,2,2),(1,0,3),(2,2,0),(0,0,3),(3,1,1),(0,3,3),(1,2,1),(3,3,2),(0,1,0),(3,3,1),(1,1,0),(3,0,3),(1,0,0),(0,2,0),(0,0,1),(0,1,1),(2,3,2),(2,2,1),(2,0,2),(1,0,1),(1,2,2),(2,1,1),(0,0,2),(0,2,2)])


mirroringcount = np.zeros(shape=65)
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
saturation = np.linspace(0,359,360)
saturationcount = np.zeros(shape=360)
minheight = np.linspace(0,359,360)
minheightcount = np.zeros(shape=360)
maxheight = np.linspace(0,359,360)
maxheightcount = np.zeros(shape=360)
minwidth = np.linspace(0,359,360)
minwidthcount = np.zeros(shape=360)
maxwidth = np.linspace(0,359,360)
maxwidthcount = np.zeros(shape=360)
lightness = np.linspace(1,100,100)
lightnesscount = np.zeros(shape=100)
animation = np.array(["Snap Spin 90","Snap Spin 180","Snap Spin 270","Snap Spin Tri","Snap Spin Quad","Snap Spin Tetra","Spin","Slow Mo","Clockwork","Spread","Staggered Spread","Jitter","Jiggle","Jolt","Grow n Shrink","Squash n Stretch","Round","Glide","Wave","Fade","Skew X","Skew Y","Stretch","Jello","Unfurl"])
animationcount = np.zeros(shape=25)
shades = np.linspace(0,7,8)
shades = shades.astype(int)
shadescount = np.zeros(shape=8)
shadescount = shadescount.astype(int)
hatching = np.linspace(1,31,31)
hatchingcount = np.zeros(shape=31)
contrast = np.linspace(0,100,101)
contrast = contrast.astype(int)
contrastcount = np.zeros(shape=101)
contrastcount = contrastcount.astype(int)


## attribute counts

for j in range(1,1409):

    rowsval = (dict[j]["trait_rows"])
    colsval = (dict[j]["trait_columns"])
    mirroringval = (dict[j]["trait_mirroring"])
    saturationval = (dict[j]["trait_saturation"])
    minheightval = (dict[j]["trait_minheight"])
    maxheightval = (dict[j]["trait_maxheight"])
    minwidthval = (dict[j]["trait_minwidth"])
    maxwidthval = (dict[j]["trait_maxwidth"])
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

    for k in range(0,len(saturation)):
        flag2 = saturation[k]
        if saturationval == flag2:
            saturationcount[k] = saturationcount[k] +1

    for k in range(0,len(minwidth)):
        flag2 = minwidth[k]
        if minwidthval == flag2:
            minwidthcount[k] = minwidthcount[k] +1

    for k in range(0,len(maxwidth)):
        flag2 = maxwidth[k]
        if maxwidthval == flag2:
            maxwidthcount[k] = maxwidthcount[k] +1

    for k in range(0,len(minheight)):
        flag2 = minheight[k]
        if minheightval == flag2:
            minheightcount[k] = minheightcount[k] +1

    for k in range(0,len(maxwidth)):
        flag2 = maxwidth[k]
        if maxwidthval == flag2:
            maxwidthcount[k] = maxwidthcount[k] +1

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
        flag2 = str(shades[k])
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

print("    {")
print("  \"boxtraits\": [")
print("    {")
print("      \"columns\": [")

for k in range(0,len(cols)-1):
    j = colscount[k]
    l = len(cols)-1

    if k < l: 
    	print("          \""+str(j)+"\"")
    else: 
    	print("          \""+str(j)+"\" ,")

print("     ]")
print("    },")
print ("{")
print("      \"rows\": [")
 

for k in range(0,len(rows)):
    j = rowscount[k]
    print("        \""+str(j)+"\" ,")


print("     ]")
print("    },")
print ("{")
print("      \"saturation\": [")
 

for k in range(0,len(saturation)):
    j = saturationcount[k]
    print("        \""+str(j)+"\" ,")


print("     ]")
print("    },")
print ("{")
print("      \"minheight\": [")
 

for k in range(0,len(minheight)):
    j = minheightcount[k]
    print("        \""+str(j)+"\" ,")


print("     ]")
print("    },")
print ("{")
print("      \"maxheight\": [")
 

for k in range(0,len(maxheight)):
    j = maxheightcount[k]
    print("        \""+str(j)+"\" ,")

print("     ]")
print("    },")
print ("{")
print("      \"minwidth\": [")
 

for k in range(0,len(minwidth)):
    j = minwidthcount[k]
    print("        \""+str(j)+"\" ,")

print("     ]")
print("    },")
print ("{")
print("      \"maxwidth\": [")
 

for k in range(0,len(maxwidth)):
    j = maxwidthcount[k]
    print("        \""+str(j)+"\" ,")


print("     ]")
print("    },")
print ("{")
print("      \"mirroring\": [")
 

for k in range(0,len(mirroring)):
    j = mirroringcount[k]
    print("          \" "+str(j)+"\" ,")
 

print("     ]")
print("    },")
print ("{")
print("      \"shapes\": [")
 

for k in range(0,len(shapes)):
    j = shapescount[k]
    print("          \" "+str(j)+"\" ,")
 

print("     ]")
print("    },")
print ("{")
print("      \"spread\": [")
 

for k in range(0,len(spread)):
    j = spreadcount[k]
    print("          \" "+str(j)+"\" ,")
 

print("     ]")
print("    },")
print ("{")
print("      \"hue\": [")
 

for k in range(0,len(hues)):
    j = huescount[k].astype(int)
    print("      \""+str(j)+"\" ,")
 

print("     ]")
print("    },")
print ("{")
print("      \"lightness\": [")
 

for k in range(0,len(lightness)):
    j = lightnesscount[k].astype(int)
    print("  \" "+str(j)+"\" ,")


print("     ]")
print("    },")
print ("{")
print("      \"animation\": [")
 

for k in range(0,len(animation)):
    j = animationcount[k].astype(int)
    print("  \" "+str(j)+" \" ,")


print("     ]")
print("    },")
print ("{")
print("      \"shades\": [")
 

for k in range(0,len(shades)):
    j = shadescount[k].astype(int)  
    print("         \" "+str(j)+" \" ,")


print("     ]")
print("    },")
print ("{")
print("      \"hatching\": [")
 

for k in range(0,len(hatching)):
    j = hatchingcount[k].astype(int)  
    print(" \""+str(j)+"\",")


print("     ]")
print("    },")
print ("{")
print("      \"contrast\": [")
 

for k in range(0,len(contrast)):
    j = contrastcount[k].astype(int)

    print("      \" "+str(j)+"\", ")

print("     ]")
print("    }")
 
    #x = myrec.insert_one(mylist)
    # print list of the _id values of the inserted documents:
    #print(x.inserted_id)

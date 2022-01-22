import json
import numpy as np


numberofboxes = 1414
quantity = numberofboxes

mirroring = np.array([(0,1,2),(0,1,3),(0,2,1),(0,2,3),(0,3,1),(0,3,2),(1,0,2),(1,0,3),(1,2,0),(1,2,3),(1,3,0),(1,3,2),(2,0,1),(2,0,3),(2,1,0),(2,1,3),(2,3,0),(2,3,1),(3,0,1),(3,0,2),(3,1,0),(3,1,2),(3,2,0),(3,2,1),(0,0,0),(1,3,3),(1,1,3),(3,1,3),(2,1,2),(3,2,3),(3,0,0),(3,3,3),(3,2,2),(1,3,1),(2,3,3),(1,1,1),(2,0,0),(0,3,0),(1,1,2),(3,3,0),(2,2,3),(2,2,2),(1,0,3),(2,2,0),(0,0,3),(3,1,1),(0,3,3),(1,2,1),(3,3,2),(0,1,0),(3,3,1),(1,1,0),(3,0,3),(1,0,0),(0,2,0),(0,0,1),(0,1,1),(2,3,2),(2,2,1),(2,0,2),(1,0,1),(1,2,2),(2,1,1),(0,0,2),(0,2,2)])
animation = np.array(["Snap Spin 90","Snap Spin 180","Snap Spin 270","Snap Spin Tri","Snap Spin Quad","Snap Spin Tetra","Spin","Slow Mo","Clockwork","Spread","Staggered Spread","Jitter","Jiggle","Jolt","Grow n Shrink","Squash n Stretch","Round","Glide","Wave","Fade","Skew X","Skew Y","Stretch","Jello","Unfurl"])



with open('traits.json') as a:
    dict = json.load(a)

with open('rarity.json') as b:
    rarity = json.load(b)


for j in range(0,numberofboxes):
    print ("{\"Box\": " + str(j + 1) + ",")

    colval = (dict[j]["trait_columns"])
    print( "\"Columns_value\": \"" + str(colval) + "\",")
    colval = colval-1
    colrarity = (rarity["boxtraits"][0]["columns"][colval])
    percentage = round((int(colrarity) / int(numberofboxes))*100,2)
    print ("\"Columns_rarity\": \"" + str(percentage)+"%\" ,")

    rowval = (dict[j]["trait_rows"])
    print( "\"Rows_value\": \"" + str(rowval) +"\",")
    rowval = rowval-1
    rowrarity = (rarity["boxtraits"][1]["rows"][rowval])
    percentage = round((int(rowrarity) / int(quantity))*100,2)
    print ("\"Row_rarity\": \"" + str(percentage)+"%\" ,")

    saturationval = (dict[j]["trait_saturation"])
    print( "\"saturation_value\": \"" + str(saturationval) +"\",")
    saturationval = saturationval-1
    saturationrarity = (rarity["boxtraits"][2]["saturation"][saturationval])
    try:
        percentage = round((int(saturationrarity) / int(quantity))*100,2)
    except:
        percentage = "0"
    print ("\"Saturation_rarity\": \"" + str(percentage)+"%\" ,")

    minheightval = (dict[j]["trait_minheight"])
    print( "\"minheight_value\": \"" + str(minheightval) +"\",")
    minheightval = minheightval-1
    minheightrarity = (rarity["boxtraits"][3]["minheight"][minheightval])
    try:
        percentage = round((int(minheightrarity) / int(quantity))*100,2)
    except:
        percentage = "0"
    print ("\"Minheight_rarity\": \"" + minheightrarity)

    maxheightval = (dict[j]["trait_maxheight"])
    print( "\"maxheight_value\": \"" + str(maxheightval) +"\",")
    print( maxheightval )
    maxheightval = maxheightval-1
    maxheightrarity = (rarity["boxtraits"][4]["maxheight"][maxheightval])
    try:
        percentage = round((int(maxheightrarity) / int(quantity))*100,2)
    except:
        percentage = "0"
    print ("\"Maxheight_rarity\": \"" + str(percentage)+"%\" ,")

    minwidthval = (dict[j]["trait_minwidth"])
    print( "\"minwidth_value\": \"" + str(minwidthval) +"\",")
    minheightval = minheightval-1
    minheightrarity = (rarity["boxtraits"][5]["minwidth"][minwidthval])
    try:
        percentage = round((int(minheightrarity) / int(quantity))*100,2)
    except:
        percentage = "0"
    print ("\"Minheight_rarity\": \"" + str(percentage)+"%\" ,")

    maxwidthval = (dict[j]["trait_maxwidth"])
    print( "\"maxwidth_value\": \"" + str(maxwidthval) +"\",")
    maxwidthval = maxwidthval-1
    maxwidthrarity = (rarity["boxtraits"][6]["maxwidth"][maxwidthval])
    try:
        percentage = round((int(maxwidthrarity) / int(quantity))*100,2)
    except:
        percentage = "0"
    print ("\"Maxwidth_rarity\": \"" + str(percentage)+"%\" ,")

    mirroringval = (dict[j]["trait_mirroring"])
    print ("\"Mirroring_value\": \"" + mirroringval + "\",")
    if mirroringval == "0,1,2":
        mirroringval = 0 
    if mirroringval == "0,1,3":
        mirroringval = 1 
    if mirroringval == "0,2,1":
        mirroringval = 2 
    if mirroringval == "0,2,3":
        mirroringval = 3 
    if mirroringval == "0,3,1":
        mirroringval = 4 
    if mirroringval == "0,3,2":
        mirroringval = 5 
    if mirroringval == "1,0,2":
        mirroringval = 6 
    if mirroringval == "1,0.3":
        mirroringval = 7 
    if mirroringval == "1,2,0":
        mirroringval = 8 
    if mirroringval == "1,2,3":
        mirroringval = 9 
    if mirroringval == "1,3,0":
        mirroringval = 10 
    if mirroringval == "1,3,2":
        mirroringval = 11 
    if mirroringval == "2,0,1":
        mirroringval = 12 
    if mirroringval == "2,0,3":
        mirroringval = 13
    if mirroringval == "2,1,0":
        mirroringval = 14 
    if mirroringval == "2,1,3":
        mirroringval = 15 
    if mirroringval == "2,3,0":
        mirroringval = 16 
    if mirroringval == "2,3,1":
        mirroringval = 17 
    if mirroringval == "3,0,1":
        mirroringval = 18 
    if mirroringval == "3,0,2":
        mirroringval = 19 
    if mirroringval == "3,1,0":
        mirroringval = 20 
    if mirroringval == "3,1,2":
        mirroringval = 21 
    if mirroringval == "3,2,0":
        mirroringval = 22 
    if mirroringval == "3,2,1":
        mirroringval = 23 
    if mirroringval == "0,0,0":
        mirroringval = 24 
    if mirroringval == "1,3,3":
        mirroringval = 25 
    if mirroringval == "1,1,3":
        mirroringval = 26 
    if mirroringval == "3,1,3":
        mirroringval = 26 
    if mirroringval == "2,1,2":
        mirroringval = 27 
    if mirroringval == "3,2,3":
        mirroringval = 28 
    if mirroringval == "3,0,0":
        mirroringval = 29 
    if mirroringval == "3,3,3":
        mirroringval = 30 
    if mirroringval == "3,2,2":
        mirroringval = 31         
    if mirroringval == "1,3,1":
        mirroringval = 32         
    if mirroringval == "2,3,3":
        mirroringval = 33  
    if mirroringval == "1,1,1":
        mirroringval = 34 
    if mirroringval == "2,0,0":
        mirroringval = 35 
    if mirroringval == "0,3,0":
        mirroringval = 36 
    if mirroringval == "1,1,2":
        mirroringval = 37         
    if mirroringval == "3,3,0":
        mirroringval = 38  
    if mirroringval == "2,2,3":
        mirroringval = 39    
    if mirroringval == "2,2,2":
        mirroringval = 40        
    if mirroringval == "1,0,3":
        mirroringval = 41  
    if mirroringval == "2,2,0":
        mirroringval = 42      
    if mirroringval == "0,0,3":
        mirroringval = 43   
    if mirroringval == "3,1,1":
        mirroringval = 44   
    if mirroringval == "0,3,3":
        mirroringval = 45   
    if mirroringval == "1,2,1":
        mirroringval = 46   
    if mirroringval == "3,3,2":
        mirroringval = 47   
    if mirroringval == "0,1,0":
        mirroringval = 48     
    if mirroringval == "3,3,1":
        mirroringval = 48        
    if mirroringval == "1,1,0":
        mirroringval = 49              
    if mirroringval == "3,0,3":
        mirroringval = 50
    if mirroringval == "1,0,0":
        mirroringval = 51
    if mirroringval == "0,2,0":
        mirroringval = 52
    if mirroringval == "0,0,1":
        mirroringval = 53       
    if mirroringval == "0,1,1":
        mirroringval = 54  
    if mirroringval == "2,3,2":
        mirroringval = 55          
    if mirroringval == "2,2,1":
        mirroringval = 56          
    if mirroringval == "2,0,2":
        mirroringval = 57          
    if mirroringval == "1,0,1":
        mirroringval = 58 
    if mirroringval == "1,2,2":
        mirroringval = 59         
    if mirroringval == "2,1,1":
        mirroringval = 60         
    if mirroringval == "0,0,2":
        mirroringval = 61  
    if mirroringval == "0,2,2":
        mirroringval = 62  


    mirroringrarity = (rarity["boxtraits"][7]["mirroring"][int(mirroringval)])
    percentage = round((int(mirroringrarity) / int(quantity))*100,2)
    print ("\"Mirroring_rarity\": \"" + str(percentage)+"%\",")

    shapeval = (dict[j]["trait_shapes"])
    print("\"Shape_value\": \"" + str(shapeval) + "\",")
    shapeval = shapeval-1
    shaperarity = (rarity["boxtraits"][8]["shapes"][int(shapeval)])
    percentage = round((int(shaperarity) / int(quantity))*100,2)
    print ("\"Shape_rarity\": \"" + str(percentage)+"%\",")

    spreadval = (dict[j]["trait_spread"])
    print("\"Spread_value\": \"" + str(spreadval) + "\"," )
    spreadval = spreadval[:-1]
    spreadval = int(spreadval)-1
    spreadrarity = (rarity["boxtraits"][9]["spread"][int(spreadval)])
    percentage = round((int(spreadrarity) / int(quantity))*100,2)
    print ("\"Spread_rarity\": \"" + str(percentage)+"%\",")

    hueval = (dict[j]["trait_hue"])
    print("\"Hue_value\": \"" + str(hueval) + "\"," )
    hueval = int(hueval)-1
    huerarity = (rarity["boxtraits"][10]["hue"][int(hueval)])
    percentage = round((int(huerarity) / int(quantity))*100,2)
    print ("\"Hue_rarity\": \"" + str(percentage)+"%\",")

    lightnessval = (dict[j]["trait_lightness"])
    print("\"Lightness_value\": \"" + str(lightnessval) + "\",")
    lightnessval = int(lightnessval)-1
    lightnessrarity = (rarity["boxtraits"][11]["lightness"][int(lightnessval)])
    percentage = round((int(lightnessrarity) / int(quantity))*100,2)
    print ("\"Lightness_rarity\": \"" + str(percentage)+"%\",")

    animationval = (dict[j]["trait_animation"])
    print("\"Animation\": \"" + str(animationval) + "\",")
    
    for n in range(0,25):   
        if str(animationval) == str(animation[n]):
            animationval = n 


    animationrarity = (rarity["boxtraits"][12]["animation"][int(animationval)])
    percentage = round((int(animationrarity) / int(quantity))*100,2)
    print ("\"Animation_rarity\": \"" + str(percentage)+"%\",")


    shadesval = (dict[j]["trait_shades"])
    print("\"Shades_value\": \"" + str(shadesval) + "\",")
#    shadesval = shadesval[:-1]
    shadesval = int(shadesval)-1
    shadesrarity = (rarity["boxtraits"][13]["shades"][int(shadesval)])
    percentage = round((int(shadesrarity) / int(quantity))*100,2)
    print ("\"Shades_rarity\": \"" + str(percentage)+"%\",")


    hatchingval = (dict[j]["trait_hatching"])
    print("\"Hatching_value\": \"" + str(hatchingval) + "\",")
#    hatchingval = hatchingval[:-1]
    hatchingval = int(hatchingval)-1
    hatchingrarity = (rarity["boxtraits"][14]["hatching"][int(hatchingval)])
    percentage = round((int(hatchingrarity) / int(quantity))*100,2)
    print ("\"Hatching_rarity\": \"" + str(percentage)+"%\",")


    contrastval = str(dict[j]["trait_contrast"])
    if '%' in contrastval:
    	contrastval = contrastval[:-1]
    print("\"Contrast_value\": \"" + str(contrastval) + "\",")
    contrastval = int(contrastval)-1
    contrastrarity = (rarity["boxtraits"][15]["contrast"][int(contrastval)])
    percentage = round((int(contrastrarity) / int(quantity))*100,2)
    print ("\"Contrast_rarity\": \"" + str(percentage)+"%\"")

    if j != numberofboxes - 1:
    	print ("},")
    else:
        print("}")


#for k in range(0,11):
#    print ( k )
#    colrarity = (rarity["boxtraits"][k])
#    print ( colrarity )


print ("]")

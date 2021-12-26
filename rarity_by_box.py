import json
import replace 
import numpy as np


mirroring = np.array([(0,1,2),(0,1,3),(0,2,1),(0,2,3),(0,3,1),(0,3,2),(1,0,2),(1,0,3),(1,2,0),(1,2,3),(1,3,0),(1,3,2),(2,0,1),(2,0,3),(2,1,0),(2,1,3),(2,3,0),(2,3,1),(3,0,1),(3,0,2),(3,1,0),(3,1,2),(3,2,0),(3,2,1),(0,0,0),(1,3,3)])


with open('traits.json') as a:
    dict = json.load(a)

with open('rarity.json') as b:
    rarity = json.load(b)

    quantity = (rarity["boxtraits"][0]["quantity"][0])

print("quant: ")
print( quantity )

for j in range(1,1409):
    print ("Box " + str(j))

    colval = (dict[j]["trait_columns"])
    colval = colval-1
    print(str(colval) + " columns")
    colrarity = (rarity["boxtraits"][1]["columns"][colval])
    percentage = round((int(colrarity) / int(quantity))*100,2)
    print ("Columns rarity: " + str(percentage)+"%")

    rowval = (dict[j]["trait_rows"])
    rowval = rowval-1
    print( "Rows: " + str(rowval))
    rowrarity = (rarity["boxtraits"][2]["rows"][rowval])
    percentage = round((int(rowrarity) / int(quantity))*100,2)
    print ("Row rarity: " + str(percentage)+"%")

    mirroringval = (dict[j]["trait_mirroring"])
    print ("Mirroring value: " + mirroringval)
  
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
        mirroringval = 61  

    mirroringrarity = (rarity["boxtraits"][3]["mirroring"][int(mirroringval)])
    percentage = round((int(mirroringrarity) / int(quantity))*100,2)
    print ("Mirroring rarity: " + str(percentage)+"%")


    shapeval = (dict[j]["trait_shapes"])
    shapeval = shapeval-1
    print("Shape value: " + str(shapeval))
    shaperarity = (rarity["boxtraits"][4]["shapes"][int(shapeval)])
    percentage = round((int(shaperarity) / int(quantity))*100,2)
    print ("Shape rarity: " + str(percentage)+"%")

    spreadval = (dict[j]["trait_spread"])
    spreadval = spreadval[:-1]
    spreadval = int(spreadval)-1
    print("Spread value: " + str(spreadval))
    spreadrarity = (rarity["boxtraits"][5]["spread"][int(spreadval)])
    percentage = round((int(spreadrarity) / int(quantity))*100,2)
    print ("Spread rarity: " + str(percentage)+"%")

    hueval = (dict[j]["trait_hue"])
    hueval = int(hueval)-1
    print("Hue value: " + str(hueval) )
    huerarity = (rarity["boxtraits"][6]["hue"][int(hueval)])
    percentage = round((int(huerarity) / int(quantity))*100,2)
    print ("Hue rarity:" + str(percentage)+"%")

    lightnessval = (dict[j]["trait_lightness"])
    lightnessval = int(lightnessval)-1
    print("Lightness value: " + str(lightnessval))
    lightnessrarity = (rarity["boxtraits"][7]["lightness"][int(lightnessval)])
    percentage = round((int(lightnessrarity) / int(quantity))*100,2)
    print ("Lightness rarity: " + str(percentage)+"%")

    animationval = (dict[j]["trait_animation"])
    print("Animation: " + str(animationval))


    animation = np.array(["Snap Spin 90","Snap Spin 180","Snap Spin 270","Snap Spin Tri","Snap Spin Quad","Snap Spin Tetra","Spin","Slow Mo","Clockwork","Spread","Staggered Spread","Jitter","Jiggle","Jolt","Grow n Shrink","Squash n Stretch","Round","Glide","Wave","Fade","Skew X","Skew Y","Stretch","Jello","Unfurl"])

    for n in range(0,24):   
        if str(animationval) == str(animation[n]):
            animationval = n 
    if str(animationval) == "Unfurl":
            animationval = 24



    animationrarity = (rarity["boxtraits"][8]["animation"][int(animationval)])
    percentage = round((int(animationrarity) / int(quantity))*100,2)
    print ("Animation rarity: " + str(percentage)+"%")


    shadesval = (dict[j]["trait_shades"])
#    shadesval = shadesval[:-1]
    shadesval = int(shadesval)-1
    print("Shades value: " + str(shadesval))
    shadesrarity = (rarity["boxtraits"][9]["shades"][int(shadesval)])
    percentage = round((int(shadesrarity) / int(quantity))*100,2)
    print ("Shades rarity: " + str(percentage)+"%")


    hatchingval = (dict[j]["trait_hatching"])
#    hatchingval = hatchingval[:-1]
#    hatchingval = int(hatchingval)-1
    print("Hatching value: " + str(hatchingval))
    hatchingrarity = (rarity["boxtraits"][10]["hatching"][int(hatchingval)])
    percentage = round((int(hatchingrarity) / int(quantity))*100,2)
    print ("Hatching rarity: " + str(percentage)+"%")


    contrastval = str(dict[j]["trait_contrast"])
    contrastval = contrastval[:-1]
    contrastval = int(contrastval)-1
    print("Contrast value: " + str(contrastval))
    contrastrarity = (rarity["boxtraits"][11]["contrast"][int(contrastval)])
    percentage = round((int(contrastrarity) / int(quantity))*100,2)
    print ("Contrast rarity: " + str(percentage)+"%")

    print ("")


#for k in range(0,11):
#    print ( k )
#    colrarity = (rarity["boxtraits"][k])
#    print ( colrarity )


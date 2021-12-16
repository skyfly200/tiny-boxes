import requests
import json
import numpy as np

n_cols=11
n_rows=2
n_mirroring=3
n_shapes=4
n_spread=5
n_hue=6
n_lightness=11
n_animation=13
n_shades=6
n_hatching=28
n_contrast=32

mirroring = np.array([(0,1,2),(0,1,3),(0,2,1),(0,2,3),(0,3,1),(0,3,2),(1,0,2),(1,0,3),(1,2,0),(1,2,3),(1,3,0),(1,3,2),(2,0,1),(2,0,3),(2,1,0),(2,1,3),(2,3,0),(2,3,1),(3,0,1),(3,0,2),(3,1,0),(3,1,2),(3,2,0),(3,2,1)])

animation = np.array(["Snap Spin 90","Snap Spin 180","Snap Spin 270","Snap Spin Tri","Snap Spin Quad","Snap Spin Tetra","Spin","Slow Mo","Clockwork","Spread","Staggered Spread","Jitter","Jiggle","Jolt","Grow n Shrink","Squash n Stretch","Round","Glide","Wave","Fade","Skew X","Skew Y","Stretch","Jello"])


boxstats = "https://raw.githubusercontent.com/SustainableCommunityDevelopmentHub/bot/main/minted_boxes.json"

RARITY_URL = "https://raw.githubusercontent.com/skyfly200/tiny-boxes/master/rarity.json"

NFTdata = requests.request("GET", RARITY_URL)

quant = NFTdata.json()["boxtraits"][0]["minted"]
quant = int(quant)
print( str(quant) + " minted boxes" )
print( " " )


cols_minted = NFTdata.json()["boxtraits"][0]["columns"][0]["0"]
print( cols_minted )
print( "Column Trait Minted" )
colrarity = round((int(cols_minted) / int(quant)) * 100, 2)
print(str(colrarity) + "% rarity")

rows_minted = NFTdata.json()["boxtraits"][0]["rows"][0]["0"]
print( rows_minted )
print( "Row Trait Minted" )
rowrarity = round((int(rows_minted) / int(quant)) * 100, 2)
print(str(rowrarity) + "% rarity")

mirr_minted = NFTdata.json()["boxtraits"][0]["mirroring"][0]["0"]
print( mirr_minted )
print( "Mirroring Trait Minted" )
mirrrarity = round((int(rows_minted) / int(quant)) * 100, 2)
print(str(mirrrarity) + "% rarity")

shapes_minted = NFTdata.json()["boxtraits"][0]["shapes"][0]["0"]
print( shapes_minted )
print( "Shapes Trait Minted" )
shapesrarity = round((int(shapes_minted) / int(quant)) * 100, 2)
print(str(shapesrarity) + "% rarity")

spread_minted = NFTdata.json()["boxtraits"][0]["spread"][0]["0"]
print( spread_minted )
print( "Spread Trait Minted" )
spreadrarity = round((int(spread_minted) / int(quant)) * 100, 2)
print(str(spreadrarity) + "% rarity")

hues_minted = NFTdata.json()["boxtraits"][0]["hue"][0]["0"]
print( hues_minted )
print( "Hue Traits Minted" )
huerarity = round((int(hues_minted) / int(quant)) * 100, 2)
print(str(huerarity) + "% rarity")

lightness_minted = NFTdata.json()["boxtraits"][0]["lightness"][0]["0"]
print( lightness_minted )
print( "Lightness Traits Minted" )
lightnessrarity = round((int(lightness_minted) / int(quant)) * 100, 2)
print(str(lightnessrarity) + "% rarity")

animations_minted = NFTdata.json()["boxtraits"][0]["animation"][0]["0"]
print( animations_minted )
print( "Animation Traits Minted" )
animationrarity = round((int(animations_minted) / int(quant)) * 100, 2)
print(str(animationrarity) + "% rarity")

shades_minted = NFTdata.json()["boxtraits"][0]["shades"][0]["0"]
print( shades_minted )
print( "Shades Traits Minted" )
shadesrarity = round((int(shades_minted) / int(quant)) * 100, 2)
print(str(shadesrarity) + "% rarity")

hatching_minted = NFTdata.json()["boxtraits"][0]["hatching"][0]["0"]
print( hatching_minted )
print( "Hatching Traits Minted" )
hatchingrarity = round((int(hatching_minted) / int(quant)) * 100, 2)
print(str(hatchingrarity) + "% rarity")

contrast_minted = NFTdata.json()["boxtraits"][0]["contrast"][0]["0"]
print( "Contrast Traits Minted" )
print( contrast_minted )
contrastrarity = round((int(contrast_minted) / int(quant)) * 100, 2)
print(str(contrastrarity) + "% rarity")



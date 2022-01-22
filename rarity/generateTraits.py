#import pymongo
import requests


#client = pymongo.MongoClient("localhost", 27017)
#mydb = client["tinybox_attributes"]
#myrec = mydb["minted_boxes"]



#API_SUBURL = "https://api.opensea.io/api/v1/asset/0x46F9A4522666d2476a5F5Cd51ea3E0b5800E7f98/"
API_SUBURL = "https://tinybox.shop/.netlify/functions/metadata?id="

LE_BASE_URL = "https://tinybox.shop/.netlify/functions/metadata?id=11579208923731619542357098500868790785326998466564056403945758400791312963"

#for i in range(1413,1414):
#for i in range(1408,1413):
#for i in range(-70,1413):
for i in range(1413,1414):

#
#       construct API request URL for each token 
#
	f = str(i)
	ii = f[0 : 1]
	if (ii == "-"):
		SUBSUB2 = 9936 + i
		API_URL = LE_BASE_URL + str(SUBSUB2)
	else:
		#API_URL = str(API_SUBURL) + str(SUBSUB2)
		API_URL = API_SUBURL + str(i)
	NFTdata = requests.request("GET", API_URL)

#
#       loop through the api output to ensure that the proper trait is being indexed
#
	for j in range(0,19):
		#print("j loop#:" + str(j) + " val: " + NFTdata.json()['attributes'][j]['trait_type'] )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Type":
			trait_type = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) + " val: " + NFTdata.json()['attributes'][j]['trait_type'] )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Min Width":
			trait_minwidth = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) + " val: " + NFTdata.json()['attributes'][j]['trait_type'] )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Max Width":
			trait_maxwidth = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) + " val: " + NFTdata.json()['attributes'][j]['trait_type'] )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Min Height":
			trait_minheight = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) + " val: " + NFTdata.json()['attributes'][j]['trait_type'] )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Max Height":
			trait_maxheight = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) + " val: " + NFTdata.json()['attributes'][j]['trait_type'] )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Scheme":
			trait_scheme = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Columns":
			trait_columns = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Rows":
			trait_rows = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Mirroring":
			trait_mirroring = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Saturation":
			trait_saturation = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Shapes":
			trait_shapes = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Spread":
			trait_spread = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Hue":
			trait_hue = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Lightness":
			trait_lightness = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Animation":
			trait_animation = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Shades":
			trait_shades = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Hatching":
			trait_hatching = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Contrast":
			trait_contrast = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Phase":
			trait_phase = NFTdata.json()['attributes'][j]['value']
	for j in range(0,19):
		#print("j loop#:" + str(j) )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Rendered":
			trait_rendered = NFTdata.json()['attributes'][j]['value']
		else:
			 trait_rendered = 0


	print("{ \"boxnum\": \"" + str(i)  + "\", \"API_URL\": \"" + str(API_URL) + "\" , \"trait_scheme\": \"" + str(trait_scheme) + "\" , \"trait_columns\": " + str(trait_columns) + " , \"trait_rows\": " + str(trait_rows) + ", \"trait_mirroring\": \"" + str(trait_mirroring) + "\", \"trait_saturation\": " + str(trait_saturation) + ", \"trait_shapes\": " + str(trait_shapes) + ", \"trait_spread\": \"" + str(trait_spread) + "\", \"trait_hue\": " + str(trait_hue) + ", \"trait_lightness\": " + str(trait_lightness) + ", \"trait_animation\": \"" + str(trait_animation) + "\", \"trait_shades\": " + str(trait_shades) + ", \"trait_hatching\": " + str(trait_hatching) + ", \"trait_contrast\": \"" + str(trait_contrast) + "\", \"trait_phase\": \"" + str(trait_phase) + "\", \"trait_rendered\": " + str(trait_rendered) +  ", \"trait_maxwidth\": " + str(trait_maxwidth) +  ", \"trait_minwidth\": " + str(trait_minwidth) +  ", \"trait_minheight\": " + str(trait_minheight) +  ", \"trait_maxheight\": " + str(trait_maxheight) + "},")

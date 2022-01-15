import pymongo
import requests


client = pymongo.MongoClient("localhost", 27017)
mydb = client["tinybox_attributes"]
myrec = mydb["minted_boxes"]


#test loop
#r=0
#for i in range(1,1000):
#    print("love i:" + str(i) +" r " + str(r) )

API_SUBURL = "https://api.opensea.io/api/v1/asset/0x46F9A4522666d2476a5F5Cd51ea3E0b5800E7f98/"

for i in range(1,1411):

	API_URL = API_SUBURL + str(i)
	NFTdata = requests.request("GET", API_URL)

	for j in range(0,18):
		print("j loop#:" + str(j) + " val: " + NFTdata.json()['traits'][j]['trait_type'] )
		if NFTdata.json()['traits'][j]['trait_type'] == "Scheme":
			trait_scheme = NFTdata.json()['traits'][j]['value']
	for j in range(0,18):
		print("j loop#:" + str(j) )
		if NFTdata.json()['traits'][j]['trait_type'] == "Columns":
			trait_columns = NFTdata.json()['traits'][j]['value']
	for j in range(0,18):
		print("j loop#:" + str(j) )
		if NFTdata.json()['traits'][j]['trait_type'] == "Rows":
			trait_rows = NFTdata.json()['traits'][j]['value']
	for j in range(0,18):
		print("j loop#:" + str(j) )
		if NFTdata.json()['traits'][j]['trait_type'] == "Mirroring":
			trait_mirroring = NFTdata.json()['traits'][j]['value']
	for j in range(0,18):
		print("j loop#:" + str(j) )
		if NFTdata.json()['traits'][j]['trait_type'] == "Saturation":
			trait_saturation = NFTdata.json()['traits'][j]['value']
	for j in range(0,18):
		print("j loop#:" + str(j) )
		if NFTdata.json()['traits'][j]['trait_type'] == "Shapes":
			trait_shapes = NFTdata.json()['traits'][j]['value']
	for j in range(0,18):
		print("j loop#:" + str(j) )
		if NFTdata.json()['traits'][j]['trait_type'] == "Spread":
			trait_spread = NFTdata.json()['traits'][j]['value']
	for j in range(0,18):
		print("j loop#:" + str(j) )
		if NFTdata.json()['traits'][j]['trait_type'] == "Hue":
			trait_hue = NFTdata.json()['traits'][j]['value']
	for j in range(0,18):
		print("j loop#:" + str(j) )
		if NFTdata.json()['traits'][j]['trait_type'] == "Lightness":
			trait_lightness = NFTdata.json()['traits'][j]['value']
	for j in range(0,18):
		print("j loop#:" + str(j) )
		if NFTdata.json()['traits'][j]['trait_type'] == "Animation":
			trait_animation = NFTdata.json()['traits'][j]['value']
	for j in range(0,18):
		print("j loop#:" + str(j) )
		if NFTdata.json()['traits'][j]['trait_type'] == "Shades":
			trait_shades = NFTdata.json()['traits'][j]['value']
	for j in range(0,18):
		print("j loop#:" + str(j) )
		if NFTdata.json()['traits'][j]['trait_type'] == "Hatching":
			trait_hatching = NFTdata.json()['traits'][j]['value']
	for j in range(0,18):
		print("j loop#:" + str(j) )
		if NFTdata.json()['traits'][j]['trait_type'] == "Contrast":
			trait_contrast = NFTdata.json()['traits'][j]['value']
	for j in range(0,18):
		print("j loop#:" + str(j) )
		if NFTdata.json()['traits'][j]['trait_type'] == "Phase":
			trait_phase = NFTdata.json()['traits'][j]['value']
	for j in range(0,18):
		print("j loop#:" + str(j) )
		if NFTdata.json()['traits'][j]['trait_type'] == "Rendered":
			trait_rendered = NFTdata.json()['traits'][j]['value']
		else:
			 trait_rendered = 0

	mylist = [
		{ "boxnum": i,
		"trait_scheme": trait_scheme,
		"trait_columns": trait_columns,
		"trait_rows": trait_rows ,
		"trait_mirroring": trait_mirroring ,
		"trait_saturation": trait_saturation ,
		"trait_shapes": trait_shapes ,
		"trait_spread": trait_spread ,
		"trait_hue": trait_hue ,
		"trait_lightness": trait_lightness ,
		"trait_animation": trait_animation ,
		"trait_shades": trait_shades ,
		"trait_hatching": trait_hatching ,
		"trait_contrast": trait_contrast ,
		"trait_phase": trait_phase ,
		"trait_rendered": trait_rendered }
		]

	x = myrec.insert_many(mylist)
	# print list of the _id values of the inserted documents:
	print(x.inserted_ids)

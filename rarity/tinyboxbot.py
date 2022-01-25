# NFT Rarity Display bot for discord
# MIT GPL 2022 Greg Willson greg@biomassiv.es
# Written for tinyboxes - tinybox.shop

# Import discord.py. Allows access to Discord's API.
import discord
from discord import Embed
from discord import File
import requests
import datetime


#import os
#from dotenv import load_dotenv
from discord.ext import commands
#load_dotenv()

# Grab the API token from the .env file.
#DISCORD_TOKEN = os.getenv("DISCORD_TOKEN")
DISCORD_TOKEN="##########################################################"

OPENSEAAPI_SUBURL = "https://api.opensea.io/api/v1/asset/0x46F9A4522666d2476a5F5Cd51ea3E0b5800E7f98/"
TINYBOXAPI_SUBURL = "https://tinybox.shop/.netlify/functions/metadata?id="

#RARITY_API = "https://raw.githubusercontent.com/skyfly200/tiny-boxes/master/rarity/index.json"
RARITY_API = "https://raw.githubusercontent.com/skyfly200/tiny-boxes/master/rarity/rarity_by_box.json"
rarity = requests.request("GET", RARITY_API)
BOXATTR = rarity.json()

bot = commands.Bot(command_prefix="#")
@bot.event
async def on_message(message):
	if message.content == "hello":
		await message.channel.send("Hello Tinybox enthusiast! Thanks for being part of the experience!.")
	if message.content == "#LE":
		brief="What is an LE token."
		await message.channel.send("LE Tokens are limited edition tokens, not for sale and given away by the project as promotions. They alloww you to design any box you want. -tokenid")
	if message.content == "catme":
		brief="Random cat provided for your enjoyment and protection."
		r = requests.get("https://api.thecatapi.com/v1/images/search").json()
		message2 = discord.Embed()
		message2.set_image(url=f"{r[0]['url']}") 
		await message.channel.send(embed=message2)

	await bot.process_commands(message)


@bot.command(
	# Adds this value to the $help ping message.
	help="Uses come crazy logic to determine if pong is actually the correct value or not.",
	# Adds this value to the $help message.
	brief="Prints pong back to the channel."
)
async def ping(ctx):
	# Sends a message to the channel using the Context object.
	await ctx.channel.send("pongo")

@bot.command(
	# Adds this value to the $help print message.
	help="Looks like you need some help.",
	# Adds this value to the $help message.
	brief="Prints Tinybox NFT token and aftermarket data to the channel."
)


async def box(ctx, *args):
	print ( " got here 2")
	#async def tinybox(ctx, *args):
	#async def tb(ctx, *args): box(ctx, *args):
	print("---------------------------------------------")
	brief = "Return a custom TinyBoxes NFT stats report."
	response = "Tinybox NFT Status"
	ELEMENT = ctx.message.content
	print("ELEMENT ID: " + ELEMENT)
	SUBELEMENT =  ELEMENT.split(' ')
	SUBSUB0 =  SUBELEMENT[1]  
	print("SUBSUB0: " + SUBSUB0)
	SUBSUB = SUBSUB0[0 : 1]
	print("SUBSUB pos/neg value: " + SUBSUB)
	if (SUBSUB == "-"):
		SUBSUB2 = 9936 + int(SUBSUB0)
		LE_num = SUBSUB0[1 : 3] 
		SUBSUB2_0 = 11579208923731619542357098500868790785326998466564056403945758400791312963
		print(SUBSUB2)
		print("helllo there : Collie Buddz 2c")
		API_URL = str(TINYBOXAPI_SUBURL) + str(SUBSUB2_0) + str(SUBSUB2)
		OPENSEAAPI_URL = str(OPENSEAAPI_SUBURL) + str(SUBSUB2_0) + str(SUBSUB2)
		print("helllo there opensea")
		print(OPENSEAAPI_URL)
	else:
		print("helllo API: ")
		API_URL = TINYBOXAPI_SUBURL + SUBSUB0
		OPENSEAAPI_URL = str(OPENSEAAPI_SUBURL) + SUBSUB0
		print("helllo API: " + API_URL)
		print("hello open sea:")
		print(OPENSEAAPI_URL)


	# get token data from api.opensea.io
	NFTdata = requests.request("GET", API_URL)
	OPENSEAdata = requests.request("GET", OPENSEAAPI_URL , headers={"X-APi-Key":"44c8a04c1fb745c3adc4b8e819328295"} )

	#last_sale = OPENSEAdata.json()['last_sale']['payment_token']['eth_price']
	#current_price = OPENSEAdata.json()['orders']['current_price']
	permalink = OPENSEAdata.json()['permalink']
	print ("current_price")
	#print (current_price)
	print ("last_sale")
	#print (last_sale)

	footer_icon = "https://lh3.googleusercontent.com/jnY8ZP3Keh11pKLeBOHtRgGBwfUY3ghlAnfub6vI37FuLtzYfna9SjoE8gs7hXbEbw1GmsKDDkgdvoFqEKJZysfiRqScz-GO4rszPQ=s120"

	#created = NFTdata.json()['asset_contract']['created_date']
	#created = datetime.date.created
	#print(img)

	#format the description
	description = NFTdata.json()['description']
	SUBdesc = description.split(' ')
	description = SUBdesc[0] + " " + SUBdesc[1] + " " + SUBdesc[2] + " " + SUBdesc[3] + " " + SUBdesc[4] + " " + SUBdesc[5] + " " + SUBdesc[6]
	#print(img)

	token_id = NFTdata.json()['tokenID']
	after_market = NFTdata.json()['external_url']
	today = datetime.date.today()

        #file conversion for svg to png
	#cairosvg.svg2png(bytestring=svg, url=img, write_to="/tmp/output.png" width=400 height=400)
	#cairosvg.svg2png(bytestring=svg, url=img, write_to="/tmp/output.png", width=400, height=400)

	#file = discord.File("sample.png")
	#file = discord.File("/tmp/output.png")

	try:
            current_price = OPENSEAdata.json()['orders'][0]['current_price']
	except:
            current_price = "NFS - make an offer"

	sales = OPENSEAdata.json()['num_sales']
	sales = int(sales)
	print(" Queen Ifrica 3!!")
	print(sales)
	print(current_price)
	print(" Queen Ifrica 3!!")

		

	#if sales == 0:
	#	print("art lives")
	#	current_price = "NFS"
	#	print("art lives")
	#else:
	#	print("art loves you")
	#current_price = NFTdata.json()['orders'][0]['current_price']
	#	last_sale_eventtype = NFTdata.json()['last_sale']['event_type']
	#	last_sale_timestamp = NFTdata.json()['last_sale']['event_timestamp']
	#	last_sale_total_price = NFTdata.json()['last_sale']['total_price']
#		try: 
#			orders_array_len = len(NFTdata.json()['orders'])
#			# if orders_array_len != ""
#			print("art loooves")
#			print(orders_array_len)
#			current_price = NFTdata.json()['orders'][0]['current_price']
				
#		except:
#			print("art loves you")
			

		#print(" Queen Ifrica 3d key:")
		#sales = int(sales)
		#print(" INvoke jah9")
		#salestup = sales - int(1)
		#print("one")
		#print(salestup)
	#print(" Queen Ifrica 4a")

	#if sales >= 2:
	#	print("Sales")
	#	for ii in range(0, sales):
	#		print(ii)
	#		print("nice up yourself")

	#print(" Queen Ifrica 1c")
	#print(current_price)
	#print(" Queen Ifrica 1c")

        # generated bot's embed statement

	print(" flag5")
	print(SUBSUB0)
	print(" flag5")
	#permalink = NFTdata.json()['permalink']
	tinybox_link = NFTdata.json()['external_url']
	#num_sales = NFTdata.json()['num_sales']


	#SUBSUB0 = int(SUBSUB0)

	if SUBSUB == "-":
		embed = discord.Embed(color=0xff9999, title="Tinybox Limited Edition NFT#" + LE_num)
		img = "https://raw.githubusercontent.com/skyfly200/tiny-boxes/master/rarity/boxesLE/" + SUBSUB0 + ".png"

#	elif SUBSUB0 >= 0 and SUBSUB0 < 1000:
#		embed = discord.Embed(color=0xff9999, title="Tinybox NFT#" + SUBSUB0)
#		print (".lt. 999 boxes")
#		img = "https://raw.githubusercontent.com/skyfly200/tiny-boxes/master/rarity/boxes/" + SUBSUB0 + ".png"
#		print (img)

	else:
		embed = discord.Embed(color=0xff9999, title="Tinybox NFT#" + SUBSUB0)
		print (".gt. 999 boxes")
		folder = "boxes"
		SUBSUB0val = int(SUBSUB0)
		if SUBSUB0val > 999:
		    folder = "boxes2" 
		img = "https://raw.githubusercontent.com/skyfly200/tiny-boxes/master/rarity/" + folder + "/" + SUBSUB0 + ".png"
		print (img)



	embed.set_image(url=img)
	embed.add_field(name="Minting", value=description, inline=True)
	#embed.add_field(name="Number of Sales", value=num_sales, inline=True)
	#embed.add_field(name="Details", value=tinybox_link + " \n" + permalink, inline=True)
	embed.add_field(name="Details", value=tinybox_link, inline=True)


	#img = NFTdata.json()['image_thumbnail_url']
	#embed.set_thumbnail(name="Image", value=img, inline=True)
	try:
		last_sale = OPENSEAdata.json()['last_sale']['payment_token']['eth_price']
		last_sale_eth =  int(last_sale) / 1000000000000000000
		embed.add_field(name="Last Sale", value=last_sale_eth, inline=True)
	except:
		print(" no last sale ")
		print(" num_sales ")
		#print(num_sales)
	#embed.set_image(url="attachment://sample.png")

	try:
		eth_price = int(current_price)
		eth_price =  (eth_price) / 1000000000000000000
	except:
		eth_price = current_price
		print(" No current price listing in opendsea data")

	embed.add_field(name="Current price:", value=eth_price, inline=True)
	#embed.add_field(name="Created", value=created[ 0 : 10 ], inline=True)


	for j in range(0,20):
		print("j loop#:" + str(j) + " val: " + NFTdata.json()['attributes'][j]['trait_type'] )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Scheme":
			trait_scheme = NFTdata.json()['attributes'][j]['value']

	for j in range(0,20):
		print("j1 loop#:" + str(j) + " val: " + NFTdata.json()['attributes'][j]['trait_type'] )
		if NFTdata.json()['attributes'][j]['trait_type'] == "Columns":
			trait_columns = NFTdata.json()['attributes'][j]['value']

	for j in range(0,20):
		if NFTdata.json()['attributes'][j]['trait_type'] == "Rows":
			trait_rows = NFTdata.json()['attributes'][j]['value']

	for j in range(0,20):
		if NFTdata.json()['attributes'][j]['trait_type'] == "Mirroring":
			trait_mirroring = NFTdata.json()['attributes'][j]['value']

	for j in range(0,20):
		if NFTdata.json()['attributes'][j]['trait_type'] == "Saturation":
			trait_saturation = NFTdata.json()['attributes'][j]['value']

	for j in range(0,20):
		if NFTdata.json()['attributes'][j]['trait_type'] == "Shapes":
			trait_shapes = NFTdata.json()['attributes'][j]['value']

	for j in range(0,20):
		if NFTdata.json()['attributes'][j]['trait_type'] == "Spread":
			trait_spread = NFTdata.json()['attributes'][j]['value']

	for j in range(0,20):
            if NFTdata.json()['attributes'][j]['trait_type'] == "Hue":
	            trait_hue = NFTdata.json()['attributes'][j]['value']

	for j in range(0,20):
            if NFTdata.json()['attributes'][j]['trait_type'] == "Lightness":
	            trait_lightness = NFTdata.json()['attributes'][j]['value']

	for j in range(0,20):
            if NFTdata.json()['attributes'][j]['trait_type'] == "Animation":
	            trait_animation = NFTdata.json()['attributes'][j]['value']

	for j in range(0,20):
            if NFTdata.json()['attributes'][j]['trait_type'] == "Shades":
	            trait_shades = NFTdata.json()['attributes'][j]['value']

	for j in range(0,20):
            if NFTdata.json()['attributes'][j]['trait_type'] == "Hatching":
	            trait_hatching = NFTdata.json()['attributes'][j]['value']

	for j in range(0,20):
            if NFTdata.json()['attributes'][j]['trait_type'] == "Contrast":
	            trait_contrast = NFTdata.json()['attributes'][j]['value']

	for j in range(0,20):
            if NFTdata.json()['attributes'][j]['trait_type'] == "Phase":
	            trait_phase = NFTdata.json()['attributes'][j]['value']
	if (SUBSUB == "-"):
	    trait_phase = "Limited Edition"

	for j in range(0,20):
            if NFTdata.json()['attributes'][j]['trait_type'] == "Rendered":
	            trait_rendered = NFTdata.json()['attributes'][j]['value']
            else:
                    trait_rendered = 0



	#rarity
	traitvar = int(SUBSUB0)
	col_rarity = BOXATTR[traitvar]['Columns_rarity']
	row_rarity = BOXATTR[traitvar]['Row_rarity']
	mirroring_rarity = BOXATTR[traitvar]['Mirroring_rarity']
	saturation_rarity = BOXATTR[traitvar]['Saturation_rarity']
	shape_rarity = BOXATTR[traitvar]['Shape_rarity']
	spread_rarity = BOXATTR[traitvar]['Spread_rarity']
	hue_rarity = BOXATTR[traitvar]['Hue_rarity']
	lightness_rarity = BOXATTR[traitvar]['Lightness_rarity']
	animation_rarity = BOXATTR[traitvar]['Animation_rarity']
	shades_rarity = BOXATTR[traitvar]['Shades_rarity']
	hatching_rarity = BOXATTR[traitvar]['Hatching_rarity']
	contrast_rarity = BOXATTR[traitvar]['Contrast_rarity']

	minheight_value = BOXATTR[traitvar]['minheight_value']
	Minheight_rarity = BOXATTR[traitvar]['Minheight_rarity']
	maxheight_value = BOXATTR[traitvar]['maxheight_value']
	Maxheight_rarity = BOXATTR[traitvar]['Maxheight_rarity']
	minwidth_value = BOXATTR[traitvar]['minwidth_value']
	Minwidth_rarity = BOXATTR[traitvar]['Minwidth_rarity']
	maxwidth_value = BOXATTR[traitvar]['maxwidth_value']
	Maxwidth_rarity = BOXATTR[traitvar]['Maxwidth_rarity']


	# would like to make this work

	#avg_rarity = (int(col_rarity[0: -1]) + int(row_rarity[0: -1]) + int(mirroring_rarity[0: -1]) + int(shape_rarity[0: -1])+ int(spread_rarity[0: -1]) + int(lightess_rarity[0: -1]) + int(animation_rarity[0: -1]) + int(shades_rarity[0: -1]) + int(hatching_rarity[0: -1]) + int(conrast_rarity[0: -1]))
	print("oo")
	print(col_rarity[0: -1])
	print("oo")

	#traits
	#embed.add_field(name="Avg Rarity", value=avg_rarity, inline=True)
	embed.add_field(name="Scheme", value=str(trait_scheme), inline=True)
	embed.add_field(name="Columns", value=str(trait_columns)+" ~ "+str(col_rarity), inline=True)
	embed.add_field(name="Rows", value=str(trait_rows)+" ~ "+str(row_rarity), inline=True)
	embed.add_field(name="Mirroring", value=str(trait_mirroring)+" ~ "+str(mirroring_rarity), inline=True)
	embed.add_field(name="Saturation", value=str(trait_saturation)+" ~ "+str(saturation_rarity), inline=True)
	embed.add_field(name="Shapes", value=str(trait_shapes)+" ~ "+str(shape_rarity), inline=True)
	embed.add_field(name="Spread", value=str(trait_spread)+" ~ "+str(spread_rarity), inline=True)
	embed.add_field(name="Hue", value=str(trait_hue)+" ~ "+str(hue_rarity), inline=True)
	embed.add_field(name="Lightness", value=str(trait_lightness)+" ~ "+str(lightness_rarity), inline=True)
	embed.add_field(name="Animation", value=str(trait_animation)+" ~ "+str(animation_rarity), inline=True)
	embed.add_field(name="Shades", value=str(trait_shades)+" ~ "+str(shades_rarity), inline=True)
	embed.add_field(name="Hatching", value=str(trait_hatching)+" ~ "+str(hatching_rarity), inline=True)
	embed.add_field(name="Contrast", value=str(trait_contrast)+" ~ "+str(contrast_rarity), inline=True)
	embed.add_field(name="Width Min", value=str(minwidth_value) + " ~ " + str(Minwidth_rarity), inline=True)
	embed.add_field(name="Width Max", value=str(maxwidth_value) + " ~ " + str(Maxwidth_rarity), inline=True)
	embed.add_field(name="Height Min", value=str(minheight_value) + " ~ " + str(Minheight_rarity), inline=True)
	embed.add_field(name="Height Max", value=str(maxheight_value) + " ~ " + str(Maxheight_rarity), inline=True)

	embed.add_field(name="Aftermarket", value=permalink, inline=True)
	embed.set_footer(text='Copyright (MIT) 2022 PolyTope Solutions', icon_url=footer_icon)
	await ctx.channel.send(embed=embed)

@bot.event
async def on_command_error(ctx, error):
	if isinstance(error, commands.MissingRequiredArgument):
		#created = NFTdata.json()['asset_contract']['created_date']
		errror_msg = created + 'This NFT has no aftermarket yet'
		await ctx.channel.send(error_msg)


# Executes the bot with the specified token. Token has been removed and used just as an example.
bot.run(DISCORD_TOKEN)

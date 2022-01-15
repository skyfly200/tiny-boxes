# Import discord.py. Allows access to Discord's API.
import discord
from discord import Embed
from discord import File
import requests
#import cairosvg
import datetime
#from cairosvg import svg2png

#import os
#from dotenv import load_dotenv
from discord.ext import commands
#load_dotenv()

# Grab the API token from the .env file.
#DISCORD_TOKEN = os.getenv("DISCORD_TOKEN")
DISCORD_TOKEN="#################################################################"

API_SUBURL = "https://api.opensea.io/api/v1/asset/0x46F9A4522666d2476a5F5Cd51ea3E0b5800E7f98/"



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
	#async def tinybox(ctx, *args):
	#async def tb(ctx, *args): box(ctx, *args):
	print("---------------------------------------------")
	brief = "Return a custom TinyBoxes NFT stats report."
	response = "Tinybox NFT Status"
	print("flag 198")
	ELEMENT = ctx.message.content
	print("element:" + ELEMENT)
	SUBELEMENT =  ELEMENT.split(' ')
	print("flag 199")
	SUBSUB0 =  SUBELEMENT[1]  
	print("subsub0: " + SUBSUB0)
	SUBSUB = SUBSUB0[0 : 1]
	if (SUBSUB == "-"):
 		print("helllo there : flag 220" + SUBSUB)
		SUBSUB2 = 9936 + int(SUBSUB0)
		LE_num = SUBSUB0[1 : 3] 
		print("helllo there : flag 2221")
		SUBSUB2_0 = 11579208923731619542357098500868790785326998466564056403945758400791312963
		print(SUBSUB2)
		API_URL = str(API_SUBURL) + str(SUBSUB2_0) + str(SUBSUB2)
	else:
		API_URL = API_SUBURL + SUBELEMENT[1]

	print("hello there : Rita Marley: ")
	# get token data from api.opensea.io
	NFTdata = requests.request("GET", API_URL)
	print("flag 335 ")
	print("flag 335a ")


	footer_icon = "https://lh3.googleusercontent.com/jnY8ZP3Keh11pKLeBOHtRgGBwfUY3ghlAnfub6vI37FuLtzYfna9SjoE8gs7hXbEbw1GmsKDDkgdvoFqEKJZysfiRqScz-GO4rszPQ=s120"

	created = NFTdata.json()['asset_contract']['created_date']
	print("helllo there : flag 337")
	#created = datetime.date.created
	#print(img)

	#format the description
	description = NFTdata.json()['description']
	SUBdesc = description.split(' ')
	description = SUBdesc[0] + " " + SUBdesc[1] + " " + SUBdesc[2] + " " + SUBdesc[3] + " " + SUBdesc[4] + " " + SUBdesc[5] + " " + SUBdesc[6]
	#print(img)

	token_id = NFTdata.json()['token_id']
	after_market = NFTdata.json()['permalink']
	today = datetime.date.today()

        #file conversion for svg to png
	#cairosvg.svg2png(bytestring=svg, url=img, write_to="/tmp/output.png" width=400 height=400)
	#cairosvg.svg2png(bytestring=svg, url=img, write_to="/tmp/output.png", width=400, height=400)

	#file = discord.File("sample.png")
	#file = discord.File("/tmp/output.png")
	print("flag 338")
 
	sales = NFTdata.json()['num_sales']
	sales = int(sales)
 	print(sales)
	 
		

	if sales == 0:
		print("art lives")
		current_price = "NFS"
		print("art lives")
	#elif sales == 1:
	else:
		print("art loves you")
		#current_price = NFTdata.json()['orders'][0]['current_price']
		last_sale_eventtype = NFTdata.json()['last_sale']['event_type']
		last_sale_timestamp = NFTdata.json()['last_sale']['event_timestamp']
		last_sale_total_price = NFTdata.json()['last_sale']['total_price']
		print("art loves alot")
		try: 
			orders_array_len = len(NFTdata.json()['orders'])
			# if orders_array_len != ""
			print("art loooves")
			print(orders_array_len)
			current_price = NFTdata.json()['orders'][0]['current_price']
				
		except:
			print("art loves you")
			

		print(" flag 339")
		sales = int(sales)
		print(" flag 440")
		#salestup = sales - int(1)
		print("one")
		#print(salestup)
		 
	if sales >= 2:
	 	for ii in range(0, sales):
			print(ii)
			print("nice up yourself")

 	#print(current_price)
	
        # generated bot's embed statement
 	print("flag 441")

	print(" Michael Rose")
	permalink = NFTdata.json()['permalink']
	tinybox_link = NFTdata.json()['external_link']
	num_sales = NFTdata.json()['num_sales']

	if (SUBSUB == "-"):
		embed = discord.Embed(color=0xff9999, title="Tinybox Limited Edition NFT#" + LE_num)
	else:
		embed = discord.Embed(color=0xff9999, title="Tinybox NFT#" + SUBSUB0)

	embed.add_field(name="Minting", value=description, inline=True)
	embed.add_field(name="Number of Sales", value=num_sales, inline=True)
	embed.add_field(name="Details", value=tinybox_link + " \n" + permalink, inline=True)
	img = NFTdata.json()['image_thumbnail_url']
	embed.add_field(name="Image", value=img, inline=True)
	try:
		last_sale = NFTdata.json()['last_sale']['total_price']
		last_sale_eth =  int(last_sale) / 1000000000000000000
		embed.add_field(name="Last Sale", value=last_sale_eth, inline=True)
	except:
		print(" no last sale ")
		print(" num_sales ")
		print(num_sales)
#	print("flag444")
	#embed.set_image(url="attachment://sample.png")


	try:
		eth_price = int(current_price)
		eth_price =  (eth_price) / 1000000000000000000
	except:
		eth_price = "NFS"
		print(" No current price listing in opendsea data")

	embed.add_field(name="Current price:", value=eth_price, inline=True)
	embed.add_field(name="Created", value=created[ 0 : 10 ], inline=True)

	trait_scheme = NFTdata.json()['traits'][0]['value']
	trait_columns = NFTdata.json()['traits'][1]['value']
	trait_rows = NFTdata.json()['traits'][2]['value']
	trait_mirroring = NFTdata.json()['traits'][3]['value']
	trait_saturation = NFTdata.json()['traits'][4]['value']
	trait_shapes = NFTdata.json()['traits'][5]['value']
	trait_spread = NFTdata.json()['traits'][6]['value']
	trait_hue = NFTdata.json()['traits'][7]['value']
	trait_lightness = NFTdata.json()['traits'][8]['value']
	trait_animation = NFTdata.json()['traits'][9]['value']
	trait_shades = NFTdata.json()['traits'][10]['value']
	trait_hatching = NFTdata.json()['traits'][12]['value']
	trait_contrast = NFTdata.json()['traits'][16]['value']
	trait_phase = NFTdata.json()['traits'][17]['value']
	trait_rendered = NFTdata.json()['traits'][18]['value']

	#traits
	embed.add_field(name="Scheme", value=trait_scheme, inline=True)
	embed.add_field(name="Columns", value=trait_columns, inline=True)
	embed.add_field(name="Rows", value=trait_rows, inline=True)
	embed.add_field(name="Mirroring", value=trait_mirroring, inline=True)
	embed.add_field(name="Saturation", value=trait_saturation, inline=True)
	embed.add_field(name="Shapes", value=trait_shapes, inline=True)
	embed.add_field(name="Spread", value=trait_spread, inline=True)
	embed.add_field(name="Hue", value=trait_hue, inline=True)
	embed.add_field(name="Lightness", value=trait_lightness, inline=True)
	embed.add_field(name="Animation", value=trait_animation, inline=True)
	embed.add_field(name="Shades", value=trait_shades, inline=True)
	embed.add_field(name="Hatching", value=trait_hatching, inline=True)
	embed.add_field(name="Contrast", value=trait_contrast, inline=True)
	embed.add_field(name="Phase", value=trait_phase, inline=True)
	embed.add_field(name="Rendered", value=trait_rendered, inline=True)

)

	embed.set_footer(text='Copyright (C) 2021 PolyTope Solutions', icon_url=footer_icon)

	#await ctx.channel.send(response, embed=embed)
	await ctx.channel.send(embed=embed)
	print("hoolo4")

@bot.event
async def on_command_error(ctx, error):
	if isinstance(error, commands.MissingRequiredArgument):
		#created = NFTdata.json()['asset_contract']['created_date']
		errror_msg = created + 'This NFT has no aftermarket yet'
		await ctx.channel.send(error_msg)


# Executes the bot with the specified token. Token has been removed and used just as an example.
bot.run(DISCORD_TOKEN)

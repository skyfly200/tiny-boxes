these boxes were generated by the following scripts [1] getsvgs.py , [2] script.sh, and [3] svgtopng.js




[1]  execute via: python3 getsvgs.py

import requests

API_SUBURL = "https://tinybox.shop/.netlify/functions/metadata?id="

LE_BASE_URL = "https://tinybox.shop/.netlify/functions/metadata?id=11579208923731619542357098500868790785326998466564056403945758400791312963"

#for i in range(1413,1414):
#for i in range(1408,1413):
for i in range(1412,1414):
#for i in range(1413,1414):

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

        imagedata = NFTdata.json()['image_data']
        file = str(i) + '.svg'

        fp = open(file, 'w')
        fp.write(imagedata)
        fp.close()


[2]  execute via: ./script.sh

#!/bin/bash
x=0
while [ $x -le 1415 ]
do
  node svgtopng2.js $x
  x=$(( $x + 1 ))
done



[3]  - setup - npm i puppeteer  , execute via script above ^

const puppeteer = require('puppeteer');

//const args = process.argv;
var x = process.argv[2];

var filename="file:///home/greg/puppeteer/";
var newfilename="file:///home/greg/puppeteer/";



(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  var filename2 = filename + x + ".svg";
  await page.goto(filename2);
  var newfilename2 =  x + ".png";
  await page.screenshot({ path: newfilename2 });
  await browser.close();
})();








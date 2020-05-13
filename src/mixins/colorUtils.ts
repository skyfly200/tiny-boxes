export function contrastingColor(hex: string) {
  const [R, G, B] = [0, 1, 2].map(i =>
    parseInt(hex.substring(i * 2 + 1, i * 2 + 3), 16)
  );
  const cBrightness = (R * 299 + G * 587 + B * 114) / 1000;
  const threshold = 100; /* about half of 256. Lower threshold equals more dark text on dark background  */
  return cBrightness > threshold ? "#000000" : "#ffffff";
}

export function intToColor(intnumber: number) {
  // bit shift color channel components
  const red = (intnumber & 0x0000ff) << 16;
  const green = intnumber & 0x00ff00;
  const blue = (intnumber & 0xff0000) >>> 16;

  // mask out each color and reverse the order
  intnumber = red | green | blue;

  // convert number to a hexstring, zero fill on left & add a #
  const HTMLcolor = intnumber.toString(16);
  const template = "#000000";
  return template.substring(0, 7 - HTMLcolor.length) + HTMLcolor;
}
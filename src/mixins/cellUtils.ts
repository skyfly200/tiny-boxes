const cellUtils: any = {
  methods: {
    level(mass: any) {
      return Math.floor(Math.log2(mass)) - 2;
    },
    levelProgress(mass: any) {
      const baseMass = 2 ** Math.floor(Math.log2(mass));
      return ((mass - baseMass) / baseMass) * 100;
    }
  }
};

export default cellUtils;

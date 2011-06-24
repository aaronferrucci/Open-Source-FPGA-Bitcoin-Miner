/* Quartus II Version 11.0 Build 157 04/27/2011 SJ Web Edition */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Cfg)
		Device PartName(EP4SGX230KF40ES) Path("C:/Users/aaronf/Documents/github/Open-Source-FPGA-Bitcoin-Miner/scripts/program/") File("stratixIVGX_4sgx230.sof") MfrSpec(OpMask(1));
	P ActionCode(Ign)
		Device PartName(EPM2210) MfrSpec(OpMask(0));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;

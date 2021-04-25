//
//  Disassembly.swift
//  my41
//
//  Created by Miroslav Perovic on 9/27/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation

var cpu = CPU.sharedInstance
var bus = Bus.sharedInstance

enum DisassemblyMode: Int {
	case disassemblyHex = 0
	case disassemblyOct = 1
}

struct NUTCode {
	var codeStr: String = ""
	var desc: String = ""
	var encoding: [String] = [String]()
}


final class Disassembly: Codable {
	let TEFs = [
		["PT", "X",  "WPT","W",  "PQ", "XS","M","S" ],
		["PT", "X",  "WPT","ALL","PQ", "XS","M","S" ],
		["@R", "S&X","R<", "ALL","P-Q","XS","M","MS"],
		["@PT","S&X","PT<","ALL","PQ", "XS","M","MS"]
	]
	
	let opCodes = [
		[
			"",
			"ST=0",
			"ST=1",
			"ST=1?",
			"LC",
			"?PT=",
			"",
			"PT=",
			"",
			"SELPF",
			"REGN=C",
			"FLG=1?",
			"",
			"",
			"C=REGN",
			"RCR",
			"NOP",
			"WMLDL",
			"#080",
			"#0C0",
			"ENROM1",
			"ENROM3",
			"ENROM2",
			"ENROM4",
			"#018",
			"G=C",
			"C=G",
			"CGEX",
			"#118",
			"M=C",
			"C=M",
			"CMEX",
			"#218",
			"F=SB",
			"SB=F",
			"FEXSB",
			"#318",
			"ST=C",
			"C=ST",
			"CSTEX",
			"SPOPND",
			"POWOFF",
			"SELP",
			"SELQ",
			"?P=Q",
			"?LLD",
			"CLRABC",
			"GOTOC",
			"C=KEYS",
			"SETHEX",
			"SETDEC",
			"DISOFF",
			"DISTOG",
			"RTNC",
			"RTNNC",
			"RTN",
			"SRLDA",
			"SRLDB",
			"SRLDC",
			"SRLDAB",
			"SRLABC",
			"SLLDAB",
			"SLLABC",
			"SRSDA",
			"SRSDB",
			"SRSDC",
			"SLSDA",
			"SLSDB",
			"SRSDAB",
			"SLSDAB",
			"SRSABC",
			"SLSABC",
			"?F3=1",
			"?F4=1",
			"?F5=1",
			"?F10=1",
			"?F8=1",
			"?F6=1",
			"?F11=1",
			"#1EC",
			"?F2=1",
			"?F9=1",
			"?F7=1",
			"?F13=1",
			"?F1=1",
			"?F12=1",
			"?F0=1",
			"#3EC",
			"ROMBLK",
			"N=C",
			"C=N",
			"CNEX",
			"LDI",
			"STK=C",
			"C=STK",
			"WPTOG",
			"GOKEYS",
			"DADD=C",
			"#2B0",
			"DATA=C",
			"CXISA",
			"C=CORA",
			"C=C&A",
			"PFAD=C",
			"FLLDA",
			"FLLDB",
			"FLLDC",
			"FLLDAB",
			"FLLABC",
			"READEN",
			"FLSDC",
			"FRSDA",
			"FRSDB",
			"FRSDC",
			"FLSDA",
			"FLSDB",
			"FRSDAB",
			"FLSDAB",
			"FRSABC",
			"FLSABC",
			"WRTEN",
			"HPIL=C",
			"CLRST",
			"RSTKB",
			"CHKKB",
			"DECPT",
			"INCPT",
			"C=DATA",
			"GSUBNC",
			"GSUBC",
			"GOLNC",
			"GOLC",
			"GSB41C",
			"GOL41C",
			"WRTIME",
			"WDTIME",
			"WRALM",
			"WRSTS",
			"WRSCR",
			"WSINT",
			"#1A8",
			"STPINT",
			"DSWKUP",
			"ENWKUP",
			"DSALM",
			"ENALM",
			"STOPC",
			"STARTC",
			"PT=B",
			"PT=A",
			"RDTIME",
			"RCTIME",
			"RDALM",
			"RDSTS",
			"RDSCR",
			"RDINT",
			"ENWRIT",
			"STWRIT",
			"ENREAD",
			"STREAD",
			"#128",
			"CRDWPF",
			"#1A8",
			"CRDOHF",
			"#228",
			"CRDINF",
			"#2A8",
			"TSTBUF",
			"TRPCRD",
			"TCLCRD",
			"#3A8",
			"CRDFLG",
			"A=0",
			"B=0",
			"C=0",
			"ABEX",
			"B=A",
			"ACEX",
			"C=B",
			"BCEX",
			"A=C",
			"A=A+B",
			"A=A+C",
			"A=A+1",
			"A=A-B",
			"A=A-1",
			"A=A-C",
			"C=C+C",
			"C=A+C",
			"C=C+1",
			"C=A-C",
			"C=C-1",
			"C=-C",
			"C=-C-1",
			"?B#0",
			"?C#0",
			"?A<C",
			"?A<B",
			"?A#0",
			"?A#C",
			"ASR",
			"BSR",
			"CSR",
			"ASL",
			"GONC",
			"GOC",
			"DEFP4K",
			"DEFR4K",
			"DEFR8K",
			"U4KDEF",
			"U8KDEF",
			"A=B",
			"B=C",
			"C=A",
			"LC3",
			"CON",
			"FCNS",
			"XROM",
			"undef",
			"undef",
			"undef",
			"BUSY?",
			"ERROR?",
			"POWON?",
			"PRINT",
			"STATUS",
			"RTNCPU"
		],
		[
			"",
			"CF",
			"SF",
			"?FS",
			"LC",
			"?PT=",
			"",
			"PT=",
			"",
			"PERTCT",
			"REG=C",
			"?PF",
			"",
			"",
			"C=REG",
			"RCR",
			"NOP",
			"WMLDL",
			"#080",
			"#0C0",
			"ENBANK1",
			"ENBANK3",
			"ENBANK2",
			"ENBANK4",
			"#018",
			"G=C",
			"C=G",
			"C<>G",
			"#118",
			"M=C",
			"C=M",
			"C<>M",
			"#218",
			"F=ST",
			"ST=F",
			"ST<>F",
			"#318",
			"ST=C",
			"C=ST",
			"C<>ST",
			"CLRRTN",
			"POWOFF",
			"PT=P",
			"PT=Q",
			"?P=Q",
			"?BAT",
			"ABC=0",
			"GTOC",
			"C=KEY",
			"SETHEX",
			"SETDEC",
			"DISOFF",
			"DISTOG",
			"CRTN",
			"NCRTN",
			"RTN",
			"WRA12L",
			"WRB12L",
			"WRC12L",
			"WRAB6L",
			"WRABC4L",
			"WRAB6R",
			"WRABC4R",
			"WRA1L",
			"WRB1L",
			"WRC1L",
			"WRA1R",
			"WRB1R",
			"WRAB1L",
			"WRAB1R",
			"WRABC1L",
			"WRABC1R",
			"?PF 3",
			"?PF 4",
			"?EDAV",
			"?ORAV",
			"?FRAV",
			"?IFCR",
			"?TFAIL",
			"#1EC",
			"?WNDB",
			"?FRNS",
			"?SRQR",
			"?SERV",
			"?CRDR",
			"?ALM",
			"?PBSY",
			"#3EC",
			"ROMBLK",
			"N=C",
			"C=N",
			"C<>N",
			"LDI",
			"STK=C",
			"C=STK",
			"WPTOG",
			"GTOKEY",
			"RAMSLCT",
			"#2B0",
			"WDATA",
			"RDROM",
			"C=CORA",
			"C=CANDA",
			"PERSLCT",
			"RDA12L",
			"RDB12L",
			"RDC12L",
			"RDAB6L",
			"RDABC4L",
			"READAN",
			"RDC1L",
			"RDA1R",
			"RDB1R",
			"RDC1R",
			"RDA1L",
			"RDB1L",
			"RDAB1R",
			"RDAB1L",
			"RDABC1R",
			"RDABC1L",
			"WRITAN",
			"HPIL=C",
			"ST=0",
			"CLRKEY",
			"?KEY",
			"-PT",
			"+PT",
			"RDATA",
			"NCXQ",
			"CXQ",
			"NCGO",
			"CGO",
			"NCXQREL",
			"NCGOREL",
			"WTIME",
			"WTIME-",
			"WALM",
			"WSTS",
			"WSCR",
			"WINTST",
			"#1A8",
			"STPINT",
			"WKUPOFF",
			"WKUPON",
			"ALMOFF",
			"ALMON",
			"STOPC",
			"STARTC",
			"TIMER=B",
			"TIMER=A",
			"RTIME",
			"RTIMEST",
			"RALM",
			"RSTS",
			"RSCR",
			"RINT",
			"ENDWRIT",
			"STWRIT",
			"ENDREAD",
			"STREAD",
			"#128",
			"CRDWPF",
			"#1A8",
			"CRDOHF",
			"#228",
			"CRDINF",
			"#2A8",
			"TSTBUF",
			"SETCTF",
			"TCLCTF",
			"#3A8",
			"CRDEXF",
			"A=0",
			"B=0",
			"C=0",
			"A<>B",
			"B=A",
			"A<>C",
			"C=B",
			"B<>C",
			"A=C",
			"A=A+B",
			"A=A+C",
			"A=A+1",
			"A=A-B",
			"A=A-1",
			"A=A-C",
			"C=C+C",
			"C=A+C",
			"C=C+1",
			"C=A-C",
			"C=C-1",
			"C=-C",
			"C=-C-1",
			"?B#0",
			"?C#0",
			"?A<C",
			"?A<B",
			"?A#0",
			"?A#C",
			"ASR",
			"BSR",
			"CSR",
			"ASL",
			"JNC",
			"JC",
			"DEFP4K",
			"DEFR4K",
			"DEFR8K",
			"U4KDEF",
			"U8KDEF",
			"A=B",
			"B=C",
			"C=A",
			"LC3",
			"CON",
			"FCNS",
			"XROM",
			"undef",
			"undef",
			"undef",
			"BUSY?",
			"ERROR?",
			"POWON?",
			"PRINT",
			"STATUS",
			"RTNCPU"
		],
		[
			"",
			"CLRF",
			"SETF",
			"?FSET",
			"LD@R",
			"?R=",
			"",
			"R=",
			"",
			"SELPF",
			"WRIT",
			"?FI=",
			"",
			"",
			"READ",
			"RCR",
			"NOP",
			"WROM",
			"#080",
			"#0C0",
			"ENROM1",
			"ENROM3",
			"ENROM2",
			"ENROM4",
			"#018",
			"G=C",
			"C=G",
			"C<>G",
			"#118",
			"M=C",
			"C=M",
			"C<>M",
			"#218",
			"T=ST",
			"ST=T",
			"ST<>T",
			"#318",
			"ST=C",
			"C=ST",
			"C<>ST",
			"XQ>GO",
			"POWOFF",
			"SLCTP",
			"SLCTQ",
			"?P=Q",
			"?LOWBAT",
			"A=B=C=0",
			"GOTOADR",
			"C=KEY",
			"SETHEX",
			"SETDEC",
			"DSPOFF",
			"DSPTOG",
			"?CRTN",
			"?NCRTN",
			"RTN",
			"SRLDA",
			"SRLDB",
			"SRLDC",
			"SRLDAB",
			"SRLABC",
			"SLLDAB",
			"SLLABC",
			"SRSDA",
			"SRSDB",
			"SRSDC",
			"SLSDA",
			"SLSDB",
			"SRSDAB",
			"SLSDAB",
			"SRSABC",
			"SLSABC",
			"?FI= 3",
			"?FI= 4",
			"?FI= 5",
			"?FI= 10",
			"?FI= 8",
			"?FI= 6",
			"?FI= 11",
			"#1EC",
			"?FI= 2",
			"?FI= 9",
			"?FI= 7",
			"?FI= 13",
			"?FI= 1",
			"?FI= 12",
			"?FI= 0",
			"#3EC",
			"ROMBLK",
			"N=C",
			"C=N",
			"C<>N",
			"LDIS&X",
			"PUSHADR",
			"POPADR",
			"WPTOG",
			"GTOKEY",
			"RAMSLCT",
			"#2B0",
			"WRITDATA",
			"FETCHS&X",
			"C=CORA",
			"C=CANDA",
			"PRPHSLCT",
			"FLLDA",
			"FLLDB",
			"FLLDC",
			"FLLDAB",
			"FLLABC",
			"READEN",
			"FLSDC",
			"FRSDA",
			"FRSDB",
			"FRSDC",
			"FLSDA",
			"FLSDB",
			"FRSDAB",
			"FLSDAB",
			"FRSABC",
			"FLSABC",
			"WRTEN",
			"HPIL=C",
			"ST=0",
			"CLRKEY",
			"?KEY",
			"R=R-1",
			"R=R+1",
			"READDATA",
			"?NCXQ",
			"?CXQ",
			"?NCGO",
			"?CGO",
			"?NCXQREL",
			"?NCGOREL",
			"WRTIME",
			"WDTIME",
			"WRALM",
			"WRSTS",
			"WRSCR",
			"WSINT",
			"#1A8",
			"STPINT",
			"DSWKUP",
			"ENWKUP",
			"DSALM",
			"ENALM",
			"STOPC",
			"STARTC",
			"PT=B",
			"PT=A",
			"RDTIME",
			"RCTIME",
			"RDALM",
			"RDSTS",
			"RDSCR",
			"RDINT",
			"ENWRIT",
			"STWRIT",
			"ENREAD",
			"STREAD",
			"#128",
			"CRDWPF",
			"#1A8",
			"CRDOHF",
			"#228",
			"CRDINF",
			"#2A8",
			"TSTBUF",
			"TRPCRD",
			"TCLCRD",
			"#3A8",
			"CRDFLG",
			"A=0",
			"B=0",
			"C=0",
			"A<>B",
			"B=A",
			"A<>C",
			"C=B",
			"B<>C",
			"A=C",
			"A=A+B",
			"A=A+C",
			"A=A+1",
			"A=A-B",
			"A=A-1",
			"A=A-C",
			"C=C+C",
			"C=C+A",
			"C=C+1",
			"C=A-C",
			"C=C-1",
			"C=0-C",
			"C=-C-1",
			"?B#0",
			"?C#0",
			"?A<C",
			"?A<B",
			"?A#0",
			"?A#C",
			"RSHFA",
			"RSHFB",
			"RSHFC",
			"LSHFA",
			"JNC",
			"JC",
			"DEFP4K",
			"DEFR4K",
			"DEFR8K",
			"U4KDEF",
			"U8KDEF",
			"A=B",
			"B=C",
			"C=A",
			"LD@R3",
			"CON",
			"FCNS",
			"XROM",
			"undef",
			"undef",
			"undef",
			"BUSY?",
			"ERROR?",
			"POWON?",
			"PRINT",
			"STATUS",
			"RTNCPU"
		]
	]

	let globalDict: [String: Int] = [
		"[ADATE]"		: 0x5B6E,
		"[ALMCAT]"		: 0x5806,
		"[ALMNOW]"		: 0x5F38,
		"[ATIME]"		: 0x5B67,
		"[ATIME24]"		: 0x5B5F,
		"[CLK12]"		: 0x52D7,
		"[CLK24]"		: 0x52E2,
		"[CLKT]"		: 0x52EA,
		"[CLKTD]"		: 0x52F3,
		"[CLOCK]"		: 0x5634,
		"[CORRECT]"		: 0x5407,
		"[DATE]"		: 0x5100,
		"[DATE+]"		: 0x52C1,
		"[DDAYS]"		: 0x52C8,
		"[DMY]"			: 0x5179,
		"[DOW]"			: 0x5089,
		"[MDY]"			: 0x516E,
		"[RCLAF]"		: 0x5122,
		"[RCLSW]"		: 0x5117,
		"[RUNSW]"		: 0x5135,
		"[SETAF]"		: 0x5B01,
		"[SETDATE]"		: 0x5423,
		"[SETIME]"		: 0x540F,
		"[SETSW]"		: 0x5B44,
		"[STOPSW]"		: 0x5CE5,
		"[SW]"			: 0x5560,
		"[T+X]"			: 0x59FB,
		"[TIME]"		: 0x50EE,
		"[XYZALM]"		: 0x5941,
		"[CLALMA]"		: 0x5069,
		"[CLALMX]"		: 0x52D0,
		"[CLRALMS]"		: 0x507A,
		"[RCLALM]"		: 0x5071,
		"[SWPT]"		: 0x5061,
		"[SEL_T_A]"		: 0x50E2,
		"[TSTMAP]"		: 0x14A1,
		"[XCAT]"		: 0x0B80,
		"[ASCLCD]"		: 0x2C5D,
		"[ASCLCA]"		: 0x2C5E,
		"[ADRFCH]"		: 0x0004,
		"[GOTINT]"		: 0x02F8,
		"[INTINT]"		: 0x02FB,
		"[R_P]"			: 0x11C0,
		"[XCLSIG]"		: 0x14B0,
		"[XDEG]"		: 0x171C,
		"[OFF]"			: 0x11C8,
		"[XGRAD]"		: 0x1726,
		"[DEROVF]"		: 0x08EB,
		"[XMSGPR]"		: 0x056D,
		"[XPACK]"		: 0x2000,
		"[FSTIN]"		: 0x14C2,
		"[LNC10_]"		: 0x1AAD,
		"[LNC10]"		: 0x1AAE,
		"[GTAINC]"		: 0x0304,
		"[NAMEA]"		: 0x0ED9,
		"[PR3RT]"		: 0x0EDD,
		"[RG9LCD]"		: 0x08EF,
		"[BRT160]"		: 0x1DA8,
		"[RTJLBL]"		: 0x14C9,
		"[ONE_BY_X]"	: 0x11D6,
		"[XRDN]"		: 0x14BD,
		"[BRT290]"		: 0x1DAC,
		"[NFRST_PLUS]"	: 0x0BEE,
		"[XROMNF]"		: 0x2F6C,
		"[NAME20]"		: 0x0EE6,
		"[GENLNK]"		: 0x239A,
		"[SEPXY]"		: 0x14D2,
		"[LNC20]"		: 0x1ABD,
		"[CHK_NO_S1]"	: 0x14D4,
		"[NAME21]"		: 0x0EE9,
		"[P_R]"			: 0x11DC,
		"[XSIZE]"		: 0x1795,
		"[CHK_NO_S]"	: 0x14D8,
		"[CHK_NO_S2]"	: 0x14D9,
		"[NAME33]"		: 0x0EEF,
		"[OUTLCD]"		: 0x2C80,
		"[PACK]"		: 0x11E7,
		"[PAKEND]"		: 0x20AC,
		"[XNNROW]"		: 0x0026,
		"[CLRSB2]"		: 0x0C00,
		"[MASK]"		: 0x2C88,
		"[CLRSB3]"		: 0x0C02,
		"[ERRAD]"		: 0x14E2,
		"[PCTCH]"		: 0x11EC,
		"[PARSE]"		: 0x0C05,
		"[XROLLUP]"		: 0x14E5,
		"[TBITMA]"		: 0x2F7F,
		"[TBITMP]"		: 0x2F81,
		"[XSTYON]"		: 0x1411,
		"[INSSUB]"		: 0x23B2,
		"[RDNSUB]"		: 0x14E9,
		"[XX_EQ_Y]"		: 0x1614,
		"[XX_LE_0]"		: 0x160D,
		"[R_SUB]"		: 0x14ED,
		"[XX_NE_0]"		: 0x1611,
		"[X_EQ_0]"		: 0x130E,
		"[X_EQ_Y]"		: 0x1314,
		"[AFORMT]"		: 0x0628,
		"[PSE]"			: 0x11FC,
		"[NAME37]"		: 0x0F09,
		"[X_GT_Y]"		: 0x1320,
		"[X_LT_0]"		: 0x12E8,
		"[X_TO_2]"		: 0x106B,
		"[GTO_5]"		: 0x29AA,
		"[X_XCHNG]"		: 0x124C,
		"[X_XCHNG_Y]"	: 0x12FC,
		"[LOAD3]"		: 0x14FA,
		"[Y_MINUS_X]"	: 0x1421,
		"[Y_TO_X]"		: 0x102A,
		"[GTBYT]"		: 0x29B0,
		"[PROMPT]"		: 0x1209,
		"[GTAI40]"		: 0x0341,
		"[GSUBS1]"		: 0x23C9,
		"[GTBYTO]"		: 0x29B2,
		"[BIGBRC]"		: 0x004F,
		"[R_D]"			: 0x120E,
		"[NXBYT3]"		: 0x29B7,
		"[SETSST]"		: 0x17F9,
		"[NXBYTA]"		: 0x29B9,
		"[ASRCH]"		: 0x26C5,
		"[GTBYTA]"		: 0x29BB,
		"[GOSUB0]"		: 0x23D2,
		"[STOP]"		: 0x1215,
		"[ADDONE]"		: 0x1800,
		"[GOL0]"		: 0x23D0,
		"[BRT140]"		: 0x1DEC,
		"[RUN_STOP]"	: 0x1218,
		"[SRBMAP]"		: 0x2FA5,
		"[CALDSP]"		: 0x29C3,
		"[GOL1]"		: 0x23D9,
		"[AD2_10]"		: 0x1807,
		"[PARS05]"		: 0x0C34,
		"[AD1_10]"		: 0x1809,
		"[LN1_PLUS_X]"	: 0x1220,
		"[DECAD]"		: 0x29C7,
		"[AD2_13]"		: 0x180C,
		"[DECADA]"		: 0x29CA,
		"[GOL2]"		: 0x23E2,
		"[GOSUB1]"		: 0x23DB,
		"[GOSUB2]"		: 0x23E4,
		"[INCAD]"		: 0x29CF,
		"[LASTX]"		: 0x1228,
		"[INCADP]"		: 0x29D1,
		"[GTFEN1]"		: 0x20EB,
		"[INCAD2]"		: 0x29D3,
		"[GTFEND]"		: 0x20E8,
		"[GOL3]"		: 0x23EB,
		"[INCADA]"		: 0x29D6,
		"[GOSUB3]"		: 0x23ED,
		"[NAM40]"		: 0x0F34,
		"[ENCP00]"		: 0x0952,
		"[XROW1]"		: 0x0074,
		"[PAKSPC]"		: 0x20F2,
		"[TXTLB1]"		: 0x2FC6,
		"[PGMAON]"		: 0x0956,
		"[RCL]"			: 0x122E,
		"[RFDS55]"		: 0x0949,
		"[XVIEW]"		: 0x036F,
		"[SUBONE]"		: 0x1802,
		"[CHS]"			: 0x123A,
		"[BRT200]"		: 0x1E0F,
		"[GSB000]"		: 0x23FA,
		"[INBYTP]"		: 0x29E5,
		"[INBYT]"		: 0x29E6,
		"[SCROLL]"		: 0x2CDC,
		"[ROMH05]"		: 0x066C,
		"[SCROL0]"		: 0x2CDE,
		"[INBYT1]"		: 0x29EA,
		"[GSB256]"		: 0x23FA,
		"[GSB512]"		: 0x23FA,
		"[MSGDLY]"		: 0x037C,
		"[GSB768]"		: 0x23FA,
		"[STMSGF]"		: 0x037E,
		"[INBYT0]"		: 0x29E3,
		"[INBYTC]"		: 0x29E4,
		"[NOREG9]"		: 0x095E,
		"[PKIOAS]"		: 0x2114,
		"[INSLIN]"		: 0x29F4,
		"[RSTSEQ]"		: 0x0384,
		"[INLIN2]"		: 0x29F6,
		"[CPGMHD]"		: 0x067B,
		"[XRTN]"		: 0x2703,
		"[PI]"			: 0x1242,
		"[RDN]"			: 0x1252,
		"[CLLCDE]"		: 0x2CF0,
		"[CPGM10]"		: 0x067F,
		"[PR10RT]"		: 0x0372,
		"[RSTKB]"		: 0x0098,
		"[RND]"			: 0x1257,
		"[ROMH35]"		: 0x0678,
		"[CLRLCD]"		: 0x2CF6,
		"[DATOFF]"		: 0x0390,
		"[RSTMSC]"		: 0x0392,
		"[OUTROM]"		: 0x2FEE,
		"[ROMHED]"		: 0x066A,
		"[KEYOP]"		: 0x068A,
		"[RST05]"		: 0x009B,
		"[ERROF]"		: 0x00A2,
		"[ROLLUP]"		: 0x1260,
		"[RSTMS0]"		: 0x038E,
		"[MP2_10]"		: 0x184D,
		"[TRC30]"		: 0x1E38,
		"[MP1_10]"		: 0x184F,
		"[LN10]"		: 0x1B45,
		"[KYOPCK]"		: 0x0693,
		"[MP2_13]"		: 0x1852,
		"[NBYTAB]"		: 0x2D06,
		"[NXTBYT]"		: 0x2D07,
		"[NBYTA0]"		: 0x2D04,
		"[NFRNC]"		: 0x00A5,
		"[SIGMA_PLUS]"	: 0x126D,
		"[NXBYTO]"		: 0x2D0B,
		"[INSHRT]"		: 0x2A17,
		"[STOPS]"		: 0x03A7,
		"[APPEND]"		: 0x2D0E,
		"[NAM44_]"		: 0x0F7D,
		"[NM44_5]"		: 0x0F7E,
		"[RAK06]"		: 0x0C7F,
		"[PSESTP]"		: 0x03AC,
		"[SEARC1]"		: 0x2434,
		"[ALPDEF]"		: 0x03AE,
		"[APNDNW]"		: 0x2D14,
		"[ERRIGN]"		: 0x00BB,
		"[PARSDE]"		: 0x0C90,
		"[MPY150]"		: 0x1865,
		"[COS]"			: 0x127C,
		"[PARS56]"		: 0x0C93,
		"[RSTMS1]"		: 0x0390,
		"[END2]"		: 0x03B6,
		"[NFRSIG]"		: 0x00C2,
		"[SNR10]"		: 0x243F,
		"[NFRENT]"		: 0x00C4,
		"[SHF10]"		: 0x186D,
		"[BAKDE]"		: 0x09A5,
		"[NFRKB]"		: 0x00C7,
		"[NRM10]"		: 0x1870,
		"[END3]"		: 0x03BE,
		"[NRM12]"		: 0x1872,
		"[NFRKB1]"		: 0x00C6,
		"[NFRX]"		: 0x00CC,
		"[NRM11]"		: 0x1871,
		"[CLRREG]"		: 0x2155,
		"[RSTSQ]"		: 0x0385,
		"[RTN30]"		: 0x272F,
		"[DATENT]"		: 0x2D2C,
		"[ROW12]"		: 0x2743,
		"[RTN]"			: 0x125C,
		"[CLCTMG]"		: 0x03C9,
		"[MOVREG]"		: 0x215C,
		"[XLN1_PLUS_X]"	: 0x1B73,
		"[PUTREG]"		: 0x215E,
		"[SCI]"			: 0x1265,
		"[SEARCH]"		: 0x2433,
		"[NFRXY]"		: 0x00DA,
		"[NAME4A]"		: 0x0FA4,
		"[NRM13]"		: 0x1884,
		"[SF]"			: 0x1269,
		"[XCOPY]"		: 0x2165,
		"[ALCL00]"		: 0x06C9,
		"[QUTCAT]"		: 0x03D5,
		"[SHF40]"		: 0x186C,
		"[SIGMA_MINUS]"	: 0x1271,
		"[NAME4D]"		: 0x0FAC,
		"[DROPST]"		: 0x00E4,
		"[STAYON]"		: 0x12A3,
		"[ONE_BY_X13]"	: 0x188E,
		"[INEX]"		: 0x2A4A,
		"[ONE_BY_X10]"	: 0x188B,
		"[SIGREG]"		: 0x1277,
		"[FILLXL]"		: 0x00EA,
		"[ERRRAM]"		: 0x2172,
		"[XDSE]"		: 0x159F,
		"[PACH4]"		: 0x03E2,
		"[NFRPR]"		: 0x00EE,
		"[SIN]"			: 0x1288,
		"[DV2_10]"		: 0x1898,
		"[DAT106]"		: 0x2D4C,
		"[DV1_10]"		: 0x189A,
		"[NFRC]"		: 0x00F1,
		"[NFRPU]"		: 0x00F0,
		"[DV2_13]"		: 0x189D,
		"[ROW0]"		: 0x2766,
		"[NFRFST]"		: 0x00F7,
		"[PACH10]"		: 0x03EC,
		"[PARS75]"		: 0x0CCD,
		"[SIZE]"		: 0x1292,
		"[STO_MINUS]"	: 0x12B9,
		"[SNR12]"		: 0x2441,
		"[DIV110]"		: 0x18A5,
		"[DSPLN_]"		: 0x0FC7,
		"[IN3B]"		: 0x2A65,
		"[PACH11]"		: 0x03F5,
		"[DIV15]"		: 0x18A9,
		"[ERRPR]"		: 0x2184,
		"[STO_DIVIDE]"	: 0x12C1,
		"[BAKAPH]"		: 0x09E3,
		"[SNROM]"		: 0x2400,
		"[NFRNIO]"		: 0x0106,
		"[DIV120]"		: 0x18AF,
		"[RUNING]"		: 0x0108,
		"[PACH12]"		: 0x03FC,
		"[SQRT]"		: 0x1298,
		"[SST]"			: 0x129E,
		"[POWER_OF_10]"	: 0x12CA,
		"[INSTR]"		: 0x2A73,
		"[STBT30]"		: 0x2FE0,
		"[STBT31]"		: 0x2FE5,
		"[GOLNGH]"		: 0x0FD9,
		"[GOLONG]"		: 0x0FDA,
		"[TONE]"		: 0x12D0,
		"[RAK60]"		: 0x06FA,
		"[GOSUBH]"		: 0x0FDD,
		"[GOSUB]"		: 0x0FDE,
		"[SQR10]"		: 0x18BE,
		"[INTXC]"		: 0x2A7D,
		"[VIEW]"		: 0x12D6,
		"[PAR111]"		: 0x0CED,
		"[SQR13]"		: 0x18C1,
		"[ERR0]"		: 0x18C3,
		"[DAT231]"		: 0x2D77,
		"[RUNNK]"		: 0x011D,
		"[X_NE_0]"		: 0x12DC,
		"[STOPSB]"		: 0x03A9,
		"[RAK70]"		: 0x070A,
		"[PAR112]"		: 0x0CF5,
		"[GT3DBT]"		: 0x0FEB,
		"[STO_MULT]"	: 0x12A8,
		"[X_NE_Y]"		: 0x12E2,
		"[LINNUM]"		: 0x2A8B,
		"[STO_PLUS]"	: 0x12B0,
		"[TAN]"			: 0x1282,
		"[TEXT]"		: 0x2CAF,
		"[TONSTF]"		: 0x0054,
		"[LINNM1]"		: 0x2A90,
		"[BKROM2]"		: 0x2A91,
		"[TOREC]"		: 0x1E75,
		"[LINN1A]"		: 0x2A93,
		"[TRCS10]"		: 0x1E57,
		"[TRG100]"		: 0x1E78,
		"[TXTLBL]"		: 0x2FC7,
		"[X_LE_0]"		: 0x12EF,
		"[XASN]"		: 0x276A,
		"[XAVIEW]"		: 0x0364,
		"[XCUTB1]"		: 0x0091,
		"[XCUTEB]"		: 0x0090,
		"[LN560]"		: 0x1BD3,
		"[XEND]"		: 0x2728,
		"[X_LE_Y]"		: 0x12F6,
		"[DAT260]"		: 0x2D94,
		"[XGA00]"		: 0x248D,
		"[STOST0]"		: 0x013B,
		"[XX_LT_Y]"		: 0x15EF,
		"[DAT280]"		: 0x2D98,
		"[ABTSEQ]"		: 0x0D12,
		"[TRG240]"		: 0x1ED1,
		"[DAT300]"		: 0x2D9B,
		"[XISG]"		: 0x15A0,
		"[ABTS10]"		: 0x0D16,
		"[XPRMPT]"		: 0x03A0,
		"[XFT100]"		: 0x18EC,
		"[XGI57]"		: 0x24C1,
		"[XROM]"		: 0x2FAF,
		"[DAT320]"		: 0x2DA2,
		"[XSIGN]"		: 0x0FF4,
		"[XX_GT_0]"		: 0x15F1,
		"[X_LT_Y]"		: 0x1308,
		"[XGI]"			: 0x24C7,
		"[PMUL]"		: 0x1BE9,
		"[TRGSET]"		: 0x21D4,
		"[PARA06]"		: 0x0D22,
		"[XX_GT_Y]"		: 0x15F8,
		"[XRND]"		: 0x0A2F,
		"[ASN15]"		: 0x27C2,
		"[XX_LE_Y]"		: 0x1601,
		"[XX_EQ_0]"		: 0x1606,
		"[XX_LT_0]"		: 0x15FA,
		"[PATCH1]"		: 0x21DC,
		"[ROUND]"		: 0x0A35,
		"[XX_LE_0A]"	: 0x1609,
		"[XY_TO_X]"		: 0x1B11,
		"[X_BY_Y13]"	: 0x1893,
		"[PATCH2]"		: 0x21E1,
		"[ASN20]"		: 0x27CC,
		"[X_GT_0]"		: 0x131A,
		"[NOPRT]"		: 0x015B,
		"[XGI07]"		: 0x24DA,
		"[OFSHFT]"		: 0x0749,
		"[DROWSY]"		: 0x0160,
		"[DRSY05]"		: 0x0161,
		"[SAVRTN]"		: 0x27D3,
		"[GTSRCH]"		: 0x24DF,
		"[SAVR10]"		: 0x27D5,
		"[XGOIND]"		: 0x1323,
		"[NOSKP]"		: 0x1619,
		"[DOSRC1]"		: 0x24E3,
		"[DOSRCH]"		: 0x24E4,
		"[HMS_PLUS]"	: 0x1032,
		"[XEQ]"			: 0x1328,
		"[OFFSHF]"		: 0x0750,
		"[PATCH5]"		: 0x21F3,
		"[DEC]"			: 0x132B,
		"[SAVRC]"		: 0x27DF,
		"[RSTANN]"		: 0x0759,
		"[PARA60]"		: 0x0D35,
		"[ANN_14]"		: 0x075B,
		"[ANNOUT]"		: 0x075C,
		"[DRSY25]"		: 0x0173,
		"[IORUN]"		: 0x27E4,
		"[PARA75]"		: 0x0D49,
		"[XX_NE_Y]"		: 0x1629,
		"[OCT]"			: 0x1330,
		"[STSCR_]"		: 0x1920,
		"[SIGN]"		: 0x1337,
		"[STSCR]"		: 0x1922,
		"[MSGAD]"		: 0x1C18,
		"[HMS_MINUS]"	: 0x1045,
		"[PARA61]"		: 0x0D37,
		"[AON]"			: 0x133C,
		"[DOSKP]"		: 0x1631,
		"[LSWKUP]"		: 0x0180,
		"[PLUS]"		: 0x104A,
		"[EXSCR]"		: 0x192A,
		"[RMCK15]"		: 0x27F4,
		"[WKUP10]"		: 0x0184,
		"[MSGDE]"		: 0x1C22,
		"[MOD]"			: 0x104F,
		"[AOFF]"		: 0x1345,
		"[PATCH3]"		: 0x21EE,
		"[XGTO]"		: 0x2505,
		"[RCSCR_]"		: 0x1932,
		"[MINUS]"		: 0x1054,
		"[BSTE2]"		: 0x2AF2,
		"[DF150]"		: 0x0482,
		"[PATCH6]"		: 0x1C06,
		"[MODE]"		: 0x134D,
		"[DF160]"		: 0x0485,
		"[MODE1]"		: 0x134F,
		"[ROW940]"		: 0x0487,
		"[INTFRC]"		: 0x193B,
		"[DRSY51]"		: 0x0194,
		"[DRSY50]"		: 0x0190,
		"[XGNN10]"		: 0x2512,
		"[NXLDEL]"		: 0x2AFD,
		"[PCT]"			: 0x1061,
		"[PARSEB]"		: 0x0D6D,
		"[XCF]"			: 0x164D,
		"[MSGNE]"		: 0x1C38,
		"[FORMAT]"		: 0x0A7B,
		"[MSGML]"		: 0x1C2D,
		"[FLGANN]"		: 0x1651,
		"[MSGNL]"		: 0x1C3C,
		"[MULTIPLY]"	: 0x105C,
		"[NXLSST]"		: 0x2AF7,
		"[SINFRA]"		: 0x194A,
		"[PATCH9]"		: 0x1C03,
		"[PUTPCL]"		: 0x2AF3,
		"[RCSCR]"		: 0x1934,
		"[DIVIDE]"		: 0x106F,
		"[PR14RT]"		: 0x1365,
		"[MSGPR]"		: 0x1C43,
		"[RMCK05]"		: 0x27EC,
		"[DAT400]"		: 0x2E05,
		"[RMCK10]"		: 0x27F3,
		"[ROMCHK]"		: 0x27E6,
		"[ABS]"			: 0x1076,
		"[NXLIN]"		: 0x2B14,
		"[INBCHS]"		: 0x2E0A,
		"[DSWKUP]"		: 0x01AD,
		"[INBYTJ]"		: 0x2E0C,
		"[MSGOF]"		: 0x1C4F,
		"[XR_S]"		: 0x079D,
		"[ACOS]"		: 0x107D,
		"[DAT500]"		: 0x2E10,
		"[SUMCK2]"		: 0x1669,
		"[LDSST0]"		: 0x0797,
		"[DEROW]"		: 0x04AD,
		"[MSGWR]"		: 0x1C56,
		"[WKUP25]"		: 0x01BA,
		"[CHKADR]"		: 0x166E,
		"[AGTO]"		: 0x1085,
		"[DERW00]"		: 0x04B2,
		"[ERRDE]"		: 0x282D,
		"[MOD10]"		: 0x195C,
		"[GTLNKA]"		: 0x2247,
		"[NXL1B]"		: 0x2B23,
		"[MSGTA]"		: 0x1C5F,
		"[ARCL]"		: 0x108C,
		"[NXLINA]"		: 0x2B1F,
		"[CAT3]"		: 0x1383,
		"[MSGYES]"		: 0x1C62,
		"[GTLINK]"		: 0x224E,
		"[MSGNO]"		: 0x1C64,
		"[ASHF]"		: 0x1092,
		"[MSGRAM]"		: 0x1C67,
		"[P6RTN]"		: 0x1670,
		"[PARB40]"		: 0x0D99,
		"[MSGROM]"		: 0x1C6A,
		"[MSG]"			: 0x1C6B,
		"[ASIN]"		: 0x1098,
		"[MSGA]"		: 0x1C6C,
		"[ROW933]"		: 0x0467,
		"[SERR]"		: 0x24E8,
		"[CHKAD4]"		: 0x1686,
		"[MSGE]"		: 0x1C71,
		"[ASN]"			: 0x109E,
		"[SHIFT]"		: 0x1348,
		"[SINFR]"		: 0x1947,
		"[MSGX]"		: 0x1C75,
		"[DTOR]"		: 0x1981,
		"[RUN]"			: 0x07C2,
		"[ASTO]"		: 0x10A4,
		"[SKPLIN]"		: 0x2AF9,
		"[SKP]"			: 0x162E,
		"[IND]"			: 0x0DB2,
		"[SUMCHK]"		: 0x1667,
		"[TEN_TO_X]"	: 0x1BF8,
		"[ATAN]"		: 0x10AA,
		"[TRG430]"		: 0x1F5B,
		"[MSG105]"		: 0x1C80,
		"[FIX57]"		: 0x0AC3,
		"[NXLCHN]"		: 0x2B49,
		"[RTOD]"		: 0x198C,
		"[ROLBAK]"		: 0x2E42,
		"[TOOCT]"		: 0x1F79,
		"[AVIEW]"		: 0x10B2,
		"[NWGOOS]"		: 0x07D4,
		"[SIGMA]"		: 0x1C88,
		"[AXEQ]"		: 0x10B5,
		"[LD90]"		: 0x1995,
		"[MSG110]"		: 0x1C86,
		"[UPLINK]"		: 0x2235,
		"[IND21]"		: 0x0DC4,
		"[OPROMT]"		: 0x2E4C,
		"[BEEP]"		: 0x10BB,
		"[DF200]"		: 0x04E7,
		"[RW0110]"		: 0x04E9,
		"[WKUP70]"		: 0x01F5,
		"[PI_BY_2]"		: 0x199A,
		"[INTARG]"		: 0x07E1,
		"[STFLGS]"		: 0x16A7,
		"[BST]"			: 0x10C2,
		"[NXLIN3]"		: 0x2B5F,
		"[TRC10]"		: 0x19A1,
		"[AJ3]"			: 0x0DD0,
		"[NXL3B2]"		: 0x2B63,
		"[NOTFIX]"		: 0x0ADD,
		"[CAT]"			: 0x10C8,
		"[AJ2]"			: 0x0DD4,
		"[TXRW10]"		: 0x04F6,
		"[RW0141]"		: 0x04F1,
		"[CF]"			: 0x10CC,
		"[STOLCC]"		: 0x2E5B,
		"[CLRPGM]"		: 0x228C,
		"[INLIN]"		: 0x2876,
		"[APHST_]"		: 0x2E62,
		"[CLA]"			: 0x10D1,
		"[MEMCHK]"		: 0x0205,
		"[XTOHRS]"		: 0x19B2,
		"[MESSL]"		: 0x07EF,
		"[ENLCD]"		: 0x07F6,
		"[XSCI]"		: 0x16C0,
		"[MIDDIG]"		: 0x0DE0,
		"[STORFC]"		: 0x07E8,
		"[TXTROM]"		: 0x04F5,
		"[NXLTX]"		: 0x2B77,
		"[STO]"			: 0x10DA,
		"[TXTROW]"		: 0x04F2,
		"[TXTSTR]"		: 0x04F6,
		"[WKUP21]"		: 0x01A7,
		"[GTRMAD]"		: 0x0800,
		"[CLDSP]"		: 0x10E0,
		"[WKUP80]"		: 0x01FF,
		"[XARCL]"		: 0x1696,
		"[GCPKC]"		: 0x2B80,
		"[XBST]"		: 0x2250,
		"[XCUTE]"		: 0x015B,
		"[XEQC01]"		: 0x24EA,
		"[CLP]"			: 0x10E7,
		"[STK]"			: 0x0DF3,
		"[XBEEP]"		: 0x16D1,
		"[DELNNN]"		: 0x22A8,
		"[CHKRPC]"		: 0x0222,
		"[GCPKC0]"		: 0x2B89,
		"[CLREG]"		: 0x10ED,
		"[ROW120]"		: 0x0519,
		"[STK00]"		: 0x0DFA,
		"[TODEC]"		: 0x1FB3,
		"[TONE7X]"		: 0x16DB,
		"[XDELET]"		: 0x22AF,
		"[CLSIG]"		: 0x10F3,
		"[STATCK]"		: 0x1CC8,
		"[STK04]"		: 0x0E00,
		"[TONEB]"		: 0x16DD,
		"[XFS]"			: 0x1645,
		"[XGNN12]"		: 0x2514,
		"[CLST]"		: 0x10F9,
		"[ROW11]"		: 0x25AD,
		"[COLDST]"		: 0x0232,
		"[XGNN40]"		: 0x255D,
		"[XRS45]"		: 0x07BE,
		"[XSF]"			: 0x164A,
		"[SETQ_P]"		: 0x0B15,
		"[XSGREG]"		: 0x1659,
		"[CLX]"			: 0x1101,
		"[XCLX1]"		: 0x1102,
		"[XSST]"		: 0x2260,
		"[XTONE]"		: 0x16DE,
		"[XXEQ]"		: 0x252F,
		"[CHSA]"		: 0x1CDA,
		"[LDD_P_]"		: 0x0B1D,
		"[CHSA1]"		: 0x1CDC,
		"[COPY]"		: 0x1109,
		"[HMSDV]"		: 0x19E5,
		"[FCNTBL]"		: 0x1400,
		"[ADD1]"		: 0x1CE0,
		"[HMSMP]"		: 0x19E7,
		"[D_R]"			: 0x110E,
		"[ADD2]"		: 0x1CE3,
		"[DSPCRG]"		: 0x0B26,
		"[STBT10]"		: 0x2EA3,
		"[GTACOD]"		: 0x1FDB,
		"[LDDP10]"		: 0x0B1E,
		"[DEG]"			: 0x1114,
		"[DGENS8]"		: 0x0836,
		"[DIGENT]"		: 0x0837,
		"[GETXY]"		: 0x1CEB,
		"[GCP112]"		: 0x2BB5,
		"[GETY]"		: 0x1CED,
		"[GETXSQ]"		: 0x1CEE,
		"[GETX]"		: 0x1CEF,
		"[AVAIL]"		: 0x28C4,
		"[GETN]"		: 0x1CEA,
		"[TGSHF1]"		: 0x1FE7,
		"[AVAILA]"		: 0x28C7,
		"[DSPCA]"		: 0x0B35,
		"[GCPK05]"		: 0x2BBE,
		"[GCPK04]"		: 0x2BBC,
		"[GETYSQ]"		: 0x1CEC,
		"[DEL]"			: 0x1124,
		"[FDIGIT]"		: 0x0E2F,
		"[GETLIN]"		: 0x1419,
		"[DELETE]"		: 0x1127,
		"[GRAD]"		: 0x111A,
		"[LNSUB]"		: 0x19F9,
		"[APND_]"		: 0x1FF3,
		"[EXP10]"		: 0x1A0A,
		"[APND10]"		: 0x1FF5,
		"[DFKBCK]"		: 0x0559,
		"[EXP13]"		: 0x1A0D,
		"[DSE]"			: 0x112D,
		"[DECMPL]"		: 0x2EC2,
		"[APNDDG]"		: 0x1FFA,
		"[END]"			: 0x1132,
		"[XBAR_]"		: 0x1D07,
		"[OVFL10]"		: 0x1429,
		"[DFRST9]"		: 0x0561,
		"[BSTEP]"		: 0x28DE,
		"[DFILLF]"		: 0x0563,
		"[XRAD]"		: 0x1722,
		"[PACKE]"		: 0x2002,
		"[NEXT1]"		: 0x0E45,
		"[DCPL00]"		: 0x2EC3,
		"[SD]"			: 0x1D10,
		"[CAT2]"		: 0x0B53,
		"[ENTER]"		: 0x113E,
		"[DFRST8]"		: 0x0562,
		"[DEGDO]"		: 0x172A,
		"[ERR120]"		: 0x22FF,
		"[EXP400]"		: 0x1A21,
		"[BSTEPA]"		: 0x28EB,
		"[ENG]"			: 0x1135,
		"[NEXT]"		: 0x0E50,
		"[FNDEND]"		: 0x1730,
		"[E_TO_X]"		: 0x1147,
		"[DELLIN]"		: 0x2306,
		"[CLR]"			: 0x1733,
		"[ERR110]"		: 0x22FB,
		"[ERROR]"		: 0x22F5,
		"[ERRSUB]"		: 0x22E8,
		"[ADVNCE]"		: 0x114D,
		"[FDIG20]"		: 0x0E3D,
		"[INCGT2]"		: 0x0286,
		"[LNSUB_MINUS]"	: 0x19F8,
		"[NEXT2]"		: 0x0E48,
		"[NEXT3]"		: 0x0E4B,
		"[NROOM3]"		: 0x28C2,
		"[FACT]"		: 0x1154,
		"[PACKN]"		: 0x2000,
		"[PCKDUR]"		: 0x16FC,
		"[PR15RT]"		: 0x22DF,
		"[RAD]"			: 0x111F,
		"[SGTO19]"		: 0x25C9,
		"[FC]"			: 0x115A,
		"[DF060]"		: 0x0587,
		"[PTLINK]"		: 0x231A,
		"[PTLNKA]"		: 0x231B,
		"[XASHF]"		: 0x1748,
		"[LEFTJ]"		: 0x2BF7,
		"[NULT_]"		: 0x0E65,
		"[SAROM]"		: 0x260D,
		"[SSTBST]"		: 0x22DD,
		"[BSTE]"		: 0x290B,
		"[E_TO_X_MIN1]"	: 0x1163,
		"[PTBYTA]"		: 0x2323,
		"[PTLNKB]"		: 0x2321,
		"[TOGSHF]"		: 0x1FE5,
		"[TONE7]"		: 0x1716,
		"[XBAR]"		: 0x1CFE,
		"[PTBYTP]"		: 0x2328,
		"[DEEXP]"		: 0x088C,
		"[FC_C]"		: 0x116B,
		"[EXP710]"		: 0x1A4C,
		"[PUTPCD]"		: 0x232C,
		"[ROW10]"		: 0x02A6,
		"[FIXEND]"		: 0x2918,
		"[EXP720]"		: 0x1A50,
		"[XASTO]"		: 0x175C,
		"[ARGOUT]"		: 0x2C10,
		"[FIX]"			: 0x1171,
		"[MEMLFT]"		: 0x05A1,
		"[NULT_3]"		: 0x0E7C,
		"[GTCNTR]"		: 0x0B8D,
		"[BLINK1]"		: 0x0899,
		"[DCPLRT]"		: 0x2F0B,
		"[BLINK]"		: 0x0899,
		"[DCRT10]"		: 0x2F0D,
		"[FRAC]"		: 0x117C,
		"[FLINKP]"		: 0x2925,
		"[INT]"			: 0x1177,
		"[FLINKA]"		: 0x2927,
		"[FLINK]"		: 0x2928,
		"[FLINKM]"		: 0x2929,
		"[EXP500]"		: 0x1A61,
		"[FS]"			: 0x1182,
		"[NULT_5]"		: 0x0E8F,
		"[ERRTA]"		: 0x2F17,
		"[NLT000]"		: 0x0E91,
		"[CNTLOP]"		: 0x0B9D,
		"[FS_C]"		: 0x1188,
		"[INPTDG]"		: 0x08A0,
		"[P10RTN]"		: 0x02AC,
		"[BLANK]"		: 0x05B7,
		"[DERUN]"		: 0x08AD,
		"[CHRLCD]"		: 0x05B9,
		"[AOUT15]"		: 0x2C2B,
		"[CHKFUL]"		: 0x05BA,
		"[FIND_NO_1]"	: 0x1775,
		"[DIGST_]"		: 0x08B2,
		"[GTOL]"		: 0x118C,
		"[HMS_H]"		: 0x1193,
		"[GTO]"			: 0x1191,
		"[NLT020]"		: 0x0EA0,
		"[ALLOK]"		: 0x02CD,
		"[BRTS10]"		: 0x1D6B,
		"[PAK200]"		: 0x2055,
		"[H_HMS]"		: 0x1199,
		"[PTBYTM]"		: 0x2921,
		"[PROMFC]"		: 0x05C7,
		"[PUTPCA]"		: 0x2339,
		"[PUTPCF]"		: 0x2331,
		"[ISG]"			: 0x119E,
		"[NLT040]"		: 0x0EAA,
		"[PROMF1]"		: 0x05CB,
		"[R_SCAT]"		: 0x0BB7,
		"[PUTPCX]"		: 0x232F,
		"[PUTPC]"		: 0x2337,
		"[BSTCAT]"		: 0x0BBA,
		"[LBL]"			: 0x11A4,
		"[LN]"			: 0x11A6,
		"[PROMF2]"		: 0x05D3,
		"[GETPC]"		: 0x2950,
		"[ERRNE]"		: 0x02E0,
		"[GETPCA]"		: 0x2952,
		"[LNAP]"		: 0x1A8A,
		"[BCDBIN]"		: 0x02E3,
		"[CAT1]"		: 0x0BC3,
		"[BRT100]"		: 0x1D80,
		"[LOG]"			: 0x11AC,
		"[REGLFT]"		: 0x059A,
		"[GTONN]"		: 0x2959,
		"[STDEV]"		: 0x11B2,
		"[RSTST]"		: 0x08A7,
		"[SARO21]"		: 0x2640,
		"[SARO22]"		: 0x2641,
		"[SIZSUB]"		: 0x1797,
		"[SKPDEL]"		: 0x2349,
		"[XECROM]"		: 0x2F4A,
		"[MEAN]"		: 0x11B9,
		"[SSTCAT]"		: 0x0BB4,
		"[NULTST]"		: 0x0EC6,
		"[GENNUM]"		: 0x05E8,
		"[TOPOL]"		: 0x1D49
	]

	enum NumberMode: Int, Codable {
		case hex
		case oct
	}

	var numberMode: NumberMode = .hex

	enum OpcodeNames: Int, Codable {
		case hp			= 0
		case zencode	= 1
		case jacobs		= 2
	}
	
	var names = OpcodeNames.hp
	
	static let sharedInstance = Disassembly()

	enum CodingKeys: String, CodingKey {
		case numberMode
		case names
	}

	init() {
		
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		numberMode = try values.decode(NumberMode.self, forKey: .numberMode)
		names = try values.decode(OpcodeNames.self, forKey: .names)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(numberMode, forKey: .numberMode)
		try container.encode(names, forKey: .names)
	}

	func getOpcodeName(_ opcode: Int) -> String {
		return opCodes[names.rawValue][opcode]
	}
	
	func getTEFName(_ tef: Int) -> String {
		return TEFs[names.rawValue][tef]
	}
	
	func getLocForAddress(_ address: Int) -> String? {
		for (key, value) in globalDict {
			if address == value {
				return key
			}
		}
		
		return nil
	}
	
	func bitRepresentation(value: Int, lenght aLenght: Int) -> String? {
		var intValue = value
		let max: Int = Int(pow(Double(2), Double(aLenght)) - 1)
		if intValue > max {
			return nil
		}
		
		var rep = ""
		for idx in Array((0..<aLenght).reversed()) {
			let m: Int = Int(pow(Double(2), Double(idx)))
			if intValue >= m {
				rep += "1"
				intValue -= m
			} else {
				rep += "0"
			}
		}
		
		return rep
	}
	
	func fetchNextROMAddress() throws -> Int {
		let nextAddress = Int(cpu.savedPC) + 1
		do {
			let result = try bus.readRomAddress(nextAddress)
			return result
		} catch {
			if TRACE != 0 {
				print("error read ROM at Address: \(nextAddress)")
			}
			throw RomError.invalidAddress
		}
	}
	
	func getLabelForCurrentAddress() -> String {
		if let label = getLocForAddress(Int(cpu.savedPC)) {
			if label.count < 8 {
				return label + "\t"
			} else {
				return label
			}
		} else {
			return ""
		}
	}

	func disassemblyClass0Line0(_ anOpCode: OpCode) -> String {
		do {
			let result = try fetchNextROMAddress()
			
			let pc = NSString(format:"%04X", cpu.savedPC) as String
			let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
			let nextTyteStr = NSString(format: "%03X", result) as String
			switch anOpCode.row {
			case 0x0,	// NOP
			0x1,	// WMLDL
			0x4,	// ENBANK1
			0x6,	// ENBANK2
			0x5,	// ENBANK3
			0x7,	// ENBANK4
			0x2,	// NOT USED
			0x3:
				return "\(pc)\t\(tyteStr)\(nextTyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(16 + anOpCode.row))"
			default:
				let paramStr = NSString(format: "%X", anOpCode.row - 8) as String
				return "\(pc)\t\(tyteStr)\(nextTyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(121))\t\(paramStr)"
			}
		} catch {
			return "ERROR: NO NEXT ROM LOCATION"
		}
	}

	func disassemblyClass0Line1(_ anOpCode: OpCode) -> String {
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
		switch anOpCode.row {
		case 0x7:
			// NOT USED
			return "\(pc)\t\(tyteStr)"
		case 0xF:
			// ST=0
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(122))"
		default:
			// CF 0-13
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(1))\t\(fTable[anOpCode.row])"
		}
	}
	
	func disassemblyClass0Line2(_ anOpCode: OpCode) -> String {
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
		switch anOpCode.row {
		case 0x7:
			// NOT USED
			return "\(pc)\t\(tyteStr)"
		case 0xF:
			// CLRKEY
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(123))"
		default:
			// SF 0-13
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(2))\t\(fTable[anOpCode.row])"
		}
	}

	func disassemblyClass0Line3(_ anOpCode: OpCode) -> String {
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
		switch anOpCode.row {
		case 0x7:
			// NOT USED
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())"
		case 0xF:
			// ?KEY
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(124))"
		default:
			// ?FS 0-13
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(3))\t\t\(fTable[anOpCode.row])"
		}
	}
	
	func disassemblyClass0Line4(_ anOpCode: OpCode) -> String {
		// LC 0-15 (HP) OR LC 0-9,A-F (OTHERS)
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
		if names == OpcodeNames.hp {
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(4))\t\(anOpCode.row)"
		} else {
			let paramStr = NSString(format: "%1X", anOpCode.row) as String
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(4))\t\(paramStr)"
		}
	}

	func disassemblyClass0Line5(_ anOpCode: OpCode) -> String {
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
		switch anOpCode.row {
		case 0x7:
			// NOT USED
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())"
		case 0xF:
			// -PT
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(125))"
		default:
			// ?PT 0-15
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(5))\t\(fTable[Int(anOpCode.row)])"
		}
	}

	func disassemblyClass0Line6(_ anOpCode: OpCode) -> String {
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
		return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(24 + anOpCode.row))"
	}
	
	func disassemblyClass0Line7(_ anOpCode: OpCode) -> String {
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
		switch anOpCode.row {
		case 0x7:
			// LITERAL
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())"
		case 0xF:
			// +PT
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(126))"
		default:
			// PT 0-15
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(7))\t\(fTable[Int(anOpCode.row)])"
		}
	}
	
	func disassemblyClass0Line8(_ anOpCode: OpCode) -> String {
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
		return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(40 + anOpCode.row))"
	}
	
	func disassemblyClass0Line9(_ anOpCode: OpCode) -> String {
		// PERTCT 0-15 (HP) OR PERTCT 0-9,A-F (OTHERS)
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
		if names == OpcodeNames.hp {
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(9)) \t\(anOpCode.row)"
		} else {
			let paramStr = NSString(format: "%1X", anOpCode.row) as String
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(9))\t\(paramStr)"
		}
	}
	
	func disassemblyClass0LineA(_ anOpCode: OpCode) -> String {
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
		let paramStr = NSString(format: "%1X", anOpCode.row) as String
		switch cpu.reg.peripheral {
		case 0x0:
			// ram
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(10))\t\(paramStr)"
		case 0xfb:
			// timer write
			if cpu.reg.ramAddress > 0x39 || cpu.reg.ramAddress < 0x10 {
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(10))\t\(paramStr)"
			} else {
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(134 + anOpCode.row))\tmodif=\(anOpCode.row)"
			}
		case 0xfc:
			// card reader
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(156 + anOpCode.row))"
		case 0xfd:
			// main display
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(56 + anOpCode.row))"
		case 0xfe:
			// wand
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\twand"
		case 0x10:
			// halfnut display
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\thalfnut write"
		default:
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())"
		}
	}
	
	func disassemblyClass0LineB(_ anOpCode: OpCode) -> String {
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
		return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(72 + anOpCode.row))"
	}
	
	func disassemblyClass0LineC(_ anOpCode: OpCode) -> String {
			let pc = NSString(format:"%04X", cpu.savedPC) as String
			let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
//			var paramStr = NSString(format: "%1X", fTable[Int(anOpCode.row())]) as String
		switch anOpCode.row {
			case 0x1:
				// N=C
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(88 + anOpCode.row))"
			case 0x2:
				// C=N
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(88 + anOpCode.row))"
			case 0x3:
				// C<>N
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(88 + anOpCode.row))"
			case 0x4:
				// LDI
				do {
					let result = try fetchNextROMAddress()
					
					let nextTyteStr = NSString(format: "%03X", result) as String
					return "\(pc)\t\(tyteStr)\(nextTyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(88 + anOpCode.row))\t\(nextTyteStr)"
				} catch {
					return "ERROR: NO NEXT ROM LOCATION"
				}
			case 0x5:
				// STK=C
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(88 + anOpCode.row))"
			case 0x6:
				// C=STK
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(88 + anOpCode.row))"
			case 0x8:
				// GTOKEY
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(88 + anOpCode.row))"
			case 0x9:
				// RAMSLCT
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(88 + anOpCode.row))"
//			case 0xA:
//				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\tCLRDATA"
			case 0xB:
				// WDATA
				switch cpu.reg.peripheral {
				case 0x0:
					// ram
					return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(99))"
				case 0xfd:
					// main display
					return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(120))"
				case 0xfb:
					// timer
					return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(99))"
				default:
					return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t"
				}
			case 0xC:
				// RDROM
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(88 + anOpCode.row))"
			case 0xD:
				// C=CORA
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(88 + anOpCode.row))"
			case 0xE:
				// C=CANDA
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(88 + anOpCode.row))"
			case 0xF:
				// PERSLCT
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(88 + anOpCode.row))"
			default:
				// NOT USED
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())"
			}
	}
	
	func disassemblyClass0LineD(_ anOpCode: OpCode) -> String {
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
		return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())"							// Not used
	}
	
	func disassemblyClass0LineE(_ anOpCode: OpCode) -> String {
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
		switch cpu.reg.peripheral {
		case 0x0:
			// ram
			if anOpCode.row == 0 {
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(127))"
			} else {
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(14))\t\(anOpCode.row)"
			}
		case 0xfb:
			// timer
			if anOpCode.row > 5 {
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(14))\t\(anOpCode.row)"
			} else {
				return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(150 + anOpCode.row))\tmodif=\(anOpCode.row)"
			}
		case 0xfc:
			// card reader
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\tcard_reader"
		case 0xfd:
			// main display
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(104 + anOpCode.row))"
		case 0xfe:
			// wand
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\twand read"
		case 0x10:
			// halfnut display
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\thalfnut read"
		default:
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\tunknown peripherial"
		}
	}
	
	func disassemblyClass0LineF(_ anOpCode: OpCode) -> String {
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
		switch anOpCode.row {
		case 0x7, 0xF:
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())"
		default:
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(15))\t\(fTable[anOpCode.row])"
		}
	}
	
	
	func disassemblyClass1(_ anOpCode: OpCode) -> String {
		do {
			let result = try fetchNextROMAddress()
			
			let pc = NSString(format:"%04X", cpu.savedPC) as String
			let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
			let nextType = OpCode(opcode: result)
			let nextTyteStr = NSString(format: "%03X", nextType.opcode) as String
			let addr = (nextType.opcode & 0x3fc) << 6 | (anOpCode.opcode & 0x3fc) >> 2
			let addrStr = NSString(format: "%04X", addr) as String
			switch nextType.set {
			case 0x0:
				// NCXQ
				if let label = getLocForAddress(addr) {
					return "\(pc)\t\(tyteStr)\(nextTyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(128)) \t\(label)\t\(addrStr)"
				} else {
					return "\(pc)\t\(tyteStr)\(nextTyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(128)) \t\(addrStr)"
				}
			case 0x1:
				// CQX
				if let label = getLocForAddress(addr) {
					return "\(pc)\t\(tyteStr)\(nextTyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(129)) \t\(label)\t\(addrStr)"
				} else {
					return "\(pc)\t\(tyteStr)\(nextTyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(129)) \t\(addrStr)"
				}
			case 0x2:
				// NCGO
				if let label = getLocForAddress(addr) {
					return "\(pc)\t\(tyteStr)\(nextTyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(130)) \t\(label)\t\(addrStr)"
				} else {
					return "\(pc)\t\(tyteStr)\(nextTyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(130)) \t\(addrStr)"
				}
			case 0x3:
				// CGO
				if let label = getLocForAddress(addr) {
					return "\(pc)\t\(tyteStr)\(nextTyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(131)) \t\(label)\t\(addrStr)"
				} else {
					return "\(pc)\t\(tyteStr)\(nextTyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(131)) \t\(addrStr)"
				}
			default:
				return "\(pc)\t\(tyteStr)\(nextTyteStr)"
			}
		} catch {
			return "ERROR: NO NEXT ROM LOCATION"
		}
	}
	
	func disassemblyClass2(_ anOpCode: OpCode) -> String {
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String
		_ = bitRepresentation(value: anOpCode.tef, lenght: 3)
		let subclass = (anOpCode.opcode & 0x3e0) >> 5
		
		return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(172 + subclass)) \t\(getTEFName(anOpCode.tef))"
	}
	
	func disassemblyClass3(_ anOpCode: OpCode) -> String {
		let pc = NSString(format:"%04X", cpu.savedPC) as String
		let tyteStr = NSString(format: "%03X", anOpCode.opcode) as String

		let oncarry = (anOpCode.opcode & 0x0004) >> 2;
		var displacement = (anOpCode.opcode & 0x01f8) >> 3
		if (anOpCode.opcode & 0x0200) != 0 {
			displacement = -(64 - displacement)
		}
		let displacementStr = NSString(format: "%+d", displacement);
		
		let addr = Int(cpu.savedPC) + displacement
		let addrStr = NSString(format: "%04X", addr) as String
		
		if let label = getLocForAddress(addr) {
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(204 + oncarry)) \t\(displacementStr) \t\(label) \t\(addrStr)"
		} else {
			return "\(pc)\t\(tyteStr)\t\(getLabelForCurrentAddress())\t\(getOpcodeName(204 + oncarry)) \t\(displacementStr) \t\(addrStr)"
		}
	}

	struct DisassembledLine {
		var address: String? = nil
		var instruction: String? = nil
		var desc: String? = nil
		var sufix: String? = nil
		var nwords: Int? = 0
	}
	
	func disassembleInstruction(_ numberMode: NumberMode, programCounter: Int, word1: Int, word2: Int) -> DisassembledLine {
		var line = DisassembledLine()
		if word1 == 0x130 {
			line.desc = "LDI S&X"
			line.sufix = formatNumber(word2, bits: 10)
			line.nwords = 2
		} else {
			switch (word1 & 0x3) {
			case 0:
//				DisassembleClass0(word1, prefix, suffix);
				line.nwords = 1;
				
			case 1:
//				DisassembleClass1(word1, word2, prefix, suffix);
				line.nwords = 2;

			case 2:
//				DisassembleClass2(word1, prefix, suffix);
				line.nwords = 1;
				
			case 3:
//				DisassembleClass3(pc, word1, prefix, suffix);
				line.nwords = 1;

			default:
				break
			}
		}
		
		return line
	}
	
	func formatNumber(_ value: Int, bits: Int) -> String {
		switch numberMode {
		case .hex:
			return NSString(format:"%0*X", (bits + 3) / 4, value) as String
		case .oct:
			return NSString(format:"%0*o", (bits + 2) / 3, value) as String
		}
	}
}

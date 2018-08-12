//
//  Timer.swift
//  my41
//
//  Created by Miroslav Perovic on 8/28/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

// TimerSeected ==1 if TIMER=A, ==0 if TIMER=B
// Clock A is usually current time and B is usually stopwatch time (good until Dec 20, 2330)
// Alarm A is usually time of next alarm or cleared. B usually has a constant of 09999999999000h which is checked for timer integrity
// Scratch A is used to hold the last time when corrected.  B bit 5 is set for 24 hour, bit 6 is set for display of both time and date.
// Interval A,B - 56 bits total but only 20 are used: [4-0] sss.hh where sss = seconds, hh = hundredths
// Timer status - 13 bits
//   Bit  Meaning
//   0    ALMA  - Set on valid compare of Alarm A with Clock A
//   1    DTZA  - Set on overflow of clock A (or decrement of 10's complement)
//   2    ALMB  - Set on valid compare of Alarm B with Clock B
//   3    DTZB  - Set on overflow of Clock B
//   4    DTZIT - Set by terminal count state of Interval Timer (it has counted a whole interval)
//   5    PUS   - Power Up Status - set when power first applied or falls below a certain minimum
//   6    CKAEN - Enable Clock A incrementers
//   7    CKBEN - Enable Clock B incrementers
//   8    ALAEN - Enables comparator logic between Alarm A and Clock A - Set if Alarm A is enabled.  Since time alarms are usually enabled, this flag is usually set
//   9    ALBEN - Enables comparator logic between Alarm B and Clock B - Set if Alarm B is enabled.  Always clear since stopwatch alarms are not possible.  Timer alarms occur as a result of bit 3 set.
//  10    ITEN  - Enables Interval Timer incrementing and comparator logic (interval timer is running)
//  11    TESTA - Enables Test A mode
//  12    TESTB - Enables Test B mode
//
// This code does not do any accuracy factor corrections

import Foundation

enum TimerType : Int {
	case timerB = 0
	case timerA = 1
}

struct TimerRegisters {
	var CLK: [Digits14] = [Digits14(), Digits14()]
	var ALM: [Digits14] = [Digits14(), Digits14()]
	var SCR: [Digits14] = [Digits14(), Digits14()]
	var INT: [Digits14] = [Digits14(), Digits14()]
	var ACC_F: Digits14 = Digits14()
	var TMR_S: Digits14 = Digits14()
}

class Timer : Peripheral {
	private static var __once: () = {  Static.sharedInstance = Timer() }()
	var timerSelected: TimerType = .timerA
	var clock: [UInt64] = [0, 0]
	var alarm: [UInt64] = [0, 0]
	var intTimer: UInt64 = 0
	var intTimerEnd: UInt64 = 0
	var aBus: Bus?
	
	var registers: TimerRegisters = TimerRegisters()
	
	struct Static {
		static var token : Int = 0
		static var sharedInstance : Timer?
	}
	
	static let sharedInstance = Timer()
	
	init() {
		assert(Static.sharedInstance == nil, "Singleton already initialized!")

		bus.installPeripheral(self, inSlot: 0xFB)
		bus.timer = self
		
		resetTimer()

		SYNCHRONYZE =  UserDefaults.standard.bool(forKey: "synchronyzeTime")

		if SYNCHRONYZE {
			synchronyzeWithComputer()
		}
	}
	
	func synchronyzeWithComputer()
	{
		// This should help me detect when I'm being activated. I want to reset the clock
		if (Int(self.registers.TMR_S[1]) & 0x04) != 0 {		// bit 6 - Clock A enabled
			self.setToCurrentTime()
		}
	}
	
	func resetTimer() {
		timerSelected = .timerA
		registers.CLK[1] = Digits14()
		registers.CLK[0] = Digits14()
		registers.ALM[1] = Digits14()
		registers.ALM[0] = Digits14()
		registers.SCR[1] = Digits14()
		registers.SCR[0] = Digits14()
		registers.INT[1] = Digits14()
		registers.INT[0] = Digits14()
		registers.ACC_F = Digits14()
		registers.TMR_S = Digits14()
		
		// Clear internal simulation variable
		clock[TimerType.timerA.rawValue] = 0
		clock[TimerType.timerB.rawValue] = 0
		alarm[TimerType.timerA.rawValue] = 0
		alarm[TimerType.timerB.rawValue] = 0
		intTimer = 0
		intTimerEnd = 0
		
		// Set to initial timer module value
		registers.TMR_S[1] &= 0x04
		convertToReg14(9999999999000, dst: &registers.ALM[0])		 // anti-corruption constant
		setToCurrentTime()
	}
	
	// Converts UINT64 to Reg14 (BCD)
	func convertToReg14(_ source: UInt64, dst: inout Digits14) {
		var src = source
		for idx in 0...13 {
			dst[idx] = (Digit)(src % 10)
			src /= 10
		}
	}
	
	// Converts Reg14 (BCD) to UINT64
	func convertToUint64(_ dest: inout UInt64, withRegister reg: Digits14) {
		var temp: UInt64 = 0
		for idx in Array((0...13).reversed()) {
			temp *= 10
			temp += UInt64(reg[idx]) % 10
		}
		
		dest = temp
	}
	
	func setToCurrentTime() {
		let daylightSavingTimeOffset: Int = TimeZone.current.isDaylightSavingTime() ? 3600 : 0
		var dateComponents: DateComponents = DateComponents()
		dateComponents.day = 1
		dateComponents.month = 1
		dateComponents.year = 1900
		let referenceDate: Date = Calendar.current.date(from: dateComponents)!
		let interval: TimeInterval = -1 * referenceDate.timeIntervalSinceNow + TimeInterval(daylightSavingTimeOffset)
		clock[TimerType.timerA.rawValue] = UInt64(interval) * 100
	}
	
	// MARK: Peripheral Delegate Methods
	func pluggedIntoBus(_ theBus: Bus?) {
		self.aBus = theBus
	}
	
	func readFromRegister(_ param: Bits4) {
		switch param {
		case 0x0:		// RTIME
			convertToReg14(
				clock[timerSelected.rawValue],
				dst: &registers.CLK[timerSelected.rawValue]
			)
			cpu.reg.C = registers.CLK[timerSelected.rawValue]
		case 0x1:		// RTIMEST
			convertToReg14(
				clock[timerSelected.rawValue],
				dst: &registers.CLK[timerSelected.rawValue]
			)
			cpu.reg.C = registers.CLK[timerSelected.rawValue]
		case 0x2:		// RALM
			cpu.reg.C = registers.ALM[timerSelected.rawValue]
		case 0x3:		// RSTS
			if timerSelected.rawValue != 0 {
				cpu.reg.C = registers.TMR_S
			} else {
				cpu.reg.C = Digits14()
				for idx in 0..<4 {
					cpu.reg.C[idx+1] = registers.ACC_F[idx]
				}
			}
		case 0x4:		// RSCR
			cpu.reg.C = registers.SCR[timerSelected.rawValue]
		case 0x5:		// RINT
			cpu.reg.C = Digits14()
			for idx in 0..<5 {
				cpu.reg.C[idx + 1] = registers.INT[0][idx]
			}
		default:
			break
		}
	}
	
	func writeDataFrom(_ data: Digits14) {
		//TODO: Implement this method
	}
	
	func writeToRegister(_ register: Bits4) {
		switch register {
		case 0x0:
			// WTIME
			registers.CLK[timerSelected.rawValue] = cpu.reg.C
			convertToUint64(
				&clock[timerSelected.rawValue],
				withRegister:registers.CLK[timerSelected.rawValue]
			)
		case 0x1:
			// WTIME-
			registers.CLK[timerSelected.rawValue] = cpu.reg.C
			convertToUint64(
				&clock[timerSelected.rawValue],
				withRegister:registers.CLK[timerSelected.rawValue]
			)
		case 0x2:
			// WALM
			registers.ALM[timerSelected.rawValue] = cpu.reg.C
			convertToUint64(
				&alarm[timerSelected.rawValue],
				withRegister:registers.ALM[timerSelected.rawValue]
			)
		case 0x3:
			// WSTS
			if timerSelected == .timerA {
				registers.TMR_S[0] &= cpu.reg.C[0]
				registers.TMR_S[1] &= (0x0C | (cpu.reg.C[1] & 0x03))
				if registers.TMR_S[0] == 0 || (registers.TMR_S[1] & 0x03) == 0 {
					// clearing flag 12,13 is in wrong place because SHIFT ON does not work.
					cpu.reg.FI &= 0xcfff
				}
			} else {
				registers.ACC_F[3] = cpu.reg.C[4] & 0x1
				registers.ACC_F[2] = cpu.reg.C[3]
				registers.ACC_F[1] = cpu.reg.C[2]
				registers.ACC_F[0] = cpu.reg.C[1]
			}
		case 0x4:
			// WSCR
			registers.SCR[timerSelected.rawValue] = cpu.reg.C
		case 0x5:
			// WINTST - set and start interval time
			registers.INT[0] = cpu.reg.C
			convertToUint64(
				&intTimerEnd,
				withRegister:registers.INT[0]
			)
			intTimer = 0
			registers.TMR_S[2] |= 0x04			// set bit 10- ITEN - Interval Timer Enable
		case 0x7:
			// STPINT - stop interval timer
			registers.TMR_S[2] &= 0x0B			// clear bit 10
		case 0x8:
			// WKUPOFF - clear test mode
			if timerSelected == .timerA {
				registers.TMR_S[2] &= 0x07		// clear bit 11 - Test A mode
			} else {
				registers.TMR_S[3] &= 0x0E		// clear bit 12 - Test B mode
			}
		case 0x9:
			// WKUPON - set test mode
			if timerSelected == .timerA {
				registers.TMR_S[2] |= 0x08		// set bit 11
			} else {
				registers.TMR_S[3] |= 0x01		// set bit 12
			}
		case 0xA:
			// ALMOFF
			if timerSelected == .timerA {
				registers.TMR_S[2] &= 0x0E		// clear bit 8
			} else {
				registers.TMR_S[2] &= 0x0D		// clear bit 9
			}
		case 0xB:
			// ALMON
			if timerSelected == .timerA {
				registers.TMR_S[2] |= 0x01		// set bit 8
			} else {
				registers.TMR_S[2] |= 0x02		// set bit 9
			}
		case 0xC:
			// STOPC
			if timerSelected == .timerA {		// should never stop Clock A or time will get messed up!
				registers.TMR_S[1] &= 0x0B		// clear bit 6 - Clock A incrementer
			} else {
				registers.TMR_S[1] &= 0x07		// clear bit 7 - Clock B incrementer
			}
		case 0xD:
			// STARTC
			if timerSelected == .timerA {
				registers.TMR_S[1] |= 0x04		// set bit 6
			} else {
				registers.TMR_S[1] |= 0x08		// set bit 7
			}
		case 0xE:
			// TIMER=B
			timerSelected = .timerB
		case 0xF:
			// TIMER=A
			timerSelected = .timerA
		default:
			break
		}
	}
	
	func timeSlice(_ timer: Foundation.Timer) {
		var fAlert: Int
		if (registers.TMR_S[1] & 0x04) != 0 {		// bit 6 - Clock A enabled
			clock[TimerType.timerA.rawValue] += 1
			if clock[TimerType.timerA.rawValue] > 99999999999999 || clock[TimerType.timerA.rawValue]  == 0 {
				clock[TimerType.timerA.rawValue] = 0
				registers.TMR_S[0] |= 0x02			// set bit 1 - overflow in clock A
				cpu.reg.FI |= 0x2000				// set flag 13 - general service request flag
				cpu.reg.FI |= 0x1000				// set flag 12 - timer request
				cpu.setPowerMode(.powerOn)
			}
			if ((UInt64(registers.TMR_S[2]) & 0x01) != 0 && (clock[TimerType.timerA.rawValue] == UInt64(alarm[TimerType.timerA.rawValue]))) {
				// if bit 8 set - enable ClockA & AlarmA comparator
				registers.TMR_S[0] |= 0x01			// set bit 0 - valid compare
				cpu.reg.FI |= 0x2000				// set flag 13 - general service request flag
				cpu.reg.FI |= 0x1000				// set flag 12 - timer request
				cpu.setPowerMode(.powerOn)
				fAlert = 1
			}
		}
		if (registers.TMR_S[1] & 0x08) != 0 {		// bit 7 - Clock B enabled
			clock[TimerType.timerB.rawValue] += 1
			if clock[TimerType.timerB.rawValue] > 99999999999999 || clock[TimerType.timerB.rawValue]  == 0 {
				clock[TimerType.timerB.rawValue] = 0
				registers.TMR_S[0] |= 0x08			// set bit 3 - overflow in clock B
				cpu.reg.FI |= 0x2000				// set flag 13 - general service request flag
				cpu.reg.FI |= 0x1000				// set flag 12 - timer request
				cpu.setPowerMode(.powerOn)
			}
			if ((UInt64(registers.TMR_S[2]) & 0x02) != 0 && (clock[TimerType.timerB.rawValue] == UInt64(alarm[TimerType.timerB.rawValue]))) {
				// if bit 9 set - enable ClockB & AlarmB comparator
				registers.TMR_S[0] |= 0x04			// set bit 2 - valid compare
				cpu.reg.FI |= 0x2000				// set flag 13 - general service request flag
				cpu.reg.FI |= 0x1000				// set flag 12 - timer request
				cpu.setPowerMode(.powerOn)
				fAlert = 1
			}
		}
		
		// Interval Timer
		if (registers.TMR_S[2] & 0x04) != 0 {
			// bit 10 - interval timer enabled
			intTimer += 1
			if (intTimer == intTimerEnd) {
				intTimer = 0						// reset interval timer to zero
				registers.TMR_S[1] |= 0x01			// set bit 4 - DTZIT - Decrement Through Zero Interval timer
				cpu.reg.FI |= 0x2000				// set flag 13 - general service request flag
				cpu.reg.FI |= 0x1000				// set flag 12 - timer request
				cpu.setPowerMode(.powerOn)
			}
		}
		
		// alert for an alarm
//		if fAlert != 0 {
//			// I'll make the dock icon bounce
//			NSApp.requestUserAttention(NSInformationalRequest)
//		}
	}
}

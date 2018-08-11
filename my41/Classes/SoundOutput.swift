//
//  SoundOutput.swift
//  my41
//
//  Created by Miroslav Perovic on 8/11/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation

enum SoundCmds: Int, Codable {
	case nullCmd                       = 0
	case quietCmd                      = 3
	case flushCmd                      = 4
	case reInitCmd                     = 5
	case waitCmd                       = 10
	case pauseCmd                      = 11
	case resumeCmd                     = 12
	case callBackCmd                   = 13
	case syncCmd                       = 14
	case availableCmd                  = 24
	case versionCmd                    = 25
	case volumeCmd                     = 46		/*sound manager 3.0 or later only*/
	case getVolumeCmd                  = 47		/*sound manager 3.0 or later only*/
	case clockComponentCmd             = 50		/*sound manager 3.2.1 or later only*/
	case getClockComponentCmd          = 51		/*sound manager 3.2.1 or later only*/
	case scheduledSoundCmd             = 52		/*sound manager 3.3 or later only*/
	case linkSoundComponentsCmd        = 53		/*sound manager 3.3 or later only*/
	case soundCmd                      = 80
	case bufferCmd                     = 81
	case rateMultiplierCmd             = 86
	case getRateMultiplierCmd          = 87
}

// Sample rate is equal to the CPU word execution rate.
let SAMPLE_RATE			= (1.0 / 155e-6)

// SOUND_LATENCY is the delay between the CPU producing sound
// samples and sending those samples to the Sound Manager, to
// smooth out fluctuations in instruction execution rate by
// the emulator.
let SOUND_LATENCY		= 0.1

// TOTAL_BUFFERS is the total number of sound buffers to allocate.
// LATENCY_BUFFERS is the number of buffers that will be filled during
// the latency period.
// SILENCE_BUFFERS is the number of buffers after which sound sample
// processing will be stopped if there is no sound activity.
let TOTAL_BUFFERS		= 4 // 8
let LATENCY_BUFFERS		= 2
let SILENCE_BUFFERS		= 2

// Amplitute of the generated square wave
let AMPLITUDE			= 10

//--------------------------------------------------------------------------------

// Fixed point representation of the sample rate.
let SAMPLE_RATE_FIXED: UInt64		= UInt64(44100.0 * SAMPLE_RATE)

// We will wait until at least LATENCY_BUFFERS buffers of sound are filled before
// starting to send them to the sound channel. The buffer size is
// calculated so that LATENCY_BUFFERS buffers equals the specified latency.
let SAMPLES_PER_BUFFER: Int		= Int(Double(SOUND_LATENCY) * Double(SAMPLE_RATE) / Double(LATENCY_BUFFERS))

// Sample values for high and low levels of the square wave
let LOW_SAMPLE: UInt8				= UInt8(0x80 - AMPLITUDE)
let HIGH_SAMPLE: UInt8				= UInt8(0x80 + AMPLITUDE)

var gDroppedSampleCount: Int = 0

enum SoundMode {
	case none, speaker, wawe
}

final class SoundOutput: Codable {
	typealias SoundSample = UInt8

	struct SndCommand: Codable {
		var cmd: SoundCmds			= .nullCmd
		var param1: Int16			= 0
		var param2: SoundHeader?	= nil
	}
	
	struct SndChannel: Codable {
//		var nextChan:  SndChannel<T>
		var firstMod 					= [String]()	/* reserved for the Sound Manager */
//			SndCallBackUPP      callBack
		var userInfo: Int32				= 0
		var wait: Int32					= 0				/* The following is for internal Sound Manager use only.*/
		var cmdInProgress				= SndCommand()
		var flags: Int16				= 0
		var qLength: Int16				= 0
		var qHead: Int16				= 0
		var qTail: Int16				= 0
		var queue						= [SndCommand]()
	}
	
	struct SoundHeader: Codable {
		var samplePtr: [SoundSample]?	= nil				/*if NIL then samples are in sampleArea*/
		var length: Int					= 0					/*length of sound in bytes*/
		var sampleRate: UInt64			= 0					/*sample rate for this sound*/
		var loopStart: UInt64			= 0					/*start of looping portion*/
		var loopEnd: UInt64				= 0					/*end of looping portion*/
		var encode: UInt8				= 0					/*header encoding*/
		var baseFrequency: UInt8		= 0					/*baseFrequency value*/
		var sampleArea: UInt8			= 0					/*space for when samples follow directly*/
	}
	
	struct SoundBuffer: Codable {
	//	var next: SoundBuffer? = nil
		var inUse: Bool = false
		var header: SoundHeader = SoundHeader()
		var samples: [SoundSample] = [SoundSample](repeating: 0, count: SAMPLES_PER_BUFFER)
	}

	var soundMode = SoundMode.none

	var gSndChannel: SndChannel?
	var gBuffers = [SoundBuffer]()
	var gBufferSendPtr: Int = 0
	var gBufferAllocPtr: Int = 0
	var gNumPendingBuffers: Int = 0
	var gCurrentBuffer: SoundBuffer?
	var gBufferingSound: Bool = false
	var gConstantSampleCount: Int = 0
	var gLastSample = SoundSample(LOW_SAMPLE)

	enum CodingKeys: String, CodingKey {
		case gSndChannel
		case gBuffers
		case gBufferSendPtr
		case gBufferAllocPtr
		case gNumPendingBuffers
		case gCurrentBuffer
		case gBufferingSound
		case gConstantSampleCount
		case gLastSample
	}

	init() {
//		var idx: Int
//		for idx = 0; idx < TOTAL_BUFFERS; idx++ {
		for _ in 0..<TOTAL_BUFFERS {
			gBuffers.append(SoundBuffer())
		}
	}

	required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		gSndChannel = try values.decode(SndChannel.self, forKey: .gSndChannel)
		gBuffers = try values.decode([SoundBuffer].self, forKey: .gBuffers)
		gBufferSendPtr = try values.decode(Int.self, forKey: .gBufferSendPtr)
		gBufferAllocPtr = try values.decode(Int.self, forKey: .gBufferAllocPtr)
		gNumPendingBuffers = try values.decode(Int.self, forKey: .gNumPendingBuffers)
		gCurrentBuffer = try values.decode(SoundBuffer.self, forKey: .gCurrentBuffer)
		gBufferingSound = try values.decode(Bool.self, forKey: .gBufferingSound)
		gConstantSampleCount = try values.decode(Int.self, forKey: .gConstantSampleCount)
		gLastSample = try values.decode(SoundSample.self, forKey: .gLastSample)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(gSndChannel, forKey: .gSndChannel)
		try container.encode(gBuffers, forKey: .gBuffers)
		try container.encode(gBufferSendPtr, forKey: .gBufferSendPtr)
		try container.encode(gBufferAllocPtr, forKey: .gBufferAllocPtr)
		try container.encode(gNumPendingBuffers, forKey: .gNumPendingBuffers)
		try container.encode(gCurrentBuffer, forKey: .gCurrentBuffer)
		try container.encode(gBufferingSound, forKey: .gBufferingSound)
		try container.encode(gConstantSampleCount, forKey: .gConstantSampleCount)
		try container.encode(gLastSample, forKey: .gLastSample)
	}

	func soundAvailableBufferSpace() -> Int {
		var p = gBufferAllocPtr
		var numFreeBuffers: Int = 0
		while numFreeBuffers < TOTAL_BUFFERS && !gBuffers[p].inUse {
			numFreeBuffers += 1
			incBufferPtr(&p)
		}
		
		return numFreeBuffers * SAMPLES_PER_BUFFER
	}
	
	func incBufferPtr(_ ptr: inout Int) {
		if ptr == TOTAL_BUFFERS {
			ptr = 0
		}
	}
	
	func anyBuffersInUse() -> Bool {
//		var idx: Int
//		for idx = 0; idx < TOTAL_BUFFERS; idx++ {
		for idx in 0..<TOTAL_BUFFERS {
			if gBuffers[idx].inUse {
				return true
			}
		}
		
		return false
	}
	
	func soundTimeslice() {
		if !gBufferingSound && gSndChannel != nil && !anyBuffersInUse() {
			shutDownSoundChannel()
		}
	}
	
	func shutDownSoundChannel() {
		gSndChannel = nil
	}
	
	func flushAndSuspendSoundOutput() {
		finishBuffer()
		sendPendingBuffers()
		gBufferingSound = false
	}
	
	func finishBuffer() {
		if gCurrentBuffer != nil {
//			println("Finished filling buffer \(gCurrentBuffer - gBuffers)")
			gNumPendingBuffers += 1
			gCurrentBuffer = nil
		}
	}
	
	func sendPendingBuffers() {
		while gNumPendingBuffers != 0  {
			startUpSoundChannel()
			if TRACE != 0 {
				print("Sending buffer \(gBufferSendPtr)")
			}
			let buf: SoundBuffer = gBuffers[gBufferSendPtr]
			var cmd = SndCommand()
			cmd.cmd = .bufferCmd
			cmd.param1 = 0
			cmd.param2 = buf.header
//			SndDoCommand(gSndChannel, &cmd, YES)
			cmd.cmd = .callBackCmd
			cmd.param1 = Int16(gBufferSendPtr)
			cmd.param2 = nil
//			SndDoCommand(gSndChannel, &cmd, YES)
			
			incBufferPtr(&gBufferSendPtr)
			gNumPendingBuffers -= 1
		}
	}
	
	func startUpSoundChannel() {
		if gSndChannel != nil {
			if TRACE != 0 {
				print("Allocating sound channel\n")
			}
//			SndNewChannel(&gSndChannel, sampledSynth, 0, (SndCallBackUPP)SoundCallback)
		}
	}
	
	func getBuffer() -> SoundBuffer? {
		var buf = gCurrentBuffer
		if buf == nil {
			buf = gBuffers[gBufferAllocPtr]
			if buf?.inUse == true {
				if gDroppedSampleCount == 0 {
					if TRACE != 0 {
						print("Buffer \(gBufferAllocPtr) is in use\n")
					}
				}
				gDroppedSampleCount += 1
				return nil
			}
			if gDroppedSampleCount != 0 {
				if TRACE != 0 {
					print("Buffer \(gBufferAllocPtr) is free after \(gDroppedSampleCount) dropped samples\n")
				}
				gDroppedSampleCount = 0
			}
			if TRACE != 0 {
				print("Starting to fill buffer \(gBufferAllocPtr)\n")
			}
			initBuffer(&buf!)
			buf?.inUse = true
			incBufferPtr(&gBufferAllocPtr)
			gCurrentBuffer = buf
		}
		
		return buf!
	}
	
	func soundOutputForWordTime(_ state: Int) {
		let sample = state != 0 ? HIGH_SAMPLE : LOW_SAMPLE
		if !gBufferingSound {
			if sample == gLastSample {
				return
			}
			if TRACE != 0 {
				print("Starting to buffer sound\n")
			}
			gBufferingSound = true
		}
		
		if let aBuf = getBuffer() {
			var buf: SoundBuffer = aBuf
			buf.samples[buf.header.length] = sample
			buf.header.length += 1
		}
	}
	
	func initBuffer(_ buf: inout SoundBuffer) {
		buf.header.sampleRate = SAMPLE_RATE_FIXED
		buf.header.samplePtr = buf.samples
		buf.header.length = 0
	}
}

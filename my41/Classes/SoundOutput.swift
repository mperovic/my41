//
//  SoundOutput.swift
//  my41
//
//  Created by Miroslav Perovic on 8/11/14.
//  Copyright (c) 2014 iPera. All rights reserved.
//

import Foundation
import Carbon

enum SoundCmds: Int {
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
let SAMPLE_RATE_FIXED: ULONG		= ULONG(65536.0 * SAMPLE_RATE)

// We will wait until at least LATENCY_BUFFERS buffers of sound are filled before
// starting to send them to the sound channel. The buffer size is
// calculated so that LATENCY_BUFFERS buffers equals the specified latency.
let SAMPLES_PER_BUFFER: Int		= Int(Double(SOUND_LATENCY) * Double(SAMPLE_RATE) / Double(LATENCY_BUFFERS))

// Sample values for high and low levels of the square wave
let LOW_SAMPLE: UInt8				= (0x80 - AMPLITUDE)
let HIGH_SAMPLE: UInt8				= (0x80 + AMPLITUDE)

var gDroppedSampleCount: Int = 0

class SoundOutput {
	typealias SoundSample = UInt8
	
	struct SndCommand {
		var cmd: SoundCmds			= .nullCmd
		var param1: Int16			= 0
		var param2: SoundHeader?	= nil
	}
	
	struct SndChannel {
//		var nextChan:  SndChannel<T>
		var firstMod: [String]				/* reserved for the Sound Manager */
//			SndCallBackUPP      callBack
		var userInfo: Int32
		var wait: Int32						/* The following is for internal Sound Manager use only.*/
		var cmdInProgress: SndCommand
		var flags: Int16
		var qLength: Int16
		var qHead: Int16
		var qTail: Int16
		var queue: [SndCommand]?
	}
	
	struct SoundHeader {
		var samplePtr: [SoundSample]? = nil				/*if NIL then samples are in sampleArea*/
		var length: Int = 0								/*length of sound in bytes*/
		var sampleRate: ULONG = 0						/*sample rate for this sound*/
		var loopStart: ULONG = 0						/*start of looping portion*/
		var loopEnd: ULONG = 0							/*end of looping portion*/
		var encode: UInt8 = 0							/*header encoding*/
		var baseFrequency: UInt8 = 0					/*baseFrequency value*/
		var sampleArea: UInt8 = 0						/*space for when samples follow directly*/
	}
	
	struct SoundBuffer {
	//	var next: SoundBuffer? = nil
		var inUse: Bool = false
		var header: SoundHeader = SoundHeader()
		var samples: [SoundSample] = [SoundSample](count: SAMPLES_PER_BUFFER, repeatedValue: 0)
	}
	
	var gSndChannel: SndChannel?
	var gBuffers: [SoundBuffer] = [SoundBuffer]()
	var gBufferSendPtr: Int = 0
	var gBufferAllocPtr: Int = 0
	var gNumPendingBuffers: Int = 0
	var gCurrentBuffer: SoundBuffer?
	var gBufferingSound: Bool = false
	var gConstantSampleCount: Int = 0
	var gLastSample: SoundSample = SoundSample(LOW_SAMPLE)

	init() {
		var idx: Int
		for idx = 0; idx < TOTAL_BUFFERS; idx++ {
			gBuffers.append(SoundBuffer())
		}
	}

	func soundAvailableBufferSpace() -> Int {
		var p = gBufferAllocPtr
		var numFreeBuffers: Int = 0
		while numFreeBuffers < TOTAL_BUFFERS && !gBuffers[p].inUse {
			++numFreeBuffers
			incBufferPtr(&p)
		}
		
		return Int(numFreeBuffers * Int(SAMPLES_PER_BUFFER))
	}
	
	func incBufferPtr(inout ptr: Int) {
		if ptr == TOTAL_BUFFERS {
			ptr = 0
		}
	}
	
	func anyBuffersInUse() -> Bool {
		var idx: Int
		for idx = 0; idx < TOTAL_BUFFERS; idx++ {
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
			++gNumPendingBuffers
			gCurrentBuffer = nil
		}
	}
	
	func sendPendingBuffers() {
		while gNumPendingBuffers != 0  {
			startUpSoundChannel()
			println("Sending buffer \(gBufferSendPtr)")
			var buf: SoundBuffer = gBuffers[gBufferSendPtr]
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
			--gNumPendingBuffers
		}
	}
	
	func startUpSoundChannel() {
		if gSndChannel != nil {
			println("Allocating sound channel\n")
//			SndNewChannel(&gSndChannel, sampledSynth, 0, (SndCallBackUPP)SoundCallback)
		}
	}
	
	func getBuffer() -> SoundBuffer? {
		var buf = gCurrentBuffer
		if buf == nil {
			buf = gBuffers[gBufferAllocPtr]
			if buf?.inUse == true {
				if gDroppedSampleCount == 0 {
					println("Buffer \(gBufferAllocPtr) is in use\n")
				}
				++gDroppedSampleCount
				return nil
			}
			if gDroppedSampleCount != 0 {
				println("Buffer \(gBufferAllocPtr) is free after \(gDroppedSampleCount) dropped samples\n")
				gDroppedSampleCount = 0
			}
			println("Starting to fill buffer \(gBufferAllocPtr)\n")
			initBuffer(&buf!)
			buf?.inUse = true
			incBufferPtr(&gBufferAllocPtr)
			gCurrentBuffer = buf
		}
		
		return buf!
	}
	
	func soundOutputForWordTime(state: Int) {
		var sample = state != 0 ? HIGH_SAMPLE : LOW_SAMPLE
		if !gBufferingSound {
			if sample == gLastSample {
				return
			}
			println("Starting to buffer sound\n")
			gBufferingSound = true
		}
		
		if let aBuf = getBuffer() {
			var buf: SoundBuffer = aBuf
			buf.samples[buf.header.length++] = sample
		}
	}
	
	func initBuffer(inout buf: SoundBuffer) {
		buf.header.sampleRate = SAMPLE_RATE_FIXED
		buf.header.samplePtr = buf.samples
		buf.header.length = 0
	}
}

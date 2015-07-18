//
//  MIDIDriver.h
//  Obie
//
//  Created by groumpf on Sat Apr 03 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/MIDIServices.h>

#define PATCH_TAB_SIZE 134
// 134 parametres en nibbles + checksum + sysex
#define PATCH_SYSEX_SIZE  (2*PATCH_TAB_SIZE+1+6)

#define MASTER_DATA_SIZE 172
#define MASTER_DATA_SYSEX_SIZE (2*MASTER_DATA_SIZE+1+6)


@interface MIDIDriver : NSObject 
{
	MIDIClientRef mMIDIclient;
	MIDIPortRef 	mInPort;
	MIDIPortRef		mOutPort;
	MIDIEndpointRef	mDest;
	MIDIEndpointRef mSource;
	int mInputPortNumber;
	int mOutputPortNumber;
}

// singleton
+ (MIDIDriver *)sharedInstance;

- (void)setMIDIInput:(int)aInputPort Output:(int)aOutputPort;
- (NSArray *)midiInputs;
- (NSArray *)midiOutputs;
-(int)inputPortNumber;
-(int)outputPortNumber;


// envoi d'un parameter seul
- (void)sendParameter: (int)aParameter value:(int) aValue;

// Remote matrix  parameter edit
- (void)sendMatrixPath:(int)aPath Source:(int)aSource Value:(int) aValue Dest:(int)aDest;

// demande des donnees au synthe
//	  aType 0 : all patches 
//	1 single patch, 
//	3 master parameters 
//	4 edit buffer
// 	aNumber 0 si type = 0 ou 3
//
- (void)sendRequestDataType:(int)aType Number:(int)aNumber;

// envoi le patch dans le buffer d'edition
- (void)sendPatch:(uint8_t*)aPatch;

// aType : 0x0D pour le buffer d'edition
//         1 pour stocker le patch a l'emplacement designe par aNumber 
//           dans la banque courante
-(void)sendPatch:(uint8_t*)aPatch Type:(int)aType Number:(int)aNumber;

// sauvegarde le patch en memoire interne (banque 0 et 1)
- (void)storePatch:(uint8_t*)aPatch Bank:(int)aBankNumber Number:(int)aPatchNumber;

// positionne la banque courante
- (void)setBank:(int)aBankNumber;

// envoi des parametres globaux
-(void)sendMasterData:(uint8_t*)aData;

//
// recupere les donnees recues apres un appel a sendRequestDataType
- (int)getReceivedBytes:(uint8_t *)aPatch maxSize:(int)aMaxSize;

@end

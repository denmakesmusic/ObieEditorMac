//
//  MIDIDriver.m
//  Matrix 1000 MIDI driver
//
//  Created by groumpf on Sat Apr 03 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "MIDIDriver.h"

// taille du buffer de reception 
#define RECEIVE_BUFFER_SIZE 1024

#define SOX (Byte)0xF0
#define IDC (Byte)0x10
#define IDE (Byte)0x06
#define EOX	(Byte)0xF7


static Byte *mReceivePointer = NULL;
static int mReceiveCount = 0;
static Byte mReceiveBuffer[RECEIVE_BUFFER_SIZE];


static void SysexCompleteProc(MIDISysexSendRequest *  request)
{
	//printf("SysexCompleteProc\n");
	free(request);
}

static void MyReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon)
{
	if (mReceivePointer == NULL || mReceivePointer >= (mReceiveBuffer + RECEIVE_BUFFER_SIZE)) 
	{
		// depassement ?
		NSLog(@"Depassement buffer de reception\n");
		return;
	}
	MIDIPacket *packet = (MIDIPacket *)pktlist->packet;	
	
	//NSLog(@"MyReadProc numPackets = %d\n", pktlist->numPackets);
	int j;
	for (j = 0; j < pktlist->numPackets; ++j) 
	{
	//	NSLog(@"packet %d len = %d\n", j, packet->length);
// memcpy ne semble pas fonctionner...		
//		memcpy(packet->data, mReceivePointer, packet->length);
//		mReceivePointer += packet->length;
//		mReceiveCount += packet->length;
		int k;
		for (k = 0; k < packet->length; k++)
		{
			*mReceivePointer++ = packet->data[k];
			//printf("%02x, ", packet->data[k]);
			mReceiveCount++;
		}
	}
//	printf("\nreceive count = %d\n", mReceiveCount);
}


@implementation MIDIDriver

// single instance
static MIDIDriver *sharedInstance = NULL;

+ (MIDIDriver *)sharedInstance {
    return sharedInstance ? sharedInstance : [[self alloc] init];
}

- (id)init {
    if (sharedInstance) {   // We just have one instance of the MIDIDriver class, return that one instead
        [self release];
    } else if (self = [super init]) {
        sharedInstance = self;

//		NSLog(@"MIDIDriver init\n");
		// create client and ports
		OSStatus oStatus = MIDIClientCreate(CFSTR("Matrix 1000 editor"), NULL, NULL, &mMIDIclient);	
//		NSLog(@"MIDIClientCreate %d\n", oStatus);
		oStatus = MIDIInputPortCreate(mMIDIclient, CFSTR("Input port"), MyReadProc, NULL, &mInPort);
//		NSLog(@"MIDIInputPortCreate %d\n", oStatus);
		oStatus = MIDIOutputPortCreate(mMIDIclient, CFSTR("Output port"), &mOutPort);
//		NSLog(@"MIDIOutputPortCreate %d\n", oStatus);
    }
    return sharedInstance;
}

- (void)dealloc {
    if (self != sharedInstance) [super dealloc];	// Don't free the shared instance
}


- (void)setMIDIInput:(int)aInputPort Output:(int)aOutputPort
{		
//	NSLog(@"setMIDIInput = %d output = %d", aInputPort, aOutputPort);
	mSource = MIDIGetSource(aInputPort);
	OSStatus oStatus = MIDIPortConnectSource(mInPort, mSource, mSource);
//	NSLog(@"MIDIPortConnectSource %d\n", oStatus);
		
	mDest = MIDIGetDestination(aOutputPort);
	mInputPortNumber = aInputPort;
	mOutputPortNumber = aOutputPort;
}

-(int)inputPortNumber
{
	return mInputPortNumber;
}
-(int)outputPortNumber
{
	return mOutputPortNumber;
}

// Remote parameter edit
- (void)sendParameter: (int)aParameter value:(int) aValue
{
	Byte *oData = calloc(1, 7);	
	oData[0] = SOX;
	oData[1] = IDC;
	oData[2] = IDE;
	oData[3] = (Byte)0x06;
	oData[4] = (Byte)aParameter;
	oData[5] = (Byte)(aValue & 0x7F);
	oData[6] = EOX;
	
	MIDISysexSendRequest *request = calloc( 1, sizeof(MIDISysexSendRequest));	
	request->destination = mDest;
	request->data = oData;
	request->bytesToSend = 7;
	request->completionProc = &SysexCompleteProc;
	
	OSStatus oStatus = MIDISendSysex(request);
	//printf("sendParameter status = %d\n", oStatus);
}


// Remote matrix  parameter edit
- (void)sendMatrixPath:(int)aPath Source:(int)aSource Value:(int) aValue Dest:(int)aDest
{
	Byte *oData = calloc(1, 9);	
	oData[0] = SOX;
	oData[1] = IDC;
	oData[2] = IDE;
	oData[3] = (Byte)0x0B;
	oData[4] = (Byte)aPath;
	oData[5] = (Byte)aSource;	
	oData[6] = (Byte)(aValue & 0x7F);
	oData[7] = (Byte)aDest;
	oData[8] = EOX;
	
	MIDISysexSendRequest *request = calloc( 1, sizeof(MIDISysexSendRequest));	
	request->destination = mDest;
	request->data = oData;
	request->bytesToSend = 9;
	request->completionProc = &SysexCompleteProc;
	
	OSStatus oStatus = MIDISendSysex(request);
	//printf("sendParameter status = %d\n", oStatus);
}

// aType 0,1, 3 ou 4
// aNumber 0 si type = 0 ou 3
- (void)sendRequestDataType:(int)aType Number:(int)aNumber
{
	Byte *oData = calloc(1, 7);	
	oData[0] = SOX;
	oData[1] = IDC;
	oData[2] = IDE;
	oData[3] = (Byte)0x04;
	oData[4] = (Byte)aType;
	oData[5] = (Byte)(aNumber & 0x7F);
	oData[6] = EOX;
	
	MIDISysexSendRequest *request = calloc( 1, sizeof(MIDISysexSendRequest));	
	request->destination = mDest;
	request->data = oData;
	request->bytesToSend = 7;
	request->completionProc = &SysexCompleteProc;
	
	// reinitialiser le pointeur au debut du buffer de reception
	mReceivePointer = mReceiveBuffer;
	mReceiveCount = 0;
	
	OSStatus oStatus = MIDISendSysex(request);
}

// envoi d'un patch dans le buffer d'edition
// aPatch contient un tableau des parametres (non nibbles)
- (void)sendPatch:(uint8_t*)aPatch
{
	[self sendPatch:aPatch Type:0x0D Number:0];
}

// aType : 0x0D pour le buffer d'edition
//         1 pour stocker le patch a l'emplacement designe par aNumber 
//           dans la banque courante
-(void)sendPatch:(uint8_t*)aPatch Type:(int)aType Number:(int)aNumber
{
	Byte *oData = calloc(1, PATCH_SYSEX_SIZE);	
	oData[0] = SOX;
	oData[1] = IDC;
	oData[2] = IDE;
	oData[3] = (Byte)aType;
	oData[4] = (Byte)aNumber;
	oData[PATCH_SYSEX_SIZE-1] = EOX;
	
	uint8_t *p = aPatch;
	int sum = 0;
	int i;
	for(i = 0; i < PATCH_TAB_SIZE; i++)
	{
		oData[5+2*i] = (Byte)(*p & 0x0F);
		oData[5+2*i+1] = (Byte)((*p >> 4) & 0x0F);
		sum += *p;
		p++; 
	}
	// checksum
	oData[PATCH_SYSEX_SIZE-2] = (Byte) (sum % 128);
	
	MIDISysexSendRequest *request = calloc( 1, sizeof(MIDISysexSendRequest));	
	request->destination = mDest;
	request->data = oData;
	request->bytesToSend = PATCH_SYSEX_SIZE;
	request->completionProc = &SysexCompleteProc;
	
	OSStatus oStatus = MIDISendSysex(request);
}

// envoi des parametres globaux
-(void)sendMasterData:(uint8_t*)aData
{
	Byte *oData = calloc(1, MASTER_DATA_SYSEX_SIZE);	
	oData[0] = SOX;
	oData[1] = IDC;
	oData[2] = IDE;
	oData[3] = (Byte)0x03;
	oData[4] = (Byte)0x03;
	oData[MASTER_DATA_SYSEX_SIZE-1] = EOX;
	
	uint8_t *p = aData;
	int sum = 0;
	int i;
	for(i = 0; i < MASTER_DATA_SIZE; i++)
	{
		oData[5+2*i] = (Byte)(*p & 0x0F);
		oData[5+2*i+1] = (Byte)((*p >> 4) & 0x0F);
		sum += *p;
		p++; 
	}
	// checksum
	oData[MASTER_DATA_SYSEX_SIZE-2] = (Byte) (sum % 128);
	
	MIDISysexSendRequest *request = calloc( 1, sizeof(MIDISysexSendRequest));	
	request->destination = mDest;
	request->data = oData;
	request->bytesToSend = MASTER_DATA_SYSEX_SIZE;
	request->completionProc = &SysexCompleteProc;
	
	OSStatus oStatus = MIDISendSysex(request);
}


// positionne la banque courante (0..9)
- (void)setBank:(int)aBankNumber
{
	Byte *oData = calloc(1, 6);	
	oData[0] = SOX;
	oData[1] = IDC;
	oData[2] = IDE;
	oData[3] = (Byte)0x0A;
	oData[4] = (Byte)aBankNumber;
	oData[5] = EOX;
	
	MIDISysexSendRequest *request = calloc( 1, sizeof(MIDISysexSendRequest));	
	request->destination = mDest;
	request->data = oData;
	request->bytesToSend = 6;
	request->completionProc = &SysexCompleteProc;
	
	OSStatus oStatus = MIDISendSysex(request);
}

// sauvegarde un patch
- (void)storePatch:(uint8_t*)aPatch Bank:(int)aBankNumber Number:(int)aPatchNumber
{
	[self setBank:aBankNumber];
	[self sendPatch:aPatch Type:1 Number:aPatchNumber];
}

// recuperer un patch recu
- (int)getReceivedBytes:(uint8_t *)aPatch maxSize:(int)aMaxSize
{
	int i = 0;
	uint8_t *p = aPatch;
	int count = 0;
	bool oSysexStart = FALSE;
	for (i = 0; i < mReceiveCount;)
	{
		int oByte = mReceiveBuffer[i];	
		//printf("%02x ", oByte);	
		if (oByte == EOX)
		{
			break;
		}
		else
		if (oSysexStart)
		{
			*p = (mReceiveBuffer[i] | (mReceiveBuffer[i+1] << 4)) & 0x7F;
			//printf("%d %02x / %02x = %02x \n ", count, mReceiveBuffer[i], mReceiveBuffer[i+1], *p);
			i += 2;
			count++;
			p++;
			if (count >= aMaxSize)
			{
				// fini, on oublie le checksum
				break;
			}
/*			if (count == 8)
			{
				*p = 0;
				printf("PatchName = %s\n", aPatch);
			}*/
		}
		else
		if (oByte == SOX)
		{
			oSysexStart = TRUE;
			// passer l'entete
			i += 5;
		}
		else
		{
			i++;
		}
	}
	//printf("\ncount = %d\n", count);
	return count;
}

- (NSArray *)midiInputs
{
	NSMutableArray *oList = [NSMutableArray array];

	ItemCount oSourcesNb = MIDIGetNumberOfSources();
	ItemCount i;
	for (i = 0; i < oSourcesNb; i++)
	{
		NSMutableString *oName = [[NSMutableString alloc] init];

		MIDIEndpointRef oIn = MIDIGetSource(i);
		MIDIEntityRef oEntity;
		OSStatus stat = MIDIEndpointGetEntity(oIn, &oEntity);
		if (stat == 0)
		{
			MIDIDeviceRef oDevice;
			stat = MIDIEntityGetDevice(oEntity, &oDevice);		
			if (stat == 0)
			{
				CFStringRef oDeviceName;
				MIDIObjectGetStringProperty(oDevice, kMIDIPropertyName, &oDeviceName);
				[oName appendString:(NSString *)oDeviceName];
				[oName appendString:@" - "];
				CFRelease(oDeviceName);
			}
		}
		CFStringRef oSourceString;
		MIDIObjectGetStringProperty(oIn, kMIDIPropertyName, &oSourceString);
		[oName appendString:(NSString *)oSourceString];
		CFRelease(oSourceString);
				
		[oList addObject:oName];
		[oName release];
	}
	return oList;	
}

- (NSArray *)midiOutputs
{
	NSMutableArray *oList = [NSMutableArray array];
		
	ItemCount oDestNb = MIDIGetNumberOfDestinations();
	ItemCount i;
	for (i = 0; i < oDestNb; i++)
	{
		NSMutableString *oName = [[NSMutableString alloc] init];

		MIDIEndpointRef oIn = MIDIGetDestination(i);
		MIDIEntityRef oEntity;
		OSStatus stat = MIDIEndpointGetEntity(oIn, &oEntity);
		if (stat == 0)
		{
			MIDIDeviceRef oDevice;
			stat = MIDIEntityGetDevice(oEntity, &oDevice);		
			if (stat == 0)
			{
				CFStringRef oDeviceName;
				MIDIObjectGetStringProperty(oDevice, kMIDIPropertyName, &oDeviceName);
				[oName appendString:(NSString *)oDeviceName];
				[oName appendFormat:@" - "];
				CFRelease(oDeviceName);
			}
		}
		CFStringRef oDestString;
		MIDIObjectGetStringProperty(oIn, kMIDIPropertyName, &oDestString);
		
		[oName appendString:(NSString *)oDestString];				
		CFRelease(oDestString);
				
		[oList addObject:oName];
		[oName release];
	}
	return oList;
}

@end
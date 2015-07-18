//
//  MyDocument.h
//  ObieEditor
//
//  Created by groumpf on Mon Apr 05 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "MIDIDriver.h"

// liste des indexes de parametres (offset dans la table)
enum
{
	MATRIX_INDEX_KEYBOARD_MODE = 8,
	MATRIX_INDEX_DCO1_FREQ,
	MATRIX_INDEX_DCO1_WAVESHAPE, // 10
	MATRIX_INDEX_DCO1_PULSEWIDTH,
	MATRIX_INDEX_DCO1_FIXEDMOD,
	MATRIX_INDEX_DCO1_WAVE,
	MATRIX_INDEX_DCO2_FREQ,
	MATRIX_INDEX_DCO2_WAVESHAPE,
	MATRIX_INDEX_DCO2_PULSEWIDTH,
	MATRIX_INDEX_DCO2_FIXEDMOD,
	MATRIX_INDEX_DCO2_WAVE,
	MATRIX_INDEX_DCO2_DETUNE,
	MATRIX_INDEX_MIX, //20
	MATRIX_INDEX_DCO1_FIXEDMOD2,
	MATRIX_INDEX_DCO1_CLIC,
	MATRIX_INDEX_DCO2_FIXEDMOD2,
	MATRIX_INDEX_DCO2_CLIC,
	MATRIX_INDEX_SYNCMODE,
	MATRIX_INDEX_FILTER_FREQ,
	MATRIX_INDEX_FILTER_RES,
	MATRIX_INDEX_FILTER_FIXEDMOD,
	MATRIX_INDEX_FILTER_KEYMOD,
	MATRIX_INDEX_FILTER_FM, // 30
	MATRIX_INDEX_VCA1_AMOUNT,
	MATRIX_INDEX_PORTAMENTO_RATE,
	MATRIX_INDEX_LAGMODE,
	MATRIX_INDEX_PORTAMENTO_ENABLE,
	MATRIX_INDEX_LFO1_SPEED,
	MATRIX_INDEX_LFO1_TRIGGER,
	MATRIX_INDEX_LFO1_LAG_ENABLE,
	MATRIX_INDEX_LFO1_WAVESHAPE,
	MATRIX_INDEX_LFO1_RETRIGGER_POINT,
	MATRIX_INDEX_LFO1_SAMPLED_SOURCE, // 40
	MATRIX_INDEX_LFO1_AMP,
	MATRIX_INDEX_LFO2_SPEED,
	MATRIX_INDEX_LFO2_TRIGGER,
	MATRIX_INDEX_LFO2_LAG_ENABLE,
	MATRIX_INDEX_LFO2_WAVESHAPE,
	MATRIX_INDEX_LFO2_RETRIGGER_POINT,
	MATRIX_INDEX_LFO2_SAMPLED_SOURCE,
	MATRIX_INDEX_LFO2_AMP,
	MATRIX_INDEX_ENV1_TRIGGER_MODE, 
	MATRIX_INDEX_ENV1_DELAY, // 50
	MATRIX_INDEX_ENV1_ATTACK,
	MATRIX_INDEX_ENV1_DECAY,
	MATRIX_INDEX_ENV1_SUSTAIN,
	MATRIX_INDEX_ENV1_RELEASE,
	MATRIX_INDEX_ENV1_AMP,
	MATRIX_INDEX_ENV1_LFO_TRIGGER_MODE,
	MATRIX_INDEX_ENV1_MODE,
	MATRIX_INDEX_ENV2_TRIGGER_MODE,
	MATRIX_INDEX_ENV2_DELAY,
	MATRIX_INDEX_ENV2_ATTACK, // 60
	MATRIX_INDEX_ENV2_DECAY,
	MATRIX_INDEX_ENV2_SUSTAIN,
	MATRIX_INDEX_ENV2_RELEASE,
	MATRIX_INDEX_ENV2_AMP,
	MATRIX_INDEX_ENV2_LFO_TRIGGER_MODE,
	MATRIX_INDEX_ENV2_MODE,
	MATRIX_INDEX_ENV3_TRIGGER_MODE,
	MATRIX_INDEX_ENV3_DELAY,
	MATRIX_INDEX_ENV3_ATTACK,
	MATRIX_INDEX_ENV3_DECAY, // 70
	MATRIX_INDEX_ENV3_SUSTAIN,
	MATRIX_INDEX_ENV3_RELEASE,
	MATRIX_INDEX_ENV3_AMP,
	MATRIX_INDEX_ENV3_LFO_TRIGGER_MODE,
	MATRIX_INDEX_ENV3_MODE,
	MATRIX_INDEX_TRACKGEN_INPUT_SOURCE,
	MATRIX_INDEX_TRACKGEN_POINT_1,
	MATRIX_INDEX_TRACKGEN_POINT_2,
	MATRIX_INDEX_TRACKGEN_POINT_3,
	MATRIX_INDEX_TRACKGEN_POINT_4, // 80
	MATRIX_INDEX_TRACKGEN_POINT_5,
	MATRIX_INDEX_RAMP1_RATE,
	MATRIX_INDEX_RAMP1_MODE,
	MATRIX_INDEX_RAMP2_RATE,
	MATRIX_INDEX_RAMP2_MODE,
	MATRIX_INDEX_LFO1_TO_DCO1_FREQ,
	MATRIX_INDEX_LFO2_TO_DCO1_PW,
	MATRIX_INDEX_LFO1_TO_DCO2_FREQ,
	MATRIX_INDEX_LFO2_TO_DCO2_PW,
	MATRIX_INDEX_ENV1_TO_VCF_FREQ, // 90
	MATRIX_INDEX_PRESS_TO_VCF_FREQ,
	MATRIX_INDEX_VELOCITY_TO_VCA1,
	MATRIX_INDEX_ENV2_TO_VCA2,
	MATRIX_INDEX_VELOCITY_TO_ENV1_AMP,
	MATRIX_INDEX_VELOCITY_TO_ENV2_AMP,
	MATRIX_INDEX_VELOCITY_TO_ENV3_AMP,
	MATRIX_INDEX_RAMP1_TO_LFO1_AMP,
	MATRIX_INDEX_RAMP2_TO_LFO2_AMP,
	MATRIX_INDEX_VELOCITY_TO_PORTAMENTO_RATE,
	MATRIX_INDEX_ENV3_TO_VCF_FM, // 100
	MATRIX_INDEX_PRESS_TO_VCF_FM,
	MATRIX_INDEX_PRESS_TO_LFO1_SPEED,
	MATRIX_INDEX_KEYBOARD_TO_LFO2_SPEED,
	MATRIX_INDEX_MATRIX_SOURCE_0,
	MATRIX_INDEX_MATRIX_AMOUNT_0,
	MATRIX_INDEX_MATRIX_DEST_0,
	MATRIX_INDEX_MATRIX_SOURCE_1,
	MATRIX_INDEX_MATRIX_AMOUNT_1,
	MATRIX_INDEX_MATRIX_DEST_1,
	MATRIX_INDEX_MATRIX_SOURCE_2, // 110
	MATRIX_INDEX_MATRIX_AMOUNT_2,
	MATRIX_INDEX_MATRIX_DEST_2,
	MATRIX_INDEX_MATRIX_SOURCE_3,
	MATRIX_INDEX_MATRIX_AMOUNT_3,
	MATRIX_INDEX_MATRIX_DEST_3,
	MATRIX_INDEX_MATRIX_SOURCE_4,
	MATRIX_INDEX_MATRIX_AMOUNT_4,
	MATRIX_INDEX_MATRIX_DEST_4,
	MATRIX_INDEX_MATRIX_SOURCE_5,
	MATRIX_INDEX_MATRIX_AMOUNT_5,
	MATRIX_INDEX_MATRIX_DEST_5,
	MATRIX_INDEX_MATRIX_SOURCE_6,
	MATRIX_INDEX_MATRIX_AMOUNT_6,
	MATRIX_INDEX_MATRIX_DEST_6,
	MATRIX_INDEX_MATRIX_SOURCE_7,
	MATRIX_INDEX_MATRIX_AMOUNT_7,
	MATRIX_INDEX_MATRIX_DEST_7,
	MATRIX_INDEX_MATRIX_SOURCE_8,
	MATRIX_INDEX_MATRIX_AMOUNT_8,
	MATRIX_INDEX_MATRIX_DEST_8,
	MATRIX_INDEX_MATRIX_SOURCE_9,
	MATRIX_INDEX_MATRIX_AMOUNT_9,
	MATRIX_INDEX_MATRIX_DEST_9,
};

// offset dans la table des parametres globaux
enum
{
	MATRIX_INDEX_GLOBAL_VIB_SPEED = 1,
	MATRIX_INDEX_GLOBAL_VIB_SPEED_MOD_SOURCE,
	MATRIX_INDEX_GLOBAL_VIB_SPEED_MOD_AMOUNT,
	MATRIX_INDEX_GLOBAL_VIB_WAVEFORM,
	MATRIX_INDEX_GLOBAL_VIB_AMP,
	MATRIX_INDEX_GLOBAL_VIB_AMP_MOD_SOURCE,
	MATRIX_INDEX_GLOBAL_VIB_AMP_MOD_AMOUNT,
	MATRIX_INDEX_GLOBAL_MASTER_TUNE,
	MATRIX_INDEX_GLOBAL_MIDI_CHANNEL = 11,
	MATRIX_INDEX_GLOBAL_MIDI_OMNI,
	MATRIX_INDEX_GLOBAL_MIDI_CONTROLLER_ENABLE,
	MATRIX_INDEX_GLOBAL_MIDI_PATCH_CHANGE_ENABLE,
	MATRIX_INDEX_GLOBAL_MIDI_PEDAL_1 = 17,
	MATRIX_INDEX_GLOBAL_MIDI_PEDAL_2,
	MATRIX_INDEX_GLOBAL_MIDI_LEVER_2,
	MATRIX_INDEX_GLOBAL_MIDI_LEVER_3,
	MATRIX_INDEX_GLOBAL_BEND_RANGE = 164
};


@interface MyDocument : NSDocument
{
	
	// table de tous les parametres (non nibble)
	uint8_t mParameters[PATCH_TAB_SIZE];
	
	// table des parametres globaux (non nibble)
	// je trouve ca pratique de les stocker en meme temps que le patch
	// pour le vibrato en particulier
	uint8_t mGlobalParameters[MASTER_DATA_SIZE];
	
	bool mValidGlobalParameters;
	
	// nom du patch
	IBOutlet NSTextField *mPatchName;		

}

- (IBAction)patchNameAction:(id)sender;

	// get Global parameters
- (IBAction)getGlobalParameters:(id)sender;

	// send global parameters
- (IBAction)sendGlobalParameters:(id)sender;


-(void)updateGlobalParameters;



+ (MyDocument *)documentForWindow:(NSWindow *)window ;
+ (NSString *)documentType;

- (void)setPatchName:(NSString *)aName;
- (NSString *)patchName;

//
// returns true if global parameters are initialized
- (bool)validGlobalparameters;

//
// retourne tous les parametres
//
- (uint8_t *)patch;

// retourne tous les parametres globaux
- (uint8_t *)globalParameters;

//
// prend la valeur venant du controle, la stocke dans le modele et l'envoie au synthe
// aValue valeur donnee par le controle (Slider ou autre)
// aIndex : l'index (voir constantes)
//
- (void)setParameter:(int)aValue At:(int)aIndex;

//
// positionne tous les parametres du modele 
//
- (void)setParameters:(uint8_t*)aPatch;

//
// retourne la valeur d'un parametre
//
- (int)getParameter:(int)aIndex;

// positionne les parametres globaux
- (void)setGlobalParameters:(uint8_t*)aData;

// positionne un parametre global
- (void)setGlobalParameter:(int)aValue At:(int)aIndex;

// retourne la valeur d'un parametre global
- (int)getGlobalParameter:(int)aIndex;

- (void)setObjectUI:(NSView*)aView dico:(id)aDico tag:(int)aTag;

@end
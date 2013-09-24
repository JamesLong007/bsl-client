//
//  Recorder.h
//  cube-ios
//
//  Created by apple2310 on 13-9-9.
//
//

#import <Foundation/Foundation.h>

@class AVAudioRecorder;
@class AVAudioPlayer;
@class Recorder;


@protocol RecorderDelegate <NSObject>

-(void)recordDidPlayFinish:(Recorder*)recorder;
-(void)recordDidPlayError:(Recorder*)recorder;
-(void)refreshAudioPower:(Recorder*)recorder level:(int)level;
@end

@interface Recorder : NSObject{
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer*  audioPlayer;
    int recordEncoding;
    
    NSTimer* recordTimer;

}

@property(nonatomic,assign) float addInterval;
@property(nonatomic,assign) id<RecorderDelegate> delegate;
@property(nonatomic,readonly) NSURL*  recordFile;


-(void)record;

-(void)stop;

-(void)play:(NSURL*)url;

-(void)removeRecord;

@end

//
//  Recorder.m
//  cube-ios
//
//  Created by apple2310 on 13-9-9.
//
//

#import "Recorder.h"

#import <AVFoundation/AVFoundation.h>
typedef enum{
    ENC_AAC = 1,
    ENC_ALAC = 2,
    ENC_IMA4 = 3,
    ENC_ILBC = 4,
    ENC_ULAW = 5,
    ENC_PCM = 6,
} encodingTypes;

@interface Recorder()<AVAudioPlayerDelegate,AVAudioRecorderDelegate>
-(void)observerAudioPower;
-(void)refreshAudioPower;
@end


@implementation Recorder
@synthesize delegate;
@synthesize recordFile;
@synthesize addInterval;

-(id)init{
    self=[super init];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];

    recordEncoding = ENC_AAC;

    return self;
}

-(void)dealloc{
    
    
    [audioRecorder stop];
    
    [audioPlayer stop];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];

}

-(void)record{
    [self stop];
    recordFile=nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];

    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:6];
    if(recordEncoding == ENC_PCM){
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    }
    else{
        NSNumber *formatObject;
        switch (recordEncoding) {
            case (ENC_AAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatMPEG4AAC];
                break;
            case (ENC_ALAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleLossless];
                break;
            case (ENC_IMA4):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
                break;
            case (ENC_ILBC):
                formatObject = [NSNumber numberWithInt: kAudioFormatiLBC];
                break;
            case (ENC_ULAW):
                formatObject = [NSNumber numberWithInt: kAudioFormatULaw];
                break;
            default:
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
        }
        
        [recordSettings setObject:formatObject forKey: AVFormatIDKey];//ID
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];//采样率
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];//通道的数目,1单声道,2立体声
        [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];//解码率
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];//采样位
        [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    }
    //获取document 目录
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex: 0];
    
    recordFile= [NSURL fileURLWithPath:[docDir stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"aac"]]];
    
        
    NSError *error = nil;
    audioRecorder = [[ AVAudioRecorder alloc] initWithURL:recordFile settings:recordSettings error:&error];
    audioRecorder.delegate=self;
    [audioRecorder prepareToRecord];
    [audioRecorder record];
    audioRecorder.meteringEnabled = YES;
    
    [self observerAudioPower];
    
}


-(void)observerAudioPower{
    [recordTimer invalidate];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    recordTimer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(refreshAudioPower) userInfo:nil repeats:YES];
    [runLoop addTimer:recordTimer forMode:NSRunLoopCommonModes];
}

-(void)refreshAudioPower{
    self.addInterval+=0.2f;
    [audioRecorder updateMeters];
    float level = [audioRecorder peakPowerForChannel:0];
    //NSLog(@"chanel2-->%f",[audioRecorder peakPowerForChannel:1]);
    
    int condition = abs(level);
    if(condition < 10){
        condition=11;
    }else if(condition <= 20){
        condition=10;
    }else if(condition >= 30){
        condition=1;
    }else{//介乎于21~29
        condition = condition%20;
    }
    if([self.delegate respondsToSelector:@selector(refreshAudioPower:level:)])
        [self.delegate refreshAudioPower:self level:condition];
    
    if(self.addInterval>=60){
        
    }
}


-(void)stop{
    self.addInterval=0.0f;
    [recordTimer invalidate];
    recordTimer=nil;
    
    
    [audioRecorder stop];
    audioRecorder = nil;
    
    [audioPlayer stop];
    audioPlayer=nil;

}

-(void)removeRecord{
    [self stop];
    
    NSFileManager* fileManeger = [NSFileManager defaultManager];
    [fileManeger removeItemAtURL:recordFile error:nil];
    recordFile=nil;
}

-(void)play:(NSURL*)url{
    [self stop];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSError *error;
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if(error!=nil){
        [self stop];
        if([self.delegate respondsToSelector:@selector(recordDidPlayError:)])
            [self.delegate recordDidPlayError:self];
        return;
    }
     
    audioPlayer.numberOfLoops = 0;
    audioPlayer.delegate = self;
    [audioPlayer prepareToPlay];
    [audioPlayer play];

}

#pragma mark  recorder delegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    [self stop];
}

#pragma mark  audio player delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self stop];
    if([self.delegate respondsToSelector:@selector(recordDidPlayFinish:)])
        [self.delegate recordDidPlayFinish:self];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    [self stop];
    if([self.delegate respondsToSelector:@selector(recordDidPlayError:)])
        [self.delegate recordDidPlayError:self];

}


@end

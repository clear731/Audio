//
//  ViewController.m
//  audioGame
//
//  Created by lingcao(曹玲) on 2017/11/8.
//  Copyright © 2017年 lingcao. All rights reserved.
//

#import "ViewController.h"
#import "AudioMix.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"zoral_music" ofType:@"wav"];;
//    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"tiger_music" ofType:@"wav"];;
//    [AudioMix mixAudioWithFile1:filePath1 file2:filePath2 useChannel:NO];

    NSString *filePath3 = [[NSBundle mainBundle] pathForResource:@"recorder2" ofType:@"wav"];;
    [AudioMix changePcmData:filePath3];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

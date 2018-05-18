//
//  ViewController.m
//  KLAlbumDemo
//
//  Created by zbmy on 2018/5/18.
//  Copyright © 2018年 HakoWaii. All rights reserved.
//

#import "ViewController.h"
#import "KLAlbumViewController.h"
@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openAlbum:(id)sender {
    KLAlbumViewController* albumVC = [[KLAlbumViewController alloc]initWithContentType:KLAlbumContentTypeOnlyPhoto SelectMaxCount:1 MinVideoDuration:0 IsMutiChoice:NO];
    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:albumVC];
    [self presentViewController:nav animated:YES completion:nil];
}

@end

//
//  InsertViewController.m
//  01_squlite练习
//
//  Created by qingyun on 15/10/20.
//  Copyright (c) 2015年 lmy. All rights reserved.
//

#import "InsertViewController.h"
#import "ClassMateMode.h"
#import "DBHandleOpration.h"

@interface InsertViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfID;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;

@end

@implementation InsertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addsubView];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)choosePhoto:(UIButton *)sender {
    //图片选择器
    UIImagePickerController *pickerViewcontroller=[[UIImagePickerController alloc] init];
    //相册
    pickerViewcontroller.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    pickerViewcontroller.delegate=self;
    [self presentViewController:pickerViewcontroller animated:YES completion:^{
        
    }];

    
}
#pragma mark -UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    _iconImage.image = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)SaveValue{
    ClassMateMode *mode=[[ClassMateMode alloc] initWith:_tfName.text Id:_tfID.text.intValue phoneFor:_tfPhone.text icon:UIImageJPEGRepresentation(_iconImage.image, 1)];
    //执行插入操作
    
    if ([[DBHandleOpration ShardDBHandle] insertFisrt:mode]) {
        NSLog(@"=====chenggon");
    };
    
}



-(void)addsubView{
    
    UIBarButtonItem *item=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(SaveValue)];
    self.navigationItem.rightBarButtonItem=item;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

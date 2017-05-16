//
//  PracticalInfo.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/12/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "PracticalInfo.h"
#import "PracticalInfoCell.h"
#import "AboutUsVC.h"
#import "ServiceManager.h"
#import "LocalizableLabel.h"
#import "MMMaterialDesignSpinner.h"

@interface PracticalInfo ()<UITableViewDelegate,UITableViewDataSource,ServicesManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *talbeview;
    @property (weak, nonatomic) IBOutlet LocalizableLabel *titleLbl;
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *indicator;
@property NSArray<PagesModel*> *pages;
@end

@implementation PracticalInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.titleLbl changeLocalizable:@"pracinfolbl"];
    [self buildServiceManager];
}
-(void)buildServiceManager{
    ServiceManager *manager = [[ServiceManager alloc] init];
    manager.delegate = self;
    self.indicator.hidden = NO;
    [self.indicator startAnimating];
    [manager getPages];
}
#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.pages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PracticalInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PracticalInfoCell" forIndexPath:indexPath];
    PagesModel *model = self.pages[indexPath.row];
    cell.pageTitle.text = model.pageTitle;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
    AboutUsVC *viewController = (AboutUsVC *)[mainStoryboard
                                                                instantiateViewControllerWithIdentifier:@"AboutUsVC"];
    PagesModel *model = self.pages[indexPath.row];
    viewController.model = model;
    viewController.titleStr = model.pageTitle;
    viewController.isFromInfo = YES;
    viewController.pageID = model.pageID;
    [self.navigationController pushViewController:viewController animated:YES];

}

#pragma mark - Navigation

- (IBAction)backTo:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ServicesManagerDelegate

-(void)errorGetPages:(NSError *)error{
    if (error) {
        self.indicator.hidden = YES;
        [self.indicator stopAnimating];
    }
}

-(void)getPages:(NSArray<PagesModel *> *)pages{
    NSPredicate* predicateCity = [NSPredicate predicateWithFormat:@"pageID != %@",[NSNumber numberWithInt:33]];
    self.pages = [pages filteredArrayUsingPredicate:predicateCity];
    self.indicator.hidden = YES;
    [self.indicator stopAnimating];
    [self.talbeview reloadData];
}

@end

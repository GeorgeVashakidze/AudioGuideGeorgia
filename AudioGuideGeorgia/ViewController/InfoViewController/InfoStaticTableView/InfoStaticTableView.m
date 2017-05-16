//
//  InfoStaticTableView.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/12/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "InfoStaticTableView.h"
#import "RestEventViewController.h"
#import "InfoStaticCell.h"

@interface InfoStaticTableView ()

@end

@implementation InfoStaticTableView

- (void)viewDidLoad {
    [super viewDidLoad];
}
#pragma mark - Navigation to Controllers

-(void)navigationToViewControllerByID:(NSString*)controllerIdentifire withTitle:(NSString*)str withIndex:(NSUInteger)index{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    RestEventViewController *viewController = (RestEventViewController *)[mainStoryboard
                                                            instantiateViewControllerWithIdentifier:controllerIdentifire];
    [viewController setTitleStr:str];
    if (index == 3) {
        viewController.info = restaurants;
    }else if(index == 4){
        viewController.info = shops;
    }else if (index == 6){
        viewController.info = festivals;
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableviewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 10;
    }
    return 42;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    InfoStaticCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (indexPath.row) {
        case 1:
            [self navigationToViewControllerByID:@"PracticalInfo" withTitle:cell.pracLbl.text withIndex:indexPath.row];
            break;
        case 3:
            [self navigationToViewControllerByID:@"RestEventViewController" withTitle:cell.restLbl.text withIndex:indexPath.row];
            break;
        case 4:
            [self navigationToViewControllerByID:@"RestEventViewController" withTitle:cell.shopLbl.text withIndex:indexPath.row];
            break;
        case 6:
            [self navigationToViewControllerByID:@"RestEventViewController" withTitle:cell.eventcLbl.text withIndex:indexPath.row];
        default:
            break;
    }
}
@end

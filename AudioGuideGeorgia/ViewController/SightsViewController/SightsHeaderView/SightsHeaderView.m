//
//  SightsHeaderView.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "SightsHeaderView.h"
#import "SightsFilterCell.h"

@implementation SightsHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    // you can change wether it expands at the top or as soon as you scroll down
    self.filterTableView.delegate = self;
    self.filterTableView.dataSource = self;
    self.expansionMode = GSKStretchyHeaderViewExpansionModeTopOnly;
    
    // You can change the minimum and maximum content heights
    self.minimumContentHeight = 0; // you can replace the navigation bar with a stretchy header view
    self.maximumContentHeight = 279;
    
    // You can specify if the content expands when the table view bounces, and if it shrinks if contentView.height < maximumContentHeight. This is specially convenient if you use auto layout inside the stretchy header view
    self.contentShrinks = YES;
    self.contentExpands = NO; // useful if you want to display the refreshControl below the header view
    
    // You can specify wether the content view sticks to the top or the bottom of the header view if one of the previous properties is set to NO
    // In this case, when the user bounces the scrollView, the content will keep its height and will stick to the bottom of the header view
    self.contentAnchor = GSKStretchyHeaderViewContentAnchorBottom;
    [self registerCell];
    self.needMustSee = NO;
//    self.filterTableView.scrollEnabled = NO;
}
-(void)setDefaultButtons{
    UIColor *selectedColor = [UIColor colorWithRed:61.0/255.0 green:56.0/255.0 blue:122.0/255.0 alpha:1];
    self.firstFilterBtn.layer.masksToBounds = YES;
    self.secondFilterBtn.layer.masksToBounds = YES;
    self.firstFilterBtn.layer.cornerRadius = 4.0f;
    self.secondFilterBtn.layer.cornerRadius = 4.0f;
    if (self.isSelecteedFirst) {
        self.firstFilterBtn.backgroundColor = selectedColor;
        self.firstFilterBtn.layer.borderWidth = 0.0f;
        [self.firstFilterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        self.firstFilterBtn.backgroundColor = [UIColor clearColor];
        self.firstFilterBtn.layer.borderWidth = 1.0f;
        self.firstFilterBtn.layer.borderColor = selectedColor.CGColor;
        [self.firstFilterBtn setTitleColor:selectedColor forState:UIControlStateNormal];
    }
    
    if (self.isSelecteedSecond) {
        self.secondFilterBtn.backgroundColor = selectedColor;
        self.secondFilterBtn.layer.borderWidth = 0.0f;
        [self.secondFilterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        self.secondFilterBtn.backgroundColor = [UIColor clearColor];
        self.secondFilterBtn.layer.borderWidth = 1.0f;
        self.secondFilterBtn.layer.borderColor = selectedColor.CGColor;
        [self.secondFilterBtn setTitleColor:selectedColor forState:UIControlStateNormal];
    }
}
-(void)buildService{
    if (self.selectedCellIndexArray == nil) {
        self.selectedCellIndexArray = [[NSMutableArray alloc] initWithCapacity:100];
    }
    self.manager = [[ServiceManager alloc] init];
    self.manager.delegate = self;
    if (self.isFromTours) {
        [self.manager getTourFilters];
    }else{
        [self.manager getSightFilters];
    }
    self.loadIndicator.hidden = NO;
    [self.loadIndicator startAnimating];
}
-(void)selectedFirstBtn:(BOOL)isFirstBtn{
    self.firstFilterBtn.layer.masksToBounds = YES;
    self.secondFilterBtn.layer.masksToBounds = YES;
    self.firstFilterBtn.layer.cornerRadius = 4.0f;
    self.secondFilterBtn.layer.cornerRadius = 4.0f;
    UIColor *selectedColor = [UIColor colorWithRed:61.0/255.0 green:56.0/255.0 blue:122.0/255.0 alpha:1];
    if (isFirstBtn) {
        if (self.isSelecteedFirst) {
            self.firstFilterBtn.backgroundColor = [UIColor clearColor];
            self.firstFilterBtn.layer.borderWidth = 1.0f;
            self.firstFilterBtn.layer.borderColor = selectedColor.CGColor;
            [self.firstFilterBtn setTitleColor:selectedColor forState:UIControlStateNormal];
            self.isSelecteedFirst = NO;
        }else{
            self.isSelecteedFirst = YES;
            [self.firstFilterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.firstFilterBtn.backgroundColor = selectedColor;
            self.firstFilterBtn.layer.borderWidth = 0.0f;
        }
        
    }else{
        if (self.isSelecteedSecond) {
            self.isSelecteedSecond = NO;
            [self.secondFilterBtn setTitleColor:selectedColor forState:UIControlStateNormal];
            self.secondFilterBtn.backgroundColor = [UIColor clearColor];
            self.secondFilterBtn.layer.borderWidth = 1.0f;
            self.secondFilterBtn.layer.borderColor = selectedColor.CGColor;
        }else{
            self.isSelecteedSecond = YES;
            self.secondFilterBtn.backgroundColor = selectedColor;
            self.secondFilterBtn.layer.borderWidth = 0.0f;
            [self.secondFilterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }

    }
}
- (IBAction)firstFilterTaped:(UIButton *)sender {
    [self selectedFirstBtn:true];
    self.needMustSee = NO;
    [self.filterDelegate chooseFilter:self.selectedCellIndexArray withMustSee:self.isSelecteedSecond withNear:self.isSelecteedFirst];
}
- (IBAction)secondFilterTaped:(UIButton *)sender {
    [self selectedFirstBtn:false];
    self.needMustSee = YES;
    [self.filterDelegate chooseFilter:self.selectedCellIndexArray withMustSee:self.isSelecteedSecond withNear:self.isSelecteedFirst];
}
-(void)registerCell{
    UINib *nib = [UINib nibWithNibName:@"SightsFilterCell" bundle:nil];
    [self.filterTableView registerNib:nib forCellReuseIdentifier:@"SightsFilterCell"];
}
#pragma mark - Tableview

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filterTours.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     SightsFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SightsFilterCell" forIndexPath:indexPath];
    FilterModel *model = self.filterTours[indexPath.row];
    if ([self.selectedCellIndexArray containsObject:model.filterID]) {
        cell.checkImage.image = [UIImage imageNamed:@"filterCheck"];
    }else{
        cell.checkImage.image = [UIImage imageNamed:@"filterUnCheck"];
    }
    cell.filterTitle.text = model.title;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 39;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SightsFilterCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    FilterModel *model = self.filterTours[indexPath.row];
    if([self.selectedCellIndexArray containsObject:model.filterID]){
        [self.selectedCellIndexArray removeObject:model.filterID];
        cell.checkImage.image = [UIImage imageNamed:@"filterUnCheck"];
    }else{
        [self.selectedCellIndexArray addObject:model.filterID];
        cell.checkImage.image = [UIImage imageNamed:@"filterCheck"];
    }
    [self.filterDelegate chooseFilter:self.selectedCellIndexArray withMustSee:self.isSelecteedSecond withNear:self.isSelecteedFirst];
}
#pragma mark - ServicesManagerDelegate
-(void)getTourFilters:(NSArray<FilterModel *> *)tourFilter{
    self.loadIndicator.hidden = YES;
    [self.loadIndicator stopAnimating];
    self.filterTours = tourFilter;
    CGFloat heightFilter = 279;
    if(self.filterTours.count > 4){
        heightFilter = heightFilter + 39*(self.filterTours.count - 4);
        self.maximumContentHeight = heightFilter;
        [self.filterDelegate changeHeightOfHeader:heightFilter];
    }
    [self.filterTableView reloadData];
}
-(void)errorgetTourFilter:(NSError *)error{
    if (error) {
        self.loadIndicator.hidden = YES;
        [self.loadIndicator stopAnimating];
    }
}
@end

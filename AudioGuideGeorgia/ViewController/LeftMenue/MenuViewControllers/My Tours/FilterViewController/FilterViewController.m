//
//  FilterViewController.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 1/29/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "FilterViewController.h"
#import "SightsHeaderView.h"
#import "SliderSubClass.h"
#import "LocalizableLabel.h"

@interface FilterViewController ()<FilterDelegate>{
    NSMutableArray *numbers;
}
@property (weak, nonatomic) IBOutlet UIView *filteHelperView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceLblRightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *showToursBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filterHeightConstant;
@property (weak, nonatomic) IBOutlet UISlider *customSlider;
@property (weak, nonatomic) IBOutlet UILabel *priceLbl;
@property (weak, nonatomic) SightsHeaderView *headerView;
@property (weak, nonatomic) IBOutlet LocalizableLabel *filterTilte;
@property (weak, nonatomic) IBOutlet LocalizableLabel *priceRangeLbl;
@property (weak, nonatomic) IBOutlet LocalizableLabel *freePriceLbl;
@property NSArray *filterArray;
@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.filterArray = [[NSArray alloc] init];
    [self loadFilterHelper];
    [self setCornerRadiuse];
    [self configureCustomSlider];
    [self configureSlider];
    [self setLocalizable];
}

-(void)setLocalizable{
    [self.filterTilte changeLocalizable:@"filtertitle"];
    [self.freePriceLbl changeLocalizable:@"freeprice"];
    [self.priceRangeLbl changeLocalizable:@"pricerage"];
    [self.showToursBtn setTitle:[[LanguageManager sharedManager] getLocalizedStringFromKey:@"showtours"] forState:UIControlStateNormal];
}
-(void)configureSlider{
    // These number values represent each slider position
    numbers = [[NSMutableArray alloc] initWithCapacity:7];
    CGFloat detlaPrice = self.tourTotalPrice/(float)6;
    for (int i = 0; i < 7; i++) {
        [numbers addObject:[NSNumber numberWithFloat:i*detlaPrice]];
    }
    // slider values go from 0 to the number of values in your numbers array
    NSInteger numberOfSteps = ((float)[numbers count] - 1);
    _customSlider.maximumValue = numberOfSteps;
    _customSlider.minimumValue = 0;
    
    // As the slider moves it will continously call the -valueChanged:
    _customSlider.continuous = YES; // NO makes it call only once you let go
    [_customSlider setValue:numberOfSteps animated:NO];
    self.priceLbl.text =  [NSString stringWithFormat:@"%.2f$",self.currentPrice];
}
-(void)configureCustomSlider{
    [self.customSlider setThumbImage:[UIImage imageNamed:@"priceRangeSlider"] forState:UIControlStateNormal];
    [self.customSlider setThumbImage:[UIImage imageNamed:@"priceRangeSlider"] forState:UIControlStateSelected];
      [self.customSlider setThumbImage:[UIImage imageNamed:@"priceRangeSlider"] forState:UIControlStateApplication];
      [self.customSlider setThumbImage:[UIImage imageNamed:@"priceRangeSlider"] forState:UIControlStateReserved];
}
-(void)setCornerRadiuse{
    self.showToursBtn.layer.masksToBounds = YES;
    self.showToursBtn.layer.cornerRadius = 4.0f;
}

#pragma mark - Filter Helper

-(void)loadFilterHelper{
    [self.view layoutIfNeeded];
    self.headerView = [[[NSBundle mainBundle] loadNibNamed:@"SightsHeaderView" owner:self options:nil] objectAtIndex:0];
    self.headerView.isFromTours = YES;
    self.headerView.currentCity = self.currentCity;
    self.headerView.filterDelegate = self;
    self.headerView.isSelecteedFirst = self.isSelectedFirst;
    self.headerView.isSelecteedSecond = self.isSelectedSecond;
    self.headerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.filteHelperView.frame.size.height);
    self.headerView.selectedCellIndexArray = [[NSMutableArray alloc] initWithArray:self.filterIDS];
    [self.headerView setDefaultButtons];
    [self.headerView buildService];
    [self.filteHelperView addSubview:self.headerView];
}
-(void)changeHeightOfHeader:(CGFloat)heightHeader{
    self.filterHeightConstant.constant += (heightHeader - 279);
    [UIView animateWithDuration:0.15 animations:^{
        [self.view layoutIfNeeded];
    }];
}
#pragma mark - IBAction

- (IBAction)backTo:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)valueChanged:(SliderSubClass *)sender {
    // round the slider position to the nearest index of the numbers array
    NSUInteger index = (NSUInteger)(_customSlider.value + 0.5);
    [_customSlider setValue:index animated:NO];
    NSNumber *number = numbers[index]; // <-- This numeric value you want
    self.priceLbl.text = [NSString stringWithFormat:@"%.2f$",[number doubleValue]];
    self.currentPrice = [number doubleValue];
    if (index == 0) {
        self.priceLbl.hidden = YES;
    }else{
        self.priceLbl.hidden = NO;
        if (index == self->numbers.count-1) {
            self.priceLblRightConstraint.constant = 20;
        }else{
            self.priceLblRightConstraint.constant = ((self->numbers.count - 1) - index)*(sender.frame.size.width/(self->numbers.count - 1));
        }
    }
}


#pragma mark - Pan Gesture
- (IBAction)panGesture:(UIPanGestureRecognizer *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)finisheFilter:(UIButton *)sender {
    [self.filterDelegate filterTour:self.filterArray withCity:self.headerView.isSelecteedSecond withNearMee:self.headerView.isSelecteedFirst withPirceRange:self.currentPrice];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - FilterDelegate

-(void)chooseFilter:(NSArray *)filterID withMustSee:(BOOL)mustSee withNear:(BOOL)nearMee{
    self.filterArray = filterID;

}


@end

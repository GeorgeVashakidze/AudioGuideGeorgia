//
//  CustomAnnotationView.m
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/23/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "SightModel.h"
#import "ShopsModel.h"
#import "FestivalsModel.h"
#import "RestaurantsModel.h"

@implementation CustomAnnotationView{
    id <MGLAnnotation> _representedObject;
    __unused UIView *_leftAccessoryView;/* unused */
    __unused UIView *_rightAccessoryView;/* unused */
    __weak id <MGLCalloutViewDelegate> _delegate;
}

@synthesize representedObject = _representedObject;
@synthesize anchoredToAnnotation = _anchoredToAnnotation;
@synthesize dismissesAutomatically = _dismissesAutomatically;
@synthesize leftAccessoryView = _leftAccessoryView;/* unused */
@synthesize rightAccessoryView = _rightAccessoryView;/* unused */
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}
-(BOOL)dismissesAutomatically{
    return NO;
}
-(CGFloat)getWithText:(NSString*)textStr{
    CGSize frameSize = CGSizeMake(1000,44);
    UIFont *font = [UIFont fontWithName:@"DINPro-Medium" size:14];;
    
    CGRect idealFrame = [textStr boundingRectWithSize:frameSize
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{ NSFontAttributeName:font }
                                           context:nil];
    return idealFrame.size.width;
}
#pragma mark - MGLCalloutView API

- (void)presentCalloutFromRect:(CGRect)rect inView:(UIView *)view constrainedToView:(UIView *)constrainedView animated:(BOOL)animated
{
    // Do not show a callout if there is no title set for the annotation
    if (![self.representedObject respondsToSelector:@selector(title)])
    {
        return;
    }
        
        [view addSubview:self];
        
        // Prepare title label
        
        
        CGFloat widthFrame = [self getWithText:self.representedObject.title];
        widthFrame += 20;
        if ([self.model isKindOfClass:[SightModel class]]) {
            widthFrame -= 65;
        }
        self.backgroundColor = [UIColor clearColor];
        view.backgroundColor = [UIColor clearColor];
        UIView *frameMain = [[UIView alloc] initWithFrame:CGRectMake(0, 2, widthFrame, 44)];
        frameMain.backgroundColor = [self backgroundColorForCallout];
        frameMain.layer.masksToBounds = YES;
        frameMain.layer.cornerRadius = 8;
        UIButton *mainBody = [UIButton buttonWithType:UIButtonTypeSystem];
        mainBody.backgroundColor = [UIColor clearColor];
        mainBody.tintColor = [UIColor clearColor];
        mainBody.contentEdgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
        mainBody.layer.cornerRadius = 4.0;
        self.mainBody = mainBody;
        self.mainBody.frame = CGRectMake(0, 0, 243, 44);
        self.titleLbl = [[UILabel alloc] init];
        self.titleLbl.font = [UIFont fontWithName:@"DINPro-Medium" size:14];
        self.titleLbl.frame = CGRectMake(8, 0, 180, 44);
        self.titleLbl.numberOfLines = 2;
        if([self.model isKindOfClass:[SightModel class]]){
            self.titleLbl.textColor = [UIColor colorWithRed:61./255. green:56./255. blue:122./255. alpha:1];
        }else{
            self.titleLbl.textColor =  [UIColor whiteColor];
        }
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(200, 13, 11, 21)];
        arrow.image = [UIImage imageNamed:@"arrowLeftColor"];
        [frameMain addSubview:self.titleLbl];
        [frameMain addSubview:self.mainBody];
        [frameMain addSubview:arrow];
        [self addSubview:frameMain];
        
        if ([self isCalloutTappable])
        {
            // Handle taps and eventually try to send them to the delegate (usually the map view)
            [self.mainBody addTarget:self action:@selector(calloutTapped) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            // Disable tapping and highlighting
            self.mainBody.userInteractionEnabled = NO;
        }
        self.titleLbl.text = self.representedObject.title;
        
        // Prepare our frame, adding extra space at the bottom for the tip
        CGFloat deltaY = 120;
        CGFloat frameOriginX = rect.origin.x + (rect.size.width/2.0) - (widthFrame/2.0);
        if ([self.model isKindOfClass:[SightModel class]]) {
            deltaY = 54;
        }
        CGFloat frameOriginY = rect.origin.y - deltaY;
        
        self.frame = CGRectMake(frameOriginX, frameOriginY,
                                widthFrame, 54);
        
        if (animated)
        {
            self.alpha = 0.0;
            
            [UIView animateWithDuration:0.2 animations:^{
                self.alpha = 1.0;
            }];
        }
}
- (void)setCenter:(CGPoint)center {
    if ([self.model isKindOfClass:[SightModel class]]) {
        center.y = center.y - CGRectGetMidY(self.bounds)+13;
    }else{
        center.y = center.y - CGRectGetMidY(self.bounds);
    }
    [super setCenter:center];
}

- (void)dismissCalloutAnimated:(BOOL)animated
{
    if (self.superview)
    {
        if (animated)
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        }
        else
        {
            [self removeFromSuperview];
        }
    }
}

#pragma mark - Callout interaction handlers

- (BOOL)isCalloutTappable
{
    if ([self.delegate respondsToSelector:@selector(calloutViewShouldHighlight:)]) {
        return [self.delegate performSelector:@selector(calloutViewShouldHighlight:) withObject:self];
    }
    
    return NO;
}

- (void)calloutTapped
{
    if ([self isCalloutTappable] && [self.delegate respondsToSelector:@selector(calloutViewTapped:)])
    {
        [self.delegate performSelector:@selector(calloutViewTapped:) withObject:self];
    }
}

#pragma mark - Custom view styling

- (UIColor *)backgroundColorForCallout
{
    if ([self.model isKindOfClass:[SightModel class]]) {
        return [UIColor colorWithRed:0 green:1 blue:138.0/255. alpha:1];
    }else if([self.model isKindOfClass:[FestivalsModel class]]){
        return [UIColor colorWithRed:0 green:155.0/255. blue:215.0/255. alpha:1];
    }else if([self.model isKindOfClass:[ShopsModel class]]){
        return [UIColor colorWithRed:235.0/255.0 green:144.0/255. blue:28.0/255. alpha:1];
    }else if([self.model isKindOfClass:[RestaurantsModel class]]){
        if ([((RestaurantsModel*)self.model).restKind isEqualToString:@"1"]) {
            return [UIColor colorWithRed:77.0/255.0 green:6.0/255. blue:57.0/255. alpha:1];
        }else{
            return [UIColor colorWithRed:40.0/255.0 green:150.0/255. blue:146.0/255. alpha:1];
        }
    }
    return [UIColor colorWithRed:0 green:1 blue:138.0/255. alpha:1];
}

- (void)drawRect:(CGRect)rect
{
    // Draw the pointed tip at the bottom
    UIColor *fillColor = [self backgroundColorForCallout];

    CGFloat tipLeft = rect.origin.x + (rect.size.width / 2.0) - (tipWidth / 2.0);
    CGPoint tipBottom = CGPointMake(rect.origin.x + (rect.size.width / 2.0), rect.origin.y +rect.size.height);
    CGFloat heightWithoutTip = rect.size.height - tipHeight;
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef tipPath = CGPathCreateMutable();
    CGPathMoveToPoint(tipPath, NULL, tipLeft, heightWithoutTip);
    CGPathAddLineToPoint(tipPath, NULL, tipBottom.x, tipBottom.y);
    CGPathAddLineToPoint(tipPath, NULL, tipLeft + tipWidth, heightWithoutTip);
    CGPathCloseSubpath(tipPath);
    
    [fillColor setFill];
    CGContextAddPath(currentContext, tipPath);
    CGContextFillPath(currentContext);
    CGPathRelease(tipPath);
}



@end

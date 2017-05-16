//
//  CustomAnnotationView.h
//  AudioGuideGeorgia
//
//  Created by Tornike Davitashvili on 2/23/17.
//  Copyright © 2017 Tornike Davitashvili. All rights reserved.
//

#import <Mapbox/Mapbox.h>
static CGFloat const tipHeight = 10.0;
static CGFloat const tipWidth = 20.0;
@class SightModel;
@interface CustomAnnotationView : UIView<MGLCalloutView>
@property (strong, nonatomic) UIButton *mainBody;
@property (strong, nonatomic) UILabel *titleLbl;
@property (strong,nonatomic) SightModel *model;
@property (nonatomic, assign, getter=isAnchoredToAnnotation) BOOL anchoredToAnnotation;
@property (nonatomic, assign) BOOL dismissesAutomatically;
@end

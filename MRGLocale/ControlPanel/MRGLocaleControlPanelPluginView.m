//
//  MRGLocaleControlPanelPluginView.m
//  MRGLocale
//
//  Created by Vincent Roy Chevalier on 2014-03-05.
//  Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGLocaleControlPanelPluginView.h"
#import <MRGLocale.h>

@interface MRGLocaleControlPanelPluginView ()
@property (nonatomic) UILabel *label;
@end

@implementation MRGLocaleControlPanelPluginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] init];
        _label.text = MRGString(@"test");
        _label.textColor = [UIColor blackColor];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect rect = self.bounds;
    _label.frame = rect;
}

////////////////////////////////////////////////////////////////////////
#pragma mark Public methods
////////////////////////////////////////////////////////////////////////

- (void)refreshLabel
{
    _label.text = MRGString(@"test");
}

- (void)setLabelTextWithKey:(NSString *)key
{
    _label.text = MRGString(key);
}

@end

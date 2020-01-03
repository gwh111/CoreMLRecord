//
//  CC_ShareUI+ItemDesLabel.m
//  BallOC
//
//  Created by gwh on 2019/12/30.
//  Copyright © 2019 gwh. All rights reserved.
//

#import "CC_ShareUI+BallOC.h"

@implementation CC_ShareUI (BallOC)

- (CC_Label *)itemTitleLabel {
    return ccs.Label
    .cc_frame(RH(20), 0, WIDTH(), RH(50))
    .cc_textColor(UIColor.blackColor)
    .cc_text(@"标题")
    .cc_font(RF(20));
}

- (CC_Label *)itemDesLabel {
    return ccs.Label
    .cc_frame(RH(10), RH(15), RH(200), RH(35))
    .cc_textColor(UIColor.grayColor)
    .cc_textAlignment(NSTextAlignmentCenter)
    .cc_font(RF(14))
    .cc_text(@"描述");
}

@end

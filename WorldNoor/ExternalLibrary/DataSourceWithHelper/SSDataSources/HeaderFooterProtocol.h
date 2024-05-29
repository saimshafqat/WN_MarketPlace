//
//  HeaderFooterProtocol.h
//  SweetSpot
//
//  Created by Muhammad Umair Soorage on 08/03/2018.
//  Copyright © 2018 Xtraiq. All rights reserved.
//

#ifndef HeaderFooterProtocol_h
#define HeaderFooterProtocol_h

#import <UIKit/UIKit.h>

@protocol HeaderFooterDelegate <NSObject>

- (IBAction)digestSeeMoreButton:(id)sender;
- (IBAction)digestHeaderButton:(id)sender;

@end

#endif /* HeaderFooterProtocol_h */

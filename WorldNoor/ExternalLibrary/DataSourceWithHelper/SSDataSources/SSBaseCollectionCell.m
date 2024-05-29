//
//  SSBaseCollectionCell.m
//  SSDataSources
//
//  Created by Jonathan Hersh on 6/24/13.
//
//

#import "SSBaseCollectionCell.h"

@interface SSBaseCollectionCell ()

@property (nonatomic, assign) BOOL didCompleteSetup;

@end

@implementation SSBaseCollectionCell

+ (NSString *)identifier {
    return NSStringFromClass(self);
}

+ (instancetype)cellForCollectionView:(UICollectionView *)collectionView
                            indexPath:(NSIndexPath *)indexPath {
    
    SSBaseCollectionCell *cell = (SSBaseCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[self identifier]
                                                                                                   forIndexPath:indexPath];
  
    if (!cell.didCompleteSetup) {
        [cell configureCell];
      
        cell.didCompleteSetup = YES;
    }
  
    return cell;
}

- (void)configureCell {
    // override me!
}

- (void)configureCell:(id)cell atIndex:(NSIndexPath *)thisIndex withObject:(id)object   {
    // override me!
}

- (IBAction)didTapButton:(id)sender {
    if (self.didTapCollectionButtonBlock)
        self.didTapCollectionButtonBlock(sender);
}

@end

//
//  SSBaseDataSource.m
//  SSDataSources
//
//  Created by Jonathan Hersh on 6/8/13.
//  Copyright (c) 2013 Splinesoft. All rights reserved.
//

#import "SSDataSources.h"

@interface SSBaseDataSource ()

@property (nonatomic, assign) UITableViewCellSeparatorStyle cachedSeparatorStyle;

- (void) _updateEmptyView;

@end

@implementation SSBaseDataSource

#pragma mark - init

- (instancetype)init {
    if ((self = [super init])) {
        self.cellClass = [SSBaseTableCell class];
        self.collectionViewSupplementaryElementClass = [SSBaseCollectionReusableView class];
        self.rowAnimation = UITableViewRowAnimationAutomatic;
        self.cachedSeparatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return self;
}

- (void)dealloc {
    if (self.emptyView) {
        [self.emptyView removeFromSuperview];
        self.emptyView = nil;
    }
    _currentFilter = nil;
    self.cellConfigureBlock = nil;
    self.cellCreationBlock = nil;
    self.collectionSupplementaryConfigureBlock = nil;
    self.collectionSupplementaryCreationBlock = nil;
    self.tableActionBlock = nil;
    self.tableDeletionBlock = nil;
    self.tableView.dataSource = nil;
    self.collectionView.dataSource = nil;
}

#pragma mark - SSBaseDataSource

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSUInteger)numberOfSections {
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (NSUInteger)numberOfItems {
    NSUInteger count = 0;
    
    for (NSUInteger i = 0; i < [self numberOfSections]; i++) {
        count += [self numberOfItemsInSection:i];
    }
    
    return count;
}

- (NSIndexPath *)indexPathForItem:(id)item {
    for (NSUInteger section = 0; section < [self numberOfSections]; section++) {
        for (NSUInteger row = 0; row < [self numberOfItemsInSection:section]; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            if ([[self itemAtIndexPath:indexPath] isEqual:item]) {
                return indexPath;
            }
        }
    }
    
    return nil;
}

- (void)enumerateItemsWithBlock:(SSDataSourceEnumerator)itemBlock {
    if (!itemBlock) {
        return;
    }
    
    BOOL stop = NO;
    
    id <SSDataSourceItemAccess> dataSource = (self.currentFilter ?: self);
    
    for (NSUInteger i = 0; i < [self numberOfSections]; i++) {
        for (NSUInteger j = 0; j < [self numberOfItemsInSection:i]; j++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            id item = [dataSource itemAtIndexPath:indexPath];
            
            itemBlock(indexPath, item, &stop);
            
            if (stop) {
                return;
            }
        }
    }
}

#pragma mark - Common

- (void)configureCell:(id)cell
              forItem:(id)item
           parentView:(id)parentView
            indexPath:(NSIndexPath *)indexPath {
    
    if (self.cellConfigureBlock) {
            self.cellConfigureBlock(cell, item, parentView, indexPath);
    }
}

- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    
    if (tableView) {
        tableView.dataSource = self;
    }

    [self _updateEmptyView];
}

- (void)setCollectionView:(UICollectionView *)collectionView {
    _collectionView = collectionView;
    
    if (collectionView) {
        collectionView.dataSource = self;
    }

    [self _updateEmptyView];
}

//#pragma mark - SkeletonTableViewDataSource
//
//- (UITableViewCell *)collectionSkeletonView:(UITableView *)tv skeletonCellForRowAt:(NSIndexPath *)indexPath {
//    id item = [self itemAtIndexPath:indexPath];
//
//    id cell = (self.cellCreationBlock ? self.cellCreationBlock(item, tv, indexPath) : [self.cellClass cellForTableView:tv]);
//        [self configureCell:cell forItem:item parentView:tv indexPath:indexPath];
//    return cell;
//}
//
//- (NSInteger)collectionSkeletonView:(UITableView *)skeletonView numberOfRowsInSection:(NSInteger)section {
//    return (NSInteger)[self numberOfItemsInSection:section];
//}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tv
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    id item = [self itemAtIndexPath:indexPath];

    id cell = (self.cellCreationBlock ? self.cellCreationBlock(item, tv, indexPath) : [self.cellClass cellForTableView:tv]);
        [self configureCell:cell forItem:item parentView:tv indexPath:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (NSInteger)[self numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)[self numberOfItemsInSection:section];
}

- (BOOL)tableView:(UITableView *)tv canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.tableActionBlock) {
        return self.tableActionBlock(SSCellActionTypeMove,
                                     tv,
                                     indexPath);
    }
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tv canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.tableActionBlock) {
        return self.tableActionBlock(SSCellActionTypeEdit,
                                     tv,
                                     indexPath);
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tv
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.tableDeletionBlock) {
        self.tableDeletionBlock(self,
                                tv,
                                indexPath);
    }
}

//#pragma mark - SkeletonCollectionViewDataSource
//
//- (NSString *)collectionSkeletonView:(UICollectionView *)cv cellIdentifierForItemAt:(NSIndexPath *)indexPath {
//    id item = [self itemAtIndexPath:indexPath];
//    UICollectionViewCell *cell = (self.cellCreationBlock
//               ? self.cellCreationBlock(item, cv, indexPath)
//               : [self.cellClass cellForCollectionView:cv
//                                             indexPath:indexPath]);
//    return cell.reuseIdentifier;
//}
//
//- (NSString *)collectionSkeletonView:(UICollectionView *)cv supplementaryViewIdentifierOfKind:(NSString *)kind at:(NSIndexPath *)indexPath {
//    UICollectionReusableView *supplementaryView =
//        (self.collectionSupplementaryCreationBlock
//         ? self.collectionSupplementaryCreationBlock(kind, cv, indexPath)
//         : [self.collectionViewSupplementaryElementClass
//            supplementaryViewForCollectionView:cv
//            kind:kind
//            indexPath:indexPath]);
//    return supplementaryView.reuseIdentifier;
//}

//- (void)collectionSkeletonView:(UICollectionView *)cv prepareCellForSkeleton:(UICollectionViewCell *)cell at:(NSIndexPath *)indexPath {
//    id item = [self itemAtIndexPath:indexPath];
//
//    [self configureCell:cell
//                forItem:item
//             parentView:cv
//              indexPath:indexPath];
//}
//
//- (UICollectionViewCell *)collectionSkeletonView:(UICollectionView *)cv skeletonCellForItemAt:(NSIndexPath *)indexPath {
//    id item = [self itemAtIndexPath:indexPath];
//
//    id cell = (self.cellCreationBlock
//               ? self.cellCreationBlock(item, cv, indexPath)
//               : [self.cellClass cellForCollectionView:cv
//                                             indexPath:indexPath]);
//
//    [self configureCell:cell
//                forItem:item
//             parentView:cv
//              indexPath:indexPath];
//
//    return cell;
//}
//
//
//- (NSInteger)numSectionsIn:(UICollectionView *)collectionSkeletonView {
//    return (NSInteger)[self numberOfSections];
//}
//
//- (NSInteger)collectionSkeletonView:(UICollectionView *)skeletonView numberOfItemsInSection:(NSInteger)section {
//    return (NSInteger)[self numberOfItemsInSection:section];
//}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    id item = [self itemAtIndexPath:indexPath];
    
    id cell = (self.cellCreationBlock
               ? self.cellCreationBlock(item, cv, indexPath)
               : [self.cellClass cellForCollectionView:cv
                                             indexPath:indexPath]);

    [self configureCell:cell
                forItem:item
             parentView:cv
              indexPath:indexPath];

    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return (NSInteger)[self numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  
    return (NSInteger)[self numberOfItemsInSection:section];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)cv
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *supplementaryView =
        (self.collectionSupplementaryCreationBlock
         ? self.collectionSupplementaryCreationBlock(kind, cv, indexPath)
         : [self.collectionViewSupplementaryElementClass
            supplementaryViewForCollectionView:cv
            kind:kind
            indexPath:indexPath]);
    if (supplementaryView == nil) {
        supplementaryView = [self.collectionViewSupplementaryElementClass
           supplementaryViewForCollectionView:cv
           kind:kind
                             indexPath:indexPath];
    }
    
    if (self.collectionSupplementaryConfigureBlock) {
        self.collectionSupplementaryConfigureBlock(supplementaryView, kind, cv, indexPath);
    }
    
    return supplementaryView;
}

#pragma mark - Empty Views

- (void)setEmptyView:(UIView *)emptyView {
    if (self.emptyView) {
        [self.emptyView removeFromSuperview];
    }
    
    _emptyView = emptyView;
    self.emptyView.hidden = YES;
    
    [self _updateEmptyView];
}

- (void)_updateEmptyView {
    if (!self.emptyView) {
        return;
    }
    
    UITableView *tableView = self.tableView;
    UICollectionView *collectionView = self.collectionView;
    UIScrollView *targetView = (tableView ?: collectionView);
    
    if (!targetView) {
        return;
    }
    
    if (self.emptyView.superview != targetView) {
        [targetView addSubview:self.emptyView];
    }
    
    BOOL shouldShowEmptyView = ([self numberOfItems] == 0);
    BOOL isShowingEmptyView = !self.emptyView.hidden;
    
    if (shouldShowEmptyView) {
        if (tableView.separatorStyle != UITableViewCellSeparatorStyleNone) {
            self.cachedSeparatorStyle = tableView.separatorStyle;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
    } else if (self.cachedSeparatorStyle != UITableViewCellSeparatorStyleNone) {
        tableView.separatorStyle = self.cachedSeparatorStyle;
    }
    
    if (shouldShowEmptyView == isShowingEmptyView) {
        return;
    }
    
    if (CGRectEqualToRect(self.emptyView.frame, CGRectZero)) {
        CGRect frame = UIEdgeInsetsInsetRect(targetView.bounds, targetView.contentInset);
//        UIEdgeInsets targetViewContentInset = targetView.contentInset;
//        CGRect frame = UIEdgeInsetsInsetRect(targetView.bounds, UIEdgeInsetsMake(targetViewContentInset.top, targetViewContentInset.left+16, targetViewContentInset.bottom, targetViewContentInset.right+16));
        
        if (tableView.tableHeaderView) {
            frame.size.height -= CGRectGetHeight(tableView.tableHeaderView.frame);
        }
        
        [self.emptyView setFrame:frame];
        self.emptyView.autoresizingMask = targetView.autoresizingMask;
    }
    
    self.emptyView.hidden = !shouldShowEmptyView;
    
    // Reloading seems to work around an awkward delay where the empty view
    // is not immediately visible but the separator lines still are
    if (shouldShowEmptyView) {
        //[tableView reloadData];
        [collectionView reloadData];
    }
}

#pragma mark - NSIndexPath helpers

+ (NSArray *)indexPathArrayWithIndexSet:(NSIndexSet *)indexes
                              inSection:(NSInteger)section {
    
    NSMutableArray *ret = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        [ret addObject:[NSIndexPath indexPathForRow:(NSInteger)index inSection:section]];
    }];
    
    return ret;
}

+ (NSArray *)indexPathArrayWithRange:(NSRange)range
                           inSection:(NSInteger)section {
    
    return [self indexPathArrayWithIndexSet:[NSIndexSet indexSetWithIndexesInRange:range]
                                  inSection:section];
}

#pragma mark - UITableView/UICollectionView Operations

- (void)insertCellsAtIndexPaths:(NSArray *)indexPaths {
    //Save the tableview content offset
    CGPoint tableViewOffset = [self.tableView contentOffset];
    
    //Turn of animations for the update block
    //to get the effect of adding rows on top of TableView
    [UIView setAnimationsEnabled:NO];
    
    [self.tableView beginUpdates];
    
    NSMutableArray *rowsInsertIndexPath = [[NSMutableArray alloc] init];
    
  //  int heightForNewRows = 0;
    
    for (NSInteger i = 0; i < indexPaths.count; i++) {
        
        NSIndexPath *tempIndexPath = [indexPaths objectAtIndex:i];
        [rowsInsertIndexPath addObject:tempIndexPath];
        
     //   heightForNewRows = heightForNewRows + [self heightForCellAtIndexPath:tempIndexPath];
    }
    
    [self.tableView insertRowsAtIndexPaths:indexPaths
                          withRowAnimation: self.rowAnimation];
    
    
    [self.collectionView insertItemsAtIndexPaths:indexPaths];
    
//    tableViewOffset.y += heightForNewRows;
    
    [self.tableView endUpdates];
    
    [UIView setAnimationsEnabled:YES];
    
    [self.tableView setContentOffset:tableViewOffset animated:NO];
    
    [self _updateEmptyView];
}

-(int) heightForCellAtIndexPath: (NSIndexPath *) indexPath
{
    
    UITableViewCell *cell =  [self.tableView cellForRowAtIndexPath:indexPath];
    
    int cellHeight =  cell.frame.size.height;
    
    return cellHeight;
}


- (void)deleteCellsAtIndexPaths:(NSArray *)indexPaths {
    [self.tableView deleteRowsAtIndexPaths:indexPaths
                          withRowAnimation:self.rowAnimation];
    
    
    [self.collectionView deleteItemsAtIndexPaths:indexPaths];
    
    [self _updateEmptyView];
}

- (void)reloadCellsAtIndexPaths:(NSArray *)indexPaths {
    [self.tableView reloadRowsAtIndexPaths:indexPaths
                          withRowAnimation:self.rowAnimation];
    
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
}

- (void)moveCellAtIndexPath:(NSIndexPath *)index1 toIndexPath:(NSIndexPath *)index2 {
    [self.tableView moveRowAtIndexPath:index1
                           toIndexPath:index2];
    
    [self.collectionView moveItemAtIndexPath:index1
                                 toIndexPath:index2];
}

- (void)moveSectionAtIndex:(NSInteger)index1 toIndex:(NSInteger)index2 {
    [self.tableView moveSection:index1
                      toSection:index2];
    
    [self.collectionView moveSection:index1
                           toSection:index2];
}

- (void)insertSectionsAtIndexes:(NSIndexSet *)indexes {
    [self.tableView insertSections:indexes
                  withRowAnimation:self.rowAnimation];
    
    [self.collectionView insertSections:indexes];
    
    [self _updateEmptyView];
}

- (void)deleteSectionsAtIndexes:(NSIndexSet *)indexes {
    [self.tableView deleteSections:indexes
                  withRowAnimation:self.rowAnimation];
    
    [self.collectionView deleteSections:indexes];
    
    [self _updateEmptyView];
}

- (void)reloadSectionsAtIndexes:(NSIndexSet *)indexes {
    [self.tableView reloadSections:indexes
                  withRowAnimation:self.rowAnimation];

    [self.collectionView reloadSections:indexes];
}

- (void)reloadData {
     _currentFilter = nil;
    
    [self.tableView reloadData];
    [self.collectionView reloadData];
    
  //  [self _updateEmptyView];
}

#pragma mark - Filtering

- (void)setCurrentFilter:(SSResultsFilter *)newFilter {
    SSResultsFilter *currentFilter = self.currentFilter;
    
    NSMutableArray *inserts = [NSMutableArray new];
    NSMutableArray *deletes = [NSMutableArray new];
    
    if (!newFilter && currentFilter) {
        _currentFilter = nil;
        
        // Restore objects that did not pass the current filter.
        [self enumerateItemsWithBlock:^(NSIndexPath *indexPath,
                                        id item,
                                        BOOL *stop) {
            if (![currentFilter.filterPredicate evaluateWithObject:item]) {
                [inserts addObject:indexPath];
            }
        }];
        
        if ([inserts count] > 0) {
            [self insertCellsAtIndexPaths:inserts];
        }
    } else if (newFilter && !currentFilter) {
        // No current filter. Remove any object not passing the new filter.
        [newFilter.sections removeAllObjects];
        
        for (NSUInteger i = 0; i < [self numberOfSections]; i++) {
            
            NSMutableArray *sectionItems = [NSMutableArray new];
            
            for (NSUInteger j = 0; j < [self numberOfItemsInSection:i]; j++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                id item = [self itemAtIndexPath:indexPath];
                
                if (![newFilter.filterPredicate evaluateWithObject:item]) {
                    [deletes addObject:indexPath];
                } else {
                    [sectionItems addObject:item];
                }
            }
            
            [newFilter.sections addObject:sectionItems];
        }
        
        _currentFilter = newFilter;
        
        if ([deletes count] > 0) {
            [self deleteCellsAtIndexPaths:deletes];
        }
    } else if (newFilter && currentFilter) {
        // Changing active filter
        
        [self enumerateItemsWithBlock:^(NSIndexPath *indexPath,
                                        id item,
                                        BOOL *stop) {
            [deletes addObject:indexPath];
        }];
        
        [newFilter.sections removeAllObjects];
        
        _currentFilter = nil;
        
        for (NSUInteger i = 0; i < [self numberOfSections]; i++) {
            
            NSMutableArray *sectionItems = [NSMutableArray new];
            
            for (NSUInteger j = 0; j < [self numberOfItemsInSection:i]; j++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                id item = [self itemAtIndexPath:indexPath];
                
                if ([newFilter.filterPredicate evaluateWithObject:item]) {
                    [inserts addObject:[NSIndexPath indexPathForRow:([sectionItems count])
                                                          inSection:i]];
                    [sectionItems addObject:item];
                }
            }
            
            [newFilter.sections addObject:sectionItems];
        }
        
        _currentFilter = newFilter;
        
        void (^ProcessIndexUpdatesBlock)(void) = ^{
            if ([deletes count] > 0) {
                [self deleteCellsAtIndexPaths:deletes];
            }
            
            if ([inserts count] > 0) {
                [self insertCellsAtIndexPaths:inserts];
            }
        };
        
        if (self.tableView) {
            [self.tableView beginUpdates];
            ProcessIndexUpdatesBlock();
            [self.tableView endUpdates];
        }
        
        if (self.collectionView) {
            [self.collectionView performBatchUpdates:ProcessIndexUpdatesBlock
                                          completion:nil];
        }
    }
}


@end
